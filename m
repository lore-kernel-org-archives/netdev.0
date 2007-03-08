From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 6/8] tcp: whitespace cleanup
Date: Thu, 08 Mar 2007 12:52:20 -0800
Message-ID: <20070308205306.066926316@linux-foundation.org>
References: <20070308205214.580772044@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:35783 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933328AbXCHUyl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 15:54:41 -0500
Content-Disposition: inline; filename=tcp-cleanup
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add whitespace around keywords.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


---
 net/ipv4/tcp_hybla.c     |    2 -
 net/ipv4/tcp_input.c     |   57 +++++++++++++++++++++++------------------------
 net/ipv4/tcp_minisocks.c |    6 ++--
 net/ipv4/tcp_output.c    |   34 ++++++++++++++--------------
 net/ipv4/tcp_westwood.c  |    2 -
 5 files changed, 51 insertions(+), 50 deletions(-)

--- net-2.6.22.orig/net/ipv4/tcp_input.c	2007-03-07 15:09:04.000000000 -0800
+++ net-2.6.22/net/ipv4/tcp_input.c	2007-03-07 15:11:14.000000000 -0800
@@ -578,7 +578,7 @@
 	 * does not matter how to _calculate_ it. Seems, it was trap
 	 * that VJ failed to avoid. 8)
 	 */
-	if(m == 0)
+	if (m == 0)
 		m = 1;
 	if (tp->srtt != 0) {
 		m -= (tp->srtt >> 3);	/* m is now error in rtt est */
@@ -1758,12 +1758,11 @@
 
 			/* clear xmit_retransmit_queue hints
 			 *  if this is beyond hint */
-			if(tp->retransmit_skb_hint != NULL &&
-			   before(TCP_SKB_CB(skb)->seq,
-				  TCP_SKB_CB(tp->retransmit_skb_hint)->seq)) {
-
+			if (tp->retransmit_skb_hint != NULL &&
+			    before(TCP_SKB_CB(skb)->seq,
+				   TCP_SKB_CB(tp->retransmit_skb_hint)->seq))
 				tp->retransmit_skb_hint = NULL;
-			}
+
 		}
 	}
 	tcp_sync_left_out(tp);
