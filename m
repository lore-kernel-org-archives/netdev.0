From: Jason Borg <jcborg@somanetworks.com>
Subject: [PATCH 4/5] smc911x: Fix to some timeout logic
Date: Wed, 23 Aug 2006 15:16:47 -0400
Message-ID: <1156360607.15824.74.camel@borg.yyz.somanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dustin@sensoria.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhost.somanetworks.com ([216.126.67.42]:59553 "EHLO
	mail.somanetworks.com") by vger.kernel.org with ESMTP
	id S965124AbWHWTQt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 15:16:49 -0400
Received: from borg.yyz.somanetworks.com ([10.11.11.252])
          (envelope-sender <jcborg@somanetworks.com>)
          by mail.somanetworks.com (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 23 Aug 2006 19:16:47 -0000
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix some timeout off by one errors so the logic works
as intended.

Signed-off-by: Jason Borg <jcborg@somanetworks.com>
---

diff -uprN linux-2.6.18-rc4-orig/drivers/net/smc911x.c linux-2.6.18-rc4/drivers/net/smc911x.c
--- linux-2.6.18-rc4-orig/drivers/net/smc911x.c	2006-08-22 15:49:20.573284797 -0400
+++ linux-2.6.18-rc4/drivers/net/smc911x.c	2006-08-22 15:50:37.049536155 -0400
@@ -251,7 +251,7 @@ static void smc911x_reset(struct net_dev
 		do {
 			udelay(10);
 			reg = SMC_GET_PMT_CTRL() & PMT_CTRL_READY_;
-		} while ( timeout-- && !reg);
+		} while ( --timeout && !reg);
 		if (timeout == 0) {
 			PRINTK("%s: smc911x_reset timeout waiting for PM restore\n", dev->name);
 			return;
@@ -275,7 +275,7 @@ static void smc911x_reset(struct net_dev
 				resets++;
 				break;
 			}
-		} while ( timeout-- && (reg & HW_CFG_SRST_));
+		} while ( --timeout && (reg & HW_CFG_SRST_));
 	}
 	if (timeout == 0) {
 		PRINTK("%s: smc911x_reset timeout waiting for reset\n", dev->name);
@@ -421,7 +421,7 @@ static inline void smc911x_drop_pkt(stru
 		do {
 			udelay(10);
 			reg = SMC_GET_RX_DP_CTRL() & RX_DP_CTRL_FFWD_BUSY_;
-		} while ( timeout-- && reg);
+		} while ( --timeout && reg);
 		if (timeout == 0) {
 			PRINTK("%s: timeout waiting for RX fast forward\n", dev->name);
 		}


