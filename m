From: Jingju Hou <houjingj@marvell.com>
Subject: [PATCH v3 net-next] net: mvneta: implement .set_wol and .get_wol
Date: Mon, 23 Jan 2017 12:11:18 +0800
Message-ID: <1485144678-11777-1-git-send-email-houjingj@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jszhang@marvell.com>, <thomas.petazzoni@free-electrons.com>,
        <netdev@vger.kernel.org>, Jingju Hou <houjingj@marvell.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016f401.pphosted.com ([67.231.148.174]:37025 "EHLO
        mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750712AbdAWEMA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 23:12:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mvneta itself does not support WOL, but the PHY might.
So pass the calls to the PHY

Signed-off-by: Jingju Hou <houjingj@marvell.com>
---
Since v2:
- it should be phydev member not phy_dev

 drivers/net/ethernet/marvell/mvneta.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index e05e227..fea4968 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3908,6 +3908,25 @@ static int mvneta_ethtool_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
 	return 0;
 }
 
+static void
+mvneta_ethtool_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	wol->supported = 0;
+	wol->wolopts = 0;
+
+	if (dev->phy_dev)
+		return phy_ethtool_get_wol(dev->phydev, wol);
+}
+
+static int
+mvneta_ethtool_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
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
@@ -3937,6 +3956,8 @@ static int mvneta_ethtool_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
 	.set_rxfh	= mvneta_ethtool_set_rxfh,
 	.get_link_ksettings = phy_ethtool_get_link_ksettings,
 	.set_link_ksettings = mvneta_ethtool_set_link_ksettings,
+	.get_wol        = mvneta_ethtool_get_wol,
+	.set_wol        = mvneta_ethtool_set_wol,
 };
 
 /* Initialize hw */
-- 
1.9.1
