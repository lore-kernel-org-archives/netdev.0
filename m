From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/16] ixgbevf: Check for adapter removal on register writes
Date: Fri, 21 Mar 2014 05:09:59 -0700
Message-ID: <1395403806-29302-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15182 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965502AbaCUMKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2014 08:10:13 -0400
In-Reply-To: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Prevent writes to an adapter that has been detected as removed
by a previous failing read.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/vf.h | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index 7cb1a52..096d33a 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -178,7 +178,11 @@ struct ixgbevf_info {
 
 static inline void ixgbe_write_reg(struct ixgbe_hw *hw, u32 reg, u32 value)
 {
-	writel(value, hw->hw_addr + reg);
+	u8 __iomem *reg_addr = ACCESS_ONCE(hw->hw_addr);
+
+	if (IXGBE_REMOVED(reg_addr))
+		return;
+	writel(value, reg_addr + reg);
 }
 #define IXGBE_WRITE_REG(h, r, v) ixgbe_write_reg(h, r, v)
 
-- 
1.8.3.1
