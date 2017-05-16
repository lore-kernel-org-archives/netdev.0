From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 10/15] tcp: uses jiffies_32 to feed tp->chrono_start
Date: Tue, 16 May 2017 14:00:09 -0700
Message-ID: <20170516210014.31176-11-edumazet@google.com>
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
Received: from mail-pg0-f53.google.com ([74.125.83.53]:33466 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752815AbdEPV2X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 17:28:23 -0400
Received: by mail-pg0-f53.google.com with SMTP id u187so82198624pgb.0
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 14:28:23 -0700 (PDT)
In-Reply-To: <20170516210014.31176-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_time_stamp will no longer be tied to jiffies.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp.c        | 2 +-
 net/ipv4/tcp_output.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index d0bb61ee28bbceff8f2e27416ce87fec94935973..b85bfe7cb11dca68952cc4be19b169d893963fef 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2757,7 +2757,7 @@ static void tcp_get_info_chrono_stats(const struct tcp_sock *tp,
 	for (i = TCP_CHRONO_BUSY; i < __TCP_CHRONO_MAX; ++i) {
 		stats[i] = tp->chrono_stat[i - 1];
 		if (i == tp->chrono_type)
-			stats[i] += tcp_time_stamp - tp->chrono_start;
+			stats[i] += tcp_jiffies32 - tp->chrono_start;
 		stats[i] *= USEC_PER_SEC / HZ;
 		total += stats[i];
 	}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f0fd1b4fdb3291638fcdca613d826db2cd27f517..1011ea40c2ba4c12cce21149cab176e1fa4db583 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2202,7 +2202,7 @@ static bool tcp_small_queue_check(struct sock *sk, const struct sk_buff *skb,
 
 static void tcp_chrono_set(struct tcp_sock *tp, const enum tcp_chrono new)
 {
-	const u32 now = tcp_time_stamp;
+	const u32 now = tcp_jiffies32;
 
 	if (tp->chrono_type > TCP_CHRONO_UNSPEC)
 		tp->chrono_stat[tp->chrono_type - 1] += now - tp->chrono_start;
-- 
2.13.0.303.g4ebf302169-goog
