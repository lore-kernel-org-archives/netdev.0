From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] Revert "ipv6: Initial skb->dev and
 skb->protocol in ip6_output"
Date: Sat, 10 Jun 2017 07:55:47 -0700
Message-ID: <1497106547.736.104.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1497038162-10327-1-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Lorenzo Colitti <lorenzo@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33340 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751958AbdFJOzw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 10:55:52 -0400
Received: by mail-pf0-f193.google.com with SMTP id w12so1635215pfk.0
        for <netdev@vger.kernel.org>; Sat, 10 Jun 2017 07:55:52 -0700 (PDT)
In-Reply-To: <1497038162-10327-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-06-09 at 12:56 -0700, Chenbo Feng wrote:
> From: Chenbo Feng <fengc@google.com>
> 
> This reverts commit 97a7a37a7b7b("ipv6: Initial skb->dev and
> skb->protocol in ip6_output") since it does not handles the
> skb->dev assignment inside ip6_fragment() code path properly.
> Need to rework and upload again

We can avoid the revert I believe the patch is fine after analysis.

Please submit this followup, thanks ! :

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 02cd44f0953900108701895108b2fdaa9f9980e5..0d6f3b6345de26c329ae1d6f25dde652a5452d4b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -869,7 +869,6 @@ int ip6_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 	if (skb->sk && dst_allfrag(skb_dst(skb)))
 		sk_nocaps_add(skb->sk, NETIF_F_GSO_MASK);
 
-	skb->dev = skb_dst(skb)->dev;
 	icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 	err = -EMSGSIZE;
 
