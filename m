From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 16/26] meth: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:50 +0400
Message-ID: <1239835980-22502-16-git-send-email-a.beregalov@gmail.com>
References: <1239835980-22502-1-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-2-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-3-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-4-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-5-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-6-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-7-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-8-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-9-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-10-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-11-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-12-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-13-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-14-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-15-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:38634 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753524AbZDOWxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:24 -0400
Received: by mail-bw0-f169.google.com with SMTP id 17so114630bwz.37
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:23 -0700 (PDT)
In-Reply-To: <1239835980-22502-15-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/meth.c |   28 +++++++++++++++-------------
 1 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/drivers/net/meth.c b/drivers/net/meth.c
index aa08987..46ffdb4 100644
--- a/drivers/net/meth.c
+++ b/drivers/net/meth.c
@@ -769,9 +769,17 @@ static int meth_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	}
 }
 
-/*
- * Return statistics to the caller
- */
+static const struct net_device_ops meth_netdev_ops = {
+	.ndo_open		= meth_open,
+	.ndo_stop		= meth_release,
+	.ndo_start_xmit		= meth_tx,
+	.ndo_do_ioctl		= meth_ioctl,
+	.ndo_tx_timeout		= meth_tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
 /*
  * The init function.
  */
@@ -785,16 +793,10 @@ static int __init meth_probe(struct platform_device *pdev)
 	if (!dev)
 		return -ENOMEM;
 
-	dev->open            = meth_open;
-	dev->stop            = meth_release;
-	dev->hard_start_xmit = meth_tx;
-	dev->do_ioctl        = meth_ioctl;
-#ifdef HAVE_TX_TIMEOUT
-	dev->tx_timeout      = meth_tx_timeout;
-	dev->watchdog_timeo  = timeout;
-#endif
-	dev->irq	     = MACE_ETHERNET_IRQ;
-	dev->base_addr	     = (unsigned long)&mace->eth;
+	dev->netdev_ops		= &meth_netdev_ops;
+	dev->watchdog_timeo	= timeout;
+	dev->irq		= MACE_ETHERNET_IRQ;
+	dev->base_addr		= (unsigned long)&mace->eth;
 	memcpy(dev->dev_addr, o2meth_eaddr, 6);
 
 	priv = netdev_priv(dev);
-- 
1.6.2.3

