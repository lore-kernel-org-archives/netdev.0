From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH 04/10] bnx2x: remove unnecessary dma_sync
Date: Tue, 19 Jul 2011 14:40:27 +0300
Message-ID: <1311075627.30287.5.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4807 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752240Ab1GSLu0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2011 07:50:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Zolotarov <vladz@broadcom.com>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.h |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index 595d4cd..83d7d1b 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -936,16 +936,11 @@ static inline int bnx2x_alloc_rx_skb(struct bnx2x *bp,
 static inline void bnx2x_reuse_rx_skb(struct bnx2x_fastpath *fp,
 				      u16 cons, u16 prod)
 {
-	struct bnx2x *bp = fp->bp;
 	struct sw_rx_bd *cons_rx_buf = &fp->rx_buf_ring[cons];
 	struct sw_rx_bd *prod_rx_buf = &fp->rx_buf_ring[prod];
 	struct eth_rx_bd *cons_bd = &fp->rx_desc_ring[cons];
 	struct eth_rx_bd *prod_bd = &fp->rx_desc_ring[prod];
 
-	dma_sync_single_for_device(&bp->pdev->dev,
-				   dma_unmap_addr(cons_rx_buf, mapping),
-				   RX_COPY_THRESH, DMA_FROM_DEVICE);
-
 	dma_unmap_addr_set(prod_rx_buf, mapping,
 			   dma_unmap_addr(cons_rx_buf, mapping));
 	prod_rx_buf->skb = cons_rx_buf->skb;
-- 
1.7.2.2




