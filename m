From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: [PATCH] sis900: use pci_dev->revision
Date: Tue, 22 Feb 2011 23:29:01 +0300
Message-ID: <201102222329.02049.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, venza@brownhat.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dev.rtsoft.ru ([213.79.90.226]:48550 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752441Ab1BVUaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 15:30:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver uses PCI_CLASS_REVISION instead of PCI_REVISION_ID, so it wasn't
converted by commit 44c10138fd4bbc4b6d6bff0873c24902f2a9da65 (PCI: Change all
drivers to use pci_device->revision).

Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

---
The patch is against the recent Linus' tree.

 drivers/net/sis900.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/drivers/net/sis900.c
===================================================================
--- linux-2.6.orig/drivers/net/sis900.c
+++ linux-2.6/drivers/net/sis900.c
@@ -495,7 +495,7 @@ static int __devinit sis900_probe(struct
 	sis_priv->mii_info.reg_num_mask = 0x1f;
 
 	/* Get Mac address according to the chip revision */
-	pci_read_config_byte(pci_dev, PCI_CLASS_REVISION, &(sis_priv->chipset_rev));
+	sis_priv->chipset_rev = pci_dev->revision;
 	if(netif_msg_probe(sis_priv))
 		printk(KERN_DEBUG "%s: detected revision %2.2x, "
 				"trying to get MAC address...\n",
@@ -532,7 +532,7 @@ static int __devinit sis900_probe(struct
 	/* save our host bridge revision */
 	dev = pci_get_device(PCI_VENDOR_ID_SI, PCI_DEVICE_ID_SI_630, NULL);
 	if (dev) {
-		pci_read_config_byte(dev, PCI_CLASS_REVISION, &sis_priv->host_bridge_rev);
+		sis_priv->host_bridge_rev = dev->revision;
 		pci_dev_put(dev);
 	}
 
