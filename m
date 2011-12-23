From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/9] ixgbe: add write flush in ixgbe_clock_out_i2c_byte()
Date: Fri, 23 Dec 2011 01:09:13 -0800
Message-ID: <1324631357-31789-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:44079 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753983Ab1LWJJW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Dec 2011 04:09:22 -0500
In-Reply-To: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

I2C access is timing critical. Always do a write flush after writing
to the I2CCTL register.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index 8b113e3..7cf1e1f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -1457,6 +1457,7 @@ static s32 ixgbe_clock_out_i2c_byte(struct ixgbe_hw *hw, u8 data)
 	i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL);
 	i2cctl |= IXGBE_I2C_DATA_OUT;
 	IXGBE_WRITE_REG(hw, IXGBE_I2CCTL, i2cctl);
+	IXGBE_WRITE_FLUSH(hw);
 
 	return status;
 }
-- 
1.7.7.4
