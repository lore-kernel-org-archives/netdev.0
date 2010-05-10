From: kaber@trash.net
Subject: [PATCH 75/84] netfilter: xtables: remove old comments about reentrancy
Date: Mon, 10 May 2010 22:18:46 +0200
Message-ID: <1273522735-24672-76-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54523 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756739Ab0EJUT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:28 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ip_tables.c   |    2 --
 net/ipv4/netfilter/ipt_REJECT.c  |    3 ---
 net/ipv6/netfilter/ip6_tables.c  |    2 --
 net/ipv6/netfilter/ip6t_REJECT.c |    3 ---
 4 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 70900ec..bb5e0d9 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -434,8 +434,6 @@ ipt_do_table(struct sk_buff *skb,
 			continue;
 		}
 
-		/* Targets which reenter must return
-		   abs. verdicts */
 		tgpar.target   = t->u.kernel.target;
 		tgpar.targinfo = t->data;
 
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index b026014..038fa0b 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -139,9 +139,6 @@ reject_tg(struct sk_buff *skb, const struct xt_target_param *par)
 {
 	const struct ipt_reject_info *reject = par->targinfo;
 
-	/* WARNING: This code causes reentry within iptables.
-	   This means that the iptables jump stack is now crap.  We
-	   must return an absolute verdict. --RR */
 	switch (reject->with) {
 	case IPT_ICMP_NET_UNREACHABLE:
 		send_unreach(skb, ICMP_NET_UNREACH);
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 2a2770b..7afa117 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -451,8 +451,6 @@ ip6t_do_table(struct sk_buff *skb,
 			continue;
 		}
 
-		/* Targets which reenter must return
-		   abs. verdicts */
 		tgpar.target   = t->u.kernel.target;
 		tgpar.targinfo = t->data;
 
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index 55b9b2d..dad9762 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -179,9 +179,6 @@ reject_tg6(struct sk_buff *skb, const struct xt_target_param *par)
 	struct net *net = dev_net((par->in != NULL) ? par->in : par->out);
 
 	pr_debug("%s: medium point\n", __func__);
-	/* WARNING: This code causes reentry within ip6tables.
-	   This means that the ip6tables jump stack is now crap.  We
-	   must return an absolute verdict. --RR */
 	switch (reject->with) {
 	case IP6T_ICMP6_NO_ROUTE:
 		send_unreach(net, skb, ICMPV6_NOROUTE, par->hooknum);
-- 
1.7.0.4

