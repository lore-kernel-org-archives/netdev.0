From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: ax88796: use phy_ethtool_{get|set}_link_ksettings
Date: Thu, 16 Jun 2016 00:12:49 +0200
Message-ID: <1466028769-27866-2-git-send-email-tremyfr@gmail.com>
References: <1466028769-27866-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: andrew@lunn.ch, davem@davemloft.net, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466028769-27866-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/8390/ax88796.c |   24 ++----------------------
 1 files changed, 2 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
index b446977..5698f53 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -470,26 +470,6 @@ static void ax_get_drvinfo(struct net_device *dev,
 	strlcpy(info->bus_info, pdev->name, sizeof(info->bus_info));
 }
 
-static int ax_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	struct phy_device *phy_dev = dev->phydev;
-
-	if (!phy_dev)
-		return -ENODEV;
-
-	return phy_ethtool_gset(phy_dev, cmd);
-}
-
-static int ax_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	struct phy_device *phy_dev = dev->phydev;
-
-	if (!phy_dev)
-		return -ENODEV;
-
-	return phy_ethtool_sset(phy_dev, cmd);
-}
-
 static u32 ax_get_msglevel(struct net_device *dev)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
@@ -506,12 +486,12 @@ static void ax_set_msglevel(struct net_device *dev, u32 v)
 
 static const struct ethtool_ops ax_ethtool_ops = {
 	.get_drvinfo		= ax_get_drvinfo,
-	.get_settings		= ax_get_settings,
-	.set_settings		= ax_set_settings,
 	.get_link		= ethtool_op_get_link,
 	.get_ts_info		= ethtool_op_get_ts_info,
 	.get_msglevel		= ax_get_msglevel,
 	.set_msglevel		= ax_set_msglevel,
+	.get_link_ksettings	= phy_ethtool_get_link_ksettings,
+	.set_link_ksettings	= phy_ethtool_set_link_ksettings,
 };
 
 #ifdef CONFIG_AX88796_93CX6
-- 
1.7.4.4
