From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 04/29] LMC: fix initialization messages.
Date: Sat, 31 Jul 2010 17:05:27 +0200
Message-ID: <1280588752-9340-4-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:48075 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755961Ab0GaPF7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:05:59 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/main.c |   15 ++++++---------
 1 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wan/lmc/main.c b/drivers/net/wan/lmc/main.c
index 4fa75ad..63297a5 100644
--- a/drivers/net/wan/lmc/main.c
+++ b/drivers/net/wan/lmc/main.c
@@ -837,12 +837,9 @@ static int __devinit lmc_init_one(struct pci_dev *=
pdev,
 	spin_lock_init(&sc->lmc_lock);
 	pci_set_master(pdev);
=20
-	printk(KERN_INFO "%s: detected at %lx, irq %d\n", dev->name,
-	       dev->base_addr, dev->irq);
-
 	err =3D register_hdlc_device(dev);
 	if (err) {
-		printk(KERN_ERR "%s: register_netdev failed.\n", dev->name);
+		dev_err(&pdev->dev, "lmc: register_hdlc_device() failed.\n");
 		free_netdev(dev);
 		goto err_hdlcdev;
 	}
@@ -860,27 +857,27 @@ static int __devinit lmc_init_one(struct pci_dev =
*pdev,
=20
 	switch (subdevice) {
 	case PCI_DEVICE_ID_LMC_HSSI:
-		printk(KERN_INFO "%s: LMC HSSI\n", dev->name);
+		dev_info(&pdev->dev, "%s =3D LMC HSSI\n", dev->name);
 		sc->lmc_cardtype =3D LMC_CARDTYPE_HSSI;
 		sc->lmc_media =3D &lmc_hssi_media;
 		break;
 	case PCI_DEVICE_ID_LMC_DS3:
-		printk(KERN_INFO "%s: LMC DS3\n", dev->name);
+		dev_info(&pdev->dev, "%s =3D LMC DS3\n", dev->name);
 		sc->lmc_cardtype =3D LMC_CARDTYPE_DS3;
 		sc->lmc_media =3D &lmc_ds3_media;
 		break;
 	case PCI_DEVICE_ID_LMC_SSI:
-		printk(KERN_INFO "%s: LMC SSI\n", dev->name);
+		dev_info(&pdev->dev, "%s =3D LMC SSI\n", dev->name);
 		sc->lmc_cardtype =3D LMC_CARDTYPE_SSI;
 		sc->lmc_media =3D &lmc_ssi_media;
 		break;
 	case PCI_DEVICE_ID_LMC_T1:
-		printk(KERN_INFO "%s: LMC T1\n", dev->name);
+		dev_info(&pdev->dev, "%s =3D LMC T1\n", dev->name);
 		sc->lmc_cardtype =3D LMC_CARDTYPE_T1;
 		sc->lmc_media =3D &lmc_t1_media;
 		break;
 	default:
-		printk(KERN_WARNING "%s: LMC UNKNOWN CARD!\n", dev->name);
+		dev_warn(&pdev->dev, "%s =3D LMC UNKNOWN CARD!\n", dev->name);
 		break;
 	}
=20
--=20
1.7.1.1

