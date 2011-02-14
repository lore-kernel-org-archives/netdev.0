From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-26 1/4] cxgb4vf: Check driver parameters in the right place ...
Date: Mon, 14 Feb 2011 14:56:22 -0800
Message-ID: <1297724185-27452-2-git-send-email-leedom@chelsio.com>
References: <1297724185-27452-1-git-send-email-leedom@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:28811 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066Ab1BNW43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 17:56:29 -0500
In-Reply-To: <1297724185-27452-1-git-send-email-leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check module parameter validity in the module initialization routine instead
of the PCI Device Probe routine.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |   23 +++++++++++------------
 1 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index 56166ae..072b64e 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -2489,17 +2489,6 @@ static int __devinit cxgb4vf_pci_probe(struct pci_dev *pdev,
 	struct net_device *netdev;
 
 	/*
-	 * Vet our module parameters.
-	 */
-	if (msi != MSI_MSIX && msi != MSI_MSI) {
-		dev_err(&pdev->dev, "bad module parameter msi=%d; must be %d"
-			" (MSI-X or MSI) or %d (MSI)\n", msi, MSI_MSIX,
-			MSI_MSI);
-		err = -EINVAL;
-		goto err_out;
-	}
-
-	/*
 	 * Print our driver banner the first time we're called to initialize a
 	 * device.
 	 */
@@ -2802,7 +2791,6 @@ err_release_regions:
 err_disable_device:
 	pci_disable_device(pdev);
 
-err_out:
 	return err;
 }
 
@@ -2915,6 +2903,17 @@ static int __init cxgb4vf_module_init(void)
 {
 	int ret;
 
+	/*
+	 * Vet our module parameters.
+	 */
+	if (msi != MSI_MSIX && msi != MSI_MSI) {
+		printk(KERN_WARNING KBUILD_MODNAME
+		       ": bad module parameter msi=%d; must be %d"
+		       " (MSI-X or MSI) or %d (MSI)\n",
+		       msi, MSI_MSIX, MSI_MSI);
+		return -EINVAL;
+	}
+
 	/* Debugfs support is optional, just warn if this fails */
 	cxgb4vf_debugfs_root = debugfs_create_dir(KBUILD_MODNAME, NULL);
 	if (!cxgb4vf_debugfs_root)
-- 
1.7.0.4

