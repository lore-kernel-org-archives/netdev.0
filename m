From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 02/10] sfc: Remove redundant function
 efx_nic_has_mc()
Date: Sat, 10 Mar 2012 00:49:07 +0000
Message-ID: <1331340547.2537.12.camel@bwh-desktop>
References: <1331340409.2537.10.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:32192 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756821Ab2CJAtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 19:49:11 -0500
In-Reply-To: <1331340409.2537.10.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is now used in only one place, where it always returns
true.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/nic.h   |    4 ----
 drivers/net/ethernet/sfc/siena.c |    3 +--
 2 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 246c414..ac12f7f 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -35,10 +35,6 @@ static inline int efx_nic_rev(struct efx_nic *efx)
 
 extern u32 efx_nic_fpga_ver(struct efx_nic *efx);
 
-static inline bool efx_nic_has_mc(struct efx_nic *efx)
-{
-	return efx_nic_rev(efx) >= EFX_REV_SIENA_A0;
-}
 /* NIC has two interlinked PCI functions for the same port. */
 static inline bool efx_nic_is_dual_func(struct efx_nic *efx)
 {
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 7bea790..9f8d7ce 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -409,8 +409,7 @@ static void siena_remove_nic(struct efx_nic *efx)
 	siena_reset_hw(efx, RESET_TYPE_ALL);
 
 	/* Relinquish the device back to the BMC */
-	if (efx_nic_has_mc(efx))
-		efx_mcdi_drv_attach(efx, false, NULL);
+	efx_mcdi_drv_attach(efx, false, NULL);
 
 	/* Tear down the private nic state */
 	kfree(efx->nic_data);
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
