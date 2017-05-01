From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2 net-next] rhashtable: compact struct rhashtable_params
Date: Mon,  1 May 2017 22:18:01 +0200
Message-ID: <20170501201801.17344-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43966 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750802AbdEAUSL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 16:18:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By using smaller datatypes this (rather large) struct shrinks considerably
(80 -> 48 bytes on x86_64).

As this is embedded in other structs, this also rerduces size of several
others, e.g. cls_fl_head or nft_hash.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 changes since v1: rebase on top of net-next master

 David, if its too late, just mark this as deferred in patchwork
 and I'll resubmit when net-next reopens.

 include/linux/rhashtable.h | 18 +++++++++---------
 lib/rhashtable.c           |  2 +-
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 45f89369c4c8..7d56a7ea2b2e 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -127,23 +127,23 @@ struct rhashtable;
  * @head_offset: Offset of rhash_head in struct to be hashed
  * @max_size: Maximum size while expanding
  * @min_size: Minimum size while shrinking
- * @nulls_base: Base value to generate nulls marker
- * @automatic_shrinking: Enable automatic shrinking of tables
  * @locks_mul: Number of bucket locks to allocate per cpu (default: 128)
+ * @automatic_shrinking: Enable automatic shrinking of tables
+ * @nulls_base: Base value to generate nulls marker
  * @hashfn: Hash function (default: jhash2 if !(key_len % 4), or jhash)
  * @obj_hashfn: Function to hash object
  * @obj_cmpfn: Function to compare key with object
  */
 struct rhashtable_params {
-	size_t			nelem_hint;
-	size_t			key_len;
-	size_t			key_offset;
-	size_t			head_offset;
+	u16			nelem_hint;
+	u16			key_len;
+	u16			key_offset;
+	u16			head_offset;
 	unsigned int		max_size;
-	unsigned int		min_size;
-	u32			nulls_base;
+	u16			min_size;
 	bool			automatic_shrinking;
-	size_t			locks_mul;
+	u8			locks_mul;
+	u32			nulls_base;
 	rht_hashfn_t		hashfn;
 	rht_obj_hashfn_t	obj_hashfn;
 	rht_obj_cmpfn_t		obj_cmpfn;
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 3895486ef551..a930e436db5d 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -967,7 +967,7 @@ int rhashtable_init(struct rhashtable *ht,
 			ht->max_elems = ht->p.max_size * 2;
 	}
 
-	ht->p.min_size = max(ht->p.min_size, HASH_MIN_SIZE);
+	ht->p.min_size = max_t(u16, ht->p.min_size, HASH_MIN_SIZE);
 
 	if (params->nelem_hint)
 		size = rounded_hashtable_size(&ht->p);
-- 
2.10.2
