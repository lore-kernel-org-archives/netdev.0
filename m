From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 15/24] net: cdc_ncm: set correct dev->hard_mtu
Date: Fri,  1 Nov 2013 11:16:52 +0100
Message-ID: <1383301021-16613-16-git-send-email-bjorn@mork.no>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49989 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755949Ab3KAKRZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 06:17:25 -0400
In-Reply-To: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

usbnet use the hard_mtu value for sizing the tx queue and nothing
else.  We will be transmitting buffers of up to tx_max size, so
that's the proper value to give usbnet.

The individual datagram size is completely irrelevant here.

Cc: Alexey Orishko <alexey.orishko@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 8fc1a06..c40f742 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -404,13 +404,6 @@ int cdc_ncm_bind_common(struct usbnet *dev, struct=
 usb_interface *intf, u8 data_
=20
 			ctx->ether_desc =3D
 					(const struct usb_cdc_ether_desc *)buf;
-			dev->hard_mtu =3D
-				le16_to_cpu(ctx->ether_desc->wMaxSegmentSize);
-
-			if (dev->hard_mtu < CDC_NCM_MIN_DATAGRAM_SIZE)
-				dev->hard_mtu =3D	CDC_NCM_MIN_DATAGRAM_SIZE;
-			else if (dev->hard_mtu > CDC_NCM_MAX_DATAGRAM_SIZE)
-				dev->hard_mtu =3D	CDC_NCM_MAX_DATAGRAM_SIZE;
 			break;
=20
 		case USB_CDC_NCM_TYPE:
@@ -485,6 +478,8 @@ advance:
 		dev_info(&dev->udev->dev, "MAC-Address: %pM\n", dev->net->dev_addr);
 	}
=20
+	/* usbnet use these values for sizing tx/rx queues */
+	dev->hard_mtu =3D ctx->tx_max;
 	dev->rx_urb_size =3D ctx->rx_max;
=20
 	return 0;
--=20
1.7.10.4
