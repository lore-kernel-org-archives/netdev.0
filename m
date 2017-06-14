From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/9] ixgbe: fix writes to PFQDE
Date: Tue, 13 Jun 2017 17:38:08 -0700
Message-ID: <20170614003810.33189-8-jeffrey.t.kirsher@intel.com>
References: <20170614003810.33189-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:37346 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753957AbdFNAiX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Jun 2017 20:38:23 -0400
In-Reply-To: <20170614003810.33189-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

ixgbe_write_qde() was ignoring the qde parameter which resulted
in PFQDE.HIDE_VLAN not being set for X550.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index e2766da5fe02..0760bd7eeb01 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -818,7 +818,7 @@ static inline void ixgbe_write_qde(struct ixgbe_adapter *adapter, u32 vf,
 		IXGBE_WRITE_FLUSH(hw);
 
 		/* indicate to hardware that we want to set drop enable */
-		reg = IXGBE_QDE_WRITE | IXGBE_QDE_ENABLE;
+		reg = IXGBE_QDE_WRITE | qde;
 		reg |= i <<  IXGBE_QDE_IDX_SHIFT;
 		IXGBE_WRITE_REG(hw, IXGBE_QDE, reg);
 	}
-- 
2.12.2
