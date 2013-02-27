From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH] net: cdc_ncm: tag Huawei devices (e.g. E5331) with FLAG_WWAN
Date: Wed, 27 Feb 2013 14:08:58 +0100
Message-ID: <1361970538-24451-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@stericsson.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:48267 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932176Ab3B0NJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2013 08:09:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tag all Huawei NCM devices as WWAN modems, as we don't know of any whic=
h
are not.  This is necessary for userspace clients to know that the devi=
ce
requires further setup on e.g. an AT-capable serial ports before
connectivity is available.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 4a8c25a..61b74a2 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1213,6 +1213,14 @@ static const struct usb_device_id cdc_devs[] =3D=
 {
 	  .driver_info =3D (unsigned long) &wwan_info,
 	},
=20
+	/* tag Huawei devices as wwan */
+	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1,
+					USB_CLASS_COMM,
+					USB_CDC_SUBCLASS_NCM,
+					USB_CDC_PROTO_NONE),
+	  .driver_info =3D (unsigned long)&wwan_info,
+	},
+
 	/* Huawei NCM devices disguised as vendor specific */
 	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x16),
 	  .driver_info =3D (unsigned long)&wwan_info,
--=20
1.7.10.4
