From: Andreas Gruenbacher <agruenba@redhat.com>
Subject: [PATCH] rhashtable: Add
	rhashtable_lookup_get_insert_fast
Date: Sat, 18 Mar 2017 00:36:15 +0100
Message-ID: <1489793775-25152-1-git-send-email-agruenba@redhat.com>
Cc: netdev@vger.kernel.org, cluster-devel@redhat.com,
	Thomas Graf <tgraf@suug.ch>, "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: linux-kernel@vger.kernel.org
Return-path: <cluster-devel-bounces@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/options/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/cluster-devel>
List-Post: <mailto:cluster-devel@redhat.com>
List-Help: <mailto:cluster-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=subscribe>
Sender: cluster-devel-bounces@redhat.com
Errors-To: cluster-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org

Add rhashtable_lookup_get_insert_fast for fixed keys, similar to
rhashtable_lookup_get_insert_key for explicit keys.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
---
 include/linux/rhashtable.h | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 092292b..e507290 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -916,6 +916,28 @@ static inline int rhashtable_lookup_insert_fast(
 }
 
 /**
+ * rhashtable_lookup_get_insert_fast - lookup and insert object into hash table
+ * @ht:		hash table
+ * @obj:	pointer to hash head inside object
+ * @params:	hash table parameters
+ *
+ * Just like rhashtable_lookup_insert_fast(), but this function returns the
+ * object if it exists, NULL if it did not and the insertion was successful,
+ * and an ERR_PTR otherwise.
+ */
+static inline void *rhashtable_lookup_get_insert_fast(
+	struct rhashtable *ht, struct rhash_head *obj,
+	const struct rhashtable_params params)
+{
+	const char *key = rht_obj(ht, obj);
+
+	BUG_ON(ht->p.obj_hashfn);
+
+	return __rhashtable_insert_fast(ht, key + ht->p.key_offset, obj, params,
+					false);
+}
+
+/**
  * rhashtable_lookup_insert_key - search and insert object to hash table
  *				  with explicit key
  * @ht:		hash table
-- 
2.7.4
