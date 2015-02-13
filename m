From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] rhashtable: use rht_obj() consistently
Date: Fri, 13 Feb 2015 21:42:41 +0100
Message-ID: <1423860161-20875-1-git-send-email-johannes@sipsolutions.net>
Cc: Thomas Graf <tgraf@suug.ch>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:33165 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753337AbbBMUmu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Feb 2015 15:42:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Looking at the RHT code I found two places where this was
done manually rather than using the rht_obj() helper, use
that instead.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 lib/rhashtable.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 6c3c723e902b..a8ea16093839 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -457,7 +457,7 @@ void *rhashtable_lookup(const struct rhashtable *ht, const void *key)
 		if (memcmp(rht_obj(ht, he) + ht->p.key_offset, key,
 			   ht->p.key_len))
 			continue;
-		return (void *) he - ht->p.head_offset;
+		return rht_obj(ht, he);
 	}
 
 	return NULL;
@@ -491,7 +491,7 @@ void *rhashtable_lookup_compare(const struct rhashtable *ht, u32 hash,
 	rht_for_each_rcu(he, tbl->buckets[hash], ht) {
 		if (!compare(rht_obj(ht, he), arg))
 			continue;
-		return (void *) he - ht->p.head_offset;
+		return rht_obj(ht, he);
 	}
 
 	return NULL;
-- 
2.1.4
