From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 07/16] atm: firestream: Use del_timer_sync() in teardown path
Date: Sun, 23 Mar 2014 15:09:28 -0000
Message-ID: <20140323150753.325835408@linutronix.de>
References: <20140323150557.288925975@linutronix.de>
Cc: Julia Lawall <Julia.Lawall@lip6.fr>,
	Andrew Morton <akpm@linux-foundation.org>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	atm <linux-atm-general@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=atm-firestream-use-del-timer-sync.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The device is about to vanish. So we need to make sure that the timer
is completely stopped and the callback is not running on another CPU.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Cc: atm <linux-atm-general@lists.sourceforge.net>
Cc: netdev <netdev@vger.kernel.org>
---
 drivers/atm/firestream.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: tip/drivers/atm/firestream.c
===================================================================
--- tip.orig/drivers/atm/firestream.c
+++ tip/drivers/atm/firestream.c
@@ -2000,7 +2000,7 @@ static void firestream_remove_one(struct
 
 		fs_dprintk (FS_DEBUG_CLEANUP, "Freeing irq%d.\n", dev->irq);
 		free_irq (dev->irq, dev);
-		del_timer (&dev->timer);
+		del_timer_sync (&dev->timer);
 
 		atm_dev_deregister(dev->atm_dev);
 		free_queue (dev, &dev->hp_txq);
