From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 14/21] [TCP]: Added queue parameter to _for_write_queue helpers
Date: Sun,  2 Dec 2007 00:48:09 +0200
Message-ID: <11965492972855-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11965492963603-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492964079-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296202-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296278-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961750-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296588-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962509-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962214-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963057-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296324-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962283-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961234-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963381-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492973133-git-send-email-ilpo.ja
 rvinen@helsinki.fi>
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
	with ESMTP id S1753374AbXLAWsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 17:48:22 -0500
In-Reply-To: <11965492973133-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |    8 ++++----
 net/ipv4/tcp_input.c  |   18 +++++++++---------
 net/ipv4/tcp_output.c |    8 ++++----
 3 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 433c6a6..0883697 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1232,16 +1232,16 @@ static inline struct sk_buff *tcp_write_queue_p=
rev(struct sock *sk, struct sk_bu
 	return skb->prev;
 }
=20
-#define tcp_for_write_queue(skb, sk)					\
+#define tcp_for_write_queue(skb, sk, queue)				\
 		for (skb =3D (sk)->sk_write_queue.next;			\
 		     (skb !=3D (struct sk_buff *)&(sk)->sk_write_queue);	\
 		     skb =3D skb->next)
=20
-#define tcp_for_write_queue_from(skb, sk)				\
+#define tcp_for_write_queue_from(skb, sk, queue)			\
 		for (; (skb !=3D (struct sk_buff *)&(sk)->sk_write_queue);\
 		     skb =3D skb->next)
=20
-#define tcp_for_write_queue_from_safe(skb, tmp, sk)			\
+#define tcp_for_write_queue_from_safe(skb, tmp, sk, queue)		\
 		for (tmp =3D skb->next;					\
 		     (skb !=3D (struct sk_buff *)&(sk)->sk_write_queue);	\
 		     skb =3D tmp, tmp =3D skb->next)
@@ -1364,7 +1364,7 @@ static inline void tcp_reset_fack_counts(struct s=
ock *sk, struct sk_buff *skb)
 	if (prev !=3D (struct sk_buff *) &sk->sk_write_queue)
 		fc =3D TCP_SKB_CB(prev)->fack_count + tcp_skb_pcount(prev);
