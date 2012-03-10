From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: linux-next: Tree for Mar 9 (netfilter)
Date: Sat, 10 Mar 2012 12:21:54 +0100
Message-ID: <20120310112154.GA22478@1984>
References: <20120309191101.8634973f7d9988c602143f7c@canb.auug.org.au>
 <4F5A6872.3050502@xenotime.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="DocE+STaALJfprDB"
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F5A6872.3050502@xenotime.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Mar 09, 2012 at 12:30:42PM -0800, Randy Dunlap wrote:
> On 03/09/2012 12:11 AM, Stephen Rothwell wrote:
> 
> > Hi all,
> > 
> > There will be no linux-next release on March 12 due to a public holiday.
> > 
> > Changes since 20120308:
> 
> 
> xt_LOG.c:(.text+0x789b1): undefined reference to `ip6t_ext_hdr'
> 
> Full randconfig file is attached.

The patch attached fixes this problem, thanks!

--DocE+STaALJfprDB
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-xt_LOG-use-CONFIG_IP6_NF_IPTABLES-instead-.patch"

>From 56467b18daa0dcf92a680ea0bc5389108b83228a Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sat, 10 Mar 2012 12:15:15 +0100
Subject: [PATCH] netfilter: xt_LOG: use CONFIG_IP6_NF_IPTABLES instead of
 CONFIG_IPV6

This fixes the following linking error:

xt_LOG.c:(.text+0x789b1): undefined reference to `ip6t_ext_hdr'

ifdefs have to use CONFIG_IP6_NF_IPTABLES instead of CONFIG_IPV6.

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
1.7.7.3


--DocE+STaALJfprDB--
