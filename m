From: janitor@sternwelten.at
Subject: [patch 2/8]  irda/irtty-sir: replace 	schedule_timeout() with msleep()
Date: Wed, 01 Sep 2004 23:05:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C2cIL-0007zg-5D@sputnik>
Cc: jgarzik@pobox.com, jt@hpl.hp.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org







I would appreciate any comments from the janitor@sternweltens list. 



Description: Replace schedule_timeout() with msleep() to guarantee the
task delays for the desired time.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>



---

 linux-2.6.9-rc1-bk7-max/drivers/net/irda/irtty-sir.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff -puN drivers/net/irda/irtty-sir.c~msleep-drivers_net_irda_irtty-sir drivers/net/irda/irtty-sir.c
--- linux-2.6.9-rc1-bk7/drivers/net/irda/irtty-sir.c~msleep-drivers_net_irda_irtty-sir	2004-09-01 19:35:31.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/drivers/net/irda/irtty-sir.c	2004-09-01 19:35:31.000000000 +0200
@@ -32,6 +32,7 @@
 #include <linux/init.h>
 #include <asm/uaccess.h>
 #include <linux/smp_lock.h>
+#include <linux/delay.h>
 
 #include <net/irda/irda.h>
 #include <net/irda/irda_device.h>
@@ -96,10 +97,8 @@ static void irtty_wait_until_sent(struct
 		tty->driver->wait_until_sent(tty, msecs_to_jiffies(100));
 		unlock_kernel();
 	}
-	else {
-		set_task_state(current, TASK_UNINTERRUPTIBLE);
-		schedule_timeout(msecs_to_jiffies(USBSERIAL_TX_DONE_DELAY));
-	}
+	else
+		msleep(USBSERIAL_TX_DONE_DELAY);
 }
 
 /* 

_
