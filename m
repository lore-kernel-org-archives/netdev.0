From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 3/3] [TCP]: Added emptylines after the new tcp_sock *tp initialization
Date: Mon, 16 Apr 2007 15:48:48 +0300
Message-ID: <1176727728949-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1176727728729-git-send-email-ilpo.jarvinen@helsinki.fi> <1176727728273-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38431 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030510AbXDPMsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 08:48:51 -0400
In-Reply-To: <1176727728273-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Improves readability a bit here and there (this is likely less
than complete change anyway).

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c  |   10 ++++++++++
 net/ipv4/tcp_output.c |    2 ++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 877239f..49af779 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -257,6 +257,7 @@ static void tcp_grow_window(struct sock=20
 			    struct sk_buff *skb)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
+
 	/* Check #1 */
 	if (tp->rcv_ssthresh < tp->window_clamp &&
 	    (int)tp->rcv_ssthresh < tcp_space(sk) &&
@@ -1548,6 +1549,7 @@ static inline int tcp_skb_timedout(struc
 static inline int tcp_head_timedout(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
+
 	return tp->packets_out &&
 	       tcp_skb_timedout(sk, tcp_write_queue_head(sk));
 }
@@ -1717,6 +1719,7 @@ static void tcp_add_reno_sack(struct soc
 static void tcp_remove_reno_sacks(struct sock *sk, int acked)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
+
 	if (acked > 0) {
 		/* One ACK acked hole. The rest eat duplicate ACKs. */
 		if (acked-1 >=3D tp->sacked_out)
@@ -1782,6 +1785,7 @@ static void tcp_mark_head_lost(struct so
 static void tcp_update_scoreboard(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
+
 	if (IsFack(tp)) {
 		int lost =3D tp->fackets_out - tp->reordering;
 		if (lost <=3D 0)
@@ -1928,6 +1932,7 @@ static inline int tcp_may_undo(struct tc
 static int tcp_try_undo_recovery(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
+
 	if (tcp_may_undo(tp)) {
 		/* Happy end! We did not retransmit anything
 		 * or our original transmission succeeded.
@@ -1955,6 +1960,7 @@ static int tcp_try_undo_recovery(struct=20
 static void tcp_try_undo_dsack(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
+
 	if (tp->undo_marker && !tp->undo_retrans) {
 		DBGUNDO(sk, "D-SACK");
 		tcp_undo_cwr(sk, 1);
@@ -1998,6 +2004,7 @@ static int tcp_try_undo_partial(struct s
 static int tcp_try_undo_loss(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
+
 	if (tcp_may_undo(tp)) {
 		struct sk_buff *skb;
 		tcp_for_write_queue(skb, sk) {
@@ -2033,6 +2040,7 @@ static inline void tcp_complete_cwr(stru
 static void tcp_try_to_open(struct sock *sk, int flag)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
+
 	tp->left_out =3D tp->sacked_out;
=20
 	if (tp->retrans_out =3D=3D 0)
@@ -2331,6 +2339,7 @@ static void tcp_cong_avoid(struct sock *
 static void tcp_ack_packets_out(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
+
 	if (!tp->packets_out) {
 		inet_csk_clear_xmit_timer(sk, ICSK_TIME_RETRANS);
 	} else {
@@ -3822,6 +3831,7 @@ void tcp_cwnd_application_limited(struct
 static int tcp_should_expand_sndbuf(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
+
 	/* If the user specified a specific send buffer setting, do
 	 * not modify it.
 	 */
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d17159a..2634aee 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -66,6 +66,7 @@ static void update_send_head(struct sock
 			     struct sk_buff *skb)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
+
 	tcp_advance_send_head(sk, skb);
 	tp->snd_nxt =3D TCP_SKB_CB(skb)->end_seq;
 	tcp_packets_out_inc(sk, skb);
@@ -80,6 +81,7 @@ static void update_send_head(struct sock
 static inline __u32 tcp_acceptable_seq(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
+
 	if (!before(tp->snd_una+tp->snd_wnd, tp->snd_nxt))
 		return tp->snd_nxt;
 	else
--=20
1.4.2

