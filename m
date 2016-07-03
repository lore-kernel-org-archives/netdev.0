From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: bcmgenet: use phy_ethtool_{get|set}_link_ksettings
Date: Sun,  3 Jul 2016 17:33:57 +0200
Message-ID: <1467560037-21784-2-git-send-email-tremyfr@gmail.com>
References: <1467560037-21784-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: f.fainelli@gmail.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467560037-21784-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c |   28 +----------------------
 1 files changed, 2 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 8d4f849..76ed6df 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -450,30 +450,6 @@ static inline void bcmgenet_rdma_ring_writel(struct bcmgenet_priv *priv,
 			genet_dma_ring_regs[r]);
 }
 
-static int bcmgenet_get_settings(struct net_device *dev,
-				 struct ethtool_cmd *cmd)
-{
-	if (!netif_running(dev))
-		return -EINVAL;
-
-	if (!dev->phydev)
-		return -ENODEV;
-
-	return phy_ethtool_gset(dev->phydev, cmd);
-}
-
-static int bcmgenet_set_settings(struct net_device *dev,
-				 struct ethtool_cmd *cmd)
-{
-	if (!netif_running(dev))
-		return -EINVAL;
-
-	if (!dev->phydev)
-		return -ENODEV;
-
-	return phy_ethtool_sset(dev->phydev, cmd);
-}
-
 static int bcmgenet_set_rx_csum(struct net_device *dev,
 				netdev_features_t wanted)
 {
@@ -977,8 +953,6 @@ static struct ethtool_ops bcmgenet_ethtool_ops = {
 	.get_strings		= bcmgenet_get_strings,
 	.get_sset_count		= bcmgenet_get_sset_count,
 	.get_ethtool_stats	= bcmgenet_get_ethtool_stats,
-	.get_settings		= bcmgenet_get_settings,
-	.set_settings		= bcmgenet_set_settings,
 	.get_drvinfo		= bcmgenet_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
 	.get_msglevel		= bcmgenet_get_msglevel,
@@ -990,6 +964,8 @@ static struct ethtool_ops bcmgenet_ethtool_ops = {
 	.nway_reset		= bcmgenet_nway_reset,
 	.get_coalesce		= bcmgenet_get_coalesce,
 	.set_coalesce		= bcmgenet_set_coalesce,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 /* Power down the unimac, based on mode. */
-- 
1.7.4.4
