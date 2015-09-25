From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 17/17] inet: constify inet_rtx_syn_ack() sock argument
Date: Fri, 25 Sep 2015 07:39:24 -0700
Message-ID: <1443191964-923-18-git-send-email-edumazet@google.com>
References: <1443191964-923-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33213 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113AbbIYOks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 10:40:48 -0400
Received: by pacex6 with SMTP id ex6so107630037pac.0
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 07:40:47 -0700 (PDT)
In-Reply-To: <1443191964-923-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SYNACK packets are sent on behalf on unlocked listeners
or fastopen sockets. Mark socket as const to catch future changes
that might break the assumption.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/request_sock.h      | 2 +-
 net/ipv4/inet_connection_sock.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index ff7ce1e53ed4..181f97f9fe1c 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -42,7 +42,7 @@ struct request_sock_ops {
 	void		(*syn_ack_timeout)(const struct request_sock *req);
 };
 
-int inet_rtx_syn_ack(struct sock *parent, struct request_sock *req);
+int inet_rtx_syn_ack(const struct sock *parent, struct request_sock *req);
 
 /* struct request_sock - mini sock to represent a connection request
  */
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 631301406f7e..ba2f90d90cb5 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -563,7 +563,7 @@ static inline void syn_ack_recalc(struct request_sock *req, const int thresh,
 		  req->num_timeout >= rskq_defer_accept - 1;
 }
 
-int inet_rtx_syn_ack(struct sock *parent, struct request_sock *req)
+int inet_rtx_syn_ack(const struct sock *parent, struct request_sock *req)
 {
 	int err = req->rsk_ops->rtx_syn_ack(parent, req);
 
-- 
2.6.0.rc2.230.g3dd15c0
