From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 05/21] [TCP] MTUprobe: prepare skb fields earlier
Date: Sun,  2 Dec 2007 00:48:00 +0200
Message-ID: <1196549296588-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11965492963603-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492964079-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296202-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296278-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961750-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59570 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355AbXLAWsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 17:48:20 -0500
In-Reply-To: <11965492961750-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

They better be valid when call to write_queue functions is made
once things that follow are going in.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f8266f9..4cb4a7f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1343,7 +1343,6 @@ static int tcp_mtu_probe(struct sock *sk)
 	sk_charge_skb(sk, nskb);
=20
 	skb =3D tcp_send_head(sk);
-	tcp_insert_write_queue_before(nskb, skb, sk);
=20
 	TCP_SKB_CB(nskb)->seq =3D TCP_SKB_CB(skb)->seq;
 	TCP_SKB_CB(nskb)->end_seq =3D TCP_SKB_CB(skb)->seq + probe_size;
@@ -1352,6 +1351,8 @@ static int tcp_mtu_probe(struct sock *sk)
 	nskb->csum =3D 0;
 	nskb->ip_summed =3D skb->ip_summed;
=20
+	tcp_insert_write_queue_before(nskb, skb, sk);
+
 	len =3D 0;
 	while (len < probe_size) {
 		next =3D tcp_write_queue_next(sk, skb);
--=20
1.5.0.6

