From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 12/15] tcp_westwood: use tcp_jiffies32 instead of tcp_time_stamp
Date: Tue, 16 May 2017 14:00:11 -0700
Message-ID: <20170516210014.31176-13-edumazet@google.com>
References: <20170516210014.31176-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:35663 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752969AbdEPV2e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 17:28:34 -0400
Received: by mail-pg0-f43.google.com with SMTP id q125so62895708pgq.2
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 14:28:28 -0700 (PDT)
In-Reply-To: <20170516210014.31176-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This CC does not need 1 ms tcp_time_stamp and can use
the jiffy based 'timestamp'.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_westwood.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
index 9775453b8d174c848dc09df83d1fa185422cd8cc..bec9cafbe3f92938e5d79d743d629b2f33464418 100644
--- a/net/ipv4/tcp_westwood.c
+++ b/net/ipv4/tcp_westwood.c
@@ -68,7 +68,7 @@ static void tcp_westwood_init(struct sock *sk)
 	w->cumul_ack = 0;
 	w->reset_rtt_min = 1;
 	w->rtt_min = w->rtt = TCP_WESTWOOD_INIT_RTT;
-	w->rtt_win_sx = tcp_time_stamp;
+	w->rtt_win_sx = tcp_jiffies32;
 	w->snd_una = tcp_sk(sk)->snd_una;
 	w->first_ack = 1;
 }
@@ -116,7 +116,7 @@ static void tcp_westwood_pkts_acked(struct sock *sk,
 static void westwood_update_window(struct sock *sk)
 {
 	struct westwood *w = inet_csk_ca(sk);
-	s32 delta = tcp_time_stamp - w->rtt_win_sx;
+	s32 delta = tcp_jiffies32 - w->rtt_win_sx;
 
 	/* Initialize w->snd_una with the first acked sequence number in order
 	 * to fix mismatch between tp->snd_una and w->snd_una for the first
@@ -140,7 +140,7 @@ static void westwood_update_window(struct sock *sk)
 		westwood_filter(w, delta);
 
 		w->bk = 0;
-		w->rtt_win_sx = tcp_time_stamp;
+		w->rtt_win_sx = tcp_jiffies32;
 	}
 }
 
-- 
2.13.0.303.g4ebf302169-goog
