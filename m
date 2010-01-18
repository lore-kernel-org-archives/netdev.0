From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6] sfc: QT202x: Remove unreliable MMD check at
	initialisation
Date: Mon, 18 Jan 2010 15:47:16 +0000
Message-ID: <1263829636.3667.3.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:25399 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078Ab0ARPrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 10:47:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Slattery <mslattery@solarflare.com>

Checking the PHY XS MMD here is unnecessary and can give false negatives.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/qt202x_phy.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sfc/qt202x_phy.c b/drivers/net/sfc/qt202x_phy.c
index ff8f0a4..e0d13a4 100644
--- a/drivers/net/sfc/qt202x_phy.c
+++ b/drivers/net/sfc/qt202x_phy.c
@@ -318,12 +318,6 @@ static int qt202x_reset_phy(struct efx_nic *efx)
 	/* Wait 250ms for the PHY to complete bootup */
 	msleep(250);
 
-	/* Check that all the MMDs we expect are present and responding. We
-	 * expect faults on some if the link is down, but not on the PHY XS */
-	rc = efx_mdio_check_mmds(efx, QT202X_REQUIRED_DEVS, MDIO_DEVS_PHYXS);
-	if (rc < 0)
-		goto fail;
-
 	falcon_board(efx)->type->init_phy(efx);
 
 	return rc;
-- 
1.5.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

