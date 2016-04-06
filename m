From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/14] i40e: Fix for supported link modes in 10GBaseT PHY's
Date: Tue,  5 Apr 2016 20:36:05 -0700
Message-ID: <1459913769-56510-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Avinash Dayanand <avinash.dayanand@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60574 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760852AbcDFDg2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 23:36:28 -0400
In-Reply-To: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Avinash Dayanand <avinash.dayanand@intel.com>

100baseT/Full is now listed and supported link mode for 10GBaseT PHY.
This is a fix to list all the supported link modes of 10GBaseT PHY.

Change-ID: If2be3212ef0fef85fd5d6e4550c7783de2f915e9
Signed-off-by: Avinash Dayanand <avinash.dayanand@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 410d237..8a83d45 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -313,6 +313,13 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 			ecmd->advertising |= ADVERTISED_10000baseT_Full;
 		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_1GB)
 			ecmd->advertising |= ADVERTISED_1000baseT_Full;
+		/* adding 100baseT support for 10GBASET_PHY */
+		if (pf->flags & I40E_FLAG_HAVE_10GBASET_PHY) {
+			ecmd->supported |= SUPPORTED_100baseT_Full;
+			ecmd->advertising |= ADVERTISED_100baseT_Full |
+					     ADVERTISED_1000baseT_Full |
+					     ADVERTISED_10000baseT_Full;
+		}
 		break;
 	case I40E_PHY_TYPE_1000BASE_T_OPTICAL:
 		ecmd->supported = SUPPORTED_Autoneg |
@@ -325,6 +332,15 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 				  SUPPORTED_100baseT_Full;
 		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_100MB)
 			ecmd->advertising |= ADVERTISED_100baseT_Full;
+		/* firmware detects 10G phy as 100M phy at 100M speed */
+		if (pf->flags & I40E_FLAG_HAVE_10GBASET_PHY) {
+			ecmd->supported |= SUPPORTED_10000baseT_Full |
+					   SUPPORTED_1000baseT_Full;
+			ecmd->advertising |= ADVERTISED_Autoneg |
+					     ADVERTISED_100baseT_Full |
+					     ADVERTISED_1000baseT_Full |
+					     ADVERTISED_10000baseT_Full;
+		}
 		break;
 	case I40E_PHY_TYPE_10GBASE_CR1_CU:
 	case I40E_PHY_TYPE_10GBASE_CR1:
-- 
2.5.5
