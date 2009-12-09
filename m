From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 2/3] tcp: Remove unrequired operations in tcp_push()
Date: Wed, 09 Dec 2009 13:56:19 +0530
Message-ID: <20091209082619.19055.10563.sendpatchset@localhost.localdomain>
References: <20091209082613.19055.58864.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([122.248.162.1]:49534 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640AbZLII0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 03:26:19 -0500
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp01.in.ibm.com (8.14.3/8.13.1) with ESMTP id nB98QK36006629
	for <netdev@vger.kernel.org>; Wed, 9 Dec 2009 13:56:20 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nB98QKTc3711080
	for <netdev@vger.kernel.org>; Wed, 9 Dec 2009 13:56:20 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nB98QJv9032742
	for <netdev@vger.kernel.org>; Wed, 9 Dec 2009 19:26:20 +1100
In-Reply-To: <20091209082613.19055.58864.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Remove unrequired operations in tcp_push()

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 net/ipv4/tcp.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff -ruNp org/net/ipv4/tcp.c new/net/ipv4/tcp.c
--- org/net/ipv4/tcp.c	2009-12-04 18:16:10.000000000 +0530
+++ new/net/ipv4/tcp.c	2009-12-09 10:01:35.000000000 +0530
@@ -536,8 +536,7 @@ static inline void skb_entail(struct soc
 		tp->nonagle &= ~TCP_NAGLE_PUSH;
 }
 
-static inline void tcp_mark_urg(struct tcp_sock *tp, int flags,
-				struct sk_buff *skb)
+static inline void tcp_mark_urg(struct tcp_sock *tp, int flags)
 {
 	if (flags & MSG_OOB)
 		tp->snd_up = tp->write_seq;
@@ -546,13 +545,15 @@ static inline void tcp_mark_urg(struct t
 static inline void tcp_push(struct sock *sk, int flags, int mss_now,
 			    int nonagle)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
-
 	if (tcp_send_head(sk)) {
-		struct sk_buff *skb = tcp_write_queue_tail(sk);
-		if (!(flags & MSG_MORE) || forced_push(tp))
+		struct tcp_sock *tp = tcp_sk(sk);
+
+		if (!(flags & MSG_MORE) || forced_push(tp)) {
+			struct sk_buff *skb = tcp_write_queue_tail(sk);
+
 			tcp_mark_push(tp, skb);
-		tcp_mark_urg(tp, flags, skb);
+		}
+		tcp_mark_urg(tp, flags);
 		__tcp_push_pending_frames(sk, mss_now,
 					  (flags & MSG_MORE) ? TCP_NAGLE_CORK : nonagle);
 	}
