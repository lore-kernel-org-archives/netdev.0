From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 07/32] sfc: Rename efx_wanted_channels() to
 efx_wanted_parallelism()
Date: Fri, 27 Jan 2012 20:44:15 +0000
Message-ID: <1327697055.2503.14.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:63527 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753136Ab2A0UoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:44:18 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function returns the degree of parallelism wanted, which is not
necessarily the total number of channels we want to create.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 9ca5dcd..5fcc42f 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1146,9 +1146,7 @@ static void efx_fini_io(struct efx_nic *efx)
 	pci_disable_device(efx->pci_dev);
 }
 
-/* Get number of channels wanted.  Each channel will have its own IRQ,
- * 1 RX queue and/or 2 TX queues. */
-static int efx_wanted_channels(void)
+static int efx_wanted_parallelism(void)
 {
 	cpumask_var_t core_mask;
 	int count;
@@ -1211,7 +1209,7 @@ static int efx_probe_interrupts(struct efx_nic *efx)
 		struct msix_entry xentries[EFX_MAX_CHANNELS];
 		int n_channels;
 
-		n_channels = efx_wanted_channels();
+		n_channels = efx_wanted_parallelism();
 		if (separate_tx_channels)
 			n_channels *= 2;
 		n_channels = min(n_channels, max_channels);
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
