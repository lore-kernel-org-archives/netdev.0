From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH 02/31] [SK_BUFF]: Remove skb_add_mtu() leftovers
Date: Tue, 20 Mar 2007 19:52:21 -0300
Message-ID: <20070320225221.GN17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:24621 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853AbXCTWw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 18:52:26 -0400
Received: by wx-out-0506.google.com with SMTP id h31so60061wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 15:52:25 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/linux/skbuff.h |    1 -
 net/core/skbuff.c      |   14 --------------
 2 files changed, 0 insertions(+), 15 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4803e4d..155f0e6 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1510,7 +1510,6 @@ static inline void *skb_header_pointer(const struct sk_buff *skb, int offset,
 }
 
 extern void skb_init(void);
-extern void skb_add_mtu(int mtu);
 
 /**
  *	skb_get_timestamp - get timestamp from a skb
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 88625f9..e5e41d6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -157,7 +157,6 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	if (!skb)
 		goto out;
 
-	/* Get the DATA. Size must match skb_add_mtu(). */
 	size = SKB_DATA_ALIGN(size);
 	data = kmalloc_node_track_caller(size + sizeof(struct skb_shared_info),
 			gfp_mask, node);
@@ -1590,19 +1589,6 @@ void skb_insert(struct sk_buff *old, struct sk_buff *newsk, struct sk_buff_head
 	spin_unlock_irqrestore(&list->lock, flags);
 }
 
-#if 0
-/*
- * 	Tune the memory allocator for a new MTU size.
- */
-void skb_add_mtu(int mtu)
-{
-	/* Must match allocation in alloc_skb */
-	mtu = SKB_DATA_ALIGN(mtu) + sizeof(struct skb_shared_info);
-
-	kmem_add_cache_size(mtu);
-}
-#endif
-
 static inline void skb_split_inside_header(struct sk_buff *skb,
 					   struct sk_buff* skb1,
 					   const u32 len, const int pos)
-- 
1.5.0.3

