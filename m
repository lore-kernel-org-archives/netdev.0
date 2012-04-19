From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] packet: dont drop packet but consume it
Date: Thu, 19 Apr 2012 14:24:42 +0200
Message-ID: <1334838282.2395.153.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:51492 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639Ab2DSMYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 08:24:46 -0400
Received: by mail-bk0-f46.google.com with SMTP id ik5so6293431bkc.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 05:24:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When we need to clone skb, we dont drop a packet.
Call consume_skb() to not confuse dropwatch.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/packet/af_packet.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index d2b5f65..40053a0 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1654,7 +1654,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 			skb->data = skb_head;
 			skb->len = skb_len;
 		}
-		kfree_skb(skb);
+		consume_skb(skb);
 		skb = nskb;
 	}
 
