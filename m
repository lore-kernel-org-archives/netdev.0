From: janitor@sternwelten.at
Subject: [patch 08/18]  net/cs89x0: replace 	schedule_timeout() with msleep_interruptible()
Date: Sun, 31 Oct 2004 00:42:42 +0200
Message-ID: <E1CO1vn-0002EW-95@sputnik>
Cc: netdev@oss.sgi.com, janitor@sternwelten.at, nacc@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Use msleep_interruptible() instead of schedule_timeout()
to guarantee the task delays as expected.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>

---

 linux-2.6.10-rc1-max/drivers/net/cs89x0.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/cs89x0.c~msleep_interruptible-drivers_net_cs89x0 drivers/net/cs89x0.c
--- linux-2.6.10-rc1/drivers/net/cs89x0.c~msleep_interruptible-drivers_net_cs89x0	2004-10-24 17:05:10.000000000 +0200
+++ linux-2.6.10-rc1-max/drivers/net/cs89x0.c	2004-10-24 17:05:10.000000000 +0200
@@ -93,6 +93,7 @@
    or override something. */
 #include <linux/config.h>
 #include <linux/module.h>
+#include <linux/delay.h>
 
 /*
  * Set this to zero to disable DMA code
@@ -909,8 +910,7 @@ void  __init reset_chip(struct net_devic
 	writereg(dev, PP_SelfCTL, readreg(dev, PP_SelfCTL) | POWER_ON_RESET);
 
 	/* wait 30 ms */
-	current->state = TASK_INTERRUPTIBLE;
-	schedule_timeout(30*HZ/1000);
+	msleep_interruptible(30);
 
 #ifndef CONFIG_ARCH_IXDP2X01
 	if (lp->chip_type != CS8900) {
_
