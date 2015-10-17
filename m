From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/17] i40e/i40evf: Fix an accidental error with BIT_ULL replacement
Date: Fri, 16 Oct 2015 22:28:26 -0700
Message-ID: <1445059711-45992-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445059711-45992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:25665 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752164AbbJQF2n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 01:28:43 -0400
In-Reply-To: <1445059711-45992-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
