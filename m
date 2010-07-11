From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: sock_free() optimizations
Date: Sun, 11 Jul 2010 10:45:17 +0200
Message-ID: <1278837917.2538.138.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61743 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500Ab0GKIpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 04:45:21 -0400
Received: by wwb24 with SMTP id 24so105589wwb.1
        for <netdev@vger.kernel.org>; Sun, 11 Jul 2010 01:45:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid two extra instructions in sock_free(), to reload
skb->truesize and skb->sk

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/sock.c b/net/core/sock.c
index fef2434..363bc26 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1339,9 +1339,10 @@ EXPORT_SYMBOL(sock_wfree);
 void sock_rfree(struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;
+	unsigned int len = skb->truesize;
 
-	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
-	sk_mem_uncharge(skb->sk, skb->truesize);
+	atomic_sub(len, &sk->sk_rmem_alloc);
+	sk_mem_uncharge(sk, len);
 }
 EXPORT_SYMBOL(sock_rfree);
 


