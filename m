From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/9] i40e: future proof some sizeof calls
Date: Mon,  9 Mar 2015 10:55:35 -0700
Message-ID: <1425923742-4488-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425923742-4488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:5904 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753398AbbCIRzp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 13:55:45 -0400
In-Reply-To: <1425923742-4488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Make sure the sizeof() calls are taking the size of the actual struct
that we care about.  By using the pointer variable, we'll always get
the right struct size, even if the variable type changes sometime in
the future.

Change-ID: Id5858f883cf42447365ea3733080d7714f975bce
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index fb78bdd..2ca3d09 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -2017,7 +2017,7 @@ i40e_status i40e_aq_add_macvlan(struct i40e_hw *hw, u16 seid,
 	if (count == 0 || !mv_list || !hw)
 		return I40E_ERR_PARAM;
 
-	buf_size = count * sizeof(struct i40e_aqc_add_macvlan_element_data);
+	buf_size = count * sizeof(*mv_list);
 
 	/* prep the rest of the request */
 	i40e_fill_default_direct_cmd_desc(&desc, i40e_aqc_opc_add_macvlan);
@@ -2059,7 +2059,7 @@ i40e_status i40e_aq_remove_macvlan(struct i40e_hw *hw, u16 seid,
 	if (count == 0 || !mv_list || !hw)
 		return I40E_ERR_PARAM;
 
-	buf_size = count * sizeof(struct i40e_aqc_remove_macvlan_element_data);
+	buf_size = count * sizeof(*mv_list);
 
 	/* prep the rest of the request */
 	i40e_fill_default_direct_cmd_desc(&desc, i40e_aqc_opc_remove_macvlan);
-- 
1.9.3
