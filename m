From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 06/10] [TCP]: Prior_fackets can be replaced by highest_sack seq
Date: Thu, 15 Nov 2007 15:37:30 +0200
Message-ID: <11951338543774-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11951338542267-git-send-email-ilpo.jarvinen@helsinki.fi> <1195133854795-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338543953-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338542528-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338542967-git-send-email-ilpo.jarvinen@helsinki.fi> <1195133854614-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58594 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757476AbXKONhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 08:37:38 -0500
In-Reply-To: <1195133854614-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b7af304..29fff81 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1251,7 +1251,6 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 	struct sk_buff *cached_skb;
 	int num_sacks =3D (ptr[1] - TCPOLEN_SACK_BASE)>>3;
 	int reord =3D tp->packets_out;
-	int prior_fackets;
 	int flag =3D 0;
 	int found_dup_sack =3D 0;
 	int cached_fack_count;
@@ -1264,7 +1263,6 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 			tp->fackets_out =3D 0;
 		tp->highest_sack =3D tcp_write_queue_head(sk);
 	}
-	prior_fackets =3D tp->fackets_out;
=20
 	found_dup_sack =3D tcp_check_dsack(tp, ack_skb, sp,
 					 num_sacks, prior_snd_una);
@@ -1457,7 +1455,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 						/* New sack for not retransmitted frame,
 						 * which was in hole. It is reordering.
 						 */
-						if (fack_count < prior_fackets)
+						if (before(TCP_SKB_CB(skb)->seq,
+							   tcp_highest_sack_seq(tp)))
 							reord =3D min(fack_count, reord);
=20
 						/* SACK enhanced F-RTO (RFC4138; Appendix B) */
--=20
1.5.0.6

