From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 2/5] tcp: use C99 initializers in new_state[]
Date: Tue, 24 Mar 2015 15:58:53 -0700
Message-ID: <1427237936-19030-3-git-send-email-edumazet@google.com>
References: <1427237936-19030-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:33297 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395AbbCXW7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 18:59:23 -0400
Received: by obbnt9 with SMTP id nt9so619706obb.0
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 15:59:21 -0700 (PDT)
In-Reply-To: <1427237936-19030-1-git-send-email-edumazet@google.com>
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
