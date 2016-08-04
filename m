From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: [PATCH] net: use non-compound pages in frag allocator
Date: Thu,  4 Aug 2016 15:47:38 +0300
Message-ID: <1470314858-32105-1-git-send-email-ilyal@mellanox.com>
Cc: Ilya Lesokhin <ilyal@mellanox.com>
To: netdev@vger.kernel.org, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57808 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933643AbcHDMrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 08:47:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code currently always references the first page in the
frag therefore there is no need to pay the extra overhead
of making the frag page compound

Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
---
 net/core/sock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 08bf97e..77432ba 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1993,7 +1993,7 @@ bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t gfp)
 	if (SKB_FRAG_PAGE_ORDER) {
 		/* Avoid direct reclaim but allow kswapd to wake */
 		pfrag->page = alloc_pages((gfp & ~__GFP_DIRECT_RECLAIM) |
-					  __GFP_COMP | __GFP_NOWARN |
+					  __GFP_NOWARN |
 					  __GFP_NORETRY,
 					  SKB_FRAG_PAGE_ORDER);
 		if (likely(pfrag->page)) {
-- 
1.8.3.1
