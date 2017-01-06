From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/10] igb: Workaround for igb i210 firmware issue
Date: Fri,  6 Jan 2017 02:48:46 -0800
Message-ID: <20170106104852.10363-5-jeffrey.t.kirsher@intel.com>
References: <20170106104852.10363-1-jeffrey.t.kirsher@intel.com>
Cc: Chris J Arges <christopherarges@gmail.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:51441 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965534AbdAFKtX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 05:49:23 -0500
In-Reply-To: <20170106104852.10363-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris J Arges <christopherarges@gmail.com>

Sometimes firmware may not properly initialize I347AT4_PAGE_SELECT causing
the probe of an igb i210 NIC to fail. This patch adds an addition zeroing
of this register during igb_get_phy_id to workaround this issue.

Thanks for Jochen Henneberg for the idea and original patch.

Signed-off-by: Chris J Arges <christopherarges@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_phy.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index 5b54254..569ee25 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -77,6 +77,10 @@ s32 igb_get_phy_id(struct e1000_hw *hw)
 	s32 ret_val = 0;
 	u16 phy_id;
 
+	/* ensure PHY page selection to fix misconfigured i210 */
+	if (hw->mac.type == e1000_i210)
+		phy->ops.write_reg(hw, I347AT4_PAGE_SELECT, 0);
+
 	ret_val = phy->ops.read_reg(hw, PHY_ID1, &phy_id);
 	if (ret_val)
 		goto out;
-- 
2.9.3
