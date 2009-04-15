From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 10/26] ixp2000/ixpdev: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:44 +0400
Message-ID: <1239835980-22502-10-git-send-email-a.beregalov@gmail.com>
References: <1239835980-22502-1-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-2-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-3-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-4-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-5-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-6-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-7-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-8-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-9-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:38634 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755496AbZDOWxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:16 -0400
Received: by mail-bw0-f169.google.com with SMTP id 17so114630bwz.37
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:15 -0700 (PDT)
In-Reply-To: <1239835980-22502-9-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/ixp2000/ixpdev.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixp2000/ixpdev.c b/drivers/net/ixp2000/ixpdev.c
index d3bf2f0..2a0174b 100644
--- a/drivers/net/ixp2000/ixpdev.c
+++ b/drivers/net/ixp2000/ixpdev.c
@@ -270,6 +270,18 @@ static int ixpdev_close(struct net_device *dev)
 	return 0;
 }
 
+static const struct net_device_ops ixpdev_netdev_ops = {
+	.ndo_open		= ixpdev_open,
+	.ndo_stop		= ixpdev_close,
+	.ndo_start_xmit		= ixpdev_xmit,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= ixpdev_poll_controller,
+#endif
+};
+
 struct net_device *ixpdev_alloc(int channel, int sizeof_priv)
 {
 	struct net_device *dev;
@@ -279,12 +291,7 @@ struct net_device *ixpdev_alloc(int channel, int sizeof_priv)
 	if (dev == NULL)
 		return NULL;
 
-	dev->hard_start_xmit = ixpdev_xmit;
-	dev->open = ixpdev_open;
-	dev->stop = ixpdev_close;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ixpdev_poll_controller;
-#endif
+	dev->netdev_ops = &ixpdev_netdev_ops;
 
 	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM;
 
-- 
1.6.2.3

