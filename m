From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/4] chelsio: remove leftover code
Date: Fri, 17 Nov 2006 11:21:33 -0800
Message-ID: <20061117112133.3807bcac@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:41396 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1753022AbWKQUKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 15:10:12 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The chelsio network driver has some extra ifdef's that got in because the
driver was originally based on code that worked on 2.4 as well as 2.6.
This patch removes the dead code.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- chelsio-t2.orig/drivers/net/chelsio/cxgb2.c
+++ chelsio-t2/drivers/net/chelsio/cxgb2.c
@@ -56,34 +56,6 @@
 #include "sge.h"
 #include "espi.h"
 
-#ifdef work_struct
-#include <linux/tqueue.h>
-#define INIT_WORK INIT_TQUEUE
-#define schedule_work schedule_task
-#define flush_scheduled_work flush_scheduled_tasks
-
-static inline void schedule_mac_stats_update(struct adapter *ap, int secs)
-{
-	mod_timer(&ap->stats_update_timer, jiffies + secs * HZ);
-}
-
-static inline void cancel_mac_stats_update(struct adapter *ap)
-{
-	del_timer_sync(&ap->stats_update_timer);
-	flush_scheduled_tasks();
-}
-
-/*
- * Stats update timer for 2.4.  It schedules a task to do the actual update as
- * we need to access MAC statistics in process context.
- */
-static void mac_stats_timer(unsigned long data)
-{
-	struct adapter *ap = (struct adapter *)data;
-
-	schedule_task(&ap->stats_update_task);
-}
-#else
 #include <linux/workqueue.h>
 
 static inline void schedule_mac_stats_update(struct adapter *ap, int secs)
@@ -95,7 +67,6 @@ static inline void cancel_mac_stats_upda
 {
 	cancel_delayed_work(&ap->stats_update_task);
 }
-#endif
 
 #define MAX_CMDQ_ENTRIES 16384
 #define MAX_CMDQ1_ENTRIES 1024
@@ -1090,12 +1061,6 @@ static int __devinit init_one(struct pci
 				  ext_intr_task, adapter);
 			INIT_WORK(&adapter->stats_update_task, mac_stats_task,
 				  adapter);
-#ifdef work_struct
-			init_timer(&adapter->stats_update_timer);
-			adapter->stats_update_timer.function = mac_stats_timer;
-			adapter->stats_update_timer.data =
-				(unsigned long)adapter;
-#endif
 
 			pci_set_drvdata(pdev, netdev);
 		}
