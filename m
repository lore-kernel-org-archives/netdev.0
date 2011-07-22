From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: [PATCH] sbni: use pci_dev->subsystem_device
Date: Fri, 22 Jul 2011 19:50:25 +0400
Message-ID: <201107221950.25960.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dev.rtsoft.ru ([213.79.90.226]:48557 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751418Ab1GVPwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 11:52:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver reads PCI subsystem ID from the PCI configuration register while it's
already stored by the PCI subsystem in the 'subsystem_device' field of 'struct
pci_dev'...

Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

---
The patch is against the recent Linus' tree.

 drivers/net/wan/sbni.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

Index: linux-2.6/drivers/net/wan/sbni.c
===================================================================
--- linux-2.6.orig/drivers/net/wan/sbni.c
+++ linux-2.6/drivers/net/wan/sbni.c
@@ -303,7 +303,6 @@ sbni_pci_probe( struct net_device  *dev 
 	       != NULL ) {
 		int  pci_irq_line;
 		unsigned long  pci_ioaddr;
-		u16  subsys;
 
 		if( pdev->vendor != SBNI_PCI_VENDOR &&
 		    pdev->device != SBNI_PCI_DEVICE )
@@ -314,9 +313,7 @@ sbni_pci_probe( struct net_device  *dev 
 
 		/* Avoid already found cards from previous calls */
 		if( !request_region( pci_ioaddr, SBNI_IO_EXTENT, dev->name ) ) {
-			pci_read_config_word( pdev, PCI_SUBSYSTEM_ID, &subsys );
-
-			if (subsys != 2)
+			if (pdev->subsystem_device != 2)
 				continue;
 
 			/* Dual adapter is present */
