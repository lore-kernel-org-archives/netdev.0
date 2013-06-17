From: cphealy@gmail.com
Subject: [PATCH 1/1] fec: Add support to restart autonegotiate
Date: Mon, 17 Jun 2013 07:25:06 -0700
Message-ID: <1371479106-2897-1-git-send-email-cphealy@gmail.com>
Cc: Chris Healy <cphealy@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	Jim Baxter <jim_baxter@mentor.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:43543 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601Ab3FQOZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 10:25:12 -0400
Received: by mail-ob0-f178.google.com with SMTP id fb19so3241233obc.9
        for <netdev@vger.kernel.org>; Mon, 17 Jun 2013 07:25:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Healy <cphealy@gmail.com>

Add ethtool operation to restart autonegotiation via the PHY.

Tested on i.MX28EVK.

Signed-off-by: Chris Healy <cphealy@gmail.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index a667015..a327492 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1436,6 +1436,17 @@ static int fec_enet_set_pauseparam(struct net_device *ndev,
 	return 0;
 }
 
+static int fec_enet_nway_reset(struct net_device *dev)
+{
+	struct fec_enet_private *fep = netdev_priv(dev);
+	struct phy_device *phydev = fep->phy_dev;
+
+	if (!phydev)
+		return -ENODEV;
+
+	return genphy_restart_aneg(phydev);
+}
+
 static const struct ethtool_ops fec_enet_ethtool_ops = {
 	.get_pauseparam		= fec_enet_get_pauseparam,
 	.set_pauseparam		= fec_enet_set_pauseparam,
@@ -1444,6 +1455,7 @@ static const struct ethtool_ops fec_enet_ethtool_ops = {
 	.get_drvinfo		= fec_enet_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
 	.get_ts_info		= fec_enet_get_ts_info,
+	.nway_reset		= fec_enet_nway_reset,
 };
 
 static int fec_enet_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
-- 
1.8.1.2
