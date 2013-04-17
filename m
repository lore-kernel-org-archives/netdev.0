From: Nathaniel Yazdani <n1ght.4nd.d4y@gmail.com>
Subject: [PATCH] IPv6: simplify & condense a few declarations & statements
Date: Wed, 17 Apr 2013 10:20:22 -0700
Message-ID: <1366219222.3504.8.camel@lizardlounge>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nathaniel Yazdani <n1ght.4nd.d4y@gmail.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch combines several statements/declarations into more concise forms and removes a 
couple of unnecessary local variables within a few functions, mostly inline.

Signed-off-by: Nathaniel Yazdani <n1ght.4nd.d4y@gmail.com>
---
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 192dd1a..3f7dcdb 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -111,10 +111,7 @@ static inline void fib6_walker_unlink(struct fib6_walker_t *w)
 }
 static __inline__ u32 fib6_new_sernum(void)
 {
-	u32 n = ++rt_sernum;
-	if ((__s32)n <= 0)
-		rt_sernum = n = 1;
-	return n;
+	return (__s32)++rt_sernum <= 0 ? rt_sernum = 1 : rt_sernum;
 }
 
 /*
@@ -149,11 +146,7 @@ static __inline__ __be32 addr_bit_set(const void *token, int fn_bit)
 
 static __inline__ struct fib6_node * node_alloc(void)
 {
-	struct fib6_node *fn;
-
-	fn = kmem_cache_zalloc(fib6_node_kmem, GFP_ATOMIC);
-
-	return fn;
+	return kmem_cache_zalloc(fib6_node_kmem, GFP_ATOMIC);
 }
 
 static __inline__ void node_free(struct fib6_node * fn)
@@ -190,9 +183,8 @@ static void fib6_link_table(struct net *net, struct fib6_table *tb)
 
 static struct fib6_table *fib6_alloc_table(struct net *net, u32 id)
 {
-	struct fib6_table *table;
+	struct fib6_table *table = kzalloc(sizeof(struct fib6_table), GFP_ATOMIC);
 
-	table = kzalloc(sizeof(*table), GFP_ATOMIC);
 	if (table) {
 		table->tb6_id = id;
 		table->tb6_root.leaf = net->ipv6.ip6_null_entry;
