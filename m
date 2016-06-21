From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: macb: use phy_ethtool_{get|set}_link_ksettings
Date: Wed, 22 Jun 2016 00:32:36 +0200
Message-ID: <1466548356-19166-2-git-send-email-tremyfr@gmail.com>
References: <1466548356-19166-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466548356-19166-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/cadence/macb.c |   30 ++++--------------------------
 1 files changed, 4 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 090463f..89c0cfa 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2091,28 +2091,6 @@ static struct net_device_stats *macb_get_stats(struct net_device *dev)
 	return nstat;
 }
 
-static int macb_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	struct macb *bp = netdev_priv(dev);
-	struct phy_device *phydev = dev->phydev;
-
-	if (!phydev)
-		return -ENODEV;
-
-	return phy_ethtool_gset(phydev, cmd);
-}
-
-static int macb_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	struct macb *bp = netdev_priv(dev);
-	struct phy_device *phydev = dev->phydev;
-
-	if (!phydev)
-		return -ENODEV;
-
-	return phy_ethtool_sset(phydev, cmd);
-}
-
 static int macb_get_regs_len(struct net_device *netdev)
 {
 	return MACB_GREGS_NBR * sizeof(u32);
@@ -2185,19 +2163,17 @@ static int macb_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 }
 
 static const struct ethtool_ops macb_ethtool_ops = {
-	.get_settings		= macb_get_settings,
-	.set_settings		= macb_set_settings,
 	.get_regs_len		= macb_get_regs_len,
 	.get_regs		= macb_get_regs,
 	.get_link		= ethtool_op_get_link,
 	.get_ts_info		= ethtool_op_get_ts_info,
 	.get_wol		= macb_get_wol,
 	.set_wol		= macb_set_wol,
+	.get_link_ksettings     = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings     = phy_ethtool_set_link_ksettings,
 };
 
 static const struct ethtool_ops gem_ethtool_ops = {
-	.get_settings		= macb_get_settings,
-	.set_settings		= macb_set_settings,
 	.get_regs_len		= macb_get_regs_len,
 	.get_regs		= macb_get_regs,
 	.get_link		= ethtool_op_get_link,
@@ -2205,6 +2181,8 @@ static const struct ethtool_ops gem_ethtool_ops = {
 	.get_ethtool_stats	= gem_get_ethtool_stats,
 	.get_strings		= gem_get_ethtool_strings,
 	.get_sset_count		= gem_get_sset_count,
+	.get_link_ksettings     = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings     = phy_ethtool_set_link_ksettings,
 };
 
 static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
-- 
1.7.4.4
