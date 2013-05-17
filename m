From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: small skb_segment() cleanup
Date: Fri, 17 May 2013 10:13:24 -0700
Message-ID: <1368810804.3301.100.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:42758 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755940Ab3EQRNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 13:13:25 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz10so3771871pad.2
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 10:13:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

if (cond) {
	...
	__skb_put(nskb, doffset);
} else {
	...
	__skb_put(nskb, doffset);
}

can be simplified to

if (cond) {
	...
} else {
	...
}
__skb_put(nskb, doffset);


Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/skbuff.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index af9185d..87b5814 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2817,7 +2817,6 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 
 			nskb->truesize += skb_end_offset(nskb) - hsize;
 			skb_release_head_state(nskb);
-			__skb_push(nskb, doffset);
 		} else {
 			nskb = __alloc_skb(hsize + doffset + headroom,
 					   GFP_ATOMIC, skb_alloc_rx_flag(skb),
@@ -2827,8 +2826,8 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 				goto err;
 
 			skb_reserve(nskb, headroom);
-			__skb_put(nskb, doffset);
 		}
+		__skb_put(nskb, doffset);
 
 		if (segs)
 			tail->next = nskb;
