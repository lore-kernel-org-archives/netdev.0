From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 5/5] tc35815: Use 0 RxFragSize.MinFrag value for non-packing mode
Date: Thu,  6 Aug 2009 23:41:49 +0900
Message-ID: <1249569709-21403-5-git-send-email-anemo@mba.ocn.ne.jp>
Cc: David Miller <davem@davemloft.net>,
	Ralf Roesch <ralf.roesch@rw-gmbh.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.28.14.163]:56607 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753826AbZHFPbT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2009 11:31:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The datasheet say "When not enabling packing, the MinFrag value must
remain at 0".  Do not set value to RxFragSize register if
TC35815_USE_PACKEDBUFFER disabled.

This is not a bugfix.  No real problem reported on this.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/tc35815.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 564d555..d2ca47f 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -2394,8 +2394,6 @@ static void tc35815_chip_init(struct net_device *dev)
 		tc_writel(DMA_BURST_SIZE, &tr->DMA_Ctl);
 #ifdef TC35815_USE_PACKEDBUFFER
 	tc_writel(RxFrag_EnPack | ETH_ZLEN, &tr->RxFragSize);	/* Packing */
-#else
-	tc_writel(ETH_ZLEN, &tr->RxFragSize);
 #endif
 	tc_writel(0, &tr->TxPollCtr);	/* Batch mode */
 	tc_writel(TX_THRESHOLD, &tr->TxThrsh);
-- 
1.5.6.5

