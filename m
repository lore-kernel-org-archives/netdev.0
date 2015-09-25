From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 14/17] tcp: constify tcp_v{4|6}_send_synack() socket argument
Date: Fri, 25 Sep 2015 07:39:21 -0700
Message-ID: <1443191964-923-15-git-send-email-edumazet@google.com>
References: <1443191964-923-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36743 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113AbbIYOkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 10:40:36 -0400
Received: by pablk4 with SMTP id lk4so10834130pab.3
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 07:40:36 -0700 (PDT)
In-Reply-To: <1443191964-923-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This documents fact that listener lock might not be held
at the time SYNACK are sent.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h   | 2 +-
 net/ipv4/tcp_ipv4.c | 2 +-
 net/ipv6/tcp_ipv6.c | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index fde20acb3328..0f847eb9af65 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1717,7 +1717,7 @@ struct tcp_request_sock_ops {
 				       const struct request_sock *req,
 				       bool *strict);
 	__u32 (*init_seq)(const struct sk_buff *skb);
-	int (*send_synack)(struct sock *sk, struct dst_entry *dst,
+	int (*send_synack)(const struct sock *sk, struct dst_entry *dst,
 			   struct flowi *fl, struct request_sock *req,
 			   u16 queue_mapping, struct tcp_fastopen_cookie *foc);
 	void (*queue_hash_add)(struct sock *sk, struct request_sock *req,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1c1009d783f5..a23ba7daecbf 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -818,7 +818,7 @@ static void tcp_v4_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
  *	This still operates on a request_sock only, not on a big
  *	socket.
  */
-static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
+static int tcp_v4_send_synack(const struct sock *sk, struct dst_entry *dst,
 			      struct flowi *fl,
 			      struct request_sock *req,
 			      u16 queue_mapping,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 1071131a6c53..16fb299dcab8 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -434,7 +434,7 @@ out:
 }
 
 
-static int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
+static int tcp_v6_send_synack(const struct sock *sk, struct dst_entry *dst,
 			      struct flowi *fl,
 			      struct request_sock *req,
 			      u16 queue_mapping,
-- 
2.6.0.rc2.230.g3dd15c0
