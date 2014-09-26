From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 5/5] vxlan: Set inner protocol before transmit
Date: Fri, 26 Sep 2014 09:22:34 -0700
Message-ID: <1411748554-7346-6-git-send-email-therbert@google.com>
References: <1411748554-7346-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:48367 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755253AbaIZQXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 12:23:05 -0400
Received: by mail-pd0-f182.google.com with SMTP id y10so1360533pdj.13
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 09:23:05 -0700 (PDT)
In-Reply-To: <1411748554-7346-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call skb_set_inner_protocol to set inner Ethernet protocol to
ETH_P_TEB before transmit. This is needed for GSO with UDP tunnels.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/vxlan.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 34e102e..2af795d 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1610,6 +1610,8 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 	vxh->vx_flags = htonl(VXLAN_FLAGS);
 	vxh->vx_vni = vni;
 
+	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
+
 	udp_tunnel6_xmit_skb(vs->sock, dst, skb, dev, saddr, daddr, prio,
 			     ttl, src_port, dst_port);
 	return 0;
@@ -1652,6 +1654,8 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 	vxh->vx_flags = htonl(VXLAN_FLAGS);
 	vxh->vx_vni = vni;
 
+	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
+
 	return udp_tunnel_xmit_skb(vs->sock, rt, skb, src, dst, tos,
 				   ttl, df, src_port, dst_port, xnet);
 }
-- 
2.1.0.rc2.206.gedb03e5
