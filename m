From: yegorslists@googlemail.com
Subject: [PATCH v4] cpsw: ethtool: add support for getting/setting EEE registers
Date: Mon, 28 Nov 2016 09:41:33 +0100
Message-ID: <1480322493-25308-1-git-send-email-yegorslists@googlemail.com>
Cc: linux-omap@vger.kernel.org, grygorii.strashko@ti.com,
        mugunthanvnm@ti.com, davem@davemloft.net,
        Yegor Yefremov <yegorslists@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33912 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932141AbcK1Ilt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 03:41:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yegor Yefremov <yegorslists@googlemail.com>

Add the ability to query and set Energy Efficient Ethernet parameters
via ethtool for applicable devices.

This patch doesn't activate full EEE support in cpsw driver, but it
enables reading and writing EEE advertising settings. This way one
can disable advertising EEE for certain speeds.

Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
Acked-by: Rami Rosen <roszenrami@gmail.com>
---
Changes:
	v4: respine against net-next (David Miller)
	v3: explain what features will be available with this patch (Florian Fainelli)
	v2: make routines static (Rami Rosen)

 drivers/net/ethernet/ti/cpsw.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index da40ea5..df87bff 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2237,6 +2237,30 @@ static int cpsw_set_channels(struct net_device *ndev,
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
@@ -2260,6 +2284,8 @@ static const struct ethtool_ops cpsw_ethtool_ops = {
 	.set_channels	= cpsw_set_channels,
 	.get_link_ksettings	= cpsw_get_link_ksettings,
 	.set_link_ksettings	= cpsw_set_link_ksettings,
+	.get_eee	= cpsw_get_eee,
+	.set_eee	= cpsw_set_eee,
 };
 
 static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_common *cpsw,
-- 
2.1.4
