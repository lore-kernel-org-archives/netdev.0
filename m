From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 21/29] LMC: I'm sure Linux doesn't swap PCI subsystem device and vendor IDs.
Date: Sat, 31 Jul 2010 17:05:44 +0200
Message-ID: <1280588752-9340-21-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:45531 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756591Ab0GaPGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:24 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/main.c |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wan/lmc/main.c b/drivers/net/wan/lmc/main.c
index 2229e0a..bd7def0 100644
--- a/drivers/net/wan/lmc/main.c
+++ b/drivers/net/wan/lmc/main.c
@@ -77,8 +77,6 @@ static int LMC_PKT_BUF_SZ =3D 1542;
 static DEFINE_PCI_DEVICE_TABLE(lmc_pci_tbl) =3D {
 	{ PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_FAST,
 	  PCI_VENDOR_ID_LMC, PCI_ANY_ID },
-	{ PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_FAST,
-	  PCI_ANY_ID, PCI_VENDOR_ID_LMC },
 	{ 0 }
 };
=20
@@ -773,14 +771,6 @@ static int __devinit lmc_init_one(struct pci_dev *=
pdev,
 	sc->cardtype =3D LMC_CARDTYPE_UNKNOWN;
 	sc->timing =3D LMC_CTL_CLOCK_SOURCE_EXT;
=20
-	/*
-	 * Check either the subvendor or the subdevice, some systems reverse
-	 * the setting in the bois, seems to be version and arch dependent?
-	 * Fix the error, exchange the two values
-	 */
-	if ((subdevice =3D pdev->subsystem_device) =3D=3D PCI_VENDOR_ID_LMC)
-		subdevice =3D pdev->subsystem_vendor;
-
 	switch (subdevice) {
 	case PCI_DEVICE_ID_LMC_HSSI:
 		dev_info(&pdev->dev, "%s =3D LMC HSSI\n", dev->name);
--=20
1.7.1.1

