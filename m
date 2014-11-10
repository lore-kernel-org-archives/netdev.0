From: Alexander Duyck <alexander.h.duyck-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [net-next PATCH 5/5] net: Remove __skb_alloc_page and
 __skb_alloc_pages
Date: Mon, 10 Nov 2014 11:52:28 -0800
Message-ID: <20141110195228.16182.44996.stgit@ahduyck-vm-fedora20>
References: <20141110195104.16182.98174.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, balbi-l0cyMroinI0@public.gmane.org,
	matthew.vick-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, mgorman-l3A5Bk7waGM@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141110195104.16182.98174.stgit@ahduyck-vm-fedora20>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Remove the two functions which are now dead code.

Signed-off-by: Alexander Duyck <alexander.h.duyck-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 include/linux/skbuff.h |   43 -------------------------------------------
 1 file changed, 43 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f196628..e4acbca 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2233,49 +2233,6 @@ static inline struct page *netdev_alloc_page(void)
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
