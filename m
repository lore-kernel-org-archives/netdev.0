From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] i40e: Reassign incorrect PHY type to fix a FW bug
Date: Thu,  5 Mar 2015 08:46:25 -0800
Message-ID: <1425573992-30955-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:47536 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754768AbbCEQqi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 11:46:38 -0500
In-Reply-To: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Some FW versions are incorrectly reporting a breakout cable as PHY type
0x3 when it should be 0x16 (I40E_PHY_TYPE_10GBASE_SFPP_CU).
If we get this value back from FW and the version is < 4.40, reassign it
to I40E_PHY_TYPE_10GBASE_SFPP_CU.

Change-ID: Ibb41a0e3cd2c0753744e8553959240df6ed13ae8
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index cc10303..0bfc82b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1481,6 +1481,10 @@ i40e_status i40e_aq_get_link_info(struct i40e_hw *hw,
 	else
 		hw_link_info->lse_enable = false;
 
+	if ((hw->aq.fw_maj_ver < 4 || (hw->aq.fw_maj_ver == 4 &&
+	     hw->aq.fw_min_ver < 40)) && hw_link_info->phy_type == 0xE)
+		hw_link_info->phy_type = I40E_PHY_TYPE_10GBASE_SFPP_CU;
+
 	/* save link status information */
 	if (link)
 		*link = *hw_link_info;
-- 
1.9.3
