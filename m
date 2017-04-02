From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH 1/4] net: netfilter:Remove exceptional & on function name
Date: Sun,  2 Apr 2017 14:52:12 +0530
Message-ID: <20170402092215.22792-1-arushisinghal19971997@gmail.com>
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Arushi Singhal <arushisinghal19971997@gmail.com>
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
---
 net/netfilter/ipset/ip_set_core.c | 2 +-
 net/netfilter/ipvs/ip_vs_ctl.c    | 4 ++--
 net/netfilter/nfnetlink.c         | 2 +-
 net/netfilter/nfnetlink_log.c     | 2 +-
 net/netfilter/nfnetlink_queue.c   | 4 ++--
 net/netfilter/nft_ct.c            | 2 +-
 net/netfilter/nft_exthdr.c        | 2 +-
 net/netfilter/nft_meta.c          | 2 +-
 net/netfilter/nft_numgen.c        | 2 +-
 net/netfilter/nft_queue.c         | 2 +-
 10 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index c296f9b606d4..14f748b0bd17 100644
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
index 5aeb0dde6ccc..23c44b3b7510 100644
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
index 08247bf7d7b8..436d4dfe3e74 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -801,7 +801,7 @@ static int nfulnl_recv_unsupp(struct net *net, struct sock *ctnl,
 static struct nf_logger nfulnl_logger __read_mostly = {
 	.name	= "nfnetlink_log",
 	.type	= NF_LOG_TYPE_ULOG,
-	.logfn	= &nfulnl_log_packet,
+	.logfn	= nfulnl_log_packet,
 	.me	= THIS_MODULE,
 };
 
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 3ee0b8a000a4..e062ec234091 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -1208,8 +1208,8 @@ static const struct nla_policy nfqa_cfg_policy[NFQA_CFG_MAX+1] = {
 };
 
 static const struct nf_queue_handler nfqh = {
-	.outfn		= &nfqnl_enqueue_packet,
-	.nf_hook_drop	= &nfqnl_nf_hook_drop,
+	.outfn		= nfqnl_enqueue_packet,
+	.nf_hook_drop	= nfqnl_nf_hook_drop,
 };
 
 static int nfqnl_recv_config(struct net *net, struct sock *ctnl,
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 0264258c46fe..08f01d0853ef 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -696,7 +696,7 @@ nft_ct_select_ops(const struct nft_ctx *ctx,
 
 static struct nft_expr_type nft_ct_type __read_mostly = {
 	.name		= "ct",
-	.select_ops	= &nft_ct_select_ops,
+	.select_ops	= nft_ct_select_ops,
 	.policy		= nft_ct_policy,
 	.maxattr	= NFTA_CT_MAX,
 	.owner		= THIS_MODULE,
diff --git a/net/netfilter/nft_exthdr.c b/net/netfilter/nft_exthdr.c
index c308920b194c..9137721dd3b4 100644
--- a/net/netfilter/nft_exthdr.c
+++ b/net/netfilter/nft_exthdr.c
@@ -225,7 +225,7 @@ nft_exthdr_select_ops(const struct nft_ctx *ctx,
 
 static struct nft_expr_type nft_exthdr_type __read_mostly = {
 	.name		= "exthdr",
-	.select_ops	= &nft_exthdr_select_ops,
+	.select_ops	= nft_exthdr_select_ops,
 	.policy		= nft_exthdr_policy,
 	.maxattr	= NFTA_EXTHDR_MAX,
 	.owner		= THIS_MODULE,
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 7b60e01f38ff..f2520a6a388d 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -471,7 +471,7 @@ nft_meta_select_ops(const struct nft_ctx *ctx,
 
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
2.11.0
