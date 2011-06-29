From: Dan Carpenter <error27@gmail.com>
Subject: [patch] wanxl: remove a stray irq enable
Date: Wed, 29 Jun 2011 09:29:51 +0300
Message-ID: <20110629062951.GD14591@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:46791 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974Ab1F2Gax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 02:30:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is error path calls unlock_irq() where we haven't disabled the
IRQs.  The comment says that this error path can never happen.

Signed-off-by: Dan Carpenter <error27@gmail.com>
---
This is a static checker fix and I don't have the hardware to test.

diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index 8d7aa43..44b7071 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -284,7 +284,7 @@ static netdev_tx_t wanxl_xmit(struct sk_buff *skb, struct net_device *dev)
                 printk(KERN_DEBUG "%s: transmitter buffer full\n", dev->name);
 #endif
 		netif_stop_queue(dev);
-		spin_unlock_irq(&port->lock);
+		spin_unlock(&port->lock);
 		return NETDEV_TX_BUSY;       /* request packet to be queued */
 	}
 
