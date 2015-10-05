From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/5] ipv6: inet6_sk() should use sk_fullsock()
Date: Sun,  4 Oct 2015 21:08:09 -0700
Message-ID: <1444018091-21987-4-git-send-email-edumazet@google.com>
References: <1444018091-21987-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35016 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121AbbJEEIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 00:08:38 -0400
Received: by pacfv12 with SMTP id fv12so166859889pac.2
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 21:08:38 -0700 (PDT)
In-Reply-To: <1444018091-21987-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SYN_RECV & TIMEWAIT sockets are not full blown, they do not have a pinet6
pointer.

Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/ipv6.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index f1f32af6d9b9..0ef2a97ccdb5 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -264,9 +264,9 @@ struct tcp6_timewait_sock {
 };
 
 #if IS_ENABLED(CONFIG_IPV6)
-static inline struct ipv6_pinfo * inet6_sk(const struct sock *__sk)
+static inline struct ipv6_pinfo *inet6_sk(const struct sock *__sk)
 {
-	return inet_sk(__sk)->pinet6;
+	return sk_fullsock(__sk) ? inet_sk(__sk)->pinet6 : NULL;
 }
 
 static inline struct raw6_sock *raw6_sk(const struct sock *sk)
-- 
2.6.0.rc2.230.g3dd15c0
