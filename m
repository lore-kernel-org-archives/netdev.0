From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 21/25] ixgb: clean up assignments inside if statements
Date: Tue, 08 Jul 2008 15:52:48 -0700
Message-ID: <20080708225248.6925.83391.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:48202 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754898AbYGHWwu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:52:50 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 365212b..05b2677 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -355,15 +355,16 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	int i;
 	int err;
 
-	if ((err = pci_enable_device(pdev)))
+	err = pci_enable_device(pdev);
+	if (err)
 		return err;
 
 	if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
-	   !(err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK))) {
+	    !(err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK))) {
 		pci_using_dac = 1;
 	} else {
 		if ((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) ||
-		   (err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK))) {
+		    (err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK))) {
 			printk(KERN_ERR
 			 "ixgb: No usable DMA configuration, aborting\n");
 			goto err_dma_mask;
@@ -371,7 +372,8 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		pci_using_dac = 0;
 	}
 
-	if ((err = pci_request_regions(pdev, ixgb_driver_name)))
+	err = pci_request_regions(pdev, ixgb_driver_name);
+	if (err)
 		goto err_request_regions;
 
 	pci_set_master(pdev);
@@ -435,7 +437,8 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* setup the private structure */
 
-	if ((err = ixgb_sw_init(adapter)))
+	err = ixgb_sw_init(adapter);
+	if (err)
 		goto err_sw_init;
 
 	netdev->features = NETIF_F_SG |
@@ -474,7 +477,8 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	INIT_WORK(&adapter->tx_timeout_task, ixgb_tx_timeout_task);
 
 	strcpy(netdev->name, "eth%d");
-	if ((err = register_netdev(netdev)))
+	err = register_netdev(netdev);
+	if (err)
 		goto err_register;
 
 	/* we're going to reset, so assume we have no link for now */
@@ -594,16 +598,18 @@ ixgb_open(struct net_device *netdev)
 	int err;
 
 	/* allocate transmit descriptors */
-
-	if ((err = ixgb_setup_tx_resources(adapter)))
+	err = ixgb_setup_tx_resources(adapter);
+	if (err)
 		goto err_setup_tx;
 
 	/* allocate receive descriptors */
 
-	if ((err = ixgb_setup_rx_resources(adapter)))
+	err = ixgb_setup_rx_resources(adapter);
+	if (err)
 		goto err_setup_rx;
 
-	if ((err = ixgb_up(adapter)))
+	err = ixgb_up(adapter);
+	if (err)
 		goto err_up;
 
 	return 0;

