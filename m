From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 51/62: iptables: remove unused function arguments
Date: Tue, 16 Feb 2010 15:56:29 +0100 (MET)
Message-ID: <20100216145626.2796.63096.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52096 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932753Ab0BPO4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:56:30 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit fa96a0e2e67fe34a3d994e3f354a5c229dd14286
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Sun Nov 1 00:36:40 2009 +0100

    netfilter: iptables: remove unused function arguments
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index c833330..b9b8346 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -36,11 +36,7 @@ static const struct xt_table packet_mangler = {
 };
 
 static unsigned int
-ipt_local_hook(unsigned int hook,
-		   struct sk_buff *skb,
-		   const struct net_device *in,
-		   const struct net_device *out,
-		   int (*okfn)(struct sk_buff *))
+ipt_mangle_out(struct sk_buff *skb, const struct net_device *out)
 {
 	unsigned int ret;
 	const struct iphdr *iph;
@@ -60,7 +56,7 @@ ipt_local_hook(unsigned int hook,
 	daddr = iph->daddr;
 	tos = iph->tos;
 
-	ret = ipt_do_table(skb, hook, in, out,
+	ret = ipt_do_table(skb, NF_INET_LOCAL_OUT, NULL, out,
 			   dev_net(out)->ipv4.iptable_mangle);
 	/* Reroute for ANY change. */
 	if (ret != NF_DROP && ret != NF_STOLEN && ret != NF_QUEUE) {
@@ -86,7 +82,7 @@ iptable_mangle_hook(unsigned int hook,
 		     int (*okfn)(struct sk_buff *))
 {
 	if (hook == NF_INET_LOCAL_OUT)
-		return ipt_local_hook(hook, skb, in, out, okfn);
+		return ipt_mangle_out(skb, out);
 	if (hook == NF_INET_POST_ROUTING)
 		return ipt_do_table(skb, hook, in, out,
 				    dev_net(out)->ipv4.iptable_mangle);
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index b6216de..7844e55 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -30,12 +30,8 @@ static const struct xt_table packet_mangler = {
 };
 
 static unsigned int
-ip6t_local_out_hook(unsigned int hook,
-		   struct sk_buff *skb,
-		   const struct net_device *out,
-		   int (*okfn)(struct sk_buff *))
+ip6t_mangle_out(struct sk_buff *skb, const struct net_device *out)
 {
-
 	unsigned int ret;
 	struct in6_addr saddr, daddr;
 	u_int8_t hop_limit;
@@ -60,7 +56,7 @@ ip6t_local_out_hook(unsigned int hook,
 	/* flowlabel and prio (includes version, which shouldn't change either */
 	flowlabel = *((u_int32_t *)ipv6_hdr(skb));
 
-	ret = ip6t_do_table(skb, hook, NULL, out,
+	ret = ip6t_do_table(skb, NF_INET_LOCAL_OUT, NULL, out,
 			    dev_net(out)->ipv6.ip6table_mangle);
 
 	if (ret != NF_DROP && ret != NF_STOLEN &&
@@ -80,7 +76,7 @@ ip6table_mangle_hook(unsigned int hook, struct sk_buff *skb,
 		     int (*okfn)(struct sk_buff *))
 {
 	if (hook == NF_INET_LOCAL_OUT)
-		return ip6t_local_out_hook(hook, skb, out, okfn);
+		return ip6t_mangle_out(skb, out);
 	if (hook == NF_INET_POST_ROUTING)
 		return ip6t_do_table(skb, hook, in, out,
 				     dev_net(out)->ipv6.ip6table_mangle);
