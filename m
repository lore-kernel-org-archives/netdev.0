From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next-2.6 1/2] be2net: Adding an option to use INTx
 instead of MSI-X
Date: Mon, 25 Oct 2010 16:42:35 +0530
Message-ID: <20101025111235.GA2024@emulex.com>
Reply-To: Somnath Kotur <somnath.kotur@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:44728 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753417Ab0JYLMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 07:12:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default, be2net uses MSIx wherever possible.
Adding a module parameter to use INTx for users who do not want to use MSIx.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/benet/be_main.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 45b1f66..1262292 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -27,10 +27,13 @@ MODULE_LICENSE("GPL");
 
 static unsigned int rx_frag_size = 2048;
 static unsigned int num_vfs;
+static unsigned int msix = 1;
 module_param(rx_frag_size, uint, S_IRUGO);
 module_param(num_vfs, uint, S_IRUGO);
+module_param(msix, uint, S_IRUGO);
 MODULE_PARM_DESC(rx_frag_size, "Size of a fragment that holds rcvd data.");
 MODULE_PARM_DESC(num_vfs, "Number of PCI VFs to initialize");
+MODULE_PARM_DESC(msix, "Enable/Disable the MSIx (MSIx enabled by default)");
 
 static bool multi_rxq = true;
 module_param(multi_rxq, bool, S_IRUGO | S_IWUSR);
@@ -2856,7 +2859,8 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	if (status)
 		goto stats_clean;
 
-	be_msix_enable(adapter);
+	if (msix)
+		be_msix_enable(adapter);
 
 	INIT_DELAYED_WORK(&adapter->work, be_worker);
 
@@ -3082,6 +3086,12 @@ static int __init be_init_module(void)
 		num_vfs = 32;
 	}
 
+	if (!msix && num_vfs > 0) {
+		printk(KERN_WARNING DRV_NAME
+			" : MSIx required for num_vfs > 0. Ignoring msix=0\n");
+		msix = 1;
+	}
+
 	return pci_register_driver(&be_driver);
 }
 module_init(be_init_module);
-- 
1.5.6.1

