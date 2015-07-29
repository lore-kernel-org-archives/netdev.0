From: WingMan Kwok <w-kwok2@ti.com>
Subject: [PATCH 1/2] net: Export __netdev_alloc_frag() to allow gfp_mask flags
Date: Wed, 29 Jul 2015 11:10:52 -0400
Message-ID: <1438182653-2136-1-git-send-email-w-kwok2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: WingMan Kwok <w-kwok2@ti.com>, "Reece R. Pollack" <x0183204@ti.com>
To: <davem@davemloft.net>, <m-karicheri2@ti.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes the function __netdev_alloc_frag() non-static and
exports it so that drivers that need to specify additional flags,
such as __GFP_DMA, can use it. The currently exported function,
netdev_alloc_frag() doesn't allow passing in gfp_mask flags.

Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
Signed-off-by: Reece R. Pollack <x0183204@ti.com>
---
 include/linux/skbuff.h |    1 +
 net/core/skbuff.c      |    3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d6cdd6e..596deb3 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2139,6 +2139,7 @@ static inline void __skb_queue_purge(struct sk_buff_head *list)
 		kfree_skb(skb);
 }
 
+void *__netdev_alloc_frag(unsigned int fragsz, gfp_t gfp_mask);
 void *netdev_alloc_frag(unsigned int fragsz);
 
 struct sk_buff *__netdev_alloc_skb(struct net_device *dev, unsigned int length,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index b6a19ca..6f3451f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -350,7 +350,7 @@ EXPORT_SYMBOL(build_skb);
 static DEFINE_PER_CPU(struct page_frag_cache, netdev_alloc_cache);
 static DEFINE_PER_CPU(struct page_frag_cache, napi_alloc_cache);
 
-static void *__netdev_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
+void *__netdev_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
 {
 	struct page_frag_cache *nc;
 	unsigned long flags;
@@ -362,6 +362,7 @@ static void *__netdev_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
 	local_irq_restore(flags);
 	return data;
 }
+EXPORT_SYMBOL(__netdev_alloc_frag);
 
 /**
  * netdev_alloc_frag - allocate a page fragment
-- 
1.7.9.5
