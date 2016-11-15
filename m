From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 08/15] net: ethernet: ixp4xx_eth: Utilize phy_ethtool_nway_reset
Date: Tue, 15 Nov 2016 10:06:37 -0800
Message-ID: <20161115180644.3941-9-f.fainelli@gmail.com>
References: <20161115180644.3941-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, tremyfr@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Krzysztof Halasa <khalasa@piap.pl>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115180644.3941-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/xscale/ixp4xx_eth.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index 07d862d90869..aee55c03def0 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -1001,11 +1001,6 @@ static void ixp4xx_get_drvinfo(struct net_device *dev,
 	strlcpy(info->bus_info, "internal", sizeof(info->bus_info));
 }
 
-static int ixp4xx_nway_reset(struct net_device *dev)
-{
-	return phy_start_aneg(dev->phydev);
-}
-
 int ixp46x_phc_index = -1;
 EXPORT_SYMBOL_GPL(ixp46x_phc_index);
 
@@ -1037,7 +1032,7 @@ static int ixp4xx_get_ts_info(struct net_device *dev,
 
 static const struct ethtool_ops ixp4xx_ethtool_ops = {
 	.get_drvinfo = ixp4xx_get_drvinfo,
-	.nway_reset = ixp4xx_nway_reset,
+	.nway_reset = phy_ethtool_nway_reset,
 	.get_link = ethtool_op_get_link,
 	.get_ts_info = ixp4xx_get_ts_info,
 	.get_link_ksettings = phy_ethtool_get_link_ksettings,
-- 
2.9.3
