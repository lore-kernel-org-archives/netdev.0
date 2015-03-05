From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/14] i40e: Add AOC PHY types to case statements
Date: Thu,  5 Mar 2015 08:46:27 -0800
Message-ID: <1425573992-30955-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:47536 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754977AbbCEQqj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 11:46:39 -0500
In-Reply-To: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Add the 10G and 40G AOC PHY types to the case statement in get_media_type
and ethtool get_settings so that the correct information gets reported
back to the user.

Change-ID: I1b4849d22199a9acf7c8807166d0317c1faad375
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c  | 2 ++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 0bfc82b..99af788 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -834,6 +834,8 @@ static enum i40e_media_type i40e_get_media_type(struct i40e_hw *hw)
 	case I40E_PHY_TYPE_10GBASE_CR1:
 	case I40E_PHY_TYPE_40GBASE_CR4:
 	case I40E_PHY_TYPE_10GBASE_SFPP_CU:
+	case I40E_PHY_TYPE_40GBASE_AOC:
+	case I40E_PHY_TYPE_10GBASE_AOC:
 		media = I40E_MEDIA_TYPE_DA;
 		break;
 	case I40E_PHY_TYPE_1000BASE_KX:
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 415aebc..764305e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -259,6 +259,7 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 		break;
 	case I40E_PHY_TYPE_XLAUI:
 	case I40E_PHY_TYPE_XLPPI:
+	case I40E_PHY_TYPE_40GBASE_AOC:
 		ecmd->supported = SUPPORTED_40000baseCR4_Full;
 		break;
 	case I40E_PHY_TYPE_40GBASE_KR4:
@@ -328,6 +329,7 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 	case I40E_PHY_TYPE_XFI:
 	case I40E_PHY_TYPE_SFI:
 	case I40E_PHY_TYPE_10GBASE_SFPP_CU:
+	case I40E_PHY_TYPE_10GBASE_AOC:
 		ecmd->supported = SUPPORTED_10000baseT_Full;
 		break;
 	case I40E_PHY_TYPE_SGMII:
-- 
1.9.3
