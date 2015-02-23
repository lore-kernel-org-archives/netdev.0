From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/16] i40e: rename debugfs clear_stats option
Date: Sun, 22 Feb 2015 19:25:33 -0800
Message-ID: <1424661944-1779-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424661944-1779-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24899 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752178AbbBWDZz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Feb 2015 22:25:55 -0500
In-Reply-To: <1424661944-1779-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Change debugfs command from "clear_stats pf" to "clear_stats port"
to be clearer what the action is.  Also, limit the action to the
base PF, not the NPAR partitions.

Change-ID: I22aa39c0962d83a83a985097b1000ed7f8c66f3f
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 61236f9..43a6bf0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1485,11 +1485,15 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			} else {
 				dev_info(&pf->pdev->dev, "clear_stats vsi [seid]\n");
 			}
-		} else if (strncmp(&cmd_buf[12], "pf", 2) == 0) {
-			i40e_pf_reset_stats(pf);
-			dev_info(&pf->pdev->dev, "pf clear stats called\n");
+		} else if (strncmp(&cmd_buf[12], "port", 4) == 0) {
+			if (pf->hw.partition_id == 1) {
+				i40e_pf_reset_stats(pf);
+				dev_info(&pf->pdev->dev, "port stats cleared\n");
+			} else {
+				dev_info(&pf->pdev->dev, "clear port stats not allowed on this port partition\n");
+			}
 		} else {
-			dev_info(&pf->pdev->dev, "clear_stats vsi [seid] or clear_stats pf\n");
+			dev_info(&pf->pdev->dev, "clear_stats vsi [seid] or clear_stats port\n");
 		}
 	} else if (strncmp(cmd_buf, "send aq_cmd", 11) == 0) {
 		struct i40e_aq_desc *desc;
@@ -1895,7 +1899,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		dev_info(&pf->pdev->dev, "  read <reg>\n");
 		dev_info(&pf->pdev->dev, "  write <reg> <value>\n");
 		dev_info(&pf->pdev->dev, "  clear_stats vsi [seid]\n");
-		dev_info(&pf->pdev->dev, "  clear_stats pf\n");
+		dev_info(&pf->pdev->dev, "  clear_stats port\n");
 		dev_info(&pf->pdev->dev, "  pfr\n");
 		dev_info(&pf->pdev->dev, "  corer\n");
 		dev_info(&pf->pdev->dev, "  globr\n");
-- 
1.9.3
