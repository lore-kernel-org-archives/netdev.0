From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 08/16] atm: idt77105: Use del_timer_sync() in exit path
Date: Sun, 23 Mar 2014 15:09:28 -0000
Message-ID: <20140323150753.433572795@linutronix.de>
References: <20140323150557.288925975@linutronix.de>
Cc: Julia Lawall <Julia.Lawall@lip6.fr>,
	Andrew Morton <akpm@linux-foundation.org>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	atm <linux-atm-general@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=atm-idt77x-use-del-timer-sync.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The module is about to go away. Make sure everything is stopped safely
before we pull the plug.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Cc: atm <linux-atm-general@lists.sourceforge.net>
Cc: netdev <netdev@vger.kernel.org>
---
 drivers/atm/idt77105.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: tip/drivers/atm/idt77105.c
===================================================================
--- tip.orig/drivers/atm/idt77105.c
+++ tip/drivers/atm/idt77105.c
@@ -368,9 +368,9 @@ EXPORT_SYMBOL(idt77105_init);
 
 static void __exit idt77105_exit(void)
 {
-        /* turn off timers */
-        del_timer(&stats_timer);
-        del_timer(&restart_timer);
+	/* turn off timers */
+	del_timer_sync(&stats_timer);
+	del_timer_sync(&restart_timer);
 }
 
 module_exit(idt77105_exit);
