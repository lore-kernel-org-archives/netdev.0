From: Mark Brown <broonie@sirena.org.uk>
Subject: natsemi: Fix detection of vanilla natsemi cards
Date: Fri, 23 Feb 2007 11:32:11 +0000
Message-ID: <20070223113209.GB9282@sirena.org.uk>
References: <20070223020920.b9528e0e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@stusta.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Tim Hockin <thockin@hockin.org>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:2982 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932136AbXBWLcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Feb 2007 06:32:25 -0500
Content-Disposition: inline
In-Reply-To: <20070223020920.b9528e0e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bob Tracy <rct@gherkin.frus.com> reported that the addition of support
for Aculab E1/T1 cPCI carrier cards broke detection of vanilla natsemi
cards.  This patch fixes that: the problem is that the driver-specific
data in the PCI device table is an index into a second table and this
had not been updated for the vanilla cards.

This patch fixes the problem minimally.

Signed-Off-By: Mark Brown <broonie@sirena.org.uk>

--- linux.orig/drivers/net/natsemi.c	2007-02-23 11:13:03.000000000 +0000
+++ linux/drivers/net/natsemi.c	2007-02-23 11:12:00.000000000 +0000
@@ -260,7 +260,7 @@
 
 static const struct pci_device_id natsemi_pci_tbl[] __devinitdata = {
 	{ PCI_VENDOR_ID_NS, 0x0020, 0x12d9,     0x000c,     0, 0, 0 },
-	{ PCI_VENDOR_ID_NS, 0x0020, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 }
+	{ PCI_VENDOR_ID_NS, 0x0020, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 1 },
 	{ }	/* terminate list */
 };
 MODULE_DEVICE_TABLE(pci, natsemi_pci_tbl);

-- 
"You grabbed my hand and we fell into it, like a daydream - or a fever."
