From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: ixp4xx_eth: use phy_ethtool_{get|set}_link_ksettings
Date: Sat,  2 Jul 2016 14:06:15 +0200
Message-ID: <1467461175-25137-2-git-send-email-tremyfr@gmail.com>
References: <1467461175-25137-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: khalasa@piap.pl, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467461175-25137-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/xscale/ixp4xx_eth.c |   14 ++------------
 1 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index a7778d9..7f127dc 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -1002,16 +1002,6 @@ static void ixp4xx_get_drvinfo(struct net_device *dev,
 	strlcpy(info->bus_info, "internal", sizeof(info->bus_info));
 }
 
-static int ixp4xx_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	return phy_ethtool_gset(dev->phydev, cmd);
-}
-
-static int ixp4xx_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	return phy_ethtool_sset(dev->phydev, cmd);
-}
-
 static int ixp4xx_nway_reset(struct net_device *dev)
 {
 	return phy_start_aneg(dev->phydev);
@@ -1048,11 +1038,11 @@ static int ixp4xx_get_ts_info(struct net_device *dev,
 
 static const struct ethtool_ops ixp4xx_ethtool_ops = {
 	.get_drvinfo = ixp4xx_get_drvinfo,
-	.get_settings = ixp4xx_get_settings,
-	.set_settings = ixp4xx_set_settings,
 	.nway_reset = ixp4xx_nway_reset,
 	.get_link = ethtool_op_get_link,
 	.get_ts_info = ixp4xx_get_ts_info,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 
-- 
1.7.4.4
