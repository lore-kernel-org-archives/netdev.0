From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 3/9] [TCP]: Remove unnecessary local variables
Date: Mon, 31 Dec 2007 12:47:51 +0200
Message-ID: <11990980771495-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11990980772344-git-send-email-ilpo.jarvinen@helsinki.fi> <1199098077874-git-send-email-ilpo.jarvinen@helsinki.fi> <11990980773391-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41549 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755544AbXLaKr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 05:47:59 -0500
In-Reply-To: <11990980773391-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1ca638b..025dddf 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -995,9 +995,8 @@ unsigned int tcp_current_mss(struct sock *sk, int l=
arge_allowed)
 static void tcp_cwnd_validate(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
-	__u32 packets_out =3D tp->packets_out;
=20
-	if (packets_out >=3D tp->snd_cwnd) {
+	if (tp->packets_out >=3D tp->snd_cwnd) {
 		/* Network is feed fully. */
 		tp->snd_cwnd_used =3D 0;
 		tp->snd_cwnd_stamp =3D tcp_time_stamp;
@@ -1042,17 +1041,13 @@ static unsigned int tcp_mss_split_point(struct =
sock *sk, struct sk_buff *skb,
  */
 static inline unsigned int tcp_cwnd_test(struct tcp_sock *tp, struct s=
k_buff *skb)
 {
-	u32 in_flight, cwnd;
-
 	/* Don't be strict about the congestion window for the final FIN.  */
 	if ((TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN) &&
 	    tcp_skb_pcount(skb) =3D=3D 1)
 		return 1;
=20
-	in_flight =3D tcp_packets_in_flight(tp);
-	cwnd =3D tp->snd_cwnd;
-	if (in_flight < cwnd)
-		return (cwnd - in_flight);
+	if (tcp_packets_in_flight(tp) < tp->snd_cwnd)
+		return tp->snd_cwnd - tcp_packets_in_flight(tp);
=20
 	return 0;
 }
--=20
1.5.0.6

