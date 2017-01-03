From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 05/21] ixgbe: Add bounds check for x540 LED functions
Date: Tue,  3 Jan 2017 13:07:41 -0800
Message-ID: <20170103210757.38847-6-jeffrey.t.kirsher@intel.com>
References: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:25260 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935985AbdACVIE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 16:08:04 -0500
In-Reply-To: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

This is an extension of commit 003287e0f087 ("ixgbevf: Correct parameter
sent to LED function"); add bounds checking to x540 functions to ensure the
index is valid.

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index e2ff823..afc4d16 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -780,8 +780,10 @@ s32 ixgbe_blink_led_start_X540(struct ixgbe_hw *hw, u32 index)
 	ixgbe_link_speed speed;
 	bool link_up;
 
-	/*
-	 * Link should be up in order for the blink bit in the LED control
+	if (index > 3)
+		return IXGBE_ERR_PARAM;
+
+	/* Link should be up in order for the blink bit in the LED control
 	 * register to work. Force link and speed in the MAC if link is down.
 	 * This will be reversed when we stop the blinking.
 	 */
@@ -814,6 +816,9 @@ s32 ixgbe_blink_led_stop_X540(struct ixgbe_hw *hw, u32 index)
 	u32 macc_reg;
 	u32 ledctl_reg;
 
+	if (index > 3)
+		return IXGBE_ERR_PARAM;
+
 	/* Restore the LED to its default value. */
 	ledctl_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
 	ledctl_reg &= ~IXGBE_LED_MODE_MASK(index);
-- 
2.9.3
