From: Jirka Pirko <jirka@pirko.cz>
Subject: [PATCH] tokenring/3c359.c: fix allocation null check
Date: Sun, 23 Nov 2008 20:28:50 +0100
Message-ID: <20081123202850.372eb7cb@jirka.pirko.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, davem@davemloft.net
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from onyx.pirko.cz ([84.16.102.30]:49539 "EHLO onyx.pirko.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757997AbYKWUAS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Nov 2008 15:00:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed type when allocating rx_ring, tx_ring was checked for null instead.

Signed-off-by: Jirka Pirko <jirka@pirko.cz>
---
 drivers/net/tokenring/3c359.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index bf62132..f832f9b 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -644,7 +644,7 @@ static int xl_open(struct net_device *dev)
 		return -ENOMEM;
 	}
 	xl_priv->xl_rx_ring = kzalloc((sizeof(struct xl_rx_desc) * XL_RX_RING_SIZE) +7, GFP_DMA | GFP_KERNEL);
-	if (xl_priv->xl_tx_ring == NULL) {
+	if (xl_priv->xl_rx_ring == NULL) {
 		printk(KERN_WARNING "%s: Not enough memory to allocate rx buffers.\n",
 				     dev->name);
 		free_irq(dev->irq,dev);
-- 
1.5.4.3


