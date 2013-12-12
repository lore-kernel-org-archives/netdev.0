From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40e: debugfs command to change RSS queue count
Date: Thu, 12 Dec 2013 04:40:47 -0800
Message-ID: <1386852051-27907-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386852051-27907-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:4524 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751789Ab3LLMlF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Dec 2013 07:41:05 -0500
In-Reply-To: <1386852051-27907-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

This is the 3rd of 3 patches that implements changing the number
of queues on the fly.

This patch adds the debugfs hook for calling the change queues
flow with a request to change the number of RSS queues.

This is intended to also be called eventually from ethtool.

Change-Id: Ib6b332f0ec8e58989ef8c65ec30079d01fdf6c9a
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 9c675b5..3303b43 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1792,6 +1792,17 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		}
 		kfree(buff);
 		buff = NULL;
+	} else if (strncmp(cmd_buf, "set rss_size", 12) == 0) {
+		u16 queue_count;
+		cnt = sscanf(&cmd_buf[12], "%hi", &queue_count);
+		if (cnt != 1) {
+			dev_info(&pf->pdev->dev,
+				 "set rss_size: bad command string, cnt=%d\n", cnt);
+			goto command_write_done;
+		}
+		dev_info(&pf->pdev->dev, " set rss_size requesting %d queues\n", queue_count);
+		i40e_reconfig_rss_queues(pf, queue_count);
+		dev_info(&pf->pdev->dev, " new rss_size %d\n", pf->rss_size);
 	} else {
 		dev_info(&pf->pdev->dev, "unknown command '%s'\n", cmd_buf);
 		dev_info(&pf->pdev->dev, "available commands\n");
@@ -1827,6 +1838,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		dev_info(&pf->pdev->dev, "  lldp event on\n");
 		dev_info(&pf->pdev->dev, "  lldp event off\n");
 		dev_info(&pf->pdev->dev, "  nvm read [module] [word_offset] [word_count]\n");
+		dev_info(&pf->pdev->dev, "  set rss_size <count>\n");
 	}
 
 command_write_done:
-- 
1.8.3.1
