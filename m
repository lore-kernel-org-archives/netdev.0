From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: netns nat: fixup DNAT in netns
Date: Mon, 21 Jul 2008 20:55:57 +0400
Message-ID: <20080721165557.GO13390@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	dev@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, benjamin.thery@bull.net
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:10803 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899AbYGUQ5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 12:57:45 -0400
Received: by ug-out-1314.google.com with SMTP id h2so277666ugf.16
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 09:57:44 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/netfilter/nf_nat_rule.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -91,13 +91,13 @@ static unsigned int ipt_snat_target(struct sk_buff *skb,
 }
 
 /* Before 2.6.11 we did implicit source NAT if required. Warn about change. */
-static void warn_if_extra_mangle(__be32 dstip, __be32 srcip)
+static void warn_if_extra_mangle(struct net *net, __be32 dstip, __be32 srcip)
 {
 	static int warned = 0;
 	struct flowi fl = { .nl_u = { .ip4_u = { .daddr = dstip } } };
 	struct rtable *rt;
 
-	if (ip_route_output_key(&init_net, &rt, &fl) != 0)
+	if (ip_route_output_key(net, &rt, &fl) != 0)
 		return;
 
 	if (rt->rt_src != srcip && !warned) {
@@ -130,7 +130,7 @@ static unsigned int ipt_dnat_target(struct sk_buff *skb,
 
 	if (hooknum == NF_INET_LOCAL_OUT &&
 	    mr->range[0].flags & IP_NAT_RANGE_MAP_IPS)
-		warn_if_extra_mangle(ip_hdr(skb)->daddr,
+		warn_if_extra_mangle(dev_net(out), ip_hdr(skb)->daddr,
 				     mr->range[0].min_ip);
 
 	return nf_nat_setup_info(ct, &mr->range[0], IP_NAT_MANIP_DST);
-- 
1.5.4.5


