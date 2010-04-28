From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 08/17] sfc: Read MEM_STAT for SRM_PERR as well as MEM_PERR
 errors
Date: Wed, 28 Apr 2010 20:28:52 +0100
Message-ID: <1272482932.2549.24.camel@achroite.uk.solarflarecom.com>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12524 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756754Ab0D1T2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:28:55 -0400
In-Reply-To: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Parity errors in different blocks of SRAM may set one of two different
interrupt flags.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/nic.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index b61674c..4105f90 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -1287,7 +1287,8 @@ irqreturn_t efx_nic_fatal_interrupt(struct efx_nic *efx)
 		error ? "disabling bus mastering" : "no recognised error");
 
 	/* If this is a memory parity error dump which blocks are offending */
-	mem_perr = EFX_OWORD_FIELD(fatal_intr, FRF_AZ_MEM_PERR_INT_KER);
+	mem_perr = (EFX_OWORD_FIELD(fatal_intr, FRF_AZ_MEM_PERR_INT_KER) ||
+		    EFX_OWORD_FIELD(fatal_intr, FRF_AZ_SRM_PERR_INT_KER));
 	if (mem_perr) {
 		efx_oword_t reg;
 		efx_reado(efx, &reg, FR_AZ_MEM_STAT);
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

