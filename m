From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 7/9] [TCP]: reduce tcp_output's indentation levels a bit
Date: Mon, 31 Dec 2007 12:47:55 +0200
Message-ID: <11990980774113-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11990980772344-git-send-email-ilpo.jarvinen@helsinki.fi> <1199098077874-git-send-email-ilpo.jarvinen@helsinki.fi> <11990980773391-git-send-email-ilpo.jarvinen@helsinki.fi> <11990980771495-git-send-email-ilpo.jarvinen@helsinki.fi> <11990980772309-git-send-email-ilpo.jarvinen@helsinki.fi> <11990980773732-git-send-email-ilpo.jarvinen@helsinki.fi> <11990980772445-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41549 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755916AbXLaKsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 05:48:01 -0500
In-Reply-To: <11990980772445-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |  239 +++++++++++++++++++++++++----------------=
--------
 1 files changed, 121 insertions(+), 118 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 182ae21..199253c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1668,75 +1668,77 @@ static void tcp_retrans_try_collapse(struct soc=
k *sk, struct sk_buff *skb, int m
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *next_skb =3D tcp_write_queue_next(sk, skb);
+	int skb_size, next_skb_size;
+	u16 flags;
=20
 	/* The first test we must make is that neither of these two
 	 * SKB's are still referenced by someone else.
 	 */
-	if (!skb_cloned(skb) && !skb_cloned(next_skb)) {
-		int skb_size =3D skb->len, next_skb_size =3D next_skb->len;
-		u16 flags =3D TCP_SKB_CB(skb)->flags;
+	if (skb_cloned(skb) || skb_cloned(next_skb))
+		return;
=20
-		/* Also punt if next skb has been SACK'd. */
-		if (TCP_SKB_CB(next_skb)->sacked & TCPCB_SACKED_ACKED)
-			return;
+	skb_size =3D skb->len;
+	next_skb_size =3D next_skb->len;
+	flags =3D TCP_SKB_CB(skb)->flags;
=20
-		/* Next skb is out of window. */
-		if (after(TCP_SKB_CB(next_skb)->end_seq, tcp_wnd_end(tp)))
-			return;
+	/* Also punt if next skb has been SACK'd. */
+	if (TCP_SKB_CB(next_skb)->sacked & TCPCB_SACKED_ACKED)
+		return;
=20
-		/* Punt if not enough space exists in the first SKB for
-		 * the data in the second, or the total combined payload
-		 * would exceed the MSS.
-		 */
-		if ((next_skb_size > skb_tailroom(skb)) ||
-		    ((skb_size + next_skb_size) > mss_now))
-			return;
+	/* Next skb is out of window. */
+	if (after(TCP_SKB_CB(next_skb)->end_seq, tcp_wnd_end(tp)))
+		return;
=20
-		BUG_ON(tcp_skb_pcount(skb) !=3D 1 ||
-		       tcp_skb_pcount(next_skb) !=3D 1);
+	/* Punt if not enough space exists in the first SKB for
+	 * the data in the second, or the total combined payload
+	 * would exceed the MSS.
+	 */
+	if ((next_skb_size > skb_tailroom(skb)) ||
+	    ((skb_size + next_skb_size) > mss_now))
+		return;
=20
-		tcp_highest_sack_combine(sk, next_skb, skb);
+	BUG_ON(tcp_skb_pcount(skb) !=3D 1 || tcp_skb_pcount(next_skb) !=3D 1)=
;
=20
-		/* Ok.	We will be able to collapse the packet. */
-		tcp_unlink_write_queue(next_skb, sk);
+	tcp_highest_sack_combine(sk, next_skb, skb);
=20
-		skb_copy_from_linear_data(next_skb,
-					  skb_put(skb, next_skb_size),
-					  next_skb_size);
+	/* Ok.	We will be able to collapse the packet. */
+	tcp_unlink_write_queue(next_skb, sk);
=20
-		if (next_skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
-			skb->ip_summed =3D CHECKSUM_PARTIAL;
+	skb_copy_from_linear_data(next_skb, skb_put(skb, next_skb_size),
+				  next_skb_size);
=20
-		if (skb->ip_summed !=3D CHECKSUM_PARTIAL)
-			skb->csum =3D csum_block_add(skb->csum, next_skb->csum, skb_size);
+	if (next_skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
+		skb->ip_summed =3D CHECKSUM_PARTIAL;
=20
-		/* Update sequence range on original skb. */
-		TCP_SKB_CB(skb)->end_seq =3D TCP_SKB_CB(next_skb)->end_seq;
+	if (skb->ip_summed !=3D CHECKSUM_PARTIAL)
+		skb->csum =3D csum_block_add(skb->csum, next_skb->csum, skb_size);
=20
-		/* Merge over control information. */
-		flags |=3D TCP_SKB_CB(next_skb)->flags; /* This moves PSH/FIN etc. o=
ver */
-		TCP_SKB_CB(skb)->flags =3D flags;
+	/* Update sequence range on original skb. */
+	TCP_SKB_CB(skb)->end_seq =3D TCP_SKB_CB(next_skb)->end_seq;
=20
-		/* All done, get rid of second SKB and account for it so
-		 * packet counting does not break.
-		 */
-		TCP_SKB_CB(skb)->sacked |=3D TCP_SKB_CB(next_skb)->sacked & TCPCB_EV=
ER_RETRANS;
-		if (TCP_SKB_CB(next_skb)->sacked&TCPCB_SACKED_RETRANS)
-			tp->retrans_out -=3D tcp_skb_pcount(next_skb);
-		if (TCP_SKB_CB(next_skb)->sacked&TCPCB_LOST)
-			tp->lost_out -=3D tcp_skb_pcount(next_skb);
-		/* Reno case is special. Sigh... */
-		if (tcp_is_reno(tp) && tp->sacked_out)
-			tcp_dec_pcount_approx(&tp->sacked_out, next_skb);
-
-		tcp_adjust_fackets_out(sk, next_skb, tcp_skb_pcount(next_skb));
-		tp->packets_out -=3D tcp_skb_pcount(next_skb);
-
-		/* changed transmit queue under us so clear hints */
-		tcp_clear_retrans_hints_partial(tp);
-
-		sk_wmem_free_skb(sk, next_skb);
-	}
+	/* Merge over control information. */
+	flags |=3D TCP_SKB_CB(next_skb)->flags; /* This moves PSH/FIN etc. ov=
er */
+	TCP_SKB_CB(skb)->flags =3D flags;
+
+	/* All done, get rid of second SKB and account for it so
+	 * packet counting does not break.
+	 */
+	TCP_SKB_CB(skb)->sacked |=3D TCP_SKB_CB(next_skb)->sacked & TCPCB_EVE=
R_RETRANS;
+	if (TCP_SKB_CB(next_skb)->sacked & TCPCB_SACKED_RETRANS)
+		tp->retrans_out -=3D tcp_skb_pcount(next_skb);
+	if (TCP_SKB_CB(next_skb)->sacked & TCPCB_LOST)
+		tp->lost_out -=3D tcp_skb_pcount(next_skb);
+	/* Reno case is special. Sigh... */
+	if (tcp_is_reno(tp) && tp->sacked_out)
+		tcp_dec_pcount_approx(&tp->sacked_out, next_skb);
+
+	tcp_adjust_fackets_out(sk, next_skb, tcp_skb_pcount(next_skb));
+	tp->packets_out -=3D tcp_skb_pcount(next_skb);
+
+	/* changed transmit queue under us so clear hints */
+	tcp_clear_retrans_hints_partial(tp);
+
+	sk_wmem_free_skb(sk, next_skb);
 }
=20
 /* Do a simple retransmit without using the backoff mechanisms in
@@ -2411,37 +2413,38 @@ void tcp_send_delayed_ack(struct sock *sk)
 /* This routine sends an ack and also updates the window. */
 void tcp_send_ack(struct sock *sk)
 {
-	/* If we have been reset, we may not send again. */
-	if (sk->sk_state !=3D TCP_CLOSE) {
-		struct sk_buff *buff;
+	struct sk_buff *buff;
=20
-		/* We are not putting this on the write queue, so
-		 * tcp_transmit_skb() will set the ownership to this
-		 * sock.
-		 */
-		buff =3D alloc_skb(MAX_TCP_HEADER, GFP_ATOMIC);
-		if (buff =3D=3D NULL) {
-			inet_csk_schedule_ack(sk);
-			inet_csk(sk)->icsk_ack.ato =3D TCP_ATO_MIN;
-			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
-						  TCP_DELACK_MAX, TCP_RTO_MAX);
-			return;
-		}
+	/* If we have been reset, we may not send again. */
+	if (sk->sk_state =3D=3D TCP_CLOSE)
+		return;
=20
-		/* Reserve space for headers and prepare control bits. */
-		skb_reserve(buff, MAX_TCP_HEADER);
-		buff->csum =3D 0;
-		TCP_SKB_CB(buff)->flags =3D TCPCB_FLAG_ACK;
-		TCP_SKB_CB(buff)->sacked =3D 0;
-		skb_shinfo(buff)->gso_segs =3D 1;
-		skb_shinfo(buff)->gso_size =3D 0;
-		skb_shinfo(buff)->gso_type =3D 0;
-
-		/* Send it off, this clears delayed acks for us. */
-		TCP_SKB_CB(buff)->seq =3D TCP_SKB_CB(buff)->end_seq =3D tcp_acceptab=
le_seq(sk);
-		TCP_SKB_CB(buff)->when =3D tcp_time_stamp;
-		tcp_transmit_skb(sk, buff, 0, GFP_ATOMIC);
+	/* We are not putting this on the write queue, so
+	 * tcp_transmit_skb() will set the ownership to this
+	 * sock.
+	 */
+	buff =3D alloc_skb(MAX_TCP_HEADER, GFP_ATOMIC);
+	if (buff =3D=3D NULL) {
+		inet_csk_schedule_ack(sk);
+		inet_csk(sk)->icsk_ack.ato =3D TCP_ATO_MIN;
+		inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
+					  TCP_DELACK_MAX, TCP_RTO_MAX);
+		return;
 	}
+
+	/* Reserve space for headers and prepare control bits. */
+	skb_reserve(buff, MAX_TCP_HEADER);
+	buff->csum =3D 0;
+	TCP_SKB_CB(buff)->flags =3D TCPCB_FLAG_ACK;
+	TCP_SKB_CB(buff)->sacked =3D 0;
+	skb_shinfo(buff)->gso_segs =3D 1;
+	skb_shinfo(buff)->gso_size =3D 0;
+	skb_shinfo(buff)->gso_type =3D 0;
+
+	/* Send it off, this clears delayed acks for us. */
+	TCP_SKB_CB(buff)->seq =3D TCP_SKB_CB(buff)->end_seq =3D tcp_acceptabl=
e_seq(sk);
+	TCP_SKB_CB(buff)->when =3D tcp_time_stamp;
+	tcp_transmit_skb(sk, buff, 0, GFP_ATOMIC);
 }
=20
 /* This routine sends a packet with an out of date sequence
@@ -2486,46 +2489,46 @@ static int tcp_xmit_probe_skb(struct sock *sk, =
int urgent)
=20
 int tcp_write_wakeup(struct sock *sk)
 {
-	if (sk->sk_state !=3D TCP_CLOSE) {
-		struct tcp_sock *tp =3D tcp_sk(sk);
-		struct sk_buff *skb;
-
-		if ((skb =3D tcp_send_head(sk)) !=3D NULL &&
-		    before(TCP_SKB_CB(skb)->seq, tcp_wnd_end(tp))) {
-			int err;
-			unsigned int mss =3D tcp_current_mss(sk, 0);
-			unsigned int seg_size =3D tcp_wnd_end(tp) - TCP_SKB_CB(skb)->seq;
-
-			if (before(tp->pushed_seq, TCP_SKB_CB(skb)->end_seq))
-				tp->pushed_seq =3D TCP_SKB_CB(skb)->end_seq;
-
-			/* We are probing the opening of a window
-			 * but the window size is !=3D 0
-			 * must have been a result SWS avoidance ( sender )
-			 */
-			if (seg_size < TCP_SKB_CB(skb)->end_seq - TCP_SKB_CB(skb)->seq ||
-			    skb->len > mss) {
-				seg_size =3D min(seg_size, mss);
-				TCP_SKB_CB(skb)->flags |=3D TCPCB_FLAG_PSH;
-				if (tcp_fragment(sk, skb, seg_size, mss))
-					return -1;
-			} else if (!tcp_skb_pcount(skb))
-				tcp_set_skb_tso_segs(sk, skb, mss);
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct sk_buff *skb;
=20
+	if (sk->sk_state =3D=3D TCP_CLOSE)
+		return -1;
+
+	if ((skb =3D tcp_send_head(sk)) !=3D NULL &&
+	    before(TCP_SKB_CB(skb)->seq, tcp_wnd_end(tp))) {
+		int err;
+		unsigned int mss =3D tcp_current_mss(sk, 0);
+		unsigned int seg_size =3D tcp_wnd_end(tp) - TCP_SKB_CB(skb)->seq;
+
+		if (before(tp->pushed_seq, TCP_SKB_CB(skb)->end_seq))
+			tp->pushed_seq =3D TCP_SKB_CB(skb)->end_seq;
+
+		/* We are probing the opening of a window
+		 * but the window size is !=3D 0
+		 * must have been a result SWS avoidance ( sender )
+		 */
+		if (seg_size < TCP_SKB_CB(skb)->end_seq - TCP_SKB_CB(skb)->seq ||
+		    skb->len > mss) {
+			seg_size =3D min(seg_size, mss);
 			TCP_SKB_CB(skb)->flags |=3D TCPCB_FLAG_PSH;
-			TCP_SKB_CB(skb)->when =3D tcp_time_stamp;
-			err =3D tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
-			if (!err)
-				tcp_event_new_data_sent(sk, skb);
-			return err;
-		} else {
-			if (tp->urg_mode &&
-			    between(tp->snd_up, tp->snd_una+1, tp->snd_una+0xFFFF))
-				tcp_xmit_probe_skb(sk, 1);
-			return tcp_xmit_probe_skb(sk, 0);
-		}
+			if (tcp_fragment(sk, skb, seg_size, mss))
+				return -1;
+		} else if (!tcp_skb_pcount(skb))
+			tcp_set_skb_tso_segs(sk, skb, mss);
+
+		TCP_SKB_CB(skb)->flags |=3D TCPCB_FLAG_PSH;
+		TCP_SKB_CB(skb)->when =3D tcp_time_stamp;
+		err =3D tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
+		if (!err)
+			tcp_event_new_data_sent(sk, skb);
+		return err;
+	} else {
+		if (tp->urg_mode &&
+		    between(tp->snd_up, tp->snd_una + 1, tp->snd_una + 0xFFFF))
+			tcp_xmit_probe_skb(sk, 1);
+		return tcp_xmit_probe_skb(sk, 0);
 	}
-	return -1;
 }
=20
 /* A window probe timeout has occurred.  If window is not closed send
--=20
1.5.0.6

