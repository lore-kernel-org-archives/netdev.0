From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCHv2 net-next 06/15] tcp: No need to clear retransmit_skb_hint when SACKing
Date: Sun, 21 Sep 2008 00:47:49 +0300
Message-ID: <1221947278-16715-7-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1221947278-16715-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221947278-16715-6-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56256 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbYITVsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 17:48:04 -0400
In-Reply-To: <1221947278-16715-6-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because lost counter no longer requires tuning, this is
trivial to remove (the tuning wouldn't have been too
hard either) because no "new" retransmittable skb appeared
below retransmit_skb_hint when SACKing for sure.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 28e93f1..d017aed 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1298,9 +1298,6 @@ static int tcp_sacktag_one(struct sk_buff *skb, s=
truct sock *sk,
 					~(TCPCB_LOST|TCPCB_SACKED_RETRANS);
 				tp->lost_out -=3D tcp_skb_pcount(skb);
 				tp->retrans_out -=3D tcp_skb_pcount(skb);
-
-				/* clear lost hint */
-				tp->retransmit_skb_hint =3D NULL;
 			}
 		} else {
 			if (!(sacked & TCPCB_RETRANS)) {
@@ -1319,9 +1316,6 @@ static int tcp_sacktag_one(struct sk_buff *skb, s=
truct sock *sk,
 			if (sacked & TCPCB_LOST) {
 				TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_LOST;
 				tp->lost_out -=3D tcp_skb_pcount(skb);
-
-				/* clear lost hint */
-				tp->retransmit_skb_hint =3D NULL;
 			}
 		}
=20
@@ -1351,7 +1345,6 @@ static int tcp_sacktag_one(struct sk_buff *skb, s=
truct sock *sk,
 	if (dup_sack && (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS)) {
 		TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_RETRANS;
 		tp->retrans_out -=3D tcp_skb_pcount(skb);
-		tp->retransmit_skb_hint =3D NULL;
 	}
=20
 	return flag;
--=20
1.5.2.2

