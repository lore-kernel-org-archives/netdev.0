From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 01/17] i40e: use assignment instead of memcpy
Date: Fri, 10 Jan 2014 12:30:23 -0800
Message-ID: <1389385839-11996-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389385839-11996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:26548 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758195AbaAJUal (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 15:30:41 -0500
In-Reply-To: <1389385839-11996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

These instances were found by coccinelle/spatch, and can
use struct assignment instead of memcpy.

Change-ID: Idc23c3599241bf8a658bda18c80417af3fbfee66
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c | 3 +--
 drivers/net/ethernet/intel/i40e/i40e_hmc.c    | 8 +++-----
 3 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index c75aa2d..4e5a02c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -922,7 +922,7 @@ i40e_status i40e_clean_arq_element(struct i40e_hw *hw,
 			   "AQRX: Event received with error 0x%X.\n",
 			   hw->aq.arq_last_status);
 	} else {
-		memcpy(&e->desc, desc, sizeof(struct i40e_aq_desc));
+		e->desc = *desc;
 		datalen = le16_to_cpu(desc->datalen);
 		e->msg_size = min(datalen, e->msg_size);
 		if (e->msg_buf != NULL && (e->msg_size != 0))
diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 807312b..6bfbeec 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -599,8 +599,7 @@ i40e_status i40e_aq_get_link_info(struct i40e_hw *hw,
 		goto aq_get_link_info_exit;
 
 	/* save off old link status information */
-	memcpy(&hw->phy.link_info_old, hw_link_info,
-	       sizeof(struct i40e_link_status));
+	hw->phy.link_info_old = *hw_link_info;
 
 	/* update link status */
 	hw_link_info->phy_type = (enum i40e_aq_phy_type)resp->phy_type;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_hmc.c b/drivers/net/ethernet/intel/i40e/i40e_hmc.c
index 76dfef3..bf2d4cc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_hmc.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_hmc.c
@@ -89,11 +89,9 @@ i40e_status i40e_add_sd_table_entry(struct i40e_hw *hw,
 			sd_entry->u.pd_table.pd_entry =
 				(struct i40e_hmc_pd_entry *)
 				sd_entry->u.pd_table.pd_entry_virt_mem.va;
-			memcpy(&sd_entry->u.pd_table.pd_page_addr, &mem,
-			       sizeof(struct i40e_dma_mem));
+			sd_entry->u.pd_table.pd_page_addr = mem;
 		} else {
-			memcpy(&sd_entry->u.bp.addr, &mem,
-			       sizeof(struct i40e_dma_mem));
+			sd_entry->u.bp.addr = mem;
 			sd_entry->u.bp.sd_pd_index = sd_index;
 		}
 		/* initialize the sd entry */
@@ -164,7 +162,7 @@ i40e_status i40e_add_pd_table_entry(struct i40e_hw *hw,
 		if (ret_code)
 			goto exit;
 
-		memcpy(&pd_entry->bp.addr, &mem, sizeof(struct i40e_dma_mem));
+		pd_entry->bp.addr = mem;
 		pd_entry->bp.sd_pd_index = pd_index;
 		pd_entry->bp.entry_type = I40E_SD_TYPE_PAGED;
 		/* Set page address and valid bit */
-- 
1.8.3.1
