From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/3] [TCP]: cleanup tcp_{in,out}put.c style
Date: Mon, 31 Dec 2007 16:21:45 +0200
Message-ID: <11991109072239-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58165 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752590AbXLaOVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 09:21:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These were manually selected from indent's results which as is
are too noisy to be of any use without human reason. In addition,
some extra newlines between function and its comment were removed
too.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c  |  436 +++++++++++++++++++++++++----------------=
-------
 net/ipv4/tcp_output.c |  146 ++++++++--------
 2 files changed, 300 insertions(+), 282 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1e7fd81..18e099c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -121,8 +121,7 @@ int sysctl_tcp_abc __read_mostly;
 /* Adapt the MSS value used to make delayed ack decision to the
  * real world.
  */
-static void tcp_measure_rcv_mss(struct sock *sk,
-				const struct sk_buff *skb)
+static void tcp_measure_rcv_mss(struct sock *sk, const struct sk_buff =
*skb)
 {
 	struct inet_connection_sock *icsk =3D inet_csk(sk);
 	const unsigned int lss =3D icsk->icsk_ack.last_seg_size;
@@ -133,7 +132,7 @@ static void tcp_measure_rcv_mss(struct sock *sk,
 	/* skb->len may jitter because of SACKs, even if peer
 	 * sends good full-sized frames.
 	 */
-	len =3D skb_shinfo(skb)->gso_size ?: skb->len;
+	len =3D skb_shinfo(skb)->gso_size ? : skb->len;
 	if (len >=3D icsk->icsk_ack.rcv_mss) {
 		icsk->icsk_ack.rcv_mss =3D len;
 	} else {
@@ -173,8 +172,8 @@ static void tcp_incr_quickack(struct sock *sk)
 	struct inet_connection_sock *icsk =3D inet_csk(sk);
 	unsigned quickacks =3D tcp_sk(sk)->rcv_wnd / (2 * icsk->icsk_ack.rcv_=
mss);
=20
-	if (quickacks=3D=3D0)
-		quickacks=3D2;
+	if (quickacks =3D=3D 0)
+		quickacks =3D 2;
 	if (quickacks > icsk->icsk_ack.quick)
 		icsk->icsk_ack.quick =3D min(quickacks, TCP_MAX_QUICKACKS);
 }
@@ -199,7 +198,7 @@ static inline int tcp_in_quickack_mode(const struct=
 sock *sk)
=20
 static inline void TCP_ECN_queue_cwr(struct tcp_sock *tp)
 {
-	if (tp->ecn_flags&TCP_ECN_OK)
+	if (tp->ecn_flags & TCP_ECN_OK)
 		tp->ecn_flags |=3D TCP_ECN_QUEUE_CWR;
 }
=20
@@ -216,7 +215,7 @@ static inline void TCP_ECN_withdraw_cwr(struct tcp_=
sock *tp)
=20
 static inline void TCP_ECN_check_ce(struct tcp_sock *tp, struct sk_buf=
f *skb)
 {
-	if (tp->ecn_flags&TCP_ECN_OK) {
+	if (tp->ecn_flags & TCP_ECN_OK) {
 		if (INET_ECN_is_ce(TCP_SKB_CB(skb)->flags))
 			tp->ecn_flags |=3D TCP_ECN_DEMAND_CWR;
 		/* Funny extension: if ECT is not set on a segment,
@@ -229,19 +228,19 @@ static inline void TCP_ECN_check_ce(struct tcp_so=
ck *tp, struct sk_buff *skb)
=20
 static inline void TCP_ECN_rcv_synack(struct tcp_sock *tp, struct tcph=
dr *th)
 {
-	if ((tp->ecn_flags&TCP_ECN_OK) && (!th->ece || th->cwr))
+	if ((tp->ecn_flags & TCP_ECN_OK) && (!th->ece || th->cwr))
 		tp->ecn_flags &=3D ~TCP_ECN_OK;
 }
=20
 static inline void TCP_ECN_rcv_syn(struct tcp_sock *tp, struct tcphdr =
*th)
 {
-	if ((tp->ecn_flags&TCP_ECN_OK) && (!th->ece || !th->cwr))
+	if ((tp->ecn_flags & TCP_ECN_OK) && (!th->ece || !th->cwr))
 		tp->ecn_flags &=3D ~TCP_ECN_OK;
 }
=20
 static inline int TCP_ECN_rcv_ecn_echo(struct tcp_sock *tp, struct tcp=
hdr *th)
 {
-	if (th->ece && !th->syn && (tp->ecn_flags&TCP_ECN_OK))
+	if (th->ece && !th->syn && (tp->ecn_flags & TCP_ECN_OK))
 		return 1;
 	return 0;
 }
@@ -303,8 +302,7 @@ static int __tcp_grow_window(const struct sock *sk,=
 const struct sk_buff *skb)
 	return 0;
 }
=20
-static void tcp_grow_window(struct sock *sk,
-			    struct sk_buff *skb)
+static void tcp_grow_window(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
=20
@@ -318,12 +316,13 @@ static void tcp_grow_window(struct sock *sk,
 		 * will fit to rcvbuf in future.
 		 */
 		if (tcp_win_from_space(skb->truesize) <=3D skb->len)
-			incr =3D 2*tp->advmss;
+			incr =3D 2 * tp->advmss;
 		else
 			incr =3D __tcp_grow_window(sk, skb);
=20
 		if (incr) {
-			tp->rcv_ssthresh =3D min(tp->rcv_ssthresh + incr, tp->window_clamp)=
;
+			tp->rcv_ssthresh =3D min(tp->rcv_ssthresh + incr,
+					       tp->window_clamp);
 			inet_csk(sk)->icsk_ack.quick |=3D 1;
 		}
 	}
@@ -398,10 +397,9 @@ static void tcp_clamp_window(struct sock *sk)
 				    sysctl_tcp_rmem[2]);
 	}
 	if (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf)
-		tp->rcv_ssthresh =3D min(tp->window_clamp, 2U*tp->advmss);
+		tp->rcv_ssthresh =3D min(tp->window_clamp, 2U * tp->advmss);
 }
=20
-
 /* Initialize RCV_MSS value.
  * RCV_MSS is an our guess about MSS used by the peer.
  * We haven't any direct information about the MSS.
@@ -414,7 +412,7 @@ void tcp_initialize_rcv_mss(struct sock *sk)
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	unsigned int hint =3D min_t(unsigned int, tp->advmss, tp->mss_cache);
=20
-	hint =3D min(hint, tp->rcv_wnd/2);
+	hint =3D min(hint, tp->rcv_wnd / 2);
 	hint =3D min(hint, TCP_MIN_RCVMSS);
 	hint =3D max(hint, TCP_MIN_MSS);
=20
@@ -471,16 +469,15 @@ static inline void tcp_rcv_rtt_measure(struct tcp=
_sock *tp)
 		goto new_measure;
 	if (before(tp->rcv_nxt, tp->rcv_rtt_est.seq))
 		return;
-	tcp_rcv_rtt_update(tp,
-			   jiffies - tp->rcv_rtt_est.time,
-			   1);
+	tcp_rcv_rtt_update(tp, jiffies - tp->rcv_rtt_est.time, 1);
=20
 new_measure:
 	tp->rcv_rtt_est.seq =3D tp->rcv_nxt + tp->rcv_wnd;
 	tp->rcv_rtt_est.time =3D tcp_time_stamp;
 }
=20
-static inline void tcp_rcv_rtt_measure_ts(struct sock *sk, const struc=
t sk_buff *skb)
+static inline void tcp_rcv_rtt_measure_ts(struct sock *sk,
+					  const struct sk_buff *skb)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	if (tp->rx_opt.rcv_tsecr &&
@@ -503,8 +500,7 @@ void tcp_rcv_space_adjust(struct sock *sk)
 		goto new_measure;
=20
 	time =3D tcp_time_stamp - tp->rcvq_space.time;
-	if (time < (tp->rcv_rtt_est.rtt >> 3) ||
-	    tp->rcv_rtt_est.rtt =3D=3D 0)
+	if (time < (tp->rcv_rtt_est.rtt >> 3) || tp->rcv_rtt_est.rtt =3D=3D 0=
)
 		return;
=20
 	space =3D 2 * (tp->copied_seq - tp->rcvq_space.seq);
@@ -580,7 +576,7 @@ static void tcp_event_data_recv(struct sock *sk, st=
ruct sk_buff *skb)
 	} else {
 		int m =3D now - icsk->icsk_ack.lrcvtime;
=20
-		if (m <=3D TCP_ATO_MIN/2) {
+		if (m <=3D TCP_ATO_MIN / 2) {
 			/* The fastest case is the first. */
 			icsk->icsk_ack.ato =3D (icsk->icsk_ack.ato >> 1) + TCP_ATO_MIN / 2;
 		} else if (m < icsk->icsk_ack.ato) {
@@ -609,7 +605,7 @@ static u32 tcp_rto_min(struct sock *sk)
 	u32 rto_min =3D TCP_RTO_MIN;
=20
 	if (dst && dst_metric_locked(dst, RTAX_RTO_MIN))
-		rto_min =3D dst->metrics[RTAX_RTO_MIN-1];
+		rto_min =3D dst->metrics[RTAX_RTO_MIN - 1];
 	return rto_min;
 }
=20
@@ -672,14 +668,14 @@ static void tcp_rtt_estimator(struct sock *sk, co=
nst __u32 mrtt)
 		}
 		if (after(tp->snd_una, tp->rtt_seq)) {
 			if (tp->mdev_max < tp->rttvar)
-				tp->rttvar -=3D (tp->rttvar-tp->mdev_max)>>2;
+				tp->rttvar -=3D (tp->rttvar - tp->mdev_max) >> 2;
 			tp->rtt_seq =3D tp->snd_nxt;
 			tp->mdev_max =3D tcp_rto_min(sk);
 		}
 	} else {
 		/* no previous measure. */
-		tp->srtt =3D m<<3;	/* take the measured time to be rtt */
-		tp->mdev =3D m<<1;	/* make sure rto =3D 3*rtt */
+		tp->srtt =3D m << 3;	/* take the measured time to be rtt */
+		tp->mdev =3D m << 1;	/* make sure rto =3D 3*rtt */
 		tp->mdev_max =3D tp->rttvar =3D max(tp->mdev, tcp_rto_min(sk));
 		tp->rtt_seq =3D tp->snd_nxt;
 	}
@@ -733,7 +729,7 @@ void tcp_update_metrics(struct sock *sk)
=20
 	dst_confirm(dst);
