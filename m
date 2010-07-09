From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] ac3200: fix error path
Date: Fri,  9 Jul 2010 16:28:09 +0400
Message-ID: <1278678489-7053-1-git-send-email-segooon@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:56355 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755855Ab0GIM20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 08:28:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not call free_irq() if request_irq() failed.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/ac3200.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ac3200.c b/drivers/net/ac3200.c
index b9115a7..5181e93 100644
--- a/drivers/net/ac3200.c
+++ b/drivers/net/ac3200.c
@@ -211,7 +211,7 @@ static int __init ac_probe1(int ioaddr, struct net_device *dev)
 	retval = request_irq(dev->irq, ei_interrupt, 0, DRV_NAME, dev);
 	if (retval) {
 		printk (" nothing! Unable to get IRQ %d.\n", dev->irq);
-		goto out1;
+		goto out;
 	}
 
 	printk(" IRQ %d, %s port\n", dev->irq, port_name[dev->if_port]);
-- 
1.7.0.4

