From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/6] rhashtable: Use SINGLE_DEPTH_NESTING
Date: Fri, 13 Mar 2015 20:57:11 +1100
Message-ID: <E1YWML9-0000BP-B0@gondolin.me.apana.org.au>
References: <20150313095607.GA598@gondor.apana.org.au>
To: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:55906 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113AbbCMJ5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 05:57:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We only nest one level deep there is no need to roll our own
subclasses.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 lib/rhashtable.c |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index f7c7607..5d06cc2 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -33,11 +33,6 @@
 /* Base bits plus 1 bit for nulls marker */
 #define HASH_RESERVED_SPACE	(RHT_BASE_BITS + 1)
 
-enum {
-	RHT_LOCK_NORMAL,
-	RHT_LOCK_NESTED,
-};
-
 /* The bucket lock is selected based on the hash and protects mutations
  * on a group of hash buckets.
  *
@@ -231,7 +226,7 @@ static int rhashtable_rehash_one(struct rhashtable *ht, unsigned old_hash)
 
 	new_bucket_lock = bucket_lock(new_tbl, new_hash);
 
-	spin_lock_nested(new_bucket_lock, RHT_LOCK_NESTED);
+	spin_lock_nested(new_bucket_lock, SINGLE_DEPTH_NESTING);
 	head = rht_dereference_bucket(new_tbl->buckets[new_hash],
 				      new_tbl, new_hash);
 
@@ -405,7 +400,7 @@ static bool __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 	tbl = rht_dereference_rcu(ht->future_tbl, ht);
 	if (tbl != old_tbl) {
 		hash = head_hashfn(ht, tbl, obj);
-		spin_lock_nested(bucket_lock(tbl, hash), RHT_LOCK_NESTED);
+		spin_lock_nested(bucket_lock(tbl, hash), SINGLE_DEPTH_NESTING);
 	}
 
 	if (compare &&
