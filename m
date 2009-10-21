From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] pktgen: initialize IP ID field
Date: Wed, 21 Oct 2009 06:22:29 +0200
Message-ID: <4ADE8C85.6020809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43508 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007AbZJUEW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 00:22:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While playing with pktgen, I realized IP ID was not filled and a random value
was taken, possibly leaking 2 bytes of kernel memory.

We can use an increasing ID, this can help diagnostics anyway.


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 1da0e03..59396a5 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -335,6 +335,7 @@ struct pktgen_dev {
 	__u32 cur_src_mac_offset;
 	__be32 cur_saddr;
 	__be32 cur_daddr;
+	__u16 ip_id;
 	__u16 cur_udp_dst;
 	__u16 cur_udp_src;
 	__u16 cur_queue_map;
@@ -2630,6 +2631,8 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	iph->protocol = IPPROTO_UDP;	/* UDP */
 	iph->saddr = pkt_dev->cur_saddr;
 	iph->daddr = pkt_dev->cur_daddr;
+	iph->id = htons(pkt_dev->ip_id);
+	pkt_dev->ip_id++;
 	iph->frag_off = 0;
 	iplen = 20 + 8 + datalen;
 	iph->tot_len = htons(iplen);
