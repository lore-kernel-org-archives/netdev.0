From: janitor@sternwelten.at
Subject: [patch 03/18]  net/ixgb_osdep: replace 	schedule_timeout() with msleep()
Date: Sun, 31 Oct 2004 00:42:25 +0200
Message-ID: <E1CO1vW-0001xA-8u@sputnik>
Cc: netdev@oss.sgi.com, janitor@sternwelten.at, nacc@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Use msleep() instead of schedule_timeout()
to guarantee the task delays as expected. I was told earlier that the
in_interrupt() check is not necessary. It would be nice to get some
verification of this (i.e. the driver functions the same without it).

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>

---

 linux-2.6.10-rc1-max/drivers/net/ixgb/ixgb_osdep.h |    8 +-------
 1 files changed, 1 insertion(+), 7 deletions(-)

diff -puN drivers/net/ixgb/ixgb_osdep.h~msleep-drivers_net_ixgb_ixgb_osdep drivers/net/ixgb/ixgb_osdep.h
--- linux-2.6.10-rc1/drivers/net/ixgb/ixgb_osdep.h~msleep-drivers_net_ixgb_ixgb_osdep	2004-10-24 17:04:57.000000000 +0200
+++ linux-2.6.10-rc1-max/drivers/net/ixgb/ixgb_osdep.h	2004-10-24 17:04:57.000000000 +0200
@@ -41,13 +41,7 @@
 #include <linux/sched.h>
 
 #ifndef msec_delay
-#define msec_delay(x)	do { if(in_interrupt()) { \
-				/* Don't mdelay in interrupt context! */ \
-	                	BUG(); \
-			} else { \
-				set_current_state(TASK_UNINTERRUPTIBLE); \
-				schedule_timeout((x * HZ)/1000 + 2); \
-			} } while(0)
+#define msec_delay(x)	msleep(x)
 #endif
 
 #define PCI_COMMAND_REGISTER   PCI_COMMAND
_
