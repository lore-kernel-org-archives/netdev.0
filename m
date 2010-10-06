From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 13/19] bnx2x: use proper constants for
 dma_unmap* calls
Date: Wed, 6 Oct 2010 15:30:27 +0200
Message-ID: <1286371827.30552.49.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4218 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932260Ab0JFNkX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 09:40:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |    2 +-
 drivers/net/bnx2x/bnx2x_cmn.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 5b8c0b6..7ee9af0 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -54,7 +54,7 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	DP(BNX2X_MSG_OFF, "free bd_idx %d\n", bd_idx);
 	tx_start_bd = &fp->tx_desc_ring[bd_idx].start_bd;
 	dma_unmap_single(&bp->pdev->dev, BD_UNMAP_ADDR(tx_start_bd),
-			 BD_UNMAP_LEN(tx_start_bd), PCI_DMA_TODEVICE);
+			 BD_UNMAP_LEN(tx_start_bd), DMA_TO_DEVICE);
 
 	nbd = le16_to_cpu(tx_start_bd->nbd) - 1;
 #ifdef BNX2X_STOP_ON_ERROR
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index 73ed5a6..f08a42a 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -597,7 +597,7 @@ static inline void bnx2x_free_rx_sge(struct bnx2x *bp,
 		return;
 
 	dma_unmap_page(&bp->pdev->dev, dma_unmap_addr(sw_buf, mapping),
-		       SGE_PAGE_SIZE*PAGES_PER_SGE, PCI_DMA_FROMDEVICE);
+		       SGE_PAGE_SIZE*PAGES_PER_SGE, DMA_FROM_DEVICE);
 	__free_pages(page, PAGES_PER_SGE_SHIFT);
 
 	sw_buf->page = NULL;
-- 
1.7.1




