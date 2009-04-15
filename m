From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 5/5] declance: convert to net_device_ops
Date: Wed, 15 Apr 2009 08:30:25 +0400
Message-ID: <1239769825-12413-5-git-send-email-a.beregalov@gmail.com>
References: <1239769825-12413-1-git-send-email-a.beregalov@gmail.com>
 <1239769825-12413-2-git-send-email-a.beregalov@gmail.com>
 <1239769825-12413-3-git-send-email-a.beregalov@gmail.com>
 <1239769825-12413-4-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.187]:25628 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbZDOEak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 00:30:40 -0400
Received: by fk-out-0910.google.com with SMTP id 18so1253680fkq.5
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2009 21:30:39 -0700 (PDT)
In-Reply-To: <1239769825-12413-4-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/declance.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/declance.c b/drivers/net/declance.c
index 861c867..b62405a 100644
--- a/drivers/net/declance.c
+++ b/drivers/net/declance.c
@@ -1010,6 +1010,17 @@ static void lance_set_multicast_retry(unsigned long _opaque)
 	lance_set_multicast(dev);
 }
 
+static const struct net_device_ops lance_netdev_ops = {
+	.ndo_open		= lance_open,
+	.ndo_stop		= lance_close,
+	.ndo_start_xmit		= lance_start_xmit,
+	.ndo_tx_timeout		= lance_tx_timeout,
+	.ndo_set_multicast_list	= lance_set_multicast,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
 static int __init dec_lance_probe(struct device *bdev, const int type)
 {
 	static unsigned version_printed;
@@ -1223,12 +1234,8 @@ static int __init dec_lance_probe(struct device *bdev, const int type)
 
 	printk(", addr = %pM, irq = %d\n", dev->dev_addr, dev->irq);
 
-	dev->open = &lance_open;
-	dev->stop = &lance_close;
-	dev->hard_start_xmit = &lance_start_xmit;
-	dev->tx_timeout = &lance_tx_timeout;
+	dev->netdev_ops = &lance_netdev_ops;
 	dev->watchdog_timeo = 5*HZ;
-	dev->set_multicast_list = &lance_set_multicast;
 
 	/* lp->ll is the location of the registers for lance card */
 	lp->ll = ll;
-- 
1.6.2.3

