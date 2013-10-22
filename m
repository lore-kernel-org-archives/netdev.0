From: Thierry Reding <thierry.reding@gmail.com>
Subject: linux-next: manual merge of the arm tree
Date: Tue, 22 Oct 2013 17:08:35 +0200
Message-ID: <1382454517-4074-2-git-send-email-treding@nvidia.com>
References: <1382454517-4074-1-git-send-email-treding@nvidia.com>
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Russell King <rmk@arm.linux.org.uk>,
	Merav Sicron <meravs@broadcom.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382454517-4074-1-git-send-email-treding@nvidia.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Today's linux-next merge of the arm tree got a conflict in

	drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c

caused by commits 1bfa2c4 (DMA-API: net: broadcom/bnx2x: replace
dma_set_mask()+dma_set_coherent_mask() with new helper) and edd3147
(bnx2x: Set NETIF_F_HIGHDMA unconditionally).

I fixed it up (see below). Please verify that the resolution looks good.

Thanks,
Thierry
---
diff --cc drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index b42f89c,38bf998..767aafb
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@@ -12117,12 -12079,9 +12117,8 @@@ static int bnx2x_set_coherency_mask(str
  {
  	struct device *dev = &bp->pdev->dev;
  
- 	if (dma_set_mask(dev, DMA_BIT_MASK(64)) == 0) {
- 		if (dma_set_coherent_mask(dev, DMA_BIT_MASK(64)) != 0) {
- 			dev_err(dev, "dma_set_coherent_mask failed, aborting\n");
- 			return -EIO;
- 		}
- 	} else if (dma_set_mask(dev, DMA_BIT_MASK(32)) != 0) {
 -	if (dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64)) == 0) {
 -		bp->flags |= USING_DAC_FLAG;
 -	} else if (dma_set_mask_and_coherent(dev, DMA_BIT_MASK(32)) != 0) {
++	if (dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64)) != 0 &&
++	    dma_set_mask_and_coherent(dev, DMA_BIT_MASK(32)) != 0) {
  		dev_err(dev, "System does not support DMA, aborting\n");
  		return -EIO;
  	}
