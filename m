From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/17] i40e: remove FD atr control from debugfs
Date: Thu, 15 Oct 2015 02:39:57 -0700
Message-ID: <1444902004-14433-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12861 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752419AbbJOJmb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 05:42:31 -0400
In-Reply-To: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Since the flow-director-atr priv flag was added to our ethtool interface,
we don't need the on/off control in debugfs.

Change-ID: Ib3b599916434ab30ccd40074e71d7a81609b5bb5
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 24 ------------------------
 1 file changed, 24 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index c1dd248..d15bd62 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -953,24 +953,6 @@ static void i40e_dbg_dump_veb_all(struct i40e_pf *pf)
 	}
 }
 
-/**
- * i40e_dbg_cmd_fd_ctrl - Enable/disable FD sideband/ATR
- * @pf: the PF that would be altered
- * @flag: flag that needs enabling or disabling
- * @enable: Enable/disable FD SD/ATR
- **/
-static void i40e_dbg_cmd_fd_ctrl(struct i40e_pf *pf, u64 flag, bool enable)
-{
-	if (enable) {
-		pf->flags |= flag;
-	} else {
-		pf->flags &= ~flag;
-		pf->auto_disable_flags |= flag;
-	}
-	dev_info(&pf->pdev->dev, "requesting a PF reset\n");
-	i40e_do_reset_safe(pf, BIT(__I40E_PF_RESET_REQUESTED));
-}
-
 #define I40E_MAX_DEBUG_OUT_BUFFER (4096*4)
 /**
  * i40e_dbg_command_write - write into command datum
@@ -1759,10 +1741,6 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		raw_packet = NULL;
 		kfree(asc_packet);
 		asc_packet = NULL;
-	} else if (strncmp(cmd_buf, "fd-atr off", 10) == 0) {
-		i40e_dbg_cmd_fd_ctrl(pf, I40E_FLAG_FD_ATR_ENABLED, false);
-	} else if (strncmp(cmd_buf, "fd-atr on", 9) == 0) {
-		i40e_dbg_cmd_fd_ctrl(pf, I40E_FLAG_FD_ATR_ENABLED, true);
 	} else if (strncmp(cmd_buf, "fd current cnt", 14) == 0) {
 		dev_info(&pf->pdev->dev, "FD current total filter count for this interface: %d\n",
 			 i40e_get_current_fd_count(pf));
@@ -1989,8 +1967,6 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		dev_info(&pf->pdev->dev, "  send indirect aq_cmd <flags> <opcode> <datalen> <retval> <cookie_h> <cookie_l> <param0> <param1> <param2> <param3> <buffer_len>\n");
 		dev_info(&pf->pdev->dev, "  add fd_filter <dest q_index> <flex_off> <pctype> <dest_vsi> <dest_ctl> <fd_status> <cnt_index> <fd_id> <packet_len> <packet>\n");
 		dev_info(&pf->pdev->dev, "  rem fd_filter <dest q_index> <flex_off> <pctype> <dest_vsi> <dest_ctl> <fd_status> <cnt_index> <fd_id> <packet_len> <packet>\n");
-		dev_info(&pf->pdev->dev, "  fd-atr off\n");
-		dev_info(&pf->pdev->dev, "  fd-atr on\n");
 		dev_info(&pf->pdev->dev, "  fd current cnt");
 		dev_info(&pf->pdev->dev, "  lldp start\n");
 		dev_info(&pf->pdev->dev, "  lldp stop\n");
-- 
2.4.3
