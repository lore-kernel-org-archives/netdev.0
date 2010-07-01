From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/5] igb: fix PHY config access on 82580
Date: Thu, 01 Jul 2010 16:37:54 -0700
Message-ID: <20100701233733.16171.4629.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.emeryville.ca.mail.comcast.net ([76.96.27.227]:49674
	"EHLO qmta12.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755523Ab0GAXiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jul 2010 19:38:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

82580 NICs can have up to 4 functions. This fixes phy accesses
to use the correct locks for functions 2 and 3.

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c   |    8 ++++++++
 drivers/net/igb/e1000_defines.h |    2 ++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 86438b5..06251a9 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -295,6 +295,10 @@ static s32 igb_acquire_phy_82575(struct e1000_hw *hw)
 
 	if (hw->bus.func == E1000_FUNC_1)
 		mask = E1000_SWFW_PHY1_SM;
+	else if (hw->bus.func == E1000_FUNC_2)
+		mask = E1000_SWFW_PHY2_SM;
+	else if (hw->bus.func == E1000_FUNC_3)
+		mask = E1000_SWFW_PHY3_SM;
 
 	return igb_acquire_swfw_sync_82575(hw, mask);
 }
@@ -312,6 +316,10 @@ static void igb_release_phy_82575(struct e1000_hw *hw)
 
 	if (hw->bus.func == E1000_FUNC_1)
 		mask = E1000_SWFW_PHY1_SM;
+	else if (hw->bus.func == E1000_FUNC_2)
+		mask = E1000_SWFW_PHY2_SM;
+	else if (hw->bus.func == E1000_FUNC_3)
+		mask = E1000_SWFW_PHY3_SM;
 
 	igb_release_swfw_sync_82575(hw, mask);
 }
diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index 24d9be6..90bc29d 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -164,6 +164,8 @@
 #define E1000_SWFW_EEP_SM   0x1
 #define E1000_SWFW_PHY0_SM  0x2
 #define E1000_SWFW_PHY1_SM  0x4
+#define E1000_SWFW_PHY2_SM  0x20
+#define E1000_SWFW_PHY3_SM  0x40
 
 /* FACTPS Definitions */
 /* Device Control */

