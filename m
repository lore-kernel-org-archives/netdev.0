From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: dsa: use consume_skb()
Date: Wed, 23 Aug 2017 21:40:32 -0700
Message-ID: <1503549632.2499.77.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170822221215.16305-1-f.fainelli@gmail.com>
         <20170823.203725.2147193612476095021.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        vivien.didelot@savoirfairelinux.com, Woojung.Huh@microchip.com,
        UNGLinuxDriver@microchip.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:38675 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751262AbdHXEke (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 00:40:34 -0400
Received: by mail-pg0-f65.google.com with SMTP id u9so2165673pgn.5
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 21:40:34 -0700 (PDT)
In-Reply-To: <20170823.203725.2147193612476095021.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Two kfree_skb() should be consume_skb(), to be friend with drop monitor
(perf record ... -e skb:kfree_skb)

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/dsa/tag_ksz.c     |    2 +-
 net/dsa/tag_trailer.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c
index 3bd6e2a83125..fcd90f79458e 100644
--- a/net/dsa/tag_ksz.c
+++ b/net/dsa/tag_ksz.c
@@ -67,7 +67,7 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (skb_put_padto(nskb, nskb->len + padlen))
 			return NULL;
 
-		kfree_skb(skb);
+		consume_skb(skb);
 	}
 
 	tag = skb_put(nskb, KSZ_INGRESS_TAG_LEN);
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index b09e56214005..9c7b1d74a5c6 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -40,7 +40,7 @@ static struct sk_buff *trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_set_network_header(nskb, skb_network_header(skb) - skb->head);
 	skb_set_transport_header(nskb, skb_transport_header(skb) - skb->head);
 	skb_copy_and_csum_dev(skb, skb_put(nskb, skb->len));
-	kfree_skb(skb);
+	consume_skb(skb);
 
 	if (padlen) {
 		skb_put_zero(nskb, padlen);
