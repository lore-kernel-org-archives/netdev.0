From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/4] ixgbevf: only check Tx queue enablement when debugging
Date: Thu, 18 Aug 2016 23:03:35 -0700
Message-ID: <1471586616-64728-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471586616-64728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:23047 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754712AbcHSGDy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 02:03:54 -0400
In-Reply-To: <1471586616-64728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Following a write the VFTXDCTL.ENABLE bit is set only when the Tx queue
is actually enabled, which may not happen during the configure phase even
if we waited for it. Make this check debug only since this is causing
confusion with users who notice the warning in dmesg.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 8d4f535..4044608 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1612,7 +1612,7 @@ static void ixgbevf_configure_tx_ring(struct ixgbevf_adapter *adapter,
 		txdctl = IXGBE_READ_REG(hw, IXGBE_VFTXDCTL(reg_idx));
 	}  while (--wait_loop && !(txdctl & IXGBE_TXDCTL_ENABLE));
 	if (!wait_loop)
-		pr_err("Could not enable Tx Queue %d\n", reg_idx);
+		hw_dbg(hw, "Could not enable Tx Queue %d\n", reg_idx);
 }
 
 /**
-- 
2.7.4
