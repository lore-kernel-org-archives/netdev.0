From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH 1/1] ixgbe: add missing braces
Date: Fri, 10 Aug 2012 10:35:14 -0700
Message-ID: <1344620114-6173-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2164 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753615Ab2HJRff (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2012 13:35:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch adds missing braces around the 10gig link check to include the check for  KR support.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Reported-by: Sascha Wildner <saw@online.de>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 50fc137..18bf08c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -804,12 +804,13 @@ static s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw,
 	    link_mode == IXGBE_AUTOC_LMS_KX4_KX_KR_SGMII) {
 		/* Set KX4/KX/KR support according to speed requested */
 		autoc &= ~(IXGBE_AUTOC_KX4_KX_SUPP_MASK | IXGBE_AUTOC_KR_SUPP);
-		if (speed & IXGBE_LINK_SPEED_10GB_FULL)
+		if (speed & IXGBE_LINK_SPEED_10GB_FULL) {
 			if (orig_autoc & IXGBE_AUTOC_KX4_SUPP)
 				autoc |= IXGBE_AUTOC_KX4_SUPP;
 			if ((orig_autoc & IXGBE_AUTOC_KR_SUPP) &&
 			    (hw->phy.smart_speed_active == false))
 				autoc |= IXGBE_AUTOC_KR_SUPP;
+		}
 		if (speed & IXGBE_LINK_SPEED_1GB_FULL)
 			autoc |= IXGBE_AUTOC_KX_SUPP;
 	} else if ((pma_pmd_1g == IXGBE_AUTOC_1G_SFI) &&
-- 
1.7.11.2
