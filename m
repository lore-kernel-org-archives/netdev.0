From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net 1/2] geneve: Set GSO type on transmit.
Date: Mon,  3 Nov 2014 19:38:37 -0800
Message-ID: <1415072318-64442-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog130.obsmtp.com ([74.125.149.143]:53973 "HELO
	na3sys009aog130.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751460AbaKDDpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 22:45:18 -0500
Received: by mail-pa0-f42.google.com with SMTP id bj1so13624364pad.29
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 19:45:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Geneve does not currently set the inner protocol type when
transmitting packets. This causes GSO segmentation to fail on NICs
that do not support Geneve offloading.

CC: Andy Zhou <azhou@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/ipv4/geneve.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
index 065cd94..6e5266c 100644
--- a/net/ipv4/geneve.c
+++ b/net/ipv4/geneve.c
@@ -144,6 +144,8 @@ int geneve_xmit_skb(struct geneve_sock *gs, struct rtable *rt,
 	gnvh = (struct genevehdr *)__skb_push(skb, sizeof(*gnvh) + opt_len);
 	geneve_build_header(gnvh, tun_flags, vni, opt_len, opt);
 
+	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
+
 	return udp_tunnel_xmit_skb(gs->sock, rt, skb, src, dst,
 				   tos, ttl, df, src_port, dst_port, xnet);
 }
-- 
1.9.1
