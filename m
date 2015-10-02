From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 16/17] tcp/dccp: add a reschedule point in inet_csk_listen_stop()
Date: Fri,  2 Oct 2015 11:43:38 -0700
Message-ID: <1443811419-4798-17-git-send-email-edumazet@google.com>
References: <1443811419-4798-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33051 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753894AbbJBSo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 14:44:28 -0400
Received: by pacex6 with SMTP id ex6so113543490pac.0
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 11:44:28 -0700 (PDT)
In-Reply-To: <1443811419-4798-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a listener with thousands of children in accept queue
is dismantled, it can take a while to close all of them.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_connection_sock.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 5f6e31a4aeae..89eedfbd4ad5 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -809,6 +809,7 @@ void inet_csk_listen_stop(struct sock *sk)
 		sock_put(child);
 
 		reqsk_put(req);
+		cond_resched();
 	}
 	if (queue->fastopenq.rskq_rst_head) {
 		/* Free all the reqs queued in rskq_rst_head. */
-- 
2.6.0.rc2.230.g3dd15c0
