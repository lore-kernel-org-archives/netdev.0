From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] cpmac: use #ifdef CONFIG_NETDEVICES_MULTIQUEUE to wrap mq
 feature
Date: Thu, 19 Jun 2008 11:20:45 +0800
Message-ID: <4859D08D.4030503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jgarzik@pobox.com>, NETDEV <netdev@vger.kernel.org>,
	Eugene Konev <ejka@imfi.kspu.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62488 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756128AbYFSDYo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 23:24:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev->features |= NETIF_F_MULTI_QUEUE should wrapped by
#ifdef CONFIG_NETDEVICES_MULTIQUEUE.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/cpmac.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 7f3f62e..9172dec 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -1152,7 +1152,11 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 		}
 	}
 
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	dev = alloc_etherdev_mq(sizeof(*priv), CPMAC_QUEUES);
+#else
+	dev = alloc_etherdev(sizeof(*priv));
+#endif
 
 	if (!dev) {
 		printk(KERN_ERR "cpmac: Unable to allocate net_device\n");
@@ -1179,7 +1183,9 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	dev->set_multicast_list = cpmac_set_multicast_list;
 	dev->tx_timeout         = cpmac_tx_timeout;
 	dev->ethtool_ops        = &cpmac_ethtool_ops;
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	dev->features |= NETIF_F_MULTI_QUEUE;
+#endif
 
 	netif_napi_add(dev, &priv->napi, cpmac_poll, 64);
 
-- 
1.5.3.4

