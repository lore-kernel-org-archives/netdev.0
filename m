From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] i40e: Enable Loopback for the FCOE vsi as well
Date: Mon,  9 Feb 2015 02:44:00 -0800
Message-ID: <1423478641-3138-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38701 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760654AbbBIKoH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2015 05:44:07 -0500
In-Reply-To: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

For all VSIs on a VEB, Loopback mode should be either on or off.
Our configuration requires them to be ON so that VSIs can directly
talk to each other without going out on the wire.

Change-ID: I77b8310bc846329972b13b185949ab1431a46c30
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
index 401f7ed..27c206e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
@@ -395,6 +395,7 @@ int i40e_fcoe_vsi_init(struct i40e_vsi *vsi, struct i40e_vsi_context *ctxt)
 					    I40E_AQ_VSI_PROP_INGRESS_UP_VALID |
 					    I40E_AQ_VSI_PROP_EGRESS_UP_VALID));
 
+	info->switch_id = cpu_to_le16(I40E_AQ_VSI_SW_ID_FLAG_ALLOW_LB);
 	enabled_tc = i40e_get_fcoe_tc_map(pf);
 	i40e_vsi_setup_queue_map(vsi, ctxt, enabled_tc, true);
 
-- 
1.9.3
