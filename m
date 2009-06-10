From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/2] sfc: Expose 100/1000BASE-T MDI-X status via ethtool
Date: Wed, 10 Jun 2009 16:30:05 +0100
Message-ID: <1244647805.2848.10.camel@achroite>
References: <1244647684.2848.8.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:48123 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756950AbZFJPaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 11:30:05 -0400
In-Reply-To: <1244647684.2848.8.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/tenxpress.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index db723c5..f4d5090 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -63,6 +63,7 @@
 
 /* extended status register */
 #define PMA_PMD_XSTATUS_REG	49153
+#define PMA_PMD_XSTAT_MDIX_LBN	14
 #define PMA_PMD_XSTAT_FLP_LBN   (12)
 
 /* LED control register */
@@ -741,9 +742,17 @@ tenxpress_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 
 	mdio45_ethtool_gset_npage(&efx->mdio, ecmd, adv, lpa);
 
-	if (efx->phy_type != PHY_TYPE_SFX7101)
+	if (efx->phy_type != PHY_TYPE_SFX7101) {
 		ecmd->supported |= (SUPPORTED_100baseT_Full |
 				    SUPPORTED_1000baseT_Full);
+		if (ecmd->speed != SPEED_10000) {
+			ecmd->eth_tp_mdix =
+				(efx_mdio_read(efx, MDIO_MMD_PMAPMD,
+					       PMA_PMD_XSTATUS_REG) &
+				 (1 << PMA_PMD_XSTAT_MDIX_LBN))
+				? ETH_TP_MDI_X : ETH_TP_MDI;
+		}
+	}
 
 	/* In loopback, the PHY automatically brings up the correct interface,
 	 * but doesn't advertise the correct speed. So override it */

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

