From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 25/52] sfc: Remove initialisation of RX_FILTER_CTL_REG.NUM_KER
Date: Mon, 1 Sep 2008 12:47:52 +0100
Message-ID: <20080901114751.GS7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:59329 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759580AbYIALrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:47:55 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have long since given up doing RSS on Falcon A1 and therefore we
would always write the default value of 0.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 03194d6..bfae082 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2780,19 +2780,14 @@ int falcon_init_nic(struct efx_nic *efx)
 	EFX_INVERT_OWORD(temp);
 	falcon_write(efx, &temp, FATAL_INTR_REG_KER);
 
-	/* Set number of RSS queues for receive path. */
-	falcon_read(efx, &temp, RX_FILTER_CTL_REG);
-	if (falcon_rev(efx) >= FALCON_REV_B0)
-		EFX_SET_OWORD_FIELD(temp, NUM_KER, 0);
-	else
-		EFX_SET_OWORD_FIELD(temp, NUM_KER, efx->n_rx_queues - 1);
 	if (EFX_WORKAROUND_7244(efx)) {
+		falcon_read(efx, &temp, RX_FILTER_CTL_REG);
 		EFX_SET_OWORD_FIELD(temp, UDP_FULL_SRCH_LIMIT, 8);
 		EFX_SET_OWORD_FIELD(temp, UDP_WILD_SRCH_LIMIT, 8);
 		EFX_SET_OWORD_FIELD(temp, TCP_FULL_SRCH_LIMIT, 8);
 		EFX_SET_OWORD_FIELD(temp, TCP_WILD_SRCH_LIMIT, 8);
+		falcon_write(efx, &temp, RX_FILTER_CTL_REG);
 	}
-	falcon_write(efx, &temp, RX_FILTER_CTL_REG);
 
 	falcon_setup_rss_indir_table(efx);
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

