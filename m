From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 50/52] sfc: Disable interrupts after a fatal interrupt occurs until reset
Date: Mon, 1 Sep 2008 12:50:14 +0100
Message-ID: <20080901115013.GQ7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:35748 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759704AbYIALuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:50:16 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This should avoid an interrupt storm, which has been observed in the
field with one faulty board.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 3a5289f..d30c938 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1374,10 +1374,11 @@ static irqreturn_t falcon_fatal_interrupt(struct efx_nic *efx)
 			EFX_OWORD_FMT "\n", EFX_OWORD_VAL(reg));
 	}
 
-	/* Disable DMA bus mastering on both devices */
+	/* Disable both devices */
 	pci_disable_device(efx->pci_dev);
 	if (FALCON_IS_DUAL_FUNC(efx))
 		pci_disable_device(nic_data->pci_dev2);
+	falcon_disable_interrupts(efx);
 
 	if (++n_int_errors < FALCON_MAX_INT_ERRORS) {
 		EFX_ERR(efx, "SYSTEM ERROR - reset scheduled\n");
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

