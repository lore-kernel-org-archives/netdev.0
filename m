From: Lekensteyn <lekensteyn@gmail.com>
Subject: [PATCH] jme: netpoll support
Date: Tue, 17 Jul 2012 18:29:34 +0200
Message-ID: <18143736.brt1iGhlQ1@al>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: Guo-Fu Tseng <cooldavid@cooldavid.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:50177 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944Ab2GQQ3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 12:29:45 -0400
Received: by eaak11 with SMTP id k11so241234eaa.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 09:29:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Wu <lekensteyn@gmail.com>

This patch adds the netpoll function to support netconsole. Tested and works
fine on my "JMC250 PCI Express Gigabit Ethernet Controller" (PCI ID 0250).

Signed-off-by: Peter Wu <lekensteyn@gmail.com>
---
 drivers/net/ethernet/jme.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 4ea6580..c911d88 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -2743,6 +2743,17 @@ jme_set_features(struct net_device *netdev, netdev_features_t features)
 	return 0;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void jme_netpoll(struct net_device *dev)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	jme_intr(dev->irq, dev);
+	local_irq_restore(flags);
+}
+#endif
+
 static int
 jme_nway_reset(struct net_device *netdev)
 {
@@ -2944,6 +2955,9 @@ static const struct net_device_ops jme_netdev_ops = {
 	.ndo_tx_timeout		= jme_tx_timeout,
 	.ndo_fix_features       = jme_fix_features,
 	.ndo_set_features       = jme_set_features,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= jme_netpoll,
+#endif
 };
 
 static int __devinit
-- 
1.7.9.5
