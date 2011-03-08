From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 12/14] ixgbe: improve logic in ixgbe_init_mbx_params_pf
Date: Mon,  7 Mar 2011 18:25:06 -0800
Message-ID: <1299551108-23663-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55556 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755993Ab1CHC0H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 21:26:07 -0500
In-Reply-To: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Use if/then instead of an all-inclusive case statement.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_mbx.c |   27 ++++++++++++---------------
 1 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_mbx.c b/drivers/net/ixgbe/ixgbe_mbx.c
index 2acacfa..3cf8aec 100644
--- a/drivers/net/ixgbe/ixgbe_mbx.c
+++ b/drivers/net/ixgbe/ixgbe_mbx.c
@@ -448,23 +448,20 @@ void ixgbe_init_mbx_params_pf(struct ixgbe_hw *hw)
 {
 	struct ixgbe_mbx_info *mbx = &hw->mbx;
 
-	switch (hw->mac.type) {
-	case ixgbe_mac_82599EB:
-	case ixgbe_mac_X540:
-		mbx->timeout = 0;
-		mbx->usec_delay = 0;
+	if (hw->mac.type != ixgbe_mac_82599EB &&
+	    hw->mac.type != ixgbe_mac_X540)
+		return;
 
-		mbx->size = IXGBE_VFMAILBOX_SIZE;
+	mbx->timeout = 0;
+	mbx->udelay = 0;
 
-		mbx->stats.msgs_tx = 0;
-		mbx->stats.msgs_rx = 0;
-		mbx->stats.reqs = 0;
-		mbx->stats.acks = 0;
-		mbx->stats.rsts = 0;
-		break;
-	default:
-		break;
-	}
+	mbx->stats.msgs_tx = 0;
+	mbx->stats.msgs_rx = 0;
+	mbx->stats.reqs = 0;
+	mbx->stats.acks = 0;
+	mbx->stats.rsts = 0;
+
+	mbx->size = IXGBE_VFMAILBOX_SIZE;
 }
 #endif /* CONFIG_PCI_IOV */
 
-- 
1.7.4

