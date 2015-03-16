From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/5] net: add sk_fullsock() helper
Date: Sun, 15 Mar 2015 21:12:12 -0700
Message-ID: <1426479136-15645-2-git-send-email-edumazet@google.com>
References: <1426479136-15645-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:34113 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640AbbCPEMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 00:12:24 -0400
Received: by padet14 with SMTP id et14so10344501pad.1
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 21:12:23 -0700 (PDT)
In-Reply-To: <1426479136-15645-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have many places where we want to check if a socket is
not a timewait or request socket. Use a helper to avoid
hard coding this.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index f10832ca2e90..e0360f5a53e9 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -67,6 +67,7 @@
 #include <linux/atomic.h>
 #include <net/dst.h>
 #include <net/checksum.h>
+#include <net/tcp_states.h>
 #include <linux/net_tstamp.h>
 
 struct cgroup;
@@ -2218,6 +2219,14 @@ static inline struct sock *skb_steal_sock(struct sk_buff *skb)
 	return NULL;
 }
 
+/* This helper checks if a socket is a full socket,
+ * ie _not_ a timewait or request socket.
+ */
+static inline bool sk_fullsock(const struct sock *sk)
+{
+	return (1 << sk->sk_state) & ~(TCPF_TIME_WAIT | TCPF_NEW_SYN_RECV);
+}
+
 void sock_enable_timestamp(struct sock *sk, int flag);
 int sock_get_timestamp(struct sock *, struct timeval __user *);
 int sock_get_timestampns(struct sock *, struct timespec __user *);
-- 
2.2.0.rc0.207.ga3a616c
