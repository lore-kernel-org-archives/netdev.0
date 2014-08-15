From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH] batman-adv: Fix parameter order of hlist_add_behind
Date: Fri, 15 Aug 2014 10:19:39 +0200
Message-ID: <1408090779-5020-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, Sven Eckelmann <sven@narfation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:53487 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750772AbaHOIUK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2014 04:20:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1d023284c31a4e40a94d5bbcb7dbb7a35ee0bcbc ("list: fix order of arguments for
hlist_add_after(_rcu)") was incorrectly rebased on top of
d9124268d84a836f14a6ead54ff9d8eee4c43be5 ("batman-adv: Fix out-of-order
fragmentation support"). The parameter order change of the rebased patch was
not re-applied as expected. This causes a memory leak and can cause crashes
when out-of-order packets are received. hlist_add_behind will try to access the
uninitalized list pointers of frag_entry_new to find the previous/next entry
and may modify/read random memory locations.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 net/batman-adv/fragmentation.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index 52c43f9..fc1835c 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -188,7 +188,7 @@ static bool batadv_frag_insert_packet(struct batadv_orig_node *orig_node,
 
 	/* Reached the end of the list, so insert after 'frag_entry_last'. */
 	if (likely(frag_entry_last)) {
-		hlist_add_behind(&frag_entry_last->list, &frag_entry_new->list);
+		hlist_add_behind(&frag_entry_new->list, &frag_entry_last->list);
 		chain->size += skb->len - hdr_size;
 		chain->timestamp = jiffies;
 		ret = true;
-- 
2.1.0.rc1
