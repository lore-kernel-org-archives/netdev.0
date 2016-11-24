From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch net-next] sfc: remove unneeded variable
Date: Thu, 24 Nov 2016 14:16:51 +0300
Message-ID: <20161124111651.GJ17225@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bert Kenward <bkenward@solarflare.com>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
        Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25587 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964867AbcKXLSB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 06:18:01 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't use ->heap_buf after commit 46d1efd852cc ("sfc: remove Software
TSO") so let's remove the last traces.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index f97f828..fd17bda 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -139,8 +139,6 @@ struct efx_special_buffer {
  * struct efx_tx_buffer - buffer state for a TX descriptor
  * @skb: When @flags & %EFX_TX_BUF_SKB, the associated socket buffer to be
  *	freed when descriptor completes
- * @heap_buf: When @flags & %EFX_TX_BUF_HEAP, the associated heap buffer to be
- *	freed when descriptor completes.
  * @option: When @flags & %EFX_TX_BUF_OPTION, a NIC-specific option descriptor.
  * @dma_addr: DMA address of the fragment.
  * @flags: Flags for allocation and DMA mapping type
@@ -151,10 +149,7 @@ struct efx_special_buffer {
  * Only valid if @unmap_len != 0.
  */
 struct efx_tx_buffer {
-	union {
-		const struct sk_buff *skb;
-		void *heap_buf;
-	};
+	const struct sk_buff *skb;
 	union {
 		efx_qword_t option;
 		dma_addr_t dma_addr;
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 1aa728c..bb07034 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -84,8 +84,6 @@ static void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
 		netif_vdbg(tx_queue->efx, tx_done, tx_queue->efx->net_dev,
 			   "TX queue %d transmission id %x complete\n",
 			   tx_queue->queue, tx_queue->read_count);
-	} else if (buffer->flags & EFX_TX_BUF_HEAP) {
-		kfree(buffer->heap_buf);
 	}
 
 	buffer->len = 0;
