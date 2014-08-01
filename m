From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 06/14] i40e: disable local loopback on vmdq vsi
Date: Fri,  1 Aug 2014 13:27:07 -0700
Message-ID: <1406924835-31550-7-git-send-email-aaron.f.brown@intel.com>
References: <1406924835-31550-1-git-send-email-aaron.f.brown@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:60887 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754818AbaHAUXY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2014 16:23:24 -0400
In-Reply-To: <1406924835-31550-1-git-send-email-aaron.f.brown@intel.com>
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
index 6ac8487..51bc030 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7576,7 +7576,6 @@ static int i40e_add_vsi(struct i40e_vsi *vsi)
 		 * should be set to zero by default.
 		 */
 		ctxt.info.switch_id = 0;
-		ctxt.info.switch_id |= cpu_to_le16(I40E_AQ_VSI_SW_ID_FLAG_LOCAL_LB);
 		ctxt.info.switch_id |= cpu_to_le16(I40E_AQ_VSI_SW_ID_FLAG_ALLOW_LB);
 
 		/* Setup the VSI tx/rx queue map for TC0 only for now */
-- 
1.9.3
