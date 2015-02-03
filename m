From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net] amd-xgbe: Set RSS enablement based on hardware features
Date: Tue, 3 Feb 2015 14:14:32 -0600
Message-ID: <20150203201432.18889.73945.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0107.outbound.protection.outlook.com ([65.55.169.107]:39936
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S966671AbbBCUOo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 15:14:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RSS support requires enablement based on the features reported by
the hardware. The setting of this flag is missing. Add support to
set the RSS enablement flag based on the reported hardware features.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 1246140..e5ffb2c 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -523,6 +523,7 @@ void xgbe_get_all_hw_features(struct xgbe_prv_data *pdata)
 	hw_feat->sph           = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R, SPHEN);
 	hw_feat->tso           = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R, TSOEN);
 	hw_feat->dma_debug     = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R, DBGMEMA);
+	hw_feat->rss           = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R, RSSEN);
 	hw_feat->tc_cnt	       = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R, NUMTC);
 	hw_feat->hash_table_size = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R,
 						  HASHTBLSZ);
