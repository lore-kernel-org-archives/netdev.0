From: pablo@netfilter.org
Subject: [PATCH 1/5] netfilter: xt_LOG: use CONFIG_IP6_NF_IPTABLES instead of CONFIG_IPV6
Date: Fri, 23 Mar 2012 10:34:13 +0100
Message-ID: <1332495257-3149-2-git-send-email-pablo@netfilter.org>
References: <1332495257-3149-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1332495257-3149-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This fixes the following linking error:

xt_LOG.c:(.text+0x789b1): undefined reference to `ip6t_ext_hdr'

ifdefs have to use CONFIG_IP6_NF_IPTABLES instead of CONFIG_IPV6.

Acked-by: Randy Dunlap <rdunlap@xenotime.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_LOG.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
index f99f8de..ff5f75f 100644
--- a/net/netfilter/xt_LOG.c
+++ b/net/netfilter/xt_LOG.c
@@ -480,7 +480,7 @@ ipt_log_packet(u_int8_t pf,
 	sb_close(m);
 }
 
-#if IS_ENABLED(CONFIG_IPV6)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 /* One level of recursion won't kill us */
 static void dump_ipv6_packet(struct sbuff *m,
 			const struct nf_loginfo *info,
@@ -824,7 +824,7 @@ log_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	if (par->family == NFPROTO_IPV4)
 		ipt_log_packet(NFPROTO_IPV4, par->hooknum, skb, par->in,
 			       par->out, &li, loginfo->prefix);
-#if IS_ENABLED(CONFIG_IPV6)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	else if (par->family == NFPROTO_IPV6)
 		ip6t_log_packet(NFPROTO_IPV6, par->hooknum, skb, par->in,
 				par->out, &li, loginfo->prefix);
@@ -864,7 +864,7 @@ static struct xt_target log_tg_regs[] __read_mostly = {
 		.checkentry	= log_tg_check,
 		.me		= THIS_MODULE,
 	},
-#if IS_ENABLED(CONFIG_IPV6)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	{
 		.name		= "LOG",
 		.family		= NFPROTO_IPV6,
@@ -882,7 +882,7 @@ static struct nf_logger ipt_log_logger __read_mostly = {
 	.me		= THIS_MODULE,
 };
 
-#if IS_ENABLED(CONFIG_IPV6)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 static struct nf_logger ip6t_log_logger __read_mostly = {
 	.name		= "ip6t_LOG",
 	.logfn		= &ip6t_log_packet,
@@ -899,7 +899,7 @@ static int __init log_tg_init(void)
 		return ret;
 
 	nf_log_register(NFPROTO_IPV4, &ipt_log_logger);
-#if IS_ENABLED(CONFIG_IPV6)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	nf_log_register(NFPROTO_IPV6, &ip6t_log_logger);
 #endif
 	return 0;
@@ -908,7 +908,7 @@ static int __init log_tg_init(void)
 static void __exit log_tg_exit(void)
 {
 	nf_log_unregister(&ipt_log_logger);
-#if IS_ENABLED(CONFIG_IPV6)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	nf_log_unregister(&ip6t_log_logger);
 #endif
 	xt_unregister_targets(log_tg_regs, ARRAY_SIZE(log_tg_regs));
-- 
1.7.2.5

