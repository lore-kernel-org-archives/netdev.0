From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] [RFC] tcp: TSQ - do not always throttle.
Date: Tue, 17 Jul 2012 17:33:58 +0530
Message-ID: <20120717120358.16611.98190.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([122.248.162.6]:35686 "EHLO
	e28smtp06.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060Ab2GQMEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 08:04:11 -0400
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <krkumar2@in.ibm.com>;
	Tue, 17 Jul 2012 17:34:07 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6HC41s366060508
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 17:34:01 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6HHXWZe002551
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 23:03:34 +0530
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not throttle if sysctl_tcp_limit_output_bytes==0.

Maybe it is better to throttle earlier in the loop, after
calling tcp_init_tso_segs().

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 tcp_output.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -ruNp org/net/ipv4/tcp_output.c new/net/ipv4/tcp_output.c
--- org/net/ipv4/tcp_output.c	2012-07-17 09:56:12.000000000 +0530
+++ new/net/ipv4/tcp_output.c	2012-07-17 13:02:12.476111697 +0530
@@ -1948,7 +1948,8 @@ static bool tcp_write_xmit(struct sock *
 		/* TSQ : sk_wmem_alloc accounts skb truesize,
 		 * including skb overhead. But thats OK.
 		 */
-		if (atomic_read(&sk->sk_wmem_alloc) >= sysctl_tcp_limit_output_bytes) {
+		if (sysctl_tcp_limit_output_bytes > 0 &&
+		    atomic_read(&sk->sk_wmem_alloc) >= sysctl_tcp_limit_output_bytes) {
 			set_bit(TSQ_THROTTLED, &tp->tsq_flags);
 			break;
 		}
