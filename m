From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH 6/8] smc9194: Remove unnecessary memset of netdev private data
Date: Thu,  6 May 2010 17:41:31 +0200
Message-ID: <1273160491-13228-1-git-send-email-tklauser@distanz.ch>
Cc: kernel-janitors@vger.kernel.org,
	Tobias Klauser <tklauser@distanz.ch>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:46875 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932097Ab0EFPle (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 11:41:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory for the private data is allocated using kzalloc in
alloc_etherdev (or alloc_netdev_mq respectively) so there is no need to
set it to 0 again.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/smc9194.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/smc9194.c b/drivers/net/smc9194.c
index e94521c..d76c815 100644
--- a/drivers/net/smc9194.c
+++ b/drivers/net/smc9194.c
@@ -1042,9 +1042,6 @@ static int __init smc_probe(struct net_device *dev, int ioaddr)
 	*/
 	printk("ADDR: %pM\n", dev->dev_addr);
 
-	/* set the private data to zero by default */
-	memset(netdev_priv(dev), 0, sizeof(struct smc_local));
-
 	/* Grab the IRQ */
       	retval = request_irq(dev->irq, smc_interrupt, 0, DRV_NAME, dev);
       	if (retval) {
-- 
1.6.3.3

