From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 07/15] i40e: disable local loopback on vmdq vsi
Date: Wed, 30 Jul 2014 17:32:03 -0700
Message-ID: <1406766731-4209-8-git-send-email-aaron.f.brown@intel.com>
References: <1406766731-4209-1-git-send-email-aaron.f.brown@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:24422 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756037AbaGaA2S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2014 20:28:18 -0400
In-Reply-To: <1406766731-4209-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The local loopback should only be enabled for VSIs that are supporting
cascaded VEBs or VEPA setups.  This is not the case here, and we need
to stop the VEB from echoing the VMDQ VSI packets back at the VSI.

Change-ID: I9dfb6ac79db24d04360d7efde62d81e20abc5090
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 66a1070..715242a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7575,7 +7575,6 @@ static int i40e_add_vsi(struct i40e_vsi *vsi)
 		 * should be set to zero by default.
 		 */
 		ctxt.info.switch_id = 0;
-		ctxt.info.switch_id |= cpu_to_le16(I40E_AQ_VSI_SW_ID_FLAG_LOCAL_LB);
 		ctxt.info.switch_id |= cpu_to_le16(I40E_AQ_VSI_SW_ID_FLAG_ALLOW_LB);
 
 		/* Setup the VSI tx/rx queue map for TC0 only for now */
-- 
1.9.3
