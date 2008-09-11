From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/3]: net: Add DMA mapping tokens to skb_shared_info.
Date: Thu, 11 Sep 2008 05:03:06 -0700 (PDT)
Message-ID: <20080911.050306.202304047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56515
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752581AbYIKMDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 08:03:12 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id D5362C8C181
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 05:03:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


net: Add DMA mapping tokens to skb_shared_info.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9099237..4b2be23 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -146,8 +146,14 @@ struct skb_shared_info {
 	unsigned short	gso_segs;
 	unsigned short  gso_type;
 	__be32          ip6_frag_id;
+#ifdef CONFIG_HAS_DMA
+	unsigned int	num_dma_maps;
+#endif
 	struct sk_buff	*frag_list;
 	skb_frag_t	frags[MAX_SKB_FRAGS];
+#ifdef CONFIG_HAS_DMA
+	dma_addr_t	dma_maps[MAX_SKB_FRAGS + 1];
+#endif
 };
 
 /* We divide dataref into two halves.  The higher 16 bits hold references
-- 
1.5.6.5.GIT

