From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 04/10] tcp: do not pass timestamp to tcp_rack_identify_loss()
Date: Tue, 25 Apr 2017 10:15:35 -0700
Message-ID: <20170425171541.3417-5-edumazet@google.com>
References: <20170425171541.3417-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:36587 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951792AbdDYRQC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:16:02 -0400
Received: by mail-io0-f172.google.com with SMTP id p80so101579110iop.3
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 10:16:02 -0700 (PDT)
In-Reply-To: <20170425171541.3417-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not used anymore now tp->tcp_mstamp holds the information.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 net/ipv4/tcp_input.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d4885f7a6a930ff1794b0ab931c0b73c274371b2..99b0d65de169a13679477f49f3733ca00c842090 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2760,8 +2760,7 @@ static bool tcp_try_undo_partial(struct sock *sk, const int acked)
 	return false;
 }
 
-static void tcp_rack_identify_loss(struct sock *sk, int *ack_flag,
-				   const struct skb_mstamp *ack_time)
+static void tcp_rack_identify_loss(struct sock *sk, int *ack_flag)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
@@ -2857,11 +2856,11 @@ static void tcp_fastretrans_alert(struct sock *sk, const int acked,
 			tcp_try_keep_open(sk);
 			return;
 		}
-		tcp_rack_identify_loss(sk, ack_flag, ack_time);
+		tcp_rack_identify_loss(sk, ack_flag);
 		break;
 	case TCP_CA_Loss:
 		tcp_process_loss(sk, flag, is_dupack, rexmit);
-		tcp_rack_identify_loss(sk, ack_flag, ack_time);
+		tcp_rack_identify_loss(sk, ack_flag);
 		if (!(icsk->icsk_ca_state == TCP_CA_Open ||
 		      (*ack_flag & FLAG_LOST_RETRANS)))
 			return;
@@ -2877,7 +2876,7 @@ static void tcp_fastretrans_alert(struct sock *sk, const int acked,
 		if (icsk->icsk_ca_state <= TCP_CA_Disorder)
 			tcp_try_undo_dsack(sk);
 
-		tcp_rack_identify_loss(sk, ack_flag, ack_time);
+		tcp_rack_identify_loss(sk, ack_flag);
 		if (!tcp_time_to_recover(sk, flag)) {
 			tcp_try_to_open(sk, flag);
 			return;
-- 
2.13.0.rc0.306.g87b477812d-goog
