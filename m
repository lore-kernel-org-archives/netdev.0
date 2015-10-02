From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 09/17] tcp/dccp: remove inet_csk_reqsk_queue_added() timeout argument
Date: Fri,  2 Oct 2015 11:43:31 -0700
Message-ID: <1443811419-4798-10-git-send-email-edumazet@google.com>
References: <1443811419-4798-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:32817 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753382AbbJBSoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 14:44:11 -0400
Received: by pacex6 with SMTP id ex6so113537792pac.0
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 11:44:10 -0700 (PDT)
In-Reply-To: <1443811419-4798-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is no longer used.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_connection_sock.h | 3 +--
 net/ipv4/inet_connection_sock.c    | 2 +-
 net/ipv6/inet6_connection_sock.c   | 2 +-
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index ee54f21a8113..b2e2e30befa9 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -282,8 +282,7 @@ static inline void inet_csk_reqsk_queue_add(struct sock *sk,
 void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
 				   unsigned long timeout);
 
-static inline void inet_csk_reqsk_queue_added(struct sock *sk,
-					      const unsigned long timeout)
+static inline void inet_csk_reqsk_queue_added(struct sock *sk)
 {
 	reqsk_queue_added(&inet_csk(sk)->icsk_accept_queue);
 }
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 093ef04e6ebf..e62f04775c93 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -531,7 +531,7 @@ void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
 				     lopt->hash_rnd, lopt->nr_table_entries);
 
 	reqsk_queue_hash_req(&icsk->icsk_accept_queue, h, req, timeout);
-	inet_csk_reqsk_queue_added(sk, timeout);
+	inet_csk_reqsk_queue_added(sk);
 }
 EXPORT_SYMBOL_GPL(inet_csk_reqsk_queue_hash_add);
 
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 163bfef3e5db..ea915aa5e4e2 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -157,7 +157,7 @@ void inet6_csk_reqsk_queue_hash_add(struct sock *sk,
 				      lopt->hash_rnd, lopt->nr_table_entries);
 
 	reqsk_queue_hash_req(&icsk->icsk_accept_queue, h, req, timeout);
-	inet_csk_reqsk_queue_added(sk, timeout);
+	inet_csk_reqsk_queue_added(sk);
 }
 EXPORT_SYMBOL_GPL(inet6_csk_reqsk_queue_hash_add);
 
-- 
2.6.0.rc2.230.g3dd15c0
