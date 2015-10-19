From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 12/17] i40e/i40evf: Fix an accidental error with BIT_ULL replacement
Date: Mon, 19 Oct 2015 15:49:26 -0700
Message-ID: <1445294971-44714-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445294971-44714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49701 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751274AbbJSWth (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 18:49:37 -0400
In-Reply-To: <1445294971-44714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

A mask value of 0x1FF was accidentally replaced with a bit mask
causing flow director sideband to be broken.

Change-ID: Id3387f67dd1b567b41692b570b383c58671e1eae
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_type.h   | 4 ++--
 drivers/net/ethernet/intel/i40evf/i40e_type.h | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index f631ca0..dd2da35 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -1068,8 +1068,8 @@ enum i40e_filter_program_desc_fd_status {
 };
 
 #define I40E_TXD_FLTR_QW0_DEST_VSI_SHIFT	23
-#define I40E_TXD_FLTR_QW0_DEST_VSI_MASK \
-				       BIT_ULL(I40E_TXD_FLTR_QW0_DEST_VSI_SHIFT)
+#define I40E_TXD_FLTR_QW0_DEST_VSI_MASK	(0x1FFUL << \
+					 I40E_TXD_FLTR_QW0_DEST_VSI_SHIFT)
 
 #define I40E_TXD_FLTR_QW1_CMD_SHIFT	4
 #define I40E_TXD_FLTR_QW1_CMD_MASK	(0xFFFFULL << \
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 85af3b4..301fe2b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -1055,8 +1055,8 @@ enum i40e_filter_program_desc_fd_status {
 };
 
 #define I40E_TXD_FLTR_QW0_DEST_VSI_SHIFT	23
-#define I40E_TXD_FLTR_QW0_DEST_VSI_MASK \
-				       BIT_ULL(I40E_TXD_FLTR_QW0_DEST_VSI_SHIFT)
+#define I40E_TXD_FLTR_QW0_DEST_VSI_MASK	(0x1FFUL << \
+					 I40E_TXD_FLTR_QW0_DEST_VSI_SHIFT)
 
 #define I40E_TXD_FLTR_QW1_CMD_SHIFT	4
 #define I40E_TXD_FLTR_QW1_CMD_MASK	(0xFFFFULL << \
-- 
2.4.3
