From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] i40e: clear AQ head and tail registers
Date: Fri,  6 Dec 2013 00:06:16 -0800
Message-ID: <1386317188-13944-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42214 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751543Ab3LFIGe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 03:06:34 -0500
In-Reply-To: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

During admin queue shutdown clear some more registers
explicitly.

Change-Id: Ifb235c691e1c55e76bf66e0642207f464153d05a
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index cfef7fc..2bf73dd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -466,10 +466,15 @@ static i40e_status i40e_shutdown_asq(struct i40e_hw *hw)
 		return I40E_ERR_NOT_READY;
 
 	/* Stop firmware AdminQ processing */
-	if (hw->mac.type == I40E_MAC_VF)
+	if (hw->mac.type == I40E_MAC_VF) {
 		wr32(hw, I40E_VF_ATQLEN1, 0);
-	else
+		wr32(hw, I40E_VF_ATQH1, 0);
+		wr32(hw, I40E_VF_ATQT1, 0);
+	} else {
 		wr32(hw, I40E_PF_ATQLEN, 0);
+		wr32(hw, I40E_PF_ATQH, 0);
+		wr32(hw, I40E_PF_ATQT, 0);
+	}
 
 	/* make sure lock is available */
 	mutex_lock(&hw->aq.asq_mutex);
@@ -500,10 +505,15 @@ static i40e_status i40e_shutdown_arq(struct i40e_hw *hw)
 		return I40E_ERR_NOT_READY;
 
 	/* Stop firmware AdminQ processing */
-	if (hw->mac.type == I40E_MAC_VF)
+	if (hw->mac.type == I40E_MAC_VF) {
 		wr32(hw, I40E_VF_ARQLEN1, 0);
-	else
+		wr32(hw, I40E_VF_ARQH1, 0);
+		wr32(hw, I40E_VF_ARQT1, 0);
+	} else {
 		wr32(hw, I40E_PF_ARQLEN, 0);
+		wr32(hw, I40E_PF_ARQH, 0);
+		wr32(hw, I40E_PF_ARQT, 0);
+	}
 
 	/* make sure lock is available */
 	mutex_lock(&hw->aq.arq_mutex);
-- 
1.8.3.1
