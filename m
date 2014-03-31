From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/13] ixgbevf: Change ixgbe_read_reg to ixgbevf_read_reg
Date: Mon, 31 Mar 2014 16:34:52 -0700
Message-ID: <1396308899-20926-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42191 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751633AbaCaXgK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2014 19:36:10 -0400
In-Reply-To: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Change the ixgbe_read_reg function name to ixgbevf_read_reg to
avoid a namespace clash with the ixgbe driver. This will allow
ixgbe to take its register read function out-of-line to reduce
memory footprint.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      | 8 ++++----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 4 ++--
 drivers/net/ethernet/intel/ixgbevf/vf.h           | 6 +++---
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index b2d0023..1baecb6 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -540,10 +540,10 @@ static bool reg_pattern_test(struct ixgbevf_adapter *adapter, u64 *data,
 		return true;
 	}
 	for (pat = 0; pat < ARRAY_SIZE(register_test_patterns); pat++) {
-		before = ixgbe_read_reg(&adapter->hw, reg);
+		before = ixgbevf_read_reg(&adapter->hw, reg);
 		ixgbe_write_reg(&adapter->hw, reg,
 				register_test_patterns[pat] & write);
-		val = ixgbe_read_reg(&adapter->hw, reg);
+		val = ixgbevf_read_reg(&adapter->hw, reg);
 		if (val != (register_test_patterns[pat] & write & mask)) {
 			hw_dbg(&adapter->hw,
 			       "pattern test reg %04X failed: got 0x%08X expected 0x%08X\n",
@@ -567,9 +567,9 @@ static bool reg_set_and_check(struct ixgbevf_adapter *adapter, u64 *data,
 		*data = 1;
 		return true;
 	}
-	before = ixgbe_read_reg(&adapter->hw, reg);
+	before = ixgbevf_read_reg(&adapter->hw, reg);
 	ixgbe_write_reg(&adapter->hw, reg, write & mask);
-	val = ixgbe_read_reg(&adapter->hw, reg);
+	val = ixgbevf_read_reg(&adapter->hw, reg);
 	if ((write & mask) != (val & mask)) {
 		pr_err("set/check reg %04X test failed: got 0x%08X expected 0x%08X\n",
 		       reg, (val & mask), write & mask);
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index a50e892..5d93759 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -124,12 +124,12 @@ static void ixgbevf_check_remove(struct ixgbe_hw *hw, u32 reg)
 		ixgbevf_remove_adapter(hw);
 		return;
 	}
-	value = ixgbe_read_reg(hw, IXGBE_VFSTATUS);
+	value = ixgbevf_read_reg(hw, IXGBE_VFSTATUS);
 	if (value == IXGBE_FAILED_READ_REG)
 		ixgbevf_remove_adapter(hw);
 }
 
-u32 ixgbe_read_reg(struct ixgbe_hw *hw, u32 reg)
+u32 ixgbevf_read_reg(struct ixgbe_hw *hw, u32 reg)
 {
 	u8 __iomem *reg_addr = ACCESS_ONCE(hw->hw_addr);
 	u32 value;
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index 096d33a..3061d18 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -186,8 +186,8 @@ static inline void ixgbe_write_reg(struct ixgbe_hw *hw, u32 reg, u32 value)
 }
 #define IXGBE_WRITE_REG(h, r, v) ixgbe_write_reg(h, r, v)
 
-u32 ixgbe_read_reg(struct ixgbe_hw *hw, u32 reg);
-#define IXGBE_READ_REG(h, r) ixgbe_read_reg(h, r)
+u32 ixgbevf_read_reg(struct ixgbe_hw *hw, u32 reg);
+#define IXGBE_READ_REG(h, r) ixgbevf_read_reg(h, r)
 
 static inline void ixgbe_write_reg_array(struct ixgbe_hw *hw, u32 reg,
 					  u32 offset, u32 value)
@@ -199,7 +199,7 @@ static inline void ixgbe_write_reg_array(struct ixgbe_hw *hw, u32 reg,
 static inline u32 ixgbe_read_reg_array(struct ixgbe_hw *hw, u32 reg,
 					u32 offset)
 {
-	return ixgbe_read_reg(hw, reg + (offset << 2));
+	return ixgbevf_read_reg(hw, reg + (offset << 2));
 }
 #define IXGBE_READ_REG_ARRAY(h, r, o) ixgbe_read_reg_array(h, r, o)
 
-- 
1.9.0
