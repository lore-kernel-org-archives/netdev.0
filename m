From: janitor@sternwelten.at
Subject: [patch 09/16]  ixgb/ixgb_osdep: replace 	schedule_timeout() with msleep()
Date: Wed, 01 Sep 2004 23:03:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C2cGH-0007qo-Fw@sputnik>
Cc: jgarzik@pobox.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org







I would appreciate any comments from the janitor@sternweltens list. 



Description: Replace schedule_timeout() with msleep() to guarantee the
task delays for the desired time. Redefine msec_delay(x) to directly
call msleep(x).

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>



---

 linux-2.6.9-rc1-bk7-max/drivers/net/ixgb/ixgb_osdep.h |    8 +-------
 1 files changed, 1 insertion(+), 7 deletions(-)

diff -puN drivers/net/ixgb/ixgb_osdep.h~msleep-drivers_net_ixgb_osdep drivers/net/ixgb/ixgb_osdep.h
--- linux-2.6.9-rc1-bk7/drivers/net/ixgb/ixgb_osdep.h~msleep-drivers_net_ixgb_osdep	2004-09-01 19:35:34.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/drivers/net/ixgb/ixgb_osdep.h	2004-09-01 19:35:34.000000000 +0200
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
