From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 06/17] ipv6: constify inet6_csk_route_req() socket argument
Date: Fri, 25 Sep 2015 07:39:13 -0700
Message-ID: <1443191964-923-7-git-send-email-edumazet@google.com>
References: <1443191964-923-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33614 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113AbbIYOkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 10:40:04 -0400
Received: by pacex6 with SMTP id ex6so107614408pac.0
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 07:40:03 -0700 (PDT)
In-Reply-To: <1443191964-923-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

socket is not modified, make it const so that callers can
do the same if they need.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet6_connection_sock.h | 2 +-
 net/ipv6/inet6_connection_sock.c    | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/inet6_connection_sock.h b/include/net/inet6_connection_sock.h
index 6d539e4e5ba7..81d937e820c4 100644
--- a/include/net/inet6_connection_sock.h
+++ b/include/net/inet6_connection_sock.h
@@ -25,7 +25,7 @@ struct sockaddr;
 int inet6_csk_bind_conflict(const struct sock *sk,
 			    const struct inet_bind_bucket *tb, bool relax);
 
-struct dst_entry *inet6_csk_route_req(struct sock *sk, struct flowi6 *fl6,
+struct dst_entry *inet6_csk_route_req(const struct sock *sk, struct flowi6 *fl6,
 				      const struct request_sock *req);
 
 struct request_sock *inet6_csk_search_req(struct sock *sk,
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 6927f3fb5597..91b7d33f508b 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -65,7 +65,7 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 }
 EXPORT_SYMBOL_GPL(inet6_csk_bind_conflict);
 
-struct dst_entry *inet6_csk_route_req(struct sock *sk,
+struct dst_entry *inet6_csk_route_req(const struct sock *sk,
 				      struct flowi6 *fl6,
 				      const struct request_sock *req)
 {
-- 
2.6.0.rc2.230.g3dd15c0
