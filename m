From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: cirrus: ep93xx: use new api ethtool_{get|set}_link_ksettings
Date: Mon, 12 Dec 2016 23:28:33 +0100
Message-ID: <1481581713-6590-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: hsweeten@visionengravers.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/cirrus/ep93xx_eth.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/ep93xx_eth.c b/drivers/net/ethernet/cirrus/ep93xx_eth.c
index a1de0d1..396c886 100644
--- a/drivers/net/ethernet/cirrus/ep93xx_eth.c
+++ b/drivers/net/ethernet/cirrus/ep93xx_eth.c
@@ -715,16 +715,18 @@ static void ep93xx_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *i
 	strlcpy(info->version, DRV_MODULE_VERSION, sizeof(info->version));
 }
 
-static int ep93xx_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int ep93xx_get_link_ksettings(struct net_device *dev,
+				     struct ethtool_link_ksettings *cmd)
 {
 	struct ep93xx_priv *ep = netdev_priv(dev);
-	return mii_ethtool_gset(&ep->mii, cmd);
+	return mii_ethtool_get_link_ksettings(&ep->mii, cmd);
 }
 
-static int ep93xx_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int ep93xx_set_link_ksettings(struct net_device *dev,
+				     const struct ethtool_link_ksettings *cmd)
 {
 	struct ep93xx_priv *ep = netdev_priv(dev);
-	return mii_ethtool_sset(&ep->mii, cmd);
+	return mii_ethtool_set_link_ksettings(&ep->mii, cmd);
 }
 
 static int ep93xx_nway_reset(struct net_device *dev)
@@ -741,10 +743,10 @@ static u32 ep93xx_get_link(struct net_device *dev)
 
 static const struct ethtool_ops ep93xx_ethtool_ops = {
 	.get_drvinfo		= ep93xx_get_drvinfo,
-	.get_settings		= ep93xx_get_settings,
-	.set_settings		= ep93xx_set_settings,
 	.nway_reset		= ep93xx_nway_reset,
 	.get_link		= ep93xx_get_link,
+	.get_link_ksettings	= ep93xx_get_link_ksettings,
+	.set_link_ksettings	= ep93xx_set_link_ksettings,
 };
 
 static const struct net_device_ops ep93xx_netdev_ops = {
-- 
1.7.4.4
