From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: make sk_ehashfn() static
Date: Mon, 03 Jul 2017 02:57:54 -0700
Message-ID: <1499075874.1462.6.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35643 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753830AbdGCJ55 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 05:57:57 -0400
Received: by mail-wm0-f67.google.com with SMTP id u23so19482510wma.2
        for <netdev@vger.kernel.org>; Mon, 03 Jul 2017 02:57:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

sk_ehashfn() is only used from a single file.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_hashtables.h |    1 -
 net/ipv4/inet_hashtables.c    |    2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index b9e6e0e1f55ce1acd61ff491c88a12b83086f331..5026b1f08bb87bf7b9be9df84d70fedf2bd8707f 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -359,7 +359,6 @@ static inline struct sock *__inet_lookup_skb(struct inet_hashinfo *hashinfo,
 			     refcounted);
 }
 
-u32 sk_ehashfn(const struct sock *sk);
 u32 inet6_ehashfn(const struct net *net,
 		  const struct in6_addr *laddr, const u16 lport,
 		  const struct in6_addr *faddr, const __be16 fport);
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index a4be2c1cb6887a9f639ccc1349df60a5befc7929..2e3389d614d1689856c3a8a9929dba8f7e7e1a37 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -43,7 +43,7 @@ static u32 inet_ehashfn(const struct net *net, const __be32 laddr,
 /* This function handles inet_sock, but also timewait and request sockets
  * for IPv4/IPv6.
  */
-u32 sk_ehashfn(const struct sock *sk)
+static u32 sk_ehashfn(const struct sock *sk)
 {
 #if IS_ENABLED(CONFIG_IPV6)
 	if (sk->sk_family == AF_INET6 &&
