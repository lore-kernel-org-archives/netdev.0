From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 6/9] net: r6040: Utilize __napi_schedule_irqoff
Date: Mon,  4 Jul 2016 14:36:06 -0700
Message-ID: <1467668169-31547-7-git-send-email-f.fainelli@gmail.com>
References: <1467668169-31547-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:32879 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932574AbcGDVgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 17:36:19 -0400
Received: by mail-oi0-f66.google.com with SMTP id w141so24984984oia.0
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2016 14:36:19 -0700 (PDT)
In-Reply-To: <1467668169-31547-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are already in hard IRQ context, so we can use
__napi_schedule_irqoff() to save a few operations.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/rdc/r6040.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 96b2d639c3c1..13ff80088268 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -690,7 +690,7 @@ static irqreturn_t r6040_interrupt(int irq, void *dev_id)
 		if (likely(napi_schedule_prep(&lp->napi))) {
 			/* Mask off RX interrupt */
 			misr &= ~(RX_INTS | TX_INTS);
-			__napi_schedule(&lp->napi);
+			__napi_schedule_irqoff(&lp->napi);
 		}
 	}
 
-- 
2.7.4
