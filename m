From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/ixgbe/ixgbe_common.c: use %pM to show MAC address
Date: Tue, 5 Jan 2010 09:56:52 -0700
Message-ID: <201001050956.53199.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [206.15.93.42] ([206.15.93.42]:9423 "EHLO
	visionfs1.visionengravers.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754903Ab0AERDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 12:03:25 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the %pM kernel extension to display the MAC address.

The only difference in the output is that the MAC address is
shown in the usual colon-separated hex notation.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

Repost due to merge issues.

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 688b8ca..1cedb9a 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1278,19 +1278,11 @@ s32 ixgbe_init_rx_addrs_generic(struct ixgbe_hw *hw)
 		/* Get the MAC address from the RAR0 for later reference */
 		hw->mac.ops.get_mac_addr(hw, hw->mac.addr);
 
-		hw_dbg(hw, " Keeping Current RAR0 Addr =%.2X %.2X %.2X ",
-		       hw->mac.addr[0], hw->mac.addr[1],
-		       hw->mac.addr[2]);
-		hw_dbg(hw, "%.2X %.2X %.2X\n", hw->mac.addr[3],
-		       hw->mac.addr[4], hw->mac.addr[5]);
+		hw_dbg(hw, " Keeping Current RAR0 Addr =%pM\n", hw->mac.addr);
 	} else {
 		/* Setup the receive address. */
 		hw_dbg(hw, "Overriding MAC Address in RAR[0]\n");
-		hw_dbg(hw, " New MAC Addr =%.2X %.2X %.2X ",
-		       hw->mac.addr[0], hw->mac.addr[1],
-		       hw->mac.addr[2]);
-		hw_dbg(hw, "%.2X %.2X %.2X\n", hw->mac.addr[3],
-		       hw->mac.addr[4], hw->mac.addr[5]);
+		hw_dbg(hw, " New MAC Addr =%pM\n", hw->mac.addr);
 
 		hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0, IXGBE_RAH_AV);
 	}
