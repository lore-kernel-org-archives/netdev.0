From: akpm@linux-foundation.org
Subject: [patch 1/1] fix "netpoll: Allow netpoll_setup/cleanup recursion"
Date: Thu, 24 Jun 2010 20:54:01 -0700
Message-ID: <201006250353.o5P3rwti014499@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	herbert@gondor.hengli.com.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56704 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754602Ab0FYDyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 23:54:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

Remove rtnl_unlock() which had no corresponding rtnl_lock().

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/core/netpoll.c |    1 -
 1 file changed, 1 deletion(-)

diff -puN net/core/netpoll.c~fix-netpoll-allow-netpoll_setup-cleanup-recursion net/core/netpoll.c
--- a/net/core/netpoll.c~fix-netpoll-allow-netpoll_setup-cleanup-recursion
+++ a/net/core/netpoll.c
@@ -748,7 +748,6 @@ int __netpoll_setup(struct netpoll *np)
 
 	/* last thing to do is link it to the net device structure */
 	rcu_assign_pointer(ndev->npinfo, npinfo);
-	rtnl_unlock();
 
 	return 0;
 
_
