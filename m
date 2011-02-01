From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Update some fib_hash centric interface names.
Date: Tue, 01 Feb 2011 15:38:08 -0800 (PST)
Message-ID: <20110201.153808.246526487.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52911
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751503Ab1BAXhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 18:37:33 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B2A1624C087
	for <netdev@vger.kernel.org>; Tue,  1 Feb 2011 15:38:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


fib_hash_init() --> fib_trie_init()
fib_hash_table() --> fib_trie_table()

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h    |    6 +++---
 net/ipv4/fib_frontend.c |    8 ++++----
 net/ipv4/fib_trie.c     |    5 ++---
 3 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 819d61c..08b46b8 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -228,9 +228,9 @@ extern int fib_sync_up(struct net_device *dev);
 extern __be32  __fib_res_prefsrc(struct fib_result *res);
 extern void fib_select_multipath(const struct flowi *flp, struct fib_result *res);
 
-/* Exported by fib_{hash|trie}.c */
-extern void fib_hash_init(void);
-extern struct fib_table *fib_hash_table(u32 id);
+/* Exported by fib_trie.c */
+extern void fib_trie_init(void);
+extern struct fib_table *fib_trie_table(u32 id);
 
 static inline void fib_combine_itag(u32 *itag, struct fib_result *res)
 {
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 930768b..2a49c06 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -51,11 +51,11 @@ static int __net_init fib4_rules_init(struct net *net)
 {
 	struct fib_table *local_table, *main_table;
 
-	local_table = fib_hash_table(RT_TABLE_LOCAL);
+	local_table = fib_trie_table(RT_TABLE_LOCAL);
 	if (local_table == NULL)
 		return -ENOMEM;
 
-	main_table  = fib_hash_table(RT_TABLE_MAIN);
+	main_table  = fib_trie_table(RT_TABLE_MAIN);
 	if (main_table == NULL)
 		goto fail;
 
@@ -82,7 +82,7 @@ struct fib_table *fib_new_table(struct net *net, u32 id)
 	if (tb)
 		return tb;
 
-	tb = fib_hash_table(id);
+	tb = fib_trie_table(id);
 	if (!tb)
 		return NULL;
 	h = id & (FIB_TABLE_HASHSZ - 1);
@@ -1086,5 +1086,5 @@ void __init ip_fib_init(void)
 	register_netdevice_notifier(&fib_netdev_notifier);
 	register_inetaddr_notifier(&fib_inetaddr_notifier);
 
-	fib_hash_init();
+	fib_trie_init();
 }
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 16d589c..73cb984 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1916,7 +1916,7 @@ int fib_table_dump(struct fib_table *tb, struct sk_buff *skb,
 	return skb->len;
 }
 
-void __init fib_hash_init(void)
+void __init fib_trie_init(void)
 {
 	fn_alias_kmem = kmem_cache_create("ip_fib_alias",
 					  sizeof(struct fib_alias),
@@ -1929,8 +1929,7 @@ void __init fib_hash_init(void)
 }
 
 
-/* Fix more generic FIB names for init later */
-struct fib_table *fib_hash_table(u32 id)
+struct fib_table *fib_trie_table(u32 id)
 {
 	struct fib_table *tb;
 	struct trie *t;
-- 
1.7.4

