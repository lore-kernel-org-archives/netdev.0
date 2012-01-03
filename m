From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/11] e1000e: re-enable alternate MAC address for all devices which support it
Date: Tue,  3 Jan 2012 11:19:14 -0800
Message-ID: <1325618356-2655-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1325618356-2655-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57343 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754802Ab2ACTTs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jan 2012 14:19:48 -0500
In-Reply-To: <1325618356-2655-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/lib.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/lib.c b/drivers/net/ethernet/intel/e1000e/lib.c
index 0893ab1..78e3f4c 100644
--- a/drivers/net/ethernet/intel/e1000e/lib.c
+++ b/drivers/net/ethernet/intel/e1000e/lib.c
@@ -187,11 +187,8 @@ s32 e1000_check_alt_mac_addr_generic(struct e1000_hw *hw)
 	if (ret_val)
 		goto out;
 
-	/* Check for LOM (vs. NIC) or one of two valid mezzanine cards */
-	if (!((nvm_data & NVM_COMPAT_LOM) ||
-	      (hw->adapter->pdev->device == E1000_DEV_ID_82571EB_SERDES_DUAL) ||
-	      (hw->adapter->pdev->device == E1000_DEV_ID_82571EB_SERDES_QUAD) ||
-	      (hw->adapter->pdev->device == E1000_DEV_ID_82571EB_SERDES)))
+	/* not supported on older hardware or 82573 */
+	if ((hw->mac.type < e1000_82571) || (hw->mac.type == e1000_82573))
 		goto out;
 
 	ret_val = e1000_read_nvm(hw, NVM_ALT_MAC_ADDR_PTR, 1,
-- 
1.7.7.4
