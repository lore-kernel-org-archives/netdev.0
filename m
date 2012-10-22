From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH v3 1/4] net/macb: fix truncate warnings
Date: Mon, 22 Oct 2012 20:45:31 +0200
Message-ID: <1350931534-8416-2-git-send-email-manabian@gmail.com>
References: <1350931534-8416-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net,
	hskinnemoen@gmail.com, egtvedt@samfundet.no, plagnioj@jcrosoft.com,
	bgat@billgatliff.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:35491 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756046Ab2JVSrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 14:47:19 -0400
Received: by mail-lb0-f174.google.com with SMTP id n3so1873942lbo.19
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2012 11:47:17 -0700 (PDT)
In-Reply-To: <1350931534-8416-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When building macb on x86_64 the following warnings show up:
  drivers/net/ethernet/cadence/macb.c: In function macb_interrupt:
  drivers/net/ethernet/cadence/macb.c:556:4: warning: large integer implicitly truncated to unsigned type [-Woverflow]
  drivers/net/ethernet/cadence/macb.c: In function macb_reset_hw:
  drivers/net/ethernet/cadence/macb.c:792:2: warning: large integer implicitly truncated to unsigned type [-Woverflow]
  drivers/net/ethernet/cadence/macb.c:793:2: warning: large integer implicitly truncated to unsigned type [-Woverflow]
  drivers/net/ethernet/cadence/macb.c:796:2: warning: large integer implicitly truncated to unsigned type [-Woverflow]

Use -1 insted of ~0UL, as done in other places in the driver,
to silence these warnings.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/cadence/macb.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 6c84a11..6a4f499 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -553,7 +553,7 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 	while (status) {
 		/* close possible race with dev_close */
 		if (unlikely(!netif_running(dev))) {
-			macb_writel(bp, IDR, ~0UL);
+			macb_writel(bp, IDR, -1);
 			break;
 		}
 
@@ -789,11 +789,11 @@ static void macb_reset_hw(struct macb *bp)
 	macb_writel(bp, NCR, MACB_BIT(CLRSTAT));
 
 	/* Clear all status flags */
-	macb_writel(bp, TSR, ~0UL);
-	macb_writel(bp, RSR, ~0UL);
+	macb_writel(bp, TSR, -1);
+	macb_writel(bp, RSR, -1);
 
 	/* Disable all interrupts */
-	macb_writel(bp, IDR, ~0UL);
+	macb_writel(bp, IDR, -1);
 	macb_readl(bp, ISR);
 }
 
-- 
1.7.12.4
