From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 2/3 Ver2] tcp: Remove unrequired operations in tcp_push()
Date: Thu, 10 Dec 2009 22:46:52 +0530
Message-ID: <20091210171652.20777.79982.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp05.au.ibm.com ([202.81.31.147]:38126 "EHLO
	e23smtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761065AbZLJRQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 12:16:49 -0500
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp05.au.ibm.com (8.14.3/8.13.1) with ESMTP id nBAHDoPV024170
	for <netdev@vger.kernel.org>; Fri, 11 Dec 2009 04:13:50 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBAHGsNd1753284
	for <netdev@vger.kernel.org>; Fri, 11 Dec 2009 04:16:54 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBAHGrBn005225
	for <netdev@vger.kernel.org>; Fri, 11 Dec 2009 04:16:54 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krishna Kumar <krkumar2@in.ibm.com>

Remove unrequired operations in tcp_push()

Changelog:
	Removed a temporary skb variable from tcp_push()

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
Acked-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff -ruNp org/net/ipv4/tcp.c new/net/ipv4/tcp.c
--- org/net/ipv4/tcp.c	2009-12-10 21:12:15.000000000 +0530
+++ new/net/ipv4/tcp.c	2009-12-10 21:22:41.000000000 +0530
@@ -536,8 +536,7 @@ static inline void skb_entail(struct soc
 		tp->nonagle &=3D ~TCP_NAGLE_PUSH;
 }
=20
-static inline void tcp_mark_urg(struct tcp_sock *tp, int flags,
-				struct sk_buff *skb)
+static inline void tcp_mark_urg(struct tcp_sock *tp, int flags)
 {
 	if (flags & MSG_OOB)
 		tp->snd_up =3D tp->write_seq;
@@ -546,13 +545,13 @@ static inline void tcp_mark_urg(struct t
 static inline void tcp_push(struct sock *sk, int flags, int mss_now,
 			    int nonagle)
 {
-	struct tcp_sock *tp =3D tcp_sk(sk);
-
 	if (tcp_send_head(sk)) {
-		struct sk_buff *skb =3D tcp_write_queue_tail(sk);
+		struct tcp_sock *tp =3D tcp_sk(sk);
+
 		if (!(flags & MSG_MORE) || forced_push(tp))
-			tcp_mark_push(tp, skb);
-		tcp_mark_urg(tp, flags, skb);
+			tcp_mark_push(tp, tcp_write_queue_tail(sk));
+
+		tcp_mark_urg(tp, flags);
 		__tcp_push_pending_frames(sk, mss_now,
 					  (flags & MSG_MORE) ? TCP_NAGLE_CORK : nonagle);
 	}
