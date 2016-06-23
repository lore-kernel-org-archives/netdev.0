From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: dnet: use phy_ethtool_{get|set}_link_ksettings
Date: Thu, 23 Jun 2016 23:48:59 +0200
Message-ID: <1466718539-6526-2-git-send-email-tremyfr@gmail.com>
References: <1466718539-6526-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: andrew@lunn.ch, davem@davemloft.net, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466718539-6526-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/dnet.c |   24 ++----------------------
 1 files changed, 2 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index 9c6955f..c3b64cd 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -730,26 +730,6 @@ static struct net_device_stats *dnet_get_stats(struct net_device *dev)
 	return nstat;
 }
 
-static int dnet_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	struct phy_device *phydev = dev->phydev;
-
-	if (!phydev)
-		return -ENODEV;
-
-	return phy_ethtool_gset(phydev, cmd);
-}
-
-static int dnet_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	struct phy_device *phydev = dev->phydev;
-
-	if (!phydev)
-		return -ENODEV;
-
-	return phy_ethtool_sset(phydev, cmd);
-}
-
 static int dnet_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct phy_device *phydev = dev->phydev;
@@ -772,11 +752,11 @@ static void dnet_get_drvinfo(struct net_device *dev,
 }
 
 static const struct ethtool_ops dnet_ethtool_ops = {
-	.get_settings		= dnet_get_settings,
-	.set_settings		= dnet_set_settings,
 	.get_drvinfo		= dnet_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
 	.get_ts_info		= ethtool_op_get_ts_info,
+	.get_link_ksettings     = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings     = phy_ethtool_set_link_ksettings,
 };
 
 static const struct net_device_ops dnet_netdev_ops = {
-- 
1.7.4.4
