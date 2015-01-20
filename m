From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next] amd-xgbe: Let OS arch support adjust DMA mask as
 needed
Date: Tue, 20 Jan 2015 14:47:55 -0600
Message-ID: <20150120204755.23431.37523.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [165.204.77.2] ([165.204.77.2]:50712 "EHLO
	tlendack-t1.amdoffice.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751630AbbATUr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 15:47:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set the DMA mask to 64-bit and let the underlying arch support adjust
it as appropriate based on device tree DMA ranges, etc.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index 32dd651..080c3a8 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -377,7 +377,7 @@ static int xgbe_probe(struct platform_device *pdev)
 	/* Set the DMA mask */
 	if (!dev->dma_mask)
 		dev->dma_mask = &dev->coherent_dma_mask;
-	ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(40));
+	ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64));
 	if (ret) {
 		dev_err(dev, "dma_set_mask_and_coherent failed\n");
 		goto err_io;
