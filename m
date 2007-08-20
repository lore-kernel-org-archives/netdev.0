From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/5] [TCP]: Remove unnecessary wrapper tcp_packets_out_dec
Date: Mon, 20 Aug 2007 16:16:29 +0300
Message-ID: <1187615793197-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <118761579315-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39021 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755543AbXHTNQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 09:16:35 -0400
In-Reply-To: <118761579315-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Makes caller side more obvious, there's no need to have
a wrapper for this oneliner!

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |    6 ------
 net/ipv4/tcp_input.c  |    2 +-
 net/ipv4/tcp_output.c |    2 +-
 3 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7c65989..6d586ca 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -626,12 +626,6 @@ static inline void tcp_packets_out_inc(struct sock=
 *sk,
 					  inet_csk(sk)->icsk_rto, TCP_RTO_MAX);
 }
=20
-static inline void tcp_packets_out_dec(struct tcp_sock *tp,=20
-				       const struct sk_buff *skb)
-{
-	tp->packets_out -=3D tcp_skb_pcount(skb);
-}
-
 /* Events passed to congestion control interface */
 enum tcp_ca_event {
 	CA_EVENT_TX_START,	/* first transmit when no packets in flight */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 96ced89..45ad32c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2548,7 +2548,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, _=
_s32 *seq_rtt_p)
 			last_ackt =3D skb->tstamp;
 		}
 		tcp_dec_pcount_approx(&tp->fackets_out, skb);
-		tcp_packets_out_dec(tp, skb);
+		tp->packets_out -=3D tcp_skb_pcount(skb);
 		tcp_unlink_write_queue(skb, sk);
 		sk_stream_free_skb(sk, skb);
 		clear_all_retrans_hints(tp);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a367917..1d65ce1 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1735,7 +1735,7 @@ static void tcp_retrans_try_collapse(struct sock =
*sk, struct sk_buff *skb, int m
 		 * it is better to underestimate fackets.
 		 */
 		tcp_dec_pcount_approx(&tp->fackets_out, next_skb);
-		tcp_packets_out_dec(tp, next_skb);
+		tp->packets_out -=3D tcp_skb_pcount(next_skb);
 		sk_stream_free_skb(sk, next_skb);
 	}
 }
--=20
1.5.0.6

