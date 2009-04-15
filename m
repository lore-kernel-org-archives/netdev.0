From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 08/26] irda/sa1100_ir: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:42 +0400
Message-ID: <1239835980-22502-8-git-send-email-a.beregalov@gmail.com>
References: <1239835980-22502-1-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-2-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-3-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-4-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-5-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-6-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-7-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.185]:46923 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753524AbZDOWxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:14 -0400
Received: by mu-out-0910.google.com with SMTP id g7so51282muf.1
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:12 -0700 (PDT)
In-Reply-To: <1239835980-22502-7-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/irda/sa1100_ir.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/irda/sa1100_ir.c b/drivers/net/irda/sa1100_ir.c
index 7a2b003..44a748e 100644
--- a/drivers/net/irda/sa1100_ir.c
+++ b/drivers/net/irda/sa1100_ir.c
@@ -875,6 +875,16 @@ static int sa1100_irda_init_iobuf(iobuff_t *io, int size)
 	return io->head ? 0 : -ENOMEM;
 }
 
+static const struct net_device_ops sa1100_irda_netdev_ops = {
+	.ndo_open		= sa1100_irda_start,
+	.ndo_stop		= sa1100_irda_stop,
+	.ndo_start_xmit		= sa1100_irda_hard_xmit,
+	.ndo_do_ioctl		= sa1100_irda_ioctl,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
 static int sa1100_irda_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
@@ -913,11 +923,8 @@ static int sa1100_irda_probe(struct platform_device *pdev)
 	if (err)
 		goto err_mem_5;
 
-	dev->hard_start_xmit	= sa1100_irda_hard_xmit;
-	dev->open		= sa1100_irda_start;
-	dev->stop		= sa1100_irda_stop;
-	dev->do_ioctl		= sa1100_irda_ioctl;
-	dev->irq		= IRQ_Ser2ICP;
+	dev->netdev_ops	= &sa1100_irda_netdev_ops;
+	dev->ir		= IRQ_Ser2ICP;
 
 	irda_init_max_qos_capabilies(&si->qos);
 
-- 
1.6.2.3

