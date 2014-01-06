From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40e: Hide the Port VLAN VLAN ID
Date: Mon,  6 Jan 2014 04:30:33 -0800
Message-ID: <1389011436-18424-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389011436-18424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22497 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753845AbaAFMap (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 07:30:45 -0500
In-Reply-To: <1389011436-18424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The VF VSI Port VLAN settings still allow the user to view VLAN tag in
the descriptor.  Fix the settings to hide the VLAN ID from the VF. The
VF is not supposed to be aware it is on a VLAN in the Port VLAN
scenario.

Change-Id: I976f2bacb455dbb750f8c53a781c689f02cb8907
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 40484e0..9c16aa8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2018,7 +2018,7 @@ int i40e_vsi_add_pvid(struct i40e_vsi *vsi, u16 vid)
 	vsi->info.pvid = cpu_to_le16(vid);
 	vsi->info.port_vlan_flags = I40E_AQ_VSI_PVLAN_MODE_TAGGED |
 				    I40E_AQ_VSI_PVLAN_INSERT_PVID |
-				    I40E_AQ_VSI_PVLAN_EMOD_STR_BOTH;
+				    I40E_AQ_VSI_PVLAN_EMOD_STR;
 
 	ctxt.seid = vsi->seid;
 	memcpy(&ctxt.info, &vsi->info, sizeof(vsi->info));
-- 
1.8.3.1
