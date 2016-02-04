From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/20] i40e: Replace X722 mac check in ethtool get_settings
Date: Thu,  4 Feb 2016 03:48:54 -0800
Message-ID: <1454586551-35919-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50262 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933863AbcBDLtP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 06:49:15 -0500
In-Reply-To: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

100M SGMII is only supported on X722.  Replace the mac check with
a feature flag check that is only set for the X722 device.

Change-ID: I53452d9af6af8cd9dca8500215fbc6ce93418f52
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         | 1 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 68f2204..47f6c0a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -339,6 +339,7 @@ struct i40e_pf {
 #define I40E_FLAG_VEB_MODE_ENABLED		BIT_ULL(40)
 #define I40E_FLAG_GENEVE_OFFLOAD_CAPABLE	BIT_ULL(41)
 #define I40E_FLAG_NO_PCI_LINK_CHECK		BIT_ULL(42)
+#define I40E_FLAG_100M_SGMII_CAPABLE		BIT_ULL(43)
 #define I40E_FLAG_PF_MAC			BIT_ULL(50)
 
 	/* tracks features that get auto disabled by errors */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index c8b9dca..252a9dd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -340,7 +340,7 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 				  SUPPORTED_1000baseT_Full;
 		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_1GB)
 			ecmd->advertising |= ADVERTISED_1000baseT_Full;
-		if (pf->hw.mac.type == I40E_MAC_X722) {
+		if (pf->flags & I40E_FLAG_100M_SGMII_CAPABLE) {
 			ecmd->supported |= SUPPORTED_100baseT_Full;
 			if (hw_link_info->requested_speeds &
 			    I40E_LINK_SPEED_100MB)
-- 
2.5.0
