From: yegorslists@googlemail.com
Subject: [PATCH v2] cpsw: ethtool: add support for getting/setting EEE registers
Date: Wed, 23 Nov 2016 15:38:33 +0100
Message-ID: <1479911913-1761-1-git-send-email-yegorslists@googlemail.com>
Cc: linux-omap@vger.kernel.org, grygorii.strashko@ti.com,
        mugunthanvnm@ti.com, roszenrami@gmail.com,
        Yegor Yefremov <yegorslists@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f194.google.com ([209.85.210.194]:33051 "EHLO
        mail-wj0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936535AbcKWOj3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 09:39:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yegor Yefremov <yegorslists@googlemail.com>

Add the ability to query and set Energy Efficient Ethernet parameters
via ethtool for applicable devices.

Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
---
Changes:
	v2: make routines static (Rami Rosen)

 drivers/net/ethernet/ti/cpsw.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index c6cff3d..c706540 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2239,6 +2239,30 @@ static int cpsw_set_channels(struct net_device *ndev,
 	return ret;
 }
 
+static int cpsw_get_eee(struct net_device *ndev, struct ethtool_eee *edata)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = priv->cpsw;
+	int slave_no = cpsw_slave_index(cpsw, priv);
+
+	if (cpsw->slaves[slave_no].phy)
+		return phy_ethtool_get_eee(cpsw->slaves[slave_no].phy, edata);
+	else
+		return -EOPNOTSUPP;
+}
+
+static int cpsw_set_eee(struct net_device *ndev, struct ethtool_eee *edata)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = priv->cpsw;
+	int slave_no = cpsw_slave_index(cpsw, priv);
+
+	if (cpsw->slaves[slave_no].phy)
+		return phy_ethtool_set_eee(cpsw->slaves[slave_no].phy, edata);
+	else
+		return -EOPNOTSUPP;
+}
+
 static const struct ethtool_ops cpsw_ethtool_ops = {
 	.get_drvinfo	= cpsw_get_drvinfo,
 	.get_msglevel	= cpsw_get_msglevel,
@@ -2262,6 +2286,8 @@ static const struct ethtool_ops cpsw_ethtool_ops = {
 	.complete	= cpsw_ethtool_op_complete,
 	.get_channels	= cpsw_get_channels,
 	.set_channels	= cpsw_set_channels,
+	.get_eee	= cpsw_get_eee,
+	.set_eee	= cpsw_set_eee,
 };
 
 static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_common *cpsw,
-- 
2.1.4
