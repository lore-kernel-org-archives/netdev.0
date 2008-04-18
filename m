From: akpm@linux-foundation.org
Subject: [patch 8/9] smc911x: test after postfix decrement fails in smc911x_{reset,drop_pkt}
Date: Fri, 18 Apr 2008 13:50:48 -0700
Message-ID: <200804182050.m3IKonMV014845@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	12o3l@tiscali.nl, jacmet@sunsite.dk
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48689 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756684AbYDRUve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 16:51:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <12o3l@tiscali.nl>

When timeout reaches 0 the postfix decrement still subtracts, so the test
fails.

[akpm@linux-foundation.org: coding-style fixes]
Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
Acked-by: Peter Korsgaard <jacmet@sunsite.dk>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/smc911x.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff -puN drivers/net/smc911x.c~smc911x-test-after-postfix-decrement-fails-in-smc911x_resetdrop_pkt drivers/net/smc911x.c
--- a/drivers/net/smc911x.c~smc911x-test-after-postfix-decrement-fails-in-smc911x_resetdrop_pkt
+++ a/drivers/net/smc911x.c
@@ -244,7 +244,7 @@ static void smc911x_reset(struct net_dev
 		do {
 			udelay(10);
 			reg = SMC_GET_PMT_CTRL() & PMT_CTRL_READY_;
-		} while ( timeout-- && !reg);
+		} while (--timeout && !reg);
 		if (timeout == 0) {
 			PRINTK("%s: smc911x_reset timeout waiting for PM restore\n", dev->name);
 			return;
@@ -268,7 +268,7 @@ static void smc911x_reset(struct net_dev
 				resets++;
 				break;
 			}
-		} while ( timeout-- && (reg & HW_CFG_SRST_));
+		} while (--timeout && (reg & HW_CFG_SRST_));
 	}
 	if (timeout == 0) {
 		PRINTK("%s: smc911x_reset timeout waiting for reset\n", dev->name);
@@ -414,7 +414,7 @@ static inline void smc911x_drop_pkt(stru
 		do {
 			udelay(10);
 			reg = SMC_GET_RX_DP_CTRL() & RX_DP_CTRL_FFWD_BUSY_;
-		} while ( timeout-- && reg);
+		} while (--timeout && reg);
 		if (timeout == 0) {
 			PRINTK("%s: timeout waiting for RX fast forward\n", dev->name);
 		}
_
