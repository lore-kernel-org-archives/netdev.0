From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 1/1] netfilter: constify nf_conntrack_l3/4proto parameters
Date: Sat, 29 Jul 2017 21:23:17 +0200
Message-ID: <1501356197-26490-2-git-send-email-Julia.Lawall@lip6.fr>
References: <1501356197-26490-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: bhumirks@gmail.com, kernel-janitors@vger.kernel.org,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:40147
        "EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751522AbdG2Tsi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 15:48:38 -0400
In-Reply-To: <1501356197-26490-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a nf_conntrack_l3/4proto parameter is not on the left hand side
of an assignment, its address is not taken, and it is not passed to a
function that may modify its fields, then it can be declared as const.

This change is useful from a documentation point of view, and can
possibly facilitate making some nf_conntrack_l3/4proto structures const
subsequently.

Done with the help of Coccinelle.

Some spacing adjusted to fit within 80 characters.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 include/net/netfilter/nf_conntrack_l3proto.h |    6 +++---
 include/net/netfilter/nf_conntrack_l4proto.h |    8 ++++----
 include/net/netfilter/nf_conntrack_timeout.h |    2 +-
 net/netfilter/nf_conntrack_core.c            |    8 ++++----
 net/netfilter/nf_conntrack_netlink.c         |    6 +++---
 net/netfilter/nf_conntrack_proto.c           |   20 ++++++++++----------
 net/netfilter/nfnetlink_cttimeout.c          |    2 +-
 7 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
index 6d14b36..4782b15 100644
--- a/include/net/netfilter/nf_conntrack_l3proto.h
+++ b/include/net/netfilter/nf_conntrack_l3proto.h
@@ -76,17 +76,17 @@ struct nf_conntrack_l3proto {
 #ifdef CONFIG_SYSCTL
 /* Protocol pernet registration. */
 int nf_ct_l3proto_pernet_register(struct net *net,
-				  struct nf_conntrack_l3proto *proto);
+				  const struct nf_conntrack_l3proto *proto);
 #else
 static inline int nf_ct_l3proto_pernet_register(struct net *n,
-						struct nf_conntrack_l3proto *p)
+					const struct nf_conntrack_l3proto *p)
 {
 	return 0;
 }
 #endif
 
 void nf_ct_l3proto_pernet_unregister(struct net *net,
-				     struct nf_conntrack_l3proto *proto);
+				     const struct nf_conntrack_l3proto *proto);
 
 /* Protocol global registration. */
 int nf_ct_l3proto_register(struct nf_conntrack_l3proto *proto);
diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 7032e04..72589b7 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -125,13 +125,13 @@ struct nf_conntrack_l4proto *__nf_ct_l4proto_find(u_int16_t l3proto,
 
 struct nf_conntrack_l4proto *nf_ct_l4proto_find_get(u_int16_t l3proto,
 						    u_int8_t l4proto);
-void nf_ct_l4proto_put(struct nf_conntrack_l4proto *p);
+void nf_ct_l4proto_put(const struct nf_conntrack_l4proto *p);
 
 /* Protocol pernet registration. */
 int nf_ct_l4proto_pernet_register_one(struct net *net,
-				      struct nf_conntrack_l4proto *proto);
+				      const struct nf_conntrack_l4proto *proto);
 void nf_ct_l4proto_pernet_unregister_one(struct net *net,
-					 struct nf_conntrack_l4proto *proto);
+				const struct nf_conntrack_l4proto *proto);
 int nf_ct_l4proto_pernet_register(struct net *net,
 				  struct nf_conntrack_l4proto *proto[],
 				  unsigned int num_proto);
