From: domen@coderock.org
Subject: [patch 04/19] net/irtty-sir: replace schedule_timeout() with msleep()
Date: Wed, 12 Jan 2005 00:10:18 +0100
Message-ID: <20050111231018.A3ADB1F225@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, nacc@us.ibm.com,
        janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Use msleep() instead of schedule_timeout()
to guarantee the task delays as expected.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/irda/irtty-sir.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/irda/irtty-sir.c~msleep-drivers_net_irda_irtty-sir drivers/net/irda/irtty-sir.c
--- kj/drivers/net/irda/irtty-sir.c~msleep-drivers_net_irda_irtty-sir	2005-01-10 17:59:59.000000000 +0100
+++ kj-domen/drivers/net/irda/irtty-sir.c	2005-01-10 17:59:59.000000000 +0100
@@ -32,6 +32,7 @@
 #include <linux/init.h>
 #include <asm/uaccess.h>
 #include <linux/smp_lock.h>
+#include <linux/delay.h>
 
 #include <net/irda/irda.h>
 #include <net/irda/irda_device.h>
@@ -97,8 +98,7 @@ static void irtty_wait_until_sent(struct
 		unlock_kernel();
 	}
 	else {
-		set_task_state(current, TASK_UNINTERRUPTIBLE);
-		schedule_timeout(msecs_to_jiffies(USBSERIAL_TX_DONE_DELAY));
+		msleep(USBSERIAL_TX_DONE_DELAY);
 	}
 }
 
_
