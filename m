From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/9] rhashtable: Use rht_obj() instead of manual offset calculation
Date: Mon, 15 Dec 2014 13:51:04 +0100
Message-ID: <61a4301e8eb49720d976d8a1e8b51e5b80b70e17.1418647641.git.tgraf@suug.ch>
References: <cover.1418647641.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, kernel@vger.kernel.org,
	herbert@gondor.apana.org.au, paulmck@linux.vnet.ibm.com,
	edumazet@google.com, john.r.fastabend@intel.com,
	josh@joshtriplett.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38874 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbaLOMvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 07:51:18 -0500
In-Reply-To: <cover.1418647641.git.tgraf@suug.ch>
In-Reply-To: <cover.1418647641.git.tgraf@suug.ch>
References: <cover.1418647641.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 1ee0eb6..b658245 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -427,7 +427,7 @@ void *rhashtable_lookup(const struct rhashtable *ht, const void *key)
 		if (memcmp(rht_obj(ht, he) + ht->p.key_offset, key,
 			   ht->p.key_len))
 			continue;
-		return (void *) he - ht->p.head_offset;
+		return rht_obj(ht, he);
 	}
 
 	return NULL;
@@ -460,7 +460,7 @@ void *rhashtable_lookup_compare(const struct rhashtable *ht, const void *key,
 	rht_for_each_rcu(he, tbl->buckets[hash], ht) {
 		if (!compare(rht_obj(ht, he), arg))
 			continue;
-		return (void *) he - ht->p.head_offset;
+		return rht_obj(ht, he);
 	}
 
 	return NULL;
-- 
1.9.3
