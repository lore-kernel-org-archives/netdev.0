From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2/2] myri10ge - Fix spurious invokations of the watchdog reset
 handler
Date: Sun, 30 Jul 2006 00:14:15 -0400
Message-ID: <44CC3217.2030203@myri.com>
References: <44CB6BAC.10400@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:62954 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1751106AbWG3EO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2006 00:14:28 -0400
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
In-Reply-To: <44CB6BAC.10400@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix spurious invocations of the watchdog reset handler.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: linux-mm/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-mm.orig/drivers/net/myri10ge/myri10ge.c	2006-07-27 06:49:19.000000000 -0400
+++ linux-mm/drivers/net/myri10ge/myri10ge.c	2006-07-27 15:34:02.000000000 -0400
@@ -177,6 +177,7 @@
 	struct work_struct watchdog_work;
 	struct timer_list watchdog_timer;
 	int watchdog_tx_done;
+	int watchdog_tx_req;
 	int watchdog_resets;
 	int tx_linearized;
 	int pause;
@@ -2536,7 +2537,8 @@
 
 	mgp = (struct myri10ge_priv *)arg;
 	if (mgp->tx.req != mgp->tx.done &&
-	    mgp->tx.done == mgp->watchdog_tx_done)
+	    mgp->tx.done == mgp->watchdog_tx_done &&
+	    mgp->watchdog_tx_req != mgp->watchdog_tx_done)
 		/* nic seems like it might be stuck.. */
 		schedule_work(&mgp->watchdog_work);
 	else
@@ -2545,6 +2547,7 @@
 			  jiffies + myri10ge_watchdog_timeout * HZ);
 
 	mgp->watchdog_tx_done = mgp->tx.done;
+	mgp->watchdog_tx_req = mgp->tx.req;
 }
 
 static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)


