From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: remove unused tcp_fin() parameters
Date: Thu, 20 Oct 2011 23:11:24 +0200
Message-ID: <1319145084.2854.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34970 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752669Ab1JTVL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 17:11:29 -0400
Received: by wyg36 with SMTP id 36so3335939wyg.19
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 14:11:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_fin() only needs socket pointer, we can remove skb and th params.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp_input.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1e848b2..6f7fef9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4127,7 +4127,7 @@ static void tcp_reset(struct sock *sk)
  *
  *	If we are in FINWAIT-2, a received FIN moves us to TIME-WAIT.
  */
-static void tcp_fin(struct sk_buff *skb, struct sock *sk, struct tcphdr *th)
+static void tcp_fin(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
@@ -4398,7 +4398,7 @@ static void tcp_ofo_queue(struct sock *sk)
 		__skb_queue_tail(&sk->sk_receive_queue, skb);
 		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
 		if (tcp_hdr(skb)->fin)
-			tcp_fin(skb, sk, tcp_hdr(skb));
+			tcp_fin(sk);
 	}
 }
 
@@ -4480,7 +4480,7 @@ queue_and_out:
 		if (skb->len)
 			tcp_event_data_recv(sk, skb);
 		if (th->fin)
-			tcp_fin(skb, sk, th);
+			tcp_fin(sk);
 
 		if (!skb_queue_empty(&tp->out_of_order_queue)) {
 			tcp_ofo_queue(sk);
