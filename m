From: Jirka Pirko <jirka@pirko.cz>
Subject: [PATCH] tokenring/3c359.c: Fix error message when allocating
 tx_ring
Date: Sun, 23 Nov 2008 21:22:22 +0100
Message-ID: <20081123212222.45121ffe@jirka.pirko.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, davem@davemloft.net
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from onyx.pirko.cz ([84.16.102.30]:57260 "EHLO onyx.pirko.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751811AbYKWUWb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Nov 2008 15:22:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pointed out by Joe Perches. Error message after tx_ring allocation check was
wrong.

Signed-off-by: Jirka Pirko <jirka@jirka.pirko.cz>
---
 drivers/net/tokenring/3c359.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index f832f9b..46fb308 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -638,7 +638,7 @@ static int xl_open(struct net_device *dev)
 	/* These MUST be on 8 byte boundaries */
 	xl_priv->xl_tx_ring = kzalloc((sizeof(struct xl_tx_desc) * XL_TX_RING_SIZE) + 7, GFP_DMA | GFP_KERNEL);
 	if (xl_priv->xl_tx_ring == NULL) {
-		printk(KERN_WARNING "%s: Not enough memory to allocate rx buffers.\n",
+		printk(KERN_WARNING "%s: Not enough memory to allocate tx buffers.\n",
 				     dev->name);
 		free_irq(dev->irq,dev);
 		return -ENOMEM;
-- 
1.5.4.3