=20
-	if (dst && (dst->flags&DST_HOST)) {
+	if (dst && (dst->flags & DST_HOST)) {
 		const struct inet_connection_sock *icsk =3D inet_csk(sk);
 		int m;
=20
@@ -743,7 +739,7 @@ void tcp_update_metrics(struct sock *sk)
 			 * Reset our results.
 			 */
 			if (!(dst_metric_locked(dst, RTAX_RTT)))
-				dst->metrics[RTAX_RTT-1] =3D 0;
+				dst->metrics[RTAX_RTT - 1] =3D 0;
 			return;
 		}
=20
@@ -755,9 +751,9 @@ void tcp_update_metrics(struct sock *sk)
 		 */
 		if (!(dst_metric_locked(dst, RTAX_RTT))) {
 			if (m <=3D 0)
-				dst->metrics[RTAX_RTT-1] =3D tp->srtt;
+				dst->metrics[RTAX_RTT - 1] =3D tp->srtt;
 			else
-				dst->metrics[RTAX_RTT-1] -=3D (m>>3);
+				dst->metrics[RTAX_RTT - 1] -=3D (m >> 3);
 		}
=20
 		if (!(dst_metric_locked(dst, RTAX_RTTVAR))) {
@@ -770,7 +766,7 @@ void tcp_update_metrics(struct sock *sk)
 				m =3D tp->mdev;
=20
 			if (m >=3D dst_metric(dst, RTAX_RTTVAR))
-				dst->metrics[RTAX_RTTVAR-1] =3D m;
+				dst->metrics[RTAX_RTTVAR - 1] =3D m;
 			else
 				dst->metrics[RTAX_RTTVAR-1] -=3D
 					(dst->metrics[RTAX_RTTVAR-1] - m)>>2;
@@ -784,7 +780,7 @@ void tcp_update_metrics(struct sock *sk)
 				dst->metrics[RTAX_SSTHRESH-1] =3D tp->snd_cwnd >> 1;
 			if (!dst_metric_locked(dst, RTAX_CWND) &&
 			    tp->snd_cwnd > dst_metric(dst, RTAX_CWND))
-				dst->metrics[RTAX_CWND-1] =3D tp->snd_cwnd;
+				dst->metrics[RTAX_CWND - 1] =3D tp->snd_cwnd;
 		} else if (tp->snd_cwnd > tp->snd_ssthresh &&
 			   icsk->icsk_ca_state =3D=3D TCP_CA_Open) {
 			/* Cong. avoidance phase, cwnd is reliable. */
@@ -1353,12 +1349,14 @@ static struct sk_buff *tcp_sacktag_walk(struct =
sk_buff *skb, struct sock *sk,
 		}
=20
 		if (in_sack <=3D 0)
-			in_sack =3D tcp_match_skb_to_sack(sk, skb, start_seq, end_seq);
+			in_sack =3D tcp_match_skb_to_sack(sk, skb, start_seq,
+							end_seq);
 		if (unlikely(in_sack < 0))
 			break;
=20
 		if (in_sack)
-			*flag |=3D tcp_sacktag_one(skb, sk, reord, dup_sack, *fack_count);
+			*flag |=3D tcp_sacktag_one(skb, sk, reord, dup_sack,
+						 *fack_count);
=20
 		*fack_count +=3D tcp_skb_pcount(skb);
 	}
@@ -1407,7 +1405,8 @@ static int tcp_sack_cache_ok(struct tcp_sock *tp,=
 struct tcp_sack_block *cache)
 }
=20
 static int
-tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 =
prior_snd_una)
+tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
+			u32 prior_snd_una)
 {
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -1417,7 +1416,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 	struct tcp_sack_block sp[4];
 	struct tcp_sack_block *cache;
 	struct sk_buff *skb;
-	int num_sacks =3D (ptr[1] - TCPOLEN_SACK_BASE)>>3;
+	int num_sacks =3D (ptr[1] - TCPOLEN_SACK_BASE) >> 3;
 	int used_sacks;
 	int reord =3D tp->packets_out;
 	int flag =3D 0;
@@ -1484,17 +1483,17 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
=20
 	/* order SACK blocks to allow in order walk of the retrans queue */
 	for (i =3D used_sacks - 1; i > 0; i--) {
-		for (j =3D 0; j < i; j++){
-			if (after(sp[j].start_seq, sp[j+1].start_seq)) {
+		for (j =3D 0; j < i; j++) {
+			if (after(sp[j].start_seq, sp[j + 1].start_seq)) {
 				struct tcp_sack_block tmp;
=20
 				tmp =3D sp[j];
-				sp[j] =3D sp[j+1];
-				sp[j+1] =3D tmp;
+				sp[j] =3D sp[j + 1];
+				sp[j + 1] =3D tmp;
=20
 				/* Track where the first SACK block goes to */
 				if (j =3D=3D first_sack_index)
-					first_sack_index =3D j+1;
+					first_sack_index =3D j + 1;
 			}
 		}
 	}
@@ -1539,17 +1538,21 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 			/* Head todo? */
 			if (before(start_seq, cache->start_seq)) {
 				skb =3D tcp_sacktag_skip(skb, sk, start_seq);
-				skb =3D tcp_sacktag_walk(skb, sk, next_dup, start_seq,
-						       cache->start_seq, dup_sack,
-						       &fack_count, &reord, &flag);
+				skb =3D tcp_sacktag_walk(skb, sk, next_dup,
+						       start_seq,
+						       cache->start_seq,
+						       dup_sack, &fack_count,
+						       &reord, &flag);
 			}
=20
 			/* Rest of the block already fully processed? */
 			if (!after(end_seq, cache->end_seq))
 				goto advance_sp;
=20
-			skb =3D tcp_maybe_skipping_dsack(skb, sk, next_dup, cache->end_seq,
-						       &fack_count, &reord, &flag);
+			skb =3D tcp_maybe_skipping_dsack(skb, sk, next_dup,
+						       cache->end_seq,
+						       &fack_count, &reord,
+						       &flag);
=20
 			/* ...tail remains todo... */
 			if (tcp_highest_sack_seq(tp) =3D=3D cache->end_seq) {
@@ -1654,10 +1657,10 @@ static void tcp_remove_reno_sacks(struct sock *=
sk, int acked)
=20
 	if (acked > 0) {
 		/* One ACK acked hole. The rest eat duplicate ACKs. */
-		if (acked-1 >=3D tp->sacked_out)
+		if (acked - 1 >=3D tp->sacked_out)
 			tp->sacked_out =3D 0;
 		else
-			tp->sacked_out -=3D acked-1;
+			tp->sacked_out -=3D acked - 1;
 	}
 	tcp_check_reno_reordering(sk, acked);
 	tcp_verify_left_out(tp);
@@ -1691,10 +1694,10 @@ int tcp_use_frto(struct sock *sk)
 	tcp_for_write_queue_from(skb, sk) {
 		if (skb =3D=3D tcp_send_head(sk))
 			break;
-		if (TCP_SKB_CB(skb)->sacked&TCPCB_RETRANS)
+		if (TCP_SKB_CB(skb)->sacked & TCPCB_RETRANS)
 			return 0;
 		/* Short-circuit when first non-SACKed skb has been checked */
-		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED))
+		if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
 			break;
 	}
 	return 1;
@@ -1804,7 +1807,7 @@ static void tcp_enter_frto_loss(struct sock *sk, =
int allowed_segments, int flag)
 		 * Count the retransmission made on RTO correctly (only when
 		 * waiting for the first ACK and did not get it)...
 		 */
-		if ((tp->frto_counter =3D=3D 1) && !(flag&FLAG_DATA_ACKED)) {
+		if ((tp->frto_counter =3D=3D 1) && !(flag & FLAG_DATA_ACKED)) {
 			/* For some reason this R-bit might get cleared? */
 			if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS)
 				tp->retrans_out +=3D tcp_skb_pcount(skb);
@@ -1817,7 +1820,7 @@ static void tcp_enter_frto_loss(struct sock *sk, =
int allowed_segments, int flag)
 		}
=20
 		/* Don't lost mark skbs that were fwd transmitted after RTO */
-		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED) &&
+		if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) &&
 		    !after(TCP_SKB_CB(skb)->end_seq, tp->frto_highmark)) {
 			TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
 			tp->lost_out +=3D tcp_skb_pcount(skb);
@@ -1832,7 +1835,7 @@ static void tcp_enter_frto_loss(struct sock *sk, =
int allowed_segments, int flag)
 	tp->bytes_acked =3D 0;
=20
 	tp->reordering =3D min_t(unsigned int, tp->reordering,
-					     sysctl_tcp_reordering);
+			       sysctl_tcp_reordering);
 	tcp_set_ca_state(sk, TCP_CA_Loss);
 	tp->high_seq =3D tp->frto_highmark;
 	TCP_ECN_queue_cwr(tp);
@@ -1899,7 +1902,7 @@ void tcp_enter_loss(struct sock *sk, int how)
 		if (skb =3D=3D tcp_send_head(sk))
 			break;
=20
-		if (TCP_SKB_CB(skb)->sacked&TCPCB_RETRANS)
+		if (TCP_SKB_CB(skb)->sacked & TCPCB_RETRANS)
 			tp->undo_marker =3D 0;
 		TCP_SKB_CB(skb)->sacked &=3D (~TCPCB_TAGBITS)|TCPCB_SACKED_ACKED;
 		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED) || how) {
@@ -1911,7 +1914,7 @@ void tcp_enter_loss(struct sock *sk, int how)
 	tcp_verify_left_out(tp);
=20
 	tp->reordering =3D min_t(unsigned int, tp->reordering,
-					     sysctl_tcp_reordering);
+			       sysctl_tcp_reordering);
 	tcp_set_ca_state(sk, TCP_CA_Loss);
 	tp->high_seq =3D tp->snd_nxt;
 	TCP_ECN_queue_cwr(tp);
@@ -1943,7 +1946,7 @@ static int tcp_check_sack_reneging(struct sock *s=
k, int flag)
=20
 static inline int tcp_fackets_out(struct tcp_sock *tp)
 {
-	return tcp_is_reno(tp) ? tp->sacked_out+1 : tp->fackets_out;
+	return tcp_is_reno(tp) ? tp->sacked_out + 1 : tp->fackets_out;
 }
=20
 /* Heurestics to calculate number of duplicate ACKs. There's no dupACK=
s
@@ -2116,12 +2119,11 @@ static int tcp_time_to_recover(struct sock *sk)
  * retransmitted past LOST markings in the first place? I'm not fully =
sure
  * about undo and end of connection cases, which can cause R without L=
?
  */
-static void tcp_verify_retransmit_hint(struct tcp_sock *tp,
-				       struct sk_buff *skb)
+static void tcp_verify_retransmit_hint(struct tcp_sock *tp, struct sk_=
buff *skb)
 {
 	if ((tp->retransmit_skb_hint !=3D NULL) &&
 	    before(TCP_SKB_CB(skb)->seq,
-	    TCP_SKB_CB(tp->retransmit_skb_hint)->seq))
+		   TCP_SKB_CB(tp->retransmit_skb_hint)->seq))
 		tp->retransmit_skb_hint =3D NULL;
 }
=20
@@ -2156,7 +2158,7 @@ static void tcp_mark_head_lost(struct sock *sk, i=
nt packets, int fast_rexmit)
 			cnt +=3D tcp_skb_pcount(skb);
