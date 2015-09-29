From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 06/14] inet: constify __inet_inherit_port() sock argument
Date: Tue, 29 Sep 2015 07:42:44 -0700
Message-ID: <1443537772-15305-7-git-send-email-edumazet@google.com>
References: <1443537772-15305-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36158 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756604AbbI2Ont (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 10:43:49 -0400
Received: by pablk4 with SMTP id lk4so8036269pab.3
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 07:43:49 -0700 (PDT)
In-Reply-To: <1443537772-15305-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

socket is not touched, make it const.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_hashtables.h | 2 +-
 net/ipv4/inet_hashtables.c    | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index b07d126694a7..3fb778d7c875 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -199,7 +199,7 @@ static inline int inet_sk_listen_hashfn(const struct sock *sk)
 }
 
 /* Caller must disable local BH processing. */
-int __inet_inherit_port(struct sock *sk, struct sock *child);
+int __inet_inherit_port(const struct sock *sk, struct sock *child);
 
 void inet_put_port(struct sock *sk);
 
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 89120196a949..56742e995dd3 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -126,7 +126,7 @@ void inet_put_port(struct sock *sk)
 }
 EXPORT_SYMBOL(inet_put_port);
 
-int __inet_inherit_port(struct sock *sk, struct sock *child)
+int __inet_inherit_port(const struct sock *sk, struct sock *child)
 {
 	struct inet_hashinfo *table = sk->sk_prot->h.hashinfo;
 	unsigned short port = inet_sk(child)->inet_num;
-- 
2.6.0.rc2.230.g3dd15c0
