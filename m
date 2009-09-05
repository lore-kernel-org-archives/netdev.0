From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] WAN: remove deprecated PCI_DEVICE_ID from PCI200SYN driver.
Date: Sat, 05 Sep 2009 12:54:30 +0200
Message-ID: <m3ljktek61.fsf@intrepid.localdomain>
References: <m363byk3af.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:59038 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753161AbZIEKya (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Sep 2009 06:54:30 -0400
In-Reply-To: <m363byk3af.fsf@intrepid.localdomain> (Krzysztof Halasa's message
	of "Fri, 04 Sep 2009 19:50:16 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PCI200SYN has its own PCI subsystem device ID for 3+ years, now it's
time to remove the generic PLX905[02] ID from the driver. Anyone with
old EEPROM data will have to run the upgrade.

Having the generic PLX905[02] (PCI-local bus bridge) ID is harmful
as the driver tries to handle other devices based on these bridges.

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

--- a/drivers/net/wan/pci200syn.c
+++ b/drivers/net/wan/pci200syn.c
@@ -360,15 +360,6 @@ static int __devinit pci200_pci_init_one(struct pci_dev *pdev,
 	       " %u RX packets rings\n", ramsize / 1024, ramphys,
 	       pdev->irq, card->tx_ring_buffers, card->rx_ring_buffers);
 
-	if (pdev->subsystem_device == PCI_DEVICE_ID_PLX_9050) {
-		printk(KERN_ERR "Detected PCI200SYN card with old "
-		       "configuration data.\n");
-		printk(KERN_ERR "See <http://www.kernel.org/pub/"
-		       "linux/utils/net/hdlc/pci200syn/> for update.\n");
-		printk(KERN_ERR "The card will stop working with"
-		       " future versions of Linux if not updated.\n");
-	}
-
 	if (card->tx_ring_buffers < 1) {
 		printk(KERN_ERR "pci200syn: RAM test failed\n");
 		pci200_pci_remove_one(pdev);
@@ -427,8 +418,6 @@ static int __devinit pci200_pci_init_one(struct pci_dev *pdev,
 
 static struct pci_device_id pci200_pci_tbl[] __devinitdata = {
 	{ PCI_VENDOR_ID_PLX, PCI_DEVICE_ID_PLX_9050, PCI_VENDOR_ID_PLX,
-	  PCI_DEVICE_ID_PLX_9050, 0, 0, 0 },
-	{ PCI_VENDOR_ID_PLX, PCI_DEVICE_ID_PLX_9050, PCI_VENDOR_ID_PLX,
 	  PCI_DEVICE_ID_PLX_PCI200SYN, 0, 0, 0 },
 	{ 0, }
 };
-- 
Krzysztof Halasa
