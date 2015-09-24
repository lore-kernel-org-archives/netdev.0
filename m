From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/18] ixgbe: Clear I2C destination location
Date: Wed, 23 Sep 2015 23:59:24 -0700
Message-ID: <1443077981-55791-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443077981-55791-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36281 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932624AbbIXG7t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 02:59:49 -0400
In-Reply-To: <1443077981-55791-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Clear the destination location for I2C data initially so that
the received data will not be affected by previous attempts.
This could have returned wrong data in certain retry sequences.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index 315f059..88ade17 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -2026,6 +2026,7 @@ static s32 ixgbe_clock_in_i2c_byte(struct ixgbe_hw *hw, u8 *data)
 	s32 i;
 	bool bit = false;
 
+	*data = 0;
 	for (i = 7; i >= 0; i--) {
 		ixgbe_clock_in_i2c_bit(hw, &bit);
 		*data |= bit << i;
-- 
2.4.3
