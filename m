From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/4] ipv6: tcp: get rid of tcp_v6_clear_sk()
Date: Tue, 23 Aug 2016 11:39:28 -0700
Message-ID: <1471977569-27190-4-git-send-email-edumazet@google.com>
References: <1471977569-27190-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33595 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753122AbcHWSkL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 14:40:11 -0400
Received: by mail-pf0-f173.google.com with SMTP id y134so46195423pfg.0
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 11:40:10 -0700 (PDT)
In-Reply-To: <1471977569-27190-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now RCU lookups of IPv6 TCP sockets no longer dereference pinet6,
we do not need tcp_v6_clear_sk() anymore.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/tcp_ipv6.c | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 33df8b8575cc..e0f46439e391 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1862,17 +1862,6 @@ void tcp6_proc_exit(struct net *net)
 }
 #endif
 
-static void tcp_v6_clear_sk(struct sock *sk, int size)
-{
-	struct inet_sock *inet = inet_sk(sk);
-
-	/* we do not want to clear pinet6 field, because of RCU lookups */
-	sk_prot_clear_nulls(sk, offsetof(struct inet_sock, pinet6));
-
-	size -= offsetof(struct inet_sock, pinet6) + sizeof(inet->pinet6);
-	memset(&inet->pinet6 + 1, 0, size);
-}
-
 struct proto tcpv6_prot = {
 	.name			= "TCPv6",
 	.owner			= THIS_MODULE,
@@ -1914,7 +1903,6 @@ struct proto tcpv6_prot = {
 	.compat_setsockopt	= compat_tcp_setsockopt,
 	.compat_getsockopt	= compat_tcp_getsockopt,
 #endif
-	.clear_sk		= tcp_v6_clear_sk,
 	.diag_destroy		= tcp_abort,
 };
 
-- 
2.8.0.rc3.226.g39d4020
