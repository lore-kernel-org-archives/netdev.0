From: Dan Carpenter <error27@gmail.com>
Subject: [patch] arcnet: fix signed bug in probe function
Date: Sat, 17 Jul 2010 19:21:28 +0200
Message-ID: <20100717172127.GI17585@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61343 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756047Ab0GQRXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jul 2010 13:23:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

probe_irq_off() returns the first irq found or if two irqs are found
then it returns the negative of the first irq found.  We can cast
dev->irq to an int so that the test for negative values works.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/arcnet/com20020-isa.c b/drivers/net/arcnet/com20020-isa.c
index 0402da3..3727282 100644
--- a/drivers/net/arcnet/com20020-isa.c
+++ b/drivers/net/arcnet/com20020-isa.c
@@ -90,14 +90,14 @@ static int __init com20020isa_probe(struct net_device *dev)
 		outb(0, _INTMASK);
 		dev->irq = probe_irq_off(airqmask);
 
-		if (dev->irq <= 0) {
+		if ((int)dev->irq <= 0) {
 			BUGMSG(D_INIT_REASONS, "Autoprobe IRQ failed first time\n");
 			airqmask = probe_irq_on();
 			outb(NORXflag, _INTMASK);
 			udelay(5);
 			outb(0, _INTMASK);
 			dev->irq = probe_irq_off(airqmask);
-			if (dev->irq <= 0) {
+			if ((int)dev->irq <= 0) {
 				BUGMSG(D_NORMAL, "Autoprobe IRQ failed.\n");
 				err = -ENODEV;
 				goto out;
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index 4cb4018..eb27976 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -213,7 +213,7 @@ static int __init com90io_probe(struct net_device *dev)
 		outb(0, _INTMASK);
 		dev->irq = probe_irq_off(airqmask);
 
-		if (dev->irq <= 0) {
+		if ((int)dev->irq <= 0) {
 			BUGMSG(D_INIT_REASONS, "Autoprobe IRQ failed\n");
 			goto err_out;
 		}
