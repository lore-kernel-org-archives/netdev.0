From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 04/26] hplance: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:38 +0400
Message-ID: <1239835980-22502-4-git-send-email-a.beregalov@gmail.com>
References: <1239835980-22502-1-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-2-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-3-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:50591 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753740AbZDOWxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:08 -0400
Received: by bwz17 with SMTP id 17so114640bwz.37
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:06 -0700 (PDT)
In-Reply-To: <1239835980-22502-3-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/hplance.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/net/hplance.c b/drivers/net/hplance.c
index 2e80263..3e3528a 100644
--- a/drivers/net/hplance.c
+++ b/drivers/net/hplance.c
@@ -71,6 +71,19 @@ static struct dio_driver hplance_driver = {
 	.remove    = __devexit_p(hplance_remove_one),
 };
 
+static const struct net_device_ops hplance_netdev_ops = {
+	.ndo_open		= hplance_open,
+	.ndo_stop		= hplance_close,
+	.ndo_start_xmit		= lance_start_xmit,
+	.ndo_set_multicast_list	= lance_set_multicast,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= lance_poll,
+#endif
+};
+
 /* Find all the HP Lance boards and initialise them... */
 static int __devinit hplance_init_one(struct dio_dev *d,
 				const struct dio_device_id *ent)
@@ -135,13 +148,7 @@ static void __init hplance_init(struct net_device *dev, struct dio_dev *d)
 
         /* Fill the dev fields */
         dev->base_addr = va;
-        dev->open = &hplance_open;
-        dev->stop = &hplance_close;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-        dev->poll_controller = lance_poll;
-#endif
-        dev->hard_start_xmit = &lance_start_xmit;
-        dev->set_multicast_list = &lance_set_multicast;
+        dev->netdev_ops = &hplance_netdev_ops;
         dev->dma = 0;
 
         for (i=0; i<6; i++) {
-- 
1.6.2.3

