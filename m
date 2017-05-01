From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 42/53] netfilter: conntrack: mark extension structs as const
Date: Mon,  1 May 2017 12:47:09 +0200
Message-ID: <1493635640-24325-43-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_extend.h | 4 ++--
 net/netfilter/nf_conntrack_acct.c           | 2 +-
 net/netfilter/nf_conntrack_ecache.c         | 2 +-
 net/netfilter/nf_conntrack_extend.c         | 4 ++--
 net/netfilter/nf_conntrack_helper.c         | 2 +-
 net/netfilter/nf_conntrack_labels.c         | 2 +-
 net/netfilter/nf_conntrack_seqadj.c         | 2 +-
 net/netfilter/nf_conntrack_timeout.c        | 2 +-
 net/netfilter/nf_conntrack_timestamp.c      | 2 +-
 9 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index dd776bf9e2fa..b01f73fb4dcb 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -99,6 +99,6 @@ struct nf_ct_ext_type {
 	u8 align;
 };
 
-int nf_ct_extend_register(struct nf_ct_ext_type *type);
-void nf_ct_extend_unregister(struct nf_ct_ext_type *type);
+int nf_ct_extend_register(const struct nf_ct_ext_type *type);
+void nf_ct_extend_unregister(const struct nf_ct_ext_type *type);
 #endif /* _NF_CONNTRACK_EXTEND_H */
diff --git a/net/netfilter/nf_conntrack_acct.c b/net/netfilter/nf_conntrack_acct.c
index 45da11afa785..866916712905 100644
--- a/net/netfilter/nf_conntrack_acct.c
+++ b/net/netfilter/nf_conntrack_acct.c
@@ -55,7 +55,7 @@ seq_print_acct(struct seq_file *s, const struct nf_conn *ct, int dir)
 };
 EXPORT_SYMBOL_GPL(seq_print_acct);
 
-static struct nf_ct_ext_type acct_extend __read_mostly = {
+static const struct nf_ct_ext_type acct_extend = {
 	.len	= sizeof(struct nf_conn_acct),
 	.align	= __alignof__(struct nf_conn_acct),
 	.id	= NF_CT_EXT_ACCT,
diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index 515212948125..caac41ad9483 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -347,7 +347,7 @@ static struct ctl_table event_sysctl_table[] = {
 };
 #endif /* CONFIG_SYSCTL */
 
-static struct nf_ct_ext_type event_extend __read_mostly = {
+static const struct nf_ct_ext_type event_extend = {
 	.len	= sizeof(struct nf_conntrack_ecache),
 	.align	= __alignof__(struct nf_conntrack_ecache),
 	.id	= NF_CT_EXT_ECACHE,
diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index 2e4b41bc67a0..5c66816eb965 100644
--- a/net/netfilter/nf_conntrack_extend.c
+++ b/net/netfilter/nf_conntrack_extend.c
@@ -116,7 +116,7 @@ void *nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp)
 EXPORT_SYMBOL(nf_ct_ext_add);
 
 /* This MUST be called in process context. */
-int nf_ct_extend_register(struct nf_ct_ext_type *type)
+int nf_ct_extend_register(const struct nf_ct_ext_type *type)
 {
 	int ret = 0;
 
@@ -134,7 +134,7 @@ int nf_ct_extend_register(struct nf_ct_ext_type *type)
 EXPORT_SYMBOL_GPL(nf_ct_extend_register);
 
 /* This MUST be called in process context. */
-void nf_ct_extend_unregister(struct nf_ct_ext_type *type)
+void nf_ct_extend_unregister(const struct nf_ct_ext_type *type)
 {
 	mutex_lock(&nf_ct_ext_type_mutex);
 	RCU_INIT_POINTER(nf_ct_ext_types[type->id], NULL);
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 8239b4406f56..a57a52f173f7 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -535,7 +535,7 @@ void nf_conntrack_helpers_unregister(struct nf_conntrack_helper *helper,
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_helpers_unregister);
 
-static struct nf_ct_ext_type helper_extend __read_mostly = {
+static const struct nf_ct_ext_type helper_extend = {
 	.len	= sizeof(struct nf_conn_help),
 	.align	= __alignof__(struct nf_conn_help),
 	.id	= NF_CT_EXT_HELPER,
diff --git a/net/netfilter/nf_conntrack_labels.c b/net/netfilter/nf_conntrack_labels.c
index bcab8bde7312..adf219859901 100644
--- a/net/netfilter/nf_conntrack_labels.c
+++ b/net/netfilter/nf_conntrack_labels.c
@@ -82,7 +82,7 @@ void nf_connlabels_put(struct net *net)
 }
 EXPORT_SYMBOL_GPL(nf_connlabels_put);
 
-static struct nf_ct_ext_type labels_extend __read_mostly = {
+static const struct nf_ct_ext_type labels_extend = {
 	.len    = sizeof(struct nf_conn_labels),
 	.align  = __alignof__(struct nf_conn_labels),
 	.id     = NF_CT_EXT_LABELS,
diff --git a/net/netfilter/nf_conntrack_seqadj.c b/net/netfilter/nf_conntrack_seqadj.c
index ef7063eced7c..a975efd6b8c3 100644
--- a/net/netfilter/nf_conntrack_seqadj.c
+++ b/net/netfilter/nf_conntrack_seqadj.c
@@ -231,7 +231,7 @@ s32 nf_ct_seq_offset(const struct nf_conn *ct,
 }
 EXPORT_SYMBOL_GPL(nf_ct_seq_offset);
 
-static struct nf_ct_ext_type nf_ct_seqadj_extend __read_mostly = {
+static const struct nf_ct_ext_type nf_ct_seqadj_extend = {
 	.len	= sizeof(struct nf_conn_seqadj),
 	.align	= __alignof__(struct nf_conn_seqadj),
 	.id	= NF_CT_EXT_SEQADJ,
diff --git a/net/netfilter/nf_conntrack_timeout.c b/net/netfilter/nf_conntrack_timeout.c
index 26e742006c48..46aee65f339b 100644
--- a/net/netfilter/nf_conntrack_timeout.c
+++ b/net/netfilter/nf_conntrack_timeout.c
@@ -31,7 +31,7 @@ EXPORT_SYMBOL_GPL(nf_ct_timeout_find_get_hook);
 void (*nf_ct_timeout_put_hook)(struct ctnl_timeout *timeout) __read_mostly;
 EXPORT_SYMBOL_GPL(nf_ct_timeout_put_hook);
 
-static struct nf_ct_ext_type timeout_extend __read_mostly = {
+static const struct nf_ct_ext_type timeout_extend = {
 	.len	= sizeof(struct nf_conn_timeout),
 	.align	= __alignof__(struct nf_conn_timeout),
 	.id	= NF_CT_EXT_TIMEOUT,
diff --git a/net/netfilter/nf_conntrack_timestamp.c b/net/netfilter/nf_conntrack_timestamp.c
index 7a394df0deb7..4c4734b78318 100644
--- a/net/netfilter/nf_conntrack_timestamp.c
+++ b/net/netfilter/nf_conntrack_timestamp.c
@@ -33,7 +33,7 @@ static struct ctl_table tstamp_sysctl_table[] = {
 };
 #endif /* CONFIG_SYSCTL */
 
-static struct nf_ct_ext_type tstamp_extend __read_mostly = {
+static const struct nf_ct_ext_type tstamp_extend = {
 	.len	= sizeof(struct nf_conn_tstamp),
 	.align	= __alignof__(struct nf_conn_tstamp),
 	.id	= NF_CT_EXT_TSTAMP,
-- 
2.1.4

