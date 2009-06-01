From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 3/3] usb: gadget: f_phonet: fix memory allocation sizes
Date: Mon,  1 Jun 2009 14:18:57 +0300
Message-ID: <1243855137-20149-3-git-send-email-remi.denis-courmont@nokia.com>
References: <1243855137-20149-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:52404 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755667AbZFALRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 07:17:47 -0400
Received: from esebh106.NOE.Nokia.com (esebh106.ntc.nokia.com [172.21.138.213])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id n51BHFR7017582
	for <netdev@vger.kernel.org>; Mon, 1 Jun 2009 14:17:42 +0300
Received: from localhost.localdomain (esdhcp037217.research.nokia.com [172.21.37.217])
	by mgw-sa02.ext.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id n51BHbXv003855
	for <netdev@vger.kernel.org>; Mon, 1 Jun 2009 14:17:38 +0300
In-Reply-To: <1243855137-20149-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Signed-off-by: Felipe Balbi <felipe.balbi@nokia.com>
---
 drivers/usb/gadget/f_phonet.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/usb/gadget/f_phonet.c b/drivers/usb/gadget/f_phone=
t.c
index d6b4871..96fb118 100644
--- a/drivers/usb/gadget/f_phonet.c
+++ b/drivers/usb/gadget/f_phonet.c
@@ -569,9 +569,10 @@ static struct net_device *dev;
 int __init phonet_bind_config(struct usb_configuration *c)
 {
 	struct f_phonet *fp;
-	int err;
+	int err, size;
=20
-	fp =3D kzalloc(sizeof(*fp), GFP_KERNEL);
+	size =3D sizeof(*fp) + (phonet_rxq_size * sizeof(struct usb_request *=
));
+	fp =3D kzalloc(size, GFP_KERNEL);
 	if (!fp)
 		return -ENOMEM;
=20
@@ -596,9 +597,7 @@ int __init gphonet_setup(struct usb_gadget *gadget)
=20
 	/* Create net device */
 	BUG_ON(dev);
-	dev =3D alloc_netdev(sizeof(*port)
-		+ (phonet_rxq_size * sizeof(struct usb_request *)),
-				"upnlink%d", pn_net_setup);
+	dev =3D alloc_netdev(sizeof(*port), "upnlink%d", pn_net_setup);
 	if (!dev)
 		return -ENOMEM;
=20
--=20
1.6.0.4

