From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 26/26] sun3lance: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:53:00 +0400
Message-ID: <1239835980-22502-26-git-send-email-a.beregalov@gmail.com>
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
 <1239835980-22502-25-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:50591 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752315AbZDOWxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:35 -0400
Received: by mail-bw0-f169.google.com with SMTP id 17so114640bwz.37
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:34 -0700 (PDT)
In-Reply-To: <1239835980-22502-25-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/sun3lance.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sun3lance.c b/drivers/net/sun3lance.c
index e5beb29..9bd9dad 100644
--- a/drivers/net/sun3lance.c
+++ b/drivers/net/sun3lance.c
@@ -294,6 +294,16 @@ out:
 	return ERR_PTR(err);
 }
 
+static const struct net_device_ops lance_netdev_ops = {
+	.ndo_open		= lance_open,
+	.ndo_stop		= lance_close,
+	.ndo_start_xmit		= lance_start_xmit,
+	.ndo_set_multicast_list	= set_multicast_list,
+	.ndo_set_mac_address	= NULL,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int __init lance_probe( struct net_device *dev)
 {
 	unsigned long ioaddr;
@@ -397,12 +407,7 @@ static int __init lance_probe( struct net_device *dev)
 	if (did_version++ == 0)
 		printk( version );
 
-	/* The LANCE-specific entries in the device structure. */
-	dev->open = &lance_open;
-	dev->hard_start_xmit = &lance_start_xmit;
-	dev->stop = &lance_close;
-	dev->set_multicast_list = &set_multicast_list;
-	dev->set_mac_address = NULL;
+	dev->netdev_ops = &lance_netdev_ops;
 //	KLUDGE -- REMOVE ME
 	set_bit(__LINK_STATE_PRESENT, &dev->state);
 
-- 
1.6.2.3

