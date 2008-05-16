From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 4/6] [BNX2]: Rename RX_COPY_THRESH to
 BNX2_RX_COPY_THRESH.
Date: Fri, 16 May 2008 14:30:36 -0700
Message-ID: <1210973436.5507.20.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, benli@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4225 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758256AbYEPUZv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2008 16:25:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Rename RX_COPY_THRESH to BNX2_RX_COPY_THRESH.

To make the bnx2 code more consistent, all instances of
RX_COPY_THRESH have been changed to BNX2_RX_COPY_THRESH.

Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    9 +++++----
 drivers/net/bnx2.h |    2 +-
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 2180922..1534eed 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2624,7 +2624,7 @@ bnx2_reuse_rx_skb(struct bnx2 *bp, struct bnx2_napi *bnapi, struct sk_buff *skb,
 
 	pci_dma_sync_single_for_device(bp->pdev,
 		pci_unmap_addr(cons_rx_buf, mapping),
-		BNX2_RX_OFFSET + RX_COPY_THRESH, PCI_DMA_FROMDEVICE);
+		BNX2_RX_OFFSET + BNX2_RX_COPY_THRESH, PCI_DMA_FROMDEVICE);
 
 	bnapi->rx_prod_bseq += bp->rx_buf_use_size;
 
@@ -2777,7 +2777,8 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		dma_addr = pci_unmap_addr(rx_buf, mapping);
 
 		pci_dma_sync_single_for_cpu(bp->pdev, dma_addr,
-			BNX2_RX_OFFSET + RX_COPY_THRESH, PCI_DMA_FROMDEVICE);
+			BNX2_RX_OFFSET + BNX2_RX_COPY_THRESH,
+			PCI_DMA_FROMDEVICE);
 
 		rx_hdr = (struct l2_fhdr *) skb->data;
 		len = rx_hdr->l2_fhdr_pkt_len;
@@ -4760,7 +4761,7 @@ bnx2_set_rx_ring_size(struct bnx2 *bp, u32 size)
 	rx_space = SKB_DATA_ALIGN(rx_size + BNX2_RX_ALIGN) + NET_SKB_PAD +
 		sizeof(struct skb_shared_info);
 
-	bp->rx_copy_thresh = RX_COPY_THRESH;
+	bp->rx_copy_thresh = BNX2_RX_COPY_THRESH;
 	bp->rx_pg_ring_size = 0;
 	bp->rx_max_pg_ring = 0;
 	bp->rx_max_pg_ring_idx = 0;
@@ -4775,7 +4776,7 @@ bnx2_set_rx_ring_size(struct bnx2 *bp, u32 size)
 		bp->rx_max_pg_ring = bnx2_find_max_ring(jumbo_size,
 							MAX_RX_PG_RINGS);
 		bp->rx_max_pg_ring_idx = (bp->rx_max_pg_ring * RX_DESC_CNT) - 1;
-		rx_size = RX_COPY_THRESH + BNX2_RX_OFFSET;
+		rx_size = BNX2_RX_COPY_THRESH + BNX2_RX_OFFSET;
 		bp->rx_copy_thresh = 0;
 	}
 
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 142c27e..3c3c5ab 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6413,7 +6413,7 @@ struct l2_fhdr {
 #define MAX_ETHERNET_PACKET_SIZE	1514
 #define MAX_ETHERNET_JUMBO_PACKET_SIZE	9014
 
-#define RX_COPY_THRESH			128
+#define BNX2_RX_COPY_THRESH		128
 
 #define BNX2_MISC_ENABLE_DEFAULT	0x17ffffff
 
-- 
1.5.5.GIT



