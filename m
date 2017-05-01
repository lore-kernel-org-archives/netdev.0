From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/53] netfilter: Remove exceptional & on function name
Date: Mon,  1 May 2017 12:46:41 +0200
Message-ID: <1493635640-24325-15-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arushi Singhal <arushisinghal19971997@gmail.com>

Remove & from function pointers to conform to the style found elsewhere
in the file. Done using the following semantic patch

// <smpl>
@r@
identifier f;
@@

f(...) { ... }
@@
identifier r.f;
@@

- &f
+ f
// </smpl>

Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/nft_meta_bridge.c | 2 +-
 net/ipv4/netfilter/nft_fib_ipv4.c      | 2 +-
 net/ipv6/netfilter/nft_fib_ipv6.c      | 2 +-
 net/netfilter/ipset/ip_set_core.c      | 2 +-
 net/netfilter/ipvs/ip_vs_ctl.c         | 4 ++--
 net/netfilter/nfnetlink.c              | 2 +-
 net/netfilter/nfnetlink_log.c          | 2 +-
 net/netfilter/nfnetlink_queue.c        | 4 ++--
 net/netfilter/nft_ct.c                 | 2 +-
 net/netfilter/nft_exthdr.c             | 2 +-
 net/netfilter/nft_hash.c               | 2 +-
 net/netfilter/nft_meta.c               | 2 +-
 net/netfilter/nft_numgen.c             | 2 +-
 net/netfilter/nft_queue.c              | 2 +-
 14 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/net/bridge/netfilter/nft_meta_bridge.c b/net/bridge/netfilter/nft_meta_bridge.c
