From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 04/15] i40e: Allow VF to set already assigned MAC address
Date: Tue,  7 Jan 2014 22:07:25 -0800
Message-ID: <1389161256-24599-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389161256-24599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62026 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755074AbaAHGIf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 01:08:35 -0500
In-Reply-To: <1389161256-24599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The VF is allowed to request the PF to set its already assigned
MAC address without generating an error.

Change-Id: I8dfdf353396995dbbb26cafab4e42b451911da3d
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index fee368a..5c99164 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1348,10 +1348,13 @@ static inline int i40e_check_vf_permission(struct i40e_vf *vf, u8 *macaddr)
 		   is_zero_ether_addr(macaddr)) {
 		dev_err(&pf->pdev->dev, "invalid VF MAC addr %pM\n", macaddr);
 		ret = I40E_ERR_INVALID_MAC_ADDR;
-	} else if (vf->pf_set_mac && !is_multicast_ether_addr(macaddr)) {
+	} else if (vf->pf_set_mac && !is_multicast_ether_addr(macaddr) &&
+		   !ether_addr_equal(macaddr, vf->default_lan_addr.addr)) {
 		/* If the host VMM administrator has set the VF MAC address
 		 * administratively via the ndo_set_vf_mac command then deny
 		 * permission to the VF to add or delete unicast MAC addresses.
+		 * The VF may request to set the MAC address filter already
+		 * assigned to it so do not return an error in that case.
 		 */
 		dev_err(&pf->pdev->dev,
 			"VF attempting to override administratively set MAC address\nPlease reload the VF driver to resume normal operation\n");
-- 
1.8.3.1
