From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 03/21] [TCP]: Unite identical code from two seqno split blocks
Date: Sun,  2 Dec 2007 00:47:58 +0200
Message-ID: <1196549296278-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11965492963603-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492964079-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296202-git-send-email-ilpo.jarvinen@helsinki.fi>
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
	with ESMTP id S1752693AbXLAWsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 17:48:19 -0500
In-Reply-To: <1196549296202-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Bogus seqno compares just mislead, the code is identical for
both sides of the seqno compare (and was even executed just
once because of return in between).

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 6986a2d..29268df 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1246,8 +1246,7 @@ static int tcp_sacktag_one(struct sk_buff *skb, s=
truct tcp_sock *tp,
 	if (dup_sack && (sacked & TCPCB_RETRANS)) {
 		if (after(TCP_SKB_CB(skb)->end_seq, tp->undo_marker))
 			tp->undo_retrans--;
-		if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una) &&
-		    (sacked & TCPCB_SACKED_ACKED))
+		if (sacked & TCPCB_SACKED_ACKED)
 			*reord =3D min(fack_count, *reord);
 	}
=20
@@ -1310,10 +1309,6 @@ static int tcp_sacktag_one(struct sk_buff *skb, =
struct tcp_sock *tp,
=20
 		if (after(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(tp)))
 			tp->highest_sack =3D skb;
-
-	} else {
-		if (dup_sack && (sacked & TCPCB_RETRANS))
-			*reord =3D min(fack_count, *reord);
 	}
=20
 	/* D-SACK. We can detect redundant retransmission in S|R and plain R
--=20
1.5.0.6

