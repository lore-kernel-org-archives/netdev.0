From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/3] [TCP]: Fix unused variable warnings (tcp_sock *tp no longer needed)
Date: Mon, 16 Apr 2007 15:48:47 +0300
Message-ID: <1176727728273-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1176727728729-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49172 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030515AbXDPMsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 08:48:50 -0400
In-Reply-To: <1176727728729-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Manual completion to func(sk, tp, ...) -> func(sk, ...)
conversion.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c  |    1 -
 net/ipv4/tcp_output.c |    3 ---
 2 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index cd167a5..877239f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3879,7 +3879,6 @@ static void tcp_check_space(struct sock=20
=20
 static inline void tcp_data_snd_check(struct sock *sk)
 {
-	struct tcp_sock *tp =3D tcp_sk(sk);
 	tcp_push_pending_frames(sk);
 	tcp_check_space(sk);
 }
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 473ec06..d17159a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1441,7 +1441,6 @@ static int tcp_write_xmit(struct sock *s
 void __tcp_push_pending_frames(struct sock *sk,
 			       unsigned int cur_mss, int nonagle)
 {
-	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb =3D tcp_send_head(sk);
=20
 	if (skb) {
@@ -2039,7 +2038,6 @@ void tcp_send_fin(struct sock *sk)
  */
 void tcp_send_active_reset(struct sock *sk, gfp_t priority)
 {
-	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
=20
 	/* NOTE: No TCP options attached and we never retransmit this. */
@@ -2369,7 +2367,6 @@ void tcp_send_ack(struct sock *sk)
 {
 	/* If we have been reset, we may not send again. */
 	if (sk->sk_state !=3D TCP_CLOSE) {
-		struct tcp_sock *tp =3D tcp_sk(sk);
 		struct sk_buff *buff;
=20
 		/* We are not putting this on the write queue, so
--=20
1.4.2

