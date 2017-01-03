From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 06/21] ixgbe: Reduce I2C retry count on X550 devices
Date: Tue,  3 Jan 2017 13:07:42 -0800
Message-ID: <20170103210757.38847-7-jeffrey.t.kirsher@intel.com>
References: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:3461 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935988AbdACVIF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 16:08:05 -0500
In-Reply-To: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

A retry count of 10 is likely to run into problems on X550 devices that
have to detect and reset unresponsive CS4227 devices. So, reduce the I2C
retry count to 3 for X550 and above. This should avoid any possible
regressions in existing devices.

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index b272938..019b3c2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -113,7 +113,7 @@ s32 ixgbe_read_i2c_combined_generic_int(struct ixgbe_hw *hw, u8 addr,
 					u16 reg, u16 *val, bool lock)
 {
 	u32 swfw_mask = hw->phy.phy_semaphore_mask;
-	int max_retry = 10;
+	int max_retry = 3;
 	int retry = 0;
 	u8 csum_byte;
 	u8 high_bits;
@@ -1755,6 +1755,8 @@ static s32 ixgbe_read_i2c_byte_generic_int(struct ixgbe_hw *hw, u8 byte_offset,
 	u32 swfw_mask = hw->phy.phy_semaphore_mask;
 	bool nack = true;
 
+	if (hw->mac.type >= ixgbe_mac_X550)
+		max_retry = 3;
 	if (ixgbe_is_sfp_probe(hw, byte_offset, dev_addr))
 		max_retry = IXGBE_SFP_DETECT_RETRIES;
 
-- 
2.9.3
