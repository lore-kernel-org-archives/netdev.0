From: Matthew Wilcox <matthew@wil.cx>
Subject: [PATCH] [TULIP] Fix section mismatch in de2104x.c
Date: Fri, 06 Oct 2006 12:12:34 -0600
Message-ID: <11601583542790-git-send-email-matthew@wil.cx>
Reply-To: Matthew Wilcox <matthew@wil.cx>
Cc: netdev@vger.kernel.org, Helge Deller <deller@parisc-linux.org>,
	Kyle McMartin <kyle@parisc-linux.org>,
	Matthew Wilcox <matthew@wil.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:41860 "EHLO
	mail.parisc-linux.org") by vger.kernel.org with ESMTP
	id S1422801AbWJFSMf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Oct 2006 14:12:35 -0400
To: Val Henson <val_henson@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Helge Deller <deller@parisc-linux.org>

WARNING: drivers/net/tulip/de2104x.o - Section mismatch: reference to .init.text:de_init_one from .data.rel.local after 'de_driver' (at offset 0x20)
WARNING: drivers/net/tulip/de2104x.o - Section mismatch: reference to .exit.text:de_remove_one from .data.rel.local after 'de_driver' (at offset 0x28)

Signed-off-by: Helge Deller <deller@parisc-linux.org>
Signed-off-by: Kyle McMartin <kyle@parisc-linux.org>
Signed-off-by: Matthew Wilcox <matthew@wil.cx>
---
 drivers/net/tulip/de2104x.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 2cfd963..f6b3a94 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -1730,7 +1730,7 @@ static void __init de21040_get_media_inf
 }
 
 /* Note: this routine returns extra data bits for size detection. */
-static unsigned __init tulip_read_eeprom(void __iomem *regs, int location, int addr_len)
+static unsigned __devinit tulip_read_eeprom(void __iomem *regs, int location, int addr_len)
 {
 	int i;
 	unsigned retval = 0;
@@ -1926,7 +1926,7 @@ bad_srom:
 	goto fill_defaults;
 }
 
-static int __init de_init_one (struct pci_dev *pdev,
+static int __devinit de_init_one (struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
 	struct net_device *dev;
@@ -2082,7 +2082,7 @@ err_out_free:
 	return rc;
 }
 
-static void __exit de_remove_one (struct pci_dev *pdev)
+static void __devexit de_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct de_private *de = dev->priv;
@@ -2164,7 +2164,7 @@ static struct pci_driver de_driver = {
 	.name		= DRV_NAME,
 	.id_table	= de_pci_tbl,
 	.probe		= de_init_one,
-	.remove		= __exit_p(de_remove_one),
+	.remove		= __devexit_p(de_remove_one),
 #ifdef CONFIG_PM
 	.suspend	= de_suspend,
 	.resume		= de_resume,
