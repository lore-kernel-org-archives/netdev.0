From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: typhoon: convert to hw_features
Date: Sun, 17 Apr 2011 12:15:47 +0200 (CEST)
Message-ID: <20110417101547.7E01A13A6B@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Dillow <dave@thedillows.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:48108 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752395Ab1DQKPu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 06:15:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/typhoon.c |   39 ++++++++-------------------------------
 1 files changed, 8 insertions(+), 31 deletions(-)

diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 82653cb..119c394 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1144,28 +1144,6 @@ typhoon_set_wol(struct net_device *dev, struct e=
thtool_wolinfo *wol)
 	return 0;
 }
=20
-static u32
-typhoon_get_rx_csum(struct net_device *dev)
-{
-	/* For now, we don't allow turning off RX checksums.
-	 */
-	return 1;
-}
-
-static int
-typhoon_set_flags(struct net_device *dev, u32 data)
-{
-	/* There's no way to turn off the RX VLAN offloading and stripping
-	 * on the current 3XP firmware -- it does not respect the offload
-	 * settings -- so we only allow the user to toggle the TX processing.
-	 */
-	if (!(data & ETH_FLAG_RXVLAN))
-		return -EINVAL;
-
-	return ethtool_op_set_flags(dev, data,
-				    ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN);
-}
-
 static void
 typhoon_get_ringparam(struct net_device *dev, struct ethtool_ringparam=
 *ering)
 {
@@ -1187,13 +1165,7 @@ static const struct ethtool_ops typhoon_ethtool_=
ops =3D {
 	.get_wol		=3D typhoon_get_wol,
 	.set_wol		=3D typhoon_set_wol,
 	.get_link		=3D ethtool_op_get_link,
-	.get_rx_csum		=3D typhoon_get_rx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_csum,
-	.set_sg			=3D ethtool_op_set_sg,
-	.set_tso		=3D ethtool_op_set_tso,
 	.get_ringparam		=3D typhoon_get_ringparam,
-	.set_flags		=3D typhoon_set_flags,
-	.get_flags		=3D ethtool_op_get_flags,
 };
=20
 static int
@@ -2482,10 +2454,15 @@ typhoon_init_one(struct pci_dev *pdev, const st=
ruct pci_device_id *ent)
=20
 	/* We can handle scatter gather, up to 16 entries, and
 	 * we can do IP checksumming (only version 4, doh...)
+	 *
+	 * There's no way to turn off the RX VLAN offloading and stripping
+	 * on the current 3XP firmware -- it does not respect the offload
+	 * settings -- so we only allow the user to toggle the TX processing.
 	 */
-	dev->features |=3D NETIF_F_SG | NETIF_F_IP_CSUM;
-	dev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-	dev->features |=3D NETIF_F_TSO;
+	dev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
+		NETIF_F_HW_VLAN_TX;
+	dev->features =3D dev->hw_features |
+		NETIF_F_HW_VLAN_RX | NETIF_F_RXCSUM;
=20
 	if(register_netdev(dev) < 0) {
 		err_msg =3D "unable to register netdev";
--=20
1.7.2.5

