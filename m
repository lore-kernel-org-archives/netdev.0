From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/2] igb: Add additional get_phy_id call for i354 devices
Date: Tue, 10 Sep 2013 11:57:16 -0700
Message-ID: <1378839437-10965-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16614 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750905Ab3IJS5U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 14:57:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes a problem where some ports can fail to initialize on a
cold boot. This patch adds an additional call to read the PHY id for i354
devices in order workaround the hardware problem.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 79b5835..47c2d10 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -719,6 +719,10 @@ static s32 igb_get_phy_id_82575(struct e1000_hw *hw)
 	u32 ctrl_ext;
 	u32 mdic;
 
+	/* Extra read required for some PHY's on i354 */
+	if (hw->mac.type == e1000_i354)
+		igb_get_phy_id(hw);
+
 	/* For SGMII PHYs, we try the list of possible addresses until
 	 * we find one that works.  For non-SGMII PHYs
 	 * (e.g. integrated copper PHYs), an address of 1 should
-- 
1.8.3.1
