From: Chris J Arges <christopherarges@gmail.com>
Subject: [PATCH] igb: Workaround for igb i210 firmware issue.
Date: Wed,  2 Nov 2016 09:13:42 -0500
Message-ID: <1478096032-22119-1-git-send-email-christopherarges@gmail.com>
Cc: intel-wired-lan@lists.osuosl.org,
        Chris J Arges <christopherarges@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jh@henneberg-systemdesign.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sometimes firmware may not properly initialize I347AT4_PAGE_SELECT causing
the probe of an igb i210 NIC to fail. This patch adds an addition zeroing of
this register during igb_get_phy_id to workaround this issue.

Thanks for Jochen Henneberg for the idea and original patch.

Signed-off-by: Chris J Arges <christopherarges@gmail.com>
---
 drivers/net/ethernet/intel/igb/e1000_phy.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index 5b54254..93ec2d0 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -77,6 +77,10 @@ s32 igb_get_phy_id(struct e1000_hw *hw)
 	s32 ret_val = 0;
 	u16 phy_id;
 
+	/* ensure phy page selection to fix misconfigured i210 */
+	if (hw->mac.type == e1000_i210)
+		phy->ops.write_reg(hw, I347AT4_PAGE_SELECT, 0);
+
 	ret_val = phy->ops.read_reg(hw, PHY_ID1, &phy_id);
 	if (ret_val)
 		goto out;
-- 
2.7.4
