From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 09/14] tcp: constify tcp_create_openreq_child() socket argument
Date: Tue, 29 Sep 2015 07:42:47 -0700
Message-ID: <1443537772-15305-10-git-send-email-edumazet@google.com>
References: <1443537772-15305-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33982 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756581AbbI2Orm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 10:47:42 -0400
Received: by padhy16 with SMTP id hy16so8327312pad.1
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 07:47:41 -0700 (PDT)
In-Reply-To: <1443537772-15305-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This method does not touch the listener socket.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h        | 2 +-
 net/ipv4/tcp_minisocks.c | 4 +++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 1fe0bd458cb4..85995c1291d0 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -450,7 +450,7 @@ void tcp_v4_send_check(struct sock *sk, struct sk_buff *skb);
 void tcp_v4_mtu_reduced(struct sock *sk);
 void tcp_req_err(struct sock *sk, u32 seq);
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb);
-struct sock *tcp_create_openreq_child(struct sock *sk,
+struct sock *tcp_create_openreq_child(const struct sock *sk,
 				      struct request_sock *req,
 				      struct sk_buff *skb);
 void tcp_ca_openreq_child(struct sock *sk, const struct dst_entry *dst);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 139668cc2347..897e34273ba3 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -441,7 +441,9 @@ EXPORT_SYMBOL_GPL(tcp_ca_openreq_child);
  * Actually, we could lots of memory writes here. tp of listening
  * socket contains all necessary default parameters.
  */
-struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req, struct sk_buff *skb)
+struct sock *tcp_create_openreq_child(const struct sock *sk,
+				      struct request_sock *req,
+				      struct sk_buff *skb)
 {
 	struct sock *newsk = inet_csk_clone_lock(sk, req, GFP_ATOMIC);
 
-- 
2.6.0.rc2.230.g3dd15c0
