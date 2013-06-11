From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net] be2net: Fix 32-bit DMA Mask handling
Date: Tue, 11 Jun 2013 17:18:22 +0530
Message-ID: <e97260be-0d58-4285-a8e5-c9b030d60132@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:48338 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753900Ab3FKLtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 07:49:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix to set the coherent DMA mask only if dma_set_mask() succeeded, and to
error out if either fails.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 8bc1b21..a0b4be5 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4262,6 +4262,9 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 		netdev->features |= NETIF_F_HIGHDMA;
 	} else {
 		status = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
+		if (!status)
+			status = dma_set_coherent_mask(&pdev->dev,
+						       DMA_BIT_MASK(32));
 		if (status) {
 			dev_err(&pdev->dev, "Could not set PCI DMA Mask\n");
 			goto free_netdev;
-- 
1.6.0.2
