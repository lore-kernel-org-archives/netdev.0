From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH] irda: convert pxaficp device to net_device_ops
Date: Sat, 18 Apr 2009 17:44:26 +0400
Message-ID: <1240062266-4339-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:20222 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752819AbZDRNol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 09:44:41 -0400
Received: by fg-out-1718.google.com with SMTP id 16so227857fgg.17
        for <netdev@vger.kernel.org>; Sat, 18 Apr 2009 06:44:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 drivers/net/irda/pxaficp_ir.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index e775338..743952d 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -797,6 +797,14 @@ static int pxa_irda_init_iobuf(iobuff_t *io, int size)
 	return io->head ? 0 : -ENOMEM;
 }
 
+static const struct net_device_ops pxa_irda_ops = {
+	.ndo_start_xmit = pxa_irda_hard_xmit,
+	.ndo_open	= pxa_irda_start,
+	.ndo_stop	= pxa_irda_stop,
+	.ndo_do_ioctl	= pxa_irda_ioctl,
+};
+
+
 static int pxa_irda_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
@@ -845,10 +853,7 @@ static int pxa_irda_probe(struct platform_device *pdev)
 	if (err)
 		goto err_startup;
 
-	dev->hard_start_xmit	= pxa_irda_hard_xmit;
-	dev->open		= pxa_irda_start;
-	dev->stop		= pxa_irda_stop;
-	dev->do_ioctl		= pxa_irda_ioctl;
+	dev->netdev_ops = &pxa_irda_ops;
 
 	irda_init_max_qos_capabilies(&si->qos);
 
-- 
1.6.2.1

