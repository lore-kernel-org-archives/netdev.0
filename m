From: akpm@osdl.org
Subject: [patch 5/7] ep93xx: some minor cleanups to the ep93xx eth driver
Date: Tue, 19 Dec 2006 13:08:48 -0800
Message-ID: <200612192108.kBJL8ndY010501@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, burman.yan@gmail.com,
	rmk@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:35447 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932977AbWLSVJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Dec 2006 16:09:34 -0500
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yan Burman <burman.yan@gmail.com>

Small cleanup in the Cirrus Logic EP93xx ethernet driver: Check for NULL
pointer before dereferencing it instead of after.  Remove unreferenced
variable.

Signed-off-by: Yan Burman <burman.yan@gmail.com>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Russell King <rmk@arm.linux.org.uk>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/arm/ep93xx_eth.c |    4 +---
 1 files changed, 1 insertion(+), 3 deletions(-)

diff -puN drivers/net/arm/ep93xx_eth.c~ep93xx-some-minor-cleanups-to-the-ep93xx-eth-driver drivers/net/arm/ep93xx_eth.c
--- a/drivers/net/arm/ep93xx_eth.c~ep93xx-some-minor-cleanups-to-the-ep93xx-eth-driver
+++ a/drivers/net/arm/ep93xx_eth.c
@@ -780,12 +780,10 @@ static struct ethtool_ops ep93xx_ethtool
 struct net_device *ep93xx_dev_alloc(struct ep93xx_eth_data *data)
 {
 	struct net_device *dev;
-	struct ep93xx_priv *ep;
 
 	dev = alloc_etherdev(sizeof(struct ep93xx_priv));
 	if (dev == NULL)
 		return NULL;
-	ep = netdev_priv(dev);
 
 	memcpy(dev->dev_addr, data->dev_addr, ETH_ALEN);
 
@@ -840,9 +838,9 @@ static int ep93xx_eth_probe(struct platf
 	struct ep93xx_priv *ep;
 	int err;
 
-	data = pdev->dev.platform_data;
 	if (pdev == NULL)
 		return -ENODEV;
+	data = pdev->dev.platform_data;
 
 	dev = ep93xx_dev_alloc(data);
 	if (dev == NULL) {
_
