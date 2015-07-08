From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/3] inet: remove BUG_ON() in twsk_destructor()
Date: Wed,  8 Jul 2015 14:28:28 -0700
Message-ID: <1436390910-13117-2-git-send-email-edumazet@google.com>
References: <1436390910-13117-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:34491 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759188AbbGHV2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 17:28:44 -0400
Received: by igoe12 with SMTP id e12so770989igo.1
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 14:28:43 -0700 (PDT)
In-Reply-To: <1436390910-13117-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel will crash the same if one of the pointer is NULL anyway.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/timewait_sock.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/include/net/timewait_sock.h b/include/net/timewait_sock.h
index 68f0ecad6c6e..1a47946f95ba 100644
--- a/include/net/timewait_sock.h
+++ b/include/net/timewait_sock.h
@@ -33,9 +33,6 @@ static inline int twsk_unique(struct sock *sk, struct sock *sktw, void *twp)
 
 static inline void twsk_destructor(struct sock *sk)
 {
-	BUG_ON(sk == NULL);
-	BUG_ON(sk->sk_prot == NULL);
-	BUG_ON(sk->sk_prot->twsk_prot == NULL);
 	if (sk->sk_prot->twsk_prot->twsk_destructor != NULL)
 		sk->sk_prot->twsk_prot->twsk_destructor(sk);
 }
-- 
2.4.3.573.g4eafbef
