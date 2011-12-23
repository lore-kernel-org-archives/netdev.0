From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/9] igb: Add flow control advertising to ethtool setting.
Date: Fri, 23 Dec 2011 01:09:10 -0800
Message-ID: <1324631357-31789-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:44079 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753862Ab1LWJJV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Dec 2011 04:09:21 -0500
In-Reply-To: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

Added pause flag for bi-directional flow control advertising to ethtool
settings.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index e9335ef..f1206be 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -148,7 +148,8 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 				   SUPPORTED_1000baseT_Full|
 				   SUPPORTED_Autoneg |
 				   SUPPORTED_TP);
-		ecmd->advertising = ADVERTISED_TP;
+		ecmd->advertising = (ADVERTISED_TP |
+				     ADVERTISED_Pause);
 
 		if (hw->mac.autoneg == 1) {
 			ecmd->advertising |= ADVERTISED_Autoneg;
@@ -165,7 +166,8 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 
 		ecmd->advertising = (ADVERTISED_1000baseT_Full |
 				     ADVERTISED_FIBRE |
-				     ADVERTISED_Autoneg);
+				     ADVERTISED_Autoneg |
+				     ADVERTISED_Pause);
 
 		ecmd->port = PORT_FIBRE;
 	}
-- 
1.7.7.4
