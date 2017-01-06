From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/10] igb: add i211 to i210 PHY workaround
Date: Fri,  6 Jan 2017 02:48:51 -0800
Message-ID: <20170106104852.10363-10-jeffrey.t.kirsher@intel.com>
References: <20170106104852.10363-1-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:57006 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S968705AbdAFKtZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 05:49:25 -0500
In-Reply-To: <20170106104852.10363-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

i210 and i211 share the same PHY but have different PCI IDs. Don't
forget i211 for any i210 workarounds.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_phy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index 569ee25..2788a54 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -78,7 +78,7 @@ s32 igb_get_phy_id(struct e1000_hw *hw)
 	u16 phy_id;
 
 	/* ensure PHY page selection to fix misconfigured i210 */
-	if (hw->mac.type == e1000_i210)
+	if ((hw->mac.type == e1000_i210) || (hw->mac.type == e1000_i211))
 		phy->ops.write_reg(hw, I347AT4_PAGE_SELECT, 0);
 
 	ret_val = phy->ops.read_reg(hw, PHY_ID1, &phy_id);
-- 
2.9.3
