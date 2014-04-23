From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/14] i40e: report VF link state correctly
Date: Wed, 23 Apr 2014 04:15:26 -0700
Message-ID: <1398251726-13638-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398251726-13638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:6546 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753253AbaDWLPi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 07:15:38 -0400
In-Reply-To: <1398251726-13638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Although the driver would correctly allow the VF link state to be
controlled by 'ip set link', it would not report it correctly back.

Fix this by filling out the appropriate field in the vf info struct.

Change-ID: I58d8e356438190e1ee9660b424301af6f416cdbe
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 5421714..b27b2f5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2291,6 +2291,13 @@ int i40e_ndo_get_vf_config(struct net_device *netdev,
 	ivi->vlan = le16_to_cpu(vsi->info.pvid) & I40E_VLAN_MASK;
 	ivi->qos = (le16_to_cpu(vsi->info.pvid) & I40E_PRIORITY_MASK) >>
 		   I40E_VLAN_PRIORITY_SHIFT;
+	if (vf->link_forced == false)
+		ivi->linkstate = IFLA_VF_LINK_STATE_AUTO;
+	else if (vf->link_up == true)
+		ivi->linkstate = IFLA_VF_LINK_STATE_ENABLE;
+	else
+		ivi->linkstate = IFLA_VF_LINK_STATE_DISABLE;
+
 	ret = 0;
 
 error_param:
-- 
1.9.0
