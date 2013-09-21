From: Mihir Singh <me@mihirsingh.com>
Subject: [net-next] hp100: replace hardcoded name in /proc/interrupts with interface name
Date: Sat, 21 Sep 2013 18:48:09 +0000
Message-ID: <1379789289-10961-1-git-send-email-me@mihirsingh.com>
Cc: Mihir Singh <me@mihirsingh.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f44.google.com ([209.85.128.44]:60256 "EHLO
	mail-qe0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398Ab3IUSsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 14:48:18 -0400
Received: by mail-qe0-f44.google.com with SMTP id 3so1122686qeb.3
        for <netdev@vger.kernel.org>; Sat, 21 Sep 2013 11:48:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The /proc/interrupts file displays hp100, which is not the accepted style. Printing eth%d is more helpful.

Signed-off-by: Mihir Singh <me@mihirsingh.com>
---
 drivers/net/ethernet/hp/hp100.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index 91227d0..3786009 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -1098,7 +1098,7 @@ static int hp100_open(struct net_device *dev)
 	if (request_irq(dev->irq, hp100_interrupt,
 			lp->bus == HP100_BUS_PCI || lp->bus ==
 			HP100_BUS_EISA ? IRQF_SHARED : 0,
-			"hp100", dev)) {
+			dev->name, dev)) {
 		printk("hp100: %s: unable to get IRQ %d\n", dev->name, dev->irq);
 		return -EAGAIN;
 	}
-- 
1.8.1.2
