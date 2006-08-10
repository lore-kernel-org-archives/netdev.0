From: Patrick McHardy <kaber@trash.net>
Subject: [NET 01/06]: Use u32 for routing table IDs
Date: Thu, 10 Aug 2006 21:29:59 +0200 (MEST)
Message-ID: <20060810192959.14867.66066.sendpatchset@localhost.localdomain>
References: <20060810192957.14867.71965.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39642 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751240AbWHJTaA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 15:30:00 -0400
To: davem@davemloft.net
In-Reply-To: <20060810192957.14867.71965.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET]: Use u32 for routing table IDs

Use u32 for routing table IDs in net/ipv4 and net/decnet in preparation of
support for a larger number of routing tables. net/ipv6 already uses u32
everywhere and needs no further changes. No functional changes are made by
this patch.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 29a0f4a779543907ddf8fbca55b6f1d0e0017f64
tree c559ca79c2d6ab28ceb4a4c1d5ecd5ea81264f0d
parent 1b471cd32acdff18786bc06542c686d52decbc5a
author Patrick McHardy <kaber@trash.net> Thu, 10 Aug 2006 20:45:22 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 10 Aug 2006 20:45:22 +0200

 include/net/dn_fib.h     |    4 ++--
 include/net/ip_fib.h     |   14 +++++++-------
 net/decnet/dn_fib.c      |    6 +++---
 net/decnet/dn_table.c    |   10 +++++-----
 net/ipv4/fib_frontend.c  |    8 ++++----
 net/ipv4/fib_hash.c      |    4 ++--
 net/ipv4/fib_lookup.h    |    4 ++--
 net/ipv4/fib_rules.c     |    2 +-
 net/ipv4/fib_semantics.c |    4 ++--
 net/ipv4/fib_trie.c      |    6 +++---
 10 files changed, 31 insertions(+), 31 deletions(-)

