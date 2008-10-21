From: roel kluin <roel.kluin@gmail.com>
Subject: [PATCH] AX88796: ax_probe() fix irq assignment
Date: Tue, 21 Oct 2008 01:44:02 -0400
Message-ID: <48FD6C22.8030607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ben-linux@fluff.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:29186 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822AbYJTXoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 19:44:08 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1055380nfc.21
        for <netdev@vger.kernel.org>; Mon, 20 Oct 2008 16:44:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev->irq is unsigned

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index 4207d6e..9a314d8 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -838,12 +838,12 @@ static int ax_probe(struct platform_device *pdev)
 
 	/* find the platform resources */
 
-	dev->irq  = platform_get_irq(pdev, 0);
-	if (dev->irq < 0) {
+	ret  = platform_get_irq(pdev, 0);
+	if (ret < 0) {
 		dev_err(&pdev->dev, "no IRQ specified\n");
-		ret = -ENXIO;
 		goto exit_mem;
 	}
+	dev->irq = ret;
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (res == NULL) {
