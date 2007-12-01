From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 01/21] [TCP]: Move LOSTRETRANS MIB outside !(L|S) check
Date: Sun,  2 Dec 2007 00:47:56 +0200
Message-ID: <11965492964079-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11965492963603-git-send-email-ilpo.jarvinen@helsinki.fi>
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
	with ESMTP id S1752355AbXLAWsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 17:48:18 -0500
In-Reply-To: <11965492963603-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Usually those skbs will have L set, not counting them as lost
retransmissions is misleading.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9f12541..ba05e16 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1160,8 +1160,8 @@ static int tcp_mark_lost_retrans(struct sock *sk)
 				tp->lost_out +=3D tcp_skb_pcount(skb);
 				TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
 				flag |=3D FLAG_DATA_SACKED;
-				NET_INC_STATS_BH(LINUX_MIB_TCPLOSTRETRANSMIT);
 			}
+			NET_INC_STATS_BH(LINUX_MIB_TCPLOSTRETRANSMIT);
 		} else {
 			if (before(ack_seq, new_low_seq))
 				new_low_seq =3D ack_seq;
--=20
1.5.0.6

