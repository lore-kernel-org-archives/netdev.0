From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 04/14] nfp: remove inline attributes and dead code
Date: Mon, 31 Oct 2016 20:43:12 +0000
Message-ID: <1477946602-19644-5-git-send-email-jakub.kicinski@netronome.com>
References: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:38311 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034017AbcJaUoC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:44:02 -0400
Received: by mail-wm0-f50.google.com with SMTP id n67so251676749wme.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 13:44:02 -0700 (PDT)
In-Reply-To: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't declare functions as static inline in .c files and
remove dead code it was hiding.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 15 +--------------
 1 file changed, 1 insertion(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index bd28e42bee2b..025483fb9103 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -576,7 +576,7 @@ static void nfp_net_aux_irq_free(struct nfp_net *nn, u32 ctrl_offset,
  *
  * Return: True if the ring is full.
  */
-static inline int nfp_net_tx_full(struct nfp_net_tx_ring *tx_ring, int dcnt)
+static int nfp_net_tx_full(struct nfp_net_tx_ring *tx_ring, int dcnt)
 {
 	return (tx_ring->wr_p - tx_ring->rd_p) >= (tx_ring->cnt - dcnt);
 }
@@ -1032,19 +1032,6 @@ static void nfp_net_tx_timeout(struct net_device *netdev)
  */
 
 /**
- * nfp_net_rx_space() - return the number of free slots on the RX ring
- * @rx_ring:   RX ring structure
- *
- * Make sure we leave at least one slot free.
- *
- * Return: True if there is space on the RX ring
- */
-static inline int nfp_net_rx_space(struct nfp_net_rx_ring *rx_ring)
-{
-	return (rx_ring->cnt - 1) - (rx_ring->wr_p - rx_ring->rd_p);
-}
-
-/**
  * nfp_net_rx_alloc_one() - Allocate and map skb for RX
  * @rx_ring:	RX ring structure of the skb
  * @dma_addr:	Pointer to storage for DMA address (output param)
-- 
1.9.1
