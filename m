From: franco@lastsummer.de
Subject: =?ISO-8859-1?Q?[net-next-2.6 PATCH] ?=  =?ISO-8859-1?Q?e1000e: do not modify?=  =?ISO-8859-1?Q? tx_queue_len on link?=  =?ISO-8859-1?Q? speed change?=
Date: Wed,  3 Mar 2010 15:31:37 +0100 (CET)
Message-ID: <20100303143137.0BCA01220127@host64.kissl.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, Allan@host64.kissl.de,
	Bruce W <bruce.w.allan@intel.com>
To: Brandeburg@host64.kissl.de, Jesse <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.kissl.de ([213.239.241.64]:39246 "EHLO host64.kissl.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754449Ab0CCObi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 09:31:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

e1000e would try to set appropriate values of tx_queue_len for
negotiated
link speeds overwriting the already set configuration of tx_queue_len in
the process. This removes all lines touching tx_queue_len from the
driver.

Signed-off-by: Franco Fichtner <franco@lastsummer.de>
---
 drivers/net/e1000e/netdev.c |   11 +----------
 1 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 88d54d3..e1cceb6 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2289,8 +2289,6 @@ static void e1000_configure_tx(struct
e1000_adapter *adapter)
 	ew32(TCTL, tctl);

 	e1000e_config_collision_dist(hw);
-
-	adapter->tx_queue_len = adapter->netdev->tx_queue_len;
 }

 /**
@@ -2877,7 +2875,6 @@ void e1000e_down(struct e1000_adapter *adapter)
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_info_timer);

-	netdev->tx_queue_len = adapter->tx_queue_len;
 	netif_carrier_off(netdev);
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
@@ -3588,21 +3585,15 @@ static void e1000_watchdog_task(struct
work_struct *work)
 					       "link gets many collisions.\n");
 			}

-			/*
-			 * tweak tx_queue_len according to speed/duplex
-			 * and adjust the timeout factor
-			 */
-			netdev->tx_queue_len = adapter->tx_queue_len;
+			/* adjust timeout factor according to speed/duplex */
 			adapter->tx_timeout_factor = 1;
 			switch (adapter->link_speed) {
 			case SPEED_10:
 				txb2b = 0;
-				netdev->tx_queue_len = 10;
 				adapter->tx_timeout_factor = 16;
 				break;
 			case SPEED_100:
 				txb2b = 0;
-				netdev->tx_queue_len = 100;
 				adapter->tx_timeout_factor = 10;
 				break;
 			}
--


