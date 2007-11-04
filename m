From: Roel Kluin <12o3l@tiscali.nl>
Subject: Re: [PATCH] postfix decrement error in smc911x_reset(); drivers/net/smc911x.c
Date: Mon, 05 Nov 2007 00:59:43 +0100
Message-ID: <472E5CEF.3050008@tiscali.nl>
References: <472E59B1.80206@tiscali.nl> <472E5A87.9000106@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out2.tiscali.nl ([195.241.79.177]:60978 "EHLO
	smtp-out2.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753602AbXKDX7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Nov 2007 18:59:47 -0500
Received: from [82.171.216.234] (helo=[192.168.1.2])
	by smtp-out2.tiscali.nl with esmtp (Tiscali http://www.tiscali.nl)
	id 1IopNa-0001GH-UG
	for <netdev@vger.kernel.org>; Mon, 05 Nov 2007 00:59:47 +0100
In-Reply-To: <472E5A87.9000106@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Darn, another. Sorry for the noise; I also removed a whitespace in this one
--
If timeout causes the loop to end, a postfix decrement causes its value to 
become 4294967295 (unsigned int), not 0.

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index dd18af0..6a2d236 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -243,7 +243,7 @@ static void smc911x_reset(struct net_device *dev)
 		do {
 			udelay(10);
 			reg = SMC_GET_PMT_CTRL() & PMT_CTRL_READY_;
-		} while ( timeout-- && !reg);
+		} while (--timeout && !reg);
 		if (timeout == 0) {
 			PRINTK("%s: smc911x_reset timeout waiting for PM restore\n", dev->name);
 			return;
@@ -267,7 +267,7 @@ static void smc911x_reset(struct net_device *dev)
 				resets++;
 				break;
 			}
-		} while ( timeout-- && (reg & HW_CFG_SRST_));
+		} while (--timeout && (reg & HW_CFG_SRST_));
 	}
 	if (timeout == 0) {
 		PRINTK("%s: smc911x_reset timeout waiting for reset\n", dev->name);
@@ -413,7 +413,7 @@ static inline void smc911x_drop_pkt(struct net_device *dev)
 		do {
 			udelay(10);
 			reg = SMC_GET_RX_DP_CTRL() & RX_DP_CTRL_FFWD_BUSY_;
-		} while ( timeout-- && reg);
+		} while (--timeout && reg);
 		if (timeout == 0) {
 			PRINTK("%s: timeout waiting for RX fast forward\n", dev->name);
 		}
