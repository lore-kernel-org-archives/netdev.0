From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 07/10] tcp: share code through function, not through copy-paste. :-)
Date: Fri,  5 Dec 2008 22:58:53 +0200
Message-ID: <1228510736-3655-8-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1228510736-3655-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-7-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42864 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754705AbYLEU67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 15:58:59 -0500
In-Reply-To: <1228510736-3655-7-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7d887ac..e379af9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3052,6 +3052,13 @@ static void tcp_fastretrans_alert(struct sock *s=
k, int pkts_acked, int flag)
 	tcp_xmit_retransmit_queue(sk);
 }
=20
+static void tcp_valid_rtt_meas(struct sock *sk, u32 seq_rtt)
+{
+	tcp_rtt_estimator(sk, seq_rtt);
+	tcp_set_rto(sk);
+	inet_csk(sk)->icsk_backoff =3D 0;
+}
+
 /* Read draft-ietf-tcplw-high-performance before mucking
  * with this code. (Supersedes RFC1323)
  */
@@ -3073,10 +3080,8 @@ static void tcp_ack_saw_tstamp(struct sock *sk, =
int flag)
 	 * in window is lost... Voila.	 			--ANK (010210)
 	 */
 	struct tcp_sock *tp =3D tcp_sk(sk);
-	const __u32 seq_rtt =3D tcp_time_stamp - tp->rx_opt.rcv_tsecr;
-	tcp_rtt_estimator(sk, seq_rtt);
-	tcp_set_rto(sk);
-	inet_csk(sk)->icsk_backoff =3D 0;
+
+	tcp_valid_rtt_meas(sk, tcp_time_stamp - tp->rx_opt.rcv_tsecr);
 }
=20
 static void tcp_ack_no_tstamp(struct sock *sk, u32 seq_rtt, int flag)
@@ -3093,9 +3098,7 @@ static void tcp_ack_no_tstamp(struct sock *sk, u3=
2 seq_rtt, int flag)
 	if (flag & FLAG_RETRANS_DATA_ACKED)
 		return;
=20
-	tcp_rtt_estimator(sk, seq_rtt);
-	tcp_set_rto(sk);
-	inet_csk(sk)->icsk_backoff =3D 0;
+	tcp_valid_rtt_meas(sk, seq_rtt);
 }
=20
 static inline void tcp_ack_update_rtt(struct sock *sk, const int flag,
--=20
1.5.2.2

