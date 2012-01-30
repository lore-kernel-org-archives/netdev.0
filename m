From: Andrea Shepard <andrea@persephoneslair.org>
Subject: [08/22] Cyclades PC300 driver: use DEFINE_PCI_DEVICE_TABLE
Date: Sun, 29 Jan 2012 18:50:02 -0800
Message-ID: <20120130025002.GI10262@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: khc@pm.waw.pl, davem@davemloft.net, mmarek@suse.cz,
	jkosina@suse.cz, joe@perches.com, justinmattock@gmail.com,
	gregkh@suse.de, alan@linux.intel.com, jdmason@kudzu.us
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cronus.persephoneslair.org ([216.254.15.24]:58050 "EHLO
	cronus.persephoneslair.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754271Ab2A3Cue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2012 21:50:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the PCI device table to use DEFINE_PCI_DEVICE_TABLE; also avoid a query
for PCI_REVISION_ID which is only ever used in a debug printk when said printk
is #ifdefed off.

Signed-off-by: Andrea Shepard <andrea@persephoneslair.org>

diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 5d51ac1..f6da796 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -257,7 +257,7 @@ static char rcsid[] =
 #undef	PC300_DEBUG_RX
 #undef	PC300_DEBUG_OTHER
 
-static struct pci_device_id cpc_pci_dev_id[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(cpc_pci_dev_id) = {
 	/* PC300/RSV or PC300/X21, 2 chan */
 	{0x120e, 0x300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0x300},
 	/* PC300/RSV or PC300/X21, 1 chan */
@@ -3557,7 +3557,9 @@ static int __devinit
 cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	static int first_time = 1;
+#ifdef PC300_DEBUG_PCI
 	u8 cpc_rev_id;
+#endif
 	int err = 0, eeprom_outdated = 0;
 	u16 device_id;
 	pc300_t *card;
@@ -3592,7 +3594,9 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	card->hw.falcsize = pci_resource_len(pdev, 4);
 	card->hw.plxphys = pci_resource_start(pdev, 5);
 	card->hw.plxsize = pci_resource_len(pdev, 5);
+#ifdef PC300_DEBUG_PCI
 	pci_read_config_byte(pdev, PCI_REVISION_ID, &cpc_rev_id);
+#endif
 
 	switch (device_id) {
 		case PCI_DEVICE_ID_PC300_RX_1:
diff --git a/drivers/net/wan/pc300_tty.c b/drivers/net/wan/pc300_tty.c
index 883f747..bf5c2ab 100644
--- a/drivers/net/wan/pc300_tty.c
+++ b/drivers/net/wan/pc300_tty.c
@@ -38,7 +38,6 @@
 
 #include <linux/module.h>
 #include <linux/kernel.h>
-#include <linux/pci.h>
 #include <linux/errno.h>
 #include <linux/string.h>
 #include <linux/init.h>
