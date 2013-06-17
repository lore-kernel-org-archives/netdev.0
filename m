From: cphealy@gmail.com
Subject: [PATCH 1/1] fec: Add support to restart autonegotiate
Date: Sun, 16 Jun 2013 17:04:38 -0700
Message-ID: <1371427478-25902-1-git-send-email-cphealy@gmail.com>
Cc: Chris <cphealy@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	Jim Baxter <jim_baxter@mentor.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:47361 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959Ab3FQAEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jun 2013 20:04:52 -0400
Received: by mail-ob0-f176.google.com with SMTP id v19so2513166obq.21
        for <netdev@vger.kernel.org>; Sun, 16 Jun 2013 17:04:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris <cphealy@gmail.com>

Add ethtool operation to restart autonegotiation via the PHY.

Also cleanup two whitespace errors that break kernel guidelines.

Tested on i.MX28EVK.

Signed-off-by: Chris <cphealy@gmail.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index a667015..c6be728 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -150,7 +150,7 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 #define	FEC_FLASHMAC	0xf0006000
 #elif defined(CONFIG_CANCam)
 #define	FEC_FLASHMAC	0xf0020000
-#elif defined (CONFIG_M5272C3)
+#elif defined(CONFIG_M5272C3)
 #define	FEC_FLASHMAC	(0xffe04000 + 4)
 #elif defined(CONFIG_MOD5272)
 #define FEC_FLASHMAC	0xffc0406b
@@ -1206,8 +1206,7 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 	if (id_entry->driver_data & FEC_QUIRK_HAS_GBIT) {
 		phy_dev->supported &= PHY_GBIT_FEATURES;
 		phy_dev->supported |= SUPPORTED_Pause;
-	}
-	else
+	} else
 		phy_dev->supported &= PHY_BASIC_FEATURES;
 
 	phy_dev->advertising = phy_dev->supported;
@@ -1436,6 +1435,17 @@ static int fec_enet_set_pauseparam(struct net_device *ndev,
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
@@ -1444,6 +1454,7 @@ static const struct ethtool_ops fec_enet_ethtool_ops = {
 	.get_drvinfo		= fec_enet_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
 	.get_ts_info		= fec_enet_get_ts_info,
+	.nway_reset		= fec_enet_nway_reset,
 };
 
 static int fec_enet_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
-- 
1.8.1.2
