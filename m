From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next v2] rhashtable: Simplify iterator code
Date: Tue,  5 May 2015 02:22:53 +0200
Message-ID: <40f6c87a0abb31ca17cb6299660ce3acd38da33c.1430785277.git.tgraf@suug.ch>
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:57875 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbbEEAW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 20:22:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove useless obj variable and goto logic.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
---
v2: simple repost a standalone patch

 lib/rhashtable.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index b28df40..4936fc4 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -579,7 +579,6 @@ void *rhashtable_walk_next(struct rhashtable_iter *iter)
 	struct bucket_table *tbl = iter->walker->tbl;
 	struct rhashtable *ht = iter->ht;
 	struct rhash_head *p = iter->p;
-	void *obj = NULL;
 
 	if (p) {
 		p = rht_dereference_bucket_rcu(p->next, tbl, iter->slot);
@@ -599,8 +598,7 @@ next:
 		if (!rht_is_a_nulls(p)) {
 			iter->skip++;
 			iter->p = p;
-			obj = rht_obj(ht, p);
-			goto out;
+			return rht_obj(ht, p);
 		}
 
 		iter->skip = 0;
@@ -618,9 +616,7 @@ next:
 
 	iter->p = NULL;
 
-out:
-
-	return obj;
+	return NULL;
 }
 EXPORT_SYMBOL_GPL(rhashtable_walk_next);
 
-- 
2.3.5
