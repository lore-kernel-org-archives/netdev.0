From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/6] sky2: reduce default Tx ring size
Date: Wed, 16 Nov 2011 15:42:58 -0800
Message-ID: <20111116234344.813201788@vyatta.com>
References: <20111116234254.319625694@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:48427 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754158Ab1KPXwd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 18:52:33 -0500
Content-Disposition: inline; filename=sky2-tx-debloat.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The default Tx ring size for the sky2 driver is quite large and could
cause excess buffer bloat for many users. The minimum ring size 
possible and still allow handling  the worst case packet on 64bit platforms
is 38 which gets rounded up to a power of 2. But most packets only require
a couple of ring elements.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ethernet/marvell/sky2.c	2011-11-16 15:19:39.518659262 -0800
+++ b/drivers/net/ethernet/marvell/sky2.c	2011-11-16 15:19:40.990692544 -0800
@@ -68,7 +68,7 @@
 #define MAX_SKB_TX_LE	(2 + (sizeof(dma_addr_t)/sizeof(u32))*(MAX_SKB_FRAGS+1))
 #define TX_MIN_PENDING		(MAX_SKB_TX_LE+1)
 #define TX_MAX_PENDING		1024
-#define TX_DEF_PENDING		127
+#define TX_DEF_PENDING		63
 
 #define TX_WATCHDOG		(5 * HZ)
 #define NAPI_WEIGHT		64
