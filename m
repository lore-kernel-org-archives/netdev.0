From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 v2 13/15] ixgbe: cleanup namespace complaint by removing little used function
Date: Fri, 11 Feb 2011 09:21:00 -0800
Message-ID: <1297444862-32091-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1297444862-32091-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2017 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757887Ab1BKRV0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 12:21:26 -0500
In-Reply-To: <1297444862-32091-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

We had a support function that just walked a few pointers to get
from the ixgbe_hw struct to the netdev pointer.  This was causing
a namespace warning so I removed it and just reference the pointers
directly.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_common.h |    4 ++--
 drivers/net/ixgbe/ixgbe_main.c   |   10 ----------
 2 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index 66ed045..90cceb4 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -29,6 +29,7 @@
 #define _IXGBE_COMMON_H_
 
 #include "ixgbe_type.h"
+#include "ixgbe.h"
 
 u32 ixgbe_get_pcie_msix_count_generic(struct ixgbe_hw *hw);
 s32 ixgbe_init_ops_generic(struct ixgbe_hw *hw);
@@ -110,9 +111,8 @@ void ixgbe_set_vlan_anti_spoofing(struct ixgbe_hw *hw, bool enable, int vf);
 
 #define IXGBE_WRITE_FLUSH(a) IXGBE_READ_REG(a, IXGBE_STATUS)
 
-extern struct net_device *ixgbe_get_hw_dev(struct ixgbe_hw *hw);
 #define hw_dbg(hw, format, arg...) \
-	netdev_dbg(ixgbe_get_hw_dev(hw), format, ##arg)
+	netdev_dbg(((struct ixgbe_adapter *)(hw->back))->netdev, format, ##arg)
 #define e_dev_info(format, arg...) \
 	dev_info(&adapter->pdev->dev, format, ## arg)
 #define e_dev_warn(format, arg...) \
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 34fdda2..4a6bcb6 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -7707,16 +7707,6 @@ static int ixgbe_notify_dca(struct notifier_block *nb, unsigned long event,
 
 #endif /* CONFIG_IXGBE_DCA */
 
-/**
- * ixgbe_get_hw_dev return device
- * used by hardware layer to print debugging information
- **/
-struct net_device *ixgbe_get_hw_dev(struct ixgbe_hw *hw)
-{
-	struct ixgbe_adapter *adapter = hw->back;
-	return adapter->netdev;
-}
-
 module_exit(ixgbe_exit_module);
 
 /* ixgbe_main.c */
-- 
1.7.4

