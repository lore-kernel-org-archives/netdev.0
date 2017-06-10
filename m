From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next] Remove the redundant skb->dev initialization in ip6_fragment
Date: Sat, 10 Jun 2017 12:35:38 -0700
Message-ID: <1497123338-16571-1-git-send-email-chenbofeng.kernel@gmail.com>
Cc: Lorenzo Colitti <lorenzo@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Chenbo Feng <fengc@google.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33073 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751137AbdFJTfq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 15:35:46 -0400
Received: by mail-pf0-f196.google.com with SMTP id w12so2096154pfk.0
        for <netdev@vger.kernel.org>; Sat, 10 Jun 2017 12:35:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <fengc@google.com>

After moves the skb->dev and skb->protocol initialization into
ip6_output, setting the skb->dev inside ip6_fragment is unnecessary.

Fixes: 97a7a37a7b7b("ipv6: Initial skb->dev and skb->protocol in ip6_output")
Signed-off-by: Chenbo Feng <fengc@google.com>
---
 net/ipv6/ip6_output.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 02cd44f..0d6f3b6 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -869,7 +869,6 @@ int ip6_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 	if (skb->sk && dst_allfrag(skb_dst(skb)))
 		sk_nocaps_add(skb->sk, NETIF_F_GSO_MASK);
 
-	skb->dev = skb_dst(skb)->dev;
 	icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 	err = -EMSGSIZE;
 
-- 
2.7.4
