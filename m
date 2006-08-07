From: Kyle McMartin <kyle@parisc-linux.org>
Subject: [PATCH 9/9] [TULIP] Fix section mismatch in de2104x.c
Date: Mon, 07 Aug 2006 20:53:32 +0000
Message-ID: <11549840363242-git-send-email-kyle@parisc-linux.org>
References: <20060807204418.GE401@athena.road.mcmartin.ca> <11549840122892-git-send-email-kyle@parisc-linux.org> <11549840321096-git-send-email-kyle@parisc-linux.org> <1154984032324-git-send-email-kyle@parisc-linux.org> <115498403384-git-send-email-kyle@parisc-linux.org> <11549840341728-git-send-email-kyle@parisc-linux.org> <11549840343640-git-send-email-kyle@parisc-linux.org> <11549840351899-git-send-email-kyle@parisc-linux.org> <11549840361794-git-send-email-kyle@parisc-linux.org>
Reply-To: Kyle McMartin <kyle@parisc-linux.org>
Cc: grundler@parisc-linux.org, val_henson@linux.intel.com,
	akpm@osdl.org, Helge Deller <deller@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:10729 "EHLO hera.kernel.org")
	by vger.kernel.org with ESMTP id S932363AbWHGUyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 16:54:00 -0400
To: netdev@vger.kernel.org
In-Reply-To: <11549840361794-git-send-email-kyle@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Helge Deller <deller@parisc-linux.org>

WARNING: drivers/net/tulip/de2104x.o - Section mismatch: reference to .init.text:de_init_one from .data.rel.local after 'de_driver' (at offset 0x20)
WARNING: drivers/net/tulip/de2104x.o - Section mismatch: reference to .exit.text:de_remove_one from .data.rel.local after 'de_driver' (at offset 0x28)

Signed-off-by: Helge Deller <deller@parisc-linux.org>
Signed-off-by: Kyle McMartin <kyle@parisc-linux.org>
---
 drivers/net/tulip/de2104x.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index d05c5aa..150a05a 100644
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
-- 
1.4.1.1