=20
-	tcp_for_write_queue_from(skb, sk) {
+	tcp_for_write_queue_from(skb, sk, 0) {
 		if (!before(TCP_SKB_CB(skb)->seq, tcp_sk(sk)->snd_nxt) ||
 		    TCP_SKB_CB(skb)->fack_count =3D=3D fc)
 			break;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 35753b7..8a02de2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1132,7 +1132,7 @@ static void tcp_mark_lost_retrans(struct sock *sk=
)
 	    icsk->icsk_ca_state !=3D TCP_CA_Recovery)
 		return;
=20
-	tcp_for_write_queue(skb, sk) {
+	tcp_for_write_queue(skb, sk, 0) {
 		u32 ack_seq =3D TCP_SKB_CB(skb)->ack_seq;
=20
 		if (skb =3D=3D tcp_send_head(sk))
@@ -1331,7 +1331,7 @@ static struct sk_buff *tcp_sacktag_walk(struct sk=
_buff *skb, struct sock *sk,
 					int dup_sack_in, int *fack_count,
 					int *reord, int *flag)
 {
-	tcp_for_write_queue_from(skb, sk) {
+	tcp_for_write_queue_from(skb, sk, 0) {
 		int in_sack =3D 0;
 		int dup_sack =3D dup_sack_in;
=20
@@ -1370,7 +1370,7 @@ static struct sk_buff *tcp_sacktag_walk(struct sk=
_buff *skb, struct sock *sk,
 static struct sk_buff *tcp_sacktag_skip(struct sk_buff *skb, struct so=
ck *sk,
 					u32 skip_to_seq)
 {
-	tcp_for_write_queue_from(skb, sk) {
+	tcp_for_write_queue_from(skb, sk, 0) {
 		if (skb =3D=3D tcp_send_head(sk))
 			break;
=20
@@ -1687,7 +1687,7 @@ int tcp_use_frto(struct sock *sk)
=20
 	skb =3D tcp_write_queue_head(sk);
 	skb =3D tcp_write_queue_next(sk, skb);	/* Skips head */
-	tcp_for_write_queue_from(skb, sk) {
+	tcp_for_write_queue_from(skb, sk, 0) {
 		if (skb =3D=3D tcp_send_head(sk))
 			break;
 		if (TCP_SKB_CB(skb)->sacked&TCPCB_RETRANS)
@@ -1794,7 +1794,7 @@ static void tcp_enter_frto_loss(struct sock *sk, =
int allowed_segments, int flag)
 	if (tcp_is_reno(tp))
 		tcp_reset_reno_sack(tp);
=20
-	tcp_for_write_queue(skb, sk) {
+	tcp_for_write_queue(skb, sk, 0) {
 		if (skb =3D=3D tcp_send_head(sk))
 			break;
=20
@@ -1894,7 +1894,7 @@ void tcp_enter_loss(struct sock *sk, int how)
 		tcp_clear_all_retrans_hints(tp);
 	}
=20
-	tcp_for_write_queue(skb, sk) {
+	tcp_for_write_queue(skb, sk, 0) {
 		if (skb =3D=3D tcp_send_head(sk))
 			break;
=20
@@ -2145,7 +2145,7 @@ static void tcp_mark_head_lost(struct sock *sk, i=
nt packets, int fast_rexmit)
 		cnt =3D 0;
 	}
=20
-	tcp_for_write_queue_from(skb, sk) {
+	tcp_for_write_queue_from(skb, sk, 0) {
 		if (skb =3D=3D tcp_send_head(sk))
 			break;
 		/* TODO: do this better */
@@ -2200,7 +2200,7 @@ static void tcp_update_scoreboard(struct sock *sk=
, int fast_rexmit)
 		skb =3D tp->scoreboard_skb_hint ? tp->scoreboard_skb_hint
 			: tcp_write_queue_head(sk);
=20
-		tcp_for_write_queue_from(skb, sk) {
+		tcp_for_write_queue_from(skb, sk, 0) {
 			if (skb =3D=3D tcp_send_head(sk))
 				break;
 			if (!tcp_skb_timedout(sk, skb))
@@ -2398,7 +2398,7 @@ static int tcp_try_undo_loss(struct sock *sk)
=20
 	if (tcp_may_undo(tp)) {
 		struct sk_buff *skb;
-		tcp_for_write_queue(skb, sk) {
+		tcp_for_write_queue(skb, sk, 0) {
 			if (skb =3D=3D tcp_send_head(sk))
 				break;
 			TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_LOST;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 07907ce..202a48a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1348,7 +1348,7 @@ static int tcp_mtu_probe(struct sock *sk)
 	tcp_insert_write_queue_before(nskb, skb, sk);
=20
 	len =3D 0;
-	tcp_for_write_queue_from_safe(skb, next, sk) {
+	tcp_for_write_queue_from_safe(skb, next, sk, 0) {
 		copy =3D min_t(int, skb->len, probe_size - len);
 		if (nskb->ip_summed)
 			skb_copy_bits(skb, 0, skb_put(nskb, copy), copy);
@@ -1761,7 +1761,7 @@ void tcp_simple_retransmit(struct sock *sk)
 	unsigned int mss =3D tcp_current_mss(sk, 0);
 	int lost =3D 0;
=20
-	tcp_for_write_queue(skb, sk) {
+	tcp_for_write_queue(skb, sk, 0) {
 		if (skb =3D=3D tcp_send_head(sk))
 			break;
 		if (skb->len > mss &&
@@ -1937,7 +1937,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
=20
 	/* First pass: retransmit lost packets. */
 	if (tp->lost_out) {
-		tcp_for_write_queue_from(skb, sk) {
+		tcp_for_write_queue_from(skb, sk, 0) {
 			__u8 sacked =3D TCP_SKB_CB(skb)->sacked;
=20
 			if (skb =3D=3D tcp_send_head(sk))
@@ -2010,7 +2010,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 	else
 		skb =3D tcp_write_queue_head(sk);
=20
-	tcp_for_write_queue_from(skb, sk) {
+	tcp_for_write_queue_from(skb, sk, 0) {
 		if (skb =3D=3D tcp_send_head(sk))
 			break;
 		tp->forward_skb_hint =3D skb;
--=20
1.5.0.6

