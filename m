From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: tc35815: use phy_ethtool_{get|set}_link_ksettings
Date: Thu, 14 Jul 2016 15:20:47 +0200
Message-ID: <1468502447-2254-2-git-send-email-tremyfr@gmail.com>
References: <1468502447-2254-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, andrew@lunn.ch, linux@roeck-us.net,
	colin.king@canonical.com, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468502447-2254-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/toshiba/tc35815.c |   18 ++----------------
 1 files changed, 2 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index cdf8d58..5b01b3f 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -1944,20 +1944,6 @@ static void tc35815_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *
 	strlcpy(info->bus_info, pci_name(lp->pci_dev), sizeof(info->bus_info));
 }
 
-static int tc35815_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	if (!dev->phydev)
-		return -ENODEV;
-	return phy_ethtool_gset(dev->phydev, cmd);
-}
-
-static int tc35815_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	if (!dev->phydev)
-		return -ENODEV;
-	return phy_ethtool_sset(dev->phydev, cmd);
-}
-
 static u32 tc35815_get_msglevel(struct net_device *dev)
 {
 	struct tc35815_local *lp = netdev_priv(dev);
@@ -2007,14 +1993,14 @@ static void tc35815_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 
 static const struct ethtool_ops tc35815_ethtool_ops = {
 	.get_drvinfo		= tc35815_get_drvinfo,
-	.get_settings		= tc35815_get_settings,
-	.set_settings		= tc35815_set_settings,
 	.get_link		= ethtool_op_get_link,
 	.get_msglevel		= tc35815_get_msglevel,
 	.set_msglevel		= tc35815_set_msglevel,
 	.get_strings		= tc35815_get_strings,
 	.get_sset_count		= tc35815_get_sset_count,
 	.get_ethtool_stats	= tc35815_get_ethtool_stats,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 static int tc35815_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
-- 
1.7.4.4
