From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 03/10] tcp: do not pass timestamp to tcp_rack_mark_lost()
Date: Tue, 25 Apr 2017 10:15:34 -0700
Message-ID: <20170425171541.3417-4-edumazet@google.com>
References: <20170425171541.3417-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:37220 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951784AbdDYRP7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:15:59 -0400
Received: by mail-it0-f41.google.com with SMTP id x188so80276816itb.0
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 10:15:58 -0700 (PDT)
In-Reply-To: <20170425171541.3417-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is no longer used, since tcp_rack_detect_loss() takes
the timestamp from tp->tcp_mstamp

Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 include/net/tcp.h       | 2 +-
 net/ipv4/tcp_input.c    | 2 +-
 net/ipv4/tcp_recovery.c | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index da28bef1d82b6773bbfcf7c7eafebb7a4932f25b..8b4433c4aaa221b83af90d2b44ba4b01a872a7af 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1853,7 +1853,7 @@ void tcp_v4_init(void);
 void tcp_init(void);
 
 /* tcp_recovery.c */
-extern void tcp_rack_mark_lost(struct sock *sk, const struct skb_mstamp *now);
+extern void tcp_rack_mark_lost(struct sock *sk);
 extern void tcp_rack_advance(struct tcp_sock *tp, u8 sacked, u32 end_seq,
 			     const struct skb_mstamp *xmit_time,
 			     const struct skb_mstamp *ack_time);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bd18c65df4a9d9c2b66d8005f2cc4ff468140a73..d4885f7a6a930ff1794b0ab931c0b73c274371b2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2769,7 +2769,7 @@ static void tcp_rack_identify_loss(struct sock *sk, int *ack_flag,
 	if (sysctl_tcp_recovery & TCP_RACK_LOSS_DETECTION) {
 		u32 prior_retrans = tp->retrans_out;
 
-		tcp_rack_mark_lost(sk, ack_time);
+		tcp_rack_mark_lost(sk);
 		if (prior_retrans > tp->retrans_out)
 			*ack_flag |= FLAG_LOST_RETRANS;
 	}
diff --git a/net/ipv4/tcp_recovery.c b/net/ipv4/tcp_recovery.c
index fdac262e277b2f25492f155bbb295d6d87e31d02..6ca8b5d9d803d872ec7043b02c72fffaec5c7270 100644
--- a/net/ipv4/tcp_recovery.c
+++ b/net/ipv4/tcp_recovery.c
@@ -104,7 +104,7 @@ static void tcp_rack_detect_loss(struct sock *sk, u32 *reo_timeout)
 	}
 }
 
-void tcp_rack_mark_lost(struct sock *sk, const struct skb_mstamp *now)
+void tcp_rack_mark_lost(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	u32 timeout;
-- 
2.13.0.rc0.306.g87b477812d-goog
