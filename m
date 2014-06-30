From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 06/11] tlan: Don't scream if no link
Date: Mon, 30 Jun 2014 18:38:32 +0200
Message-ID: <1404146317-3094-7-git-send-email-linux@rainbow-software.org>
References: <1404146317-3094-1-git-send-email-linux@rainbow-software.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404146317-3094-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove excess printks when the link is down.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/ethernet/ti/tlan.c |    9 ---------
 drivers/net/ethernet/ti/tlan.h |    1 -
 2 files changed, 10 deletions(-)

diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index 1b64ddc..2d70a89 100644
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
