From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 01/10] tcp: force mss equality with the next skb too.
Date: Fri,  5 Dec 2008 22:58:47 +0200
Message-ID: <1228510736-3655-2-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1228510736-3655-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59059 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753351AbYLEU66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 15:58:58 -0500
In-Reply-To: <1228510736-3655-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also make if-goto forest nicer looking.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d67b6e9..63c3ef6 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1575,11 +1575,10 @@ static struct sk_buff *tcp_shift_skb_data(struc=
t sock *sk, struct sk_buff *skb,
 		goto out;
 	skb =3D tcp_write_queue_next(sk, prev);
=20
-	if (!skb_can_shift(skb))
-		goto out;
-	if (skb =3D=3D tcp_send_head(sk))
-		goto out;
-	if ((TCP_SKB_CB(skb)->sacked & TCPCB_TAGBITS) !=3D TCPCB_SACKED_ACKED=
)
+	if (!skb_can_shift(skb) ||
+	    (skb =3D=3D tcp_send_head(sk)) ||
+	    ((TCP_SKB_CB(skb)->sacked & TCPCB_TAGBITS) !=3D TCPCB_SACKED_ACKE=
D) ||
+	    (mss !=3D tcp_shift_mss(skb)))
 		goto out;
=20
 	len =3D skb->len;
--=20
1.5.2.2

