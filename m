From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/11] e1000e: ICHx/PCHx LOMs should use LPLU setting in NVM when going to Sx
Date: Thu, 26 Jan 2012 19:08:41 -0800
Message-ID: <1327633729-14086-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1327633729-14086-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:64222 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754686Ab2A0DIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 22:08:55 -0500
In-Reply-To: <1327633729-14086-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When going to Sx with an ICHx/PCH device, the default Low Power Link Up
(LPLU, a.k.a. reverse auto-negotiation) behavior should be whatever is set
in the NVM.  However, the function e1000_suspend_workarounds_ich8lan()
called when going to Sx always enabled LPLU in all power states.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 50a61fc..00b5e34 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -3698,9 +3698,10 @@ void e1000e_gig_downshift_workaround_ich8lan(struct e1000_hw *hw)
  *
  *  During S0 to Sx transition, it is possible the link remains at gig
  *  instead of negotiating to a lower speed.  Before going to Sx, set
- *  'LPLU Enabled' and 'Gig Disable' to force link speed negotiation
- *  to a lower speed.  For PCH and newer parts, the OEM bits PHY register
- *  (LED, GbE disable and LPLU configurations) also needs to be written.
+ *  'Gig Disable' to force link speed negotiation to a lower speed based on
+ *  the LPLU setting in the NVM or custom setting.  For PCH and newer parts,
+ *  the OEM bits PHY register (LED, GbE disable and LPLU configurations) also
+ *  needs to be written.
  **/
 void e1000_suspend_workarounds_ich8lan(struct e1000_hw *hw)
 {
@@ -3708,7 +3709,7 @@ void e1000_suspend_workarounds_ich8lan(struct e1000_hw *hw)
 	s32 ret_val;
 
 	phy_ctrl = er32(PHY_CTRL);
-	phy_ctrl |= E1000_PHY_CTRL_D0A_LPLU | E1000_PHY_CTRL_GBE_DISABLE;
+	phy_ctrl |= E1000_PHY_CTRL_GBE_DISABLE;
 	ew32(PHY_CTRL, phy_ctrl);
 
 	if (hw->mac.type == e1000_ich8lan)
-- 
1.7.7.6
