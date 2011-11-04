From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net v2 8/8] forcedeth: fix a few sparse warnings (variable shadowing)
Date: Thu,  3 Nov 2011 18:41:23 -0700
Message-ID: <02dc92aa978f9e91a866b5167ed0b14c337d4d5f.1320369398.git.david.decotigny@google.com>
References: <cover.1320369398.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:52675 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754309Ab1KDBmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 21:42:21 -0400
In-Reply-To: <cover.1320369398.git.david.decotigny@google.com>
In-Reply-To: <cover.1320369398.git.david.decotigny@google.com>
References: <cover.1320369398.git.david.decotigny@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes the following sparse warnings:
drivers/net/ethernet/nvidia/forcedeth.c:2113:7: warning: symbol 'size' shadows an earlier one
drivers/net/ethernet/nvidia/forcedeth.c:2102:6: originally declared here
drivers/net/ethernet/nvidia/forcedeth.c:2155:7: warning: symbol 'size' shadows an earlier one
drivers/net/ethernet/nvidia/forcedeth.c:2102:6: originally declared here
drivers/net/ethernet/nvidia/forcedeth.c:2227:7: warning: symbol 'size' shadows an earlier one
drivers/net/ethernet/nvidia/forcedeth.c:2215:6: originally declared here
drivers/net/ethernet/nvidia/forcedeth.c:2271:7: warning: symbol 'size' shadows an earlier one
drivers/net/ethernet/nvidia/forcedeth.c:2215:6: originally declared here
drivers/net/ethernet/nvidia/forcedeth.c:2986:20: warning: symbol 'addr' shadows an earlier one
drivers/net/ethernet/nvidia/forcedeth.c:2963:6: originally declared here



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |   34 +++++++++++++++---------------
 1 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 5442638..913f054 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -2110,10 +2110,10 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* add fragments to entries count */
 	for (i = 0; i < fragments; i++) {
-		u32 size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
+		u32 frag_size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
 
-		entries += (size >> NV_TX2_TSO_MAX_SHIFT) +
-			   ((size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
+		entries += (frag_size >> NV_TX2_TSO_MAX_SHIFT) +
+			   ((frag_size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
 	}
 
 	spin_lock_irqsave(&np->lock, flags);
@@ -2152,13 +2152,13 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* setup the fragments */
 	for (i = 0; i < fragments; i++) {
 		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-		u32 size = skb_frag_size(frag);
+		u32 frag_size = skb_frag_size(frag);
 		offset = 0;
 
 		do {
 			prev_tx = put_tx;
 			prev_tx_ctx = np->put_tx_ctx;
-			bcnt = (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
+			bcnt = (frag_size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : frag_size;
 			np->put_tx_ctx->dma = skb_frag_dma_map(
 							&np->pci_dev->dev,
 							frag, offset,
@@ -2170,12 +2170,12 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			put_tx->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
 
 			offset += bcnt;
-			size -= bcnt;
+			frag_size -= bcnt;
 			if (unlikely(put_tx++ == np->last_tx.orig))
 				put_tx = np->first_tx.orig;
 			if (unlikely(np->put_tx_ctx++ == np->last_tx_ctx))
 				np->put_tx_ctx = np->first_tx_ctx;
-		} while (size);
+		} while (frag_size);
 	}
 
 	/* set last fragment flag  */
@@ -2224,10 +2224,10 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 
 	/* add fragments to entries count */
 	for (i = 0; i < fragments; i++) {
-		u32 size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
+		u32 frag_size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
 
-		entries += (size >> NV_TX2_TSO_MAX_SHIFT) +
-			   ((size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
+		entries += (frag_size >> NV_TX2_TSO_MAX_SHIFT) +
+			   ((frag_size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
 	}
 
 	spin_lock_irqsave(&np->lock, flags);
@@ -2268,13 +2268,13 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 	/* setup the fragments */
 	for (i = 0; i < fragments; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-		u32 size = skb_frag_size(frag);
+		u32 frag_size = skb_frag_size(frag);
 		offset = 0;
 
 		do {
 			prev_tx = put_tx;
 			prev_tx_ctx = np->put_tx_ctx;
-			bcnt = (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
+			bcnt = (frag_size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : frag_size;
 			np->put_tx_ctx->dma = skb_frag_dma_map(
 							&np->pci_dev->dev,
 							frag, offset,
@@ -2287,12 +2287,12 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 			put_tx->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
 
 			offset += bcnt;
-			size -= bcnt;
+			frag_size -= bcnt;
 			if (unlikely(put_tx++ == np->last_tx.ex))
 				put_tx = np->first_tx.ex;
 			if (unlikely(np->put_tx_ctx++ == np->last_tx_ctx))
 				np->put_tx_ctx = np->first_tx_ctx;
-		} while (size);
+		} while (frag_size);
 	}
 
 	/* set last fragment flag  */
@@ -2983,11 +2983,11 @@ static void nv_set_multicast(struct net_device *dev)
 				struct netdev_hw_addr *ha;
 
 				netdev_for_each_mc_addr(ha, dev) {
-					unsigned char *addr = ha->addr;
+					unsigned char *hw_addr = ha->addr;
 					u32 a, b;
 
-					a = le32_to_cpu(*(__le32 *) addr);
-					b = le16_to_cpu(*(__le16 *) (&addr[4]));
+					a = le32_to_cpu(*(__le32 *) hw_addr);
+					b = le16_to_cpu(*(__le16 *) (&hw_addr[4]));
 					alwaysOn[0] &= a;
 					alwaysOff[0] &= ~a;
 					alwaysOn[1] &= b;
-- 
1.7.3.1
