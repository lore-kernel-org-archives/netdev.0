From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 7/7] amd-xgbe: Remove manual check and set of
 dma_mask pointer
Date: Tue, 12 May 2015 14:23:13 -0500
Message-ID: <20150512192313.14091.85765.stgit@tlendack-t1.amdoffice.net>
References: <20150512192229.14091.34354.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0114.outbound.protection.outlook.com ([65.55.169.114]:50032
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933471AbbELTXT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2015 15:23:19 -0400
In-Reply-To: <20150512192229.14091.34354.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The underlying device support will set the device dma_mask pointer
if DMA is set up properly for the device.  Remove the check for and
assignment of dma_mask when it is null. Instead, just error out if
the dma_set_mask_and_coherent function fails because dma_mask is null.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-main.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index 34c521d..fb7c961 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -678,8 +678,6 @@ static int xgbe_probe(struct platform_device *pdev)
 	xgbe_default_config(pdata);
 
 	/* Set the DMA mask */
-	if (!dev->dma_mask)
-		dev->dma_mask = &dev->coherent_dma_mask;
 	ret = dma_set_mask_and_coherent(dev,
 					DMA_BIT_MASK(pdata->hw_feat.dma_width));
 	if (ret) {
