From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e/i40evf: Update check for AQ aliveness
Date: Thu, 29 May 2014 08:10:02 -0700
Message-ID: <1401376216-12531-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kevin Scott <kevin.c.scott@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:51814 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756143AbaE2PKg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 11:10:36 -0400
In-Reply-To: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Scott <kevin.c.scott@intel.com>

Update the i40e_check_asq_alive check to ensure that the len register
offset is non-zero, indicating that SW has initialized the AQ.

Change-ID: I9c2e804788b4775bef9c7e80954ab004e6bdb306
Signed-off-by: Kevin Scott <kevin.c.scott@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c   | 6 +++++-
 drivers/net/ethernet/intel/i40evf/i40e_common.c | 6 +++++-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 22eefda..4bea409 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -133,7 +133,11 @@ void i40e_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
  **/
 bool i40e_check_asq_alive(struct i40e_hw *hw)
 {
-	return !!(rd32(hw, hw->aq.asq.len) & I40E_PF_ATQLEN_ATQENABLE_MASK);
+	if (hw->aq.asq.len)
+		return !!(rd32(hw, hw->aq.asq.len) &
+			  I40E_PF_ATQLEN_ATQENABLE_MASK);
+	else
+		return false;
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index ac66096..ea0f200 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -133,7 +133,11 @@ void i40evf_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
  **/
 bool i40evf_check_asq_alive(struct i40e_hw *hw)
 {
-	return !!(rd32(hw, hw->aq.asq.len) & I40E_PF_ATQLEN_ATQENABLE_MASK);
+	if (hw->aq.asq.len)
+		return !!(rd32(hw, hw->aq.asq.len) &
+			  I40E_PF_ATQLEN_ATQENABLE_MASK);
+	else
+		return false;
 }
 
 /**
-- 
1.9.3
