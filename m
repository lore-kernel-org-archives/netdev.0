From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 6/9] tlan: Don't scream if no link
Date: Tue, 27 May 2014 23:38:44 +0200
Message-ID: <1401226727-5508-7-git-send-email-linux@rainbow-software.org>
References: <1401226727-5508-1-git-send-email-linux@rainbow-software.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401226727-5508-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove excess printks when the link is down.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/ethernet/ti/tlan.c |    9 ---------
 drivers/net/ethernet/ti/tlan.h |    1 -
 2 files changed, 10 deletions(-)

diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index 1047b3f..628a779 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -1199,9 +1199,6 @@ static irqreturn_t tlan_handle_interrupt(int irq, void *dev_id)
 
 static int tlan_close(struct net_device *dev)
 {
-	struct tlan_priv *priv = netdev_priv(dev);
-
-	priv->neg_be_verbose = 0;
 	tlan_stop(dev);
 
 	free_irq(dev->irq, dev);
@@ -2702,12 +2699,6 @@ static void tlan_phy_finish_auto_neg(struct net_device *dev)
 		/* Wait for 8 sec to give the process
 		 * more time.  Perhaps we should fail after a while.
 		 */
-		if (!priv->neg_be_verbose++) {
-			pr_info("Giving autonegotiation more time.\n");
-			pr_info("Please check that your adapter has\n");
-			pr_info("been properly connected to a HUB or Switch.\n");
-			pr_info("Trying to establish link in the background...\n");
-		}
 		tlan_set_timer(dev, (8*HZ), TLAN_TIMER_PHY_FINISH_AN);
 		return;
 	}
diff --git a/drivers/net/ethernet/ti/tlan.h b/drivers/net/ethernet/ti/tlan.h
index b6ceeba..e992841 100644
--- a/drivers/net/ethernet/ti/tlan.h
+++ b/drivers/net/ethernet/ti/tlan.h
@@ -208,7 +208,6 @@ struct tlan_priv {
 	u8			tlan_full_duplex;
 	spinlock_t		lock;
 	struct work_struct			tlan_tqueue;
-	u8			neg_be_verbose;
 };
 
 
-- 
Ondrej Zary
