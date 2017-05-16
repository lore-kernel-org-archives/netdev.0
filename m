From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 11/15] tcp: use tcp_jiffies32 in __tcp_oow_rate_limited()
Date: Tue, 16 May 2017 14:00:10 -0700
Message-ID: <20170516210014.31176-12-edumazet@google.com>
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
Received: from mail-pf0-f178.google.com ([209.85.192.178]:32993 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752635AbdEPV20 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 17:28:26 -0400
Received: by mail-pf0-f178.google.com with SMTP id e193so86502588pfh.0
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 14:28:26 -0700 (PDT)
In-Reply-To: <20170516210014.31176-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This place wants to use tcp_jiffies32, this is good enough.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index eeb4967df25a8dc35128d0a0848b5ae7ee6d63e3..85575888365a10643e096f9e019adaa3eda87d40 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3390,7 +3390,7 @@ static bool __tcp_oow_rate_limited(struct net *net, int mib_idx,
 				   u32 *last_oow_ack_time)
 {
 	if (*last_oow_ack_time) {
-		s32 elapsed = (s32)(tcp_time_stamp - *last_oow_ack_time);
+		s32 elapsed = (s32)(tcp_jiffies32 - *last_oow_ack_time);
 
 		if (0 <= elapsed && elapsed < sysctl_tcp_invalid_ratelimit) {
 			NET_INC_STATS(net, mib_idx);
@@ -3398,7 +3398,7 @@ static bool __tcp_oow_rate_limited(struct net *net, int mib_idx,
 		}
 	}
 
-	*last_oow_ack_time = tcp_time_stamp;
+	*last_oow_ack_time = tcp_jiffies32;
 
 	return false;	/* not rate-limited: go ahead, send dupack now! */
 }
-- 
2.13.0.303.g4ebf302169-goog
