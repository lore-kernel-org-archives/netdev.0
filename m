From: Olivier Blin <olivier.blin@softathome.com>
Subject: [PATCH net 3/3] cdc-ether: handle promiscuous mode with a set_rx_mode callback
Date: Fri, 24 Oct 2014 19:43:02 +0200
Message-ID: <1414172582-30844-4-git-send-email-olivier.blin@softathome.com>
References: <1414172582-30844-1-git-send-email-olivier.blin@softathome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: oneukum@suse.de, hayeswang@realtek.com, bjorn@mork.no,
	davem@davemloft.net, Olivier Blin <olivier.blin@softathome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 92-137-167-83.reverse.alphalink.fr ([83.167.137.92]:39351 "EHLO
	mtantr1.softathome.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757036AbaJXRwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 13:52:09 -0400
In-Reply-To: <1414172582-30844-1-git-send-email-olivier.blin@softathome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Promiscuous mode was not supported anymore with my Lenovo adapters
(RTL8153) since commit c472ab68ad67db23c9907a27649b7dc0899b61f9
(cdc-ether: clean packet filter upon probe).

It was not possible to use them in a bridge anymore.

Signed-off-by: Olivier Blin <olivier.blin@softathome.com>
Also-analyzed-by: Lo=C3=AFc Yhuel <loic.yhuel@softathome.com>
---
 drivers/net/usb/cdc_ether.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index bee3689..d3920b5 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -76,6 +76,9 @@ static void usbnet_cdc_update_filter(struct usbnet *d=
ev)
 	    USB_CDC_PACKET_TYPE_ALL_MULTICAST | USB_CDC_PACKET_TYPE_DIRECTED =
|
 	    USB_CDC_PACKET_TYPE_BROADCAST;
=20
+	if (dev->net->flags & IFF_PROMISC)
+		cdc_filter |=3D USB_CDC_PACKET_TYPE_PROMISCUOUS;
+
 	/* FIXME cdc-ether has some multicast code too, though it complains
 	 * in routine cases.  info->ether describes the multicast support.
 	 * Implement that here, manipulating the cdc filter as needed.
@@ -496,6 +499,7 @@ static const struct driver_info	cdc_info =3D {
 	.bind =3D		usbnet_cdc_bind,
 	.unbind =3D	usbnet_cdc_unbind,
 	.status =3D	usbnet_cdc_status,
+	.set_rx_mode =3D	usbnet_cdc_update_filter,
 	.manage_power =3D	usbnet_manage_power,
 };
=20
@@ -505,6 +509,7 @@ static const struct driver_info wwan_info =3D {
 	.bind =3D		usbnet_cdc_bind,
 	.unbind =3D	usbnet_cdc_unbind,
 	.status =3D	usbnet_cdc_status,
+	.set_rx_mode =3D	usbnet_cdc_update_filter,
 	.manage_power =3D	usbnet_manage_power,
 };
=20
--=20
2.1.2

-- This message and any attachments herein are confidential, intended s=
olely for the addressees and are SoftAtHome.s ownership. Any unauthoriz=
ed use or dissemination is prohibited. If you are not the intended addr=
essee of this message, please cancel it immediately and inform the send=
er.
-- This message and any attachments herein are confidential, intended s=
olely for the addressees and are SoftAtHome.s ownership. Any unauthoriz=
ed use or dissemination is prohibited. If you are not the intended addr=
essee of this message, please cancel it immediately and inform the send=
er.
