From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/4] e1000e: alternate MAC address does not work on device id 0x1060
Date: Thu, 11 Aug 2011 15:31:45 -0700
Message-ID: <1313101908-11622-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313101908-11622-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, <stable@kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:53658 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753737Ab1HKWbv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 18:31:51 -0400
In-Reply-To: <1313101908-11622-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

This issue is present all the way back to 2.6.34 kernels.

CC: <stable@kernel.org>
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeffrey Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/lib.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 7898a67..58af091 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -190,7 +190,8 @@ s32 e1000_check_alt_mac_addr_generic(struct e1000_hw *hw)
 	/* Check for LOM (vs. NIC) or one of two valid mezzanine cards */
 	if (!((nvm_data & NVM_COMPAT_LOM) ||
 	      (hw->adapter->pdev->device == E1000_DEV_ID_82571EB_SERDES_DUAL) ||
-	      (hw->adapter->pdev->device == E1000_DEV_ID_82571EB_SERDES_QUAD)))
+	      (hw->adapter->pdev->device == E1000_DEV_ID_82571EB_SERDES_QUAD) ||
+	      (hw->adapter->pdev->device == E1000_DEV_ID_82571EB_SERDES)))
 		goto out;
 
 	ret_val = e1000_read_nvm(hw, NVM_ALT_MAC_ADDR_PTR, 1,
-- 
1.7.6

