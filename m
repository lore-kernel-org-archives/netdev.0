From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 05/14] inet: constify inet_csk_route_child_sock() socket argument
Date: Tue, 29 Sep 2015 07:42:43 -0700
Message-ID: <1443537772-15305-6-git-send-email-edumazet@google.com>
References: <1443537772-15305-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33164 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754263AbbI2Onp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 10:43:45 -0400
Received: by pacex6 with SMTP id ex6so8413862pac.0
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 07:43:44 -0700 (PDT)
In-Reply-To: <1443537772-15305-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The socket points to the (shared) listener.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_connection_sock.h | 3 ++-
 net/ipv4/inet_connection_sock.c    | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 00c3ced6ee55..187cef7e56d5 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -268,7 +268,8 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum);
 
 struct dst_entry *inet_csk_route_req(const struct sock *sk, struct flowi4 *fl4,
 				     const struct request_sock *req);
-struct dst_entry *inet_csk_route_child_sock(struct sock *sk, struct sock *newsk,
+struct dst_entry *inet_csk_route_child_sock(const struct sock *sk,
+					    struct sock *newsk,
 					    const struct request_sock *req);
 
 static inline void inet_csk_reqsk_queue_add(struct sock *sk,
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index ba2f90d90cb5..694a5e8f4f9f 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -439,7 +439,7 @@ no_route:
 }
 EXPORT_SYMBOL_GPL(inet_csk_route_req);
 
-struct dst_entry *inet_csk_route_child_sock(struct sock *sk,
+struct dst_entry *inet_csk_route_child_sock(const struct sock *sk,
 					    struct sock *newsk,
 					    const struct request_sock *req)
 {
-- 
2.6.0.rc2.230.g3dd15c0
