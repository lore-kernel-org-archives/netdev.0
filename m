From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 05/10] tcp: no need to pass prev skb around, reduces arg pressure
Date: Fri,  5 Dec 2008 22:58:51 +0200
Message-ID: <1228510736-3655-6-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1228510736-3655-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-5-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50779 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754373AbYLEU67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 15:58:59 -0500
In-Reply-To: <1228510736-3655-5-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 57134c2..37b1cac 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1376,12 +1376,12 @@ static u8 tcp_sacktag_one(struct sk_buff *skb, =
struct sock *sk,
 	return sacked;
 }
=20
-static int tcp_shifted_skb(struct sock *sk, struct sk_buff *prev,
-			   struct sk_buff *skb,
+static int tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 			   struct tcp_sacktag_state *state,
 			   unsigned int pcount, int shifted, int mss)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct sk_buff *prev =3D tcp_write_queue_prev(sk, skb);
=20
 	BUG_ON(!pcount);
=20
@@ -1565,7 +1565,7 @@ static struct sk_buff *tcp_shift_skb_data(struct =
sock *sk, struct sk_buff *skb,
=20
 	if (!skb_shift(prev, skb, len))
 		goto fallback;
-	if (!tcp_shifted_skb(sk, prev, skb, state, pcount, len, mss))
+	if (!tcp_shifted_skb(sk, skb, state, pcount, len, mss))
 		goto out;
=20
 	/* Hole filled allows collapsing with the next as well, this is very
@@ -1584,8 +1584,7 @@ static struct sk_buff *tcp_shift_skb_data(struct =
sock *sk, struct sk_buff *skb,
 	len =3D skb->len;
 	if (skb_shift(prev, skb, len)) {
 		pcount +=3D tcp_skb_pcount(skb);
-		tcp_shifted_skb(sk, prev, skb, state, tcp_skb_pcount(skb), len,
-				mss);
+		tcp_shifted_skb(sk, skb, state, tcp_skb_pcount(skb), len, mss);
 	}
=20
 out:
--=20
1.5.2.2

