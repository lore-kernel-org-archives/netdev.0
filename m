From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] net: qmi_wwan: simplify a check in qmi_wwan_bind()
Date: Tue, 26 Jun 2012 11:39:45 +0300
Message-ID: <20120626083945.GA8946@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:37201 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758245Ab2FZIkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 04:40:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code is easier to read if we specify which flags we want at the
condition instead of at the top of the function.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Acked-by: Bj=F8rn Mork <bjorn@mork.no>

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index f1e7791..23cb13c 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -129,7 +129,6 @@ static int qmi_wwan_bind(struct usbnet *dev, struct=
 usb_interface *intf)
 	struct usb_interface_descriptor *desc =3D &intf->cur_altsetting->desc=
;
 	struct usb_cdc_union_desc *cdc_union =3D NULL;
 	struct usb_cdc_ether_desc *cdc_ether =3D NULL;
-	u32 required =3D 1 << USB_CDC_HEADER_TYPE | 1 << USB_CDC_UNION_TYPE;
 	u32 found =3D 0;
 	struct usb_driver *driver =3D driver_of(intf);
 	struct qmi_wwan_state *info =3D (void *)&dev->data;
@@ -197,7 +196,8 @@ next_desc:
 	}
=20
 	/* did we find all the required ones? */
-	if ((found & required) !=3D required) {
+	if (!(found & (1 << USB_CDC_HEADER_TYPE)) ||
+	    !(found & (1 << USB_CDC_UNION_TYPE))) {
 		dev_err(&intf->dev, "CDC functional descriptors missing\n");
 		goto err;
 	}
