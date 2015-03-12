From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/7] inet: add TCP_NEW_SYN_RECV state
Date: Thu, 12 Mar 2015 14:50:10 -0700
Message-ID: <1426197016-14482-2-git-send-email-edumazet@google.com>
References: <1426197016-14482-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:34541 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324AbbCLVua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 17:50:30 -0400
Received: by obcwp18 with SMTP id wp18so4916224obc.1
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 14:50:29 -0700 (PDT)
In-Reply-To: <1426197016-14482-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP_SYN_RECV state is currently used by fast open sockets.

Initial TCP requests (the pseudo sockets created when a SYN is received)
are not yet associated to a state. They are attached to their parent,
and the parent is in TCP_LISTEN state.

This commit adds TCP_NEW_SYN_RECV state, so that we can convert
TCP stack to a different schem gradually.

This state is not exported to user space.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp_states.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/net/tcp_states.h b/include/net/tcp_states.h
index b0b645988bd8..50e78a74d0df 100644
--- a/include/net/tcp_states.h
+++ b/include/net/tcp_states.h
@@ -25,6 +25,7 @@ enum {
 	TCP_LAST_ACK,
 	TCP_LISTEN,
 	TCP_CLOSING,	/* Now a valid state */
+	TCP_NEW_SYN_RECV,
 
 	TCP_MAX_STATES	/* Leave at the end! */
 };
@@ -44,7 +45,8 @@ enum {
 	TCPF_CLOSE_WAIT	 = (1 << 8),
 	TCPF_LAST_ACK	 = (1 << 9),
 	TCPF_LISTEN	 = (1 << 10),
-	TCPF_CLOSING	 = (1 << 11) 
+	TCPF_CLOSING	 = (1 << 11),
+	TCPF_NEW_SYN_RECV = (1 << 12),
 };
 
 #endif	/* _LINUX_TCP_STATES_H */
-- 
2.2.0.rc0.207.ga3a616c
