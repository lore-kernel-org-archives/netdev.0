From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] i40evf: don't violate scope
Date: Wed,  2 Jul 2014 19:40:21 -0700
Message-ID: <1404355233-30123-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1404355233-30123-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:40759 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753732AbaGCClF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2014 22:41:05 -0400
In-Reply-To: <1404355233-30123-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Move a declaration up one level so we don't dereference it out of scope.
This didn't cause any panics, but the details->async field would
mysteriously disappear, causing unnecessary delays when sending AQ
commands. Also, the code is just plain wrong.

Change-ID: I753f64f13c55e5d75ea4351e29b14fb53b2f0104
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40e_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index a43155a..4ea90bf 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -551,6 +551,7 @@ i40e_status i40e_aq_send_msg_to_pf(struct i40e_hw *hw,
 				struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
+	struct i40e_asq_cmd_details details;
 	i40e_status status;
 
 	i40evf_fill_default_direct_cmd_desc(&desc, i40e_aqc_opc_send_msg_to_pf);
@@ -565,7 +566,6 @@ i40e_status i40e_aq_send_msg_to_pf(struct i40e_hw *hw,
 		desc.datalen = cpu_to_le16(msglen);
 	}
 	if (!cmd_details) {
-		struct i40e_asq_cmd_details details;
 		memset(&details, 0, sizeof(details));
 		details.async = true;
 		cmd_details = &details;
-- 
1.9.3