index 5974dbc1ea24..bb63c9aed55d 100644
--- a/net/bridge/netfilter/nft_meta_bridge.c
+++ b/net/bridge/netfilter/nft_meta_bridge.c
@@ -111,7 +111,7 @@ nft_meta_bridge_select_ops(const struct nft_ctx *ctx,
 static struct nft_expr_type nft_meta_bridge_type __read_mostly = {
 	.family         = NFPROTO_BRIDGE,
 	.name           = "meta",
-	.select_ops     = &nft_meta_bridge_select_ops,
+	.select_ops     = nft_meta_bridge_select_ops,
 	.policy         = nft_meta_policy,
 	.maxattr        = NFTA_META_MAX,
 	.owner          = THIS_MODULE,
diff --git a/net/ipv4/netfilter/nft_fib_ipv4.c b/net/ipv4/netfilter/nft_fib_ipv4.c
index f4e4462cb5bb..de3681df2ce7 100644
--- a/net/ipv4/netfilter/nft_fib_ipv4.c
+++ b/net/ipv4/netfilter/nft_fib_ipv4.c
@@ -212,7 +212,7 @@ nft_fib4_select_ops(const struct nft_ctx *ctx,
 
 static struct nft_expr_type nft_fib4_type __read_mostly = {
 	.name		= "fib",
-	.select_ops	= &nft_fib4_select_ops,
+	.select_ops	= nft_fib4_select_ops,
 	.policy		= nft_fib_policy,
 	.maxattr	= NFTA_FIB_MAX,
 	.family		= NFPROTO_IPV4,
diff --git a/net/ipv6/netfilter/nft_fib_ipv6.c b/net/ipv6/netfilter/nft_fib_ipv6.c
index e8d88d82636b..43f91d9b086c 100644
--- a/net/ipv6/netfilter/nft_fib_ipv6.c
+++ b/net/ipv6/netfilter/nft_fib_ipv6.c
@@ -246,7 +246,7 @@ nft_fib6_select_ops(const struct nft_ctx *ctx,
 
 static struct nft_expr_type nft_fib6_type __read_mostly = {
 	.name		= "fib",
-	.select_ops	= &nft_fib6_select_ops,
+	.select_ops	= nft_fib6_select_ops,
 	.policy		= nft_fib_policy,
 	.maxattr	= NFTA_FIB_MAX,
 	.family		= NFPROTO_IPV6,
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index c637710d861c..cb120c3c040e 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -2013,7 +2013,7 @@ static struct nf_sockopt_ops so_set __read_mostly = {
 	.pf		= PF_INET,
 	.get_optmin	= SO_IP_SET,
 	.get_optmax	= SO_IP_SET + 1,
-	.get		= &ip_set_sockfn_get,
+	.get		= ip_set_sockfn_get,
 	.owner		= THIS_MODULE,
 };
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c578b6c0dc41..90ac6bc1bd28 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1774,13 +1774,13 @@ static struct ctl_table vs_vars[] = {
 		.procname	= "sync_version",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_do_sync_mode,
+		.proc_handler	= proc_do_sync_mode,
 	},
 	{
 		.procname	= "sync_ports",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_do_sync_ports,
+		.proc_handler	= proc_do_sync_ports,
 	},
 	{
 		.procname	= "sync_persist_mode",
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 68eda920160e..185f9786a5a4 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -500,7 +500,7 @@ static void nfnetlink_rcv(struct sk_buff *skb)
 	if (nlh->nlmsg_type == NFNL_MSG_BATCH_BEGIN)
 		nfnetlink_rcv_skb_batch(skb, nlh);
 	else
-		netlink_rcv_skb(skb, &nfnetlink_rcv_msg);
+		netlink_rcv_skb(skb, nfnetlink_rcv_msg);
 }
 
 #ifdef CONFIG_MODULES
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index e7648e90d162..896741206a50 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -803,7 +803,7 @@ static int nfulnl_recv_unsupp(struct net *net, struct sock *ctnl,
 static struct nf_logger nfulnl_logger __read_mostly = {
 	.name	= "nfnetlink_log",
 	.type	= NF_LOG_TYPE_ULOG,
-	.logfn	= &nfulnl_log_packet,
+	.logfn	= nfulnl_log_packet,
 	.me	= THIS_MODULE,
 };
 
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 05e82004ab62..d09ab49e102a 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -1213,8 +1213,8 @@ static const struct nla_policy nfqa_cfg_policy[NFQA_CFG_MAX+1] = {
 };
 
 static const struct nf_queue_handler nfqh = {
-	.outfn		= &nfqnl_enqueue_packet,
-	.nf_hook_drop	= &nfqnl_nf_hook_drop,
+	.outfn		= nfqnl_enqueue_packet,
+	.nf_hook_drop	= nfqnl_nf_hook_drop,
 };
 
 static int nfqnl_recv_config(struct net *net, struct sock *ctnl,
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 640fe5a5865e..6e23dbbedd7f 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -702,7 +702,7 @@ nft_ct_select_ops(const struct nft_ctx *ctx,
 
 static struct nft_expr_type nft_ct_type __read_mostly = {
 	.name		= "ct",
-	.select_ops	= &nft_ct_select_ops,
+	.select_ops	= nft_ct_select_ops,
 	.policy		= nft_ct_policy,
 	.maxattr	= NFTA_CT_MAX,
 	.owner		= THIS_MODULE,
diff --git a/net/netfilter/nft_exthdr.c b/net/netfilter/nft_exthdr.c
index d212a85d2f33..1ec49fe5845f 100644
--- a/net/netfilter/nft_exthdr.c
+++ b/net/netfilter/nft_exthdr.c
@@ -232,7 +232,7 @@ nft_exthdr_select_ops(const struct nft_ctx *ctx,
 
 static struct nft_expr_type nft_exthdr_type __read_mostly = {
 	.name		= "exthdr",
-	.select_ops	= &nft_exthdr_select_ops,
+	.select_ops	= nft_exthdr_select_ops,
 	.policy		= nft_exthdr_policy,
 	.maxattr	= NFTA_EXTHDR_MAX,
 	.owner		= THIS_MODULE,
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index a6a4633725bb..4cfe524d8729 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -224,7 +224,7 @@ nft_hash_select_ops(const struct nft_ctx *ctx,
 
 static struct nft_expr_type nft_hash_type __read_mostly = {
 	.name		= "hash",
-	.select_ops	= &nft_hash_select_ops,
+	.select_ops	= nft_hash_select_ops,
 	.policy		= nft_hash_policy,
 	.maxattr	= NFTA_HASH_MAX,
 	.owner		= THIS_MODULE,
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 9563ce3c23aa..5a60eb23a7ed 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -467,7 +467,7 @@ nft_meta_select_ops(const struct nft_ctx *ctx,
 
 static struct nft_expr_type nft_meta_type __read_mostly = {
 	.name		= "meta",
-	.select_ops	= &nft_meta_select_ops,
+	.select_ops	= nft_meta_select_ops,
 	.policy		= nft_meta_policy,
 	.maxattr	= NFTA_META_MAX,
 	.owner		= THIS_MODULE,
diff --git a/net/netfilter/nft_numgen.c b/net/netfilter/nft_numgen.c
index a66b36097b8f..5a3a52c71545 100644
--- a/net/netfilter/nft_numgen.c
+++ b/net/netfilter/nft_numgen.c
@@ -188,7 +188,7 @@ nft_ng_select_ops(const struct nft_ctx *ctx, const struct nlattr * const tb[])
 
 static struct nft_expr_type nft_ng_type __read_mostly = {
 	.name		= "numgen",
-	.select_ops	= &nft_ng_select_ops,
+	.select_ops	= nft_ng_select_ops,
 	.policy		= nft_ng_policy,
 	.maxattr	= NFTA_NG_MAX,
 	.owner		= THIS_MODULE,
diff --git a/net/netfilter/nft_queue.c b/net/netfilter/nft_queue.c
index dbb6aaff67ec..98613658d4ac 100644
--- a/net/netfilter/nft_queue.c
+++ b/net/netfilter/nft_queue.c
@@ -197,7 +197,7 @@ nft_queue_select_ops(const struct nft_ctx *ctx,
 
 static struct nft_expr_type nft_queue_type __read_mostly = {
 	.name		= "queue",
-	.select_ops	= &nft_queue_select_ops,
+	.select_ops	= nft_queue_select_ops,
 	.policy		= nft_queue_policy,
 	.maxattr	= NFTA_QUEUE_MAX,
 	.owner		= THIS_MODULE,
-- 
2.1.4

