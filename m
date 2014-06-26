From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/14] i40e: Add debugfs hooks to print current total FD filter count
Date: Thu, 26 Jun 2014 05:13:52 -0700
Message-ID: <1403784834-23301-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:10421 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757715AbaFZMOc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 08:14:32 -0400
In-Reply-To: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

"fd current cnt" can be used to print the total filters consumed
by this interface, this includes guaranteed and best effort filters.

Change-ID: I2c417810c4999ce1388d2ea26f8e69679ba33966
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 910b01b..ec07332 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1743,6 +1743,9 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		i40e_dbg_cmd_fd_ctrl(pf, I40E_FLAG_FD_ATR_ENABLED, false);
 	} else if (strncmp(cmd_buf, "fd-atr on", 9) == 0) {
 		i40e_dbg_cmd_fd_ctrl(pf, I40E_FLAG_FD_ATR_ENABLED, true);
+	} else if (strncmp(cmd_buf, "fd current cnt", 14) == 0) {
+		dev_info(&pf->pdev->dev, "FD current total filter count for this interface: %d\n",
+			 i40e_get_current_fd_count(pf));
 	} else if (strncmp(cmd_buf, "lldp", 4) == 0) {
 		if (strncmp(&cmd_buf[5], "stop", 4) == 0) {
 			int ret;
@@ -1962,6 +1965,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		dev_info(&pf->pdev->dev, "  rem fd_filter <dest q_index> <flex_off> <pctype> <dest_vsi> <dest_ctl> <fd_status> <cnt_index> <fd_id> <packet_len> <packet>\n");
 		dev_info(&pf->pdev->dev, "  fd-atr off\n");
 		dev_info(&pf->pdev->dev, "  fd-atr on\n");
+		dev_info(&pf->pdev->dev, "  fd current cnt");
 		dev_info(&pf->pdev->dev, "  lldp start\n");
 		dev_info(&pf->pdev->dev, "  lldp stop\n");
 		dev_info(&pf->pdev->dev, "  lldp get local\n");
-- 
1.9.3
