From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/17] i40e: fix kbuild warnings
Date: Wed, 30 Sep 2015 05:52:40 -0700
Message-ID: <1443617561-40490-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, kbuild-all@01.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34535 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932352AbbI3Mws (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 08:52:48 -0400
In-Reply-To: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The 0day build infrastructure found some issues in i40e, this
removes the warnings by adding a harmless cast to a dev_info.

CC: kbuild-all@01.org
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index ee96106..9f9d842 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1497,7 +1497,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		/* check the range on address */
 		if (address > (pf->ioremap_len - sizeof(u32))) {
 			dev_info(&pf->pdev->dev, "read reg address 0x%08x too large, max=0x%08lx\n",
-				 address, (pf->ioremap_len - sizeof(u32)));
+				 address, (unsigned long int)(pf->ioremap_len - sizeof(u32)));
 			goto command_write_done;
 		}
 
@@ -1516,7 +1516,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		/* check the range on address */
 		if (address > (pf->ioremap_len - sizeof(u32))) {
 			dev_info(&pf->pdev->dev, "write reg address 0x%08x too large, max=0x%08lx\n",
-				 address, (pf->ioremap_len - sizeof(u32)));
+				 address, (unsigned long int)(pf->ioremap_len - sizeof(u32)));
 			goto command_write_done;
 		}
 		wr32(&pf->hw, address, value);
-- 
2.4.3
