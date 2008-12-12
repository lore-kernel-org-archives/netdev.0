From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 04/33] sfc: Remove unneeded register write
Date: Fri, 12 Dec 2008 12:49:31 +0000
Message-ID: <20081212124930.GD10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:49732 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756799AbYLLMtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:49:33 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was only ever needed for an FPGA version of Falcon.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index ac0b671..3af361a 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2881,15 +2881,6 @@ int falcon_init_nic(struct efx_nic *efx)
 	unsigned thresh;
 	int rc;
 
-	/* Set up the address region register. This is only needed
-	 * for the B0 FPGA, but since we are just pushing in the
-	 * reset defaults this may as well be unconditional. */
-	EFX_POPULATE_OWORD_4(temp, ADR_REGION0, 0,
-				   ADR_REGION1, (1 << 16),
-				   ADR_REGION2, (2 << 16),
-				   ADR_REGION3, (3 << 16));
-	falcon_write(efx, &temp, ADR_REGION_REG_KER);
-
 	/* Use on-chip SRAM */
 	falcon_read(efx, &temp, NIC_STAT_REG);
 	EFX_SET_OWORD_FIELD(temp, ONCHIP_SRAM, 1);
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
