From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: [PATCH] cdc_ether: add usb id for Ericsson F3507g
Date: Wed, 25 Feb 2009 15:33:58 +0100
Message-ID: <87ocwqsi09.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:36950 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754621AbZBYOkG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 09:40:06 -0500
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1LcKva-0007cb-OI
	for netdev@vger.kernel.org; Wed, 25 Feb 2009 14:40:02 +0000
Received: from 193.160.199.2 ([193.160.199.2])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2009 14:40:02 +0000
Received: from bjorn by 193.160.199.2 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2009 14:40:02 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Ericsson F3507g wireless broadband module provides a CDC Ethernet
compliant interface, but identifies it as a "Mobile Direct Line" CDC
subclass, thereby preventing the CDC Ethernet class driver from picking
it up.  This patch adds the device id to cdc_ether.c as a workaround.

Ericsson has provided a "class" driver for this device:
http://kerneltrap.org/mailarchive/linux-net/2008/10/28/3832094
But closer inspection of that driver reveals that it adds little more
than duplication of code from cdc_ether.c.  See also
http://marc.info/?l=3Dlinux-usb&m=3D123334979706403&w=3D2


Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 0e061df..55e8ecc 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -559,6 +559,11 @@ static const struct usb_device_id	products [] =3D =
{
 	USB_INTERFACE_INFO(USB_CLASS_COMM, USB_CDC_SUBCLASS_ETHERNET,
 			USB_CDC_PROTO_NONE),
 	.driver_info =3D (unsigned long) &cdc_info,
+}, {
+	/* Ericsson F3507g */
+	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1900, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info =3D (unsigned long) &cdc_info,
 },
 	{ },		// END
 };


