From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/8] fm10k: do not clear global mailbox interrupt bits
Date: Sun,  8 Jan 2017 02:10:30 -0800
Message-ID: <20170108101034.119851-5-jeffrey.t.kirsher@intel.com>
References: <20170108101034.119851-1-jeffrey.t.kirsher@intel.com>
Cc: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jacob Keller <jacob.e.keller@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:12541 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1162177AbdAHKKl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Jan 2017 05:10:41 -0500
In-Reply-To: <20170108101034.119851-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>

Partially revert commit 5e93cbadd3e9 ("fm10k: Reset mailbox global
interrupts", 2016-06-07)

The register bits related to this commit are now solely being handled by
the IES API. Recent changes in the IES API will allow an automatic
recovery from improper handling of these bits.

Signed-off-by: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 23fb319..40ee024 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -72,10 +72,6 @@ static s32 fm10k_reset_hw_pf(struct fm10k_hw *hw)
 	fm10k_write_flush(hw);
 	udelay(FM10K_RESET_TIMEOUT);
 
-	/* Reset mailbox global interrupts */
-	reg = FM10K_MBX_GLOBAL_REQ_INTERRUPT | FM10K_MBX_GLOBAL_ACK_INTERRUPT;
-	fm10k_write_reg(hw, FM10K_GMBX, reg);
-
 	/* Verify we made it out of reset */
 	reg = fm10k_read_reg(hw, FM10K_IP);
 	if (!(reg & FM10K_IP_NOTINRESET))
-- 
2.9.3
