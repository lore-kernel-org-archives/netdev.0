From: shemminger@osdl.org
Subject: [PATCH 3/9] sky2: dont use force status bit
Date: Mon, 28 Aug 2006 10:00:47 -0700
Message-ID: <20060828170216.265966554@localhost.localdomain>
References: <20060828170044.136391412@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:47746 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751273AbWH1SQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2006 14:16:53 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-ctl-bits.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't use force status bit. It was never implemented on all chips, or has
no impact.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.c	2006-08-25 16:02:27.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-08-25 16:05:10.000000000 -0700
@@ -1192,7 +1192,6 @@
 	struct sky2_tx_le *le = NULL;
 	struct tx_ring_info *re;
 	unsigned i, len;
-	int avail;
 	dma_addr_t mapping;
 	u32 addr64;
 	u16 mss;
@@ -1328,12 +1327,8 @@
 	re->idx = sky2->tx_prod;
 	le->ctrl |= EOP;
 
-	avail = tx_avail(sky2);
-	if (mss != 0 || avail < TX_MIN_PENDING) {
- 		le->ctrl |= FRC_STAT;
-		if (avail <= MAX_SKB_TX_LE)
-			netif_stop_queue(dev);
-	}
+	if (tx_avail(sky2) <= MAX_SKB_TX_LE)
+		netif_stop_queue(dev);
 
 	sky2_put_idx(hw, txqaddr[sky2->port], sky2->tx_prod);
 
--- sky2.orig/drivers/net/sky2.h	2006-08-25 16:00:28.000000000 -0700
+++ sky2/drivers/net/sky2.h	2006-08-25 16:05:10.000000000 -0700
@@ -1748,7 +1748,6 @@
 	INIT_SUM= 1<<3,
 	LOCK_SUM= 1<<4,
 	INS_VLAN= 1<<5,
-	FRC_STAT= 1<<6,
 	EOP	= 1<<7,
 };
 

--
Stephen Hemminger <shemminger@osdl.org>

