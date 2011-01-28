From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 v2 2/7] ixgbe: fix variable set but not used warnings by gcc 4.6
Date: Fri, 28 Jan 2011 04:28:58 -0800
Message-ID: <1296217743-30093-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1296217743-30093-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55113 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755140Ab1A1M3I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jan 2011 07:29:08 -0500
In-Reply-To: <1296217743-30093-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Caught with gcc 4.6 -Wunused-but-set-variable

Remove unused napi_vectors variable.

Fix the use of reset_bit in ixgbe_reset_hw_X540()

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    3 ---
 drivers/net/ixgbe/ixgbe_x540.c |    6 +++---
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 602078b..44a1cf0 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4863,16 +4863,13 @@ static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
 {
 	int q_idx, num_q_vectors;
 	struct ixgbe_q_vector *q_vector;
-	int napi_vectors;
 	int (*poll)(struct napi_struct *, int);
 
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
 		num_q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
-		napi_vectors = adapter->num_rx_queues;
 		poll = &ixgbe_clean_rxtx_many;
 	} else {
 		num_q_vectors = 1;
-		napi_vectors = 1;
 		poll = &ixgbe_poll;
 	}
 
diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ixgbe/ixgbe_x540.c
index 3a89239..f2518b0 100644
--- a/drivers/net/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ixgbe/ixgbe_x540.c
@@ -133,17 +133,17 @@ static s32 ixgbe_reset_hw_X540(struct ixgbe_hw *hw)
 	}
 
 	ctrl = IXGBE_READ_REG(hw, IXGBE_CTRL);
-	IXGBE_WRITE_REG(hw, IXGBE_CTRL, (ctrl | IXGBE_CTRL_RST));
+	IXGBE_WRITE_REG(hw, IXGBE_CTRL, (ctrl | reset_bit));
 	IXGBE_WRITE_FLUSH(hw);
 
 	/* Poll for reset bit to self-clear indicating reset is complete */
 	for (i = 0; i < 10; i++) {
 		udelay(1);
 		ctrl = IXGBE_READ_REG(hw, IXGBE_CTRL);
-		if (!(ctrl & IXGBE_CTRL_RST))
+		if (!(ctrl & reset_bit))
 			break;
 	}
-	if (ctrl & IXGBE_CTRL_RST) {
+	if (ctrl & reset_bit) {
 		status = IXGBE_ERR_RESET_FAILED;
 		hw_dbg(hw, "Reset polling failed to complete.\n");
 	}
-- 
1.7.3.5

