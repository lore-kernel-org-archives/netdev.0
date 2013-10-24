From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/11] igb: Fix master/slave mode for all m88 i354 PHY's
Date: Thu, 24 Oct 2013 08:27:31 -0700
Message-ID: <1382628458-26601-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1382628458-26601-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:12355 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755551Ab3JXP1o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Oct 2013 11:27:44 -0400
In-Reply-To: <1382628458-26601-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch calls code to set the master/slave mode for all m88 gen 2
PHY's. This patch also removes the call to this function for I210 devices
only from the function that is not called by I210 devices.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper  <jeffrey.e.pieper@gmail.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_phy.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index e726675..c4c4fe3 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -708,11 +708,6 @@ s32 igb_copper_link_setup_m88(struct e1000_hw *hw)
 		hw_dbg("Error committing the PHY changes\n");
 		goto out;
 	}
-	if (phy->type == e1000_phy_i210) {
-		ret_val = igb_set_master_slave_mode(hw);
-		if (ret_val)
-			return ret_val;
-	}
 
 out:
 	return ret_val;
@@ -806,6 +801,9 @@ s32 igb_copper_link_setup_m88_gen2(struct e1000_hw *hw)
 		hw_dbg("Error committing the PHY changes\n");
 		return ret_val;
 	}
+	ret_val = igb_set_master_slave_mode(hw);
+	if (ret_val)
+		return ret_val;
 
 	return 0;
 }
-- 
1.8.3.1
