From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH 1/2] tlan: use msecs_to_jiffies for conversion
Date: Tue,  3 Feb 2015 03:44:45 -0500
Message-ID: <1422953085-19797-1-git-send-email-hofrat@osadl.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is only an API consolidation and should make things more readable
it replaces var * HZ / 1000 by msecs_to_jiffies(var).

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Converting milliseconds to jiffies by val * HZ / 1000 is technically
not wrong but msecs_to_jiffies(val) is the cleaner solution and handles
all corner cases correctly. This is a minor API cleanup only.

Patch was only compile tested for x86_64_defconfig + CONFIG_TLAN=m

Patch is against 3.0.19-rc7 (localversion = -next-20150203)

 drivers/net/ethernet/ti/tlan.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index f2ff007..1f722c9 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -2540,7 +2540,7 @@ static void tlan_phy_power_down(struct net_device *dev)
 	 * This is abitrary.  It is intended to make sure the
 	 * transceiver settles.
 	 */
-	tlan_set_timer(dev, (HZ/20), TLAN_TIMER_PHY_PUP);
+	tlan_set_timer(dev, msecs_to_jiffies(50), TLAN_TIMER_PHY_PUP);
 
 }
 
@@ -2593,7 +2593,7 @@ static void tlan_phy_reset(struct net_device *dev)
 	 * I don't remember why I wait this long.
 	 * I've changed this to 50ms, as it seems long enough.
 	 */
-	tlan_set_timer(dev, (HZ/20), TLAN_TIMER_PHY_START_LINK);
+	tlan_set_timer(dev, msecs_to_jiffies(50), TLAN_TIMER_PHY_START_LINK);
 
 }
 
@@ -2658,7 +2658,7 @@ static void tlan_phy_start_link(struct net_device *dev)
 		data = TLAN_NET_CFG_1FRAG | TLAN_NET_CFG_1CHAN
 			| TLAN_NET_CFG_PHY_EN;
 		tlan_dio_write16(dev->base_addr, TLAN_NET_CONFIG, data);
-		tlan_set_timer(dev, (40*HZ/1000), TLAN_TIMER_PHY_PDOWN);
+		tlan_set_timer(dev, msecs_to_jiffies(40), TLAN_TIMER_PHY_PDOWN);
 		return;
 	} else if (priv->phy_num == 0) {
 		control = 0;
@@ -2725,7 +2725,7 @@ static void tlan_phy_finish_auto_neg(struct net_device *dev)
 	    (priv->adapter->flags & TLAN_ADAPTER_USE_INTERN_10) &&
 	    (priv->phy_num != 0)) {
 		priv->phy_num = 0;
-		tlan_set_timer(dev, (400*HZ/1000), TLAN_TIMER_PHY_PDOWN);
+		tlan_set_timer(dev, msecs_to_jiffies(400), TLAN_TIMER_PHY_PDOWN);
 		return;
 	}
 
@@ -2744,7 +2744,7 @@ static void tlan_phy_finish_auto_neg(struct net_device *dev)
 
 	/* Wait for 100 ms.  No reason in partiticular.
 	 */
-	tlan_set_timer(dev, (HZ/10), TLAN_TIMER_FINISH_RESET);
+	tlan_set_timer(dev, msecs_to_jiffies(100), TLAN_TIMER_FINISH_RESET);
 
 }
 
@@ -2796,7 +2796,7 @@ static void tlan_phy_monitor(unsigned long data)
 				/* set to external PHY */
 				priv->phy_num = 1;
 				/* restart autonegotiation */
-				tlan_set_timer(dev, 4 * HZ / 10,
+				tlan_set_timer(dev, msecs_to_jiffies(400),
 					       TLAN_TIMER_PHY_PDOWN);
 				return;
 			}
-- 
1.7.10.4
