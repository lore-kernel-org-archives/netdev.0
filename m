From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/6] ixgbe: fix ethtool reporting of supported links for SFP modules
Date: Fri, 13 Sep 2013 14:12:08 -0700
Message-ID: <1379106730-14994-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1379106730-14994-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38706 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753932Ab3IMVMT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Sep 2013 17:12:19 -0400
In-Reply-To: <1379106730-14994-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch resolves an issue where the driver will display incorrect info
for Q/SFP+ modules that were inserted after the driver has been loaded.

This patch adds a call to identify_phy() in ixgbe_get_settings() prior to
calling get_link_capabilities() which needs the PHY data in order to
determine the correct settings.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index b41db3b..e8649ab 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -160,6 +160,13 @@ static int ixgbe_get_settings(struct net_device *netdev,
 	bool autoneg = false;
 	bool link_up;
 
+	/* SFP type is needed for get_link_capabilities */
+	if (hw->phy.media_type & (ixgbe_media_type_fiber |
+				  ixgbe_media_type_fiber_qsfp)) {
+		if (hw->phy.sfp_type == ixgbe_sfp_type_not_present)
+				hw->phy.ops.identify_sfp(hw);
+	}
+
 	hw->mac.ops.get_link_capabilities(hw, &supported_link, &autoneg);
 
 	/* set the supported link speeds */
-- 
1.8.3.1
