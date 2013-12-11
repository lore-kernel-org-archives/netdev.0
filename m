From: Soren Brinkmann <soren.brinkmann@xilinx.com>
Subject: [PATCH] net: macb: Fix build warning
Date: Tue, 10 Dec 2013 20:57:57 -0800
Message-ID: <1386737877-16531-1-git-send-email-soren.brinkmann@xilinx.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	=?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
	kbuild test robot <fengguang.wu@intel.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:57569 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751058Ab3LKE6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 23:58:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When adjusting the link speed, the target frequency is determined by a
'swith (LINK_SPEED)' statement, that assigns the target rate only for
valid and expected LINK_SPEED values. This incomplete switch statement
leads to the following build warning:
     drivers/net/ethernet/cadence/macb.c: In function 'macb_handle_link_change':
  >> drivers/net/ethernet/cadence/macb.c:241:14: warning: 'rate' may be used uninitialized in this function [-Wmaybe-uninitialized]
        netdev_warn(dev, "unable to generate target frequency: %ld Hz\n",
                   ^
     drivers/net/ethernet/cadence/macb.c:215:13: note: 'rate' was declared here
       long ferr, rate, rate_rounded;

Fixing this by bailing out of that function in the switch's default case
before the rate variable is used.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
---
 drivers/net/ethernet/cadence/macb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 419529a9309d..3190d38e16fb 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -225,7 +225,7 @@ static void macb_set_tx_clk(struct clk *clk, int speed, struct net_device *dev)
 		rate = 125000000;
 		break;
 	default:
-		break;
+		return;
 	}
 
 	rate_rounded = clk_round_rate(clk, rate);
-- 
1.8.5.1
