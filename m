From: Jingju Hou <houjingj@marvell.com>
Subject: [PATCH] net: mvneta: implement .set_wol and .get_wol
Date: Sun, 22 Jan 2017 18:06:30 +0800
Message-ID: <1485079590-6392-1-git-send-email-houjingj@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <thomas.petazzoni@free-electrons.com>, <netdev@vger.kernel.org>,
        Jingju Hou <houjingj@marvell.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016f401.pphosted.com ([67.231.148.174]:48831 "EHLO
        mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750917AbdAVKIn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 05:08:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jingju Hou <houjingj@marvell.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index e05e227..b684f43 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3908,6 +3908,29 @@ static int mvneta_ethtool_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
 	return 0;
 }
 
+static void
+mvneta_ethtool_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct mvneta_port *pp = netdev_priv(dev);
+
+	wol->supported = 0;
+	wol->wolopts = 0;
+
+	if (pp->phy_dev)
+		return phy_ethtool_get_wol(pp->phy_dev, wol);
+}
+
+static int
+mvneta_ethtool_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct mvneta_port *pp = netdev_priv(dev);
+
+	if (!pp->phy_dev)
+		return -EOPNOTSUPP;
+
+	return phy_ethtool_set_wol(pp->phy_dev, wol);
+}
+
 static const struct net_device_ops mvneta_netdev_ops = {
 	.ndo_open            = mvneta_open,
 	.ndo_stop            = mvneta_stop,
@@ -3937,6 +3960,8 @@ static int mvneta_ethtool_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
 	.set_rxfh	= mvneta_ethtool_set_rxfh,
 	.get_link_ksettings = phy_ethtool_get_link_ksettings,
 	.set_link_ksettings = mvneta_ethtool_set_link_ksettings,
+	.get_wol        = mvneta_ethtool_get_wol,
+	.set_wol        = mvneta_ethtool_set_wol,
 };
 
 /* Initialize hw */
-- 
1.9.1
