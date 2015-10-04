From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] i40e/i40evf: set AQ count after memory allocation
Date: Sat,  3 Oct 2015 17:13:05 -0700
Message-ID: <1443917585-37687-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:1250 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750977AbbJDANI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Oct 2015 20:13:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The standard way to check if the AQ is enabled is to look at the
count field. So we should only set this field after we have
successfully allocated memory. To do otherwise is to incite
panic among the populace.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   | 4 ++--
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 62488a6..c0e943a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -386,7 +386,6 @@ static i40e_status i40e_init_asq(struct i40e_hw *hw)
 
 	hw->aq.asq.next_to_use = 0;
 	hw->aq.asq.next_to_clean = 0;
-	hw->aq.asq.count = hw->aq.num_asq_entries;
 
 	/* allocate the ring memory */
 	ret_code = i40e_alloc_adminq_asq_ring(hw);
@@ -404,6 +403,7 @@ static i40e_status i40e_init_asq(struct i40e_hw *hw)
 		goto init_adminq_free_rings;
 
 	/* success! */
+	hw->aq.asq.count = hw->aq.num_asq_entries;
 	goto init_adminq_exit;
 
 init_adminq_free_rings:
@@ -445,7 +445,6 @@ static i40e_status i40e_init_arq(struct i40e_hw *hw)
 
 	hw->aq.arq.next_to_use = 0;
 	hw->aq.arq.next_to_clean = 0;
-	hw->aq.arq.count = hw->aq.num_arq_entries;
 
 	/* allocate the ring memory */
 	ret_code = i40e_alloc_adminq_arq_ring(hw);
@@ -463,6 +462,7 @@ static i40e_status i40e_init_arq(struct i40e_hw *hw)
 		goto init_adminq_free_rings;
 
 	/* success! */
+	hw->aq.arq.count = hw->aq.num_arq_entries;
 	goto init_adminq_exit;
 
 init_adminq_free_rings:
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index 929d471..a23ebfd 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -373,7 +373,6 @@ static i40e_status i40e_init_asq(struct i40e_hw *hw)
 
 	hw->aq.asq.next_to_use = 0;
 	hw->aq.asq.next_to_clean = 0;
-	hw->aq.asq.count = hw->aq.num_asq_entries;
 
 	/* allocate the ring memory */
 	ret_code = i40e_alloc_adminq_asq_ring(hw);
@@ -391,6 +390,7 @@ static i40e_status i40e_init_asq(struct i40e_hw *hw)
 		goto init_adminq_free_rings;
 
 	/* success! */
+	hw->aq.asq.count = hw->aq.num_asq_entries;
 	goto init_adminq_exit;
 
 init_adminq_free_rings:
@@ -432,7 +432,6 @@ static i40e_status i40e_init_arq(struct i40e_hw *hw)
 
 	hw->aq.arq.next_to_use = 0;
 	hw->aq.arq.next_to_clean = 0;
-	hw->aq.arq.count = hw->aq.num_arq_entries;
 
 	/* allocate the ring memory */
 	ret_code = i40e_alloc_adminq_arq_ring(hw);
@@ -450,6 +449,7 @@ static i40e_status i40e_init_arq(struct i40e_hw *hw)
 		goto init_adminq_free_rings;
 
 	/* success! */
+	hw->aq.arq.count = hw->aq.num_arq_entries;
 	goto init_adminq_exit;
 
 init_adminq_free_rings:
-- 
2.4.3
