From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 04/21] [TCP] Cong.ctrl modules: remove unused good_ack from cong_avoid
Date: Sun,  2 Dec 2007 00:47:59 +0200
Message-ID: <11965492961750-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11965492963603-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492964079-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296202-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296278-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33125 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752405AbXLAWsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 17:48:19 -0500
In-Reply-To: <1196549296278-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h        |    4 ++--
 net/ipv4/tcp_bic.c       |    3 +--
 net/ipv4/tcp_cong.c      |    2 +-
 net/ipv4/tcp_cubic.c     |    3 +--
 net/ipv4/tcp_highspeed.c |    3 +--
 net/ipv4/tcp_htcp.c      |    3 +--
 net/ipv4/tcp_hybla.c     |    5 ++---
 net/ipv4/tcp_illinois.c  |    3 +--
 net/ipv4/tcp_input.c     |    9 ++++-----
 net/ipv4/tcp_lp.c        |    4 ++--
 net/ipv4/tcp_scalable.c  |    3 +--
 net/ipv4/tcp_vegas.c     |    7 +++----
 net/ipv4/tcp_veno.c      |    7 +++----
 net/ipv4/tcp_yeah.c      |    3 +--
 14 files changed, 24 insertions(+), 35 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7e58326..cdd0050 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -652,7 +652,7 @@ struct tcp_congestion_ops {
 	/* lower bound for congestion window (optional) */
 	u32 (*min_cwnd)(const struct sock *sk);
 	/* do new cwnd calculation (required) */
-	void (*cong_avoid)(struct sock *sk, u32 ack, u32 in_flight, int good_=
ack);
+	void (*cong_avoid)(struct sock *sk, u32 ack, u32 in_flight);
 	/* call before changing ca_state (optional) */
 	void (*set_state)(struct sock *sk, u8 new_state);
 	/* call when cwnd event occurs (optional) */
@@ -683,7 +683,7 @@ extern void tcp_slow_start(struct tcp_sock *tp);
=20
 extern struct tcp_congestion_ops tcp_init_congestion_ops;
 extern u32 tcp_reno_ssthresh(struct sock *sk);
-extern void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 in_fligh=
t, int flag);
+extern void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 in_fligh=
t);
 extern u32 tcp_reno_min_cwnd(const struct sock *sk);
 extern struct tcp_congestion_ops tcp_reno;
=20
diff --git a/net/ipv4/tcp_bic.c b/net/ipv4/tcp_bic.c
index 5dba0fc..5212ed9 100644
--- a/net/ipv4/tcp_bic.c
+++ b/net/ipv4/tcp_bic.c
@@ -136,8 +136,7 @@ static inline void bictcp_update(struct bictcp *ca,=
 u32 cwnd)
 		ca->cnt =3D 1;
 }
=20
-static void bictcp_cong_avoid(struct sock *sk, u32 ack,
-			      u32 in_flight, int data_acked)
+static void bictcp_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct bictcp *ca =3D inet_csk_ca(sk);
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 55fca18..4451750 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -324,7 +324,7 @@ EXPORT_SYMBOL_GPL(tcp_slow_start);
 /* This is Jacobson's slow start and congestion avoidance.
  * SIGCOMM '88, p. 328.
  */
-void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 in_flight, int =
flag)
+void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
=20
diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index 80bd084..3aa0b23 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -246,8 +246,7 @@ static inline void bictcp_update(struct bictcp *ca,=
 u32 cwnd)
 		ca->cnt =3D 1;
 }
=20
-static void bictcp_cong_avoid(struct sock *sk, u32 ack,
-			      u32 in_flight, int data_acked)
+static void bictcp_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct bictcp *ca =3D inet_csk_ca(sk);
diff --git a/net/ipv4/tcp_highspeed.c b/net/ipv4/tcp_highspeed.c
index 14a073d..8b6caaf 100644
--- a/net/ipv4/tcp_highspeed.c
+++ b/net/ipv4/tcp_highspeed.c
@@ -109,8 +109,7 @@ static void hstcp_init(struct sock *sk)
 	tp->snd_cwnd_clamp =3D min_t(u32, tp->snd_cwnd_clamp, 0xffffffff/128)=
;
 }
