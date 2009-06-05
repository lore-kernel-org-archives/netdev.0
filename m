From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 1/2] net: num_dma_maps is not used
Date: Fri, 05 Jun 2009 16:03:35 +0200
Message-ID: <4A2925B7.6050800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36406 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254AbZFEODk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 10:03:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of num_dma_maps in struct skb_shared_info, as it seems unused.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/skbuff.h |    3 ---
 net/core/skb_dma_map.c |    1 -
 2 files changed, 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7305da9..7485058 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -194,9 +194,6 @@ struct skb_shared_info {
 	unsigned short  gso_type;
 	__be32          ip6_frag_id;
 	union skb_shared_tx tx_flags;
-#ifdef CONFIG_HAS_DMA
-	unsigned int	num_dma_maps;
-#endif
 	struct sk_buff	*frag_list;
 	struct skb_shared_hwtstamps hwtstamps;
 	skb_frag_t	frags[MAX_SKB_FRAGS];
diff --git a/net/core/skb_dma_map.c b/net/core/skb_dma_map.c
index 8623492..7adb623 100644
--- a/net/core/skb_dma_map.c
+++ b/net/core/skb_dma_map.c
@@ -30,7 +30,6 @@ int skb_dma_map(struct device *dev, struct sk_buff *skb,
 			goto unwind;
 		sp->dma_maps[i + 1] = map;
 	}
-	sp->num_dma_maps = i + 1;
 
 	return 0;
 
