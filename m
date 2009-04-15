From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 25/26] smc911x: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:59 +0400
Message-ID: <1239835980-22502-25-git-send-email-a.beregalov@gmail.com>
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
 <1239835980-22502-16-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-17-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-18-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-19-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-20-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-21-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-22-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-23-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-24-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:48714 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756680AbZDOWxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:34 -0400
Received: by mail-fx0-f158.google.com with SMTP id 2so121386fxm.37
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:33 -0700 (PDT)
In-Reply-To: <1239835980-22502-24-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/smc911x.c |   23 +++++++++++++++--------
 1 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 2936103..bc4976a 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -1774,6 +1774,20 @@ static int __devinit smc911x_findirq(struct net_device *dev)
 	return probe_irq_off(cookie);
 }
 
+static const struct net_device_ops smc911x_netdev_ops = {
+	.ndo_open		= smc911x_open,
+	.ndo_stop		= smc911x_close,
+	.ndo_start_xmit		= smc911x_hard_start_xmit,
+	.ndo_tx_timeout		= smc911x_timeout,
+	.ndo_set_multicast_list	= smc911x_set_multicast_list,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= smc911x_poll_controller,
+#endif
+};
+
 /*
  * Function: smc911x_probe(unsigned long ioaddr)
  *
@@ -1940,16 +1954,9 @@ static int __devinit smc911x_probe(struct net_device *dev)
 	/* Fill in the fields of the device structure with ethernet values. */
 	ether_setup(dev);
 
-	dev->open = smc911x_open;
-	dev->stop = smc911x_close;
-	dev->hard_start_xmit = smc911x_hard_start_xmit;
-	dev->tx_timeout = smc911x_timeout;
+	dev->netdev_ops = &smc911x_netdev_ops;
 	dev->watchdog_timeo = msecs_to_jiffies(watchdog);
-	dev->set_multicast_list = smc911x_set_multicast_list;
 	dev->ethtool_ops = &smc911x_ethtool_ops;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = smc911x_poll_controller;
-#endif
 
 	INIT_WORK(&lp->phy_configure, smc911x_phy_configure);
 	lp->mii.phy_id_mask = 0x1f;
-- 
1.6.2.3