diff --git a/include/net/dn_fib.h b/include/net/dn_fib.h
index 32bc8ce..cd9c378 100644
--- a/include/net/dn_fib.h
+++ b/include/net/dn_fib.h
@@ -94,7 +94,7 @@ #define DN_FIB_INFO(f) ((f)->fn_info)
 
 
 struct dn_fib_table {
-	int n;
+	u32 n;
 
 	int (*insert)(struct dn_fib_table *t, struct rtmsg *r, 
 			struct dn_kern_rta *rta, struct nlmsghdr *n, 
@@ -137,7 +137,7 @@ extern int dn_fib_sync_up(struct net_dev
 /*
  * dn_tables.c
  */
-extern struct dn_fib_table *dn_fib_get_table(int n, int creat);
+extern struct dn_fib_table *dn_fib_get_table(u32 n, int creat);
 extern struct dn_fib_table *dn_fib_empty_table(void);
 extern void dn_fib_table_init(void);
 extern void dn_fib_table_cleanup(void);
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index adf7358..0dcbf16 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -150,7 +150,7 @@ #define FIB_RES_NETMASK(res)	        (0)
 #endif /* CONFIG_IP_ROUTE_MULTIPATH_WRANDOM */
 
 struct fib_table {
-	unsigned char	tb_id;
+	u32		tb_id;
 	unsigned	tb_stamp;
 	int		(*tb_lookup)(struct fib_table *tb, const struct flowi *flp, struct fib_result *res);
 	int		(*tb_insert)(struct fib_table *table, struct rtmsg *r,
@@ -173,14 +173,14 @@ #ifndef CONFIG_IP_MULTIPLE_TABLES
 extern struct fib_table *ip_fib_local_table;
 extern struct fib_table *ip_fib_main_table;
 
-static inline struct fib_table *fib_get_table(int id)
+static inline struct fib_table *fib_get_table(u32 id)
 {
 	if (id != RT_TABLE_LOCAL)
 		return ip_fib_main_table;
 	return ip_fib_local_table;
 }
 
-static inline struct fib_table *fib_new_table(int id)
+static inline struct fib_table *fib_new_table(u32 id)
 {
 	return fib_get_table(id);
 }
@@ -205,9 +205,9 @@ #define ip_fib_main_table (fib_tables[RT
 
 extern struct fib_table * fib_tables[RT_TABLE_MAX+1];
 extern int fib_lookup(struct flowi *flp, struct fib_result *res);
-extern struct fib_table *__fib_new_table(int id);
+extern struct fib_table *__fib_new_table(u32 id);
 
-static inline struct fib_table *fib_get_table(int id)
+static inline struct fib_table *fib_get_table(u32 id)
 {
 	if (id == 0)
 		id = RT_TABLE_MAIN;
@@ -215,7 +215,7 @@ static inline struct fib_table *fib_get_
 	return fib_tables[id];
 }
 
-static inline struct fib_table *fib_new_table(int id)
+static inline struct fib_table *fib_new_table(u32 id)
 {
 	if (id == 0)
 		id = RT_TABLE_MAIN;
@@ -248,7 +248,7 @@ extern int fib_convert_rtentry(int cmd, 
 extern u32  __fib_res_prefsrc(struct fib_result *res);
 
 /* Exported by fib_hash.c */
-extern struct fib_table *fib_hash_init(int id);
+extern struct fib_table *fib_hash_init(u32 id);
 
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 extern int fib4_rules_dump(struct sk_buff *skb, struct netlink_callback *cb);
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index ed5fb5c..7b3bf5c 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -534,8 +534,8 @@ int dn_fib_rtm_newroute(struct sk_buff *
 
 int dn_fib_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	int t;
-	int s_t;
+	u32 t;
+	u32 s_t;
 	struct dn_fib_table *tb;
 
 	if (NLMSG_PAYLOAD(cb->nlh, 0) >= sizeof(struct rtmsg) &&
@@ -765,7 +765,7 @@ void dn_fib_flush(void)
 {
         int flushed = 0;
         struct dn_fib_table *tb;
-        int id;
+        u32 id;
 
         for(id = RT_TABLE_MAX; id > 0; id--) {
                 if ((tb = dn_fib_get_table(id, 0)) == NULL)
diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index c6a2e41..b7c6c06 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -264,7 +264,7 @@ static int dn_fib_nh_match(struct rtmsg 
 }
 
 static int dn_fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
-                        u8 tb_id, u8 type, u8 scope, void *dst, int dst_len,
+                        u32 tb_id, u8 type, u8 scope, void *dst, int dst_len,
                         struct dn_fib_info *fi, unsigned int flags)
 {
         struct rtmsg *rtm;
@@ -327,7 +327,7 @@ rtattr_failure:
 }
 
 
-static void dn_rtmsg_fib(int event, struct dn_fib_node *f, int z, int tb_id,
+static void dn_rtmsg_fib(int event, struct dn_fib_node *f, int z, u32 tb_id,
                         struct nlmsghdr *nlh, struct netlink_skb_parms *req)
 {
         struct sk_buff *skb;
@@ -736,7 +736,7 @@ out:
 }
 
 
-struct dn_fib_table *dn_fib_get_table(int n, int create)
+struct dn_fib_table *dn_fib_get_table(u32 n, int create)
 {
         struct dn_fib_table *t;
 
@@ -773,7 +773,7 @@ struct dn_fib_table *dn_fib_get_table(in
         return t;
 }
 
-static void dn_fib_del_tree(int n)
+static void dn_fib_del_tree(u32 n)
 {
 	struct dn_fib_table *t;
 
@@ -787,7 +787,7 @@ static void dn_fib_del_tree(int n)
 
 struct dn_fib_table *dn_fib_empty_table(void)
 {
-        int id;
+        u32 id;
 
         for(id = RT_TABLE_MIN; id <= RT_TABLE_MAX; id++)
                 if (dn_fib_tables[id] == NULL)
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index a83f1aa..06f4b23 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -62,7 +62,7 @@ #define RT_TABLE_MIN 1
 
 struct fib_table *fib_tables[RT_TABLE_MAX+1];
 
-struct fib_table *__fib_new_table(int id)
+struct fib_table *__fib_new_table(u32 id)
 {
 	struct fib_table *tb;
 
@@ -82,7 +82,7 @@ static void fib_flush(void)
 	int flushed = 0;
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	struct fib_table *tb;
-	int id;
+	u32 id;
 
 	for (id = RT_TABLE_MAX; id>0; id--) {
 		if ((tb = fib_get_table(id))==NULL)
@@ -333,8 +333,8 @@ int inet_rtm_newroute(struct sk_buff *sk
 
 int inet_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	int t;
-	int s_t;
+	u32 t;
+	u32 s_t;
 	struct fib_table *tb;
 
 	if (NLMSG_PAYLOAD(cb->nlh, 0) >= sizeof(struct rtmsg) &&
diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 72c633b..f8d5c80 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -765,9 +765,9 @@ static int fn_hash_dump(struct fib_table
 }
 
 #ifdef CONFIG_IP_MULTIPLE_TABLES
-struct fib_table * fib_hash_init(int id)
+struct fib_table * fib_hash_init(u32 id)
 #else
-struct fib_table * __init fib_hash_init(int id)
+struct fib_table * __init fib_hash_init(u32 id)
 #endif
 {
 	struct fib_table *tb;
diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index ef6609e..ddd5249 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -30,11 +30,11 @@ extern struct fib_info *fib_create_info(
 extern int fib_nh_match(struct rtmsg *r, struct nlmsghdr *,
 			struct kern_rta *rta, struct fib_info *fi);
 extern int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
-			 u8 tb_id, u8 type, u8 scope, void *dst,
+			 u32 tb_id, u8 type, u8 scope, void *dst,
 			 int dst_len, u8 tos, struct fib_info *fi,
 			 unsigned int);
 extern void rtmsg_fib(int event, u32 key, struct fib_alias *fa,
-		      int z, int tb_id,
+		      int z, u32 tb_id,
 		      struct nlmsghdr *n, struct netlink_skb_parms *req);
 extern struct fib_alias *fib_find_alias(struct list_head *fah,
 					u8 tos, u32 prio);
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index d242e52..58fb91b 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -169,7 +169,7 @@ #endif
 
 static struct fib_table *fib_empty_table(void)
 {
-	int id;
+	u32 id;
 
 	for (id = 1; id <= RT_TABLE_MAX; id++)
 		if (fib_tables[id] == NULL)
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 8aa6014..17c7974 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -273,7 +273,7 @@ int ip_fib_check_default(u32 gw, struct 
 }
 
 void rtmsg_fib(int event, u32 key, struct fib_alias *fa,
-	       int z, int tb_id,
+	       int z, u32 tb_id,
 	       struct nlmsghdr *n, struct netlink_skb_parms *req)
 {
 	struct sk_buff *skb;
@@ -935,7 +935,7 @@ u32 __fib_res_prefsrc(struct fib_result 
 
 int
 fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
-	      u8 tb_id, u8 type, u8 scope, void *dst, int dst_len, u8 tos,
+	      u32 tb_id, u8 type, u8 scope, void *dst, int dst_len, u8 tos,
 	      struct fib_info *fi, unsigned int flags)
 {
 	struct rtmsg *rtm;
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 23fb9d9..b98f211 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1148,7 +1148,7 @@ fn_trie_insert(struct fib_table *tb, str
 
 	key = ntohl(key);
 
-	pr_debug("Insert table=%d %08x/%d\n", tb->tb_id, key, plen);
+	pr_debug("Insert table=%u %08x/%d\n", tb->tb_id, key, plen);
 
 	mask = ntohl(inet_make_mask(plen));
 
@@ -1943,9 +1943,9 @@ out:
 /* Fix more generic FIB names for init later */
 
 #ifdef CONFIG_IP_MULTIPLE_TABLES
-struct fib_table * fib_hash_init(int id)
+struct fib_table * fib_hash_init(u32 id)
 #else
-struct fib_table * __init fib_hash_init(int id)
+struct fib_table * __init fib_hash_init(u32 id)
 #endif
 {
 	struct fib_table *tb;
