From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 2/6] tcp: reindent two spots after prequeue removal
Date: Sun, 30 Jul 2017 03:57:19 +0200
Message-ID: <20170730015723.25587-3-fw@strlen.de>
References: <20170730015723.25587-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:45058 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752485AbdG3B5M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 21:57:12 -0400
In-Reply-To: <20170730015723.25587-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two branches are now always true, remove the conditional.
objdiff shows no changes.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/tcp_input.c | 50 +++++++++++++++++++++++---------------------------
 1 file changed, 23 insertions(+), 27 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 770ce6cb3eca..87efde9f5a90 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4611,16 +4611,14 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 			goto out_of_window;
 
 		/* Ok. In sequence. In window. */
-		if (eaten <= 0) {
 queue_and_out:
-			if (eaten < 0) {
-				if (skb_queue_len(&sk->sk_receive_queue) == 0)
-					sk_forced_mem_schedule(sk, skb->truesize);
-				else if (tcp_try_rmem_schedule(sk, skb, skb->truesize))
-					goto drop;
-			}
-			eaten = tcp_queue_rcv(sk, skb, 0, &fragstolen);
+		if (eaten < 0) {
+			if (skb_queue_len(&sk->sk_receive_queue) == 0)
+				sk_forced_mem_schedule(sk, skb->truesize);
+			else if (tcp_try_rmem_schedule(sk, skb, skb->truesize))
+				goto drop;
 		}
+		eaten = tcp_queue_rcv(sk, skb, 0, &fragstolen);
 		tcp_rcv_nxt_update(tp, TCP_SKB_CB(skb)->end_seq);
 		if (skb->len)
 			tcp_event_data_recv(sk, skb);
@@ -5410,30 +5408,28 @@ void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			int eaten = 0;
 			bool fragstolen = false;
 
-			if (!eaten) {
-				if (tcp_checksum_complete(skb))
-					goto csum_error;
+			if (tcp_checksum_complete(skb))
+				goto csum_error;
 
-				if ((int)skb->truesize > sk->sk_forward_alloc)
-					goto step5;
+			if ((int)skb->truesize > sk->sk_forward_alloc)
+				goto step5;
 
-				/* Predicted packet is in window by definition.
-				 * seq == rcv_nxt and rcv_wup <= rcv_nxt.
-				 * Hence, check seq<=rcv_wup reduces to:
-				 */
-				if (tcp_header_len ==
-				    (sizeof(struct tcphdr) + TCPOLEN_TSTAMP_ALIGNED) &&
-				    tp->rcv_nxt == tp->rcv_wup)
-					tcp_store_ts_recent(tp);
+			/* Predicted packet is in window by definition.
+			 * seq == rcv_nxt and rcv_wup <= rcv_nxt.
+			 * Hence, check seq<=rcv_wup reduces to:
+			 */
+			if (tcp_header_len ==
+			    (sizeof(struct tcphdr) + TCPOLEN_TSTAMP_ALIGNED) &&
+			    tp->rcv_nxt == tp->rcv_wup)
+				tcp_store_ts_recent(tp);
 
-				tcp_rcv_rtt_measure_ts(sk, skb);
+			tcp_rcv_rtt_measure_ts(sk, skb);
 
-				NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPHPHITS);
+			NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPHPHITS);
 
-				/* Bulk data transfer: receiver */
-				eaten = tcp_queue_rcv(sk, skb, tcp_header_len,
-						      &fragstolen);
-			}
+			/* Bulk data transfer: receiver */
+			eaten = tcp_queue_rcv(sk, skb, tcp_header_len,
+					      &fragstolen);
 
 			tcp_event_data_recv(sk, skb);
 
-- 
2.13.0
