From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/5] netfilter: nf_conntrack: silence warning on falling back to vmalloc()
Date: Mon, 10 Aug 2015 19:58:35 +0200
Message-ID: <1439229519-7640-2-git-send-email-pablo@netfilter.org>
References: <1439229519-7640-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35698 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932295AbbHJRyR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Aug 2015 13:54:17 -0400
In-Reply-To: <1439229519-7640-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 88eab472ec21 ("netfilter: conntrack: adjust nf_conntrack_buckets default
value"), the hashtable can easily hit this warning. We got reports from users
that are getting this message in a quite spamming fashion, so better silence
this.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Florian Westphal <fw@strlen.de>
---
 net/netfilter/nf_conntrack_core.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 651039a..f168099 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1544,10 +1544,8 @@ void *nf_ct_alloc_hashtable(unsigned int *sizep, int nulls)
 	sz = nr_slots * sizeof(struct hlist_nulls_head);
 	hash = (void *)__get_free_pages(GFP_KERNEL | __GFP_NOWARN | __GFP_ZERO,
 					get_order(sz));
-	if (!hash) {
-		printk(KERN_WARNING "nf_conntrack: falling back to vmalloc.\n");
+	if (!hash)
 		hash = vzalloc(sz);
-	}
 
 	if (hash && nulls)
 		for (i = 0; i < nr_slots; i++)
-- 
1.7.10.4
