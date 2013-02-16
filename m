From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH] net: fix a compile error when SOCK_REFCNT_DEBUG is enabled
Date: Sat, 16 Feb 2013 16:28:25 +0800
Message-ID: <1361003305-1198-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:50414 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399Ab3BPI23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 03:28:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When SOCK_REFCNT_DEBUG is enabled, below build error is met:

kernel/sysctl_binary.o: In function `sk_refcnt_debug_release':
include/net/sock.h:1025: multiple definition of `sk_refcnt_debug_release'
kernel/sysctl.o:include/net/sock.h:1025: first defined here
kernel/audit.o: In function `sk_refcnt_debug_release':
include/net/sock.h:1025: multiple definition of `sk_refcnt_debug_release'
kernel/sysctl.o:include/net/sock.h:1025: first defined here
make[1]: *** [kernel/built-in.o] Error 1
make: *** [kernel] Error 2

So we decide to make sk_refcnt_debug_release static to eliminate
the error.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 include/net/sock.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 182ca99..25afaa0 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1037,7 +1037,7 @@ static inline void sk_refcnt_debug_dec(struct sock *sk)
 	       sk->sk_prot->name, sk, atomic_read(&sk->sk_prot->socks));
 }
 
-inline void sk_refcnt_debug_release(const struct sock *sk)
+static inline void sk_refcnt_debug_release(const struct sock *sk)
 {
 	if (atomic_read(&sk->sk_refcnt) != 1)
 		printk(KERN_DEBUG "Destruction of the %s socket %p delayed, refcnt=%d\n",
-- 
1.7.9.5
