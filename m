From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] i40: disable FCoE for MFP modes
Date: Thu, 29 May 2014 08:10:14 -0700
Message-ID: <1401376216-12531-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vasu Dev <vasu.dev@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55978 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933154AbaE2PKj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 11:10:39 -0400
In-Reply-To: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasu Dev <vasu.dev@intel.com>

Currently FCoE is not supported with MFP modes, so this patch
makes sure it is disabled.

It is disabled by overriding HW FCoE capability, so that later
it can be re-enabled by just the SW upgrade.

Change-ID: I1c0bae5c099b209f56b88bda360031a8565e43e8
Signed-off-by: Vasu Dev <vasu.dev@intel.com>
Tested-By: Jack Morgan <jack.morgan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 064b0aa..2329e2f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1949,6 +1949,12 @@ static void i40e_parse_discover_capabilities(struct i40e_hw *hw, void *buff,
 		}
 	}
 
+	/* Software override ensuring FCoE is disabled if npar or mfp
+	 * mode because it is not supported in these modes.
+	 */
+	if (p->npar_enable || p->mfp_mode_1)
+		p->fcoe = false;
+
 	/* additional HW specific goodies that might
 	 * someday be HW version specific
 	 */
-- 
1.9.3
