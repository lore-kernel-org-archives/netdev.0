From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 08/30] net: ppp_async: semaphore cleanup
Date: Tue, 07 Sep 2010 14:32:22 -0000
Message-ID: <20100907125055.460765783@linutronix.de>
References: <20100907124636.880953480@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:43764 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932134Ab0IGOdO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Sep 2010 10:33:14 -0400
Content-Disposition: inline; filename=drivers-net-ppp-async-sema.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of init_MUTEX[_LOCKED]() and use sema_init() instead.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org

---
 drivers/net/ppp_async.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/drivers/net/ppp_async.c
===================================================================
--- linux-2.6.orig/drivers/net/ppp_async.c
+++ linux-2.6/drivers/net/ppp_async.c
@@ -184,7 +184,7 @@ ppp_asynctty_open(struct tty_struct *tty
 	tasklet_init(&ap->tsk, ppp_async_process, (unsigned long) ap);
 
 	atomic_set(&ap->refcnt, 1);
-	init_MUTEX_LOCKED(&ap->dead_sem);
+	sema_init(&ap->dead_sem, 0);
 
 	ap->chan.private = ap;
 	ap->chan.ops = &async_ops;


