From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 10/30] irda: semaphore cleanup
Date: Tue, 07 Sep 2010 14:32:30 -0000
Message-ID: <20100907125055.651362456@linutronix.de>
References: <20100907124636.880953480@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:43774 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932150Ab0IGOdR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Sep 2010 10:33:17 -0400
Content-Disposition: inline; filename=drivers-net-irda-sir-dev-sema.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of init_MUTEX[_LOCKED]() and use sema_init() instead.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org

---
 drivers/net/irda/sir_dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/drivers/net/irda/sir_dev.c
===================================================================
--- linux-2.6.orig/drivers/net/irda/sir_dev.c
+++ linux-2.6/drivers/net/irda/sir_dev.c
@@ -909,7 +909,7 @@ struct sir_dev * sirdev_get_instance(con
 	dev->tx_skb = NULL;
 
 	spin_lock_init(&dev->tx_lock);
-	init_MUTEX(&dev->fsm.sem);
+	sema_init(&dev->fsm.sem, 1);
 
 	dev->drv = drv;
 	dev->netdev = ndev;


