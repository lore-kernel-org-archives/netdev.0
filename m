From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [stable-2.6.32.y] ixgbe: fix for 82599 erratum on Header Splitting
Date: Sat,  5 Mar 2011 15:14:50 -0800
Message-ID: <1299366890-10333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, stable@kernel.org,
	netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:45169 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751667Ab1CEXQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 18:16:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

We have found a hardware erratum on 82599 hardware that can lead to
unpredictable behavior when Header Splitting mode is enabled.  So
we are no longer enabling this feature on affected hardware.

This is an updated version of the following commit which applies to the stable
linux-2.6.32.y tree:
  commit a124339ad28389093ed15eca990d39c51c5736cc
  Author: Don Skidmore <donald.c.skidmore@intel.com>
  Date:   Tue Jan 18 22:53:47 2011 +0000

    ixgbe: fix for 82599 erratum on Header Splitting

Please aaply this for the .32 longterm tree.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a873c5d..67d1d97 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2131,6 +2131,10 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	/* Decide whether to use packet split mode or not */
 	adapter->flags |= IXGBE_FLAG_RX_PS_ENABLED;
 
+	/* Disable packet split due to 82599 erratum #45 */
+	if (hw->mac.type == ixgbe_mac_82599EB)
+		adapter->flags &= ~IXGBE_FLAG_RX_PS_ENABLED;
+
 	/* Set the RX buffer length according to the mode */
 	if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
 		rx_buf_len = IXGBE_RX_HDR_SIZE;
-- 
1.7.4

