From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 10/32] sfc: Move descriptor cache base addresses to struct
	efx_nic_type
Date: Sat, 28 Nov 2009 03:46:39 +0000
Message-ID: <1259379999.2811.25.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:42488 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753421AbZK1Dqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 22:46:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c     |   12 ++++++++----
 drivers/net/sfc/net_driver.h |    4 ++++
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 7c9c9c9..539d022 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -45,11 +45,9 @@
  */
 #define TX_DC_ENTRIES 16
 #define TX_DC_ENTRIES_ORDER 1
-#define TX_DC_BASE 0x130000
 
 #define RX_DC_ENTRIES 64
 #define RX_DC_ENTRIES_ORDER 3
-#define RX_DC_BASE 0x100000
 
 static const unsigned int
 /* "Large" EEPROM device: Atmel AT25640 or similar
@@ -3043,9 +3041,11 @@ int falcon_init_nic(struct efx_nic *efx)
 		return rc;
 
 	/* Set positions of descriptor caches in SRAM. */
-	EFX_POPULATE_OWORD_1(temp, FRF_AZ_SRM_TX_DC_BASE_ADR, TX_DC_BASE / 8);
+	EFX_POPULATE_OWORD_1(temp, FRF_AZ_SRM_TX_DC_BASE_ADR,
+			     efx->type->tx_dc_base / 8);
 	efx_writeo(efx, &temp, FR_AZ_SRM_TX_DC_CFG);
-	EFX_POPULATE_OWORD_1(temp, FRF_AZ_SRM_RX_DC_BASE_ADR, RX_DC_BASE / 8);
+	EFX_POPULATE_OWORD_1(temp, FRF_AZ_SRM_RX_DC_BASE_ADR,
+			     efx->type->rx_dc_base / 8);
 	efx_writeo(efx, &temp, FR_AZ_SRM_RX_DC_CFG);
 
 	/* Set TX descriptor cache size. */
@@ -3248,6 +3248,8 @@ struct efx_nic_type falcon_a1_nic_type = {
 	.rx_buffer_padding = 0x24,
 	.max_interrupt_mode = EFX_INT_MODE_MSI,
 	.phys_addr_channels = 4,
+	.tx_dc_base = 0x130000,
+	.rx_dc_base = 0x100000,
 };
 
 struct efx_nic_type falcon_b0_nic_type = {
@@ -3271,5 +3273,7 @@ struct efx_nic_type falcon_b0_nic_type = {
 	.phys_addr_channels = 32, /* Hardware limit is 64, but the legacy
 				   * interrupt handler only supports 32
 				   * channels */
+	.tx_dc_base = 0x130000,
+	.rx_dc_base = 0x100000,
 };
 
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index a42a051..30fb21e 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -857,6 +857,8 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
  *	from &enum efx_init_mode.
  * @phys_addr_channels: Number of channels with physically addressed
  *	descriptors
+ * @tx_dc_base: Base address in SRAM of TX queue descriptor caches
+ * @rx_dc_base: Base address in SRAM of RX queue descriptor caches
  */
 struct efx_nic_type {
 	struct efx_mac_operations *default_mac_ops;
@@ -872,6 +874,8 @@ struct efx_nic_type {
 	unsigned int rx_buffer_padding;
 	unsigned int max_interrupt_mode;
 	unsigned int phys_addr_channels;
+	unsigned int tx_dc_base;
+	unsigned int rx_dc_base;
 };
 
 /**************************************************************************

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

