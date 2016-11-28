From: yegorslists@googlemail.com
Subject: [PATCH] cpsw: ethtool: add support for nway reset
Date: Mon, 28 Nov 2016 10:47:52 +0100
Message-ID: <1480326472-5849-1-git-send-email-yegorslists@googlemail.com>
Cc: linux-omap@vger.kernel.org, grygorii.strashko@ti.com,
        mugunthanvnm@ti.com, davem@davemloft.net,
        Yegor Yefremov <yegorslists@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34898 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932575AbcK1JsG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 04:48:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yegor Yefremov <yegorslists@googlemail.com>

This patch adds support for ethtool's '-r' command. Restarting
N-WAY negotiation can be useful to activate newly changed EEE
settings etc.

Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
---
 drivers/net/ethernet/ti/cpsw.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index df87bff..caec6ac 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2261,6 +2261,18 @@ static int cpsw_set_eee(struct net_device *ndev, struct ethtool_eee *edata)
 		return -EOPNOTSUPP;
 }
 
+static int cpsw_nway_reset(struct net_device *ndev)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = priv->cpsw;
+	int slave_no = cpsw_slave_index(cpsw, priv);
+
+	if (cpsw->slaves[slave_no].phy)
+		return genphy_restart_aneg(cpsw->slaves[slave_no].phy);
+	else
+		return -EOPNOTSUPP;
+}
+
 static const struct ethtool_ops cpsw_ethtool_ops = {
 	.get_drvinfo	= cpsw_get_drvinfo,
 	.get_msglevel	= cpsw_get_msglevel,
@@ -2286,6 +2298,7 @@ static const struct ethtool_ops cpsw_ethtool_ops = {
 	.set_link_ksettings	= cpsw_set_link_ksettings,
 	.get_eee	= cpsw_get_eee,
 	.set_eee	= cpsw_set_eee,
+	.nway_reset	= cpsw_nway_reset,
 };
 
 static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_common *cpsw,
-- 
2.1.4
