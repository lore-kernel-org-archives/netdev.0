From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] Tulip: don't initialize SBE xT3E3 WAN ports.
Date: Sat, 31 Jul 2010 11:32:44 +0200
Message-ID: <m31vakc7yb.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:49105 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751137Ab0GaJk1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jul 2010 05:40:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SBE 2T3E3 cards use DECchips 21143 but they need a different driver.
Don't even try to use a normal tulip driver with them.

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -1309,6 +1309,12 @@ static int __devinit tulip_init_one (struct pci_=
dev *pdev,
         if (pdev->subsystem_vendor =3D=3D PCI_VENDOR_ID_LMC) {
 		pr_err(PFX "skipping LMC card\n");
 		return -ENODEV;
+	} else if (pdev->subsystem_vendor =3D=3D PCI_VENDOR_ID_SBE &&
+		   (pdev->subsystem_device =3D=3D PCI_SUBDEVICE_ID_SBE_T3E3 ||
+		    pdev->subsystem_device =3D=3D PCI_SUBDEVICE_ID_SBE_2T3E3_P0 ||
+		    pdev->subsystem_device =3D=3D PCI_SUBDEVICE_ID_SBE_2T3E3_P1)) {
+		pr_err(PFX "skipping SBE T3E3 port\n");
+		return -ENODEV;
 	}
=20
 	/*
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1494,6 +1494,9 @@
 #define PCI_DEVICE_ID_SBE_WANXL100	0x0301
 #define PCI_DEVICE_ID_SBE_WANXL200	0x0302
 #define PCI_DEVICE_ID_SBE_WANXL400	0x0104
+#define PCI_SUBDEVICE_ID_SBE_T3E3	0x0009
+#define PCI_SUBDEVICE_ID_SBE_2T3E3_P0	0x0901
+#define PCI_SUBDEVICE_ID_SBE_2T3E3_P1	0x0902
=20
 #define PCI_VENDOR_ID_TOSHIBA		0x1179
 #define PCI_DEVICE_ID_TOSHIBA_PICCOLO_1	0x0101
