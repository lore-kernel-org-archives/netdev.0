From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 4/5] tc35815: Fix rx_missed_errors count
Date: Thu,  6 Aug 2009 23:41:48 +0900
Message-ID: <1249569709-21403-4-git-send-email-anemo@mba.ocn.ne.jp>
Cc: David Miller <davem@davemloft.net>,
	Ralf Roesch <ralf.roesch@rw-gmbh.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.28.14.163]:56599 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751509AbZHFPbT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2009 11:31:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Miss_Cnt register is cleared by reading.  Accumulate its value to
rx_missed_errors count.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/tc35815.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 1adb150..564d555 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -2139,7 +2139,7 @@ static struct net_device_stats *tc35815_get_stats(struct net_device *dev)
 		(struct tc35815_regs __iomem *)dev->base_addr;
 	if (netif_running(dev))
 		/* Update the statistics from the device registers. */
-		dev->stats.rx_missed_errors = tc_readl(&tr->Miss_Cnt);
+		dev->stats.rx_missed_errors += tc_readl(&tr->Miss_Cnt);
 
 	return &dev->stats;
 }
-- 
1.5.6.5

