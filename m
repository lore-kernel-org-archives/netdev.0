From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 18/26] mvme147: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:52 +0400
Message-ID: <1239835980-22502-18-git-send-email-a.beregalov@gmail.com>
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
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:50591 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756407AbZDOWx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:26 -0400
Received: by mail-bw0-f169.google.com with SMTP id 17so114640bwz.37
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:25 -0700 (PDT)
In-Reply-To: <1239835980-22502-17-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/mvme147.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/mvme147.c b/drivers/net/mvme147.c
index 435e5a8..93c709d 100644
--- a/drivers/net/mvme147.c
+++ b/drivers/net/mvme147.c
@@ -57,6 +57,17 @@ typedef void (*writerap_t)(void *, unsigned short);
 typedef void (*writerdp_t)(void *, unsigned short);
 typedef unsigned short (*readrdp_t)(void *);
 
+static const struct net_device_ops lance_netdev_ops = {
+	.ndo_open		= m147lance_open,
+	.ndo_stop		= m147lance_close,
+	.ndo_start_xmit		= lance_start_xmit,
+	.ndo_set_multicast_list	= lance_set_multicast,
+	.ndo_tx_timeout		= lance_tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
 /* Initialise the one and only on-board 7990 */
 struct net_device * __init mvme147lance_probe(int unit)
 {
@@ -81,11 +92,7 @@ struct net_device * __init mvme147lance_probe(int unit)
 
 	/* Fill the dev fields */
 	dev->base_addr = (unsigned long)MVME147_LANCE_BASE;
-	dev->open = &m147lance_open;
-	dev->stop = &m147lance_close;
-	dev->hard_start_xmit = &lance_start_xmit;
-	dev->set_multicast_list = &lance_set_multicast;
-	dev->tx_timeout = &lance_tx_timeout;
+	dev->netdev_ops = &lance_netdev_ops;
 	dev->dma = 0;
 
 	addr=(u_long *)ETHERNET_ADDRESS;
-- 
1.6.2.3