@@ -2441,7 +2440,7 @@
 
 		if (sacked) {
 			if (sacked & TCPCB_RETRANS) {
-				if(sacked & TCPCB_SACKED_RETRANS)
+				if (sacked & TCPCB_SACKED_RETRANS)
 					tp->retrans_out -= tcp_skb_pcount(skb);
 				acked |= FLAG_RETRANS_DATA_ACKED;
 				seq_rtt = -1;
@@ -2840,7 +2839,7 @@
 	ptr = (unsigned char *)(th + 1);
 	opt_rx->saw_tstamp = 0;
 
-	while(length>0) {
+	while (length > 0) {
 		int opcode=*ptr++;
 		int opsize;
 
@@ -2856,9 +2855,9 @@
 					return;
 				if (opsize > length)
 					return;	/* don't parse partial options */
-				switch(opcode) {
+				switch (opcode) {
 				case TCPOPT_MSS:
-					if(opsize==TCPOLEN_MSS && th->syn && !estab) {
+					if (opsize==TCPOLEN_MSS && th->syn && !estab) {
 						u16 in_mss = ntohs(get_unaligned((__be16 *)ptr));
 						if (in_mss) {
 							if (opt_rx->user_mss && opt_rx->user_mss < in_mss)
@@ -2868,12 +2867,12 @@
 					}
 					break;
 				case TCPOPT_WINDOW:
-					if(opsize==TCPOLEN_WINDOW && th->syn && !estab)
+					if (opsize==TCPOLEN_WINDOW && th->syn && !estab)
 						if (sysctl_tcp_window_scaling) {
 							__u8 snd_wscale = *(__u8 *) ptr;
 							opt_rx->wscale_ok = 1;
 							if (snd_wscale > 14) {
-								if(net_ratelimit())
+								if (net_ratelimit())
 									printk(KERN_INFO "tcp_parse_options: Illegal window "
 									       "scaling value %d >14 received.\n",
 									       snd_wscale);
@@ -2883,7 +2882,7 @@
 						}
 					break;
 				case TCPOPT_TIMESTAMP:
-					if(opsize==TCPOLEN_TIMESTAMP) {
+					if (opsize==TCPOLEN_TIMESTAMP) {
 						if ((estab && opt_rx->tstamp_ok) ||
 						    (!estab && sysctl_tcp_timestamps)) {
 							opt_rx->saw_tstamp = 1;
@@ -2893,7 +2892,7 @@
 					}
 					break;
 				case TCPOPT_SACK_PERM:
-					if(opsize==TCPOLEN_SACK_PERM && th->syn && !estab) {
+					if (opsize==TCPOLEN_SACK_PERM && th->syn && !estab) {
 						if (sysctl_tcp_sack) {
 							opt_rx->sack_ok = 1;
 							tcp_sack_reset(opt_rx);
@@ -2902,7 +2901,7 @@
 					break;
 
 				case TCPOPT_SACK:
-					if((opsize >= (TCPOLEN_SACK_BASE + TCPOLEN_SACK_PERBLOCK)) &&
+					if ((opsize >= (TCPOLEN_SACK_BASE + TCPOLEN_SACK_PERBLOCK)) &&
 					   !((opsize - TCPOLEN_SACK_BASE) % TCPOLEN_SACK_PERBLOCK) &&
 					   opt_rx->sack_ok) {
 						TCP_SKB_CB(skb)->sacked = (ptr - 2) - (unsigned char *)th;
@@ -2964,7 +2963,7 @@
 		 * Not only, also it occurs for expired timestamps.
 		 */
 
-		if((s32)(tp->rx_opt.rcv_tsval - tp->rx_opt.ts_recent) >= 0 ||
+		if ((s32)(tp->rx_opt.rcv_tsval - tp->rx_opt.ts_recent) >= 0 ||
 		   get_seconds() >= tp->rx_opt.ts_recent_stamp + TCP_PAWS_24DAYS)
 			tcp_store_ts_recent(tp);
 	}
@@ -3223,7 +3222,7 @@
 			 */
 			tp->rx_opt.num_sacks--;
 			tp->rx_opt.eff_sacks = min(tp->rx_opt.num_sacks + tp->rx_opt.dsack, 4 - tp->rx_opt.tstamp_ok);
-			for(i=this_sack; i < tp->rx_opt.num_sacks; i++)
+			for (i=this_sack; i < tp->rx_opt.num_sacks; i++)
 				sp[i] = sp[i+1];
 			continue;
 		}
@@ -3276,7 +3275,7 @@
 		tp->rx_opt.num_sacks--;
 		sp--;
 	}
-	for(; this_sack > 0; this_sack--, sp--)
+	for (; this_sack > 0; this_sack--, sp--)
 		*sp = *(sp-1);
 
 new_sack:
@@ -3302,7 +3301,7 @@
 		return;
 	}
 
-	for(this_sack = 0; this_sack < num_sacks; ) {
+	for (this_sack = 0; this_sack < num_sacks; ) {
 		/* Check if the start of the sack is covered by RCV.NXT. */
 		if (!before(tp->rcv_nxt, sp->start_seq)) {
 			int i;
@@ -3358,7 +3357,7 @@
 		__skb_unlink(skb, &tp->out_of_order_queue);
 		__skb_queue_tail(&sk->sk_receive_queue, skb);
 		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
-		if(skb->h.th->fin)
+		if (skb->h.th->fin)
 			tcp_fin(skb, sk, skb->h.th);
 	}
 }
@@ -3424,9 +3423,9 @@
 			__skb_queue_tail(&sk->sk_receive_queue, skb);
 		}
 		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
-		if(skb->len)
+		if (skb->len)
 			tcp_event_data_recv(sk, tp, skb);
-		if(th->fin)
+		if (th->fin)
 			tcp_fin(skb, sk, th);
 
 		if (!skb_queue_empty(&tp->out_of_order_queue)) {
@@ -4323,7 +4322,7 @@
 		goto discard;
 	}
 
-	if(th->rst) {
+	if (th->rst) {
 		tcp_reset(sk);
 		goto discard;
 	}
@@ -4338,7 +4337,7 @@
 	}
 
 step5:
-	if(th->ack)
+	if (th->ack)
 		tcp_ack(sk, skb, FLAG_SLOWPATH);
 
 	tcp_rcv_rtt_measure_ts(sk, skb);
@@ -4626,13 +4625,13 @@
 		goto discard;
 
 	case TCP_LISTEN:
-		if(th->ack)
+		if (th->ack)
 			return 1;
 
-		if(th->rst)
+		if (th->rst)
 			goto discard;
 
-		if(th->syn) {
+		if (th->syn) {
 			if (icsk->icsk_af_ops->conn_request(sk, skb) < 0)
 				return 1;
 
@@ -4688,7 +4687,7 @@
 	}
 
 	/* step 2: check RST bit */
-	if(th->rst) {
+	if (th->rst) {
 		tcp_reset(sk);
 		goto discard;
 	}
@@ -4711,7 +4710,7 @@
 	if (th->ack) {
 		int acceptable = tcp_ack(sk, skb, FLAG_SLOWPATH);
 
-		switch(sk->sk_state) {
+		switch (sk->sk_state) {
 		case TCP_SYN_RECV:
 			if (acceptable) {
 				tp->copied_seq = tp->rcv_nxt;
--- net-2.6.22.orig/net/ipv4/tcp_minisocks.c	2007-03-07 15:09:04.000000000 -0800
+++ net-2.6.22/net/ipv4/tcp_minisocks.c	2007-03-07 15:11:14.000000000 -0800
@@ -246,7 +246,7 @@
 	if (paws_reject)
 		NET_INC_STATS_BH(LINUX_MIB_PAWSESTABREJECTED);
 
-	if(!th->rst) {
+	if (!th->rst) {
 		/* In this case we must reset the TIMEWAIT timer.
 		 *
 		 * If it is ACKless SYN it may be both old duplicate
@@ -324,7 +324,7 @@
 				if (tcp_alloc_md5sig_pool() == NULL)
 					BUG();
 			}
-		} while(0);
+		} while (0);
 #endif
 
 		/* Linkage updates. */
@@ -439,7 +439,7 @@
 						       keepalive_time_when(newtp));
 
 		newtp->rx_opt.tstamp_ok = ireq->tstamp_ok;
-		if((newtp->rx_opt.sack_ok = ireq->sack_ok) != 0) {
+		if ((newtp->rx_opt.sack_ok = ireq->sack_ok) != 0) {
 			if (sysctl_tcp_fack)
 				newtp->rx_opt.sack_ok |= 2;
 		}
--- net-2.6.22.orig/net/ipv4/tcp_output.c	2007-03-07 15:09:04.000000000 -0800
+++ net-2.6.22/net/ipv4/tcp_output.c	2007-03-07 15:11:14.000000000 -0800
@@ -236,7 +236,7 @@
 	u32 new_win = __tcp_select_window(sk);
 
 	/* Never shrink the offered window */
-	if(new_win < cur_win) {
+	if (new_win < cur_win) {
 		/* Danger Will Robinson!
 		 * Don't update rcv_wup/rcv_wnd here or else
 		 * we will not be able to advertise a zero
@@ -287,10 +287,12 @@
 			       (TCPOPT_SACK <<  8) |
 			       (TCPOLEN_SACK_BASE + (tp->rx_opt.eff_sacks *
 						     TCPOLEN_SACK_PERBLOCK)));
-		for(this_sack = 0; this_sack < tp->rx_opt.eff_sacks; this_sack++) {
+
+		for (this_sack = 0; this_sack < tp->rx_opt.eff_sacks; this_sack++) {
 			*ptr++ = htonl(sp[this_sack].start_seq);
 			*ptr++ = htonl(sp[this_sack].end_seq);
 		}
+
 		if (tp->rx_opt.dsack) {
 			tp->rx_opt.dsack = 0;
 			tp->rx_opt.eff_sacks--;
@@ -335,7 +337,7 @@
 	 */
 	*ptr++ = htonl((TCPOPT_MSS << 24) | (TCPOLEN_MSS << 16) | mss);
 	if (ts) {
-		if(sack)
+		if (sack)
 			*ptr++ = htonl((TCPOPT_SACK_PERM << 24) |
 				       (TCPOLEN_SACK_PERM << 16) |
 				       (TCPOPT_TIMESTAMP << 8) |
@@ -347,7 +349,7 @@
 				       TCPOLEN_TIMESTAMP);
 		*ptr++ = htonl(tstamp);		/* TSVAL */
 		*ptr++ = htonl(ts_recent);	/* TSECR */
-	} else if(sack)
+	} else if (sack)
 		*ptr++ = htonl((TCPOPT_NOP << 24) |
 			       (TCPOPT_NOP << 16) |
 			       (TCPOPT_SACK_PERM << 8) |
@@ -428,7 +430,7 @@
 	sysctl_flags = 0;
 	if (unlikely(tcb->flags & TCPCB_FLAG_SYN)) {
 		tcp_header_size = sizeof(struct tcphdr) + TCPOLEN_MSS;
-		if(sysctl_tcp_timestamps) {
+		if (sysctl_tcp_timestamps) {
 			tcp_header_size += TCPOLEN_TSTAMP_ALIGNED;
 			sysctl_flags |= SYSCTL_FLAG_TSTAMPS;
 		}
@@ -1614,7 +1616,7 @@
 		u16 flags = TCP_SKB_CB(skb)->flags;
 
 		/* Also punt if next skb has been SACK'd. */
-		if(TCP_SKB_CB(next_skb)->sacked & TCPCB_SACKED_ACKED)
+		if (TCP_SKB_CB(next_skb)->sacked & TCPCB_SACKED_ACKED)
 			return;
 
 		/* Next skb is out of window. */
@@ -1774,13 +1776,13 @@
 	}
 
 	/* Collapse two adjacent packets if worthwhile and we can. */
-	if(!(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_SYN) &&
-	   (skb->len < (cur_mss >> 1)) &&
-	   (tcp_write_queue_next(sk, skb) != tcp_send_head(sk)) &&
-	   (!tcp_skb_is_last(sk, skb)) &&
-	   (skb_shinfo(skb)->nr_frags == 0 && skb_shinfo(tcp_write_queue_next(sk, skb))->nr_frags == 0) &&
-	   (tcp_skb_pcount(skb) == 1 && tcp_skb_pcount(tcp_write_queue_next(sk, skb)) == 1) &&
-	   (sysctl_tcp_retrans_collapse != 0))
+	if (!(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_SYN) &&
+	    (skb->len < (cur_mss >> 1)) &&
+	    (tcp_write_queue_next(sk, skb) != tcp_send_head(sk)) &&
+	    (!tcp_skb_is_last(sk, skb)) &&
+	    (skb_shinfo(skb)->nr_frags == 0 && skb_shinfo(tcp_write_queue_next(sk, skb))->nr_frags == 0) &&
+	    (tcp_skb_pcount(skb) == 1 && tcp_skb_pcount(tcp_write_queue_next(sk, skb)) == 1) &&
+	    (sysctl_tcp_retrans_collapse != 0))
 		tcp_retrans_try_collapse(sk, skb, cur_mss);
 
 	if (inet_csk(sk)->icsk_af_ops->rebuild_header(sk))
@@ -1790,9 +1792,9 @@
 	 * retransmit when old data is attached.  So strip it off
 	 * since it is cheap to do so and saves bytes on the network.
 	 */
-	if(skb->len > 0 &&
-	   (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN) &&
-	   tp->snd_una == (TCP_SKB_CB(skb)->end_seq - 1)) {
+	if (skb->len > 0 &&
+	    (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN) &&
+	    tp->snd_una == (TCP_SKB_CB(skb)->end_seq - 1)) {
 		if (!pskb_trim(skb, 0)) {
 			TCP_SKB_CB(skb)->seq = TCP_SKB_CB(skb)->end_seq - 1;
 			skb_shinfo(skb)->gso_segs = 1;
--- net-2.6.22.orig/net/ipv4/tcp_hybla.c	2007-03-07 15:09:04.000000000 -0800
+++ net-2.6.22/net/ipv4/tcp_hybla.c	2007-03-07 15:11:14.000000000 -0800
@@ -144,7 +144,7 @@
 	ca->snd_cwnd_cents += odd;
 
 	/* check when fractions goes >=128 and increase cwnd by 1. */
-	while(ca->snd_cwnd_cents >= 128) {
+	while (ca->snd_cwnd_cents >= 128) {
 		tp->snd_cwnd++;
 		ca->snd_cwnd_cents -= 128;
 		tp->snd_cwnd_cnt = 0;
--- net-2.6.22.orig/net/ipv4/tcp_westwood.c	2007-03-07 15:09:04.000000000 -0800
+++ net-2.6.22/net/ipv4/tcp_westwood.c	2007-03-07 15:11:14.000000000 -0800
@@ -226,7 +226,7 @@
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct westwood *w = inet_csk_ca(sk);
 
-	switch(event) {
+	switch (event) {
 	case CA_EVENT_FAST_ACK:
 		westwood_fast_bw(sk);
 		break;

--
Stephen Hemminger <shemminger@linux-foundation.org>

