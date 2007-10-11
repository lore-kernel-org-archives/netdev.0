From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 3/7] [TCP]: Kill almost unused variable pcount from sacktag
Date: Thu, 11 Oct 2007 14:41:03 +0300
Message-ID: <11921028673528-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1192102867479-git-send-email-ilpo.jarvinen@helsinki.fi> <11921028673599-git-send-email-ilpo.jarvinen@helsinki.fi> <1192102867725-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, TAKANO Ryousei <takano@axe-inc.co.jp>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41696 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755098AbXJKLlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 07:41:16 -0400
In-Reply-To: <1192102867725-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's on the way for future cutting of that function.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c827285..5004704 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1314,7 +1314,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 			flag |=3D FLAG_DATA_LOST;
=20
 		tcp_for_write_queue_from(skb, sk) {
-			int in_sack, pcount;
+			int in_sack;
 			u8 sacked;
=20
 			if (skb =3D=3D tcp_send_head(sk))
@@ -1336,9 +1336,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 			in_sack =3D !after(start_seq, TCP_SKB_CB(skb)->seq) &&
 				!before(end_seq, TCP_SKB_CB(skb)->end_seq);
=20
-			pcount =3D tcp_skb_pcount(skb);
-
-			if (pcount > 1 && !in_sack &&
+			if (tcp_skb_pcount(skb) > 1 && !in_sack &&
 			    after(TCP_SKB_CB(skb)->end_seq, start_seq)) {
 				unsigned int pkt_len;
=20
@@ -1353,10 +1351,9 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb, u32 prior_snd_
 						   TCP_SKB_CB(skb)->seq);
 				if (tcp_fragment(sk, skb, pkt_len, skb_shinfo(skb)->gso_size))
 					break;
-				pcount =3D tcp_skb_pcount(skb);
 			}
=20
-			fack_count +=3D pcount;
+			fack_count +=3D tcp_skb_pcount(skb);
=20
 			sacked =3D TCP_SKB_CB(skb)->sacked;
=20
--=20
1.5.0.6

