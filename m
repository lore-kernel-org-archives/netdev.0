From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] i40e/i40evf: clear aq bah-bal on shutdown
Date: Tue,  1 Jul 2014 04:34:59 -0700
Message-ID: <1404214511-26868-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1404214511-26868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7330 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756629AbaGALfP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2014 07:35:15 -0400
In-Reply-To: <1404214511-26868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Clear the AQ BAH and BAL registers on a clean shutdown to help make sure
all is tidy when the driver is done.

Change-ID: I393e92680247daa52a8e00bab183213672d73578
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   | 4 ++++
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c | 4 ++++
 2 files changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 87f1d8b..a8244a5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -489,6 +489,8 @@ static i40e_status i40e_shutdown_asq(struct i40e_hw *hw)
 	wr32(hw, hw->aq.asq.head, 0);
 	wr32(hw, hw->aq.asq.tail, 0);
 	wr32(hw, hw->aq.asq.len, 0);
+	wr32(hw, hw->aq.asq.bal, 0);
+	wr32(hw, hw->aq.asq.bah, 0);
 
 	/* make sure lock is available */
 	mutex_lock(&hw->aq.asq_mutex);
@@ -520,6 +522,8 @@ static i40e_status i40e_shutdown_arq(struct i40e_hw *hw)
 	wr32(hw, hw->aq.arq.head, 0);
 	wr32(hw, hw->aq.arq.tail, 0);
 	wr32(hw, hw->aq.arq.len, 0);
+	wr32(hw, hw->aq.arq.bal, 0);
+	wr32(hw, hw->aq.arq.bah, 0);
 
 	/* make sure lock is available */
 	mutex_lock(&hw->aq.arq_mutex);
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index 79a30dd..c277763 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -487,6 +487,8 @@ static i40e_status i40e_shutdown_asq(struct i40e_hw *hw)
 	wr32(hw, hw->aq.asq.head, 0);
 	wr32(hw, hw->aq.asq.tail, 0);
 	wr32(hw, hw->aq.asq.len, 0);
+	wr32(hw, hw->aq.asq.bal, 0);
+	wr32(hw, hw->aq.asq.bah, 0);
 
 	/* make sure lock is available */
 	mutex_lock(&hw->aq.asq_mutex);
@@ -518,6 +520,8 @@ static i40e_status i40e_shutdown_arq(struct i40e_hw *hw)
 	wr32(hw, hw->aq.arq.head, 0);
 	wr32(hw, hw->aq.arq.tail, 0);
 	wr32(hw, hw->aq.arq.len, 0);
+	wr32(hw, hw->aq.arq.bal, 0);
+	wr32(hw, hw->aq.arq.bah, 0);
 
 	/* make sure lock is available */
 	mutex_lock(&hw->aq.arq_mutex);
-- 
1.9.3
