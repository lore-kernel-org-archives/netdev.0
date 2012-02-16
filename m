From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 17/19] sfc: Pass NIC structure into
 efx_wanted_parallelism()
Date: Thu, 16 Feb 2012 00:51:16 +0000
Message-ID: <1329353476.2565.43.camel@bwh-desktop>
References: <1329352938.2565.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:27726 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756662Ab2BPAvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 19:51:19 -0500
In-Reply-To: <1329352938.2565.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This lets us identify the NIC affected in case of failure, and
will be necessary to adjust for SR-IOV constraints.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 0a9ab49..e943ffb 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1169,7 +1169,7 @@ static void efx_fini_io(struct efx_nic *efx)
 	pci_disable_device(efx->pci_dev);
 }
 
-static unsigned int efx_wanted_parallelism(void)
+static unsigned int efx_wanted_parallelism(struct efx_nic *efx)
 {
 	cpumask_var_t thread_mask;
 	unsigned int count;
@@ -1179,8 +1179,8 @@ static unsigned int efx_wanted_parallelism(void)
 		return rss_cpus;
 
 	if (unlikely(!zalloc_cpumask_var(&thread_mask, GFP_KERNEL))) {
-		printk(KERN_WARNING
-		       "sfc: RSS disabled due to allocation failure\n");
+		netif_warn(efx, probe, efx->net_dev,
+			   "RSS disabled due to allocation failure\n");
 		return 1;
 	}
 
@@ -1239,7 +1239,7 @@ static int efx_probe_interrupts(struct efx_nic *efx)
 		struct msix_entry xentries[EFX_MAX_CHANNELS];
 		unsigned int n_channels;
 
-		n_channels = efx_wanted_parallelism();
+		n_channels = efx_wanted_parallelism(efx);
 		if (separate_tx_channels)
 			n_channels *= 2;
 		n_channels += extra_channels;
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
