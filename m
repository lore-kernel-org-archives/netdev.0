From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 1/2] rhashtable: Simplify iterator code
Date: Thu, 30 Apr 2015 22:46:44 +0000
Message-ID: <1430434005-6143-2-git-send-email-tgraf@suug.ch>
References: <1430434005-6143-1-git-send-email-tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:35604 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522AbbD3WrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 18:47:03 -0400
Received: by pdbqd1 with SMTP id qd1so74461739pdb.2
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 15:47:03 -0700 (PDT)
In-Reply-To: <1430434005-6143-1-git-send-email-tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove useless obj variable and goto logic.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
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
1.9.3
