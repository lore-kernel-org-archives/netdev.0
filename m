From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 1/3] amd-xgbe: Add setting of a missing hardware
 feature
Date: Fri, 22 May 2015 16:32:09 -0500
Message-ID: <20150522213208.23869.34950.stgit@tlendack-t1.amdoffice.net>
References: <20150522213202.23869.67673.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0125.outbound.protection.outlook.com ([65.55.169.125]:51936
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1945968AbbEVVcN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2015 17:32:13 -0400
In-Reply-To: <20150522213202.23869.67673.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device private data structure contains all the defined hardware
features for the device. However one of the features is not set. Even
though the feature is not currently used, set it to avoid future
issues of the feature being checked thinking it has been properly set.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index e452179..c752049 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -531,6 +531,7 @@ void xgbe_get_all_hw_features(struct xgbe_prv_data *pdata)
 						RXFIFOSIZE);
 	hw_feat->tx_fifo_size  = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R,
 						TXFIFOSIZE);
+	hw_feat->adv_ts_hi     = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R, ADVTHWORD);
 	hw_feat->dma_width     = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R, ADDR64);
 	hw_feat->dcb           = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R, DCBEN);
 	hw_feat->sph           = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R, SPHEN);
