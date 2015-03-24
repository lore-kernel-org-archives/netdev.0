From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/5 net-next] rhashtable: Use 'unsigned int' consistently
Date: Tue, 24 Mar 2015 14:18:17 +0100
Message-ID: <7fccde70c22b0454b956cec9c5c167eb4ffe288a.1427202823.git.tgraf@suug.ch>
References: <cover.1427202823.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:34676 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752648AbbCXNS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 09:18:28 -0400
In-Reply-To: <cover.1427202823.git.tgraf@suug.ch>
In-Reply-To: <cover.1427202823.git.tgraf@suug.ch>
References: <cover.1427202823.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/rhashtable.h | 14 +++++++-------
 lib/rhashtable.c           | 18 ++++++++++--------
 2 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 5976ab5..f89cda0 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -208,13 +208,13 @@ static inline unsigned int rht_key_hashfn(
 	struct rhashtable *ht, const struct bucket_table *tbl,
 	const void *key, const struct rhashtable_params params)
 {
-	unsigned hash;
+	unsigned int hash;
 
 	/* params must be equal to ht->p if it isn't constant. */
 	if (!__builtin_constant_p(params.key_len))
 		hash = ht->p.hashfn(key, ht->key_len, tbl->hash_rnd);
 	else if (params.key_len) {
-		unsigned key_len = params.key_len;
+		unsigned int key_len = params.key_len;
 
 		if (params.hashfn)
 			hash = params.hashfn(key, key_len, tbl->hash_rnd);
@@ -224,7 +224,7 @@ static inline unsigned int rht_key_hashfn(
 			hash = jhash2(key, key_len / sizeof(u32),
 				      tbl->hash_rnd);
 	} else {
-		unsigned key_len = ht->p.key_len;
+		unsigned int key_len = ht->p.key_len;
 
 		if (params.hashfn)
 			hash = params.hashfn(key, key_len, tbl->hash_rnd);
@@ -512,7 +512,7 @@ static inline void *rhashtable_lookup_fast(
 	};
 	const struct bucket_table *tbl;
 	struct rhash_head *he;
-	unsigned hash;
+	unsigned int hash;
 
 	rcu_read_lock();
 
@@ -550,8 +550,8 @@ static inline int __rhashtable_insert_fast(
 	struct bucket_table *tbl, *new_tbl;
 	struct rhash_head *head;
 	spinlock_t *lock;
-	unsigned elasticity;
-	unsigned hash;
+	unsigned int elasticity;
+	unsigned int hash;
 	int err;
 
 restart:
@@ -718,7 +718,7 @@ static inline int __rhashtable_remove_fast(
 	struct rhash_head __rcu **pprev;
 	struct rhash_head *he;
 	spinlock_t * lock;
-	unsigned hash;
+	unsigned int hash;
 	int err = -ENOENT;
 
 	hash = rht_head_hashfn(ht, tbl, obj, params);
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index e96ad1a..93374d7 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -153,7 +153,7 @@ static struct bucket_table *rhashtable_last_table(struct rhashtable *ht,
 	return new_tbl;
 }
 
-static int rhashtable_rehash_one(struct rhashtable *ht, unsigned old_hash)
+static int rhashtable_rehash_one(struct rhashtable *ht, unsigned int old_hash)
 {
 	struct bucket_table *old_tbl = rht_dereference(ht->tbl, ht);
 	struct bucket_table *new_tbl = rhashtable_last_table(ht,
@@ -162,7 +162,7 @@ static int rhashtable_rehash_one(struct rhashtable *ht, unsigned old_hash)
 	int err = -ENOENT;
 	struct rhash_head *head, *next, *entry;
 	spinlock_t *new_bucket_lock;
-	unsigned new_hash;
+	unsigned int new_hash;
 
 	rht_for_each(entry, old_tbl, old_hash) {
 		err = 0;
@@ -199,7 +199,8 @@ out:
 	return err;
 }
 
-static void rhashtable_rehash_chain(struct rhashtable *ht, unsigned old_hash)
+static void rhashtable_rehash_chain(struct rhashtable *ht,
+				    unsigned int old_hash)
 {
 	struct bucket_table *old_tbl = rht_dereference(ht->tbl, ht);
 	spinlock_t *old_bucket_lock;
@@ -244,7 +245,7 @@ static int rhashtable_rehash_table(struct rhashtable *ht)
 	struct bucket_table *old_tbl = rht_dereference(ht->tbl, ht);
 	struct bucket_table *new_tbl;
 	struct rhashtable_walker *walker;
-	unsigned old_hash;
+	unsigned int old_hash;
 
 	new_tbl = rht_dereference(old_tbl->future_tbl, ht);
 	if (!new_tbl)
@@ -324,11 +325,12 @@ static int rhashtable_expand(struct rhashtable *ht)
 static int rhashtable_shrink(struct rhashtable *ht)
 {
 	struct bucket_table *new_tbl, *old_tbl = rht_dereference(ht->tbl, ht);
-	unsigned size = roundup_pow_of_two(atomic_read(&ht->nelems) * 3 / 2);
+	unsigned int size;
 	int err;
 
 	ASSERT_RHT_MUTEX(ht);
 
+	size = roundup_pow_of_two(atomic_read(&ht->nelems) * 3 / 2);
 	if (size < ht->p.min_size)
 		size = ht->p.min_size;
 
@@ -379,9 +381,9 @@ unlock:
 
 static bool rhashtable_check_elasticity(struct rhashtable *ht,
 					struct bucket_table *tbl,
-					unsigned hash)
+					unsigned int hash)
 {
-	unsigned elasticity = ht->elasticity;
+	unsigned int elasticity = ht->elasticity;
 	struct rhash_head *head;
 
 	rht_for_each(head, tbl, hash)
@@ -431,7 +433,7 @@ int rhashtable_insert_slow(struct rhashtable *ht, const void *key,
 			   struct bucket_table *tbl)
 {
 	struct rhash_head *head;
-	unsigned hash;
+	unsigned int hash;
 	int err;
 
 	tbl = rhashtable_last_table(ht, tbl);
-- 
1.9.3
