From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] greth: Use return value of register_netdev
Date: Tue, 17 Aug 2010 18:11:24 +0200
Message-ID: <1282061484-19377-1-git-send-email-tklauser@distanz.ch>
Cc: kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:34142 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751856Ab0HQQL0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Aug 2010 12:11:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the return value provided by register_netdev on error instead of
hard setting it to -ENOMEM.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/greth.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index f15c64f..fbeaf70 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -1547,10 +1547,10 @@ static int __devinit greth_of_probe(struct platform_device *ofdev, const struct
 	dev->netdev_ops = &greth_netdev_ops;
 	dev->ethtool_ops = &greth_ethtool_ops;
 
-	if (register_netdev(dev)) {
+	err = register_netdev(dev);
+	if (err) {
 		if (netif_msg_probe(greth))
 			dev_err(greth->dev, "netdevice registration failed.\n");
-		err = -ENOMEM;
 		goto error5;
 	}
 
-- 
1.7.0.4

