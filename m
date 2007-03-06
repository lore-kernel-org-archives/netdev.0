From: akpm@linux-foundation.org
Subject: [patch 03/19] user of the jiffies rounding code: e1000
Date: Tue, 06 Mar 2007 02:41:48 -0800
Message-ID: <200703061041.l26AfmEP019740@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	arjan@linux.intel.com, auke-jan.h.kok@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34666 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752943AbXCFKmU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 05:42:20 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arjan van de Ven <arjan@linux.intel.com>

Use the round_jiffies() function in e1000.

These timers all were of the "about once a second" or "about once every X
seconds" variety and several showed up in the "what wakes the cpu up" profiles
that the tickless patches provide.  Some timers are highly dynamic based on
network load; but even on low activity systems they still show up so the
rounding is done only in cases of low activity, allowing higher frequency
timers in the high activity case.

The various hardware watchdogs are an obvious case; they run every 2 seconds
but aren't otherwise specific of exactly when they need to run.

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
Acked-by: Auke Kok <auke-jan.h.kok@intel.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/e1000/e1000_main.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff -puN drivers/net/e1000/e1000_main.c~user-of-the-jiffies-rounding-code-e1000 drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c~user-of-the-jiffies-rounding-code-e1000
+++ a/drivers/net/e1000/e1000_main.c
@@ -2652,7 +2652,7 @@ e1000_watchdog(unsigned long data)
 
 			netif_carrier_on(netdev);
 			netif_wake_queue(netdev);
-			mod_timer(&adapter->phy_info_timer, jiffies + 2 * HZ);
+			mod_timer(&adapter->phy_info_timer, round_jiffies(jiffies + 2 * HZ));
 			adapter->smartspeed = 0;
 		} else {
 			/* make sure the receive unit is started */
@@ -2669,7 +2669,7 @@ e1000_watchdog(unsigned long data)
 			DPRINTK(LINK, INFO, "NIC Link is Down\n");
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
-			mod_timer(&adapter->phy_info_timer, jiffies + 2 * HZ);
+			mod_timer(&adapter->phy_info_timer, round_jiffies(jiffies + 2 * HZ));
 
 			/* 80003ES2LAN workaround--
 			 * For packet buffer work-around on link down event;
@@ -2721,7 +2721,7 @@ e1000_watchdog(unsigned long data)
 		e1000_rar_set(&adapter->hw, adapter->hw.mac_addr, 0);
 
 	/* Reset the timer */
-	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
+	mod_timer(&adapter->watchdog_timer, round_jiffies(jiffies + 2 * HZ));
 }
 
 enum latency_range {
_
