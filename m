From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 1/4] ip_tunnel: Account for secondary encapsulation header in max_headroom
Date: Wed,  1 Oct 2014 21:46:36 -0700
Message-ID: <1412225199-24942-2-git-send-email-therbert@google.com>
References: <1412225199-24942-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:40245 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751992AbaJBErE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 00:47:04 -0400
Received: by mail-pd0-f170.google.com with SMTP id p10so1432280pdj.29
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 21:47:03 -0700 (PDT)
In-Reply-To: <1412225199-24942-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When adjusting max_header for the tunnel interface based on egress
device we need to account for any extra bytes in secondary encapsulation
(e.g. FOU).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/ip_tunnel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index b75b47b..54ace25 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -759,7 +759,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		df |= (inner_iph->frag_off&htons(IP_DF));
 
 	max_headroom = LL_RESERVED_SPACE(rt->dst.dev) + sizeof(struct iphdr)
-			+ rt->dst.header_len;
+			+ rt->dst.header_len + ip_encap_hlen(&tunnel->encap);
 	if (max_headroom > dev->needed_headroom)
 		dev->needed_headroom = max_headroom;
 
-- 
2.1.0.rc2.206.gedb03e5
