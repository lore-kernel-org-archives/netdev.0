From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH] skbuff: Move definition of NETDEV_FRAG_PAGE_MAX_SIZE
Date: Fri, 08 Feb 2013 12:17:15 -0800
Message-ID: <20130208201710.27890.52546.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:57880 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964780Ab3BHUTL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2013 15:19:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to address the fact that some devices cannot support the full 32K
frag size we need to have the value accessible somewhere so that we can use it
to do comparisons against what the device can support.  As such I am moving
the values out of skbuff.c and into skbuff.h.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/linux/skbuff.h |    4 ++++
 net/core/skbuff.c      |    4 ----
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0259b71..d7573c3 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1832,6 +1832,10 @@ static inline void __skb_queue_purge(struct sk_buff_head *list)
 		kfree_skb(skb);
 }
 
+#define NETDEV_FRAG_PAGE_MAX_ORDER get_order(32768)
+#define NETDEV_FRAG_PAGE_MAX_SIZE  (PAGE_SIZE << NETDEV_FRAG_PAGE_MAX_ORDER)
+#define NETDEV_PAGECNT_MAX_BIAS	   NETDEV_FRAG_PAGE_MAX_SIZE
+
 extern void *netdev_alloc_frag(unsigned int fragsz);
 
 extern struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index bddc1dd..6e4a1e1 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -351,10 +351,6 @@ struct netdev_alloc_cache {
 };
 static DEFINE_PER_CPU(struct netdev_alloc_cache, netdev_alloc_cache);
 
-#define NETDEV_FRAG_PAGE_MAX_ORDER get_order(32768)
-#define NETDEV_FRAG_PAGE_MAX_SIZE  (PAGE_SIZE << NETDEV_FRAG_PAGE_MAX_ORDER)
-#define NETDEV_PAGECNT_MAX_BIAS	   NETDEV_FRAG_PAGE_MAX_SIZE
-
 static void *__netdev_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
 {
 	struct netdev_alloc_cache *nc;
