From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/7] tcp: kill dead end_seq variable in clean_rtx_queue
Date: Sun, 15 Mar 2009 02:23:02 +0200
Message-ID: <12370765871159-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12370765872509-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44913 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137AbZCOAXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 20:23:09 -0400
In-Reply-To: <12370765872509-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've already forgotten what for this was necessary, anyway
it's no longer used (if it ever was).

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index cd39d1d..f527a16 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3201,7 +3201,6 @@ static int tcp_clean_rtx_queue(struct sock *sk, i=
nt prior_fackets,
=20
 	while ((skb =3D tcp_write_queue_head(sk)) && skb !=3D tcp_send_head(s=
k)) {
 		struct tcp_skb_cb *scb =3D TCP_SKB_CB(skb);
-		u32 end_seq;
 		u32 acked_pcount;
 		u8 sacked =3D scb->sacked;
=20
@@ -3216,10 +3215,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, =
int prior_fackets,
 				break;
=20
 			fully_acked =3D 0;
-			end_seq =3D tp->snd_una;
 		} else {
 			acked_pcount =3D tcp_skb_pcount(skb);
-			end_seq =3D scb->end_seq;
 		}
=20
 		/* MTU probing checks */
--=20
1.5.6.5