=20
-static void hstcp_cong_avoid(struct sock *sk, u32 adk,
-			     u32 in_flight, int data_acked)
+static void hstcp_cong_avoid(struct sock *sk, u32 adk, u32 in_flight)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct hstcp *ca =3D inet_csk_ca(sk);
diff --git a/net/ipv4/tcp_htcp.c b/net/ipv4/tcp_htcp.c
index 5215691..af99776 100644
--- a/net/ipv4/tcp_htcp.c
+++ b/net/ipv4/tcp_htcp.c
@@ -225,8 +225,7 @@ static u32 htcp_recalc_ssthresh(struct sock *sk)
 	return max((tp->snd_cwnd * ca->beta) >> 7, 2U);
 }
=20
-static void htcp_cong_avoid(struct sock *sk, u32 ack,
-			    u32 in_flight, int data_acked)
+static void htcp_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct htcp *ca =3D inet_csk_ca(sk);
diff --git a/net/ipv4/tcp_hybla.c b/net/ipv4/tcp_hybla.c
index b3e55cf..44618b6 100644
--- a/net/ipv4/tcp_hybla.c
+++ b/net/ipv4/tcp_hybla.c
@@ -85,8 +85,7 @@ static inline u32 hybla_fraction(u32 odds)
  *     o Give cwnd a new value based on the model proposed
  *     o remember increments <1
  */
-static void hybla_cong_avoid(struct sock *sk, u32 ack,
-			    u32 in_flight, int flag)
+static void hybla_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct hybla *ca =3D inet_csk_ca(sk);
@@ -103,7 +102,7 @@ static void hybla_cong_avoid(struct sock *sk, u32 a=
ck,
 		return;
=20
 	if (!ca->hybla_en)
-		return tcp_reno_cong_avoid(sk, ack, in_flight, flag);
+		return tcp_reno_cong_avoid(sk, ack, in_flight);
=20
 	if (ca->rho =3D=3D 0)
 		hybla_recalc_param(sk);
diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
index 5aa5f54..1eba160 100644
--- a/net/ipv4/tcp_illinois.c
+++ b/net/ipv4/tcp_illinois.c
@@ -256,8 +256,7 @@ static void tcp_illinois_state(struct sock *sk, u8 =
new_state)
 /*
  * Increase window in response to successful acknowledgment.
  */
-static void tcp_illinois_cong_avoid(struct sock *sk, u32 ack,
-				    u32 in_flight, int flag)
+static void tcp_illinois_cong_avoid(struct sock *sk, u32 ack, u32 in_f=
light)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct illinois *ca =3D inet_csk_ca(sk);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 29268df..ed2077c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2710,11 +2710,10 @@ static inline void tcp_ack_update_rtt(struct so=
ck *sk, const int flag,
 		tcp_ack_no_tstamp(sk, seq_rtt, flag);
 }
=20
-static void tcp_cong_avoid(struct sock *sk, u32 ack,
-			   u32 in_flight, int good)
+static void tcp_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 {
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
-	icsk->icsk_ca_ops->cong_avoid(sk, ack, in_flight, good);
+	icsk->icsk_ca_ops->cong_avoid(sk, ack, in_flight);
 	tcp_sk(sk)->snd_cwnd_stamp =3D tcp_time_stamp;
 }
=20
@@ -3240,11 +3239,11 @@ static int tcp_ack(struct sock *sk, struct sk_b=
uff *skb, int flag)
 		/* Advance CWND, if state allows this. */
 		if ((flag & FLAG_DATA_ACKED) && !frto_cwnd &&
 		    tcp_may_raise_cwnd(sk, flag))
-			tcp_cong_avoid(sk, ack, prior_in_flight, 0);
+			tcp_cong_avoid(sk, ack, prior_in_flight);
 		tcp_fastretrans_alert(sk, prior_packets - tp->packets_out, flag);
 	} else {
 		if ((flag & FLAG_DATA_ACKED) && !frto_cwnd)
-			tcp_cong_avoid(sk, ack, prior_in_flight, 1);
+			tcp_cong_avoid(sk, ack, prior_in_flight);
 	}
=20
 	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag&FLAG_NOT_DUP))
diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
index e7f5ef9..ce3c41f 100644
--- a/net/ipv4/tcp_lp.c
+++ b/net/ipv4/tcp_lp.c
@@ -115,12 +115,12 @@ static void tcp_lp_init(struct sock *sk)
  * Will only call newReno CA when away from inference.
  * From TCP-LP's paper, this will be handled in additive increasement.
  */
-static void tcp_lp_cong_avoid(struct sock *sk, u32 ack, u32 in_flight,=
 int flag)
