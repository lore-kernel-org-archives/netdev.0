From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND][NET-NEXT PATCH 03/29] ixgbe: fix multicast address update
Date: Thu, 11 Sep 2008 19:55:14 -0700
Message-ID: <20080912025451.6234.22958.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:43432 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755544AbYILCzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 22:55:16 -0400
Received: by wa-out-1112.google.com with SMTP id j37so392135waf.23
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 19:55:16 -0700 (PDT)
In-Reply-To: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
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

