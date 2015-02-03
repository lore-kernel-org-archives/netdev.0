From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net] amd-xgbe: Adjust for zero-based traffic class count
Date: Tue, 3 Feb 2015 12:49:55 -0600
Message-ID: <20150203184955.14713.98160.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0114.outbound.protection.outlook.com ([157.56.110.114]:45210
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756010AbbBCTEY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 14:04:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The number of traffic classes reported by the hardware is zero-based
so increment the value returned to get an actual count.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 7bb5f07..1246140 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -552,13 +552,14 @@ void xgbe_get_all_hw_features(struct xgbe_prv_data *pdata)
 		break;
 	}
 
-	/* The Queue and Channel counts are zero based so increment them
+	/* The Queue, Channel and TC counts are zero based so increment them
 	 * to get the actual number
 	 */
 	hw_feat->rx_q_cnt++;
 	hw_feat->tx_q_cnt++;
 	hw_feat->rx_ch_cnt++;
 	hw_feat->tx_ch_cnt++;
+	hw_feat->tc_cnt++;
 
 	DBGPR("<--xgbe_get_all_hw_features\n");
 }
