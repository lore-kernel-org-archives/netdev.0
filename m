From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 10/14] i40e: Remove zero check
Date: Wed, 27 Apr 2016 13:15:49 -0700
Message-ID: <1461788153-12869-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461788153-12869-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:63244 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753126AbcD0UQb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2016 16:16:31 -0400
In-Reply-To: <1461788153-12869-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

A mirror rule ID may be zero so do not return invalid parameter when the
user passes in a zero value for a rule ID.

Change-ID: I261b8c24725ce2c6ed32f859da81093dfcbe2970
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 1db4790..25872f2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -2668,10 +2668,7 @@ i40e_status i40e_aq_delete_mirrorrule(struct i40e_hw *hw, u16 sw_seid,
 			u16 *rules_used, u16 *rules_free)
 {
 	/* Rule ID has to be valid except rule_type: INGRESS VLAN mirroring */
-	if (rule_type != I40E_AQC_MIRROR_RULE_TYPE_VLAN) {
-		if (!rule_id)
-			return I40E_ERR_PARAM;
-	} else {
+	if (rule_type == I40E_AQC_MIRROR_RULE_TYPE_VLAN) {
 		/* count and mr_list shall be valid for rule_type INGRESS VLAN
 		 * mirroring. For other rule_type, count and rule_type should
 		 * not matter.
-- 
2.5.5
