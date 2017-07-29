From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] mv643xx_eth: fix of_irq_to_resource() error check
Date: Sat, 29 Jul 2017 22:18:41 +0300
Message-ID: <20170729191901.922633706@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:37617 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752101AbdG2TTH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 15:19:07 -0400
Received: by mail-lf0-f48.google.com with SMTP id m86so94399933lfi.4
        for <netdev@vger.kernel.org>; Sat, 29 Jul 2017 12:19:06 -0700 (PDT)
Content-Disposition: inline; filename=mv643xx_eth-fix-of_irq_to_resource-error-check.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_irq_to_resource() has recently been  fixed to return negative error #'s
along with 0 in case of failure,  however the Marvell MV643xx Ethernet
driver still only regards 0  as invalid IRQ -- fix it up.

Fixes: 7a4228bbff76 ("of: irq: use of_irq_get() in of_irq_to_resource()")
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net.git' repo.

drivers/net/ethernet/marvell/mv643xx_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net/drivers/net/ethernet/marvell/mv643xx_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ net/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2734,7 +2734,7 @@ static int mv643xx_eth_shared_of_add_por
 	ppd.shared = pdev;
 
 	memset(&res, 0, sizeof(res));
-	if (!of_irq_to_resource(pnp, 0, &res)) {
+	if (of_irq_to_resource(pnp, 0, &res) <= 0) {
 		dev_err(&pdev->dev, "missing interrupt on %s\n", pnp->name);
 		return -EINVAL;
 	}
