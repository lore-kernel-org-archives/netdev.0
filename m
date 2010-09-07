From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 05/30] net: 3c527: semaphore cleanup
Date: Tue, 07 Sep 2010 14:32:10 -0000
Message-ID: <20100907125055.175750769@linutronix.de>
References: <20100907124636.880953480@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=drivers-net-3c527-sema.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Get rid of init_MUTEX[_LOCKED]() and use sema_init() instead.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 drivers/net/3c527.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/drivers/net/3c527.c
===================================================================
--- linux-2.6.orig/drivers/net/3c527.c
+++ linux-2.6/drivers/net/3c527.c
@@ -522,7 +522,7 @@ static int __init mc32_probe1(struct net
 	lp->tx_len 		= lp->exec_box->data[9];   /* Transmit list count */
 	lp->rx_len 		= lp->exec_box->data[11];  /* Receive list count */
 
-	init_MUTEX_LOCKED(&lp->cmd_mutex);
+	sema_init(&lp->cmd_mutex, 0);
 	init_completion(&lp->execution_cmd);
 	init_completion(&lp->xceiver_cmd);
 
