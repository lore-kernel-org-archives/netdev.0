From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipv4: use dst with ref during bcast/mcast loopback
Date: Sun, 7 Aug 2011 23:17:22 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1108072232170.13644@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:34369 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754858Ab1HGUMl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Aug 2011 16:12:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Make sure skb dst has reference when moving to
another context. Currently, I don't see protocols that can
hit it when sending broadcasts/multicasts to loopback using
noref dsts, so it is just a precaution.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

	Please, review and apply if needed...

diff -urp v3.0/linux/net/ipv4/ip_output.c linux/net/ipv4/ip_output.c
--- v3.0/linux/net/ipv4/ip_output.c	2011-07-22 09:43:32.000000000 +0300
+++ linux/net/ipv4/ip_output.c	2011-08-07 22:21:23.909347184 +0300
@@ -122,6 +122,7 @@ static int ip_dev_loopback_xmit(struct s
 	newskb->pkt_type = PACKET_LOOPBACK;
 	newskb->ip_summed = CHECKSUM_UNNECESSARY;
 	WARN_ON(!skb_dst(newskb));
+	skb_dst_force(newskb);
 	netif_rx_ni(newskb);
 	return 0;
 }
