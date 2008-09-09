From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 03/24] ixgbe: fix multicast address update
Date: Mon, 08 Sep 2008 21:47:40 -0700
Message-ID: <20080909044740.18904.94034.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.248]:59329 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754382AbYIIErn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 00:47:43 -0400
Received: by hs-out-0708.google.com with SMTP id 4so428996hsl.5
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 21:47:42 -0700 (PDT)
In-Reply-To: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

after the most recent patches, the driver was not using the
correct iterator for updating the receive address registers (RAR)

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_common.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 9c0d0a1..f5b2617 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -896,6 +896,7 @@ static void ixgbe_set_mta(struct ixgbe_hw *hw, u8 *mc_addr)
 static void ixgbe_add_mc_addr(struct ixgbe_hw *hw, u8 *mc_addr)
 {
 	u32 rar_entries = hw->mac.num_rar_entries;
+	u32 rar;
 
 	hw_dbg(hw, " MC Addr =%.2X %.2X %.2X %.2X %.2X %.2X\n",
 		  mc_addr[0], mc_addr[1], mc_addr[2],
@@ -906,8 +907,8 @@ static void ixgbe_add_mc_addr(struct ixgbe_hw *hw, u8 *mc_addr)
 	 * else put it in the MTA
 	 */
 	if (hw->addr_ctrl.rar_used_count < rar_entries) {
-		ixgbe_set_rar(hw, hw->addr_ctrl.rar_used_count,
-			      mc_addr, 0, IXGBE_RAH_AV);
+		rar = rar_entries - hw->addr_ctrl.mc_addr_in_rar_count - 1;
+		ixgbe_set_rar(hw, rar, mc_addr, 0, IXGBE_RAH_AV);
 		hw_dbg(hw, "Added a multicast address to RAR[%d]\n",
 			  hw->addr_ctrl.rar_used_count);
 		hw->addr_ctrl.rar_used_count++;

