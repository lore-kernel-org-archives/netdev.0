From: Sunghan Suh <sunghan.suh@samsung.com>
Subject: [PATCH] net: access page->private by using page_private
Date: Fri, 12 Jul 2013 16:17:23 +0900
Message-ID: <1373613443-17444-1-git-send-email-sunghan.suh@samsung.com>
Cc: Sunghan Suh <sunghan.suh@samsung.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:28125 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757203Ab3GLHRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 03:17:43 -0400
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MPT00CJ3AXH4ZN0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Fri, 12 Jul 2013 16:17:41 +0900 (KST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sunghan Suh <sunghan.suh@samsung.com>
---
 net/core/skbuff.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 77971a3..286607b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -823,7 +823,7 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 		page = alloc_page(gfp_mask);
 		if (!page) {
 			while (head) {
-				struct page *next = (struct page *)head->private;
+				struct page *next = (struct page *)page_private(head);
 				put_page(head);
 				head = next;
 			}
@@ -833,7 +833,7 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 		memcpy(page_address(page),
 		       vaddr + f->page_offset, skb_frag_size(f));
 		kunmap_atomic(vaddr);
-		page->private = (unsigned long)head;
+		set_page_private(page, (unsigned long)head);
 		head = page;
 	}
 
@@ -847,7 +847,7 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 	for (i = num_frags - 1; i >= 0; i--) {
 		__skb_fill_page_desc(skb, i, head, 0,
 				     skb_shinfo(skb)->frags[i].size);
-		head = (struct page *)head->private;
+		head = (struct page *)page_private(head);
 	}
 
 	skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
-- 
1.8.1.2
