From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 08/21] [TCP]: Remove duplicated code block from clean_rtx_queue
Date: Sun,  2 Dec 2007 00:48:03 +0200
Message-ID: <11965492963057-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11965492963603-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492964079-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296202-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296278-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961750-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296588-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962509-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962214-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47544 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752791AbXLAWsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 17:48:21 -0500
In-Reply-To: <11965492962214-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   48 ++++++++++++++++++++----------------------=
------
 1 files changed, 20 insertions(+), 28 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ed2077c..3f0b6c7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2799,41 +2799,33 @@ static int tcp_clean_rtx_queue(struct sock *sk,=
 s32 *seq_rtt_p,
 			tcp_mtup_probe_success(sk, skb);
 		}
=20
-		if (sacked) {
-			if (sacked & TCPCB_RETRANS) {
-				if (sacked & TCPCB_SACKED_RETRANS)
-					tp->retrans_out -=3D packets_acked;
-				flag |=3D FLAG_RETRANS_DATA_ACKED;
-				seq_rtt =3D -1;
-				if ((flag & FLAG_DATA_ACKED) ||
-				    (packets_acked > 1))
-					flag |=3D FLAG_NONHEAD_RETRANS_ACKED;
-			} else {
-				if (seq_rtt < 0) {
-					seq_rtt =3D now - scb->when;
-					if (fully_acked)
-						last_ackt =3D skb->tstamp;
-				}
-				if (!(sacked & TCPCB_SACKED_ACKED))
-					reord =3D min(cnt, reord);
-			}
-
-			if (sacked & TCPCB_SACKED_ACKED)
-				tp->sacked_out -=3D packets_acked;
-			if (sacked & TCPCB_LOST)
-				tp->lost_out -=3D packets_acked;
-
-			if ((sacked & TCPCB_URG) && tp->urg_mode &&
-			    !before(end_seq, tp->snd_up))
-				tp->urg_mode =3D 0;
+		if (sacked & TCPCB_RETRANS) {
+			if (sacked & TCPCB_SACKED_RETRANS)
+				tp->retrans_out -=3D packets_acked;
+			flag |=3D FLAG_RETRANS_DATA_ACKED;
+			seq_rtt =3D -1;
+			if ((flag & FLAG_DATA_ACKED) ||
+			    (packets_acked > 1))
+				flag |=3D FLAG_NONHEAD_RETRANS_ACKED;
 		} else {
 			if (seq_rtt < 0) {
 				seq_rtt =3D now - scb->when;
 				if (fully_acked)
 					last_ackt =3D skb->tstamp;
 			}
-			reord =3D min(cnt, reord);
+			if (!(sacked & TCPCB_SACKED_ACKED))
+				reord =3D min(cnt, reord);
 		}
+
+		if (sacked & TCPCB_SACKED_ACKED)
+			tp->sacked_out -=3D packets_acked;
+		if (sacked & TCPCB_LOST)
+			tp->lost_out -=3D packets_acked;
+
+		if ((sacked & TCPCB_URG) && tp->urg_mode &&
+		    !before(end_seq, tp->snd_up))
+			tp->urg_mode =3D 0;
+
 		tp->packets_out -=3D packets_acked;
 		cnt +=3D packets_acked;
=20
--=20
1.5.0.6

