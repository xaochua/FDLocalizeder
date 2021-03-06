//
//  MPTask.m
//  MobPods
//
//  Created by chuxiao on 16/11/8.
//  Copyright © 2016年 mob.com. All rights reserved.
//

#import "MPTask.h"

//@interface MPTask()
//@property (nonatomic, strong) NSTask *task;
//@property (nonatomic, strong) void(^success)(MPGit);
//@end

@implementation MPTask

/**
 启动 NSTask，执行命令行指令
 
 @param lanunchPath   启动路径
 @param arguments     指令执行参数
 @param directoryPath 指令执行目录
 @param success       成功回调信息
 @param exception     参数错误异常
 */
+ (void)runTaskWithLanunchPath:(NSString *)lanunchPath
                     arguments:(NSArray <NSString *>*)arguments
          currentDirectoryPath:(NSString *)directoryPath
                     onSuccess:(void(^)(NSString *))success
                   onException:(void(^)(NSException *))onException
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^{
        // 检查命令是否存在
        if (![self lanunchPathExist:lanunchPath]) {
            NSLog(@"没有命令执行程序");
            return;
        }
        
        @try
        {
            NSTask *task = [[NSTask alloc] init];
            task.launchPath = lanunchPath;
            if (arguments.count)
            {
                task.arguments = arguments;
            }
            if (directoryPath.length)
            {
                task.currentDirectoryPath = directoryPath;
            }
            //        task.terminationHandler = ^(NSTask *task)
            //        {
            //            NSLog(@"**** end task %@ ****", task);
            //        };
            
            NSPipe *inputPipe = [NSPipe pipe];
            task.standardInput = inputPipe;
            NSPipe *outputPipe = [NSPipe pipe];
            task.standardOutput = outputPipe;
            NSFileHandle *handle = [outputPipe fileHandleForReading];
            
            [task launch];
            [task waitUntilExit];
            
            NSData *data = handle.availableData;
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            
            if (success)
            {
                success(string);
            }
        }
        @catch (NSException *exception)
        {
            if (onException)
            {
                onException(exception);
            }
        }
        @finally
        {
            NSLog(@"NSTask exception handle.");
        }
    });
    
}

// 检查命令执行程序是否存在
+ (BOOL)lanunchPathExist:(NSString *)lanunchPaht{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSInteger fileSize = [[fileManager attributesOfItemAtPath:lanunchPaht error:nil] fileSize];
    
    if (![fileManager fileExistsAtPath:lanunchPaht] && fileSize <= 0){
        return NO;
    }
    return YES;
}

//+ (MPTask *)task
//{
//    MPTask *instance = [[MPTask alloc] init];
//    return instance;
//}
//
//- (instancetype)init
//{
//    if (self == [super init])
//    {
//        self.task = [[NSTask alloc] init];
//    }
//    return self;
//}


//- (void)_readReturnData
//{
//    NSPipe *outputPipe = [NSPipe pipe];
//    self.task.standardOutput = outputPipe;
//    NSFileHandle *file;
//    file = [outputPipe fileHandleForReading];
//    [file waitForDataInBackgroundAndNotify];
//    NSData *data;
//    data = [file readDataToEndOfFile];
//    
//    NSString *string;
//    string = [[NSString alloc] initWithData: data
//                                   encoding: NSUTF8StringEncoding];
//    
//    NSLog(@"_readReturnData : %@", string);
//    
//    if (self.success)
//    {
//        self.success(string);
//    }
    
//    [[outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
    
//    __weak typeof(self) weakSelf = self;
//    [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification
//                                                      object:outputPipe.fileHandleForReading
//                                                       queue:nil
//                                                  usingBlock:^(NSNotification * _Nonnull note)
//     {
//         
//         NSData *oupput = outputPipe.fileHandleForReading.availableData;
//         NSString *outputString = [[NSString alloc] initWithData:oupput encoding:NSUTF8StringEncoding];
//         if (weakSelf.success)
//         {
//             NSLog(@"--------> %@ <--------", outputString);
//             weakSelf.success(outputString);
//         }
//         [[outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
//     }];

//}


@end