@@ -141,7 +141,7 @@ void nf_ct_l4proto_pernet_unregister(struct net *net,
 
 /* Protocol global registration. */
 int nf_ct_l4proto_register_one(struct nf_conntrack_l4proto *proto);
-void nf_ct_l4proto_unregister_one(struct nf_conntrack_l4proto *proto);
+void nf_ct_l4proto_unregister_one(const struct nf_conntrack_l4proto *proto);
 int nf_ct_l4proto_register(struct nf_conntrack_l4proto *proto[],
 			   unsigned int num_proto);
 void nf_ct_l4proto_unregister(struct nf_conntrack_l4proto *proto[],
diff --git a/include/net/netfilter/nf_conntrack_timeout.h b/include/net/netfilter/nf_conntrack_timeout.h
index d40b893..b222957 100644
--- a/include/net/netfilter/nf_conntrack_timeout.h
+++ b/include/net/netfilter/nf_conntrack_timeout.h
@@ -68,7 +68,7 @@ struct nf_conn_timeout *nf_ct_timeout_ext_add(struct nf_conn *ct,
 
 static inline unsigned int *
 nf_ct_timeout_lookup(struct net *net, struct nf_conn *ct,
-		     struct nf_conntrack_l4proto *l4proto)
+		     const struct nf_conntrack_l4proto *l4proto)
 {
 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
 	struct nf_conn_timeout *timeout_ext;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 51390fe..ed4e04e 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1183,8 +1183,8 @@ void nf_conntrack_free(struct nf_conn *ct)
 static noinline struct nf_conntrack_tuple_hash *
 init_conntrack(struct net *net, struct nf_conn *tmpl,
 	       const struct nf_conntrack_tuple *tuple,
-	       struct nf_conntrack_l3proto *l3proto,
-	       struct nf_conntrack_l4proto *l4proto,
+	       const struct nf_conntrack_l3proto *l3proto,
+	       const struct nf_conntrack_l4proto *l4proto,
 	       struct sk_buff *skb,
 	       unsigned int dataoff, u32 hash)
 {
@@ -1295,8 +1295,8 @@ void nf_conntrack_free(struct nf_conn *ct)
 		  unsigned int dataoff,
 		  u_int16_t l3num,
 		  u_int8_t protonum,
-		  struct nf_conntrack_l3proto *l3proto,
-		  struct nf_conntrack_l4proto *l4proto)
+		  const struct nf_conntrack_l3proto *l3proto,
+		  const struct nf_conntrack_l4proto *l4proto)
 {
 	const struct nf_conntrack_zone *zone;
 	struct nf_conntrack_tuple tuple;
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 7999e70..5d08602 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -61,8 +61,8 @@
 static char __initdata version[] = "0.93";
 
 static int ctnetlink_dump_tuples_proto(struct sk_buff *skb,
-				       const struct nf_conntrack_tuple *tuple,
-				       struct nf_conntrack_l4proto *l4proto)
+				const struct nf_conntrack_tuple *tuple,
+				const struct nf_conntrack_l4proto *l4proto)
 {
 	int ret = 0;
 	struct nlattr *nest_parms;
@@ -86,7 +86,7 @@ static int ctnetlink_dump_tuples_proto(struct sk_buff *skb,
 
 static int ctnetlink_dump_tuples_ip(struct sk_buff *skb,
 				    const struct nf_conntrack_tuple *tuple,
-				    struct nf_conntrack_l3proto *l3proto)
+				    const struct nf_conntrack_l3proto *l3proto)
 {
 	int ret = 0;
 	struct nlattr *nest_parms;
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 1dcad22..390799a 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -188,7 +188,7 @@ struct nf_conntrack_l4proto *
 }
 EXPORT_SYMBOL_GPL(nf_ct_l4proto_find_get);
 
-void nf_ct_l4proto_put(struct nf_conntrack_l4proto *p)
+void nf_ct_l4proto_put(const struct nf_conntrack_l4proto *p)
 {
 	module_put(p->me);
 }
@@ -242,7 +242,7 @@ int nf_ct_l3proto_register(struct nf_conntrack_l3proto *proto)
 extern unsigned int nf_conntrack_default_on;
 
 int nf_ct_l3proto_pernet_register(struct net *net,
-				  struct nf_conntrack_l3proto *proto)
+				  const struct nf_conntrack_l3proto *proto)
 {
 	if (nf_conntrack_default_on == 0)
 		return 0;
@@ -271,7 +271,7 @@ void nf_ct_l3proto_unregister(struct nf_conntrack_l3proto *proto)
 EXPORT_SYMBOL_GPL(nf_ct_l3proto_unregister);
 
 void nf_ct_l3proto_pernet_unregister(struct net *net,
-				     struct nf_conntrack_l3proto *proto)
+				     const struct nf_conntrack_l3proto *proto)
 {
 	/*
 	 * nf_conntrack_default_on *might* have registered hooks.
@@ -286,7 +286,7 @@ void nf_ct_l3proto_pernet_unregister(struct net *net,
 EXPORT_SYMBOL_GPL(nf_ct_l3proto_pernet_unregister);
 
 static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
-					      struct nf_conntrack_l4proto *l4proto)
+				const struct nf_conntrack_l4proto *l4proto)
 {
 	if (l4proto->get_net_proto) {
 		/* statically built-in protocols use static per-net */
@@ -301,7 +301,7 @@ static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
 static
 int nf_ct_l4proto_register_sysctl(struct net *net,
 				  struct nf_proto_net *pn,
-				  struct nf_conntrack_l4proto *l4proto)
+				  const struct nf_conntrack_l4proto *l4proto)
 {
 	int err = 0;
 
@@ -325,7 +325,7 @@ int nf_ct_l4proto_register_sysctl(struct net *net,
 static
 void nf_ct_l4proto_unregister_sysctl(struct net *net,
 				     struct nf_proto_net *pn,
-				     struct nf_conntrack_l4proto *l4proto)
+				     const struct nf_conntrack_l4proto *l4proto)
 {
 #ifdef CONFIG_SYSCTL
 	if (pn->ctl_table_header != NULL)
@@ -395,7 +395,7 @@ int nf_ct_l4proto_register_one(struct nf_conntrack_l4proto *l4proto)
 EXPORT_SYMBOL_GPL(nf_ct_l4proto_register_one);
 
 int nf_ct_l4proto_pernet_register_one(struct net *net,
-				      struct nf_conntrack_l4proto *l4proto)
+				const struct nf_conntrack_l4proto *l4proto)
 {
 	int ret = 0;
 	struct nf_proto_net *pn = NULL;
@@ -420,7 +420,7 @@ int nf_ct_l4proto_pernet_register_one(struct net *net,
 }
 EXPORT_SYMBOL_GPL(nf_ct_l4proto_pernet_register_one);
 
-static void __nf_ct_l4proto_unregister_one(struct nf_conntrack_l4proto *l4proto)
+static void __nf_ct_l4proto_unregister_one(const struct nf_conntrack_l4proto *l4proto)
 
 {
 	BUG_ON(l4proto->l3proto >= ARRAY_SIZE(nf_ct_protos));
@@ -433,7 +433,7 @@ static void __nf_ct_l4proto_unregister_one(struct nf_conntrack_l4proto *l4proto)
 			   &nf_conntrack_l4proto_generic);
 }
 
-void nf_ct_l4proto_unregister_one(struct nf_conntrack_l4proto *l4proto)
+void nf_ct_l4proto_unregister_one(const struct nf_conntrack_l4proto *l4proto)
 {
 	mutex_lock(&nf_ct_proto_mutex);
 	__nf_ct_l4proto_unregister_one(l4proto);
@@ -444,7 +444,7 @@ void nf_ct_l4proto_unregister_one(struct nf_conntrack_l4proto *l4proto)
 EXPORT_SYMBOL_GPL(nf_ct_l4proto_unregister_one);
 
 void nf_ct_l4proto_pernet_unregister_one(struct net *net,
-					 struct nf_conntrack_l4proto *l4proto)
+				const struct nf_conntrack_l4proto *l4proto)
 {
 	struct nf_proto_net *pn = nf_ct_l4proto_net(net, l4proto);
 
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 400e9ae..ca760b9 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -401,7 +401,7 @@ static int cttimeout_default_set(struct net *net, struct sock *ctnl,
 static int
 cttimeout_default_fill_info(struct net *net, struct sk_buff *skb, u32 portid,
 			    u32 seq, u32 type, int event,
-			    struct nf_conntrack_l4proto *l4proto)
+			    const struct nf_conntrack_l4proto *l4proto)
 {
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
