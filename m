From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 3/3] deprecate dev_alloc_skb
Date: Wed, 26 Jul 2006 13:31:57 +0200
Message-ID: <20060726113157.GC403@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:38819 "EHLO mail.lst.de")
	by vger.kernel.org with ESMTP id S1751472AbWGZLcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 07:32:12 -0400
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/include/linux/skbuff.h
===================================================================
--- linux-2.6.orig/include/linux/skbuff.h	2006-07-26 12:06:12.000000000 +0200
+++ linux-2.6/include/linux/skbuff.h	2006-07-26 12:08:49.000000000 +0200
@@ -1077,9 +1077,13 @@
  *	built in space. The built in space is used for optimisations.
  *
  *	%NULL is returned in there is no free memory.
+ *
+ * 	NOTE: Do not use this function.  Network driver want to use
+ * 	netdev_alloc_skb for the receive path, everyone else wants plain
+ * 	alloc_skb.
  */
-static inline struct sk_buff *__dev_alloc_skb(unsigned int length,
-					      gfp_t gfp_mask)
+static inline struct sk_buff * __deprecated
+__dev_alloc_skb(unsigned int length, gfp_t gfp_mask)
 {
 	struct sk_buff *skb = alloc_skb(length + NET_SKB_PAD, gfp_mask);
 	if (likely(skb))
@@ -1098,8 +1102,13 @@
  *
  *	%NULL is returned in there is no free memory. Although this function
  *	allocates memory it can be called from an interrupt.
+ *
+ * 	NOTE: Do not use this function.  Network driver want to use
+ * 	netdev_alloc_skb for the receive path, everyone else wants plain
+ * 	alloc_skb.
  */
-static inline struct sk_buff *dev_alloc_skb(unsigned int length)
+static inline struct sk_buff * __deprecated
+dev_alloc_skb(unsigned int length)
 {
 	return __dev_alloc_skb(length, GFP_ATOMIC);
 }
