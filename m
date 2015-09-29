From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 12/14] tcp: constify tcp_v{4|6}_route_req() sock argument
Date: Tue, 29 Sep 2015 07:42:50 -0700
Message-ID: <1443537772-15305-13-git-send-email-edumazet@google.com>
References: <1443537772-15305-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35636 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932614AbbI2Ory (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 10:47:54 -0400
Received: by pacfv12 with SMTP id fv12so8536341pac.2
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 07:47:54 -0700 (PDT)
In-Reply-To: <1443537772-15305-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These functions do not change the listener socket.
Goal is to make sure tcp_conn_request() is not messing with
listener in a racy way.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h   | 2 +-
 net/ipv4/tcp_ipv4.c | 3 ++-
 net/ipv6/tcp_ipv6.c | 3 ++-
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5aa6672c6f5b..2c7dfe52f473 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1711,7 +1711,7 @@ struct tcp_request_sock_ops {
 	__u32 (*cookie_init_seq)(const struct sk_buff *skb,
 				 __u16 *mss);
 #endif
-	struct dst_entry *(*route_req)(struct sock *sk, struct flowi *fl,
+	struct dst_entry *(*route_req)(const struct sock *sk, struct flowi *fl,
 				       const struct request_sock *req,
 				       bool *strict);
 	__u32 (*init_seq)(const struct sk_buff *skb);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ee0239e190cf..f551e9e862db 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1180,7 +1180,8 @@ static void tcp_v4_init_req(struct request_sock *req,
 	ireq->opt = tcp_v4_save_options(skb);
 }
 
-static struct dst_entry *tcp_v4_route_req(struct sock *sk, struct flowi *fl,
+static struct dst_entry *tcp_v4_route_req(const struct sock *sk,
+					  struct flowi *fl,
 					  const struct request_sock *req,
 					  bool *strict)
 {
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2330c7be6323..97bc26e0cd0f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -689,7 +689,8 @@ static void tcp_v6_init_req(struct request_sock *req,
 	}
 }
 
-static struct dst_entry *tcp_v6_route_req(struct sock *sk, struct flowi *fl,
+static struct dst_entry *tcp_v6_route_req(const struct sock *sk,
+					  struct flowi *fl,
 					  const struct request_sock *req,
 					  bool *strict)
 {
-- 
2.6.0.rc2.230.g3dd15c0
