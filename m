From: Vitaly Wool <vitalywool@gmail.com>
Subject: [patch] fix smc911x compilation breakage
Date: Mon, 30 Apr 2007 20:57:30 +0400
Message-ID: <46361FFA.8050400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com, rmk@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.185]:26052 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946392AbXD3Q5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 12:57:43 -0400
Received: by mu-out-0910.google.com with SMTP id g7so5790muf
        for <netdev@vger.kernel.org>; Mon, 30 Apr 2007 09:57:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

this is the updated version of smc911x compilation breakage fix.
Hope it's fine now. It just adapts the driver to the new IRQ API
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



