From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 10/17] tcp: drop unnecessary local var in collapse
Date: Sat, 28 Feb 2009 16:44:35 +0200
Message-ID: <12358322834113-git-send-email-ilpo.jarvinen@helsinki.fi>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58368 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752745AbZB1Oov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 09:44:51 -0500
In-Reply-To: <12358322832711-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 77af7fa..61445b5 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1767,11 +1767,9 @@ static void tcp_collapse_retrans(struct sock *sk=
, struct sk_buff *skb)
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *next_skb =3D tcp_write_queue_next(sk, skb);
 	int skb_size, next_skb_size;
-	u16 flags;
=20
 	skb_size =3D skb->len;
 	next_skb_size =3D next_skb->len;
-	flags =3D TCP_SKB_CB(skb)->flags;
=20
 	BUG_ON(tcp_skb_pcount(skb) !=3D 1 || tcp_skb_pcount(next_skb) !=3D 1)=
;
=20
@@ -1791,9 +1789,8 @@ static void tcp_collapse_retrans(struct sock *sk,=
 struct sk_buff *skb)
 	/* Update sequence range on original skb. */
 	TCP_SKB_CB(skb)->end_seq =3D TCP_SKB_CB(next_skb)->end_seq;
=20
-	/* Merge over control information. */
-	flags |=3D TCP_SKB_CB(next_skb)->flags; /* This moves PSH/FIN etc. ov=
er */
-	TCP_SKB_CB(skb)->flags =3D flags;
+	/* Merge over control information. This moves PSH/FIN etc. over */
+	TCP_SKB_CB(skb)->flags |=3D TCP_SKB_CB(next_skb)->flags;
=20
 	/* All done, get rid of second SKB and account for it so
 	 * packet counting does not break.
--=20
1.5.6.5

