From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/9] fm10k: prefer %s and __func__ for diagnostic prints
Date: Tue,  3 Oct 2017 09:31:37 -0700
Message-ID: <20171003163138.47569-9-jeffrey.t.kirsher@intel.com>
References: <20171003163138.47569-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:31489 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751908AbdJCQcB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 12:32:01 -0400
In-Reply-To: <20171003163138.47569-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Don't hard code the function names in the diagnostic output when these
reset related routines fail. Instead, use %s and __func__ so that future
refactors don't need to change the print outs.

Additionally, while we are here, add missing function header comments
for the new reset_prepare and reset_done function handlers.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 58538ce997e1..1e9ae3197b17 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -2588,11 +2588,18 @@ static void fm10k_io_resume(struct pci_dev *pdev)
 
 	if (err)
 		dev_warn(&pdev->dev,
-			 "fm10k_io_resume failed: %d\n", err);
+			 "%s failed: %d\n", __func__, err);
 	else
 		netif_device_attach(netdev);
 }
 
+/**
+ * fm10k_io_reset_prepare - called when PCI function is about to be reset
+ * @pdev: Pointer to PCI device
+ *
+ * This callback is called when the PCI function is about to be reset,
+ * allowing the device driver to prepare for it.
+ */
 static void fm10k_io_reset_prepare(struct pci_dev *pdev)
 {
 	/* warn incase we have any active VF devices */
@@ -2602,6 +2609,13 @@ static void fm10k_io_reset_prepare(struct pci_dev *pdev)
 	fm10k_prepare_suspend(pci_get_drvdata(pdev));
 }
 
+/**
+ * fm10k_io_reset_done - called when PCI function has finished resetting
+ * @pdev: Pointer to PCI device
+ *
+ * This callback is called just after the PCI function is reset, such as via
+ * /sys/class/net/<enpX>/device/reset or similar.
+ */
 static void fm10k_io_reset_done(struct pci_dev *pdev)
 {
 	struct fm10k_intfc *interface = pci_get_drvdata(pdev);
@@ -2609,7 +2623,7 @@ static void fm10k_io_reset_done(struct pci_dev *pdev)
 
 	if (err) {
 		dev_warn(&pdev->dev,
-			 "fm10k_io_reset_notify failed: %d\n", err);
+			 "%s failed: %d\n", __func__, err);
 		netif_device_detach(interface->netdev);
 	}
 }
-- 
2.14.2
