From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/4] igb: Supported and Advertised Pause Frame
Date: Tue,  4 Sep 2012 23:25:49 -0700
Message-ID: <1346826350-27733-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1346826350-27733-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58196 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991Ab2IEG0o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2012 02:26:44 -0400
In-Reply-To: <1346826350-27733-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>

This patch add ethtool supports for Supported and Advertised Pause Frame,
based on Adapter Flow Control settings.

Signed-off-by: Akeem G. Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index c4def55..a294441 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -148,9 +148,9 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 				   SUPPORTED_100baseT_Full |
 				   SUPPORTED_1000baseT_Full|
 				   SUPPORTED_Autoneg |
-				   SUPPORTED_TP);
-		ecmd->advertising = (ADVERTISED_TP |
-				     ADVERTISED_Pause);
+				   SUPPORTED_TP |
+				   SUPPORTED_Pause);
+		ecmd->advertising = ADVERTISED_TP;
 
 		if (hw->mac.autoneg == 1) {
 			ecmd->advertising |= ADVERTISED_Autoneg;
@@ -158,6 +158,21 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 			ecmd->advertising |= hw->phy.autoneg_advertised;
 		}
 
+		if (hw->mac.autoneg != 1)
+			ecmd->advertising &= ~(ADVERTISED_Pause |
+					       ADVERTISED_Asym_Pause);
+
+		if (hw->fc.requested_mode == e1000_fc_full)
+			ecmd->advertising |= ADVERTISED_Pause;
+		else if (hw->fc.requested_mode == e1000_fc_rx_pause)
+			ecmd->advertising |= (ADVERTISED_Pause |
+					      ADVERTISED_Asym_Pause);
+		else if (hw->fc.requested_mode == e1000_fc_tx_pause)
+			ecmd->advertising |=  ADVERTISED_Asym_Pause;
+		else
+			ecmd->advertising &= ~(ADVERTISED_Pause |
+					       ADVERTISED_Asym_Pause);
+
 		ecmd->port = PORT_TP;
 		ecmd->phy_address = hw->phy.addr;
 	} else {
-- 
1.7.11.4
