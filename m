From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 2/6] nfp: drop rx_ring param from buffer allocation
Date: Thu, 27 Apr 2017 21:06:16 -0700
Message-ID: <20170428040620.8256-3-jakub.kicinski@netronome.com>
References: <20170428040620.8256-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:35631 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751249AbdD1EHA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 00:07:00 -0400
Received: by mail-pg0-f41.google.com with SMTP id o3so3017912pgn.2
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 21:06:59 -0700 (PDT)
In-Reply-To: <20170428040620.8256-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We will soon allocate RX buffers for caching on XDP TX rings.
The rx_ring parameter passed to nfp_net_rx_alloc_one() is not
actually used, remove it.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 0e87b446e98f..fc0652d175fc 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1153,16 +1153,13 @@ nfp_net_free_frag(void *frag, bool xdp)
 /**
  * nfp_net_rx_alloc_one() - Allocate and map page frag for RX
  * @dp:		NFP Net data path struct
- * @rx_ring:	RX ring structure of the skb
  * @dma_addr:	Pointer to storage for DMA address (output param)
  *
  * This function will allcate a new page frag, map it for DMA.
  *
  * Return: allocated page frag or NULL on failure.
  */
-static void *
-nfp_net_rx_alloc_one(struct nfp_net_dp *dp, struct nfp_net_rx_ring *rx_ring,
-		     dma_addr_t *dma_addr)
+static void *nfp_net_rx_alloc_one(struct nfp_net_dp *dp, dma_addr_t *dma_addr)
 {
 	void *frag;
 
@@ -1317,8 +1314,7 @@ nfp_net_rx_ring_bufs_alloc(struct nfp_net_dp *dp,
 	rxbufs = rx_ring->rxbufs;
 
 	for (i = 0; i < rx_ring->cnt - 1; i++) {
-		rxbufs[i].frag =
-			nfp_net_rx_alloc_one(dp, rx_ring, &rxbufs[i].dma_addr);
+		rxbufs[i].frag = nfp_net_rx_alloc_one(dp, &rxbufs[i].dma_addr);
 		if (!rxbufs[i].frag) {
 			nfp_net_rx_ring_bufs_free(dp, rx_ring);
 			return -ENOMEM;
-- 
2.11.0
