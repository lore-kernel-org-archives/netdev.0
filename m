From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 15/19] sfc: Make all CPU/IRQ/channel/queue counts
 unsigned
Date: Thu, 16 Feb 2012 00:50:27 +0000
Message-ID: <1329353427.2565.41.camel@bwh-desktop>
References: <1329352938.2565.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Shradha Shah <sshah@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:27700 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756585Ab2BPAua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 19:50:30 -0500
In-Reply-To: <1329352938.2565.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        |   18 ++++++++++--------
 drivers/net/ethernet/sfc/net_driver.h |    2 +-
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index eda2272..3a103f8 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1104,10 +1104,10 @@ static void efx_fini_io(struct efx_nic *efx)
 	pci_disable_device(efx->pci_dev);
 }
 
-static int efx_wanted_parallelism(void)
+static unsigned int efx_wanted_parallelism(void)
 {
 	cpumask_var_t thread_mask;
-	int count;
+	unsigned int count;
 	int cpu;
 
 	if (rss_cpus)
@@ -1136,7 +1136,8 @@ static int
 efx_init_rx_cpu_rmap(struct efx_nic *efx, struct msix_entry *xentries)
 {
 #ifdef CONFIG_RFS_ACCEL
-	int i, rc;
+	unsigned int i;
+	int rc;
 
 	efx->net_dev->rx_cpu_rmap = alloc_irq_cpu_rmap(efx->n_rx_channels);
 	if (!efx->net_dev->rx_cpu_rmap)
@@ -1159,13 +1160,14 @@ efx_init_rx_cpu_rmap(struct efx_nic *efx, struct msix_entry *xentries)
  */
 static int efx_probe_interrupts(struct efx_nic *efx)
 {
-	int max_channels =
-		min_t(int, efx->type->phys_addr_channels, EFX_MAX_CHANNELS);
-	int rc, i;
+	unsigned int max_channels =
+		min(efx->type->phys_addr_channels, EFX_MAX_CHANNELS);
+	unsigned int i;
+	int rc;
 
 	if (efx->interrupt_mode == EFX_INT_MODE_MSIX) {
 		struct msix_entry xentries[EFX_MAX_CHANNELS];
-		int n_channels;
+		unsigned int n_channels;
 
 		n_channels = efx_wanted_parallelism();
 		if (separate_tx_channels)
@@ -1178,7 +1180,7 @@ static int efx_probe_interrupts(struct efx_nic *efx)
 		if (rc > 0) {
 			netif_err(efx, drv, efx->net_dev,
 				  "WARNING: Insufficient MSI-X vectors"
-				  " available (%d < %d).\n", rc, n_channels);
+				  " available (%d < %u).\n", rc, n_channels);
 			netif_err(efx, drv, efx->net_dev,
 				  "WARNING: Performance may be reduced.\n");
 			EFX_BUG_ON_PARANOID(rc >= n_channels);
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 59c0583..3260e71 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -52,7 +52,7 @@
  *
  **************************************************************************/
 
-#define EFX_MAX_CHANNELS 32
+#define EFX_MAX_CHANNELS 32U
 #define EFX_MAX_RX_QUEUES EFX_MAX_CHANNELS
 
 /* Checksum generation is a per-queue option in hardware, so each
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
