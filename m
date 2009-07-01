From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 3/6] e1000e: do not write SmartSpeed register bits on
	parts without support
Date: Wed, 01 Jul 2009 16:28:14 -0700
Message-ID: <20090701232814.20555.5052.stgit@localhost.localdomain>
References: <20090701232731.20555.63487.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.emeryville.ca.mail.comcast.net ([76.96.27.228]:50198
	"EHLO QMTA15.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752900AbZGAX22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 19:28:28 -0400
In-Reply-To: <20090701232731.20555.63487.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The driver was accessing register bits for features on parts that do
not support that feature.  This could cause problems in the hardware.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 438778f..bf9b97d 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -977,12 +977,14 @@ static s32 e1000_set_d0_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 		phy_ctrl |= E1000_PHY_CTRL_D0A_LPLU;
 		ew32(PHY_CTRL, phy_ctrl);
 
+		if (phy->type != e1000_phy_igp_3)
+			return 0;
+
 		/*
 		 * Call gig speed drop workaround on LPLU before accessing
 		 * any PHY registers
 		 */
-		if ((hw->mac.type == e1000_ich8lan) &&
-		    (hw->phy.type == e1000_phy_igp_3))
+		if (hw->mac.type == e1000_ich8lan)
 			e1000e_gig_downshift_workaround_ich8lan(hw);
 
 		/* When LPLU is enabled, we should disable SmartSpeed */
@@ -995,6 +997,9 @@ static s32 e1000_set_d0_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 		phy_ctrl &= ~E1000_PHY_CTRL_D0A_LPLU;
 		ew32(PHY_CTRL, phy_ctrl);
 
+		if (phy->type != e1000_phy_igp_3)
+			return 0;
+
 		/*
 		 * LPLU and SmartSpeed are mutually exclusive.  LPLU is used
 		 * during Dx states where the power conservation is most
@@ -1054,6 +1059,10 @@ static s32 e1000_set_d3_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 	if (!active) {
 		phy_ctrl &= ~E1000_PHY_CTRL_NOND0A_LPLU;
 		ew32(PHY_CTRL, phy_ctrl);
+
+		if (phy->type != e1000_phy_igp_3)
+			return 0;
+
 		/*
 		 * LPLU and SmartSpeed are mutually exclusive.  LPLU is used
 		 * during Dx states where the power conservation is most
@@ -1089,12 +1098,14 @@ static s32 e1000_set_d3_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 		phy_ctrl |= E1000_PHY_CTRL_NOND0A_LPLU;
 		ew32(PHY_CTRL, phy_ctrl);
 
+		if (phy->type != e1000_phy_igp_3)
+			return 0;
+
 		/*
 		 * Call gig speed drop workaround on LPLU before accessing
 		 * any PHY registers
 		 */
-		if ((hw->mac.type == e1000_ich8lan) &&
-		    (hw->phy.type == e1000_phy_igp_3))
+		if (hw->mac.type == e1000_ich8lan)
 			e1000e_gig_downshift_workaround_ich8lan(hw);
 
 		/* When LPLU is enabled, we should disable SmartSpeed */

