From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/8] e1000e: use correct type for read of 32-bit register
Date: Thu, 30 Aug 2012 22:16:07 -0700
Message-ID: <1346390174-30449-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1346390174-30449-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:14908 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750889Ab2HaFQi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2012 01:16:38 -0400
In-Reply-To: <1346390174-30449-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The POEMB register is 32 bits, not 16.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/82571.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 080c890..c985864 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -653,7 +653,7 @@ static void e1000_put_hw_semaphore_82574(struct e1000_hw *hw)
  **/
 static s32 e1000_set_d0_lplu_state_82574(struct e1000_hw *hw, bool active)
 {
-	u16 data = er32(POEMB);
+	u32 data = er32(POEMB);
 
 	if (active)
 		data |= E1000_PHY_CTRL_D0A_LPLU;
@@ -677,7 +677,7 @@ static s32 e1000_set_d0_lplu_state_82574(struct e1000_hw *hw, bool active)
  **/
 static s32 e1000_set_d3_lplu_state_82574(struct e1000_hw *hw, bool active)
 {
-	u16 data = er32(POEMB);
+	u32 data = er32(POEMB);
 
 	if (!active) {
 		data &= ~E1000_PHY_CTRL_NOND0A_LPLU;
-- 
1.7.11.4
