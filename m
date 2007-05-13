From: Vitaly Wool <vitalywool@gmail.com>
Subject: [patch/resend] smc911x: fix compilation breakage
Date: Sun, 13 May 2007 18:42:08 +0400
Message-ID: <464723C0.70409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rmk@arm.linux.org.uk
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:25286 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932263AbXEMOmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 May 2007 10:42:35 -0400
Received: by ug-out-1314.google.com with SMTP id 44so1163178uga
        for <netdev@vger.kernel.org>; Sun, 13 May 2007 07:42:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looks like the new version of this patch has been overlooked,
so I'm resending it.

It just adapts the driver to the new IRQ API
according to what Russell has pointed out.

 drivers/net/smc911x.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>

diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index c956141..4b9bdad 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -77,7 +77,6 @@ static const char version[] =
 #include <linux/skbuff.h>
 
 #include <asm/io.h>
-#include <asm/irq.h>
 
 #include "smc911x.h"
 
@@ -2086,12 +2085,11 @@ static int __init smc911x_probe(struct n
 	lp->ctl_rspeed = 100;
 
 	/* Grab the IRQ */
-	retval = request_irq(dev->irq, &smc911x_interrupt, IRQF_SHARED, dev->name, dev);
+	retval = request_irq(dev->irq, &smc911x_interrupt,
+			IRQF_SHARED | IRQF_TRIGGER_FALLING, dev->name, dev);
 	if (retval)
 		goto err_out;
 
-	set_irq_type(dev->irq, IRQT_FALLING);
-
 #ifdef SMC_USE_DMA
 	lp->rxdma = SMC_DMA_REQUEST(dev, smc911x_rx_dma_irq);
 	lp->txdma = SMC_DMA_REQUEST(dev, smc911x_tx_dma_irq);


