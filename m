From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/4] tcp: use C99 initializers in new_state[]
Date: Mon, 23 Mar 2015 21:34:23 -0700
Message-ID: <1427171666-30585-2-git-send-email-edumazet@google.com>
References: <1427171666-30585-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f201.google.com ([209.85.160.201]:34311 "EHLO
	mail-yk0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328AbbCXEed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 00:34:33 -0400
Received: by ykq142 with SMTP id 142so8362258ykq.1
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 21:34:32 -0700 (PDT)
In-Reply-To: <1427171666-30585-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp.c | 25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 62f38428279a..dbd51cefaf02 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1913,18 +1913,19 @@ EXPORT_SYMBOL_GPL(tcp_set_state);
 
 static const unsigned char new_state[16] = {
   /* current state:        new state:      action:	*/
-  /* (Invalid)		*/ TCP_CLOSE,
-  /* TCP_ESTABLISHED	*/ TCP_FIN_WAIT1 | TCP_ACTION_FIN,
-  /* TCP_SYN_SENT	*/ TCP_CLOSE,
-  /* TCP_SYN_RECV	*/ TCP_FIN_WAIT1 | TCP_ACTION_FIN,
-  /* TCP_FIN_WAIT1	*/ TCP_FIN_WAIT1,
-  /* TCP_FIN_WAIT2	*/ TCP_FIN_WAIT2,
-  /* TCP_TIME_WAIT	*/ TCP_CLOSE,
-  /* TCP_CLOSE		*/ TCP_CLOSE,
-  /* TCP_CLOSE_WAIT	*/ TCP_LAST_ACK  | TCP_ACTION_FIN,
-  /* TCP_LAST_ACK	*/ TCP_LAST_ACK,
-  /* TCP_LISTEN		*/ TCP_CLOSE,
-  /* TCP_CLOSING	*/ TCP_CLOSING,
+  [0 /* (Invalid) */]	= TCP_CLOSE,
+  [TCP_ESTABLISHED]	= TCP_FIN_WAIT1 | TCP_ACTION_FIN,
+  [TCP_SYN_SENT]	= TCP_CLOSE,
+  [TCP_SYN_RECV]	= TCP_FIN_WAIT1 | TCP_ACTION_FIN,
+  [TCP_FIN_WAIT1]	= TCP_FIN_WAIT1,
+  [TCP_FIN_WAIT2]	= TCP_FIN_WAIT2,
+  [TCP_TIME_WAIT]	= TCP_CLOSE,
+  [TCP_CLOSE]		= TCP_CLOSE,
+  [TCP_CLOSE_WAIT]	= TCP_LAST_ACK  | TCP_ACTION_FIN,
+  [TCP_LAST_ACK]	= TCP_LAST_ACK,
+  [TCP_LISTEN]		= TCP_CLOSE,
+  [TCP_CLOSING]		= TCP_CLOSING,
+  [TCP_NEW_SYN_RECV]	= TCP_CLOSE,	/* should not happen ! */
 };
 
 static int tcp_close_state(struct sock *sk)
-- 
2.2.0.rc0.207.ga3a616c
