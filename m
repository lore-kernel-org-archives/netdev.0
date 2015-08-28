From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/2] ravb: propagate platform_get_irq() error upstream
Date: Fri, 28 Aug 2015 16:55:10 +0300
Message-ID: <1625516.DmSERANoIv@wasted.cogentembedded.com>
References: <9944836.IRPmWk4iN8@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org, horms@verge.net.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:35385 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568AbbH1NzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 09:55:13 -0400
Received: by lbcbn3 with SMTP id bn3so30444339lbc.2
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 06:55:12 -0700 (PDT)
In-Reply-To: <9944836.IRPmWk4iN8@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver overrides the error returned by platform_get_irq() with -ENODEV
which e.g. precludes the deferred  probing from working. Propagate the real
error code to the driver core instead.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/ravb_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net/drivers/net/ethernet/renesas/ravb_main.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/ravb_main.c
+++ net/drivers/net/ethernet/renesas/ravb_main.c
@@ -1643,7 +1643,7 @@ static int ravb_probe(struct platform_de
 	ndev->dma = -1;
 	irq = platform_get_irq(pdev, 0);
 	if (irq < 0) {
-		error = -ENODEV;
+		error = irq;
 		goto out_release;
 	}
 	ndev->irq = irq;
