From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: niu: convert to hw_features
Date: Sun, 17 Apr 2011 12:15:47 +0200 (CEST)
Message-ID: <20110417101547.A22AF13A6D@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:48109 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756073Ab1DQKPt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 06:15:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Side effect: allow toggling of TX offloads.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/niu.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index ea2272f..a707217 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -7913,11 +7913,6 @@ static int niu_set_phys_id(struct net_device *de=
v,
 	return 0;
 }
=20
-static int niu_set_flags(struct net_device *dev, u32 data)
-{
-	return ethtool_op_set_flags(dev, data, ETH_FLAG_RXHASH);
-}
-
 static const struct ethtool_ops niu_ethtool_ops =3D {
 	.get_drvinfo		=3D niu_get_drvinfo,
 	.get_link		=3D ethtool_op_get_link,
@@ -7934,8 +7929,6 @@ static const struct ethtool_ops niu_ethtool_ops =3D=
 {
 	.set_phys_id		=3D niu_set_phys_id,
 	.get_rxnfc		=3D niu_get_nfc,
 	.set_rxnfc		=3D niu_set_nfc,
-	.set_flags		=3D niu_set_flags,
-	.get_flags		=3D ethtool_op_get_flags,
 };
=20
 static int niu_ldg_assign_ldn(struct niu *np, struct niu_parent *paren=
t,
@@ -9764,8 +9757,8 @@ static void __devinit niu_device_announce(struct =
niu *np)
=20
 static void __devinit niu_set_basic_features(struct net_device *dev)
 {
-	dev->features |=3D (NETIF_F_SG | NETIF_F_HW_CSUM |
-			  NETIF_F_GRO | NETIF_F_RXHASH);
+	dev->hw_features =3D NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_RXHASH;
+	dev->features |=3D dev->hw_features | NETIF_F_RXCSUM;
 }
=20
 static int __devinit niu_pci_init_one(struct pci_dev *pdev,
--=20
1.7.2.5

