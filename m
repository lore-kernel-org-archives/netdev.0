From: Andy Fleming <afleming@freescale.com>
Subject: schedule_work, a summary
Date: Tue, 7 Sep 2004 15:35:54 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <840161B2-010D-11D9-AF95-000393C30512@freescale.com>
Mime-Version: 1.0 (Apple Message framework v618)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ok, so I got no response.  I will summarize on the theory that people 
tend to ignore long emails:

1) My ethernet driver works in 2.6.8.1, but does not in newer kernels.  
Note that nothing in the driver has changed.  So either there is a bug 
in the kernel now, or one has been exposed in my driver.

2) The bug causes the kernel to stop doing useful work as soon as 
schedule_work is called.  I can confirm that the function executes to 
completion, and that the process of scheduling the work is terminated 
in try_to_wake_up() when it determines that the task (presumably the 
task keventd is running in) is already running.  Once this happens, the 
kernel stops printing out information, and the bdi2000 indicates it is 
frequently in interrupt handling routines.

3) I desperately need to know what's wrong, and if this is not the 
right place to ask, please tell me where is.

Thanks,
Andy Fleming
