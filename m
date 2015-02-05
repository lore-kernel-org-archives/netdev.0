From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/16] fm10k: Validate VLAN ID in fm10k_update_xc_addr_pf
Date: Thu,  5 Feb 2015 01:35:35 -0800
Message-ID: <1423128950-12388-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423128950-12388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55144 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752911AbbBEJgD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 04:36:03 -0500
In-Reply-To: <1423128950-12388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

Currently, fm10k_update_xc_addr_pf has an issue where it does not
properly drop the upper-most four bits of the VLAN ID due to type
promotion. Resolve the issue not by masking off the bits, but by
throwing an error if the VLAN ID is out-of-bounds.

Reported-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 275423d..7e47119 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -330,13 +330,10 @@ static s32 fm10k_update_xc_addr_pf(struct fm10k_hw *hw, u16 glort,
 	struct fm10k_mac_update mac_update;
 	u32 msg[5];
 
-	/* if glort is not valid return error */
-	if (!fm10k_glort_valid_pf(hw, glort))
+	/* if glort or vlan are not valid return error */
+	if (!fm10k_glort_valid_pf(hw, glort) || vid >= FM10K_VLAN_TABLE_VID_MAX)
 		return FM10K_ERR_PARAM;
 
-	/* drop upper 4 bits of VLAN ID */
-	vid = (vid << 4) >> 4;
-
 	/* record fields */
 	mac_update.mac_lower = cpu_to_le32(((u32)mac[2] << 24) |
 						 ((u32)mac[3] << 16) |
-- 
1.9.3
