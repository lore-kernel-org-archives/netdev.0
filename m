From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH v2 net-next 3/3] net: bcmgenet: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 25 Sep 2016 18:29:27 +0200
Message-ID: <1474820967-1130-4-git-send-email-tremyfr@gmail.com>
References: <1474820967-1130-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: f.fainelli@gmail.com, jaedon.shin@gmail.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474820967-1130-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c |   24 ++++++++++--------------
 1 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 47d0a2b..2c5d9d3 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -450,32 +450,28 @@ static inline void bcmgenet_rdma_ring_writel(struct bcmgenet_priv *priv,
 			genet_dma_ring_regs[r]);
 }
 
-static int bcmgenet_get_settings(struct net_device *dev,
-				 struct ethtool_cmd *cmd)
+static int bcmgenet_get_link_ksettings(struct net_device *dev,
+				       struct ethtool_link_ksettings *cmd)
 {
-	struct bcmgenet_priv *priv = netdev_priv(dev);
-
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	if (!priv->phydev)
+	if (!dev->phydev)
 		return -ENODEV;
 
-	return phy_ethtool_gset(priv->phydev, cmd);
+	return phy_ethtool_ksettings_get(dev->phydev, cmd);
 }
 
-static int bcmgenet_set_settings(struct net_device *dev,
-				 struct ethtool_cmd *cmd)
+static int bcmgenet_set_link_ksettings(struct net_device *dev,
+				       const struct ethtool_link_ksettings *cmd)
 {
-	struct bcmgenet_priv *priv = netdev_priv(dev);
-
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	if (!priv->phydev)
+	if (!dev->phydev)
 		return -ENODEV;
 
-	return phy_ethtool_sset(priv->phydev, cmd);
+	return phy_ethtool_ksettings_set(dev->phydev, cmd);
 }
 
 static int bcmgenet_set_rx_csum(struct net_device *dev,
@@ -983,8 +979,6 @@ static const struct ethtool_ops bcmgenet_ethtool_ops = {
 	.get_strings		= bcmgenet_get_strings,
 	.get_sset_count		= bcmgenet_get_sset_count,
 	.get_ethtool_stats	= bcmgenet_get_ethtool_stats,
-	.get_settings		= bcmgenet_get_settings,
-	.set_settings		= bcmgenet_set_settings,
 	.get_drvinfo		= bcmgenet_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
 	.get_msglevel		= bcmgenet_get_msglevel,
@@ -996,6 +990,8 @@ static const struct ethtool_ops bcmgenet_ethtool_ops = {
 	.nway_reset		= bcmgenet_nway_reset,
 	.get_coalesce		= bcmgenet_get_coalesce,
 	.set_coalesce		= bcmgenet_set_coalesce,
+	.get_link_ksettings	= bcmgenet_get_link_ksettings,
+	.set_link_ksettings	= bcmgenet_set_link_ksettings,
 };
 
 /* Power down the unimac, based on mode. */
-- 
1.7.4.4
