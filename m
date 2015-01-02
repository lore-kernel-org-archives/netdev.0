From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/9] rhashtable: Use rht_obj() instead of manual offset calculation
Date: Fri,  2 Jan 2015 23:00:15 +0100
Message-ID: <e0551897609b19939d03fe607507bc37e7551699.1420230585.git.tgraf@suug.ch>
References: <cover.1420230585.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au, paulmck@linux.vnet.ibm.com,
	edumazet@google.com, john.r.fastabend@intel.com,
	josh@joshtriplett.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1420230585.git.tgraf@suug.ch>
In-Reply-To: <cover.1420230585.git.tgraf@suug.ch>
References: <cover.1420230585.git.tgraf@suug.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
