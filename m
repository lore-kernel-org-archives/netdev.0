From: Lee Jones <lee.jones@linaro.org>
Subject: [PATCH 04/15] drivers/net: Do not free an IRQ if its request failed
Date: Thu, 19 Apr 2012 21:36:33 +0100
Message-ID: <1334867804-31942-5-git-send-email-lee.jones@linaro.org>
References: <1334867804-31942-1-git-send-email-lee.jones@linaro.org>
Cc: Lee Jones <lee.jones@linaro.org>, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org, arnd@arndb.de,
	linus.walleij@stericsson.com, grant.likely@secretlab.ca,
	cjb@laptop.org, linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:41950 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932324Ab2DSUhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 16:37:05 -0400
Received: by wgbdr13 with SMTP id dr13so8993810wgb.1
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 13:37:04 -0700 (PDT)
In-Reply-To: <1334867804-31942-1-git-send-email-lee.jones@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refrain from attempting to free an interrupt line if the request
fails and hence, there is no IRQ to free.

CC: netdev@vger.kernel.org
Signed-off-by: Lee Jones <lee.jones@linaro.org>
---
 drivers/net/ethernet/smsc/smsc911x.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 4a69710..f17a76e 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2382,7 +2382,6 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	pdata = netdev_priv(dev);
-
 	dev->irq = irq_res->start;
 	irq_flags = irq_res->flags & IRQF_TRIGGER_MASK;
 	pdata->ioaddr = ioremap_nocache(res->start, res_size);
@@ -2446,7 +2445,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	if (retval) {
 		SMSC_WARN(pdata, probe,
 			  "Unable to claim requested irq: %d", dev->irq);
-		goto out_free_irq;
+		goto out_disable_resources;
 	}
 
 	retval = register_netdev(dev);
-- 
1.7.9.1
