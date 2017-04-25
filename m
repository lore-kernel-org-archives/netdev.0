From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 09/10] tcp: remove ack_time from struct tcp_sacktag_state
Date: Tue, 25 Apr 2017 10:15:40 -0700
Message-ID: <20170425171541.3417-10-edumazet@google.com>
References: <20170425171541.3417-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:33813 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951810AbdDYRQN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:16:13 -0400
Received: by mail-io0-f180.google.com with SMTP id a103so219106098ioj.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 10:16:13 -0700 (PDT)
In-Reply-To: <20170425171541.3417-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is no longer needed, everything uses tp->tcp_mstamp instead.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 net/ipv4/tcp_input.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f4e1836c696c9a45a545a32de8ba62ce3bd0dc12..f475f0b53bfe4cb67c19b7f30d9d68bd703ff23b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1131,7 +1131,6 @@ struct tcp_sacktag_state {
 	 */
 	struct skb_mstamp first_sackt;
 	struct skb_mstamp last_sackt;
-	struct skb_mstamp ack_time; /* Timestamp when the S/ACK was received */
 	struct rate_sample *rate;
 	int	flag;
 };
@@ -3572,8 +3571,6 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	if (after(ack, tp->snd_nxt))
 		goto invalid_ack;
 
-	skb_mstamp_get(&sack_state.ack_time);
-
 	if (icsk->icsk_pending == ICSK_TIME_LOSS_PROBE)
 		tcp_rearm_rto(sk);
 
@@ -3684,7 +3681,6 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	 * If data was DSACKed, see if we can undo a cwnd reduction.
 	 */
 	if (TCP_SKB_CB(skb)->sacked) {
-		skb_mstamp_get(&sack_state.ack_time);
 		flag |= tcp_sacktag_write_queue(sk, skb, prior_snd_una,
 						&sack_state);
 		tcp_fastretrans_alert(sk, acked, is_dupack, &flag, &rexmit);
-- 
2.13.0.rc0.306.g87b477812d-goog
