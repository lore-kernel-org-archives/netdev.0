From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: use skb_reset_mac_len() in dev_gro_receive()
Date: Thu, 14 Feb 2013 19:31:48 -0800
Message-ID: <1360899108.6884.77.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f177.google.com ([209.85.210.177]:40316 "EHLO
	mail-ia0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932322Ab3BODbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 22:31:50 -0500
Received: by mail-ia0-f177.google.com with SMTP id k38so2957186iah.36
        for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 19:31:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We no longer need to use mac_len, lets cleanup things.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f444736..09df22d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3784,7 +3784,6 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 	__be16 type = skb->protocol;
 	struct list_head *head = &offload_base;
 	int same_flow;
-	int mac_len;
 	enum gro_result ret;
 
 	if (!(skb->dev->features & NETIF_F_GRO) || netpoll_rx_on(skb))
@@ -3801,8 +3800,7 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 			continue;
 
 		skb_set_network_header(skb, skb_gro_offset(skb));
-		mac_len = skb->network_header - skb->mac_header;
-		skb->mac_len = mac_len;
+		skb_reset_mac_len(skb);
 		NAPI_GRO_CB(skb)->same_flow = 0;
 		NAPI_GRO_CB(skb)->flush = 0;
 		NAPI_GRO_CB(skb)->free = 0;
