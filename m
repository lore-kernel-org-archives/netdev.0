From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  5/9] igb: No PHPM support in i354 devices
Date: Wed,  4 Sep 2013 06:08:52 -0700
Message-ID: <1378300136-26003-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1378300136-26003-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56125 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762404Ab3IDNJB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 09:09:01 -0400
In-Reply-To: <1378300136-26003-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

PHY Power Management does not exist for i354 device. So, there is no
need to read and write this register or clear go link Disconnect bit,
which could cause a lot of issues.

Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index b0b33a1..d796e29 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -1421,11 +1421,18 @@ static s32 igb_setup_copper_link_82575(struct e1000_hw *hw)
 	ctrl &= ~(E1000_CTRL_FRCSPD | E1000_CTRL_FRCDPX);
 	wr32(E1000_CTRL, ctrl);
 
-	/* Clear Go Link Disconnect bit */
-	if (hw->mac.type >= e1000_82580) {
+	/* Clear Go Link Disconnect bit on supported devices */
+	switch (hw->mac.type) {
+	case e1000_82580:
+	case e1000_i350:
+	case e1000_i210:
+	case e1000_i211:
 		phpm_reg = rd32(E1000_82580_PHY_POWER_MGMT);
 		phpm_reg &= ~E1000_82580_PM_GO_LINKD;
 		wr32(E1000_82580_PHY_POWER_MGMT, phpm_reg);
+		break;
+	default:
+		break;
 	}
 
 	ret_val = igb_setup_serdes_link_82575(hw);
-- 
1.8.3.1
