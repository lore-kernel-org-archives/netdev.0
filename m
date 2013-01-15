From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 04/10] vmxnet3: use netdev_dbg
Date: Tue, 15 Jan 2013 09:28:29 -0800
Message-ID: <1358270915-32758-5-git-send-email-stephen@networkplumber.org>
References: <1358270915-32758-1-git-send-email-stephen@networkplumber.org>
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f49.google.com ([209.85.210.49]:33083 "EHLO
	mail-da0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756779Ab3AORaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 12:30:10 -0500
Received: by mail-da0-f49.google.com with SMTP id v40so130235dad.36
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 09:30:10 -0800 (PST)
In-Reply-To: <1358270915-32758-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_dbg() rather than dev_dbg() because the former prints
the device name which is more useful than the pci name.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 7b10d9c..c566b73 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -629,7 +629,7 @@ vmxnet3_rq_alloc_rx_buf(struct vmxnet3_rx_queue *rq, u32 ring_idx,
 		vmxnet3_cmd_ring_adv_next2fill(ring);
 	}
 
-	dev_dbg(&adapter->netdev->dev,
+	netdev_dbg(adapter->netdev,
 		"alloc_rx_buf: %d allocated, next2fill %u, next2comp %u\n",
 		num_allocated, ring->next2fill, ring->next2comp);
 
@@ -688,7 +688,7 @@ vmxnet3_map_pkt(struct sk_buff *skb, struct vmxnet3_tx_ctx *ctx,
 		tbi = tq->buf_info + tq->tx_ring.next2fill;
 		tbi->map_type = VMXNET3_MAP_NONE;
 
-		dev_dbg(&adapter->netdev->dev,
+		netdev_dbg(adapter->netdev,
 			"txd[%u]: 0x%Lx 0x%x 0x%x\n",
 			tq->tx_ring.next2fill,
 			le64_to_cpu(ctx->sop_txd->txd.addr),
@@ -728,7 +728,7 @@ vmxnet3_map_pkt(struct sk_buff *skb, struct vmxnet3_tx_ctx *ctx,
 		gdesc->dword[2] = cpu_to_le32(dw2);
 		gdesc->dword[3] = 0;
 
-		dev_dbg(&adapter->netdev->dev,
+		netdev_dbg(adapter->netdev,
 			"txd[%u]: 0x%Lx 0x%x 0x%x\n",
 			tq->tx_ring.next2fill, le64_to_cpu(gdesc->txd.addr),
 			le32_to_cpu(gdesc->dword[2]), gdesc->dword[3]);
@@ -768,7 +768,7 @@ vmxnet3_map_pkt(struct sk_buff *skb, struct vmxnet3_tx_ctx *ctx,
 			gdesc->dword[2] = cpu_to_le32(dw2);
 			gdesc->dword[3] = 0;
 
-			dev_dbg(&adapter->netdev->dev,
+			netdev_dbg(adapter->netdev,
 				"txd[%u]: 0x%llu %u %u\n",
 				tq->tx_ring.next2fill, le64_to_cpu(gdesc->txd.addr),
 				le32_to_cpu(gdesc->dword[2]), gdesc->dword[3]);
@@ -868,7 +868,7 @@ vmxnet3_parse_and_copy_hdr(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 	tdd = tq->data_ring.base + tq->tx_ring.next2fill;
 
 	memcpy(tdd->data, skb->data, ctx->copy_size);
-	dev_dbg(&adapter->netdev->dev,
+	netdev_dbg(adapter->netdev,
 		"copy %u bytes to dataRing[%u]\n",
 		ctx->copy_size, tq->tx_ring.next2fill);
 	return 1;
@@ -974,7 +974,7 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 
 	if (count > vmxnet3_cmd_ring_desc_avail(&tq->tx_ring)) {
 		tq->stats.tx_ring_full++;
-		dev_dbg(&adapter->netdev->dev,
+		netdev_dbg(adapter->netdev,
 			"tx queue stopped on %s, next2comp %u"
 			" next2fill %u\n", adapter->netdev->name,
 			tq->tx_ring.next2comp, tq->tx_ring.next2fill);
@@ -1057,7 +1057,7 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 			   (struct Vmxnet3_TxDesc *)ctx.sop_txd);
 	gdesc = ctx.sop_txd;
 #endif
-	dev_dbg(&adapter->netdev->dev,
+	netdev_dbg(adapter->netdev,
 		"txd[%u]: SOP 0x%Lx 0x%x 0x%x\n",
 		(u32)(ctx.sop_txd -
 		tq->tx_ring.base), le64_to_cpu(gdesc->txd.addr),
@@ -1210,7 +1210,7 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 			if (unlikely(rcd->len == 0)) {
 				/* Pretend the rx buffer is skipped. */
 				BUG_ON(!(rcd->sop && rcd->eop));
-				dev_dbg(&adapter->netdev->dev,
+				netdev_dbg(adapter->netdev,
 					"rxRing[%u][%u] 0 length\n",
 					ring_idx, idx);
 				goto rcd_done;
@@ -2211,7 +2211,7 @@ vmxnet3_activate_dev(struct vmxnet3_adapter *adapter)
 	u32 ret;
 	unsigned long flags;
 
-	dev_dbg(&adapter->netdev->dev, "%s: skb_buf_size %d, rx_buf_per_pkt %d,"
+	netdev_dbg(adapter->netdev, "%s: skb_buf_size %d, rx_buf_per_pkt %d,"
 		" ring sizes %u %u %u\n", adapter->netdev->name,
 		adapter->skb_buf_size, adapter->rx_buf_per_pkt,
 		adapter->tx_queue[0].tx_ring.size,
-- 
1.7.10.4
