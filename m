From: Nicolas Kaiser <nikai@nikai.net>
Subject: [PATCH] drivers/net: sgiseeq: fix return on error
Date: Tue, 26 Oct 2010 18:45:05 +0200
Message-ID: <20101026184505.077246a2@absol.kitzblitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webhosting01.bon.m2soft.com ([195.38.20.32]:55492 "EHLO
	webhosting01.bon.m2soft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754809Ab0JZQrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 12:47:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we continue on error, we'd likely free the IRQ that we
didn't get, right?

Signed-off-by: Nicolas Kaiser <nikai@nikai.net>
---
 drivers/net/sgiseeq.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index 9265315..3a0cc63 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -531,7 +531,7 @@ static int sgiseeq_open(struct net_device *dev)
 
 	if (request_irq(irq, sgiseeq_interrupt, 0, sgiseeqstr, dev)) {
 		printk(KERN_ERR "Seeq8003: Can't get irq %d\n", dev->irq);
-		err = -EAGAIN;
+		return -EAGAIN;
 	}
 
 	err = init_seeq(dev, sp, sregs);
-- 
1.7.2.2
