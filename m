From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ip_gre: fix a possible crash in ipgre_err()
Date: Sat, 18 May 2013 11:36:03 -0700
Message-ID: <1368902163.3301.156.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:54934 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752590Ab3ERSgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 May 2013 14:36:05 -0400
Received: by mail-pd0-f169.google.com with SMTP id y10so3536204pdj.14
        for <netdev@vger.kernel.org>; Sat, 18 May 2013 11:36:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Another fix needed in ipgre_err(), as parse_gre_header() might change
skb->head.

Bug added in commit c54419321455 (GRE: Refactor GRE tunneling code.)

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
---
 net/ipv4/ip_gre.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index c625e4d..2a83591 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -235,7 +235,7 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 	   */
 	struct net *net = dev_net(skb->dev);
 	struct ip_tunnel_net *itn;
-	const struct iphdr *iph = (const struct iphdr *)skb->data;
+	const struct iphdr *iph;
 	const int type = icmp_hdr(skb)->type;
 	const int code = icmp_hdr(skb)->code;
 	struct ip_tunnel *t;
@@ -281,6 +281,7 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 	else
 		itn = net_generic(net, ipgre_net_id);
 
+	iph = (const struct iphdr *)skb->data;
 	t = ip_tunnel_lookup(itn, skb->dev->ifindex, tpi.flags,
 			     iph->daddr, iph->saddr, tpi.key);
 
