From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 14/17] i40e: Recognize 1000Base_T_Optical phy type when link is up
Date: Fri, 16 Oct 2015 05:10:22 -0700
Message-ID: <1444997425-3396-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444997425-3396-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:56709 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753813AbbJPMKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 08:10:32 -0400
In-Reply-To: <1444997425-3396-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

1000Base_T_Optical got added to the function that figures out what
is supported when link is down but not when link is up. Add it in there
too so that we display the correct information.

Change-ID: I85ebcdfa7c02d898c44c673b1500552a53c8042e
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 1a50068..767b1db 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -307,6 +307,12 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_1GB)
 			ecmd->advertising |= ADVERTISED_1000baseT_Full;
 		break;
+	case I40E_PHY_TYPE_1000BASE_T_OPTICAL:
+		ecmd->supported = SUPPORTED_Autoneg |
+				  SUPPORTED_1000baseT_Full;
+		ecmd->advertising = ADVERTISED_Autoneg |
+				    ADVERTISED_1000baseT_Full;
+		break;
 	case I40E_PHY_TYPE_100BASE_TX:
 		ecmd->supported = SUPPORTED_Autoneg |
 				  SUPPORTED_100baseT_Full;
-- 
2.4.3
