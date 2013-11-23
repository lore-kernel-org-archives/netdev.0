From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] ipv6: fix leaking uninitialized port number of offender sockaddr
Date: Sat, 23 Nov 2013 07:22:33 +0100
Message-ID: <20131123062233.GD15822@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60523 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759Ab3KWGWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 01:22:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Offenders don't have port numbers, so set it to 0.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/datagram.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index a454b0f..6b1f73b 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -377,6 +377,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len)
 	if (serr->ee.ee_origin != SO_EE_ORIGIN_LOCAL) {
 		sin->sin6_family = AF_INET6;
 		sin->sin6_flowinfo = 0;
+		sin->sin6_port = 0;
 		if (skb->protocol == htons(ETH_P_IPV6)) {
 			sin->sin6_addr = ipv6_hdr(skb)->saddr;
 			if (np->rxopt.all)
-- 
1.8.3.1
