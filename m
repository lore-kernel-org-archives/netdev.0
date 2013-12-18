From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] i40e: Fix off by one in i40e_dbg_command_write
Date: Tue, 17 Dec 2013 22:44:36 -0800
Message-ID: <1387349082-18506-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387349082-18506-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alan Cox <alan@linux.intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24896 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752804Ab3LRGo7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 01:44:59 -0500
In-Reply-To: <1387349082-18506-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>

We assume that the resulting buffer is zero terminated when we then
re-use it. The sscanf is limited to 512 bytes but needs to be 511
to allow for a terminator.

One of a set of problems noted by Jackie Chang

Signed-off-by: Alan Cox <alan@linux.intel.com>
Acked-by: Shannon Nelson <Shannon.nelson@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index aaa2b5c..e201060 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1547,7 +1547,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		if (strncmp(cmd_buf, "add", 3) == 0)
 			add = true;
 		cnt = sscanf(&cmd_buf[13],
-			     "%hx %2hhx %2hhx %hx %2hhx %2hhx %hx %x %hd %512s",
+			     "%hx %2hhx %2hhx %hx %2hhx %2hhx %hx %x %hd %511s",
 			     &fd_data.q_index,
 			     &fd_data.flex_off, &fd_data.pctype,
 			     &fd_data.dest_vsi, &fd_data.dest_ctl,
-- 
1.8.3.1
