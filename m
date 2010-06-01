From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 04/12] sfc: Synchronise link_advertising and wanted_fc on
 Siena
Date: Tue, 01 Jun 2010 22:18:08 +0100
Message-ID: <1275427088.2114.29.camel@achroite.uk.solarflarecom.com>
References: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:50562 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754694Ab0FAVSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 17:18:11 -0400
In-Reply-To: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

All of the ethtool code paths keep them in sync, but we need
to ensure they are sync'd at start of day. Matches the sft9001
driver.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mcdi_phy.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/mcdi_phy.c b/drivers/net/sfc/mcdi_phy.c
index 5c23f22..86e43b1 100644
--- a/drivers/net/sfc/mcdi_phy.c
+++ b/drivers/net/sfc/mcdi_phy.c
@@ -395,6 +395,7 @@ static int efx_mcdi_phy_probe(struct efx_nic *efx)
 	efx->wanted_fc = EFX_FC_RX | EFX_FC_TX;
 	if (phy_data->supported_cap & (1 << MC_CMD_PHY_CAP_AN_LBN))
 		efx->wanted_fc |= EFX_FC_AUTO;
+	efx_link_set_wanted_fc(efx, efx->wanted_fc);
 
 	return 0;
 
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

