From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: [PATCH] mv643xx_eth: Do not modify struct netdev tx_queue_len
Date: Mon, 1 Oct 2007 16:02:18 -0700
Message-ID: <20071001230218.GA27461@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:48284 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751917AbXJAXCU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 19:02:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dale Farnsworth <dale@farnsworth.org>

This driver erroneously zeros dev->tx_queue_len, since
mp->tx_ring_size has not yet been initialized.  Actually,
the driver shouldn't modify tx_queue_len at all and should
leave the value set by alloc_etherdev(), currently 1000.

Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
---
Jeff, this bug was just reported today, or I would have batched
it with the one I sent you last week.  It's an obvious bugfix,
so I'm not going to hold it in my queue.

 drivers/net/mv643xx_eth.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 34288fe..3153356 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1357,7 +1357,6 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 #endif
 
 	dev->watchdog_timeo = 2 * HZ;
-	dev->tx_queue_len = mp->tx_ring_size;
 	dev->base_addr = 0;
 	dev->change_mtu = mv643xx_eth_change_mtu;
 	dev->do_ioctl = mv643xx_eth_do_ioctl;
