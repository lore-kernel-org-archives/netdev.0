From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 13/20] tg3: tg3_alloc_rx_skb(tnapi => tp)
Date: Fri, 13 Nov 2009 15:03:45 -0800
Message-ID: <1258153432-7036-14-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4673 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932472AbZKMXEX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 18:04:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts the tnapi argument of tg3_alloc_rx_skb() to tp.  The
level of indirection is unnecessary.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 9251bb5..00e7e14 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4408,11 +4408,9 @@ static void tg3_tx(struct tg3_napi *tnapi)
  * buffers the cpu only reads the last cacheline of the RX descriptor
  * (to fetch the error flags, vlan tag, checksum, and opaque cookie).
  */
-static int tg3_alloc_rx_skb(struct tg3_napi *tnapi,
-			    struct tg3_rx_prodring_set *tpr,
+static int tg3_alloc_rx_skb(struct tg3 *tp, struct tg3_rx_prodring_set *tpr,
 			    u32 opaque_key, u32 dest_idx_unmasked)
 {
-	struct tg3 *tp = tnapi->tp;
 	struct tg3_rx_buffer_desc *desc;
 	struct ring_info *map, *src_map;
 	struct sk_buff *skb;
@@ -4601,7 +4599,7 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 		) {
 			int skb_size;
 
-			skb_size = tg3_alloc_rx_skb(tnapi, tpr, opaque_key,
+			skb_size = tg3_alloc_rx_skb(tp, tpr, opaque_key,
 						    *post_ptr);
 			if (skb_size < 0)
 				goto drop_it;
@@ -5744,7 +5742,6 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp,
 				 struct tg3_rx_prodring_set *tpr)
 {
 	u32 i, rx_pkt_dma_sz;
-	struct tg3_napi *tnapi = &tp->napi[0];
 
 	/* Zero out all descriptors. */
 	memset(tpr->rx_std, 0, TG3_RX_RING_BYTES);
@@ -5771,7 +5768,7 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp,
 
 	/* Now allocate fresh SKBs for each rx ring. */
 	for (i = 0; i < tp->rx_pending; i++) {
-		if (tg3_alloc_rx_skb(tnapi, tpr, RXD_OPAQUE_RING_STD, i) < 0) {
+		if (tg3_alloc_rx_skb(tp, tpr, RXD_OPAQUE_RING_STD, i) < 0) {
 			printk(KERN_WARNING PFX
 			       "%s: Using a smaller RX standard ring, "
 			       "only %d out of %d buffers were allocated "
@@ -5802,7 +5799,7 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp,
 		}
 
 		for (i = 0; i < tp->rx_jumbo_pending; i++) {
-			if (tg3_alloc_rx_skb(tnapi, tpr, RXD_OPAQUE_RING_JUMBO,
+			if (tg3_alloc_rx_skb(tp, tpr, RXD_OPAQUE_RING_JUMBO,
 					     i) < 0) {
 				printk(KERN_WARNING PFX
 				       "%s: Using a smaller RX jumbo ring, "
-- 
1.6.4.4


