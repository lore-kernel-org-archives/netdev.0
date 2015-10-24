From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv6: gre: support SIT encapsulation
Date: Sat, 24 Oct 2015 05:47:44 -0700
Message-ID: <1445690864.22974.199.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35444 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461AbbJXMrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2015 08:47:46 -0400
Received: by pasz6 with SMTP id z6so142351096pas.2
        for <netdev@vger.kernel.org>; Sat, 24 Oct 2015 05:47:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

gre_gso_segment() chokes if SIT frames were aggregated by GRO engine.

Fixes: 61c1db7fae21e ("ipv6: sit: add GSO/TSO support")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/gre_offload.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index 5aa46d4b44ef..5a8ee3282550 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -36,7 +36,8 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 				  SKB_GSO_TCP_ECN |
 				  SKB_GSO_GRE |
 				  SKB_GSO_GRE_CSUM |
-				  SKB_GSO_IPIP)))
+				  SKB_GSO_IPIP |
+				  SKB_GSO_SIT)))
 		goto out;
 
 	if (!skb->encapsulation)
