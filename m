From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] netns: correct mib stats in ip6_route_me_harder()
Date: Wed, 15 Oct 2008 08:12:26 +0400
Message-ID: <20081015041226.GA24058@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, den@openvz.org, kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:11215 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbYJOEJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2008 00:09:31 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1134381nfc.21
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 21:09:29 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv6/netfilter.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -12,6 +12,7 @@
 
 int ip6_route_me_harder(struct sk_buff *skb)
 {
+	struct net *net = dev_net(skb->dst->dev);
 	struct ipv6hdr *iph = ipv6_hdr(skb);
 	struct dst_entry *dst;
 	struct flowi fl = {
@@ -23,7 +24,7 @@ int ip6_route_me_harder(struct sk_buff *skb)
 		    .saddr = iph->saddr, } },
 	};
 
-	dst = ip6_route_output(dev_net(skb->dst->dev), skb->sk, &fl);
+	dst = ip6_route_output(net, skb->sk, &fl);
 
 #ifdef CONFIG_XFRM
 	if (!(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
@@ -33,8 +34,7 @@ int ip6_route_me_harder(struct sk_buff *skb)
 #endif
 
 	if (dst->error) {
-		IP6_INC_STATS(&init_net, ip6_dst_idev(dst),
-			      IPSTATS_MIB_OUTNOROUTES);
+		IP6_INC_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
 		LIMIT_NETDEBUG(KERN_DEBUG "ip6_route_me_harder: No more route.\n");
 		dst_release(dst);
 		return -EINVAL;
