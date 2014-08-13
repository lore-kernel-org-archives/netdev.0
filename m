From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/4] rhashtable: unexport and make rht_obj() static
Date: Wed, 13 Aug 2014 16:38:30 +0200
Message-ID: <112651b075268abf10461170af80ac523ccc5fe9.1407939963.git.tgraf@suug.ch>
References: <cover.1407939963.git.tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:54740 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbaHMOii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 10:38:38 -0400
Received: from 77-56-195-25.dclient.hispeed.ch ([77.56.195.25] helo=lsx.localdomain)
	by bombadil.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XHZhG-00056M-88
	for netdev@vger.kernel.org; Wed, 13 Aug 2014 14:38:38 +0000
In-Reply-To: <cover.1407939963.git.tgraf@suug.ch>
In-Reply-To: <cover.1407939963.git.tgraf@suug.ch>
References: <cover.1407939963.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to export rht_obj(), all inner to outer object translations
occur internally. It was intended to be used with rht_for_each() which
now primarily serves as the iterator for rhashtable_remove_pprev() to
effectively flush and free the full table.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/rhashtable.h | 1 -
 lib/rhashtable.c           | 8 +-------
 2 files changed, 1 insertion(+), 8 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 8c6048e..af967c4 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -117,7 +117,6 @@ void rhashtable_destroy(const struct rhashtable *ht);
 #define rht_dereference_rcu(p, ht) \
 	rcu_dereference_check(p, lockdep_rht_mutex_is_held(ht))
 
-/* Internal, use rht_obj() instead */
 #define rht_entry(ptr, type, member) container_of(ptr, type, member)
 #define rht_entry_safe(ptr, type, member) \
 ({ \
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 338dd7a..a2c7881 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -38,16 +38,10 @@ int lockdep_rht_mutex_is_held(const struct rhashtable *ht)
 EXPORT_SYMBOL_GPL(lockdep_rht_mutex_is_held);
 #endif
 
-/**
- * rht_obj - cast hash head to outer object
- * @ht:		hash table
- * @he:		hashed node
- */
-void *rht_obj(const struct rhashtable *ht, const struct rhash_head *he)
+static void *rht_obj(const struct rhashtable *ht, const struct rhash_head *he)
 {
 	return (void *) he - ht->p.head_offset;
 }
-EXPORT_SYMBOL_GPL(rht_obj);
 
 static u32 __hashfn(const struct rhashtable *ht, const void *key,
 		      u32 len, u32 hsize)
-- 
1.9.3
