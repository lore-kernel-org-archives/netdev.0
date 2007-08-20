From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 3/5] [TCP]: Rename tcp_ack_packets_out -> tcp_rearm_rto
Date: Mon, 20 Aug 2007 16:16:31 +0300
Message-ID: <118761579328-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <118761579315-git-send-email-ilpo.jarvinen@helsinki.fi> <1187615793197-git-send-email-ilpo.jarvinen@helsinki.fi> <1187615793583-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34469 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755705AbXHTNQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 09:16:36 -0400
In-Reply-To: <1187615793583-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Only thing that tiny function does is rearming the RTO (if
necessary), name it accordingly.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 45ad32c..2bf3d57 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2406,8 +2406,7 @@ static void tcp_cong_avoid(struct sock *sk, u32 a=
ck,
 /* Restart timer after forward progress on connection.
  * RFC2988 recommends to restart timer to now+rto.
  */
-
-static void tcp_ack_packets_out(struct sock *sk)
+static void tcp_rearm_rto(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
=20
@@ -2560,7 +2559,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, _=
_s32 *seq_rtt_p)
 			=3D inet_csk(sk)->icsk_ca_ops;
=20
 		tcp_ack_update_rtt(sk, acked, seq_rtt);
-		tcp_ack_packets_out(sk);
+		tcp_rearm_rto(sk);
=20
 		if (tcp_is_reno(tp))
 			tcp_remove_reno_sacks(sk, pkts_acked);
--=20
1.5.0.6

