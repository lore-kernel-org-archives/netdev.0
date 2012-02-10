From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/7] e1000e: remove test that is always false
Date: Fri, 10 Feb 2012 00:08:51 -0800
Message-ID: <1328861337-12810-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328861337-12810-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:7659 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755043Ab2BJIJA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 03:09:00 -0500
In-Reply-To: <1328861337-12810-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

warning: comparison of unsigned expression < 0 is always false

Remove an unnecessary test that is reported when compiling driver with W=1.
The test is unnecessary because Intel wired GbE hardware older (i.e. less)
than 82571 is not supported by this driver.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/mac.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethernet/intel/e1000e/mac.c
index e1cf107..33d1b9e 100644
--- a/drivers/net/ethernet/intel/e1000e/mac.c
+++ b/drivers/net/ethernet/intel/e1000e/mac.c
@@ -174,8 +174,8 @@ s32 e1000_check_alt_mac_addr_generic(struct e1000_hw *hw)
 	if (ret_val)
 		goto out;
 
-	/* not supported on older hardware or 82573 */
-	if ((hw->mac.type < e1000_82571) || (hw->mac.type == e1000_82573))
+	/* not supported on 82573 */
+	if (hw->mac.type == e1000_82573)
 		goto out;
 
 	ret_val = e1000_read_nvm(hw, NVM_ALT_MAC_ADDR_PTR, 1,
-- 
1.7.7.6
