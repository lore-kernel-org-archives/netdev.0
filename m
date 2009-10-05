From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 03/15] igb: update the approach taken to
	acquiring and releasing the phy lock
Date: Mon, 05 Oct 2009 09:32:07 -0700
Message-ID: <20091005163206.32487.22702.stgit@localhost.localdomain>
References: <20091005163058.32487.10125.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:38008 "EHLO
	QMTA08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753907AbZJEQeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 12:34:17 -0400
In-Reply-To: <20091005163058.32487.10125.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The current approach is just using a ?: type mechanism to set the phy
locking bit.  This if fine for now but limits us to only 2.  Switch to a
nested if statement for future compatiblity with more than 2 phys.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 5604b3e..65b9000 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -240,9 +240,10 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
  **/
 static s32 igb_acquire_phy_82575(struct e1000_hw *hw)
 {
-	u16 mask;
+	u16 mask = E1000_SWFW_PHY0_SM;
 
-	mask = hw->bus.func ? E1000_SWFW_PHY1_SM : E1000_SWFW_PHY0_SM;
+	if (hw->bus.func == E1000_FUNC_1)
+		mask = E1000_SWFW_PHY1_SM;
 
 	return igb_acquire_swfw_sync_82575(hw, mask);
 }
@@ -256,9 +257,11 @@ static s32 igb_acquire_phy_82575(struct e1000_hw *hw)
  **/
 static void igb_release_phy_82575(struct e1000_hw *hw)
 {
-	u16 mask;
+	u16 mask = E1000_SWFW_PHY0_SM;
+
+	if (hw->bus.func == E1000_FUNC_1)
+		mask = E1000_SWFW_PHY1_SM;
 
-	mask = hw->bus.func ? E1000_SWFW_PHY1_SM : E1000_SWFW_PHY0_SM;
 	igb_release_swfw_sync_82575(hw, mask);
 }
 

