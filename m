From: simran singhal <singhalsimran0@gmail.com>
Subject: [PATCH 3/5] netfilter: nf_tables_api: Clean up tests if NULL returned on failure
Date: Tue, 21 Mar 2017 14:14:37 +0530
Message-ID: <1490085879-1827-4-git-send-email-singhalsimran0@gmail.com>
References: <1490085879-1827-1-git-send-email-singhalsimran0@gmail.com>
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        gregkh@linuxfoundation.org, outreachy-kernel@googlegroups.com
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33113 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932272AbdCUIpE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 04:45:04 -0400
In-Reply-To: <1490085879-1827-1-git-send-email-singhalsimran0@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some functions like kmalloc/kzalloc return NULL on failure. When NULL
represents failure, !x is commonly used.

This was done using Coccinelle:
@@
expression *e;
identifier l1;
@@
e = \(kmalloc\|kzalloc\|kcalloc\|devm_kzalloc\)(...);
...
- e == NULL
+ !e

Signed-off-by: simran singhal <singhalsimran0@gmail.com>
---

 --This is my contribution to the netfilter project of
   Outreachy Round 14.

 net/netfilter/nf_tables_api.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 5e0ccfd..25a3951 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -117,7 +117,7 @@ static struct nft_trans *nft_trans_alloc_gfp(const struct nft_ctx *ctx,
 	struct nft_trans *trans;
 
 	trans = kzalloc(sizeof(struct nft_trans) + size, gfp);
-	if (trans == NULL)
+	if (!trans)
 		return NULL;
 
 	trans->msg_type = msg_type;
@@ -720,7 +720,7 @@ static int nf_tables_newtable(struct net *net, struct sock *nlsk,
 
 	err = -ENOMEM;
 	table = kzalloc(sizeof(*table), GFP_KERNEL);
-	if (table == NULL)
+	if (!table)
 		goto err2;
 
 	nla_strlcpy(table->name, name, NFT_TABLE_MAXNAMELEN);
@@ -1478,7 +1478,7 @@ static int nf_tables_newchain(struct net *net, struct sock *nlsk,
 			return err;
 
 		basechain = kzalloc(sizeof(*basechain), GFP_KERNEL);
-		if (basechain == NULL) {
+		if (!basechain) {
 			nft_chain_release_hook(&hook);
 			return -ENOMEM;
 		}
@@ -1526,7 +1526,7 @@ static int nf_tables_newchain(struct net *net, struct sock *nlsk,
 		basechain->policy = policy;
 	} else {
 		chain = kzalloc(sizeof(*chain), GFP_KERNEL);
-		if (chain == NULL)
+		if (!chain)
 			return -ENOMEM;
 	}
 
@@ -1800,7 +1800,7 @@ struct nft_expr *nft_expr_init(const struct nft_ctx *ctx,
 
 	err = -ENOMEM;
 	expr = kzalloc(info.ops->size, GFP_KERNEL);
-	if (expr == NULL)
+	if (!expr)
 		goto err2;
 
 	err = nf_tables_newexpr(ctx, &info, expr);
@@ -2214,7 +2214,7 @@ static int nf_tables_newrule(struct net *net, struct sock *nlsk,
 
 	err = -ENOMEM;
 	rule = kzalloc(sizeof(*rule) + size + usize, GFP_KERNEL);
-	if (rule == NULL)
+	if (!rule)
 		goto err1;
 
 	nft_activate_next(net, rule);
@@ -2810,7 +2810,7 @@ static int nf_tables_getset(struct net *net, struct sock *nlsk,
 		struct nft_ctx *ctx_dump;
 
 		ctx_dump = kmalloc(sizeof(*ctx_dump), GFP_KERNEL);
-		if (ctx_dump == NULL)
+		if (!ctx_dump)
 			return -ENOMEM;
 
 		*ctx_dump = ctx;
@@ -3014,7 +3014,7 @@ static int nf_tables_newset(struct net *net, struct sock *nlsk,
 
 	err = -ENOMEM;
 	set = kzalloc(sizeof(*set) + size + udlen, GFP_KERNEL);
-	if (set == NULL)
+	if (!set)
 		goto err1;
 
 	nla_strlcpy(name, nla[NFTA_SET_NAME], sizeof(set->name));
@@ -3543,7 +3543,7 @@ void *nft_set_elem_init(const struct nft_set *set,
 	void *elem;
 
 	elem = kzalloc(set->ops->elemsize + tmpl->len, gfp);
-	if (elem == NULL)
+	if (!elem)
 		return NULL;
 
 	ext = nft_set_elem_ext(set, elem);
@@ -3998,7 +3998,7 @@ struct nft_set_gc_batch *nft_set_gc_batch_alloc(const struct nft_set *set,
 	struct nft_set_gc_batch *gcb;
 
 	gcb = kzalloc(sizeof(*gcb), gfp);
-	if (gcb == NULL)
+	if (!gcb)
 		return gcb;
 	gcb->head.set = set;
 	return gcb;
@@ -4084,7 +4084,7 @@ static struct nft_object *nft_obj_init(const struct nft_object_type *type,
 
 	err = -ENOMEM;
 	obj = kzalloc(sizeof(struct nft_object) + type->size, GFP_KERNEL);
-	if (obj == NULL)
+	if (!obj)
 		goto err1;
 
 	err = type->init((const struct nlattr * const *)tb, obj);
@@ -5567,7 +5567,7 @@ static int __init nf_tables_module_init(void)
 
 	info = kmalloc(sizeof(struct nft_expr_info) * NFT_RULE_MAXEXPRS,
 		       GFP_KERNEL);
-	if (info == NULL) {
+	if (!info) {
 		err = -ENOMEM;
 		goto err1;
 	}
-- 
2.7.4
