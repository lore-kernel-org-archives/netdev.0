From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 01/16] sfc: Fix descriptor cache sizes
Date: Thu, 26 Nov 2009 02:08:30 +0000
Message-ID: <1259201310.2806.5.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:31069 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083AbZKZCIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 21:08:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These were accidentally undersized by a factor of 2, which limited
performance.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 41a321b..7b19686 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -49,11 +49,11 @@ static int disable_dma_stats;
  * goes idle.
  */
 #define TX_DC_ENTRIES 16
-#define TX_DC_ENTRIES_ORDER 0
+#define TX_DC_ENTRIES_ORDER 1
 #define TX_DC_BASE 0x130000
 
 #define RX_DC_ENTRIES 64
-#define RX_DC_ENTRIES_ORDER 2
+#define RX_DC_ENTRIES_ORDER 3
 #define RX_DC_BASE 0x100000
 
 static const unsigned int
@@ -2974,14 +2974,14 @@ int falcon_init_nic(struct efx_nic *efx)
 	efx_writeo(efx, &temp, FR_AZ_SRM_RX_DC_CFG);
 
 	/* Set TX descriptor cache size. */
-	BUILD_BUG_ON(TX_DC_ENTRIES != (16 << TX_DC_ENTRIES_ORDER));
+	BUILD_BUG_ON(TX_DC_ENTRIES != (8 << TX_DC_ENTRIES_ORDER));
 	EFX_POPULATE_OWORD_1(temp, FRF_AZ_TX_DC_SIZE, TX_DC_ENTRIES_ORDER);
 	efx_writeo(efx, &temp, FR_AZ_TX_DC_CFG);
 
 	/* Set RX descriptor cache size.  Set low watermark to size-8, as
 	 * this allows most efficient prefetching.
 	 */
-	BUILD_BUG_ON(RX_DC_ENTRIES != (16 << RX_DC_ENTRIES_ORDER));
+	BUILD_BUG_ON(RX_DC_ENTRIES != (8 << RX_DC_ENTRIES_ORDER));
 	EFX_POPULATE_OWORD_1(temp, FRF_AZ_RX_DC_SIZE, RX_DC_ENTRIES_ORDER);
 	efx_writeo(efx, &temp, FR_AZ_RX_DC_CFG);
 	EFX_POPULATE_OWORD_1(temp, FRF_AZ_RX_DC_PF_LWM, RX_DC_ENTRIES - 8);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

