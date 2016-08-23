From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/4] net: remove clear_sk() method
Date: Tue, 23 Aug 2016 11:39:29 -0700
Message-ID: <1471977569-27190-5-git-send-email-edumazet@google.com>
References: <1471977569-27190-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35891 "EHLO
        mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754298AbcHWSkN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 14:40:13 -0400
Received: by mail-pa0-f42.google.com with SMTP id di2so2223959pad.3
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 11:40:12 -0700 (PDT)
In-Reply-To: <1471977569-27190-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We no longer use this handler, we can delete it.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h | 1 -
 net/core/sock.c    | 8 ++------
 2 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 1bc57609f8e1..c797c57f4d9f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1020,7 +1020,6 @@ struct proto {
 	void			(*unhash)(struct sock *sk);
 	void			(*rehash)(struct sock *sk);
 	int			(*get_port)(struct sock *sk, unsigned short snum);
-	void			(*clear_sk)(struct sock *sk, int size);
 
 	/* Keeping track of sockets in use */
 #ifdef CONFIG_PROC_FS
diff --git a/net/core/sock.c b/net/core/sock.c
index 2b09c2967e21..51a730485649 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1326,12 +1326,8 @@ static struct sock *sk_prot_alloc(struct proto *prot, gfp_t priority,
 		sk = kmem_cache_alloc(slab, priority & ~__GFP_ZERO);
 		if (!sk)
 			return sk;
-		if (priority & __GFP_ZERO) {
-			if (prot->clear_sk)
-				prot->clear_sk(sk, prot->obj_size);
-			else
-				sk_prot_clear_nulls(sk, prot->obj_size);
-		}
+		if (priority & __GFP_ZERO)
+			sk_prot_clear_nulls(sk, prot->obj_size);
 	} else
 		sk = kmalloc(prot->obj_size, priority);
 
-- 
2.8.0.rc3.226.g39d4020
