From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] sfc: SFT9001: Fix condition for LNPGA power-off
Date: Sat, 10 Jan 2009 23:05:03 +0000
Message-ID: <1231628703.2671.3.camel@hashbaz.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:1187 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751163AbZAJW7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 17:59:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only the SFX7101 requires software power control.  This was
incorrectly being applied to the SFT9001 rev A as well.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/tenxpress.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index b976876..9ecb77d 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -636,10 +636,11 @@ static void tenxpress_phy_fini(struct efx_nic *efx)
 {
 	int reg;
 
-	if (efx->phy_type == PHY_TYPE_SFT9001B) {
+	if (efx->phy_type == PHY_TYPE_SFT9001B)
 		device_remove_file(&efx->pci_dev->dev,
 				   &dev_attr_phy_short_reach);
-	} else {
+
+	if (efx->phy_type == PHY_TYPE_SFX7101) {
 		/* Power down the LNPGA */
 		reg = (1 << PMA_PMD_LNPGA_POWERDOWN_LBN);
 		mdio_clause45_write(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


