From: Ying Cai <ycai@google.com>
Subject: [PATCH net] ip_tunnel: Set network header properly for IP_ECN_decapsulate()
Date: Sat, 3 May 2014 12:22:52 -0700
Message-ID: <CAL1qit8_M+D_GM9EPeUUBgPdpHNANXeZjGO1vJ6NOS9OUhEZMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:33655 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbaECTWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2014 15:22:53 -0400
Received: by mail-qc0-f172.google.com with SMTP id l6so1458717qcy.31
        for <netdev@vger.kernel.org>; Sat, 03 May 2014 12:22:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ip_tunnel_rcv(), set skb->network_header to inner IP header
before IP_ECN_decapsulate().

Without the fix, IP_ECN_decapsulate() takes outer IP header as
inner IP header, possibly causing error messages or packet drops.
---
 net/ipv4/ip_tunnel.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index fa5b751..b3f8597 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -442,6 +442,8 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct
sk_buff *skb,
                tunnel->i_seqno = ntohl(tpi->seq) + 1;
        }

+       skb_reset_network_header(skb);
+
        err = IP_ECN_decapsulate(iph, skb);
        if (unlikely(err)) {
                if (log_ecn_error)
--
1.9.1.423.g4596e3a
