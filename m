From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH] f_phonet: lock-less MTU change
Date: Fri,  7 Aug 2009 10:56:43 +0300
Message-ID: <1249631804-7438-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:45623 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757167AbZHGH4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 03:56:50 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx03.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n777uUxO025462
	for <netdev@vger.kernel.org>; Fri, 7 Aug 2009 10:56:43 +0300
Received: from localhost.localdomain (esdhcp038135.research.nokia.com [172.21.38.135])
	by mgw-da02.ext.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n777uWfd000603
	for <netdev@vger.kernel.org>; Fri, 7 Aug 2009 10:56:33 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

With the current driver, the MTU is purely indicative, so there is no
need to synchronize with the receive path.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 drivers/usb/gadget/f_phonet.c |   14 ++------------
 1 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/drivers/usb/gadget/f_phonet.c b/drivers/usb/gadget/f_phone=
t.c
index d17f108..f4eff7c 100644
--- a/drivers/usb/gadget/f_phonet.c
+++ b/drivers/usb/gadget/f_phonet.c
@@ -261,20 +261,10 @@ out:
=20
 static int pn_net_mtu(struct net_device *dev, int new_mtu)
 {
-	struct phonet_port *port =3D netdev_priv(dev);
-	unsigned long flags;
-	int err =3D -EBUSY;
-
 	if ((new_mtu < PHONET_MIN_MTU) || (new_mtu > PHONET_MAX_MTU))
 		return -EINVAL;
-
-	spin_lock_irqsave(&port->lock, flags);
-	if (!netif_carrier_ok(dev)) {
-		dev->mtu =3D new_mtu;
-		err =3D 0;
-	}
-	spin_unlock_irqrestore(&port->lock, flags);
-	return err;
+	dev->mtu =3D new_mtu;
+	return 0;
 }
=20
 static const struct net_device_ops pn_netdev_ops =3D {
--=20
1.6.0.4

