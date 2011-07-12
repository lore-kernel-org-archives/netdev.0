From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: [PATCH] lanai: use pci_dev->subsystem_device
Date: Tue, 12 Jul 2011 18:47:57 +0400
Message-ID: <201107121847.57793.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dev.rtsoft.ru ([213.79.90.226]:53055 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751009Ab1GLOtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 10:49:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver reads PCI subsystem IDs from the PCI configuration registers while
it is already stored by the PCI subsystem in the 'subsystem_device' field of
'struct pci_dev'...

Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

---
The patch is against the recent Linus' tree.

 drivers/atm/lanai.c |    9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

Index: linux-2.6/drivers/atm/lanai.c
===================================================================
--- linux-2.6.orig/drivers/atm/lanai.c
+++ linux-2.6/drivers/atm/lanai.c
@@ -1947,7 +1947,6 @@ static int __devinit lanai_pci_start(str
 {
 	struct pci_dev *pci = lanai->pci;
 	int result;
-	u16 w;
 
 	if (pci_enable_device(pci) != 0) {
 		printk(KERN_ERR DEV_LABEL "(itf %d): can't enable "
@@ -1965,13 +1964,7 @@ static int __devinit lanai_pci_start(str
 		    "(itf %d): No suitable DMA available.\n", lanai->number);
 		return -EBUSY;
 	}
-	result = pci_read_config_word(pci, PCI_SUBSYSTEM_ID, &w);
-	if (result != PCIBIOS_SUCCESSFUL) {
-		printk(KERN_ERR DEV_LABEL "(itf %d): can't read "
-		    "PCI_SUBSYSTEM_ID: %d\n", lanai->number, result);
-		return -EINVAL;
-	}
-	result = check_board_id_and_rev("PCI", w, NULL);
+	result = check_board_id_and_rev("PCI", pci->subsystem_device, NULL);
 	if (result != 0)
 		return result;
 	/* Set latency timer to zero as per lanai docs */
