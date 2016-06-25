From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: r6040: use phy_ethtool_{get|set}_link_ksettings
Date: Sat, 25 Jun 2016 21:09:02 +0200
Message-ID: <1466881742-13414-2-git-send-email-tremyfr@gmail.com>
References: <1466881742-13414-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: florian@openwrt.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466881742-13414-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/rdc/r6040.c |   14 ++------------
 1 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index f2bc7b0..7a7a395 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -954,22 +954,12 @@ static void netdev_get_drvinfo(struct net_device *dev,
 	strlcpy(info->bus_info, pci_name(rp->pdev), sizeof(info->bus_info));
 }
 
-static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	return  phy_ethtool_gset(dev->phydev, cmd);
-}
-
-static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	return phy_ethtool_sset(dev->phydev, cmd);
-}
-
 static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= netdev_get_drvinfo,
-	.get_settings		= netdev_get_settings,
-	.set_settings		= netdev_set_settings,
 	.get_link		= ethtool_op_get_link,
 	.get_ts_info		= ethtool_op_get_ts_info,
+	.get_link_ksettings     = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings     = phy_ethtool_set_link_ksettings,
 };
 
 static const struct net_device_ops r6040_netdev_ops = {
-- 
1.7.4.4
