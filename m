From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/47] netfilter: nf_hook_ops structs can be const
Date: Mon,  4 Sep 2017 00:27:12 +0200
Message-ID: <1504477667-12130-3-git-send-email-pablo@netfilter.org>
References: <1504477667-12130-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51138 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753182AbdICW2G (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:28:06 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 6DA81190F60
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:27:39 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 57E4DB502A
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:27:39 +0200 (CEST)
In-Reply-To: <1504477667-12130-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

We no longer place these on a list so they can be const.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 drivers/net/ipvlan/ipvlan_main.c               | 2 +-
 net/bridge/br_netfilter_hooks.c                | 2 +-
 net/bridge/netfilter/ebtable_filter.c          | 2 +-
 net/bridge/netfilter/ebtable_nat.c             | 2 +-
 net/decnet/netfilter/dn_rtmsg.c                | 2 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c             | 2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c              | 2 +-
 net/ipv4/netfilter/iptable_nat.c               | 2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c | 2 +-
 net/ipv4/netfilter/nf_defrag_ipv4.c            | 2 +-
 net/ipv6/ila/ila_xlat.c                        | 2 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c             | 2 +-
 net/ipv6/netfilter/ip6table_nat.c              | 2 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c | 2 +-
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      | 2 +-
 net/netfilter/ipvs/ip_vs_core.c                | 2 +-
 security/selinux/hooks.c                       | 2 +-
 security/smack/smack_netfilter.c               | 2 +-
 18 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index fdde20735416..943e6907dc19 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -15,7 +15,7 @@ struct ipvlan_netns {
 	unsigned int ipvl_nf_hook_refcnt;
 };
 
-static struct nf_hook_ops ipvl_nfops[] __read_mostly = {
+static const struct nf_hook_ops ipvl_nfops[] = {
 	{
 		.hook     = ipvlan_nf_input,
 		.pf       = NFPROTO_IPV4,
diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 2261e5194c82..626f4b2cef16 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -887,7 +887,7 @@ EXPORT_SYMBOL_GPL(br_netfilter_enable);
 
 /* For br_nf_post_routing, we need (prio = NF_BR_PRI_LAST), because
  * br_dev_queue_push_xmit is called afterwards */
-static struct nf_hook_ops br_nf_ops[] __read_mostly = {
+static const struct nf_hook_ops br_nf_ops[] = {
 	{
 		.hook = br_nf_pre_routing,
 		.pf = NFPROTO_BRIDGE,
diff --git a/net/bridge/netfilter/ebtable_filter.c b/net/bridge/netfilter/ebtable_filter.c
index f22ef7c21913..45a00dbdbcad 100644
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -70,7 +70,7 @@ ebt_out_hook(void *priv, struct sk_buff *skb,
 	return ebt_do_table(skb, state, state->net->xt.frame_filter);
 }
 
-static struct nf_hook_ops ebt_ops_filter[] __read_mostly = {
+static const struct nf_hook_ops ebt_ops_filter[] = {
 	{
 		.hook		= ebt_in_hook,
 		.pf		= NFPROTO_BRIDGE,
diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index 2f7a4f314406..4ecf50662b7d 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -70,7 +70,7 @@ ebt_nat_out(void *priv, struct sk_buff *skb,
 	return ebt_do_table(skb, state, state->net->xt.frame_nat);
 }
 
-static struct nf_hook_ops ebt_ops_nat[] __read_mostly = {
+static const struct nf_hook_ops ebt_ops_nat[] = {
 	{
 		.hook		= ebt_nat_out,
 		.pf		= NFPROTO_BRIDGE,
diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index aa8ffecc46a4..ab395e55cd78 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -115,7 +115,7 @@ static inline void dnrmg_receive_user_skb(struct sk_buff *skb)
 	RCV_SKB_FAIL(-EINVAL);
 }
 
-static struct nf_hook_ops dnrmg_ops __read_mostly = {
+static const struct nf_hook_ops dnrmg_ops = {
 	.hook		= dnrmg_hook,
 	.pf		= NFPROTO_DECNET,
 	.hooknum	= NF_DN_ROUTE,
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 7d72decb80f9..6637e8b37ee2 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -624,7 +624,7 @@ arp_mangle(void *priv,
 	return NF_ACCEPT;
 }
 
-static struct nf_hook_ops cip_arp_ops __read_mostly = {
+static const struct nf_hook_ops cip_arp_ops = {
 	.hook = arp_mangle,
 	.pf = NFPROTO_ARP,
 	.hooknum = NF_ARP_OUT,
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index f1528f7175a8..811689e523c3 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -416,7 +416,7 @@ static unsigned int ipv4_synproxy_hook(void *priv,
 	return NF_ACCEPT;
 }
 
-static struct nf_hook_ops ipv4_synproxy_ops[] __read_mostly = {
+static const struct nf_hook_ops ipv4_synproxy_ops[] = {
 	{
 		.hook		= ipv4_synproxy_hook,
 		.pf		= NFPROTO_IPV4,
diff --git a/net/ipv4/netfilter/iptable_nat.c b/net/ipv4/netfilter/iptable_nat.c
index 138a24bc76ad..a1a07b338ccf 100644
--- a/net/ipv4/netfilter/iptable_nat.c
+++ b/net/ipv4/netfilter/iptable_nat.c
@@ -67,7 +67,7 @@ static unsigned int iptable_nat_ipv4_local_fn(void *priv,
 	return nf_nat_ipv4_local_fn(priv, skb, state, iptable_nat_do_chain);
 }
 
-static struct nf_hook_ops nf_nat_ipv4_ops[] __read_mostly = {
+static const struct nf_hook_ops nf_nat_ipv4_ops[] = {
 	/* Before packet filtering, change destination */
 	{
 		.hook		= iptable_nat_ipv4_in,
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 2e14ed11a35c..63e4ea0e01f8 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -174,7 +174,7 @@ static unsigned int ipv4_conntrack_local(void *priv,
 
 /* Connection tracking may drop packets, but never alters them, so
    make it the first hook. */
-static struct nf_hook_ops ipv4_conntrack_ops[] __read_mostly = {
+static const struct nf_hook_ops ipv4_conntrack_ops[] = {
 	{
 		.hook		= ipv4_conntrack_in,
 		.pf		= NFPROTO_IPV4,
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index 346bf7ccac08..37fe1616ca0b 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -90,7 +90,7 @@ static unsigned int ipv4_conntrack_defrag(void *priv,
 	return NF_ACCEPT;
 }
 
-static struct nf_hook_ops ipv4_defrag_ops[] = {
+static const struct nf_hook_ops ipv4_defrag_ops[] = {
 	{
 		.hook		= ipv4_conntrack_defrag,
 		.pf		= NFPROTO_IPV4,
diff --git a/net/ipv6/ila/ila_xlat.c b/net/ipv6/ila/ila_xlat.c
index 77f7f8c7d93d..5bd419c1abc8 100644
--- a/net/ipv6/ila/ila_xlat.c
+++ b/net/ipv6/ila/ila_xlat.c
@@ -208,7 +208,7 @@ ila_nf_input(void *priv,
 	return NF_ACCEPT;
 }
 
-static struct nf_hook_ops ila_nf_hook_ops[] __read_mostly = {
+static const struct nf_hook_ops ila_nf_hook_ops[] = {
 	{
 		.hook = ila_nf_input,
 		.pf = NFPROTO_IPV6,
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index ce203dd729e0..a5cd43d75393 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -438,7 +438,7 @@ static unsigned int ipv6_synproxy_hook(void *priv,
 	return NF_ACCEPT;
 }
 
-static struct nf_hook_ops ipv6_synproxy_ops[] __read_mostly = {
+static const struct nf_hook_ops ipv6_synproxy_ops[] = {
 	{
 		.hook		= ipv6_synproxy_hook,
 		.pf		= NFPROTO_IPV6,
diff --git a/net/ipv6/netfilter/ip6table_nat.c b/net/ipv6/netfilter/ip6table_nat.c
index 7d2bd940291f..991512576c8c 100644
--- a/net/ipv6/netfilter/ip6table_nat.c
+++ b/net/ipv6/netfilter/ip6table_nat.c
@@ -69,7 +69,7 @@ static unsigned int ip6table_nat_local_fn(void *priv,
 	return nf_nat_ipv6_local_fn(priv, skb, state, ip6table_nat_do_chain);
 }
 
-static struct nf_hook_ops nf_nat_ipv6_ops[] __read_mostly = {
+static const struct nf_hook_ops nf_nat_ipv6_ops[] = {
 	/* Before packet filtering, change destination */
 	{
 		.hook		= ip6table_nat_in,
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 4e3402486833..f2d2f4a9294b 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -191,7 +191,7 @@ static unsigned int ipv6_conntrack_local(void *priv,
 	return nf_conntrack_in(state->net, PF_INET6, state->hook, skb);
 }
 
-static struct nf_hook_ops ipv6_conntrack_ops[] __read_mostly = {
+static const struct nf_hook_ops ipv6_conntrack_ops[] = {
 	{
 		.hook		= ipv6_conntrack_in,
 		.pf		= NFPROTO_IPV6,
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index ada60d1a991b..b326da59257f 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -74,7 +74,7 @@ static unsigned int ipv6_defrag(void *priv,
 	return err == 0 ? NF_ACCEPT : NF_DROP;
 }
 
-static struct nf_hook_ops ipv6_defrag_ops[] = {
+static const struct nf_hook_ops ipv6_defrag_ops[] = {
 	{
 		.hook		= ipv6_defrag,
 		.pf		= NFPROTO_IPV6,
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 2ff9d9070c95..5cb7cac9177d 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2101,7 +2101,7 @@ ip_vs_forward_icmp_v6(void *priv, struct sk_buff *skb,
 #endif
 
 
-static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
+static const struct nf_hook_ops ip_vs_ops[] = {
 	/* After packet filtering, change source only for VS/NAT */
 	{
 		.hook		= ip_vs_reply4,
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 33fd061305c4..2f2e1338cd3d 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -6530,7 +6530,7 @@ security_initcall(selinux_init);
 
 #if defined(CONFIG_NETFILTER)
 
-static struct nf_hook_ops selinux_nf_ops[] = {
+static const struct nf_hook_ops selinux_nf_ops[] = {
 	{
 		.hook =		selinux_ipv4_postroute,
 		.pf =		NFPROTO_IPV4,
diff --git a/security/smack/smack_netfilter.c b/security/smack/smack_netfilter.c
index cdeb0f3243dd..e36d17835d4f 100644
--- a/security/smack/smack_netfilter.c
+++ b/security/smack/smack_netfilter.c
@@ -58,7 +58,7 @@ static unsigned int smack_ipv4_output(void *priv,
 	return NF_ACCEPT;
 }
 
-static struct nf_hook_ops smack_nf_ops[] = {
+static const struct nf_hook_ops smack_nf_ops[] = {
 	{
 		.hook =		smack_ipv4_output,
 		.pf =		NFPROTO_IPV4,
-- 
2.1.4
