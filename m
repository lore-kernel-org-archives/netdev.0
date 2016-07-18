From: zyjzyj2000@gmail.com
Subject: [PATCH 1/1] ixgbevf: avoid checking hang when performing hardware reset
Date: Mon, 18 Jul 2016 21:44:49 +0800
Message-ID: <1468849489-8407-1-git-send-email-zyjzyj2000@gmail.com>
Cc: Zhu Yanjun <zyjzyj2000@gmail.com>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [111.193.68.65] ([111.193.68.65]:45270 "EHLO mail.zhuyj.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751251AbcGRNuc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 09:50:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>

When performing hardware reset, it is not necessary to check hang.
Or else, the call trace will appear.

Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index acc2401..d563d24 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2792,9 +2792,14 @@ static void ixgbevf_reset_subtask(struct ixgbevf_adapter *adapter)
 static void ixgbevf_check_hang_subtask(struct ixgbevf_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
 	u32 eics = 0;
 	int i;
 
+	/* When performing hardware reset, unnecessary to check hang. */
+	if (mbx->ops.check_for_rst(hw))
+		return;
+
 	/* If we're down or resetting, just bail */
 	if (test_bit(__IXGBEVF_DOWN, &adapter->state) ||
 	    test_bit(__IXGBEVF_RESETTING, &adapter->state))
-- 
2.7.4
