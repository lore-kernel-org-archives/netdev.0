From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6] sfc: 10Xpress: Report support for pause frames
Date: Thu, 22 Oct 2009 23:25:14 +0100
Message-ID: <1256250314.2785.22.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:19586 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbZJVWZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 18:25:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commits 27fbc7d 'mdio: Expose pause frame advertising flags to ethtool'
and c634263 'sfc: 10Xpress: Initialise pause advertising flags'
added to our reported advertising flags.

efx_mdio_set_settings() requires that all advertising flags are
also present in the supported flags, so make sure that is true.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This fixes a regression in 2.6.32: after resetting a 10Xpress PHY we
fail to reconfigure it if pause frames are enabled.  Manually changing
pause frame settings will also fail.

Ben.

 drivers/net/sfc/tenxpress.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 1a3495c..352cc56 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -752,6 +752,7 @@ tenxpress_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 
 	mdio45_ethtool_gset_npage(&efx->mdio, ecmd, adv, lpa);
 
+	ecmd->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
 	if (efx->phy_type != PHY_TYPE_SFX7101) {
 		ecmd->supported |= (SUPPORTED_100baseT_Full |
 				    SUPPORTED_1000baseT_Full);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

