From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/14] AF_RXRPC socket family and AFS rewrite [net-2.6]
Date: Thu, 26 Apr 2007 20:18:29 -0700 (PDT)
Message-ID: <20070426.201829.110908085.davem@davemloft.net>
References: <20070426.161522.76328746.davem@davemloft.net>
	<20070426.200809.04441500.davem@davemloft.net>
	<20070426.201213.85816532.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38634
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755203AbXD0DSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 23:18:21 -0400
In-Reply-To: <20070426.201213.85816532.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Thu, 26 Apr 2007 20:12:13 -0700 (PDT)

> In file included from net/rxrpc/rxkad.c:21:
> net/rxrpc/ar-internal.h:803:1: warning: "atomic_dec" redefined
> In file included from include/linux/spinlock.h:326,
>                  from include/linux/module.h:9,
>                  from net/rxrpc/rxkad.c:12:
> include/asm/atomic.h:67:1: warning: this is the location of the previous definition

I'm fixing this as follows, if you want this debugging code
back do it properly, thanks.

commit 411faf5810cdd0e4f5071a3805d8adb49d120a07
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Thu Apr 26 20:18:17 2007 -0700

    [RXRPC]: Remove bogus atomic_* overrides.
    
    These are done with CPP defines which several platforms
    use for their atomic.h implementation, which floods the
    build with warnings and breaks the build.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index cb1eb49..58aaf89 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -786,30 +786,6 @@ static inline void rxrpc_purge_queue(struct sk_buff_head *list)
 		rxrpc_free_skb(skb);
 }
 
-static inline void __rxrpc__atomic_inc(atomic_t *v)
-{
-	CHECK_SLAB_OKAY(v);
-	atomic_inc(v);
-}
-
-#define atomic_inc(v) __rxrpc__atomic_inc((v))
-
-static inline void __rxrpc__atomic_dec(atomic_t *v)
-{
-	CHECK_SLAB_OKAY(v);
-	atomic_dec(v);
-}
-
-#define atomic_dec(v) __rxrpc__atomic_dec((v))
-
-static inline int __rxrpc__atomic_dec_and_test(atomic_t *v)
-{
-	CHECK_SLAB_OKAY(v);
-	return atomic_dec_and_test(v);
-}
-
-#define atomic_dec_and_test(v) __rxrpc__atomic_dec_and_test((v))
-
 static inline void __rxrpc_get_local(struct rxrpc_local *local, const char *f)
 {
 	CHECK_SLAB_OKAY(&local->usage);
