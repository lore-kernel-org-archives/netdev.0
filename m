From: roy.qing.li@gmail.com
Subject: [PATCH][net-next] tcp: Change tcp_slow_start function to return void
Date: Tue, 30 Sep 2014 09:49:55 +0800
Message-ID: <1412041795-5664-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:62945 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754950AbaI3Btz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 21:49:55 -0400
Received: by mail-pd0-f173.google.com with SMTP id g10so876351pdj.18
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 18:49:55 -0700 (PDT)
Received: from localhost ([106.120.101.38])
        by mx.google.com with ESMTPSA id ks2sm13577804pdb.24.2014.09.29.18.49.53
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 29 Sep 2014 18:49:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

No caller uses the return value, so make this function return void.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 include/net/tcp.h   |    2 +-
 net/ipv4/tcp_cong.c |    4 +---
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 1f57c53..d4fef69 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -830,7 +830,7 @@ void tcp_get_available_congestion_control(char *buf, size_t len);
 void tcp_get_allowed_congestion_control(char *buf, size_t len);
 int tcp_set_allowed_congestion_control(char *allowed);
 int tcp_set_congestion_control(struct sock *sk, const char *name);
-int tcp_slow_start(struct tcp_sock *tp, u32 acked);
+void tcp_slow_start(struct tcp_sock *tp, u32 acked);
 void tcp_cong_avoid_ai(struct tcp_sock *tp, u32 w);
 
 u32 tcp_reno_ssthresh(struct sock *sk);
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index a6c8a57..b1c5970 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -291,15 +291,13 @@ int tcp_set_congestion_control(struct sock *sk, const char *name)
  * ABC caps N to 2. Slow start exits when cwnd grows over ssthresh and
  * returns the leftover acks to adjust cwnd in congestion avoidance mode.
  */
-int tcp_slow_start(struct tcp_sock *tp, u32 acked)
+void tcp_slow_start(struct tcp_sock *tp, u32 acked)
 {
 	u32 cwnd = tp->snd_cwnd + acked;
 
 	if (cwnd > tp->snd_ssthresh)
 		cwnd = tp->snd_ssthresh + 1;
-	acked -= cwnd - tp->snd_cwnd;
 	tp->snd_cwnd = min(cwnd, tp->snd_cwnd_clamp);
-	return acked;
 }
 EXPORT_SYMBOL_GPL(tcp_slow_start);
 
-- 
1.7.10.4
