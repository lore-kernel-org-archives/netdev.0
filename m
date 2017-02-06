From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH v5 net-next] net: mvneta: implement .set_wol and .get_wol
Date: Mon, 6 Feb 2017 14:58:13 +0800
Message-ID: <20170206065813.1971-1-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Jingju Hou <houjingj@marvell.com>,
        Jisheng Zhang <jszhang@marvell.com>
To: <thomas.petazzoni@free-electrons.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jingju Hou <houjingj@marvell.com>

The mvneta itself does not support WOL, but the PHY might.
So pass the calls to the PHY

Signed-off-by: Jingju Hou <houjingj@marvell.com>
Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
---
since v4:
 - address Andrew Lunn's comment

since v3:
 - really fix the build error

since v2,v1:
 - using phy_dev member in struct net_device
 - add commit msg

 drivers/net/ethernet/marvell/mvneta.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index de6c47744b8e..0f4d1697be46 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3927,6 +3927,25 @@ static int mvneta_ethtool_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
 	return 0;
 }
 
+static void mvneta_ethtool_get_wol(struct net_device *dev,
+				   struct ethtool_wolinfo *wol)
+{
+	wol->supported = 0;
+	wol->wolopts = 0;
+
+	if (dev->phydev)
+		phy_ethtool_get_wol(dev->phydev, wol);
+}
+
+static int mvneta_ethtool_set_wol(struct net_device *dev,
+				  struct ethtool_wolinfo *wol)
+{
+	if (!dev->phydev)
+		return -EOPNOTSUPP;
+
+	return phy_ethtool_set_wol(dev->phydev, wol);
+}
+
 static const struct net_device_ops mvneta_netdev_ops = {
 	.ndo_open            = mvneta_open,
 	.ndo_stop            = mvneta_stop,
@@ -3956,6 +3975,8 @@ const struct ethtool_ops mvneta_eth_tool_ops = {
 	.set_rxfh	= mvneta_ethtool_set_rxfh,
 	.get_link_ksettings = phy_ethtool_get_link_ksettings,
 	.set_link_ksettings = mvneta_ethtool_set_link_ksettings,
+	.get_wol        = mvneta_ethtool_get_wol,
+	.set_wol        = mvneta_ethtool_set_wol,
 };
 
 /* Initialize hw */
-- 
2.11.0
