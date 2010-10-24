From: Serafeim Zanikolas <sez@debian.org>
Subject: [PATCH] drivers: rtl818x: request DMA-able memory
Date: Sun, 24 Oct 2010 22:32:07 +0200
Message-ID: <1287952327-9924-1-git-send-email-sez__45800.2753476196$1287953189$gmane$org@debian.org>
Cc: Serafeim Zanikolas <sez@debian.org>
To: herton@mandriva.com.br, htl10@users.sourceforge.net,
	Larry.Finger@lwfinger.net, linville@tuxdriver.com, joe@perches.com,
	davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vg
Return-path: <netdev-owner@vger.kernel.org>
Received: from igloo.linux.gr ([62.1.205.36]:58654 "EHLO igloo.linux.gr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932438Ab0JXUqT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Oct 2010 16:46:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Despite the indicated intention in comment, the kmalloc() call was not
explicitly requesting memory from ZONE_DMA.

Signed-off-by: Serafeim Zanikolas <sez@debian.org>
---
 drivers/net/wireless/rtl818x/rtl8187_dev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/rtl818x/rtl8187_dev.c b/drivers/net/wireless/rtl818x/rtl8187_dev.c
index 38fa824..771794d 100644
--- a/drivers/net/wireless/rtl818x/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8187_dev.c
@@ -1343,7 +1343,8 @@ static int __devinit rtl8187_probe(struct usb_interface *intf,
 	priv->is_rtl8187b = (id->driver_info == DEVICE_RTL8187B);
 
 	/* allocate "DMA aware" buffer for register accesses */
-	priv->io_dmabuf = kmalloc(sizeof(*priv->io_dmabuf), GFP_KERNEL);
+	priv->io_dmabuf = kmalloc(sizeof(*priv->io_dmabuf),
+				  GFP_DMA | GFP_KERNEL);
 	if (!priv->io_dmabuf) {
 		err = -ENOMEM;
 		goto err_free_dev;
-- 
1.7.1

