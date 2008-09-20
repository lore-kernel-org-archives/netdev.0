From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 06/15] tcp: No need to clear retransmit_skb_hint when SACKing
Date: Sat, 20 Sep 2008 20:52:24 +0300
Message-ID: <1221933153-11874-7-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1221933153-11874-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-6-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59235 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbYITRwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 13:52:39 -0400
In-Reply-To: <1221933153-11874-6-git-send-email-ilpo.jarvinen@helsinki.fi>
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
index d7544ec..8a6dec8 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1296,9 +1296,6 @@ static int tcp_sacktag_one(struct sk_buff *skb, s=
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
@@ -1317,9 +1314,6 @@ static int tcp_sacktag_one(struct sk_buff *skb, s=
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
@@ -1349,7 +1343,6 @@ static int tcp_sacktag_one(struct sk_buff *skb, s=
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

