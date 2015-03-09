From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/12] netfilter: nf_tables: cleanup nf_tables.h
Date: Mon,  9 Mar 2015 18:14:29 +0100
Message-ID: <1425921275-9171-7-git-send-email-pablo@netfilter.org>
References: <1425921275-9171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47208 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753597AbbCIRLG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 13:11:06 -0400
In-Reply-To: <1425921275-9171-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

The transaction related definitions are squeezed in between the rule
and expression definitions, which are closely related and should be
next to each other. The transaction definitions actually don't belong
into that file at all since it defines the global objects and API and
transactions are internal to nf_tables_api, but for now simply move
them to a seperate section.

Similar, the chain types are in between a set of registration functions,
they belong to the chain section.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |  174 ++++++++++++++++++-------------------
 1 file changed, 87 insertions(+), 87 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 9eaaa78..04188b4 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -393,74 +393,6 @@ struct nft_rule {
 		__attribute__((aligned(__alignof__(struct nft_expr))));
 };
 
-/**
- *	struct nft_trans - nf_tables object update in transaction
- *
- *	@list: used internally
- *	@msg_type: message type
- *	@ctx: transaction context
- *	@data: internal information related to the transaction
- */
-struct nft_trans {
-	struct list_head		list;
-	int				msg_type;
-	struct nft_ctx			ctx;
-	char				data[0];
-};
-
-struct nft_trans_rule {
-	struct nft_rule			*rule;
-};
-
-#define nft_trans_rule(trans)	\
-	(((struct nft_trans_rule *)trans->data)->rule)
-
-struct nft_trans_set {
-	struct nft_set	*set;
-	u32		set_id;
-};
-
-#define nft_trans_set(trans)	\
-	(((struct nft_trans_set *)trans->data)->set)
-#define nft_trans_set_id(trans)	\
-	(((struct nft_trans_set *)trans->data)->set_id)
-
-struct nft_trans_chain {
-	bool		update;
-	char		name[NFT_CHAIN_MAXNAMELEN];
-	struct nft_stats __percpu *stats;
-	u8		policy;
-};
-
-#define nft_trans_chain_update(trans)	\
-	(((struct nft_trans_chain *)trans->data)->update)
-#define nft_trans_chain_name(trans)	\
-	(((struct nft_trans_chain *)trans->data)->name)
-#define nft_trans_chain_stats(trans)	\
-	(((struct nft_trans_chain *)trans->data)->stats)
-#define nft_trans_chain_policy(trans)	\
-	(((struct nft_trans_chain *)trans->data)->policy)
-
-struct nft_trans_table {
-	bool		update;
-	bool		enable;
-};
-
-#define nft_trans_table_update(trans)	\
-	(((struct nft_trans_table *)trans->data)->update)
-#define nft_trans_table_enable(trans)	\
-	(((struct nft_trans_table *)trans->data)->enable)
-
-struct nft_trans_elem {
-	struct nft_set		*set;
-	struct nft_set_elem	elem;
-};
-
-#define nft_trans_elem_set(trans)	\
-	(((struct nft_trans_elem *)trans->data)->set)
-#define nft_trans_elem(trans)	\
-	(((struct nft_trans_elem *)trans->data)->elem)
-
 static inline struct nft_expr *nft_expr_first(const struct nft_rule *rule)
 {
 	return (struct nft_expr *)&rule->data[0];
@@ -528,6 +460,25 @@ enum nft_chain_type {
 	NFT_CHAIN_T_MAX
 };
 
+/**
+ * 	struct nf_chain_type - nf_tables chain type info
+ *
+ * 	@name: name of the type
+ * 	@type: numeric identifier
+ * 	@family: address family
+ * 	@owner: module owner
+ * 	@hook_mask: mask of valid hooks
+ * 	@hooks: hookfn overrides
+ */
+struct nf_chain_type {
+	const char			*name;
+	enum nft_chain_type		type;
+	int				family;
+	struct module			*owner;
+	unsigned int			hook_mask;
+	nf_hookfn			*hooks[NF_MAX_HOOKS];
+};
+
 int nft_chain_validate_dependency(const struct nft_chain *chain,
 				  enum nft_chain_type type);
 int nft_chain_validate_hooks(const struct nft_chain *chain,
@@ -614,25 +565,6 @@ struct nft_af_info {
 int nft_register_afinfo(struct net *, struct nft_af_info *);
 void nft_unregister_afinfo(struct nft_af_info *);
 
-/**
- * 	struct nf_chain_type - nf_tables chain type info
- *
- * 	@name: name of the type
- * 	@type: numeric identifier
- * 	@family: address family
- * 	@owner: module owner
- * 	@hook_mask: mask of valid hooks
- * 	@hooks: hookfn overrides
- */
-struct nf_chain_type {
-	const char			*name;
-	enum nft_chain_type		type;
-	int				family;
-	struct module			*owner;
-	unsigned int			hook_mask;
-	nf_hookfn			*hooks[NF_MAX_HOOKS];
-};
-
 int nft_register_chain_type(const struct nf_chain_type *);
 void nft_unregister_chain_type(const struct nf_chain_type *);
 
@@ -657,4 +589,72 @@ void nft_unregister_expr(struct nft_expr_type *);
 #define MODULE_ALIAS_NFT_SET() \
 	MODULE_ALIAS("nft-set")
 
+/**
+ *	struct nft_trans - nf_tables object update in transaction
+ *
+ *	@list: used internally
+ *	@msg_type: message type
+ *	@ctx: transaction context
+ *	@data: internal information related to the transaction
+ */
+struct nft_trans {
+	struct list_head		list;
+	int				msg_type;
+	struct nft_ctx			ctx;
+	char				data[0];
+};
+
+struct nft_trans_rule {
+	struct nft_rule			*rule;
+};
+
+#define nft_trans_rule(trans)	\
+	(((struct nft_trans_rule *)trans->data)->rule)
+
+struct nft_trans_set {
+	struct nft_set			*set;
+	u32				set_id;
+};
+
+#define nft_trans_set(trans)	\
+	(((struct nft_trans_set *)trans->data)->set)
+#define nft_trans_set_id(trans)	\
+	(((struct nft_trans_set *)trans->data)->set_id)
+
+struct nft_trans_chain {
+	bool				update;
+	char				name[NFT_CHAIN_MAXNAMELEN];
+	struct nft_stats __percpu	*stats;
+	u8				policy;
+};
+
+#define nft_trans_chain_update(trans)	\
+	(((struct nft_trans_chain *)trans->data)->update)
+#define nft_trans_chain_name(trans)	\
+	(((struct nft_trans_chain *)trans->data)->name)
+#define nft_trans_chain_stats(trans)	\
+	(((struct nft_trans_chain *)trans->data)->stats)
+#define nft_trans_chain_policy(trans)	\
+	(((struct nft_trans_chain *)trans->data)->policy)
+
+struct nft_trans_table {
+	bool				update;
+	bool				enable;
+};
+
+#define nft_trans_table_update(trans)	\
+	(((struct nft_trans_table *)trans->data)->update)
+#define nft_trans_table_enable(trans)	\
+	(((struct nft_trans_table *)trans->data)->enable)
+
+struct nft_trans_elem {
+	struct nft_set			*set;
+	struct nft_set_elem		elem;
+};
+
+#define nft_trans_elem_set(trans)	\
+	(((struct nft_trans_elem *)trans->data)->set)
+#define nft_trans_elem(trans)	\
+	(((struct nft_trans_elem *)trans->data)->elem)
+
 #endif /* _NET_NF_TABLES_H */
-- 
1.7.10.4
