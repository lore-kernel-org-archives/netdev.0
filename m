From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/29: arptable_filter: merge forward hook
Date: Thu, 27 Nov 2008 17:15:07 +0100 (MET)
Message-ID: <20081127161507.13891.21215.sendpatchset@x2.localnet>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53360 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752401AbYK0QPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 11:15:08 -0500
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 19223f26d97077da8cf25251458afe00cae20cbb
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Tue Nov 4 14:22:13 2008 +0100

    netfilter: arptable_filter: merge forward hook
    
    It's identical to NF_ARP_IN hook.
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/arptable_filter.c b/net/ipv4/netfilter/arptable_filter.c
index bee3d11..e091187 100644
--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -75,16 +75,6 @@ static unsigned int arpt_out_hook(unsigned int hook,
 			     dev_net(out)->ipv4.arptable_filter);
 }
 
-static unsigned int arpt_forward_hook(unsigned int hook,
-				      struct sk_buff *skb,
-				      const struct net_device *in,
-				      const struct net_device *out,
-				      int (*okfn)(struct sk_buff *))
-{
-	return arpt_do_table(skb, hook, in, out,
-			     dev_net(in)->ipv4.arptable_filter);
-}
-
 static struct nf_hook_ops arpt_ops[] __read_mostly = {
 	{
 		.hook		= arpt_in_hook,
@@ -101,7 +91,7 @@ static struct nf_hook_ops arpt_ops[] __read_mostly = {
 		.priority	= NF_IP_PRI_FILTER,
 	},
 	{
-		.hook		= arpt_forward_hook,
+		.hook		= arpt_in_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_ARP,
 		.hooknum	= NF_ARP_FORWARD,
