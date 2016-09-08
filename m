From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ip_tunnel: do not clear l4 hashes
Date: Thu, 08 Sep 2016 15:40:48 -0700
Message-ID: <1473374448.18970.17.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33378 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751143AbcIHWkv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 18:40:51 -0400
Received: by mail-pf0-f193.google.com with SMTP id 128so3056285pfb.0
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 15:40:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

If skb has a valid l4 hash, there is no point clearing hash and force
a further flow dissection when a tunnel encapsulation is added.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/ip_tunnel_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 0f227db0e9ac..777bc1883870 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -69,7 +69,7 @@ void iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 
 	skb_scrub_packet(skb, xnet);
 
-	skb_clear_hash(skb);
+	skb_clear_hash_if_not_l4(skb);
 	skb_dst_set(skb, &rt->dst);
 	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 
