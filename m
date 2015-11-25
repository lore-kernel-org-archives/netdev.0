From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/16] i40e: return the number of enabled queues for ETHTOOL_GRXRINGS
Date: Tue, 24 Nov 2015 16:04:43 -0800
Message-ID: <1448409886-90686-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Helin Zhang <helin.zhang@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:23956 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752375AbbKYAEy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 19:04:54 -0500
In-Reply-To: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Helin Zhang <helin.zhang@intel.com>

This patch fixes a problem where using ethtool rxnfc command could
let RX flow hash be set on disabled queues. This patch fixes the
problem by returning the number of enabled queues before setting
rxnfc.

Change-ID: Idbac86b0b47ddacc8deee7cd257e41de01cbe5c0
Signed-off-by: Helin Zhang <helin.zhang@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index eeb1af4..a89da8a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2111,7 +2111,7 @@ static int i40e_get_rxnfc(struct net_device *netdev, struct ethtool_rxnfc *cmd,
 
 	switch (cmd->cmd) {
 	case ETHTOOL_GRXRINGS:
-		cmd->data = vsi->alloc_queue_pairs;
+		cmd->data = vsi->num_queue_pairs;
 		ret = 0;
 		break;
 	case ETHTOOL_GRXFH:
-- 
2.5.0