=20
 		if (((!fast_rexmit || (tp->lost_out > 0)) && (cnt > packets)) ||
-		     after(TCP_SKB_CB(skb)->end_seq, tp->high_seq))
+		    after(TCP_SKB_CB(skb)->end_seq, tp->high_seq))
 			break;
 		if (!(TCP_SKB_CB(skb)->sacked & (TCPCB_SACKED_ACKED|TCPCB_LOST))) {
 			TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
@@ -2223,7 +2225,7 @@ static void tcp_update_scoreboard(struct sock *sk=
, int fast_rexmit)
 static inline void tcp_moderate_cwnd(struct tcp_sock *tp)
 {
 	tp->snd_cwnd =3D min(tp->snd_cwnd,
-			   tcp_packets_in_flight(tp)+tcp_max_burst(tp));
+			   tcp_packets_in_flight(tp) + tcp_max_burst(tp));
 	tp->snd_cwnd_stamp =3D tcp_time_stamp;
 }
=20
@@ -2243,15 +2245,15 @@ static void tcp_cwnd_down(struct sock *sk, int =
flag)
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	int decr =3D tp->snd_cwnd_cnt + 1;
=20
-	if ((flag&(FLAG_ANY_PROGRESS|FLAG_DSACKING_ACK)) ||
-	    (tcp_is_reno(tp) && !(flag&FLAG_NOT_DUP))) {
-		tp->snd_cwnd_cnt =3D decr&1;
+	if ((flag & (FLAG_ANY_PROGRESS | FLAG_DSACKING_ACK)) ||
+	    (tcp_is_reno(tp) && !(flag & FLAG_NOT_DUP))) {
+		tp->snd_cwnd_cnt =3D decr & 1;
 		decr >>=3D 1;
=20
 		if (decr && tp->snd_cwnd > tcp_cwnd_min(sk))
 			tp->snd_cwnd -=3D decr;
=20
-		tp->snd_cwnd =3D min(tp->snd_cwnd, tcp_packets_in_flight(tp)+1);
+		tp->snd_cwnd =3D min(tp->snd_cwnd, tcp_packets_in_flight(tp) + 1);
 		tp->snd_cwnd_stamp =3D tcp_time_stamp;
 	}
 }
@@ -2295,7 +2297,7 @@ static void tcp_undo_cwr(struct sock *sk, const i=
nt undo)
 		if (icsk->icsk_ca_ops->undo_cwnd)
 			tp->snd_cwnd =3D icsk->icsk_ca_ops->undo_cwnd(sk);
 		else
-			tp->snd_cwnd =3D max(tp->snd_cwnd, tp->snd_ssthresh<<1);
+			tp->snd_cwnd =3D max(tp->snd_cwnd, tp->snd_ssthresh << 1);
=20
 		if (undo && tp->prior_ssthresh > tp->snd_ssthresh) {
 			tp->snd_ssthresh =3D tp->prior_ssthresh;
@@ -2314,8 +2316,7 @@ static void tcp_undo_cwr(struct sock *sk, const i=
nt undo)
=20
 static inline int tcp_may_undo(struct tcp_sock *tp)
 {
-	return tp->undo_marker &&
-		(!tp->undo_retrans || tcp_packet_delayed(tp));
+	return tp->undo_marker && (!tp->undo_retrans || tcp_packet_delayed(tp=
));
 }
=20
 /* People celebrate: "We love our President!" */
@@ -2434,7 +2435,7 @@ static void tcp_try_to_open(struct sock *sk, int =
flag)
 	if (tp->retrans_out =3D=3D 0)
 		tp->retrans_stamp =3D 0;
=20
-	if (flag&FLAG_ECE)
+	if (flag & FLAG_ECE)
 		tcp_enter_cwr(sk, 1);
=20
 	if (inet_csk(sk)->icsk_ca_state !=3D TCP_CA_CWR) {
@@ -2480,7 +2481,6 @@ static void tcp_mtup_probe_success(struct sock *s=
k, struct sk_buff *skb)
 	tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
 }
=20
-
 /* Process an event, which can update packets-in-flight not trivially.
  * Main goal of this function is to calculate new estimate for left_ou=
t,
  * taking into account both packets sitting in receiver's buffer and
@@ -2492,13 +2492,12 @@ static void tcp_mtup_probe_success(struct sock =
*sk, struct sk_buff *skb)
  * It does _not_ decide what to send, it is made in function
  * tcp_xmit_retransmit_queue().
  */
-static void
-tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
+static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int=
 flag)
 {
 	struct inet_connection_sock *icsk =3D inet_csk(sk);
 	struct tcp_sock *tp =3D tcp_sk(sk);
-	int is_dupack =3D !(flag&(FLAG_SND_UNA_ADVANCED|FLAG_NOT_DUP));
-	int do_lost =3D is_dupack || ((flag&FLAG_DATA_SACKED) &&
+	int is_dupack =3D !(flag & (FLAG_SND_UNA_ADVANCED | FLAG_NOT_DUP));
+	int do_lost =3D is_dupack || ((flag & FLAG_DATA_SACKED) &&
 				    (tcp_fackets_out(tp) > tp->reordering));
 	int fast_rexmit =3D 0;
=20
@@ -2509,7 +2508,7 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_a=
cked, int flag)
=20
 	/* Now state machine starts.
 	 * A. ECE, hence prohibit cwnd undoing, the reduction is required. */
-	if (flag&FLAG_ECE)
+	if (flag & FLAG_ECE)
 		tp->prior_ssthresh =3D 0;
=20
 	/* B. In all the states check for reneging SACKs. */
@@ -2521,7 +2520,7 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_a=
cked, int flag)
 	    before(tp->snd_una, tp->high_seq) &&
 	    icsk->icsk_ca_state !=3D TCP_CA_Open &&
 	    tp->fackets_out > tp->reordering) {
-		tcp_mark_head_lost(sk, tp->fackets_out-tp->reordering, 0);
+		tcp_mark_head_lost(sk, tp->fackets_out - tp->reordering, 0);
 		NET_INC_STATS_BH(LINUX_MIB_TCPLOSS);
 	}
=20
@@ -2581,7 +2580,7 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_a=
cked, int flag)
 			do_lost =3D tcp_try_undo_partial(sk, pkts_acked);
 		break;
 	case TCP_CA_Loss:
-		if (flag&FLAG_DATA_ACKED)
+		if (flag & FLAG_DATA_ACKED)
 			icsk->icsk_retransmits =3D 0;
 		if (!tcp_try_undo_loss(sk)) {
 			tcp_moderate_cwnd(tp);
@@ -2631,7 +2630,7 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_a=
cked, int flag)
 		tp->undo_retrans =3D tp->retrans_out;
=20
 		if (icsk->icsk_ca_state < TCP_CA_CWR) {
-			if (!(flag&FLAG_ECE))
+			if (!(flag & FLAG_ECE))
 				tp->prior_ssthresh =3D tcp_current_ssthresh(sk);
 			tp->snd_ssthresh =3D icsk->icsk_ca_ops->ssthresh(sk);
 			TCP_ECN_queue_cwr(tp);
@@ -2725,7 +2724,8 @@ static void tcp_rearm_rto(struct sock *sk)
 	if (!tp->packets_out) {
 		inet_csk_clear_xmit_timer(sk, ICSK_TIME_RETRANS);
 	} else {
-		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, inet_csk(sk)->icsk_=
rto, TCP_RTO_MAX);
+		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
+					  inet_csk(sk)->icsk_rto, TCP_RTO_MAX);
 	}
 }
=20
@@ -2803,8 +2803,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, i=
nt prior_fackets)
 			flag |=3D FLAG_RETRANS_DATA_ACKED;
 			ca_seq_rtt =3D -1;
 			seq_rtt =3D -1;
