From: janitor@sternwelten.at
Subject: [patch 4/8]  irda/sir_dev: replace schedule_timeout() 	with msleep()
Date: Wed, 01 Sep 2004 23:05:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C2cIW-000816-6g@sputnik>
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

 linux-2.6.9-rc1-bk7-max/drivers/net/irda/sir_dev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/irda/sir_dev.c~msleep-drivers_net_irda_sir_dev drivers/net/irda/sir_dev.c
--- linux-2.6.9-rc1-bk7/drivers/net/irda/sir_dev.c~msleep-drivers_net_irda_sir_dev	2004-09-01 19:35:32.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/drivers/net/irda/sir_dev.c	2004-09-01 19:35:32.000000000 +0200
@@ -15,6 +15,7 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/smp_lock.h>
+#include <linux/delay.h>
 
 #include <net/irda/irda.h>
 #include <net/irda/wrapper.h>
@@ -73,8 +74,7 @@ int sirdev_raw_write(struct sir_dev *dev
 	spin_lock_irqsave(&dev->tx_lock, flags);	/* serialize with other tx operations */
 	while (dev->tx_buff.len > 0) {			/* wait until tx idle */
 		spin_unlock_irqrestore(&dev->tx_lock, flags);
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(msecs_to_jiffies(10));
+		msleep(10);
 		spin_lock_irqsave(&dev->tx_lock, flags);
 	}
 

_
