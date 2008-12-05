From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 06/10] tcp: drop tcp_bound_rto, merge content of it tcp_set_rto
Date: Fri,  5 Dec 2008 22:58:52 +0200
Message-ID: <1228510736-3655-7-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1228510736-3655-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-6-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58938 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754670AbYLEU67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 15:58:59 -0500
In-Reply-To: <1228510736-3655-6-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both are called by the same sites.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 37b1cac..7d887ac 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -701,13 +701,10 @@ static inline void tcp_set_rto(struct sock *sk)
 	 *    all the algo is pure shit and should be replaced
 	 *    with correct one. It is exactly, which we pretend to do.
 	 */
-}
=20
-/* NOTE: clamping at TCP_RTO_MIN is not required, current algo
- * guarantees that rto is higher.
- */
-static inline void tcp_bound_rto(struct sock *sk)
-{
+	/* NOTE: clamping at TCP_RTO_MIN is not required, current algo
+	 * guarantees that rto is higher.
+	 */
 	if (inet_csk(sk)->icsk_rto > TCP_RTO_MAX)
 		inet_csk(sk)->icsk_rto =3D TCP_RTO_MAX;
 }
@@ -928,7 +925,6 @@ static void tcp_init_metrics(struct sock *sk)
 		tp->mdev_max =3D tp->rttvar =3D max(tp->mdev, tcp_rto_min(sk));
 	}
 	tcp_set_rto(sk);
-	tcp_bound_rto(sk);
 	if (inet_csk(sk)->icsk_rto < TCP_TIMEOUT_INIT && !tp->rx_opt.saw_tsta=
mp)
 		goto reset;
 	tp->snd_cwnd =3D tcp_init_cwnd(tp, dst);
@@ -3081,7 +3077,6 @@ static void tcp_ack_saw_tstamp(struct sock *sk, i=
nt flag)
 	tcp_rtt_estimator(sk, seq_rtt);
 	tcp_set_rto(sk);
 	inet_csk(sk)->icsk_backoff =3D 0;
-	tcp_bound_rto(sk);
 }
=20
 static void tcp_ack_no_tstamp(struct sock *sk, u32 seq_rtt, int flag)
@@ -3101,7 +3096,6 @@ static void tcp_ack_no_tstamp(struct sock *sk, u3=
2 seq_rtt, int flag)
 	tcp_rtt_estimator(sk, seq_rtt);
 	tcp_set_rto(sk);
 	inet_csk(sk)->icsk_backoff =3D 0;
-	tcp_bound_rto(sk);
 }
=20
 static inline void tcp_ack_update_rtt(struct sock *sk, const int flag,
--=20
1.5.2.2

