From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/9] sky2: reduce default transmit ring
Date: Wed, 17 Jun 2009 10:30:37 -0700
Message-ID: <20090617173140.074593860@vyatta.com>
References: <20090617173031.703636683@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:45316 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758623AbZFQReE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 13:34:04 -0400
Content-Disposition: inline; filename=sky2-txring.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce the size of the driver transmit ring to reduce latency
and allow qdisc to do better rate control.  Also make it
obvious what the minimum transmit ring allowed is and why.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2009-06-17 10:29:56.510685400 -0700
+++ b/drivers/net/sky2.c	2009-06-17 10:29:57.400008862 -0700
@@ -65,9 +65,9 @@
 #define RX_DEF_PENDING		RX_MAX_PENDING
 
 #define TX_RING_SIZE		512
-#define TX_DEF_PENDING		(TX_RING_SIZE - 1)
-#define TX_MIN_PENDING		64
+#define TX_DEF_PENDING		128
 #define MAX_SKB_TX_LE		(4 + (sizeof(dma_addr_t)/sizeof(u32))*MAX_SKB_FRAGS)
+#define TX_MIN_PENDING		(MAX_SKB_TX_LE+1)
 
 #define STATUS_RING_SIZE	2048	/* 2 ports * (TX + 2*RX) */
 #define STATUS_LE_BYTES		(STATUS_RING_SIZE*sizeof(struct sky2_status_le))

-- 

