From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 6/6] i40e: clean up coccicheck reported errors
Date: Tue, 24 Sep 2013 02:45:10 -0700
Message-ID: <1380015910-25927-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1380015910-25927-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32601 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754109Ab3IXJpR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 05:45:17 -0400
In-Reply-To: <1380015910-25927-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

coccicheck shows:

drivers/net/ethernet/intel/i40e/i40e_adminq.c:704:2-8: Replace memcpy
with struct assignment
drivers/net/ethernet/intel/i40e/i40e_adminq.c:763:1-7: Replace memcpy
with struct assignment
drivers/net/ethernet/intel/i40e/i40e_adminq.c:810:2-8: Replace memcpy
with struct assignment
drivers/net/ethernet/intel/i40e/i40e_common.c:510:2-8: Replace memcpy
with struct assignment

Fix each of them with a *a = *b;

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c | 7 +++----
 drivers/net/ethernet/intel/i40e/i40e_common.c | 2 +-
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 0c524fa..cfef7fc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -701,8 +701,7 @@ i40e_status i40e_asq_send_command(struct i40e_hw *hw,
 
 	details = I40E_ADMINQ_DETAILS(hw->aq.asq, hw->aq.asq.next_to_use);
 	if (cmd_details) {
-		memcpy(details, cmd_details,
-		       sizeof(struct i40e_asq_cmd_details));
+		*details = *cmd_details;
 
 		/* If the cmd_details are defined copy the cookie.  The
 		 * cpu_to_le32 is not needed here because the data is ignored
@@ -760,7 +759,7 @@ i40e_status i40e_asq_send_command(struct i40e_hw *hw,
 	desc_on_ring = I40E_ADMINQ_DESC(hw->aq.asq, hw->aq.asq.next_to_use);
 
 	/* if the desc is available copy the temp desc to the right place */
-	memcpy(desc_on_ring, desc, sizeof(struct i40e_aq_desc));
+	*desc_on_ring = *desc;
 
 	/* if buff is not NULL assume indirect command */
 	if (buff != NULL) {
@@ -807,7 +806,7 @@ i40e_status i40e_asq_send_command(struct i40e_hw *hw,
 
 	/* if ready, copy the desc back to temp */
 	if (i40e_asq_done(hw)) {
-		memcpy(desc, desc_on_ring, sizeof(struct i40e_aq_desc));
+		*desc = *desc_on_ring;
 		if (buff != NULL)
 			memcpy(buff, dma_buff->va, buff_size);
 		retval = le16_to_cpu(desc->retval);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index c21df7b..1e4ea13 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -507,7 +507,7 @@ i40e_status i40e_aq_get_link_info(struct i40e_hw *hw,
 
 	/* save link status information */
 	if (link)
-		memcpy(link, hw_link_info, sizeof(struct i40e_link_status));
+		*link = *hw_link_info;
 
 	/* flag cleared so helper functions don't call AQ again */
 	hw->phy.get_link_info = false;
-- 
1.8.3.1
