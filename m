From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40e: select reset counters correctly
Date: Fri,  6 Dec 2013 00:06:20 -0800
Message-ID: <1386317188-13944-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42215 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752916Ab3LFIGg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 03:06:36 -0500
In-Reply-To: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The indication for telling which reset happened is a value, not a
bit pattern, so select by ==, not &.

Change-Id: Ie04097388ff16b85015d6ab1236d7511ef653e8c
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 6e0f2cb..2dd4be5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2790,11 +2790,11 @@ static irqreturn_t i40e_intr(int irq, void *data)
 		val = rd32(hw, I40E_GLGEN_RSTAT);
 		val = (val & I40E_GLGEN_RSTAT_RESET_TYPE_MASK)
 		       >> I40E_GLGEN_RSTAT_RESET_TYPE_SHIFT;
-		if (val & I40E_RESET_CORER)
+		if (val == I40E_RESET_CORER)
 			pf->corer_count++;
-		else if (val & I40E_RESET_GLOBR)
+		else if (val == I40E_RESET_GLOBR)
 			pf->globr_count++;
-		else if (val & I40E_RESET_EMPR)
+		else if (val == I40E_RESET_EMPR)
 			pf->empr_count++;
 	}
 
-- 
1.8.3.1
