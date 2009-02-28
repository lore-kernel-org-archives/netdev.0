From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 14/17] tcp: remove pointless .dsack code
Date: Sat, 28 Feb 2009 16:44:39 +0200
Message-ID: <12358322831019-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12358322821815-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821434-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1235832282317-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322823783-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821182-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322832831-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831953-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831147-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322833102-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322832711-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322834113-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1235832283214-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831599-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322832879-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58368 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752785AbZB1Oox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 09:44:53 -0500
In-Reply-To: <12358322832879-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>

In the pure assignment case, the earlier zeroing is
still in effect.

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c  |    4 +---
 net/ipv4/tcp_output.c |    3 +--
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e4442a2..464c8a4 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4325,8 +4325,7 @@ static void tcp_data_queue(struct sock *sk, struc=
t sk_buff *skb)
=20
 	TCP_ECN_accept_cwr(tp, skb);
=20
-	if (tp->rx_opt.dsack)
-		tp->rx_opt.dsack =3D 0;
+	tp->rx_opt.dsack =3D 0;
=20
 	/*  Queue data for delivery to the user.
 	 *  Packets in sequence go to the receive queue.
@@ -4445,7 +4444,6 @@ drop:
 		/* Initial out of order segment, build 1 SACK. */
 		if (tcp_is_sack(tp)) {
 			tp->rx_opt.num_sacks =3D 1;
-			tp->rx_opt.dsack     =3D 0;
 			tp->selective_acks[0].start_seq =3D TCP_SKB_CB(skb)->seq;
 			tp->selective_acks[0].end_seq =3D
 						TCP_SKB_CB(skb)->end_seq;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1555bb7..d5c7245 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -441,8 +441,7 @@ static void tcp_options_write(__be32 *ptr, struct t=
cp_sock *tp,
 			*ptr++ =3D htonl(sp[this_sack].end_seq);
 		}
=20
-		if (tp->rx_opt.dsack)
-			tp->rx_opt.dsack =3D 0;
+		tp->rx_opt.dsack =3D 0;
 	}
 }
=20
--=20
1.5.6.5

