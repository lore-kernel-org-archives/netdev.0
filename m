From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/3] igb: Do not overwrite mdicnfg register when
	accessing 82580 phy
Date: Mon, 22 Mar 2010 17:07:26 -0700
Message-ID: <20100323000724.19939.17642.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:49769
	"EHLO qmta05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752684Ab0CWAHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 20:07:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change removes the extra configuration we were doing on the mdicnfg
register which should be set by EEPROM and which we should not need to
write again afterwards.  This code was a holdover from some earlier
development work that was being done on a board with an incomplete EEPROM
and is no longer needed now that the production EEPROMs are in place.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |   20 --------------------
 1 files changed, 0 insertions(+), 20 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 0bc990e..ea944f5 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1446,7 +1446,6 @@ void igb_vmdq_set_replication_pf(struct e1000_hw *hw, bool enable)
  **/
 static s32 igb_read_phy_reg_82580(struct e1000_hw *hw, u32 offset, u16 *data)
 {
-	u32 mdicnfg = 0;
 	s32 ret_val;
 
 
@@ -1454,15 +1453,6 @@ static s32 igb_read_phy_reg_82580(struct e1000_hw *hw, u32 offset, u16 *data)
 	if (ret_val)
 		goto out;
 
-	/*
-	 * We config the phy address in MDICNFG register now. Same bits
-	 * as before. The values in MDIC can be written but will be
-	 * ignored. This allows us to call the old function after
-	 * configuring the PHY address in the new register
-	 */
-	mdicnfg = (hw->phy.addr << E1000_MDIC_PHY_SHIFT);
-	wr32(E1000_MDICNFG, mdicnfg);
-
 	ret_val = igb_read_phy_reg_mdic(hw, offset, data);
 
 	hw->phy.ops.release(hw);
@@ -1481,7 +1471,6 @@ out:
  **/
 static s32 igb_write_phy_reg_82580(struct e1000_hw *hw, u32 offset, u16 data)
 {
-	u32 mdicnfg = 0;
 	s32 ret_val;
 
 
@@ -1489,15 +1478,6 @@ static s32 igb_write_phy_reg_82580(struct e1000_hw *hw, u32 offset, u16 data)
 	if (ret_val)
 		goto out;
 
-	/*
-	 * We config the phy address in MDICNFG register now. Same bits
-	 * as before. The values in MDIC can be written but will be
-	 * ignored. This allows us to call the old function after
-	 * configuring the PHY address in the new register
-	 */
-	mdicnfg = (hw->phy.addr << E1000_MDIC_PHY_SHIFT);
-	wr32(E1000_MDICNFG, mdicnfg);
-
 	ret_val = igb_write_phy_reg_mdic(hw, offset, data);
 
 	hw->phy.ops.release(hw);