-			if ((flag & FLAG_DATA_ACKED) ||
-			    (acked_pcount > 1))
+			if ((flag & FLAG_DATA_ACKED) || (acked_pcount > 1))
 				flag |=3D FLAG_NONHEAD_RETRANS_ACKED;
 		} else {
 			ca_seq_rtt =3D now - scb->when;
@@ -2950,8 +2949,9 @@ static inline int tcp_may_raise_cwnd(const struct=
 sock *sk, const int flag)
 /* Check that window update is acceptable.
  * The function assumes that snd_una<=3Dack<=3Dsnd_next.
  */
-static inline int tcp_may_update_window(const struct tcp_sock *tp, con=
st u32 ack,
-					const u32 ack_seq, const u32 nwin)
+static inline int tcp_may_update_window(const struct tcp_sock *tp,
+					const u32 ack, const u32 ack_seq,
+					const u32 nwin)
 {
 	return (after(ack, tp->snd_una) ||
 		after(ack_seq, tp->snd_wl1) ||
@@ -3020,7 +3020,7 @@ static void tcp_ratehalving_spur_to_response(stru=
ct sock *sk)
=20
 static void tcp_undo_spur_to_response(struct sock *sk, int flag)
 {
-	if (flag&FLAG_ECE)
+	if (flag & FLAG_ECE)
 		tcp_ratehalving_spur_to_response(sk);
 	else
 		tcp_undo_cwr(sk, 1);
@@ -3063,7 +3063,7 @@ static int tcp_process_frto(struct sock *sk, int =
flag)
 	tcp_verify_left_out(tp);
=20
 	/* Duplicate the behavior from Loss state (fastretrans_alert) */
-	if (flag&FLAG_DATA_ACKED)
+	if (flag & FLAG_DATA_ACKED)
 		inet_csk(sk)->icsk_retransmits =3D 0;
=20
 	if ((flag & FLAG_NONHEAD_RETRANS_ACKED) ||
@@ -3080,16 +3080,16 @@ static int tcp_process_frto(struct sock *sk, in=
t flag)
 		 * ACK isn't duplicate nor advances window, e.g., opposite dir
 		 * data, winupdate
 		 */
-		if (!(flag&FLAG_ANY_PROGRESS) && (flag&FLAG_NOT_DUP))
+		if (!(flag & FLAG_ANY_PROGRESS) && (flag & FLAG_NOT_DUP))
 			return 1;
=20
-		if (!(flag&FLAG_DATA_ACKED)) {
+		if (!(flag & FLAG_DATA_ACKED)) {
 			tcp_enter_frto_loss(sk, (tp->frto_counter =3D=3D 1 ? 0 : 3),
 					    flag);
 			return 1;
 		}
 	} else {
-		if (!(flag&FLAG_DATA_ACKED) && (tp->frto_counter =3D=3D 1)) {
+		if (!(flag & FLAG_DATA_ACKED) && (tp->frto_counter =3D=3D 1)) {
 			/* Prevent sending of new data. */
 			tp->snd_cwnd =3D min(tp->snd_cwnd,
 					   tcp_packets_in_flight(tp));
@@ -3097,10 +3097,12 @@ static int tcp_process_frto(struct sock *sk, in=
t flag)
 		}
=20
 		if ((tp->frto_counter >=3D 2) &&
-		    (!(flag&FLAG_FORWARD_PROGRESS) ||
-		     ((flag&FLAG_DATA_SACKED) && !(flag&FLAG_ONLY_ORIG_SACKED)))) {
+		    (!(flag & FLAG_FORWARD_PROGRESS) ||
+		     ((flag & FLAG_DATA_SACKED) &&
+		      !(flag & FLAG_ONLY_ORIG_SACKED)))) {
 			/* RFC4138 shortcoming (see comment above) */
-			if (!(flag&FLAG_FORWARD_PROGRESS) && (flag&FLAG_NOT_DUP))
+			if (!(flag & FLAG_FORWARD_PROGRESS) &&
+			    (flag & FLAG_NOT_DUP))
 				return 1;
=20
 			tcp_enter_frto_loss(sk, 3, flag);
@@ -3166,13 +3168,14 @@ static int tcp_ack(struct sock *sk, struct sk_b=
uff *skb, int flag)
 			tp->bytes_acked +=3D ack - prior_snd_una;
 		else if (icsk->icsk_ca_state =3D=3D TCP_CA_Loss)
 			/* we assume just one segment left network */
-			tp->bytes_acked +=3D min(ack - prior_snd_una, tp->mss_cache);
+			tp->bytes_acked +=3D min(ack - prior_snd_una,
+					       tp->mss_cache);
 	}
=20
 	prior_fackets =3D tp->fackets_out;
 	prior_in_flight =3D tcp_packets_in_flight(tp);
=20
-	if (!(flag&FLAG_SLOWPATH) && after(ack, prior_snd_una)) {
+	if (!(flag & FLAG_SLOWPATH) && after(ack, prior_snd_una)) {
 		/* Window is constant, pure forward advance.
 		 * No more checks are required.
 		 * Note, we use the fact that SND.UNA>=3DSND.WL2.
@@ -3224,13 +3227,14 @@ static int tcp_ack(struct sock *sk, struct sk_b=
uff *skb, int flag)
 		if ((flag & FLAG_DATA_ACKED) && !frto_cwnd &&
 		    tcp_may_raise_cwnd(sk, flag))
 			tcp_cong_avoid(sk, ack, prior_in_flight);
-		tcp_fastretrans_alert(sk, prior_packets - tp->packets_out, flag);
+		tcp_fastretrans_alert(sk, prior_packets - tp->packets_out,
+				      flag);
 	} else {
 		if ((flag & FLAG_DATA_ACKED) && !frto_cwnd)
 			tcp_cong_avoid(sk, ack, prior_in_flight);
 	}
=20
-	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag&FLAG_NOT_DUP))
+	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag & FLAG_NOT_DUP))
 		dst_confirm(sk->sk_dst_cache);
=20
 	return 1;
@@ -3255,22 +3259,22 @@ uninteresting_ack:
 	return 0;
 }
=20
-
 /* Look for tcp options. Normally only called on SYN and SYNACK packet=
s.
  * But, this can also be called on packets in the established flow whe=
n
  * the fast version below fails.
  */
-void tcp_parse_options(struct sk_buff *skb, struct tcp_options_receive=
d *opt_rx, int estab)
+void tcp_parse_options(struct sk_buff *skb, struct tcp_options_receive=
d *opt_rx,
+		       int estab)
 {
 	unsigned char *ptr;
 	struct tcphdr *th =3D tcp_hdr(skb);
-	int length=3D(th->doff*4)-sizeof(struct tcphdr);
+	int length =3D (th->doff * 4) - sizeof(struct tcphdr);
=20
 	ptr =3D (unsigned char *)(th + 1);
 	opt_rx->saw_tstamp =3D 0;
=20
 	while (length > 0) {
-		int opcode=3D*ptr++;
+		int opcode =3D *ptr++;
 		int opsize;
=20
 		switch (opcode) {
@@ -3359,7 +3363,7 @@ void tcp_parse_options(struct sk_buff *skb, struc=
t tcp_options_received *opt_rx,
 static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *=
th,
 				  struct tcp_sock *tp)
 {
-	if (th->doff =3D=3D sizeof(struct tcphdr)>>2) {
+	if (th->doff =3D=3D sizeof(struct tcphdr) >> 2) {
 		tp->rx_opt.saw_tstamp =3D 0;
 		return 0;
 	} else if (tp->rx_opt.tstamp_ok &&
@@ -3444,7 +3448,8 @@ static int tcp_disordered_ack(const struct sock *=
sk, const struct sk_buff *skb)
 		(s32)(tp->rx_opt.ts_recent - tp->rx_opt.rcv_tsval) <=3D (inet_csk(sk=
)->icsk_rto * 1024) / HZ);
 }
=20
-static inline int tcp_paws_discard(const struct sock *sk, const struct=
 sk_buff *skb)
+static inline int tcp_paws_discard(const struct sock *sk,
+				   const struct sk_buff *skb)
 {
 	const struct tcp_sock *tp =3D tcp_sk(sk);
 	return ((s32)(tp->rx_opt.ts_recent - tp->rx_opt.rcv_tsval) > TCP_PAWS=
_WINDOW &&
@@ -3476,16 +3481,16 @@ static void tcp_reset(struct sock *sk)
 {
 	/* We want the right error as BSD sees it (and indeed as we do). */
 	switch (sk->sk_state) {
-		case TCP_SYN_SENT:
-			sk->sk_err =3D ECONNREFUSED;
-			break;
-		case TCP_CLOSE_WAIT:
-			sk->sk_err =3D EPIPE;
-			break;
-		case TCP_CLOSE:
-			return;
-		default:
-			sk->sk_err =3D ECONNRESET;
+	case TCP_SYN_SENT:
+		sk->sk_err =3D ECONNREFUSED;
+		break;
+	case TCP_CLOSE_WAIT:
+		sk->sk_err =3D EPIPE;
+		break;
+	case TCP_CLOSE:
+		return;
+	default:
+		sk->sk_err =3D ECONNRESET;
 	}
=20
 	if (!sock_flag(sk, SOCK_DEAD))
@@ -3518,43 +3523,43 @@ static void tcp_fin(struct sk_buff *skb, struct=
 sock *sk, struct tcphdr *th)
 	sock_set_flag(sk, SOCK_DONE);
=20
 	switch (sk->sk_state) {
-		case TCP_SYN_RECV:
-		case TCP_ESTABLISHED:
-			/* Move to CLOSE_WAIT */
-			tcp_set_state(sk, TCP_CLOSE_WAIT);
-			inet_csk(sk)->icsk_ack.pingpong =3D 1;
-			break;
+	case TCP_SYN_RECV:
+	case TCP_ESTABLISHED:
+		/* Move to CLOSE_WAIT */
+		tcp_set_state(sk, TCP_CLOSE_WAIT);
+		inet_csk(sk)->icsk_ack.pingpong =3D 1;
+		break;
=20
-		case TCP_CLOSE_WAIT:
-		case TCP_CLOSING:
-			/* Received a retransmission of the FIN, do
-			 * nothing.
-			 */
-			break;
-		case TCP_LAST_ACK:
-			/* RFC793: Remain in the LAST-ACK state. */
-			break;
+	case TCP_CLOSE_WAIT:
+	case TCP_CLOSING:
+		/* Received a retransmission of the FIN, do
+		 * nothing.
+		 */
+		break;
+	case TCP_LAST_ACK:
+		/* RFC793: Remain in the LAST-ACK state. */
+		break;
=20
-		case TCP_FIN_WAIT1:
-			/* This case occurs when a simultaneous close
-			 * happens, we must ack the received FIN and
-			 * enter the CLOSING state.
-			 */
-			tcp_send_ack(sk);
-			tcp_set_state(sk, TCP_CLOSING);
-			break;
-		case TCP_FIN_WAIT2:
-			/* Received a FIN -- send ACK and enter TIME_WAIT. */
-			tcp_send_ack(sk);
-			tcp_time_wait(sk, TCP_TIME_WAIT, 0);
-			break;
-		default:
-			/* Only TCP_LISTEN and TCP_CLOSE are left, in these
-			 * cases we should never reach this piece of code.
-			 */
-			printk(KERN_ERR "%s: Impossible, sk->sk_state=3D%d\n",
-			       __FUNCTION__, sk->sk_state);
-			break;
+	case TCP_FIN_WAIT1:
+		/* This case occurs when a simultaneous close
+		 * happens, we must ack the received FIN and
+		 * enter the CLOSING state.
+		 */
+		tcp_send_ack(sk);
+		tcp_set_state(sk, TCP_CLOSING);
+		break;
+	case TCP_FIN_WAIT2:
+		/* Received a FIN -- send ACK and enter TIME_WAIT. */
+		tcp_send_ack(sk);
+		tcp_time_wait(sk, TCP_TIME_WAIT, 0);
+		break;
+	default:
+		/* Only TCP_LISTEN and TCP_CLOSE are left, in these
+		 * cases we should never reach this piece of code.
+		 */
+		printk(KERN_ERR "%s: Impossible, sk->sk_state=3D%d\n",
+		       __FUNCTION__, sk->sk_state);
+		break;
 	}
=20
 	/* It _is_ possible, that we have something out-of-order _after_ FIN.
@@ -3577,7 +3582,8 @@ static void tcp_fin(struct sk_buff *skb, struct s=
ock *sk, struct tcphdr *th)
 	}
 }
=20
-static inline int tcp_sack_extend(struct tcp_sack_block *sp, u32 seq, =
u32 end_seq)
+static inline int tcp_sack_extend(struct tcp_sack_block *sp, u32 seq,
+				  u32 end_seq)
 {
 	if (!after(seq, sp->end_seq) && !after(sp->start_seq, end_seq)) {
 		if (before(seq, sp->start_seq))
@@ -3600,7 +3606,8 @@ static void tcp_dsack_set(struct tcp_sock *tp, u3=
2 seq, u32 end_seq)
 		tp->rx_opt.dsack =3D 1;
 		tp->duplicate_sack[0].start_seq =3D seq;
 		tp->duplicate_sack[0].end_seq =3D end_seq;
-		tp->rx_opt.eff_sacks =3D min(tp->rx_opt.num_sacks + 1, 4 - tp->rx_op=
t.tstamp_ok);
+		tp->rx_opt.eff_sacks =3D min(tp->rx_opt.num_sacks + 1,
+					   4 - tp->rx_opt.tstamp_ok);
 	}
 }
=20
@@ -3640,12 +3647,12 @@ static void tcp_sack_maybe_coalesce(struct tcp_=
sock *tp)
 {
 	int this_sack;
 	struct tcp_sack_block *sp =3D &tp->selective_acks[0];
-	struct tcp_sack_block *swalk =3D sp+1;
+	struct tcp_sack_block *swalk =3D sp + 1;
=20
 	/* See if the recent change to the first SACK eats into
 	 * or hits the sequence space of other SACK blocks, if so coalesce.
 	 */
-	for (this_sack =3D 1; this_sack < tp->rx_opt.num_sacks; ) {
+	for (this_sack =3D 1; this_sack < tp->rx_opt.num_sacks;) {
 		if (tcp_sack_extend(sp, swalk->start_seq, swalk->end_seq)) {
 			int i;
=20
@@ -3653,16 +3660,19 @@ static void tcp_sack_maybe_coalesce(struct tcp_=
sock *tp)
 			 * Decrease num_sacks.
 			 */
 			tp->rx_opt.num_sacks--;
-			tp->rx_opt.eff_sacks =3D min(tp->rx_opt.num_sacks + tp->rx_opt.dsac=
k, 4 - tp->rx_opt.tstamp_ok);
-			for (i=3Dthis_sack; i < tp->rx_opt.num_sacks; i++)
-				sp[i] =3D sp[i+1];
+			tp->rx_opt.eff_sacks =3D min(tp->rx_opt.num_sacks +
+						   tp->rx_opt.dsack,
+						   4 - tp->rx_opt.tstamp_ok);
+			for (i =3D this_sack; i < tp->rx_opt.num_sacks; i++)
+				sp[i] =3D sp[i + 1];
 			continue;
 		}
 		this_sack++, swalk++;
 	}
 }
=20
-static inline void tcp_sack_swap(struct tcp_sack_block *sack1, struct =
tcp_sack_block *sack2)
+static inline void tcp_sack_swap(struct tcp_sack_block *sack1,
+				 struct tcp_sack_block *sack2)
 {
 	__u32 tmp;
=20
@@ -3685,11 +3695,11 @@ static void tcp_sack_new_ofo_skb(struct sock *s=
k, u32 seq, u32 end_seq)
 	if (!cur_sacks)
 		goto new_sack;
=20
-	for (this_sack=3D0; this_sack<cur_sacks; this_sack++, sp++) {
+	for (this_sack =3D 0; this_sack < cur_sacks; this_sack++, sp++) {
 		if (tcp_sack_extend(sp, seq, end_seq)) {
 			/* Rotate this_sack to the first one. */
-			for (; this_sack>0; this_sack--, sp--)
-				tcp_sack_swap(sp, sp-1);
+			for (; this_sack > 0; this_sack--, sp--)
+				tcp_sack_swap(sp, sp - 1);
 			if (cur_sacks > 1)
 				tcp_sack_maybe_coalesce(tp);
 			return;
@@ -3708,14 +3718,15 @@ static void tcp_sack_new_ofo_skb(struct sock *s=
k, u32 seq, u32 end_seq)
 		sp--;
 	}
 	for (; this_sack > 0; this_sack--, sp--)
-		*sp =3D *(sp-1);
+		*sp =3D *(sp - 1);
=20
 new_sack:
 	/* Build the new head SACK, and we're done. */
 	sp->start_seq =3D seq;
 	sp->end_seq =3D end_seq;
 	tp->rx_opt.num_sacks++;
-	tp->rx_opt.eff_sacks =3D min(tp->rx_opt.num_sacks + tp->rx_opt.dsack,=
 4 - tp->rx_opt.tstamp_ok);
+	tp->rx_opt.eff_sacks =3D min(tp->rx_opt.num_sacks + tp->rx_opt.dsack,
+				   4 - tp->rx_opt.tstamp_ok);
 }
=20
 /* RCV.NXT advances, some SACKs should be eaten. */
@@ -3733,7 +3744,7 @@ static void tcp_sack_remove(struct tcp_sock *tp)
 		return;
 	}
=20
-	for (this_sack =3D 0; this_sack < num_sacks; ) {
+	for (this_sack =3D 0; this_sack < num_sacks;) {
 		/* Check if the start of the sack is covered by RCV.NXT. */
 		if (!before(tp->rcv_nxt, sp->start_seq)) {
 			int i;
@@ -3752,7 +3763,9 @@ static void tcp_sack_remove(struct tcp_sock *tp)
 	}
 	if (num_sacks !=3D tp->rx_opt.num_sacks) {
 		tp->rx_opt.num_sacks =3D num_sacks;
-		tp->rx_opt.eff_sacks =3D min(tp->rx_opt.num_sacks + tp->rx_opt.dsack=
, 4 - tp->rx_opt.tstamp_ok);
+		tp->rx_opt.eff_sacks =3D min(tp->rx_opt.num_sacks +
+					   tp->rx_opt.dsack,
+					   4 - tp->rx_opt.tstamp_ok);
 	}
 }
=20
@@ -3805,14 +3818,14 @@ static void tcp_data_queue(struct sock *sk, str=
uct sk_buff *skb)
 	if (TCP_SKB_CB(skb)->seq =3D=3D TCP_SKB_CB(skb)->end_seq)
 		goto drop;
=20
-	__skb_pull(skb, th->doff*4);
+	__skb_pull(skb, th->doff * 4);
=20
 	TCP_ECN_accept_cwr(tp, skb);
=20
 	if (tp->rx_opt.dsack) {
 		tp->rx_opt.dsack =3D 0;
 		tp->rx_opt.eff_sacks =3D min_t(unsigned int, tp->rx_opt.num_sacks,
-						    4 - tp->rx_opt.tstamp_ok);
+					     4 - tp->rx_opt.tstamp_ok);
 	}
=20
 	/*  Queue data for delivery to the user.
@@ -3828,7 +3841,7 @@ static void tcp_data_queue(struct sock *sk, struc=
t sk_buff *skb)
 		    tp->copied_seq =3D=3D tp->rcv_nxt && tp->ucopy.len &&
 		    sock_owned_by_user(sk) && !tp->urg_data) {
 			int chunk =3D min_t(unsigned int, skb->len,
-							tp->ucopy.len);
+					  tp->ucopy.len);
=20
 			__set_current_state(TASK_RUNNING);
=20
@@ -3945,7 +3958,7 @@ drop:
 			tp->selective_acks[0].end_seq =3D
 						TCP_SKB_CB(skb)->end_seq;
 		}
-		__skb_queue_head(&tp->out_of_order_queue,skb);
+		__skb_queue_head(&tp->out_of_order_queue, skb);
 	} else {
 		struct sk_buff *skb1 =3D tp->out_of_order_queue.prev;
 		u32 seq =3D TCP_SKB_CB(skb)->seq;
@@ -3968,10 +3981,10 @@ drop:
 			if (!after(TCP_SKB_CB(skb1)->seq, seq))
 				break;
 		} while ((skb1 =3D skb1->prev) !=3D
-			 (struct sk_buff*)&tp->out_of_order_queue);
+			 (struct sk_buff *)&tp->out_of_order_queue);
=20
 		/* Do skb overlap to previous one? */
-		if (skb1 !=3D (struct sk_buff*)&tp->out_of_order_queue &&
+		if (skb1 !=3D (struct sk_buff *)&tp->out_of_order_queue &&
 		    before(seq, TCP_SKB_CB(skb1)->end_seq)) {
 			if (!after(end_seq, TCP_SKB_CB(skb1)->end_seq)) {
 				/* All the bits are present. Drop. */
@@ -3981,7 +3994,8 @@ drop:
 			}
 			if (after(seq, TCP_SKB_CB(skb1)->seq)) {
 				/* Partial overlap. */
-				tcp_dsack_set(tp, seq, TCP_SKB_CB(skb1)->end_seq);
+				tcp_dsack_set(tp, seq,
+					      TCP_SKB_CB(skb1)->end_seq);
 			} else {
 				skb1 =3D skb1->prev;
 			}
@@ -3990,15 +4004,17 @@ drop:
=20
 		/* And clean segments covered by new one as whole. */
 		while ((skb1 =3D skb->next) !=3D
-		       (struct sk_buff*)&tp->out_of_order_queue &&
+		       (struct sk_buff *)&tp->out_of_order_queue &&
 		       after(end_seq, TCP_SKB_CB(skb1)->seq)) {
-		       if (before(end_seq, TCP_SKB_CB(skb1)->end_seq)) {
-			       tcp_dsack_extend(tp, TCP_SKB_CB(skb1)->seq, end_seq);
-			       break;
-		       }
-		       __skb_unlink(skb1, &tp->out_of_order_queue);
-		       tcp_dsack_extend(tp, TCP_SKB_CB(skb1)->seq, TCP_SKB_CB(skb1)-=
>end_seq);
-		       __kfree_skb(skb1);
+			if (before(end_seq, TCP_SKB_CB(skb1)->end_seq)) {
+				tcp_dsack_extend(tp, TCP_SKB_CB(skb1)->seq,
+						 end_seq);
+				break;
+			}
+			__skb_unlink(skb1, &tp->out_of_order_queue);
+			tcp_dsack_extend(tp, TCP_SKB_CB(skb1)->seq,
+					 TCP_SKB_CB(skb1)->end_seq);
+			__kfree_skb(skb1);
 		}
=20
 add_sack:
@@ -4021,7 +4037,7 @@ tcp_collapse(struct sock *sk, struct sk_buff_head=
 *list,
=20
 	/* First, check that queue is collapsible and find
 	 * the point where collapsing can be useful. */
-	for (skb =3D head; skb !=3D tail; ) {
+	for (skb =3D head; skb !=3D tail;) {
 		/* No new bits? It is possible on ofo queue. */
 		if (!before(start, TCP_SKB_CB(skb)->end_seq)) {
 			struct sk_buff *next =3D skb->next;
@@ -4059,9 +4075,9 @@ tcp_collapse(struct sock *sk, struct sk_buff_head=
 *list,
 		/* Too big header? This can happen with IPv6. */
 		if (copy < 0)
 			return;
-		if (end-start < copy)
-			copy =3D end-start;
-		nskb =3D alloc_skb(copy+header, GFP_ATOMIC);
+		if (end - start < copy)
+			copy =3D end - start;
+		nskb =3D alloc_skb(copy + header, GFP_ATOMIC);
 		if (!nskb)
 			return;
=20
@@ -4171,7 +4187,7 @@ static int tcp_prune_queue(struct sock *sk)
 	tcp_collapse_ofo_queue(sk);
 	tcp_collapse(sk, &sk->sk_receive_queue,
 		     sk->sk_receive_queue.next,
-		     (struct sk_buff*)&sk->sk_receive_queue,
+		     (struct sk_buff *)&sk->sk_receive_queue,
 		     tp->copied_seq, tp->rcv_nxt);
 	sk_mem_reclaim(sk);
=20
@@ -4210,7 +4226,6 @@ static int tcp_prune_queue(struct sock *sk)
 	return -1;
 }
=20
-
 /* RFC2861, slow part. Adjust cwnd, after it was not full during one r=
to.
  * As additional protections, we do not touch cwnd in retransmission p=
hases,
  * and if application hit its sndbuf limit recently.
@@ -4272,8 +4287,8 @@ static void tcp_new_space(struct sock *sk)
 		int sndmem =3D max_t(u32, tp->rx_opt.mss_clamp, tp->mss_cache) +
 			MAX_TCP_HEADER + 16 + sizeof(struct sk_buff),
 		    demanded =3D max_t(unsigned int, tp->snd_cwnd,
-						   tp->reordering + 1);
-		sndmem *=3D 2*demanded;
+				     tp->reordering + 1);
+		sndmem *=3D 2 * demanded;
 		if (sndmem > sk->sk_sndbuf)
 			sk->sk_sndbuf =3D min(sndmem, sysctl_tcp_wmem[2]);
 		tp->snd_cwnd_stamp =3D tcp_time_stamp;
@@ -4314,8 +4329,7 @@ static void __tcp_ack_snd_check(struct sock *sk, =
int ofo_possible)
 	    /* We ACK each frame or... */
 	    tcp_in_quickack_mode(sk) ||
 	    /* We have out of order data. */
-	    (ofo_possible &&
-	     skb_peek(&tp->out_of_order_queue))) {
+	    (ofo_possible && skb_peek(&tp->out_of_order_queue))) {
 		/* Then ack it now */
 		tcp_send_ack(sk);
 	} else {
@@ -4343,7 +4357,7 @@ static inline void tcp_ack_snd_check(struct sock =
*sk)
  *	either form (or just set the sysctl tcp_stdurg).
  */
=20
-static void tcp_check_urg(struct sock * sk, struct tcphdr * th)
+static void tcp_check_urg(struct sock *sk, struct tcphdr *th)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	u32 ptr =3D ntohs(th->urg_ptr);
@@ -4392,8 +4406,7 @@ static void tcp_check_urg(struct sock * sk, struc=
t tcphdr * th)
 	 * buggy users.
 	 */
 	if (tp->urg_seq =3D=3D tp->copied_seq && tp->urg_data &&
-	    !sock_flag(sk, SOCK_URGINLINE) &&
-	    tp->copied_seq !=3D tp->rcv_nxt) {
+	    !sock_flag(sk, SOCK_URGINLINE) && tp->copied_seq !=3D tp->rcv_nxt=
) {
 		struct sk_buff *skb =3D skb_peek(&sk->sk_receive_queue);
 		tp->copied_seq++;
 		if (skb && !before(tp->copied_seq, TCP_SKB_CB(skb)->end_seq)) {
@@ -4402,8 +4415,8 @@ static void tcp_check_urg(struct sock * sk, struc=
t tcphdr * th)
 		}
 	}
=20
-	tp->urg_data   =3D TCP_URG_NOTYET;
-	tp->urg_seq    =3D ptr;
+	tp->urg_data =3D TCP_URG_NOTYET;
+	tp->urg_seq =3D ptr;
=20
 	/* Disable header prediction. */
 	tp->pred_flags =3D 0;
@@ -4416,7 +4429,7 @@ static void tcp_urg(struct sock *sk, struct sk_bu=
ff *skb, struct tcphdr *th)
=20
 	/* Check if we get a new urgent pointer - normally not. */
 	if (th->urg)
-		tcp_check_urg(sk,th);
+		tcp_check_urg(sk, th);
=20
 	/* Do we wait for any urgent data? - normally not... */
 	if (tp->urg_data =3D=3D TCP_URG_NOTYET) {
@@ -4458,7 +4471,8 @@ static int tcp_copy_to_iovec(struct sock *sk, str=
uct sk_buff *skb, int hlen)
 	return err;
 }
=20
-static __sum16 __tcp_checksum_complete_user(struct sock *sk, struct sk=
_buff *skb)
+static __sum16 __tcp_checksum_complete_user(struct sock *sk,
+					    struct sk_buff *skb)
 {
 	__sum16 result;
=20
@@ -4472,14 +4486,16 @@ static __sum16 __tcp_checksum_complete_user(str=
uct sock *sk, struct sk_buff *skb
 	return result;
 }
=20
-static inline int tcp_checksum_complete_user(struct sock *sk, struct s=
k_buff *skb)
+static inline int tcp_checksum_complete_user(struct sock *sk,
+					     struct sk_buff *skb)
 {
 	return !skb_csum_unnecessary(skb) &&
-		__tcp_checksum_complete_user(sk, skb);
+	       __tcp_checksum_complete_user(sk, skb);
 }
=20
 #ifdef CONFIG_NET_DMA
-static int tcp_dma_try_early_copy(struct sock *sk, struct sk_buff *skb=
, int hlen)
+static int tcp_dma_try_early_copy(struct sock *sk, struct sk_buff *skb=
,
+				  int hlen)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	int chunk =3D skb->len - hlen;
@@ -4495,7 +4511,9 @@ static int tcp_dma_try_early_copy(struct sock *sk=
, struct sk_buff *skb, int hlen
 	if (tp->ucopy.dma_chan && skb_csum_unnecessary(skb)) {
=20
 		dma_cookie =3D dma_skb_copy_datagram_iovec(tp->ucopy.dma_chan,
-			skb, hlen, tp->ucopy.iov, chunk, tp->ucopy.pinned_list);
+							 skb, hlen,
+							 tp->ucopy.iov, chunk,
+							 tp->ucopy.pinned_list);
=20
 		if (dma_cookie < 0)
 			goto out;
@@ -4577,7 +4595,7 @@ int tcp_rcv_established(struct sock *sk, struct s=
k_buff *skb,
 	 */
=20
 	if ((tcp_flag_word(th) & TCP_HP_BITS) =3D=3D tp->pred_flags &&
-		TCP_SKB_CB(skb)->seq =3D=3D tp->rcv_nxt) {
+	    TCP_SKB_CB(skb)->seq =3D=3D tp->rcv_nxt) {
 		int tcp_header_len =3D tp->tcp_header_len;
=20
 		/* Timestamp header prediction: tcp_header_len
@@ -4646,7 +4664,8 @@ int tcp_rcv_established(struct sock *sk, struct s=
k_buff *skb,
 					eaten =3D 1;
 				}
 #endif
-				if (tp->ucopy.task =3D=3D current && sock_owned_by_user(sk) && !co=
pied_early) {
+				if (tp->ucopy.task =3D=3D current &&
+				    sock_owned_by_user(sk) && !copied_early) {
 					__set_current_state(TASK_RUNNING);
=20
 					if (!tcp_copy_to_iovec(sk, skb, tcp_header_len))
@@ -4693,7 +4712,7 @@ int tcp_rcv_established(struct sock *sk, struct s=
k_buff *skb,
 				NET_INC_STATS_BH(LINUX_MIB_TCPHPHITS);
=20
 				/* Bulk data transfer: receiver */
-				__skb_pull(skb,tcp_header_len);
+				__skb_pull(skb, tcp_header_len);
 				__skb_queue_tail(&sk->sk_receive_queue, skb);
 				skb_set_owner_r(skb, sk);
 				tp->rcv_nxt =3D TCP_SKB_CB(skb)->end_seq;
@@ -4725,7 +4744,7 @@ no_ack:
 	}
=20
 slow_path:
-	if (len < (th->doff<<2) || tcp_checksum_complete_user(sk, skb))
+	if (len < (th->doff << 2) || tcp_checksum_complete_user(sk, skb))
 		goto csum_error;
=20
 	/*
@@ -4975,7 +4994,8 @@ discard:
 	}
=20
 	/* PAWS check. */
-	if (tp->rx_opt.ts_recent_stamp && tp->rx_opt.saw_tstamp && tcp_paws_c=
heck(&tp->rx_opt, 0))
+	if (tp->rx_opt.ts_recent_stamp && tp->rx_opt.saw_tstamp &&
+	    tcp_paws_check(&tp->rx_opt, 0))
 		goto discard_and_undo;
=20
 	if (th->syn) {
@@ -5010,7 +5030,6 @@ discard:
 		tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
 		tcp_initialize_rcv_mss(sk);
=20
-
 		tcp_send_synack(sk);
 #if 0
 		/* Note, we could accept data and URG from this segment.
@@ -5042,7 +5061,6 @@ reset_and_undo:
 	return 1;
 }
=20
-
 /*
  *	This function implements the receiving procedure of RFC 793 for
  *	all states except ESTABLISHED and TIME_WAIT.
@@ -5164,7 +5182,7 @@ int tcp_rcv_state_process(struct sock *sk, struct=
 sk_buff *skb,
 				 */
 				if (sk->sk_socket)
 					sk_wake_async(sk,
-							SOCK_WAKE_IO, POLL_OUT);
+						      SOCK_WAKE_IO, POLL_OUT);
=20
 				tp->snd_una =3D TCP_SKB_CB(skb)->ack_seq;
 				tp->snd_wnd =3D ntohs(th->window) <<
@@ -5176,8 +5194,8 @@ int tcp_rcv_state_process(struct sock *sk, struct=
 sk_buff *skb,
 				 * and does not calculate rtt.
 				 * Fix it at least with timestamps.
 				 */
-				if (tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr &&
-				    !tp->srtt)
+				if (tp->rx_opt.saw_tstamp &&
+				    tp->rx_opt.rcv_tsecr && !tp->srtt)
 					tcp_ack_saw_tstamp(sk, 0);
=20
 				if (tp->rx_opt.tstamp_ok)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 454cf84..bb7e80a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -221,14 +221,14 @@ void tcp_select_initial_window(int __space, __u32=
 mss,
 	 * following RFC2414. Senders, not following this RFC,
 	 * will be satisfied with 2.
 	 */
-	if (mss > (1<<*rcv_wscale)) {
+	if (mss > (1 << *rcv_wscale)) {
 		int init_cwnd =3D 4;
-		if (mss > 1460*3)
+		if (mss > 1460 * 3)
 			init_cwnd =3D 2;
 		else if (mss > 1460)
 			init_cwnd =3D 3;
-		if (*rcv_wnd > init_cwnd*mss)
-			*rcv_wnd =3D init_cwnd*mss;
+		if (*rcv_wnd > init_cwnd * mss)
+			*rcv_wnd =3D init_cwnd * mss;
 	}
=20
 	/* Set the clamp no higher than max representable value */
@@ -278,11 +278,10 @@ static u16 tcp_select_window(struct sock *sk)
 	return new_win;
 }
=20
-static inline void TCP_ECN_send_synack(struct tcp_sock *tp,
-				       struct sk_buff *skb)
+static inline void TCP_ECN_send_synack(struct tcp_sock *tp, struct sk_=
buff *skb)
 {
 	TCP_SKB_CB(skb)->flags &=3D ~TCPCB_FLAG_CWR;
-	if (!(tp->ecn_flags&TCP_ECN_OK))
+	if (!(tp->ecn_flags & TCP_ECN_OK))
 		TCP_SKB_CB(skb)->flags &=3D ~TCPCB_FLAG_ECE;
 }
=20
@@ -292,7 +291,7 @@ static inline void TCP_ECN_send_syn(struct sock *sk=
, struct sk_buff *skb)
=20
 	tp->ecn_flags =3D 0;
 	if (sysctl_tcp_ecn) {
-		TCP_SKB_CB(skb)->flags |=3D TCPCB_FLAG_ECE|TCPCB_FLAG_CWR;
+		TCP_SKB_CB(skb)->flags |=3D TCPCB_FLAG_ECE | TCPCB_FLAG_CWR;
 		tp->ecn_flags =3D TCP_ECN_OK;
 	}
 }
@@ -314,7 +313,7 @@ static inline void TCP_ECN_send(struct sock *sk, st=
ruct sk_buff *skb,
 		if (skb->len !=3D tcp_header_len &&
 		    !before(TCP_SKB_CB(skb)->seq, tp->snd_nxt)) {
 			INET_ECN_xmit(sk);
-			if (tp->ecn_flags&TCP_ECN_QUEUE_CWR) {
+			if (tp->ecn_flags & TCP_ECN_QUEUE_CWR) {
 				tp->ecn_flags &=3D ~TCP_ECN_QUEUE_CWR;
 				tcp_hdr(skb)->cwr =3D 1;
 				skb_shinfo(skb)->gso_type |=3D SKB_GSO_TCP_ECN;
@@ -431,7 +430,7 @@ static void tcp_syn_build_options(__be32 *ptr, int =
mss, int ts, int sack,
 			       (TCPOPT_NOP << 16) |
 			       (TCPOPT_MD5SIG << 8) |
 			       TCPOLEN_MD5SIG);
-		*md5_hash =3D (__u8 *) ptr;
+		*md5_hash =3D (__u8 *)ptr;
 	}
 #endif
 }
@@ -447,7 +446,8 @@ static void tcp_syn_build_options(__be32 *ptr, int =
mss, int ts, int sack,
  * We are working here with either a clone of the original
  * SKB, or a fresh unique copy made by the retransmit engine.
  */
-static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int =
clone_it, gfp_t gfp_mask)
+static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int =
clone_it,
+			    gfp_t gfp_mask)
 {
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
 	struct inet_sock *inet;
@@ -551,8 +551,8 @@ static int tcp_transmit_skb(struct sock *sk, struct=
 sk_buff *skb, int clone_it,
 	th->urg_ptr		=3D 0;
=20
 	if (unlikely(tp->urg_mode &&
-		     between(tp->snd_up, tcb->seq+1, tcb->seq+0xFFFF))) {
-		th->urg_ptr		=3D htons(tp->snd_up-tcb->seq);
+		     between(tp->snd_up, tcb->seq + 1, tcb->seq + 0xFFFF))) {
+		th->urg_ptr		=3D htons(tp->snd_up - tcb->seq);
 		th->urg			=3D 1;
 	}
=20
@@ -616,7 +616,6 @@ static int tcp_transmit_skb(struct sock *sk, struct=
 sk_buff *skb, int clone_it,
 #undef SYSCTL_FLAG_SACK
 }
=20
-
 /* This routine just queue's the buffer
  *
  * NOTE: probe0 timer is not checked, do not forget tcp_push_pending_f=
rames,
@@ -634,7 +633,8 @@ static void tcp_queue_skb(struct sock *sk, struct s=
k_buff *skb)
 	sk_mem_charge(sk, skb->truesize);
 }
=20
-static void tcp_set_skb_tso_segs(struct sock *sk, struct sk_buff *skb,=
 unsigned int mss_now)
+static void tcp_set_skb_tso_segs(struct sock *sk, struct sk_buff *skb,
+				 unsigned int mss_now)
 {
 	if (skb->len <=3D mss_now || !sk_can_gso(sk)) {
 		/* Avoid the costly divide in the normal
@@ -670,7 +670,8 @@ static void tcp_adjust_fackets_out(struct sock *sk,=
 struct sk_buff *skb,
  * packet to the list.  This won't be called frequently, I hope.
  * Remember, these are still headerless SKBs at this point.
  */
-int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len, unsign=
ed int mss_now)
+int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
+		 unsigned int mss_now)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *buff;
@@ -708,13 +709,14 @@ int tcp_fragment(struct sock *sk, struct sk_buff =
*skb, u32 len, unsigned int mss
=20
 	/* PSH and FIN should only be set in the second packet. */
 	flags =3D TCP_SKB_CB(skb)->flags;
-	TCP_SKB_CB(skb)->flags =3D flags & ~(TCPCB_FLAG_FIN|TCPCB_FLAG_PSH);
+	TCP_SKB_CB(skb)->flags =3D flags & ~(TCPCB_FLAG_FIN | TCPCB_FLAG_PSH)=
;
 	TCP_SKB_CB(buff)->flags =3D flags;
 	TCP_SKB_CB(buff)->sacked =3D TCP_SKB_CB(skb)->sacked;
=20
 	if (!skb_shinfo(skb)->nr_frags && skb->ip_summed !=3D CHECKSUM_PARTIA=
L) {
 		/* Copy and checksum data tail into the new buffer. */
-		buff->csum =3D csum_partial_copy_nocheck(skb->data + len, skb_put(bu=
ff, nsize),
+		buff->csum =3D csum_partial_copy_nocheck(skb->data + len,
+						       skb_put(buff, nsize),
 						       nsize, 0);
=20
 		skb_trim(skb, len);
@@ -781,7 +783,7 @@ static void __pskb_trim_head(struct sk_buff *skb, i=
nt len)
=20
 	eat =3D len;
 	k =3D 0;
-	for (i=3D0; i<skb_shinfo(skb)->nr_frags; i++) {
+	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		if (skb_shinfo(skb)->frags[i].size <=3D eat) {
 			put_page(skb_shinfo(skb)->frags[i].page);
 			eat -=3D skb_shinfo(skb)->frags[i].size;
@@ -804,8 +806,7 @@ static void __pskb_trim_head(struct sk_buff *skb, i=
nt len)
=20
 int tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
 {
-	if (skb_cloned(skb) &&
-	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+	if (skb_cloned(skb) && pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
 		return -ENOMEM;
=20
 	/* If len =3D=3D headlen, we avoid __skb_pull to preserve alignment. =
*/
@@ -909,7 +910,6 @@ void tcp_mtup_init(struct sock *sk)
    NOTE2. inet_csk(sk)->icsk_pmtu_cookie and tp->mss_cache
    are READ ONLY outside this function.		--ANK (980731)
  */
-
 unsigned int tcp_sync_mss(struct sock *sk, u32 pmtu)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -922,8 +922,8 @@ unsigned int tcp_sync_mss(struct sock *sk, u32 pmtu=
)
 	mss_now =3D tcp_mtu_to_mss(sk, pmtu);
=20
 	/* Bound mss with half of window */
-	if (tp->max_window && mss_now > (tp->max_window>>1))
-		mss_now =3D max((tp->max_window>>1), 68U - tp->tcp_header_len);
+	if (tp->max_window && mss_now > (tp->max_window >> 1))
+		mss_now =3D max((tp->max_window >> 1), 68U - tp->tcp_header_len);
=20
 	/* And store cached results */
 	icsk->icsk_pmtu_cookie =3D pmtu;
@@ -977,8 +977,7 @@ unsigned int tcp_current_mss(struct sock *sk, int l=
arge_allowed)
 				  inet_csk(sk)->icsk_ext_hdr_len -
 				  tp->tcp_header_len);
=20
-		if (tp->max_window &&
-		    (xmit_size_goal > (tp->max_window >> 1)))
+		if (tp->max_window && (xmit_size_goal > (tp->max_window >> 1)))
 			xmit_size_goal =3D max((tp->max_window >> 1),
 					     68U - tp->tcp_header_len);
=20
@@ -990,7 +989,6 @@ unsigned int tcp_current_mss(struct sock *sk, int l=
arge_allowed)
 }
=20
 /* Congestion window validation. (RFC2861) */
-
 static void tcp_cwnd_validate(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -1017,8 +1015,7 @@ static void tcp_cwnd_validate(struct sock *sk)
  * per input skb which could be mostly avoided here (if desired).
  */
 static unsigned int tcp_mss_split_point(struct sock *sk, struct sk_buf=
f *skb,
-					unsigned int mss_now,
-					unsigned int cwnd)
+					unsigned int mss_now, unsigned int cwnd)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	u32 needed, window, cwnd_len;
@@ -1039,7 +1036,8 @@ static unsigned int tcp_mss_split_point(struct so=
ck *sk, struct sk_buff *skb,
 /* Can at least one segment of SKB be sent right now, according to the
  * congestion window rules?  If so, return how many segments are allow=
ed.
  */
-static inline unsigned int tcp_cwnd_test(struct tcp_sock *tp, struct s=
k_buff *skb)
+static inline unsigned int tcp_cwnd_test(struct tcp_sock *tp,
+					 struct sk_buff *skb)
 {
 	u32 in_flight, cwnd;
=20
@@ -1059,13 +1057,12 @@ static inline unsigned int tcp_cwnd_test(struct=
 tcp_sock *tp, struct sk_buff *sk
 /* This must be invoked the first time we consider transmitting
  * SKB onto the wire.
  */
-static int tcp_init_tso_segs(struct sock *sk, struct sk_buff *skb, uns=
igned int mss_now)
+static int tcp_init_tso_segs(struct sock *sk, struct sk_buff *skb,
+			     unsigned int mss_now)
 {
 	int tso_segs =3D tcp_skb_pcount(skb);
=20
-	if (!tso_segs ||
-	    (tso_segs > 1 &&
-	     tcp_skb_mss(skb) !=3D mss_now)) {
+	if (!tso_segs || (tso_segs > 1 && tcp_skb_mss(skb) !=3D mss_now)) {
 		tcp_set_skb_tso_segs(sk, skb, mss_now);
 		tso_segs =3D tcp_skb_pcount(skb);
 	}
@@ -1085,16 +1082,13 @@ static inline int tcp_minshall_check(const stru=
ct tcp_sock *tp)
  * 4. Or TCP_CORK is not set, and all sent packets are ACKed.
  *    With Minshall's modification: all sent small packets are ACKed.
  */
-
 static inline int tcp_nagle_check(const struct tcp_sock *tp,
 				  const struct sk_buff *skb,
 				  unsigned mss_now, int nonagle)
 {
 	return (skb->len < mss_now &&
-		((nonagle&TCP_NAGLE_CORK) ||
-		 (!nonagle &&
-		  tp->packets_out &&
-		  tcp_minshall_check(tp))));
+		((nonagle & TCP_NAGLE_CORK) ||
+		 (!nonagle && tp->packets_out && tcp_minshall_check(tp))));
 }
=20
 /* Return non-zero if the Nagle test allows this packet to be
@@ -1126,7 +1120,8 @@ static inline int tcp_nagle_test(struct tcp_sock =
*tp, struct sk_buff *skb,
 }
=20
 /* Does at least the first segment of SKB fit into the send window? */
-static inline int tcp_snd_wnd_test(struct tcp_sock *tp, struct sk_buff=
 *skb, unsigned int cur_mss)
+static inline int tcp_snd_wnd_test(struct tcp_sock *tp, struct sk_buff=
 *skb,
+				   unsigned int cur_mss)
 {
 	u32 end_seq =3D TCP_SKB_CB(skb)->end_seq;
=20
@@ -1152,8 +1147,7 @@ static unsigned int tcp_snd_test(struct sock *sk,=
 struct sk_buff *skb,
 		return 0;
=20
 	cwnd_quota =3D tcp_cwnd_test(tp, skb);
-	if (cwnd_quota &&
-	    !tcp_snd_wnd_test(tp, skb, cur_mss))
+	if (cwnd_quota && !tcp_snd_wnd_test(tp, skb, cur_mss))
 		cwnd_quota =3D 0;
=20
 	return cwnd_quota;
@@ -1177,7 +1171,8 @@ int tcp_may_send_now(struct sock *sk)
  * know that all the data is in scatter-gather pages, and that the
  * packet has never been sent out before (and thus is not cloned).
  */
-static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned=
 int len, unsigned int mss_now)
+static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned=
 int len,
+			unsigned int mss_now)
 {
 	struct sk_buff *buff;
 	int nlen =3D skb->len - len;
@@ -1203,7 +1198,7 @@ static int tso_fragment(struct sock *sk, struct s=
k_buff *skb, unsigned int len,
=20
 	/* PSH and FIN should only be set in the second packet. */
 	flags =3D TCP_SKB_CB(skb)->flags;
-	TCP_SKB_CB(skb)->flags =3D flags & ~(TCPCB_FLAG_FIN|TCPCB_FLAG_PSH);
+	TCP_SKB_CB(skb)->flags =3D flags & ~(TCPCB_FLAG_FIN | TCPCB_FLAG_PSH)=
;
 	TCP_SKB_CB(buff)->flags =3D flags;
=20
 	/* This packet was never sent out yet, so no SACK bits. */
@@ -1247,8 +1242,7 @@ static int tcp_tso_should_defer(struct sock *sk, =
struct sk_buff *skb)
=20
 	in_flight =3D tcp_packets_in_flight(tp);
=20
-	BUG_ON(tcp_skb_pcount(skb) <=3D 1 ||
-	       (tp->snd_cwnd <=3D in_flight));
+	BUG_ON(tcp_skb_pcount(skb) <=3D 1 || (tp->snd_cwnd <=3D in_flight));
=20
 	send_win =3D tcp_wnd_end(tp) - TCP_SKB_CB(skb)->seq;
=20
@@ -1281,7 +1275,7 @@ static int tcp_tso_should_defer(struct sock *sk, =
struct sk_buff *skb)
 	}
=20
 	/* Ok, it looks like it is advisable to defer.  */
-	tp->tso_deferred =3D 1 | (jiffies<<1);
+	tp->tso_deferred =3D 1 | (jiffies << 1);
=20
 	return 1;
=20
@@ -1293,7 +1287,8 @@ send_now:
 /* Create a new MTU probe if we are ready.
  * Returns 0 if we should wait to probe (no cwnd available),
  *         1 if a probe was sent,
- *         -1 otherwise */
+ *         -1 otherwise
+ */
 static int tcp_mtu_probe(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -1318,7 +1313,7 @@ static int tcp_mtu_probe(struct sock *sk)
=20
 	/* Very simple search strategy: just double the MSS. */
 	mss_now =3D tcp_current_mss(sk, 0);
-	probe_size =3D 2*tp->mss_cache;
+	probe_size =3D 2 * tp->mss_cache;
 	size_needed =3D probe_size + (tp->reordering + 1) * tp->mss_cache;
 	if (probe_size > tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_high)) {
 		/* TODO: set timer for probe_converge_event */
@@ -1366,7 +1361,8 @@ static int tcp_mtu_probe(struct sock *sk)
 			skb_copy_bits(skb, 0, skb_put(nskb, copy), copy);
 		else
 			nskb->csum =3D skb_copy_and_csum_bits(skb, 0,
-					 skb_put(nskb, copy), copy, nskb->csum);
+							    skb_put(nskb, copy),
+							    copy, nskb->csum);
=20
 		if (skb->len <=3D copy) {
 			/* We've eaten all the data from this skb.
@@ -1380,7 +1376,8 @@ static int tcp_mtu_probe(struct sock *sk)
 			if (!skb_shinfo(skb)->nr_frags) {
 				skb_pull(skb, copy);
 				if (skb->ip_summed !=3D CHECKSUM_PARTIAL)
-					skb->csum =3D csum_partial(skb->data, skb->len, 0);
+					skb->csum =3D csum_partial(skb->data,
+								 skb->len, 0);
 			} else {
 				__pskb_trim_head(skb, copy);
 				tcp_set_skb_tso_segs(sk, skb, mss_now);
@@ -1400,7 +1397,7 @@ static int tcp_mtu_probe(struct sock *sk)
 	TCP_SKB_CB(nskb)->when =3D tcp_time_stamp;
 	if (!tcp_transmit_skb(sk, nskb, 1, GFP_ATOMIC)) {
 		/* Decrement cwnd here because we are sending
-		* effectively two packets. */
+		 * effectively two packets. */
 		tp->snd_cwnd--;
 		tcp_event_new_data_sent(sk, nskb);
=20
@@ -1414,7 +1411,6 @@ static int tcp_mtu_probe(struct sock *sk)
 	return -1;
 }
=20
-
 /* This routine writes packets to the network.  It advances the
  * send_head.  This happens as incoming acks open up the remote
  * window for us.
@@ -1626,7 +1622,8 @@ u32 __tcp_select_window(struct sock *sk)
 		icsk->icsk_ack.quick =3D 0;
=20
 		if (tcp_memory_pressure)
-			tp->rcv_ssthresh =3D min(tp->rcv_ssthresh, 4U*tp->advmss);
+			tp->rcv_ssthresh =3D min(tp->rcv_ssthresh,
+					       4U * tp->advmss);
=20
 		if (free_space < mss)
 			return 0;
@@ -1659,7 +1656,7 @@ u32 __tcp_select_window(struct sock *sk)
 		 * is too small.
 		 */
 		if (window <=3D free_space - mss || window > free_space)
-			window =3D (free_space/mss)*mss;
+			window =3D (free_space / mss) * mss;
 		else if (mss =3D=3D full_space &&
 			 free_space > window + (full_space >> 1))
 			window =3D free_space;
@@ -1669,7 +1666,8 @@ u32 __tcp_select_window(struct sock *sk)
 }
=20
 /* Attempt to collapse two adjacent SKB's during retransmission. */
-static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *=
skb, int mss_now)
+static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *=
skb,
+				     int mss_now)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *next_skb =3D tcp_write_queue_next(sk, skb);
@@ -1762,12 +1760,12 @@ void tcp_simple_retransmit(struct sock *sk)
 		if (skb =3D=3D tcp_send_head(sk))
 			break;
 		if (skb->len > mss &&
-		    !(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED)) {
-			if (TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_RETRANS) {
+		    !(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)) {
+			if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS) {
 				TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_RETRANS;
 				tp->retrans_out -=3D tcp_skb_pcount(skb);
 			}
-			if (!(TCP_SKB_CB(skb)->sacked&TCPCB_LOST)) {
+			if (!(TCP_SKB_CB(skb)->sacked & TCPCB_LOST)) {
 				TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
 				tp->lost_out +=3D tcp_skb_pcount(skb);
 				lost =3D 1;
@@ -1846,8 +1844,10 @@ int tcp_retransmit_skb(struct sock *sk, struct s=
k_buff *skb)
 	    (skb->len < (cur_mss >> 1)) &&
 	    (tcp_write_queue_next(sk, skb) !=3D tcp_send_head(sk)) &&
 	    (!tcp_skb_is_last(sk, skb)) &&
-	    (skb_shinfo(skb)->nr_frags =3D=3D 0 && skb_shinfo(tcp_write_queue=
_next(sk, skb))->nr_frags =3D=3D 0) &&
-	    (tcp_skb_pcount(skb) =3D=3D 1 && tcp_skb_pcount(tcp_write_queue_n=
ext(sk, skb)) =3D=3D 1) &&
+	    (skb_shinfo(skb)->nr_frags =3D=3D 0 &&
+	     skb_shinfo(tcp_write_queue_next(sk, skb))->nr_frags =3D=3D 0) &&
+	    (tcp_skb_pcount(skb) =3D=3D 1 &&
+	     tcp_skb_pcount(tcp_write_queue_next(sk, skb)) =3D=3D 1) &&
 	    (sysctl_tcp_retrans_collapse !=3D 0))
 		tcp_retrans_try_collapse(sk, skb, cur_mss);
=20
@@ -1885,7 +1885,7 @@ int tcp_retransmit_skb(struct sock *sk, struct sk=
_buff *skb)
 		tp->total_retrans++;
=20
 #if FASTRETRANS_DEBUG > 0
-		if (TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_RETRANS) {
+		if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS) {
 			if (net_ratelimit())
 				printk(KERN_DEBUG "retrans_out leaked.\n");
 		}
@@ -1927,7 +1927,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 	if (tp->retransmit_skb_hint) {
 		skb =3D tp->retransmit_skb_hint;
 		packet_cnt =3D tp->retransmit_cnt_hint;
-	}else{
+	} else {
 		skb =3D tcp_write_queue_head(sk);
 		packet_cnt =3D 0;
 	}
@@ -1954,7 +1954,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 				return;
=20
 			if (sacked & TCPCB_LOST) {
-				if (!(sacked&(TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))) {
+				if (!(sacked & (TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))) {
 					if (tcp_retransmit_skb(sk, skb)) {
 						tp->retransmit_skb_hint =3D NULL;
 						return;
@@ -2036,7 +2036,6 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 	}
 }
=20
-
 /* Send a fin.  The caller locks the socket for us.  This cannot be
  * allowed to fail queueing a FIN frame under any circumstances.
  */
@@ -2122,14 +2121,14 @@ void tcp_send_active_reset(struct sock *sk, gfp=
_t priority)
  */
 int tcp_send_synack(struct sock *sk)
 {
-	struct sk_buff* skb;
+	struct sk_buff *skb;
=20
 	skb =3D tcp_write_queue_head(sk);
-	if (skb =3D=3D NULL || !(TCP_SKB_CB(skb)->flags&TCPCB_FLAG_SYN)) {
+	if (skb =3D=3D NULL || !(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_SYN)) {
 		printk(KERN_DEBUG "tcp_send_synack: wrong queue state\n");
 		return -EFAULT;
 	}
-	if (!(TCP_SKB_CB(skb)->flags&TCPCB_FLAG_ACK)) {
+	if (!(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_ACK)) {
 		if (skb_cloned(skb)) {
 			struct sk_buff *nskb =3D skb_copy(skb, GFP_ATOMIC);
 			if (nskb =3D=3D NULL)
@@ -2153,8 +2152,8 @@ int tcp_send_synack(struct sock *sk)
 /*
  * Prepare a SYN-ACK.
  */
-struct sk_buff * tcp_make_synack(struct sock *sk, struct dst_entry *ds=
t,
-				 struct request_sock *req)
+struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst=
,
+				struct request_sock *req)
 {
 	struct inet_request_sock *ireq =3D inet_rsk(req);
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -2372,9 +2371,10 @@ void tcp_send_delayed_ack(struct sock *sk)
=20
 	if (ato > TCP_DELACK_MIN) {
 		const struct tcp_sock *tp =3D tcp_sk(sk);
-		int max_ato =3D HZ/2;
+		int max_ato =3D HZ / 2;
=20
-		if (icsk->icsk_ack.pingpong || (icsk->icsk_ack.pending & ICSK_ACK_PU=
SHED))
+		if (icsk->icsk_ack.pingpong ||
+		    (icsk->icsk_ack.pending & ICSK_ACK_PUSHED))
 			max_ato =3D TCP_DELACK_MAX;
=20
 		/* Slow path, intersegment interval is "high". */
@@ -2384,7 +2384,7 @@ void tcp_send_delayed_ack(struct sock *sk)
 		 * directly.
 		 */
 		if (tp->srtt) {
-			int rtt =3D max(tp->srtt>>3, TCP_DELACK_MIN);
+			int rtt =3D max(tp->srtt >> 3, TCP_DELACK_MIN);
=20
 			if (rtt < max_ato)
 				max_ato =3D rtt;
--=20
1.5.0.6

