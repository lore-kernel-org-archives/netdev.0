From: domen@coderock.org
Subject: [patch 07/19] net/sir_dev: replace schedule_timeout() with msleep()
Date: Wed, 12 Jan 2005 00:10:27 +0100
Message-ID: <20050111231027.03D691F225@trashy.coderock.org>
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


 kj-domen/drivers/net/irda/sir_dev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/irda/sir_dev.c~msleep-drivers_net_irda_sir_dev drivers/net/irda/sir_dev.c
--- kj/drivers/net/irda/sir_dev.c~msleep-drivers_net_irda_sir_dev	2005-01-10 18:00:01.000000000 +0100
+++ kj-domen/drivers/net/irda/sir_dev.c	2005-01-10 18:00:01.000000000 +0100
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
