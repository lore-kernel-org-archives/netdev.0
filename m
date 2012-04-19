From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] netlink: dont drop packet but consume it
Date: Thu, 19 Apr 2012 14:24:28 +0200
Message-ID: <1334838268.2395.151.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:38632 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754453Ab2DSMYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 08:24:32 -0400
Received: by eekc41 with SMTP id c41so2207028eek.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 05:24:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When we need to clone skb, we dont drop a packet.
Call consume_skb() to not confuse dropwatch.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/netlink/af_netlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index faa48f7..da87214 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -866,7 +866,7 @@ static struct sk_buff *netlink_trim(struct sk_buff *skb, gfp_t allocation)
 		struct sk_buff *nskb = skb_clone(skb, allocation);
 		if (!nskb)
 			return skb;
-		kfree_skb(skb);
+		consume_skb(skb);
 		skb = nskb;
 	}
 
