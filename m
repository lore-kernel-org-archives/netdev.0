From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 3/6] netfilter: bridge: switch hook PFs to nfproto
Date: Mon, 14 May 2012 14:56:36 +0100
Message-ID: <1337003799-2517-3-git-send-email-alban.crequy@collabora.co.uk>
References: <1337003799-2517-1-git-send-email-alban.crequy@collabora.co.uk>
Cc: Vincent Sanders <vincent.sanders@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Alban Crequy <alban.crequy@collabora.co.uk>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.135.160]:48690 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756740Ab2ENN5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 09:57:10 -0400
In-Reply-To: <1337003799-2517-1-git-send-email-alban.crequy@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NFPROTO_* constants were usually equal to PF_* constants but it is not
necessary and it will waste less memory if we don't do so (see commit 7e9c6e
"netfilter: Introduce NFPROTO_* constants")

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
Reviewed-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Reviewed-by: Vincent Sanders <vincent.sanders@collabora.co.uk>
---
 net/bridge/br_netfilter.c |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index d7f49b6..b8ba7d6 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -749,9 +749,9 @@ static unsigned int br_nf_forward_ip(unsigned int hook, struct sk_buff *skb,
 		return NF_DROP;
 
 	if (IS_IP(skb) || IS_VLAN_IP(skb) || IS_PPPOE_IP(skb))
-		pf = PF_INET;
+		pf = NFPROTO_IPV4;
 	else if (IS_IPV6(skb) || IS_VLAN_IPV6(skb) || IS_PPPOE_IPV6(skb))
-		pf = PF_INET6;
+		pf = NFPROTO_IPV6;
 	else
 		return NF_ACCEPT;
 
@@ -763,13 +763,13 @@ static unsigned int br_nf_forward_ip(unsigned int hook, struct sk_buff *skb,
 		nf_bridge->mask |= BRNF_PKT_TYPE;
 	}
 
-	if (pf == PF_INET && br_parse_ip_options(skb))
+	if (pf == NFPROTO_IPV4 && br_parse_ip_options(skb))
 		return NF_DROP;
 
 	/* The physdev module checks on this */
 	nf_bridge->mask |= BRNF_BRIDGED;
 	nf_bridge->physoutdev = skb->dev;
-	if (pf == PF_INET)
+	if (pf == NFPROTO_IPV4)
 		skb->protocol = htons(ETH_P_IP);
 	else
 		skb->protocol = htons(ETH_P_IPV6);
@@ -856,9 +856,9 @@ static unsigned int br_nf_post_routing(unsigned int hook, struct sk_buff *skb,
 		return NF_DROP;
 
 	if (IS_IP(skb) || IS_VLAN_IP(skb) || IS_PPPOE_IP(skb))
-		pf = PF_INET;
+		pf = NFPROTO_IPV4;
 	else if (IS_IPV6(skb) || IS_VLAN_IPV6(skb) || IS_PPPOE_IPV6(skb))
-		pf = PF_INET6;
+		pf = NFPROTO_IPV6;
 	else
 		return NF_ACCEPT;
 
@@ -871,7 +871,7 @@ static unsigned int br_nf_post_routing(unsigned int hook, struct sk_buff *skb,
 
 	nf_bridge_pull_encap_header(skb);
 	nf_bridge_save_header(skb);
-	if (pf == PF_INET)
+	if (pf == NFPROTO_IPV4)
 		skb->protocol = htons(ETH_P_IP);
 	else
 		skb->protocol = htons(ETH_P_IPV6);
@@ -904,49 +904,49 @@ static struct nf_hook_ops br_nf_ops[] __read_mostly = {
 	{
 		.hook = br_nf_pre_routing,
 		.owner = THIS_MODULE,
-		.pf = PF_BRIDGE,
+		.pf = NFPROTO_BRIDGE,
 		.hooknum = NF_BR_PRE_ROUTING,
 		.priority = NF_BR_PRI_BRNF,
 	},
 	{
 		.hook = br_nf_local_in,
 		.owner = THIS_MODULE,
-		.pf = PF_BRIDGE,
+		.pf = NFPROTO_BRIDGE,
 		.hooknum = NF_BR_LOCAL_IN,
 		.priority = NF_BR_PRI_BRNF,
 	},
 	{
 		.hook = br_nf_forward_ip,
 		.owner = THIS_MODULE,
-		.pf = PF_BRIDGE,
+		.pf = NFPROTO_BRIDGE,
 		.hooknum = NF_BR_FORWARD,
 		.priority = NF_BR_PRI_BRNF - 1,
 	},
 	{
 		.hook = br_nf_forward_arp,
 		.owner = THIS_MODULE,
-		.pf = PF_BRIDGE,
+		.pf = NFPROTO_BRIDGE,
 		.hooknum = NF_BR_FORWARD,
 		.priority = NF_BR_PRI_BRNF,
 	},
 	{
 		.hook = br_nf_post_routing,
 		.owner = THIS_MODULE,
-		.pf = PF_BRIDGE,
+		.pf = NFPROTO_BRIDGE,
 		.hooknum = NF_BR_POST_ROUTING,
 		.priority = NF_BR_PRI_LAST,
 	},
 	{
 		.hook = ip_sabotage_in,
 		.owner = THIS_MODULE,
-		.pf = PF_INET,
+		.pf = NFPROTO_IPV4,
 		.hooknum = NF_INET_PRE_ROUTING,
 		.priority = NF_IP_PRI_FIRST,
 	},
 	{
 		.hook = ip_sabotage_in,
 		.owner = THIS_MODULE,
-		.pf = PF_INET6,
+		.pf = NFPROTO_IPV6,
 		.hooknum = NF_INET_PRE_ROUTING,
 		.priority = NF_IP6_PRI_FIRST,
 	},
-- 
1.7.2.5
