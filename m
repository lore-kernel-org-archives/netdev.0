From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [RFC] [PATCH 3/5] net: IPv6 changes
Date: Thu, 15 Oct 2009 11:27:27 +0530
Message-ID: <20091015055727.30145.42525.sendpatchset@localhost.localdomain>
References: <20091015055602.30145.65852.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Krishna Kumar <krkumar2@in.ibm.com>, dada1@cosmosbay.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:42746 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753385AbZJOF6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 01:58:24 -0400
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp09.au.ibm.com (8.14.3/8.13.1) with ESMTP id n9FGjNRr008802
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 03:45:23 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9F5vbMT1036312
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 16:57:37 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9F5vaLj029442
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 16:57:37 +1100
In-Reply-To: <20091015055602.30145.65852.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

IPv6: Reset sk_tx_queue_mapping when dst_cache is reset.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 net/ipv6/inet6_connection_sock.c |    1 +
 1 file changed, 1 insertion(+)

diff -ruNp org/net/ipv6/inet6_connection_sock.c new/net/ipv6/inet6_connection_sock.c
--- org/net/ipv6/inet6_connection_sock.c	2009-10-14 17:59:58.000000000 +0530
+++ new/net/ipv6/inet6_connection_sock.c	2009-10-14 18:00:11.000000000 +0530
@@ -168,6 +168,7 @@ struct dst_entry *__inet6_csk_dst_check(
 	if (dst) {
 		struct rt6_info *rt = (struct rt6_info *)dst;
 		if (rt->rt6i_flow_cache_genid != atomic_read(&flow_cache_genid)) {
+			sk_record_tx_queue(sk, -1);
 			sk->sk_dst_cache = NULL;
 			dst_release(dst);
 			dst = NULL;
