From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/17] i40e: Define and use i40e_is_vf macro
Date: Fri, 21 Nov 2014 21:54:58 -0800
Message-ID: <1416635708-4765-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:46133 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750837AbaKVFzP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2014 00:55:15 -0500
In-Reply-To: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

This patch is useful for future expansion when new VF MAC types get
added. It helps with cleaning up VF driver flow.

Change-ID: Ibe1eeb71262a3a40f24a1c5409436bdc3411da7f
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h     | 2 ++
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c | 2 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h   | 2 ++
 4 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 5dc12c4..35fa09a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -51,7 +51,7 @@ static inline bool i40e_is_nvm_update_op(struct i40e_aq_desc *desc)
 static void i40e_adminq_init_regs(struct i40e_hw *hw)
 {
 	/* set head and tail registers in our local struct */
-	if (hw->mac.type == I40E_MAC_VF) {
+	if (i40e_is_vf(hw)) {
 		hw->aq.asq.tail = I40E_VF_ATQT1;
 		hw->aq.asq.head = I40E_VF_ATQH1;
 		hw->aq.asq.len  = I40E_VF_ATQLEN1;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index c852143..3904dd8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -482,6 +482,8 @@ struct i40e_hw {
 	u32 debug_mask;
 };
 
+#define i40e_is_vf(_hw)	((_hw)->mac.type == I40E_MAC_VF)
+
 struct i40e_driver_version {
 	u8 major_version;
 	u8 minor_version;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index ff6305a..1698994 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -49,7 +49,7 @@ static inline bool i40e_is_nvm_update_op(struct i40e_aq_desc *desc)
 static void i40e_adminq_init_regs(struct i40e_hw *hw)
 {
 	/* set head and tail registers in our local struct */
-	if (hw->mac.type == I40E_MAC_VF) {
+	if (i40e_is_vf(hw)) {
 		hw->aq.asq.tail = I40E_VF_ATQT1;
 		hw->aq.asq.head = I40E_VF_ATQH1;
 		hw->aq.asq.len  = I40E_VF_ATQLEN1;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 8fe34fc..77abe17 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -476,6 +476,8 @@ struct i40e_hw {
 	u32 debug_mask;
 };
 
+#define i40e_is_vf(_hw)	((_hw)->mac.type == I40E_MAC_VF)
+
 struct i40e_driver_version {
 	u8 major_version;
 	u8 minor_version;
-- 
1.9.3
