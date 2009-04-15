From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 07/26] irda/pxaficp_ir: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:41 +0400
Message-ID: <1239835980-22502-7-git-send-email-a.beregalov@gmail.com>
References: <1239835980-22502-1-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-2-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-3-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-4-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-5-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-6-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.186]:22060 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754838AbZDOWxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:12 -0400
Received: by fk-out-0910.google.com with SMTP id 18so54620fkq.5
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:10 -0700 (PDT)
In-Reply-To: <1239835980-22502-6-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/irda/pxaficp_ir.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index e775338..e8ced56 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -797,6 +797,16 @@ static int pxa_irda_init_iobuf(iobuff_t *io, int size)
 	return io->head ? 0 : -ENOMEM;
 }
 
+static const struct net_device_ops pxa_irda_netdev_ops = {
+	.ndo_open		= pxa_irda_start,
+	.ndo_stop		= pxa_irda_stop,
+	.ndo_start_xmit		= pxa_irda_hard_xmit,
+	.ndo_do_ioctl		= pxa_irda_ioctl,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
 static int pxa_irda_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
@@ -845,10 +855,7 @@ static int pxa_irda_probe(struct platform_device *pdev)
 	if (err)
 		goto err_startup;
 
-	dev->hard_start_xmit	= pxa_irda_hard_xmit;
-	dev->open		= pxa_irda_start;
-	dev->stop		= pxa_irda_stop;
-	dev->do_ioctl		= pxa_irda_ioctl;
+	dev->netdev_ops = &pxa_irda_netdev_ops;
 
 	irda_init_max_qos_capabilies(&si->qos);
 
-- 
1.6.2.3

