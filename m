From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 02/17] mv643xx_eth: get rid of IRQF_SAMPLE_RANDOM
Date: Wed,  3 Sep 2008 14:29:29 +0200
Message-ID: <1220444984-20150-3-git-send-email-buytenh@wantstofly.org>
References: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Cc: Dale Farnsworth <dale@farnsworth.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:52887 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752136AbYICM3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 08:29:46 -0400
In-Reply-To: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using IRQF_SAMPLE_RANDOM for the mv643xx_eth interrupt handler
significantly increases interrupt processing overhead, so get rid
of it.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index ad2ae93..8c812c3 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2004,8 +2004,7 @@ static int mv643xx_eth_open(struct net_device *dev)
 	rdl(mp, INT_CAUSE_EXT(mp->port_num));
 
 	err = request_irq(dev->irq, mv643xx_eth_irq,
-			  IRQF_SHARED | IRQF_SAMPLE_RANDOM,
-			  dev->name, dev);
+			  IRQF_SHARED, dev->name, dev);
 	if (err) {
 		dev_printk(KERN_ERR, &dev->dev, "can't assign irq\n");
 		return -EAGAIN;
-- 
1.5.6.4

