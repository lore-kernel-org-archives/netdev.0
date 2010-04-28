From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 01/17] sfc: Ignore parity errors in the other port's SRAM
Date: Wed, 28 Apr 2010 20:25:22 +0100
Message-ID: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12284 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753886Ab0D1TZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:25:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Siena has a separate SRAM bank for each port.  On single-port boards
these can be merged together, so each port has an interrupt flag for
parity errors in the other port's SRAM.  Currently we do not enable
such merging and should mask this interrupt source.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/nic.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index b06f8e3..664fd6c 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -1563,6 +1563,8 @@ void efx_nic_init_common(struct efx_nic *efx)
 			     FRF_AZ_ILL_ADR_INT_KER_EN, 1,
 			     FRF_AZ_RBUF_OWN_INT_KER_EN, 1,
 			     FRF_AZ_TBUF_OWN_INT_KER_EN, 1);
+	if (efx_nic_rev(efx) >= EFX_REV_SIENA_A0)
+		EFX_SET_OWORD_FIELD(temp, FRF_CZ_SRAM_PERR_INT_P_KER_EN, 1);
 	EFX_INVERT_OWORD(temp);
 	efx_writeo(efx, &temp, FR_AZ_FATAL_INTR_KER);
 
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

