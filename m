From: David L Stevens <dlstevens@us.ibm.com>
Subject: [PATCH] fix IPv6 queries for bridge multicast snooping
Date: Tue, 14 Dec 2010 10:42:16 -0800
Message-ID: <1292352136.4720.11.camel@IBM-1B506CFC885>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:43405 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113Ab0LNSmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 13:42:25 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id oBEIe14e013304
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 11:40:01 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBEIgL6v132764
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 11:42:21 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBEIgK37020808
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 11:42:21 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a missing ntohs() for bridge IPv6 multicast snooping.

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

--- linux-2.6.37-rc5/net/bridge/br_multicast.c	2010-12-06 20:09:04.000000000 -0800
+++ linux-2.6.37-rc5DLS/net/bridge/br_multicast.c	2010-12-13 14:55:34.228196279 -0800
@@ -437,7 +437,7 @@ static struct sk_buff *br_ip6_multicast_
 	ip6h = ipv6_hdr(skb);
 
 	*(__force __be32 *)ip6h = htonl(0x60000000);
-	ip6h->payload_len = 8 + sizeof(*mldq);
+	ip6h->payload_len = htons(8 + sizeof(*mldq));
 	ip6h->nexthdr = IPPROTO_HOPOPTS;
 	ip6h->hop_limit = 1;
 	ipv6_addr_set(&ip6h->saddr, 0, 0, 0, 0);



