From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 09/15] tcp: use tcp_jiffies32 to feed probe_timestamp
Date: Tue, 16 May 2017 14:00:08 -0700
Message-ID: <20170516210014.31176-10-edumazet@google.com>
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
Received: from mail-pg0-f43.google.com ([74.125.83.43]:35636 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752589AbdEPV2U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 17:28:20 -0400
Received: by mail-pg0-f43.google.com with SMTP id q125so62894385pgq.2
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 14:28:20 -0700 (PDT)
In-Reply-To: <20170516210014.31176-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use tcp_jiffies32 instead of tcp_time_stamp, since
tcp_time_stamp will soon be only used for TCP TS option.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c | 6 +++---
 net/ipv4/tcp_timer.c  | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index cbda5de164495cf318960489bd8edf98fe3a5033..f0fd1b4fdb3291638fcdca613d826db2cd27f517 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1475,7 +1475,7 @@ void tcp_mtup_init(struct sock *sk)
 	icsk->icsk_mtup.search_low = tcp_mss_to_mtu(sk, net->ipv4.sysctl_tcp_base_mss);
 	icsk->icsk_mtup.probe_size = 0;
 	if (icsk->icsk_mtup.enabled)
-		icsk->icsk_mtup.probe_timestamp = tcp_time_stamp;
+		icsk->icsk_mtup.probe_timestamp = tcp_jiffies32;
 }
 EXPORT_SYMBOL(tcp_mtup_init);
 
@@ -1987,7 +1987,7 @@ static inline void tcp_mtu_check_reprobe(struct sock *sk)
 	s32 delta;
 
 	interval = net->ipv4.sysctl_tcp_probe_interval;
-	delta = tcp_time_stamp - icsk->icsk_mtup.probe_timestamp;
+	delta = tcp_jiffies32 - icsk->icsk_mtup.probe_timestamp;
 	if (unlikely(delta >= interval * HZ)) {
 		int mss = tcp_current_mss(sk);
 
@@ -1999,7 +1999,7 @@ static inline void tcp_mtu_check_reprobe(struct sock *sk)
 		icsk->icsk_mtup.search_low = tcp_mss_to_mtu(sk, mss);
 
 		/* Update probe time stamp */
-		icsk->icsk_mtup.probe_timestamp = tcp_time_stamp;
+		icsk->icsk_mtup.probe_timestamp = tcp_jiffies32;
 	}
 }
 
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 9e0616cb8c17a6385ac97fc0cd657ef9413a1749..6629f47aa7f0182ece7873afcc3daa6f0019e228 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -115,7 +115,7 @@ static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
 	if (net->ipv4.sysctl_tcp_mtu_probing) {
 		if (!icsk->icsk_mtup.enabled) {
 			icsk->icsk_mtup.enabled = 1;
-			icsk->icsk_mtup.probe_timestamp = tcp_time_stamp;
+			icsk->icsk_mtup.probe_timestamp = tcp_jiffies32;
 			tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
 		} else {
 			struct net *net = sock_net(sk);
-- 
2.13.0.303.g4ebf302169-goog
