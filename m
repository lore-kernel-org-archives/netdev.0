From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1 2/6] net/macb: check if macb_config present
Date: Fri, 24 Jul 2015 21:24:00 +0300
Message-ID: <1437762244-2678-3-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1437762244-2678-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:8422 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753566AbbGXSYI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jul 2015 14:24:08 -0400
In-Reply-To: <1437762244-2678-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 98b5a0f4a228 introduces jumbo frame support, but also it assumes
that macb_config present which is not always true.

The configuration without macb_config fails to boot.

 Unable to handle kernel NULL pointer dereference at virtual address 00000010
 ptbr = 90350000 pgd = 00000000
 Oops: Kernel access of bad area, sig: 11 [#1]
 FRAME_POINTER chip: 0x01f:0x1e82 rev 2
 Modules linked in:
 CPU: 0 PID: 1 Comm: swapper Not tainted 4.2.0-rc3-next-20150723+ #13
 task: 91c26000 ti: 91c28000 task.ti: 91c28000
 PC is at macb_probe+0x140/0x61c

Fixes: 98b5a0f4a228 (net: macb: Add support for jumbo frames)
Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/cadence/macb.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 6980115..7986778 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2885,9 +2885,8 @@ static int macb_probe(struct platform_device *pdev)
 	bp->pclk = pclk;
 	bp->hclk = hclk;
 	bp->tx_clk = tx_clk;
-	if (macb_config->jumbo_max_len) {
+	if (macb_config)
 		bp->jumbo_max_len = macb_config->jumbo_max_len;
-	}
 
 	spin_lock_init(&bp->lock);
 
-- 
2.4.6
