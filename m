From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH] drivers/net/ethernet/tile: use skb_frag_page() API
Date: Thu, 1 Dec 2011 12:56:03 -0500
Message-ID: <201112011815.pB1IFD2t004910@farm-0002.internal.tilera.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This replaces raw access to the "page" field of the skb_frag_t.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilepro.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 10826d8..1c0f9fa 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -1697,7 +1697,7 @@ static unsigned int tile_net_tx_frags(lepp_frag_t *frags,
 	for (i = 0; i < sh->nr_frags; i++) {
 
 		skb_frag_t *f = &sh->frags[i];
-		unsigned long pfn = page_to_pfn(f->page);
+		unsigned long pfn = page_to_pfn(skb_frag_page(f));
 
 		/* FIXME: Compute "hash_for_home" properly. */
 		/* ISSUE: The hypervisor checks CHIP_HAS_REV1_DMA_PACKETS(). */
@@ -1706,7 +1706,7 @@ static unsigned int tile_net_tx_frags(lepp_frag_t *frags,
 		/* FIXME: Hmmm. */
 		if (!hash_default) {
 			void *va = pfn_to_kaddr(pfn) + f->page_offset;
-			BUG_ON(PageHighMem(f->page));
+			BUG_ON(PageHighMem(skb_frag_page(f)));
 			finv_buffer_remote(va, f->size, 0);
 		}
 
-- 
1.6.5.2
