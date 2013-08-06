From: Tingwei Liu <tingw.liu@gmail.com>
Subject: [PATCH net-next] tcp:elapsed variable calculated twice while keepalive working
Date: Tue,  6 Aug 2013 20:05:24 +0800
Message-ID: <1375790724-18834-1-git-send-email-tingw.liu@gmail.com>
Cc: Tingwei Liu <tingw.liu@gmail.com>
To: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:44084 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755449Ab3HFMFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 08:05:43 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz10so635800pad.16
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 05:05:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 net/ipv4/tcp_timer.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 4b85e6f..03091d9 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -591,11 +591,11 @@ static void tcp_keepalive_timer (unsigned long data)
 	if (!sock_flag(sk, SOCK_KEEPOPEN) || sk->sk_state == TCP_CLOSE)
 		goto out;
 
-	elapsed = keepalive_time_when(tp);
-
 	/* It is alive without keepalive 8) */
-	if (tp->packets_out || tcp_send_head(sk))
+	if (tp->packets_out || tcp_send_head(sk)) {
+		elapsed = keepalive_time_when(tp);
 		goto resched;
+	}
 
 	elapsed = keepalive_time_elapsed(tp);
 
-- 
1.6.0.2
