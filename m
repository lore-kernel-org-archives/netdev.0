From: Tingwei Liu <tingw.liu@gmail.com>
Subject: [PATCH net-next] tcp:elapsed variable calculated twice while keepalive working
Date: Tue,  6 Aug 2013 20:38:58 +0800
Message-ID: <1375792738-19099-1-git-send-email-tingw.liu@gmail.com>
Cc: Tingwei Liu <tingw.liu@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:47440 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756168Ab3HFMjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 08:39:16 -0400
Received: by mail-pa0-f54.google.com with SMTP id kx1so670486pab.41
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 05:39:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When tcp keepalive working elapsed calculated twice while the first time is not needed!

CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Signed-off-by: Tingwei Liu <tingw.liu@gmail.com>
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
