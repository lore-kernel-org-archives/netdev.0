From: Jan Luebbe <jlu@pengutronix.de>
Subject: [PATCH 3/3] net: cpsw: implement ioctl for MII
Date: Mon,  3 Dec 2012 14:49:29 +0100
Message-ID: <1354542569-6165-3-git-send-email-jlu@pengutronix.de>
References: <1354542569-6165-1-git-send-email-jlu@pengutronix.de>
Cc: "David S. Miller" <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Vaibhav Hiremath <hvaibhav@ti.com>,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	Jan Luebbe <jlu@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:53710 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754480Ab2LCNtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 08:49:50 -0500
In-Reply-To: <1354542569-6165-1-git-send-email-jlu@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows using tools like mii-diag on CPSW.

Signed-off-by: Jan Luebbe <jlu@pengutronix.de>
---
 drivers/net/ethernet/ti/cpsw.c |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 8de3e92..f476c03 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -629,6 +629,20 @@ static void cpsw_ndo_change_rx_flags(struct net_device *ndev, int flags)
 		dev_err(&ndev->dev, "multicast traffic cannot be filtered!\n");
 }
 
+static int cpsw_ndo_do_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct phy_device *phy = priv->slaves[0].phy;
+
+	if (!netif_running(ndev))
+		return -EINVAL;
+
+	if (!phy)
+		return -ENODEV;
+
+	return phy_mii_ioctl(phy, rq, cmd);
+}
+
 static void cpsw_ndo_tx_timeout(struct net_device *ndev)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
@@ -670,6 +684,7 @@ static const struct net_device_ops cpsw_netdev_ops = {
 	.ndo_start_xmit		= cpsw_ndo_start_xmit,
 	.ndo_change_rx_flags	= cpsw_ndo_change_rx_flags,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl		= cpsw_ndo_do_ioctl,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_tx_timeout		= cpsw_ndo_tx_timeout,
 	.ndo_get_stats		= cpsw_ndo_get_stats,
-- 
1.7.10.4
