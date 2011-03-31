From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: convert sunhme/sungem network drivers to hw_features
Date: Thu, 31 Mar 2011 13:01:35 +0200 (CEST)
Message-ID: <20110331110135.BDFF913A69@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:50967 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757304Ab1CaLBj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2011 07:01:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Side effects:
 - TX offloads (HW csum, scatter-gather) can be toggled now
 - RX checksum is reported correctly now (it's always active)

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
[Trivial conversion, or rather: extension in this case]

 drivers/net/sungem.c |    3 ++-
 drivers/net/sunhme.c |    6 ++++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index c1a3448..a935426 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -3146,7 +3146,8 @@ static int __devinit gem_init_one(struct pci_dev =
*pdev,
 			    gp->phy_mii.def ? gp->phy_mii.def->name : "no");
=20
 	/* GEM can do it all... */
-	dev->features |=3D NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_LLTX;
+	dev->hw_features =3D NETIF_F_SG | NETIF_F_HW_CSUM;
+	dev->features |=3D dev->hw_features | NETIF_F_RXCSUM | NETIF_F_LLTX;
 	if (pci_using_dac)
 		dev->features |=3D NETIF_F_HIGHDMA;
=20
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index eb4f59f..80e907d 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2788,7 +2788,8 @@ static int __devinit happy_meal_sbus_probe_one(st=
ruct platform_device *op, int i
 	dev->ethtool_ops =3D &hme_ethtool_ops;
=20
 	/* Happy Meal can do it all... */
-	dev->features |=3D NETIF_F_SG | NETIF_F_HW_CSUM;
+	dev->hw_features =3D NETIF_F_SG | NETIF_F_HW_CSUM;
+	dev->features |=3D dev->hw_features | NETIF_F_RXCSUM;
=20
 	dev->irq =3D op->archdata.irqs[0];
=20
@@ -3113,7 +3114,8 @@ static int __devinit happy_meal_pci_probe(struct =
pci_dev *pdev,
 	dev->dma =3D 0;
=20
 	/* Happy Meal can do it all... */
-	dev->features |=3D NETIF_F_SG | NETIF_F_HW_CSUM;
+	dev->hw_features =3D NETIF_F_SG | NETIF_F_HW_CSUM;
+	dev->features |=3D dev->hw_features | NETIF_F_RXCSUM;
=20
 #if defined(CONFIG_SBUS) && defined(CONFIG_PCI)
 	/* Hook up PCI register/descriptor accessors. */
--=20
1.7.2.5

