From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 3/4 v3] net: IPv6 changes
Date: Sun, 18 Oct 2009 18:38:04 +0530
Message-ID: <20091018130804.3960.28321.sendpatchset@localhost.localdomain>
References: <20091018130727.3960.32107.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Krishna Kumar <krkumar2@in.ibm.com>, dada1@cosmosbay.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([59.145.155.2]:37349 "EHLO
	e28smtp02.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbZJRNIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 09:08:04 -0400
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp02.in.ibm.com (8.14.3/8.13.1) with ESMTP id n9ID87RU017787
	for <netdev@vger.kernel.org>; Sun, 18 Oct 2009 18:38:07 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9ID87R22506826
	for <netdev@vger.kernel.org>; Sun, 18 Oct 2009 18:38:07 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9ID86f3028770
	for <netdev@vger.kernel.org>; Mon, 19 Oct 2009 00:08:06 +1100
In-Reply-To: <20091018130727.3960.32107.sendpatchset@localhost.localdomain>
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
