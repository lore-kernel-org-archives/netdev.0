From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v3 5/5] net: Remove __skb_alloc_page and
 __skb_alloc_pages
Date: Tue, 11 Nov 2014 09:27:05 -0800
Message-ID: <20141111172705.16460.42660.stgit@ahduyck-vm-fedora20>
References: <20141111172523.16460.16845.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: leedom@chelsio.com, hariprasad@chelsio.com,
	donald.c.skidmore@intel.com, oliver@neukum.org, balbi@ti.com,
	matthew.vick@intel.com, mgorman@suse.de, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40405 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751086AbaKKR1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2014 12:27:19 -0500
In-Reply-To: <20141111172523.16460.16845.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the two functions which are now dead code.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 include/linux/skbuff.h |   43 -------------------------------------------
 1 file changed, 43 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2e5221f..73c370e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2233,49 +2233,6 @@ static inline struct page *dev_alloc_page(void)
 }
 
 /**
- *	__skb_alloc_pages - allocate pages for ps-rx on a skb and preserve pfmemalloc data
- *	@gfp_mask: alloc_pages_node mask. Set __GFP_NOMEMALLOC if not for network packet RX
- *	@skb: skb to set pfmemalloc on if __GFP_MEMALLOC is used
- *	@order: size of the allocation
- *
- * 	Allocate a new page.
- *
- * 	%NULL is returned if there is no free memory.
-*/
-static inline struct page *__skb_alloc_pages(gfp_t gfp_mask,
-					      struct sk_buff *skb,
-					      unsigned int order)
-{
-	struct page *page;
-
-	gfp_mask |= __GFP_COLD;
-
-	if (!(gfp_mask & __GFP_NOMEMALLOC))
-		gfp_mask |= __GFP_MEMALLOC;
-
-	page = alloc_pages_node(NUMA_NO_NODE, gfp_mask, order);
-	if (skb && page && page->pfmemalloc)
-		skb->pfmemalloc = true;
-
-	return page;
-}
-
-/**
- *	__skb_alloc_page - allocate a page for ps-rx for a given skb and preserve pfmemalloc data
- *	@gfp_mask: alloc_pages_node mask. Set __GFP_NOMEMALLOC if not for network packet RX
- *	@skb: skb to set pfmemalloc on if __GFP_MEMALLOC is used
- *
- * 	Allocate a new page.
- *
- * 	%NULL is returned if there is no free memory.
- */
-static inline struct page *__skb_alloc_page(gfp_t gfp_mask,
-					     struct sk_buff *skb)
-{
-	return __skb_alloc_pages(gfp_mask, skb, 0);
-}
-
-/**
  *	skb_propagate_pfmemalloc - Propagate pfmemalloc if skb is allocated after RX page
  *	@page: The page that was allocated from skb_alloc_page
  *	@skb: The skb that may need pfmemalloc set
