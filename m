From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/12] e1000e: fix scheduling while atomic bugs
Date: Thu, 28 Mar 2013 02:00:13 -0700
Message-ID: <1364461215-7793-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1364461215-7793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31739 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751091Ab3C1JA0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Mar 2013 05:00:26 -0400
In-Reply-To: <1364461215-7793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The previous commit ce43a2168c59bc47b5f0c1825fd5f9a2a9e3b447 (e1000e:
cleanup USLEEP_RANGE checkpatch checks) converted a number of delays and
sleeps as recommended in ./Documentation/timers/timers-howto.txt.
Unfortunately, a few of the udelay() to usleep_range() conversions are in
code paths that are in an atomic context in which usleep_range() should
not be used.  Revert those specific changes.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/phy.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index cbb310f..59c76a6 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -165,7 +165,7 @@ s32 e1000e_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 	 * the lower time out
 	 */
 	for (i = 0; i < (E1000_GEN_POLL_TIMEOUT * 3); i++) {
-		usleep_range(50, 100);
+		udelay(50);
 		mdic = er32(MDIC);
 		if (mdic & E1000_MDIC_READY)
 			break;
@@ -190,7 +190,7 @@ s32 e1000e_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 	 * reading duplicate data in the next MDIC transaction.
 	 */
 	if (hw->mac.type == e1000_pch2lan)
-		usleep_range(100, 200);
+		udelay(100);
 
 	return 0;
 }
@@ -229,7 +229,7 @@ s32 e1000e_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 	 * the lower time out
 	 */
 	for (i = 0; i < (E1000_GEN_POLL_TIMEOUT * 3); i++) {
-		usleep_range(50, 100);
+		udelay(50);
 		mdic = er32(MDIC);
 		if (mdic & E1000_MDIC_READY)
 			break;
@@ -253,7 +253,7 @@ s32 e1000e_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 	 * reading duplicate data in the next MDIC transaction.
 	 */
 	if (hw->mac.type == e1000_pch2lan)
-		usleep_range(100, 200);
+		udelay(100);
 
 	return 0;
 }
-- 
1.7.11.7
