From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/16] i40e/i40evf: Use dma_set_mask_and_coherent
Date: Fri, 14 Mar 2014 02:47:26 -0700
Message-ID: <1394790446-31591-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394790446-31591-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16598 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755769AbaCNJrh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 05:47:37 -0400
In-Reply-To: <1394790446-31591-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

In Linux 3.13, dma_set_mask_and_coherent was introduced, and we have
been encouraged to use it. It simplifies the DMA mapping code a bit as
well.

Change-ID: I66e340245af7d0dedfa8b40fec1f5e352754432e
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Catherine Sullivan  <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 16 ++++++----------
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 17 ++++++-----------
 2 files changed, 12 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 54e1462..7379e5a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7970,16 +7970,12 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		return err;
 
 	/* set up for high or low dma */
-	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))) {
-		/* coherent mask for the same size will always succeed if
-		 * dma_set_mask does
-		 */
-		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64));
-	} else if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(32))) {
-		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
-	} else {
-		dev_err(&pdev->dev, "DMA configuration failed: %d\n", err);
-		err = -EIO;
+	err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));
+	if (err)
+		err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
+	if (err) {
+		dev_err(&pdev->dev,
+			"DMA configuration failed: 0x%x\n", err);
 		goto err_dma;
 	}
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 8daab3a..d62e27f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2182,17 +2182,12 @@ static int i40evf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		return err;
 
-	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))) {
-		/* coherent mask for the same size will always succeed if
-		 * dma_set_mask does
-		 */
-		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64));
-	} else if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(32))) {
-		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
-	} else {
-		dev_err(&pdev->dev, "%s: DMA configuration failed: %d\n",
-			 __func__, err);
-		err = -EIO;
+	err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));
+	if (err)
+		err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
+	if (err) {
+		dev_err(&pdev->dev,
+			"DMA configuration failed: 0x%x\n", err);
 		goto err_dma;
 	}
 
-- 
1.8.3.1
