From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] i40e: fix up scanf decoders
Date: Tue, 17 Dec 2013 22:44:32 -0800
Message-ID: <1387349082-18506-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387349082-18506-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24896 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752747Ab3LRGox (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 01:44:53 -0500
In-Reply-To: <1387349082-18506-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Fix up a couple of scanfs to accept various base numbers instead of silently
requiring hex.

Change-Id: I1cc4dffbb1d011bf603cbf34a8db093da57fad7a
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 0768beb..abac831 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1466,7 +1466,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 	} else if (strncmp(cmd_buf, "read", 4) == 0) {
 		u32 address;
 		u32 value;
-		cnt = sscanf(&cmd_buf[4], "%x", &address);
+		cnt = sscanf(&cmd_buf[4], "%i", &address);
 		if (cnt != 1) {
 			dev_info(&pf->pdev->dev, "read <reg>\n");
 			goto command_write_done;
@@ -1485,7 +1485,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 
 	} else if (strncmp(cmd_buf, "write", 5) == 0) {
 		u32 address, value;
-		cnt = sscanf(&cmd_buf[5], "%x %x", &address, &value);
+		cnt = sscanf(&cmd_buf[5], "%i %i", &address, &value);
 		if (cnt != 2) {
 			dev_info(&pf->pdev->dev, "write <reg> <value>\n");
 			goto command_write_done;
@@ -1503,7 +1503,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			 address, value);
 	} else if (strncmp(cmd_buf, "clear_stats", 11) == 0) {
 		if (strncmp(&cmd_buf[12], "vsi", 3) == 0) {
-			cnt = sscanf(&cmd_buf[15], "%d", &vsi_seid);
+			cnt = sscanf(&cmd_buf[15], "%i", &vsi_seid);
 			if (cnt == 0) {
 				int i;
 				for (i = 0; i < pf->hw.func_caps.num_vsis; i++)
-- 
1.8.3.1
