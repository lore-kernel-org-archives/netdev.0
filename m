From: Ilpo =?ISO-8859-1?Q?=20J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP]: Fixes IW > 2 cases when TCP is application limited
Date: Fri, 04 Aug 2006 00:32:36 +0300
Message-ID: <11546407561210-git-send-email-ilpo.jarvinen@helsinki.fi>
Reply-To: Ilpo =?ISO-8859-1?Q?=20J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ilpo =?ISO-8859-1?Q?=20J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38558 "EHLO
	mail.cs.helsinki.fi") by vger.kernel.org with ESMTP id S932468AbWHCVci
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 17:32:38 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Whenever a transfer is application limited, we are allowed at least
initial window worth of data per window unless cwnd is previously
less than that.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 738dad9..104af5d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3541,7 +3541,8 @@ void tcp_cwnd_application_limited(struct
 	if (inet_csk(sk)->icsk_ca_state =3D=3D TCP_CA_Open &&
 	    sk->sk_socket && !test_bit(SOCK_NOSPACE, &sk->sk_socket->flags)) =
{
 		/* Limited by application or receiver window. */
-		u32 win_used =3D max(tp->snd_cwnd_used, 2U);
+		u32 init_win =3D tcp_init_cwnd(tp, __sk_dst_get(sk));
+		u32 win_used =3D max(tp->snd_cwnd_used, init_win);
 		if (win_used < tp->snd_cwnd) {
 			tp->snd_ssthresh =3D tcp_current_ssthresh(sk);
 			tp->snd_cwnd =3D (tp->snd_cwnd + win_used) >> 1;
--=20
1.4.1

