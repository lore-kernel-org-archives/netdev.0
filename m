From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/12] e1000e: add check on e1e_wphy() return value
Date: Wed,  9 Aug 2017 14:47:37 -0700
Message-ID: <20170809214746.28139-4-jeffrey.t.kirsher@intel.com>
References: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
Cc: Gustavo A R Silva <garsilva@embeddedor.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:31102 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752291AbdHIVr4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Aug 2017 17:47:56 -0400
In-Reply-To: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo A R Silva <garsilva@embeddedor.com>

Check return value from call to e1e_wphy(). This value is being
checked during previous calls to function e1e_wphy() and it seems
a check was missing here.

Addresses-Coverity-ID: 1226905
Signed-off-by: Gustavo A R Silva <garsilva@embeddedor.com>
Reviewed-by: Ethan Zhao <ethan.zhao@oracle.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 68ea8b4555ab..d6d4ed7acf03 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -2437,6 +2437,8 @@ static s32 e1000_hv_phy_workarounds_ich8lan(struct e1000_hw *hw)
 		if (hw->phy.revision < 2) {
 			e1000e_phy_sw_reset(hw);
 			ret_val = e1e_wphy(hw, MII_BMCR, 0x3140);
+			if (ret_val)
+				return ret_val;
 		}
 	}
 
-- 
2.13.3
