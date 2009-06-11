From: Chaitanya Lala <clala@riverbed.com>
Subject: [net-next PATCH 1/1] igb: Expose MDI-X status accessible via
	ethtool
Date: Wed, 10 Jun 2009 17:42:00 -0700
Message-ID: <20090611004200.GA18663@clala-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.riverbed.com ([208.70.196.45]:58177 "EHLO
	smtp1.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752668AbZFKAub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 20:50:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In a recent patch, ethtool kernel interface changed to
incorporate MDI-X status. We expose MDI-X status with this patch.
This patch depends a previous patch called
"e1000e: Expose MDI-X status via ethtool change".

Signed-off-by: Chaitanya Lala <clala@riverbed.com>
Signed-off-by: Arthur Jones <ajones@riverbed.com>
---
 drivers/net/igb/igb_ethtool.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 27eae49..17486ff 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -168,6 +168,15 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 
 	ecmd->autoneg = ((hw->phy.media_type == e1000_media_type_fiber) ||
 			 hw->mac.autoneg) ? AUTONEG_ENABLE : AUTONEG_DISABLE;
+
+	/* MDI-X => 2; MDI =>1; Invalid =>0 */
+	if ((hw->phy.media_type == e1000_media_type_copper) &&
+	    !hw->mac.get_link_status)
+		ecmd->eth_tp_mdix = hw->phy.is_mdix ? ETH_TP_MDI_X :
+							ETH_TP_MDI;
+	else
+		ecmd->eth_tp_mdix = ETH_TP_MDI_INVALID;
+
 	return 0;
 }
 
-- 
1.6.0.4

