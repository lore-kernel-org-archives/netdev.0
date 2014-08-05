From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 1/2] amd-xgbe: Use dma_set_mask_and_coherent to set
 DMA mask
Date: Tue, 5 Aug 2014 11:21:19 -0500
Message-ID: <20140805162119.28088.36709.stgit@tlendack-t1.amdoffice.net>
References: <20140805162113.28088.67523.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0204.outbound.protection.outlook.com ([207.46.163.204]:35290
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755468AbaHEQVo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2014 12:21:44 -0400
In-Reply-To: <20140805162113.28088.67523.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the dma_set_mask_and_coherent function to set the DMA mask rather
than setting the DMA mask fields directly.  This was originally done
to work around a bug in the arm64 DMA support when RAM started above
the 4GB boundary which has since been fixed.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-main.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index ec977d3..9991bc7 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -303,8 +303,7 @@ static int xgbe_probe(struct platform_device *pdev)
 	/* Set the DMA mask */
 	if (!dev->dma_mask)
 		dev->dma_mask = &dev->coherent_dma_mask;
-	*(dev->dma_mask) = DMA_BIT_MASK(40);
-	dev->coherent_dma_mask = DMA_BIT_MASK(40);
+	dma_set_mask_and_coherent(dev, DMA_BIT_MASK(40));
 
 	if (of_property_read_bool(dev->of_node, "dma-coherent")) {
 		pdata->axdomain = XGBE_DMA_OS_AXDOMAIN;
