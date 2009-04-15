From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 06/26] irda/au1k_ir: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:40 +0400
Message-ID: <1239835980-22502-6-git-send-email-a.beregalov@gmail.com>
References: <1239835980-22502-1-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-2-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-3-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-4-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-5-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:48714 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752315AbZDOWxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:09 -0400
Received: by mail-fx0-f158.google.com with SMTP id 2so121386fxm.37
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:09 -0700 (PDT)
In-Reply-To: <1239835980-22502-5-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/irda/au1k_ir.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index 9411640..204def0 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -198,6 +198,17 @@ static int au1k_irda_init_iobuf(iobuff_t *io, int size)
 	return io->head ? 0 : -ENOMEM;
 }
 
+static const struct net_device_ops au1k_irda_netdev_ops = {
+	.ndo_open		= au1k_irda_start,
+	.ndo_stop		= au1k_irda_stop,
+	.ndo_start_xmit		= au1k_irda_hard_xmit,
+	.ndo_tx_timeout		= au1k_tx_timeout,
+	.ndo_do_ioctl		= au1k_irda_ioctl,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
 static int au1k_irda_net_init(struct net_device *dev)
 {
 	struct au1k_private *aup = netdev_priv(dev);
@@ -209,11 +220,7 @@ static int au1k_irda_net_init(struct net_device *dev)
 	if (err)
 		goto out1;
 
-	dev->open = au1k_irda_start;
-	dev->hard_start_xmit = au1k_irda_hard_xmit;
-	dev->stop = au1k_irda_stop;
-	dev->do_ioctl = au1k_irda_ioctl;
-	dev->tx_timeout = au1k_tx_timeout;
+	dev->netdev_ops = &au1k_irda_netdev_ops;
 
 	irda_init_max_qos_capabilies(&aup->qos);
 
-- 
1.6.2.3

