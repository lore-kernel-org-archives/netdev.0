From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] ixgbe: Do not clear RAR entry when clearing VMDq for SAN MAC
Date: Fri, 19 Aug 2016 20:58:26 -0700
Message-ID: <1471665506-75138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:63672 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752404AbcHTD6a (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 23:58:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The RAR entry for the SAN MAC address was being cleared when we were
clearing the VMDq pool bits.  In order to prevent this we need to add
an extra check to protect the SAN MAC from being cleared.

Fixes: 6e982aeae ("ixgbe: Clear stale pool mappings")
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index b4217f3..c47b605 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -2958,8 +2958,10 @@ s32 ixgbe_clear_vmdq_generic(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
 	}
 
 	/* was that the last pool using this rar? */
-	if (mpsar_lo == 0 && mpsar_hi == 0 && rar != 0)
+	if (mpsar_lo == 0 && mpsar_hi == 0 &&
+	    rar != 0 && rar != hw->mac.san_mac_rar_index)
 		hw->mac.ops.clear_rar(hw, rar);
+
 	return 0;
 }
 
-- 
2.7.4
