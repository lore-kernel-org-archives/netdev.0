From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH tcp-2.6 2/3] [TCP]: Remove num_acked>0 checks from cong.ctrl mods pkts_acked
Date: Fri, 15 Jun 2007 14:10:29 +0300
Message-ID: <11819058313153-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11819058302343-git-send-email-ilpo.jarvinen@helsinki.fi> <11819058303890-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54114 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908AbXFOLKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2007 07:10:32 -0400
In-Reply-To: <11819058303890-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

There is no need for such check in pkts_acked because the
callback is not invoked unless at least one segment got fully
ACKed (i.e., the snd_una moved past skb's end_seq) by the
cumulative ACK's snd_una advancement.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_bic.c      |    2 +-
 net/ipv4/tcp_cubic.c    |    2 +-
 net/ipv4/tcp_westwood.c |    3 +--
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_bic.c b/net/ipv4/tcp_bic.c
index 281c9f9..9ebd8ec 100644
--- a/net/ipv4/tcp_bic.c
+++ b/net/ipv4/tcp_bic.c
@@ -210,7 +210,7 @@ static void bictcp_acked(struct sock *sk, u32 cnt, =
ktime_t last)
 {
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
=20
-	if (cnt > 0 && icsk->icsk_ca_state =3D=3D TCP_CA_Open) {
+	if (icsk->icsk_ca_state =3D=3D TCP_CA_Open) {
 		struct bictcp *ca =3D inet_csk_ca(sk);
 		cnt -=3D ca->delayed_ack >> ACK_RATIO_SHIFT;
 		ca->delayed_ack +=3D cnt;
diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index 1422448..8be8ac4 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -338,7 +338,7 @@ static void bictcp_acked(struct sock *sk, u32 cnt, =
ktime_t last)
 {
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
=20
-	if (cnt > 0 && icsk->icsk_ca_state =3D=3D TCP_CA_Open) {
+	if (icsk->icsk_ca_state =3D=3D TCP_CA_Open) {
 		struct bictcp *ca =3D inet_csk_ca(sk);
 		cnt -=3D ca->delayed_ack >> ACK_RATIO_SHIFT;
 		ca->delayed_ack +=3D cnt;
diff --git a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
index e61e09d..0d56a5a 100644
--- a/net/ipv4/tcp_westwood.c
+++ b/net/ipv4/tcp_westwood.c
@@ -103,8 +103,7 @@ static void westwood_filter(struct westwood *w, u32=
 delta)
 static void tcp_westwood_pkts_acked(struct sock *sk, u32 cnt, ktime_t =
last)
 {
 	struct westwood *w =3D inet_csk_ca(sk);
-	if (cnt > 0)
-		w->rtt =3D tcp_sk(sk)->srtt >> 3;
+	w->rtt =3D tcp_sk(sk)->srtt >> 3;
 }
=20
 /*
--=20
1.5.0.6

