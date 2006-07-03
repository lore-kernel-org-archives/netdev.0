From: Brice Goglin <brice@myri.com>
Subject: [patch 3/4] myri10ge - Use dev_info() when printing parameters after
 probe
Date: Mon, 03 Jul 2006 18:41:30 -0400
Message-ID: <44A99D1A.5080301@myri.com>
References: <20060703220230.606593000@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:25786 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1751110AbWGCWld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2006 18:41:33 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060703220230.606593000@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Displaying the interface name when listing the device parameters
at the end of myri10ge_probe is not a good idea since udev might
rename the interface soon afterwards.
Print the bus id instead, using dev_info().

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

Index: linux-mm/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-mm.orig/drivers/net/myri10ge/myri10ge.c	2006-07-03 16:02:52.000000000 -0400
+++ linux-mm/drivers/net/myri10ge/myri10ge.c	2006-07-03 16:04:15.000000000 -0400
@@ -2734,11 +2734,10 @@
 		dev_err(&pdev->dev, "register_netdev failed: %d\n", status);
 		goto abort_with_irq;
 	}
-
-	printk(KERN_INFO "myri10ge: %s: %s IRQ %d, tx bndry %d, fw %s, WC %s\n",
-	       netdev->name, (mgp->msi_enabled ? "MSI" : "xPIC"),
-	       pdev->irq, mgp->tx.boundary, mgp->fw_name,
-	       (mgp->mtrr >= 0 ? "Enabled" : "Disabled"));
+	dev_info(dev, "%s IRQ %d, tx bndry %d, fw %s, WC %s\n",
+		 (mgp->msi_enabled ? "MSI" : "xPIC"),
+		 pdev->irq, mgp->tx.boundary, mgp->fw_name,
+		 (mgp->mtrr >= 0 ? "Enabled" : "Disabled"));
 
 	return 0;
 


