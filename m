From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40e: Do not expose fd-sb commands from debugfs
Date: Mon, 28 Apr 2014 06:52:35 -0700
Message-ID: <1398693158-2815-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:60866 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752663AbaD1Nws (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 09:52:48 -0400
In-Reply-To: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Ethtool -k/-K can handle this so we do not need it in debugfs.

Change-ID: I9df692f10a60b71805f8f48d3b87c7da3820b2aa
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 3c37386..1aaec40 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1744,10 +1744,6 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		i40e_dbg_cmd_fd_ctrl(pf, I40E_FLAG_FD_ATR_ENABLED, false);
 	} else if (strncmp(cmd_buf, "fd-atr on", 9) == 0) {
 		i40e_dbg_cmd_fd_ctrl(pf, I40E_FLAG_FD_ATR_ENABLED, true);
-	} else if (strncmp(cmd_buf, "fd-sb off", 9) == 0) {
-		i40e_dbg_cmd_fd_ctrl(pf, I40E_FLAG_FD_SB_ENABLED, false);
-	} else if (strncmp(cmd_buf, "fd-sb on", 8) == 0) {
-		i40e_dbg_cmd_fd_ctrl(pf, I40E_FLAG_FD_SB_ENABLED, true);
 	} else if (strncmp(cmd_buf, "lldp", 4) == 0) {
 		if (strncmp(&cmd_buf[5], "stop", 4) == 0) {
 			int ret;
@@ -1967,8 +1963,6 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		dev_info(&pf->pdev->dev, "  rem fd_filter <dest q_index> <flex_off> <pctype> <dest_vsi> <dest_ctl> <fd_status> <cnt_index> <fd_id> <packet_len> <packet>\n");
 		dev_info(&pf->pdev->dev, "  fd-atr off\n");
 		dev_info(&pf->pdev->dev, "  fd-atr on\n");
-		dev_info(&pf->pdev->dev, "  fd-sb off\n");
-		dev_info(&pf->pdev->dev, "  fd-sb on\n");
 		dev_info(&pf->pdev->dev, "  lldp start\n");
 		dev_info(&pf->pdev->dev, "  lldp stop\n");
 		dev_info(&pf->pdev->dev, "  lldp get local\n");
-- 
1.9.0
