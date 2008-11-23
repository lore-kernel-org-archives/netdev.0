From: Jirka Pirko <jirka@pirko.cz>
Subject: [PATCH] tokenring/3c359.c: Prevent possible mem leak when open
 failed
Date: Sun, 23 Nov 2008 21:44:10 +0100
Message-ID: <20081123214410.44810f99@jirka.pirko.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, davem@davemloft.net
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from onyx.pirko.cz ([84.16.102.30]:42105 "EHLO onyx.pirko.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750818AbYKWUoQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Nov 2008 15:44:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Freeing previously allocated buffers in case of error.

Signed-off-by: Jirka Pirko <jirka@pirko.cz>
---
 drivers/net/tokenring/3c359.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index 46fb308..4bb9ca8 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -669,6 +669,8 @@ static int xl_open(struct net_device *dev)
 	if (i==0) { 
 		printk(KERN_WARNING "%s: Not enough memory to allocate rx buffers. Adapter disabled \n",dev->name) ; 
 		free_irq(dev->irq,dev) ; 
+		kfree(xl_priv->xl_tx_ring);
+		kfree(xl_priv->xl_rx_ring);
 		return -EIO ; 
 	} 
 
-- 
1.5.4.3

