From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 05/10] tcp: do not pass timestamp to tcp_fastretrans_alert()
Date: Tue, 25 Apr 2017 10:15:36 -0700
Message-ID: <20170425171541.3417-6-edumazet@google.com>
References: <20170425171541.3417-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:34760 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951784AbdDYRQD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:16:03 -0400
Received: by mail-io0-f181.google.com with SMTP id a103so219102626ioj.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 10:16:03 -0700 (PDT)
In-Reply-To: <20170425171541.3417-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not used anymore now tp->tcp_mstamp holds the information.

This is needed to remove sack_state.ack_time in a following patch.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 net/ipv4/tcp_input.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 99b0d65de169a13679477f49f3733ca00c842090..68094aa8cfb2ee2dc6939ea1931277b745deae4a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2787,8 +2787,7 @@ static void tcp_rack_identify_loss(struct sock *sk, int *ack_flag)
  * tcp_xmit_retransmit_queue().
  */
 static void tcp_fastretrans_alert(struct sock *sk, const int acked,
-				  bool is_dupack, int *ack_flag, int *rexmit,
-				  const struct skb_mstamp *ack_time)
+				  bool is_dupack, int *ack_flag, int *rexmit)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -3646,8 +3645,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 
 	if (tcp_ack_is_dubious(sk, flag)) {
 		is_dupack = !(flag & (FLAG_SND_UNA_ADVANCED | FLAG_NOT_DUP));
-		tcp_fastretrans_alert(sk, acked, is_dupack, &flag, &rexmit,
-				      &sack_state.ack_time);
+		tcp_fastretrans_alert(sk, acked, is_dupack, &flag, &rexmit);
 	}
 	if (tp->tlp_high_seq)
 		tcp_process_tlp_ack(sk, ack, flag);
@@ -3668,8 +3666,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 no_queue:
 	/* If data was DSACKed, see if we can undo a cwnd reduction. */
 	if (flag & FLAG_DSACKING_ACK)
-		tcp_fastretrans_alert(sk, acked, is_dupack, &flag, &rexmit,
-				      &sack_state.ack_time);
+		tcp_fastretrans_alert(sk, acked, is_dupack, &flag, &rexmit);
 	/* If this ack opens up a zero window, clear backoff.  It was
 	 * being used to time the probes, and is probably far higher than
 	 * it needs to be for normal retransmission.
@@ -3693,8 +3690,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 		skb_mstamp_get(&sack_state.ack_time);
 		flag |= tcp_sacktag_write_queue(sk, skb, prior_snd_una,
 						&sack_state);
-		tcp_fastretrans_alert(sk, acked, is_dupack, &flag, &rexmit,
-				      &sack_state.ack_time);
+		tcp_fastretrans_alert(sk, acked, is_dupack, &flag, &rexmit);
 		tcp_xmit_recovery(sk, rexmit);
 	}
 
-- 
2.13.0.rc0.306.g87b477812d-goog
