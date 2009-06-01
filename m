From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 2/3] f_phonet: no need to check for carrier - scheduler does it internally
Date: Mon,  1 Jun 2009 14:18:56 +0300
Message-ID: <1243855137-20149-2-git-send-email-remi.denis-courmont@nokia.com>
References: <1243855137-20149-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:52402 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754674AbZFALRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 07:17:45 -0400
Received: from esebh106.NOE.Nokia.com (esebh106.ntc.nokia.com [172.21.138.213])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id n51BHFR5017582
	for <netdev@vger.kernel.org>; Mon, 1 Jun 2009 14:17:40 +0300
Received: from localhost.localdomain (esdhcp037217.research.nokia.com [172.21.37.217])
	by mgw-sa02.ext.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id n51BHbXu003855
	for <netdev@vger.kernel.org>; Mon, 1 Jun 2009 14:17:38 +0300
In-Reply-To: <1243855137-20149-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 drivers/usb/gadget/f_phonet.c |   10 ++--------
 1 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/usb/gadget/f_phonet.c b/drivers/usb/gadget/f_phone=
t.c
index 54451ee..d6b4871 100644
--- a/drivers/usb/gadget/f_phonet.c
+++ b/drivers/usb/gadget/f_phonet.c
@@ -188,8 +188,7 @@ static struct usb_descriptor_header *hs_pn_function=
[] =3D {
=20
 static int pn_net_open(struct net_device *dev)
 {
-	if (netif_carrier_ok(dev))
-		netif_wake_queue(dev);
+	netif_wake_queue(dev);
 	return 0;
 }
=20
@@ -219,8 +218,7 @@ static void pn_tx_complete(struct usb_ep *ep, struc=
t usb_request *req)
 	}
=20
 	dev_kfree_skb_any(skb);
-	if (netif_carrier_ok(dev))
-		netif_wake_queue(dev);
+	netif_wake_queue(dev);
 }
=20
 static int pn_net_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -383,7 +381,6 @@ static void __pn_reset(struct usb_function *f)
 	struct phonet_port *port =3D netdev_priv(dev);
=20
 	netif_carrier_off(dev);
-	netif_stop_queue(dev);
 	port->usb =3D NULL;
=20
 	usb_ep_disable(fp->out_ep);
@@ -427,8 +424,6 @@ static int pn_set_alt(struct usb_function *f, unsig=
ned intf, unsigned alt)
 			fp->in_ep->driver_data =3D fp;
=20
 			netif_carrier_on(dev);
-			if (netif_running(dev))
-				netif_wake_queue(dev);
 			for (i =3D 0; i < phonet_rxq_size; i++)
 				pn_rx_submit(fp, fp->out_reqv[i], GFP_ATOMIC);
 		}
@@ -610,7 +605,6 @@ int __init gphonet_setup(struct usb_gadget *gadget)
 	port =3D netdev_priv(dev);
 	spin_lock_init(&port->lock);
 	netif_carrier_off(dev);
-	netif_stop_queue(dev);
 	SET_NETDEV_DEV(dev, &gadget->dev);
=20
 	err =3D register_netdev(dev);
--=20
1.6.0.4

