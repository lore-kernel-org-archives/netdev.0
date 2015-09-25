From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 04/17] inet: constify inet_csk_route_req() socket argument
Date: Fri, 25 Sep 2015 07:39:11 -0700
Message-ID: <1443191964-923-5-git-send-email-edumazet@google.com>
References: <1443191964-923-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36174 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113AbbIYOj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 10:39:57 -0400
Received: by pablk4 with SMTP id lk4so10819733pab.3
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 07:39:56 -0700 (PDT)
In-Reply-To: <1443191964-923-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is used by TCP listener core, and listener socket shall
not be modified by inet_csk_route_req().

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_connection_sock.h | 2 +-
 net/ipv4/inet_connection_sock.c    | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 0320bbb7d7b5..00c3ced6ee55 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -266,7 +266,7 @@ int inet_csk_bind_conflict(const struct sock *sk,
 			   const struct inet_bind_bucket *tb, bool relax);
 int inet_csk_get_port(struct sock *sk, unsigned short snum);
 
-struct dst_entry *inet_csk_route_req(struct sock *sk, struct flowi4 *fl4,
+struct dst_entry *inet_csk_route_req(const struct sock *sk, struct flowi4 *fl4,
 				     const struct request_sock *req);
 struct dst_entry *inet_csk_route_child_sock(struct sock *sk, struct sock *newsk,
 					    const struct request_sock *req);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 7bb9c39e0a4d..631301406f7e 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -408,7 +408,7 @@ void inet_csk_reset_keepalive_timer(struct sock *sk, unsigned long len)
 }
 EXPORT_SYMBOL(inet_csk_reset_keepalive_timer);
 
-struct dst_entry *inet_csk_route_req(struct sock *sk,
+struct dst_entry *inet_csk_route_req(const struct sock *sk,
 				     struct flowi4 *fl4,
 				     const struct request_sock *req)
 {
-- 
2.6.0.rc2.230.g3dd15c0
