From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 2/4 v4] net: IPv6 changes
Date: Tue, 20 Oct 2009 15:16:32 +0530
Message-ID: <20091020094632.10404.32941.sendpatchset@localhost.localdomain>
References: <20091020094607.10404.81794.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Krishna Kumar <krkumar2@in.ibm.com>, dada1@cosmosbay.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([59.145.155.3]:56846 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757AbZJTJqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 05:46:33 -0400
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp03.in.ibm.com (8.14.3/8.13.1) with ESMTP id n9K9kaHt007456
	for <netdev@vger.kernel.org>; Tue, 20 Oct 2009 15:16:36 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9K9kaSp2478162
	for <netdev@vger.kernel.org>; Tue, 20 Oct 2009 15:16:36 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9K9kZJY014737
	for <netdev@vger.kernel.org>; Tue, 20 Oct 2009 15:16:36 +0530
In-Reply-To: <20091020094607.10404.81794.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

IPv6: Reset sk_tx_queue_mapping when dst_cache is reset. Use existing
macro to do the work.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 net/ipv6/inet6_connection_sock.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff -ruNp org/net/ipv6/inet6_connection_sock.c new/net/ipv6/inet6_connection_sock.c
--- org/net/ipv6/inet6_connection_sock.c	2009-10-16 21:29:19.000000000 +0530
+++ new/net/ipv6/inet6_connection_sock.c	2009-10-16 21:31:00.000000000 +0530
@@ -168,8 +168,7 @@ struct dst_entry *__inet6_csk_dst_check(
 	if (dst) {
 		struct rt6_info *rt = (struct rt6_info *)dst;
 		if (rt->rt6i_flow_cache_genid != atomic_read(&flow_cache_genid)) {
-			sk->sk_dst_cache = NULL;
-			dst_release(dst);
+			__sk_dst_reset(sk);
 			dst = NULL;
 		}
 	}
