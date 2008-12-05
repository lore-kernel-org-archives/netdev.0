From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 02/10] tcp: Fix thinko making the not-shiftable to cover S|R as well
Date: Fri,  5 Dec 2008 22:58:48 +0200
Message-ID: <1228510736-3655-3-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1228510736-3655-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42864 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753774AbYLEU66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 15:58:58 -0500
In-Reply-To: <1228510736-3655-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

S|R won't result in S if just SACK is received. DSACK is
another story (but it is covered correctly already).

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 63c3ef6..33902f6 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1481,7 +1481,7 @@ static struct sk_buff *tcp_shift_skb_data(struct =
sock *sk, struct sk_buff *skb,
=20
 	/* Normally R but no L won't result in plain S */
 	if (!dup_sack &&
-	    (TCP_SKB_CB(skb)->sacked & TCPCB_TAGBITS) =3D=3D TCPCB_SACKED_RET=
RANS)
+	    (TCP_SKB_CB(skb)->sacked & (TCPCB_LOST|TCPCB_SACKED_RETRANS)) =3D=
=3D TCPCB_SACKED_RETRANS)
 		goto fallback;
 	if (!skb_can_shift(skb))
 		goto fallback;
--=20
1.5.2.2

