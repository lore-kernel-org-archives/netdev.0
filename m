From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ip6_tunnel: dont drop packet but consume it
Date: Thu, 19 Apr 2012 14:24:17 +0200
Message-ID: <1334838257.2395.150.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:51492 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639Ab2DSMYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 08:24:22 -0400
Received: by bkcik5 with SMTP id ik5so6293431bkc.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 05:24:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When we need to reallocate skb, we dont drop a packet.
Call consume_skb() to not confuse dropwatch.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/ip6_tunnel.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index e25b0fd..5df487c 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -954,7 +954,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 
 		if (skb->sk)
 			skb_set_owner_w(new_skb, skb->sk);
-		kfree_skb(skb);
+		consume_skb(skb);
 		skb = new_skb;
 	}
 	skb_dst_drop(skb);
