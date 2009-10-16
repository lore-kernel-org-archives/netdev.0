From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 3/4 v2] net: IPv6 changes
Date: Fri, 16 Oct 2009 12:51:45 +0530
Message-ID: <20091016072145.24384.67151.sendpatchset@localhost.localdomain>
References: <20091016072107.24384.17358.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Krishna Kumar <krkumar2@in.ibm.com>, dada1@cosmosbay.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp08.au.ibm.com ([202.81.31.141]:59599 "EHLO
	e23smtp08.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756518AbZJPHWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 03:22:43 -0400
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp08.au.ibm.com (8.14.3/8.13.1) with ESMTP id n9GIAoTN006266
	for <netdev@vger.kernel.org>; Sat, 17 Oct 2009 05:10:50 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9G7Lrlj1220616
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 18:21:55 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n9G7Lqjd014370
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 18:21:53 +1100
In-Reply-To: <20091016072107.24384.17358.sendpatchset@localhost.localdomain>
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
--- org/net/ipv6/inet6_connection_sock.c	2009-10-16 11:59:05.000000000 +0530
+++ new/net/ipv6/inet6_connection_sock.c	2009-10-16 12:00:20.000000000 +0530
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
