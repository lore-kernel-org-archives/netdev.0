From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 21/29: ip6table_filter: merge LOCAL_IN and FORWARD hooks
Date: Thu, 27 Nov 2008 17:15:31 +0100 (MET)
Message-ID: <20081127161531.13891.96645.sendpatchset@x2.localnet>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 61d3015808d877eb4ea225b5924feb128b0c1bc7
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Thu Nov 20 09:58:08 2008 +0100

    netfilter: ip6table_filter: merge LOCAL_IN and FORWARD hooks
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index b110a8a..40d2e36 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -61,7 +61,7 @@ static struct xt_table packet_filter = {
 
 /* The work comes in here from netfilter.c. */
 static unsigned int
-ip6t_local_in_hook(unsigned int hook,
+ip6t_in_hook(unsigned int hook,
 		   struct sk_buff *skb,
 		   const struct net_device *in,
 		   const struct net_device *out,
@@ -72,17 +72,6 @@ ip6t_local_in_hook(unsigned int hook,
 }
 
 static unsigned int
-ip6t_forward_hook(unsigned int hook,
-		  struct sk_buff *skb,
-		  const struct net_device *in,
-		  const struct net_device *out,
-		  int (*okfn)(struct sk_buff *))
-{
-	return ip6t_do_table(skb, hook, in, out,
-			     dev_net(in)->ipv6.ip6table_filter);
-}
-
-static unsigned int
 ip6t_local_out_hook(unsigned int hook,
 		   struct sk_buff *skb,
 		   const struct net_device *in,
@@ -105,14 +94,14 @@ ip6t_local_out_hook(unsigned int hook,
 
 static struct nf_hook_ops ip6t_ops[] __read_mostly = {
 	{
-		.hook		= ip6t_local_in_hook,
+		.hook		= ip6t_in_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_FILTER,
 	},
 	{
-		.hook		= ip6t_forward_hook,
+		.hook		= ip6t_in_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
 		.hooknum	= NF_INET_FORWARD,
