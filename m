From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/14] fm10k: don't try to stop queues if we've lost hw_addr
Date: Mon, 29 Aug 2016 02:13:41 -0700
Message-ID: <1472462026-42133-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1472462026-42133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:61654 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932244AbcH2JNv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 05:13:51 -0400
In-Reply-To: <1472462026-42133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

In the event of a surprise remove, we expect the driver to go down,
which includes calling .stop_hw(). However, this function will return an
error because the queues won't appear to cleanly disable. Prevent this
and avoid the unnecessary checks by just returning when
FM10K_REMOVED(hw->hw_addr) is true.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_common.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_common.c b/drivers/net/ethernet/intel/fm10k/fm10k_common.c
index d6baaea..dd95ac4 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_common.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_common.c
@@ -207,6 +207,9 @@ s32 fm10k_disable_queues_generic(struct fm10k_hw *hw, u16 q_cnt)
 	/* clear tx_ready to prevent any false hits for reset */
 	hw->mac.tx_ready = false;
 
+	if (FM10K_REMOVED(hw->hw_addr))
+		return 0;
+
 	/* clear the enable bit for all rings */
 	for (i = 0; i < q_cnt; i++) {
 		reg = fm10k_read_reg(hw, FM10K_TXDCTL(i));
-- 
2.7.4
