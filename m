From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/4] rhashtable: Remove key length argument to key_hashfn
Date: Thu, 12 Mar 2015 12:30:54 +1100
Message-ID: <E1YVrxe-0003My-W5@gondolin.me.apana.org.au>
References: <20150312012944.GA12857@gondor.apana.org.au>
To: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:43079 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043AbbCLBa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 21:30:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

key_hashfn has only one caller and it doesn't really need to supply
the key length as an extra parameter.

Signed-off-by: Herbert Xu <herbert.xu@redhat.com>
---

 lib/rhashtable.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 0bda8dd..91b52da 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -81,9 +81,10 @@ static u32 obj_raw_hashfn(struct rhashtable *ht,
 }
 
 static u32 key_hashfn(struct rhashtable *ht, const struct bucket_table *tbl,
-		      const void *key, u32 len)
+		      const void *key)
 {
-	return rht_bucket_index(tbl, ht->p.hashfn(key, len, tbl->hash_rnd) >>
+	return rht_bucket_index(tbl, ht->p.hashfn(key, ht->p.key_len,
+						  tbl->hash_rnd) >>
 				     HASH_RESERVED_SPACE);
 }
 
@@ -619,7 +620,7 @@ void *rhashtable_lookup_compare(struct rhashtable *ht, const void *key,
 	rcu_read_lock();
 
 	tbl = rht_dereference_rcu(ht->tbl, ht);
-	hash = key_hashfn(ht, tbl, key, ht->p.key_len);
+	hash = key_hashfn(ht, tbl, key);
 restart:
 	rht_for_each_rcu(he, tbl, hash) {
 		if (!compare(rht_obj(ht, he), arg))
