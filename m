From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 3/4] f_phonet: fix inverted memory allocation sizes
Date: Mon,  6 Apr 2009 18:02:56 +0300
Message-ID: <1239030177-28783-3-git-send-email-remi.denis-courmont@nokia.com>
References: <200904061758.58057.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:63980 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557AbZDFPDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 11:03:14 -0400
In-Reply-To: <200904061758.58057.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 drivers/usb/gadget/f_phonet.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/usb/gadget/f_phonet.c b/drivers/usb/gadget/f_phone=
t.c
index dff7bae..25e711f 100644
--- a/drivers/usb/gadget/f_phonet.c
+++ b/drivers/usb/gadget/f_phonet.c
@@ -570,9 +570,10 @@ static struct net_device *dev;
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
@@ -597,9 +598,7 @@ int __init gphonet_setup(struct usb_gadget *gadget)
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
1.5.6.5

