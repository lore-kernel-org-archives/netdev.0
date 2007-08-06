From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Subject: [PATCH 2.6.23 3/3]S2IO: Fixed Link LED issue when MSI-X is enabled
Date: Mon, 6 Aug 2007 05:38:19 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10708060536360.4004-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:40118 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755389AbXHFJiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 05:38:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-Fixed Link LED issue when MSI-X is enabled.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN patch2/drivers/net/s2io.c patch3/drivers/net/s2io.c
--- patch2/drivers/net/s2io.c	2007-08-02 17:00:36.000000000 +0530
+++ patch3/drivers/net/s2io.c	2007-08-02 16:59:40.000000000 +0530
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.25.1"
+#define DRV_VERSION "2.0.26.1"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -6205,13 +6205,10 @@ static void s2io_set_link(struct work_st
 				netif_stop_queue(dev);
 			}
 		}
-		val64 = readq(&bar0->adapter_status);
-		if (!LINK_IS_UP(val64)) {
-			DBG_PRINT(ERR_DBG, "%s:", dev->name);
-			DBG_PRINT(ERR_DBG, " Link down after enabling ");
-			DBG_PRINT(ERR_DBG, "device \n");
-		} else
-			s2io_link(nic, LINK_UP);
+		val64 = readq(&bar0->adapter_control);
+		val64 |= ADAPTER_LED_ON;
+		writeq(val64, &bar0->adapter_control);
+		s2io_link(nic, LINK_UP);
 	} else {
 		if (CARDS_WITH_FAULTY_LINK_INDICATORS(nic->device_type,
 						      subid)) {
@@ -6220,6 +6217,10 @@ static void s2io_set_link(struct work_st
 			writeq(val64, &bar0->gpio_control);
 			val64 = readq(&bar0->gpio_control);
 		}
+		/* turn off LED */
+		val64 = readq(&bar0->adapter_control);
+		val64 = val64 &(~ADAPTER_LED_ON);
+		writeq(val64, &bar0->adapter_control);
 		s2io_link(nic, LINK_DOWN);
 	}
 	clear_bit(0, &(nic->link_state));

