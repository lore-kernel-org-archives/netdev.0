From: domen@coderock.org
Subject: [patch 08/19] net/ixgb_osdep: replace schedule_timeout() with msleep()
Date: Wed, 12 Jan 2005 00:10:30 +0100
Message-ID: <20050111231031.49F9D1F22A@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, nacc@us.ibm.com,
        janitor@sternwelten.at
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
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/ixgb/ixgb_osdep.h |    8 +-------
 1 files changed, 1 insertion(+), 7 deletions(-)

diff -puN drivers/net/ixgb/ixgb_osdep.h~msleep-drivers_net_ixgb_ixgb_osdep drivers/net/ixgb/ixgb_osdep.h
--- kj/drivers/net/ixgb/ixgb_osdep.h~msleep-drivers_net_ixgb_ixgb_osdep	2005-01-10 18:00:01.000000000 +0100
+++ kj-domen/drivers/net/ixgb/ixgb_osdep.h	2005-01-10 18:00:01.000000000 +0100
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