+static void tcp_lp_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 {
 	struct lp *lp =3D inet_csk_ca(sk);
=20
 	if (!(lp->flag & LP_WITHIN_INF))
-		tcp_reno_cong_avoid(sk, ack, in_flight, flag);
+		tcp_reno_cong_avoid(sk, ack, in_flight);
 }
=20
 /**
diff --git a/net/ipv4/tcp_scalable.c b/net/ipv4/tcp_scalable.c
index be27a33..2747ec7 100644
--- a/net/ipv4/tcp_scalable.c
+++ b/net/ipv4/tcp_scalable.c
@@ -15,8 +15,7 @@
 #define TCP_SCALABLE_AI_CNT	50U
 #define TCP_SCALABLE_MD_SCALE	3
=20
-static void tcp_scalable_cong_avoid(struct sock *sk, u32 ack,
-				    u32 in_flight, int flag)
+static void tcp_scalable_cong_avoid(struct sock *sk, u32 ack, u32 in_f=
light)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
=20
diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
index 007304e..be24d6e 100644
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -162,14 +162,13 @@ void tcp_vegas_cwnd_event(struct sock *sk, enum t=
cp_ca_event event)
 }
 EXPORT_SYMBOL_GPL(tcp_vegas_cwnd_event);
=20
-static void tcp_vegas_cong_avoid(struct sock *sk, u32 ack,
-				 u32 in_flight, int flag)
+static void tcp_vegas_cong_avoid(struct sock *sk, u32 ack, u32 in_flig=
ht)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct vegas *vegas =3D inet_csk_ca(sk);
=20
 	if (!vegas->doing_vegas_now)
-		return tcp_reno_cong_avoid(sk, ack, in_flight, flag);
+		return tcp_reno_cong_avoid(sk, ack, in_flight);
=20
 	/* The key players are v_beg_snd_una and v_beg_snd_nxt.
 	 *
@@ -228,7 +227,7 @@ static void tcp_vegas_cong_avoid(struct sock *sk, u=
32 ack,
 			/* We don't have enough RTT samples to do the Vegas
 			 * calculation, so we'll behave like Reno.
 			 */
-			tcp_reno_cong_avoid(sk, ack, in_flight, flag);
+			tcp_reno_cong_avoid(sk, ack, in_flight);
 		} else {
 			u32 rtt, target_cwnd, diff;
=20
diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
index 8fb2aee..d16689e 100644
--- a/net/ipv4/tcp_veno.c
+++ b/net/ipv4/tcp_veno.c
@@ -114,14 +114,13 @@ static void tcp_veno_cwnd_event(struct sock *sk, =
enum tcp_ca_event event)
 		tcp_veno_init(sk);
 }
=20
-static void tcp_veno_cong_avoid(struct sock *sk, u32 ack,
-				u32 in_flight, int flag)
+static void tcp_veno_cong_avoid(struct sock *sk, u32 ack, u32 in_fligh=
t)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct veno *veno =3D inet_csk_ca(sk);
=20
 	if (!veno->doing_veno_now)
-		return tcp_reno_cong_avoid(sk, ack, in_flight, flag);
+		return tcp_reno_cong_avoid(sk, ack, in_flight);
=20
 	/* limited by applications */
 	if (!tcp_is_cwnd_limited(sk, in_flight))
@@ -132,7 +131,7 @@ static void tcp_veno_cong_avoid(struct sock *sk, u3=
2 ack,
 		/* We don't have enough rtt samples to do the Veno
 		 * calculation, so we'll behave like Reno.
 		 */
-		tcp_reno_cong_avoid(sk, ack, in_flight, flag);
+		tcp_reno_cong_avoid(sk, ack, in_flight);
 	} else {
 		u32 rtt, target_cwnd;
=20
diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
index c107fba..e03b101 100644
--- a/net/ipv4/tcp_yeah.c
+++ b/net/ipv4/tcp_yeah.c
@@ -69,8 +69,7 @@ static void tcp_yeah_pkts_acked(struct sock *sk, u32 =
pkts_acked, s32 rtt_us)
 	tcp_vegas_pkts_acked(sk, pkts_acked, rtt_us);
 }
=20
-static void tcp_yeah_cong_avoid(struct sock *sk, u32 ack,
-				u32 in_flight, int flag)
+static void tcp_yeah_cong_avoid(struct sock *sk, u32 ack, u32 in_fligh=
t)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct yeah *yeah =3D inet_csk_ca(sk);
--=20
1.5.0.6

