From: Mark Repka <repkam09@gmail.com>
Subject: [net-next] Fix hardcoded ni65 interrupt name to use system device value
Date: Sat, 21 Sep 2013 19:32:19 +0000
Message-ID: <1379791939-23887-1-git-send-email-repkam09@gmail.com>
Cc: Mark Repka <repkam09@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:47084 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899Ab3IUTch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 15:32:37 -0400
Received: by mail-qa0-f49.google.com with SMTP id k15so542330qaq.15
        for <netdev@vger.kernel.org>; Sat, 21 Sep 2013 12:32:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ni65 interrupt handler was using the hard-coded name which would make it difficult to tell where the interrupt came from. Changed to use the device name that made the interrupt.

Signed-off-by: Mark Repka <repkam09@gmail.com>
---
 drivers/net/ethernet/amd/ni65.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/ni65.c b/drivers/net/ethernet/amd/ni65.c
index 1cf33ad..00cb6db 100644
--- a/drivers/net/ethernet/amd/ni65.c
+++ b/drivers/net/ethernet/amd/ni65.c
@@ -295,7 +295,7 @@ static int ni65_open(struct net_device *dev)
 {
 	struct priv *p = dev->ml_priv;
 	int irqval = request_irq(dev->irq, ni65_interrupt,0,
-                        cards[p->cardno].cardname,dev);
+                       dev->name,dev);
 	if (irqval) {
 		printk(KERN_ERR "%s: unable to get IRQ %d (irqval=%d).\n",
 		          dev->name,dev->irq, irqval);
-- 
1.8.1.4
