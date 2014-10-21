From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net] sfc: remove incorrect EFX_BUG_ON_PARANOID check
Date: Tue, 21 Oct 2014 14:50:29 +0100
Message-ID: <alpine.LFD.2.03.1410211353290.26215@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <sshah@solarflare.com>, <jcooper@solarflare.com>,
	<linux-net-drivers@solarflare.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:56551 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932556AbaJUNy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2014 09:54:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

write_count and insert_count can wrap around, making > check invalid.

Fixes: 70b33fb0ddec827cbbd14cdc664fc27b2ef4a6b6 ("sfc: add support for
 skb->xmit_more").

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
Compile tested only.

 drivers/net/ethernet/sfc/tx.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index ee84a90..aaf2987 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -343,8 +343,6 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 	unsigned short dma_flags;
 	int i = 0;
 
-	EFX_BUG_ON_PARANOID(tx_queue->write_count > tx_queue->insert_count);
-
 	if (skb_shinfo(skb)->gso_size)
 		return efx_enqueue_skb_tso(tx_queue, skb);
 
@@ -1258,8 +1256,6 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 	/* Find the packet protocol and sanity-check it */
 	state.protocol = efx_tso_check_protocol(skb);
 
-	EFX_BUG_ON_PARANOID(tx_queue->write_count > tx_queue->insert_count);
-
 	rc = tso_start(&state, efx, skb);
 	if (rc)
 		goto mem_err;
-- 
1.7.11.7
