From: pablo@netfilter.org
Subject: [PATCH 22/25] netfilter: bridge: switch hook PFs to nfproto
Date: Mon, 11 Jun 2012 16:43:58 +0200
Message-ID: <1339425841-24171-23-git-send-email-pablo@netfilter.org>
References: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alban Crequy <alban.crequy@collabora.co.uk>

This patch is a cleanup. Use NFPROTO_* for consistency with other
netfilter code.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
Reviewed-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Reviewed-by: Vincent Sanders <vincent.sanders@collabora.co.uk>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_netfilter.c |   28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index e41456b..20fa719 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -764,9 +764,9 @@ static unsigned int br_nf_forward_ip(unsigned int hook, struct sk_buff *skb,
 		return NF_DROP;
 
 	if (IS_IP(skb) || IS_VLAN_IP(skb) || IS_PPPOE_IP(skb))
-		pf = PF_INET;
+		pf = NFPROTO_IPV4;
 	else if (IS_IPV6(skb) || IS_VLAN_IPV6(skb) || IS_PPPOE_IPV6(skb))
-		pf = PF_INET6;
+		pf = NFPROTO_IPV6;
 	else
 		return NF_ACCEPT;
 
@@ -778,13 +778,13 @@ static unsigned int br_nf_forward_ip(unsigned int hook, struct sk_buff *skb,
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
@@ -871,9 +871,9 @@ static unsigned int br_nf_post_routing(unsigned int hook, struct sk_buff *skb,
 		return NF_DROP;
 
 	if (IS_IP(skb) || IS_VLAN_IP(skb) || IS_PPPOE_IP(skb))
-		pf = PF_INET;
+		pf = NFPROTO_IPV4;
 	else if (IS_IPV6(skb) || IS_VLAN_IPV6(skb) || IS_PPPOE_IPV6(skb))
-		pf = PF_INET6;
+		pf = NFPROTO_IPV6;
 	else
 		return NF_ACCEPT;
 
@@ -886,7 +886,7 @@ static unsigned int br_nf_post_routing(unsigned int hook, struct sk_buff *skb,
 
 	nf_bridge_pull_encap_header(skb);
 	nf_bridge_save_header(skb);
-	if (pf == PF_INET)
+	if (pf == NFPROTO_IPV4)
 		skb->protocol = htons(ETH_P_IP);
 	else
 		skb->protocol = htons(ETH_P_IPV6);
@@ -919,49 +919,49 @@ static struct nf_hook_ops br_nf_ops[] __read_mostly = {
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
1.7.10

