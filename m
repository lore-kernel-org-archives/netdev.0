From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Rename fib_hash_* locals in fib_semantics.c
Date: Tue, 01 Feb 2011 15:38:09 -0800 (PST)
Message-ID: <20110201.153809.28806748.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52914
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751942Ab1BAXhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 18:37:34 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 0A4B924C087
	for <netdev@vger.kernel.org>; Tue,  1 Feb 2011 15:38:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


To avoid confusion with the recently deleted fib_hash.c
code, use "fib_info_hash_*" instead of plain "fib_hash_*".

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/fib_semantics.c |   40 ++++++++++++++++++++--------------------
 1 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index b15857d..146bd82 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -49,7 +49,7 @@
 static DEFINE_SPINLOCK(fib_info_lock);
 static struct hlist_head *fib_info_hash;
 static struct hlist_head *fib_info_laddrhash;
-static unsigned int fib_hash_size;
+static unsigned int fib_info_hash_size;
 static unsigned int fib_info_cnt;
 
 #define DEVINDEX_HASHBITS 8
@@ -223,7 +223,7 @@ static inline unsigned int fib_devindex_hashfn(unsigned int val)
 
 static inline unsigned int fib_info_hashfn(const struct fib_info *fi)
 {
-	unsigned int mask = (fib_hash_size - 1);
+	unsigned int mask = (fib_info_hash_size - 1);
 	unsigned int val = fi->fib_nhs;
 
 	val ^= fi->fib_protocol;
@@ -615,14 +615,14 @@ out:
 
 static inline unsigned int fib_laddr_hashfn(__be32 val)
 {
-	unsigned int mask = (fib_hash_size - 1);
+	unsigned int mask = (fib_info_hash_size - 1);
 
 	return ((__force u32)val ^
 		((__force u32)val >> 7) ^
 		((__force u32)val >> 14)) & mask;
 }
 
-static struct hlist_head *fib_hash_alloc(int bytes)
+static struct hlist_head *fib_info_hash_alloc(int bytes)
 {
 	if (bytes <= PAGE_SIZE)
 		return kzalloc(bytes, GFP_KERNEL);
@@ -632,7 +632,7 @@ static struct hlist_head *fib_hash_alloc(int bytes)
 					 get_order(bytes));
 }
 
-static void fib_hash_free(struct hlist_head *hash, int bytes)
+static void fib_info_hash_free(struct hlist_head *hash, int bytes)
 {
 	if (!hash)
 		return;
@@ -643,18 +643,18 @@ static void fib_hash_free(struct hlist_head *hash, int bytes)
 		free_pages((unsigned long) hash, get_order(bytes));
 }
 
-static void fib_hash_move(struct hlist_head *new_info_hash,
-			  struct hlist_head *new_laddrhash,
-			  unsigned int new_size)
+static void fib_info_hash_move(struct hlist_head *new_info_hash,
+			       struct hlist_head *new_laddrhash,
+			       unsigned int new_size)
 {
 	struct hlist_head *old_info_hash, *old_laddrhash;
-	unsigned int old_size = fib_hash_size;
+	unsigned int old_size = fib_info_hash_size;
 	unsigned int i, bytes;
 
 	spin_lock_bh(&fib_info_lock);
 	old_info_hash = fib_info_hash;
 	old_laddrhash = fib_info_laddrhash;
-	fib_hash_size = new_size;
+	fib_info_hash_size = new_size;
 
 	for (i = 0; i < old_size; i++) {
 		struct hlist_head *head = &fib_info_hash[i];
@@ -695,8 +695,8 @@ static void fib_hash_move(struct hlist_head *new_info_hash,
 	spin_unlock_bh(&fib_info_lock);
 
 	bytes = old_size * sizeof(struct hlist_head *);
-	fib_hash_free(old_info_hash, bytes);
-	fib_hash_free(old_laddrhash, bytes);
+	fib_info_hash_free(old_info_hash, bytes);
+	fib_info_hash_free(old_laddrhash, bytes);
 }
 
 struct fib_info *fib_create_info(struct fib_config *cfg)
@@ -720,8 +720,8 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 #endif
 
 	err = -ENOBUFS;
-	if (fib_info_cnt >= fib_hash_size) {
-		unsigned int new_size = fib_hash_size << 1;
+	if (fib_info_cnt >= fib_info_hash_size) {
+		unsigned int new_size = fib_info_hash_size << 1;
 		struct hlist_head *new_info_hash;
 		struct hlist_head *new_laddrhash;
 		unsigned int bytes;
@@ -729,15 +729,15 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 		if (!new_size)
 			new_size = 1;
 		bytes = new_size * sizeof(struct hlist_head *);
-		new_info_hash = fib_hash_alloc(bytes);
-		new_laddrhash = fib_hash_alloc(bytes);
+		new_info_hash = fib_info_hash_alloc(bytes);
+		new_laddrhash = fib_info_hash_alloc(bytes);
 		if (!new_info_hash || !new_laddrhash) {
-			fib_hash_free(new_info_hash, bytes);
-			fib_hash_free(new_laddrhash, bytes);
+			fib_info_hash_free(new_info_hash, bytes);
+			fib_info_hash_free(new_laddrhash, bytes);
 		} else
-			fib_hash_move(new_info_hash, new_laddrhash, new_size);
+			fib_info_hash_move(new_info_hash, new_laddrhash, new_size);
 
-		if (!fib_hash_size)
+		if (!fib_info_hash_size)
 			goto failure;
 	}
 
-- 
1.7.4

