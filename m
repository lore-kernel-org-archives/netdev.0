From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: tehuti: convert to hw_features
Date: Sun, 17 Apr 2011 12:15:46 +0200 (CEST)
Message-ID: <20110417101546.8F6DD13A65@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Indenbaum <baum@tehutinetworks.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:48096 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755381Ab1DQKPs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 06:15:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As a side effect, make TX offloads changeable.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/tehuti.c |   26 +++-----------------------
 1 files changed, 3 insertions(+), 23 deletions(-)

diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 8564ec5..8be71de 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -2017,9 +2017,11 @@ bdx_probe(struct pci_dev *pdev, const struct pci=
_device_id *ent)
 		ndev->irq =3D pdev->irq;
 		ndev->features =3D NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO
 		    | NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
-		    NETIF_F_HW_VLAN_FILTER
+		    NETIF_F_HW_VLAN_FILTER | NETIF_F_RXCSUM
 		    /*| NETIF_F_FRAGLIST */
 		    ;
+		ndev->hw_features =3D NETIF_F_IP_CSUM | NETIF_F_SG |
+			NETIF_F_TSO | NETIF_F_HW_VLAN_TX;
=20
 		if (pci_using_dac)
 			ndev->features |=3D NETIF_F_HIGHDMA;
@@ -2188,24 +2190,6 @@ bdx_get_drvinfo(struct net_device *netdev, struc=
t ethtool_drvinfo *drvinfo)
 }
=20
 /*
- * bdx_get_rx_csum - report whether receive checksums are turned on or=
 off
- * @netdev
- */
-static u32 bdx_get_rx_csum(struct net_device *netdev)
-{
-	return 1;		/* always on */
-}
-
-/*
- * bdx_get_tx_csum - report whether transmit checksums are turned on o=
r off
- * @netdev
- */
-static u32 bdx_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_IP_CSUM) !=3D 0;
-}
-
-/*
  * bdx_get_coalesce - get interrupt coalescing parameters
  * @netdev
  * @ecoal
@@ -2424,10 +2408,6 @@ static void bdx_set_ethtool_ops(struct net_devic=
e *netdev)
 		.set_coalesce =3D bdx_set_coalesce,
 		.get_ringparam =3D bdx_get_ringparam,
 		.set_ringparam =3D bdx_set_ringparam,
-		.get_rx_csum =3D bdx_get_rx_csum,
-		.get_tx_csum =3D bdx_get_tx_csum,
-		.get_sg =3D ethtool_op_get_sg,
-		.get_tso =3D ethtool_op_get_tso,
 		.get_strings =3D bdx_get_strings,
 		.get_sset_count =3D bdx_get_sset_count,
 		.get_ethtool_stats =3D bdx_get_ethtool_stats,
--=20
1.7.2.5

