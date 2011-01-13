From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH] tcp: remove duplicate th = tcp_hdr(skb)
Date: Thu, 13 Jan 2011 16:41:42 +0100
Message-ID: <1294933302-28469-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:56649 "EHLO
	smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756090Ab1AMPrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 10:47:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

th is already set some lines before to be th = tcp_hdr(skb).

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 net/ipv4/tcp_ipv4.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 856f684..7fe29c6 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1644,7 +1644,6 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	if (!skb_csum_unnecessary(skb) && tcp_v4_checksum_init(skb))
 		goto bad_packet;
 
-	th = tcp_hdr(skb);
 	iph = ip_hdr(skb);
 	TCP_SKB_CB(skb)->seq = ntohl(th->seq);
 	TCP_SKB_CB(skb)->end_seq = (TCP_SKB_CB(skb)->seq + th->syn + th->fin +
-- 
1.7.1

