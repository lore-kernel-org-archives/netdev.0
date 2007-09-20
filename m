From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 3/9] [TCP]: clear_all_retrans_hints prefixed by tcp_
Date: Thu, 20 Sep 2007 15:17:46 +0300
Message-ID: <11902906723822-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11902906724088-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906721846-git-send-email-ilpo.jarvinen@helsinki.fi> <11902906723619-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45006 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbXITMRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 08:17:54 -0400
In-Reply-To: <11902906723619-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In addition, fix its function comment spacing.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |    4 ++--
 net/ipv4/tcp_input.c  |   10 +++++-----
 net/ipv4/tcp_output.c |    6 +++---
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index f28f382..16dfe3c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1066,8 +1066,8 @@ static inline void tcp_mib_init(void)
 	TCP_ADD_STATS_USER(TCP_MIB_MAXCONN, -1);
 }
=20
-/*from STCP */
-static inline void clear_all_retrans_hints(struct tcp_sock *tp){
+/* from STCP */
+static inline void tcp_clear_all_retrans_hints(struct tcp_sock *tp) {
 	tp->lost_skb_hint =3D NULL;
 	tp->scoreboard_skb_hint =3D NULL;
 	tp->retransmit_skb_hint =3D NULL;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 09b6b1d..89162a9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1670,7 +1670,7 @@ static void tcp_enter_frto_loss(struct sock *sk, =
int allowed_segments, int flag)
 	tp->high_seq =3D tp->frto_highmark;
 	TCP_ECN_queue_cwr(tp);
=20
-	clear_all_retrans_hints(tp);
+	tcp_clear_all_retrans_hints(tp);
 }
=20
 void tcp_clear_retrans(struct tcp_sock *tp)
@@ -1741,7 +1741,7 @@ void tcp_enter_loss(struct sock *sk, int how)
 	/* Abort FRTO algorithm if one is in progress */
 	tp->frto_counter =3D 0;
=20
-	clear_all_retrans_hints(tp);
+	tcp_clear_all_retrans_hints(tp);
 }
=20
 static int tcp_check_sack_reneging(struct sock *sk)
@@ -2106,7 +2106,7 @@ static void tcp_undo_cwr(struct sock *sk, const i=
nt undo)
=20
 	/* There is something screwy going on with the retrans hints after
 	   an undo */
-	clear_all_retrans_hints(tp);
+	tcp_clear_all_retrans_hints(tp);
 }
=20
 static inline int tcp_may_undo(struct tcp_sock *tp)
@@ -2199,7 +2199,7 @@ static int tcp_try_undo_loss(struct sock *sk)
 			TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_LOST;
 		}
=20
-		clear_all_retrans_hints(tp);
+		tcp_clear_all_retrans_hints(tp);
=20
 		DBGUNDO(sk, "partial loss");
 		tp->lost_out =3D 0;
@@ -2656,7 +2656,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, _=
_s32 *seq_rtt_p)
 		tp->packets_out -=3D tcp_skb_pcount(skb);
 		tcp_unlink_write_queue(skb, sk);
 		sk_stream_free_skb(sk, skb);
-		clear_all_retrans_hints(tp);
+		tcp_clear_all_retrans_hints(tp);
 	}
=20
 	if (acked&FLAG_ACKED) {
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index cbe8bf6..f46d24b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -687,7 +687,7 @@ int tcp_fragment(struct sock *sk, struct sk_buff *s=
kb, u32 len, unsigned int mss
=20
 	BUG_ON(len > skb->len);
=20
-	clear_all_retrans_hints(tp);
+	tcp_clear_all_retrans_hints(tp);
 	nsize =3D skb_headlen(skb) - len;
 	if (nsize < 0)
 		nsize =3D 0;
@@ -1719,7 +1719,7 @@ static void tcp_retrans_try_collapse(struct sock =
*sk, struct sk_buff *skb, int m
 		       tcp_skb_pcount(next_skb) !=3D 1);
=20
 		/* changing transmit queue under us so clear hints */
-		clear_all_retrans_hints(tp);
+		tcp_clear_all_retrans_hints(tp);
=20
 		/* Ok.	We will be able to collapse the packet. */
 		tcp_unlink_write_queue(next_skb, sk);
@@ -1792,7 +1792,7 @@ void tcp_simple_retransmit(struct sock *sk)
 		}
 	}
=20
-	clear_all_retrans_hints(tp);
+	tcp_clear_all_retrans_hints(tp);
=20
 	if (!lost)
 		return;
--=20
1.5.0.6

