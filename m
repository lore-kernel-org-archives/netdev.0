From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/12] igb: add argument names to mailbox op function declarations
Date: Wed,  9 Aug 2017 14:47:39 -0700
Message-ID: <20170809214746.28139-6-jeffrey.t.kirsher@intel.com>
References: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
Cc: Greg Edwards <gedwards@ddn.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:31102 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752331AbdHIVr4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Aug 2017 17:47:56 -0400
In-Reply-To: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Edwards <gedwards@ddn.com>

Signed-off-by: Greg Edwards <gedwards@ddn.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_hw.h  | 15 ++++++++-------
 drivers/net/ethernet/intel/igb/e1000_mbx.h | 12 ++++++------
 2 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_hw.h b/drivers/net/ethernet/intel/igb/e1000_hw.h
index 2fb2213cd562..fd7865a8d2e3 100644
--- a/drivers/net/ethernet/intel/igb/e1000_hw.h
+++ b/drivers/net/ethernet/intel/igb/e1000_hw.h
@@ -491,13 +491,14 @@ struct e1000_fc_info {
 
 struct e1000_mbx_operations {
 	s32 (*init_params)(struct e1000_hw *hw);
-	s32 (*read)(struct e1000_hw *, u32 *, u16,  u16);
-	s32 (*write)(struct e1000_hw *, u32 *, u16, u16);
-	s32 (*read_posted)(struct e1000_hw *, u32 *, u16,  u16);
-	s32 (*write_posted)(struct e1000_hw *, u32 *, u16, u16);
-	s32 (*check_for_msg)(struct e1000_hw *, u16);
-	s32 (*check_for_ack)(struct e1000_hw *, u16);
-	s32 (*check_for_rst)(struct e1000_hw *, u16);
+	s32 (*read)(struct e1000_hw *hw, u32 *msg, u16 size, u16 mbx_id);
+	s32 (*write)(struct e1000_hw *hw, u32 *msg, u16 size, u16 mbx_id);
+	s32 (*read_posted)(struct e1000_hw *hw, u32 *msg, u16 size, u16 mbx_id);
+	s32 (*write_posted)(struct e1000_hw *hw, u32 *msg, u16 size,
+			    u16 mbx_id);
+	s32 (*check_for_msg)(struct e1000_hw *hw, u16 mbx_id);
+	s32 (*check_for_ack)(struct e1000_hw *hw, u16 mbx_id);
+	s32 (*check_for_rst)(struct e1000_hw *hw, u16 mbx_id);
 };
 
 struct e1000_mbx_stats {
diff --git a/drivers/net/ethernet/intel/igb/e1000_mbx.h b/drivers/net/ethernet/intel/igb/e1000_mbx.h
index 3e7fed73df15..73d90aeb48b2 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mbx.h
+++ b/drivers/net/ethernet/intel/igb/e1000_mbx.h
@@ -67,11 +67,11 @@
 
 #define E1000_PF_CONTROL_MSG	0x0100 /* PF control message */
 
-s32 igb_read_mbx(struct e1000_hw *, u32 *, u16, u16);
-s32 igb_write_mbx(struct e1000_hw *, u32 *, u16, u16);
-s32 igb_check_for_msg(struct e1000_hw *, u16);
-s32 igb_check_for_ack(struct e1000_hw *, u16);
-s32 igb_check_for_rst(struct e1000_hw *, u16);
-s32 igb_init_mbx_params_pf(struct e1000_hw *);
+s32 igb_read_mbx(struct e1000_hw *hw, u32 *msg, u16 size, u16 mbx_id);
+s32 igb_write_mbx(struct e1000_hw *hw, u32 *msg, u16 size, u16 mbx_id);
+s32 igb_check_for_msg(struct e1000_hw *hw, u16 mbx_id);
+s32 igb_check_for_ack(struct e1000_hw *hw, u16 mbx_id);
+s32 igb_check_for_rst(struct e1000_hw *hw, u16 mbx_id);
+s32 igb_init_mbx_params_pf(struct e1000_hw *hw);
 
 #endif /* _E1000_MBX_H_ */
-- 
2.13.3
