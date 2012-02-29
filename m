From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: [PATCH] vmxnet3: Fix log messages and corrects some typos
Date: Tue, 28 Feb 2012 22:55:31 -0800 (PST)
Message-ID: <alpine.LRH.2.00.1202282209500.19873@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: pv-drivers@vmware.com, petr@vmware.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:45570 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964954Ab2B2Gzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 01:55:31 -0500
Received: from sc9-mailhost2.vmware.com (sc9-mailhost2.vmware.com [10.113.161.72])
	by smtp-outbound-1.vmware.com (Postfix) with ESMTP id 78EC92830A
	for <netdev@vger.kernel.org>; Tue, 28 Feb 2012 22:55:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix log messages and corrects some typos

Change logging of failure to enable MSI/MSI-X to display device's PCI
address instead of eth%d. Rectify a typo.

Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
---

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index de7fc34..51ec299 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2709,8 +2709,8 @@ vmxnet3_acquire_msix_vectors(struct vmxnet3_adapter *adapter,
 			adapter->intr.num_intrs = vectors;
 			return 0;
 		} else if (err < 0) {
-			printk(KERN_ERR "Failed to enable MSI-X for %s, error"
-			       " %d\n",	adapter->netdev->name, err);
+			netdev_info(adapter->netdev, "Failed to enable MSI-X, "
+				    "error: %d\n", err);
 			vectors = 0;
 		} else if (err < vector_threshold) {
 			break;
@@ -2718,15 +2718,15 @@ vmxnet3_acquire_msix_vectors(struct vmxnet3_adapter *adapter,
 			/* If fails to enable required number of MSI-x vectors
 			 * try enabling minimum number of vectors required.
 			 */
+			netdev_info(adapter->netdev, "Failed to enable %d MSI-X"
+				    ", trying %d instead\n", vectors,
+				    vector_threshold);
 			vectors = vector_threshold;
-			printk(KERN_ERR "Failed to enable %d MSI-X for %s, try"
-			       " %d instead\n", vectors, adapter->netdev->name,
-			       vector_threshold);
 		}
 	}
 
-	printk(KERN_INFO "Number of MSI-X interrupts which can be allocatedi"
-	       " are lower than min threshold required.\n");
+	netdev_info(adapter->netdev, "Number of MSI-X interrupts which can be "
+		    " allocated are lower than min threshold required.\n");
 	return err;
 }
 
@@ -2792,8 +2792,8 @@ vmxnet3_alloc_intr_resources(struct vmxnet3_adapter *adapter)
 			return;
 
 		/* If we cannot allocate MSIx vectors use only one rx queue */
-		printk(KERN_INFO "Failed to enable MSI-X for %s, error %d."
-		       "#rx queues : 1, try MSI\n", adapter->netdev->name, err);
+		netdev_info(adapter->netdev, "Failed to enable MSI-X, error %d."
+			    "Limiting #rx queues to 1, try MSI.\n", err);
 
 		adapter->intr.type = VMXNET3_IT_MSI;
 	}
