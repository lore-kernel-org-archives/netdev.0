From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 14/17] fm10k: fix incorrect DIR_NEVATIVE bit in 1588 code
Date: Wed, 17 Jun 2015 05:55:01 -0700
Message-ID: <1434545704-112470-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1434545704-112470-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:30799 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756596AbbFQMzW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 08:55:22 -0400
In-Reply-To: <1434545704-112470-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The SYSTIME_CFG.Adjust Direction bit is actually supposed to indicate
that the adjustment is positive. Fix the code to align correctly with
hardware and documentation.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c   | 4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_type.h | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 3b94206..ab81c00 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -1792,8 +1792,8 @@ static s32 fm10k_adjust_systime_pf(struct fm10k_hw *hw, s32 ppb)
 	if (systime_adjust > FM10K_SW_SYSTIME_ADJUST_MASK)
 		return FM10K_ERR_PARAM;
 
-	if (ppb < 0)
-		systime_adjust |= FM10K_SW_SYSTIME_ADJUST_DIR_NEGATIVE;
+	if (ppb > 0)
+		systime_adjust |= FM10K_SW_SYSTIME_ADJUST_DIR_POSITIVE;
 
 	fm10k_write_sw_reg(hw, FM10K_SW_SYSTIME_ADJUST, (u32)systime_adjust);
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_type.h b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
index 4af9668..2a17d82 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_type.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
@@ -369,7 +369,7 @@ struct fm10k_hw;
 /* Registers contained in BAR 4 for Switch management */
 #define FM10K_SW_SYSTIME_ADJUST	0x0224D
 #define FM10K_SW_SYSTIME_ADJUST_MASK		0x3FFFFFFF
-#define FM10K_SW_SYSTIME_ADJUST_DIR_NEGATIVE	0x80000000
+#define FM10K_SW_SYSTIME_ADJUST_DIR_POSITIVE	0x80000000
 #define FM10K_SW_SYSTIME_PULSE(_n)	((_n) + 0x02252)
 
 enum fm10k_int_source {
-- 
2.4.3
