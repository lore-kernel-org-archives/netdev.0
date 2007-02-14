From: Mark Brown <broonie@sirena.org.uk>
Subject: [patch 2/2] natsemi: Support Aculab E1/T1 PMXc cPCI carrier cards
Date: Wed, 14 Feb 2007 10:02:05 +0000
Message-ID: <20070214100227.222896000@sirena.org.uk>
References: <20070214100203.413293000@sirena.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tim Hockin <thockin@hockin.org>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:4405 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557AbXBNKj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Feb 2007 05:39:57 -0500
Content-Disposition: inline; filename=natsemi-aculab-cpci-carrier.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Aculab E1/T1 PMXc cPCI carrier card cards present a natsemi on the cPCI
bus with an oversized EEPROM using a direct MII<->MII connection with no
PHY.  This patch adds a new device table entry supporting these cards.

Signed-Off-By: Mark Brown <broonie@sirena.org.uk>

Index: linux/drivers/net/natsemi.c
===================================================================
--- linux.orig/drivers/net/natsemi.c	2007-02-12 18:09:44.000000000 +0000
+++ linux/drivers/net/natsemi.c	2007-02-12 18:09:59.000000000 +0000
@@ -244,6 +244,9 @@
 	MII_EN_SCRM	= 0x0004,	/* enable scrambler (tp) */
 };
 
+enum {
+	NATSEMI_FLAG_IGNORE_PHY		= 0x1,
+};
 
 /* array of board data directly indexed by pci_tbl[x].driver_data */
 static const struct {
@@ -251,10 +254,12 @@
 	unsigned long flags;
 	unsigned int eeprom_size;
 } natsemi_pci_info[] __devinitdata = {
+	{ "Aculab E1/T1 PMXc cPCI carrier card", NATSEMI_FLAG_IGNORE_PHY, 128 },
 	{ "NatSemi DP8381[56]", 0, 24 },
 };
 
 static const struct pci_device_id natsemi_pci_tbl[] __devinitdata = {
+	{ PCI_VENDOR_ID_NS, 0x0020, 0x12d9,     0x000c,     0, 0, 0 },
 	{ PCI_VENDOR_ID_NS, 0x0020, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	{ }	/* terminate list */
 };
@@ -811,7 +816,11 @@
 	np->hands_off = 0;
 	np->intr_status = 0;
 	np->eeprom_size = natsemi_pci_info[chip_idx].eeprom_size;
-	np->ignore_phy = 0;
+	if (natsemi_pci_info[chip_idx].flags & NATSEMI_FLAG_IGNORE_PHY) {
+		np->ignore_phy = 1;
+	} else {
+		np->ignore_phy = 0;
+	}
 
 	/* Initial port:
 	 * - If configured to ignore the PHY set up for external.

--
"You grabbed my hand and we fell into it, like a daydream - or a fever."
