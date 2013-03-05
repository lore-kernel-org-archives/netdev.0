From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/4] igb: Fix link setup for I210 devices
Date: Tue,  5 Mar 2013 01:48:36 -0800
Message-ID: <1362476917-5189-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1362476917-5189-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43723 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755464Ab3CEJsn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Mar 2013 04:48:43 -0500
In-Reply-To: <1362476917-5189-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch changes the setup copper link function to use a switch
statement for the PHY id's available for the given PHY types.  It
also adds a case for the I210 PHY id, so the appropriate setup link
function is called for it.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 84e7e09..b64542a 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -1361,11 +1361,16 @@ static s32 igb_setup_copper_link_82575(struct e1000_hw *hw)
 	switch (hw->phy.type) {
 	case e1000_phy_i210:
 	case e1000_phy_m88:
-		if (hw->phy.id == I347AT4_E_PHY_ID ||
-		    hw->phy.id == M88E1112_E_PHY_ID)
+		switch (hw->phy.id) {
+		case I347AT4_E_PHY_ID:
+		case M88E1112_E_PHY_ID:
+		case I210_I_PHY_ID:
 			ret_val = igb_copper_link_setup_m88_gen2(hw);
-		else
+			break;
+		default:
 			ret_val = igb_copper_link_setup_m88(hw);
+			break;
+		}
 		break;
 	case e1000_phy_igp_3:
 		ret_val = igb_copper_link_setup_igp(hw);
-- 
1.7.11.7
