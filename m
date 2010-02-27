From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 2/9] Bluetooth: Make USB device id constant
Date: Sat, 27 Feb 2010 23:38:31 +0100
Message-ID: <8978111e2d148f75bd5e329a14600feadc567381.1267276098.git.marcel@holtmann.org>
References: <cover.1267276098.git.marcel@holtmann.org>
 <8e5b2308489dbca27c104fc6a557d4c9348552e5.1267276098.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54690 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936359Ab0B0WkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 17:40:18 -0500
In-Reply-To: <8e5b2308489dbca27c104fc6a557d4c9348552e5.1267276098.git.marcel@holtmann.org>
In-Reply-To: <cover.1267276098.git.marcel@holtmann.org>
References: <cover.1267276098.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: M=C3=A1rton N=C3=A9meth <nm127@freemail.hu>

The id_table field of the struct usb_device_id is constant in <linux/us=
b.h>
so it is worth to make bcm203x_table also constant.

The semantic match that finds this kind of pattern is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r@
disable decl_init,const_decl_init;
identifier I1, I2, x;
@@
	struct I1 {
	  ...
	  const struct I2 *x;
	  ...
	};
@s@
identifier r.I1, y;
identifier r.x, E;
@@
	struct I1 y =3D {
	  .x =3D E,
	};
@c@
identifier r.I2;
identifier s.E;
@@
	const struct I2 E[] =3D ... ;
@depends on !c@
identifier r.I2;
identifier s.E;
@@
+	const
	struct I2 E[] =3D ...;
// </smpl>

Signed-off-by: M=C3=A1rton N=C3=A9meth <nm127@freemail.hu>
Cc: Julia Lawall <julia@diku.dk>
Cc: cocci@diku.dk
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/bcm203x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/bluetooth/bcm203x.c b/drivers/bluetooth/bcm203x.c
index eafd4af..b0c84c1 100644
--- a/drivers/bluetooth/bcm203x.c
+++ b/drivers/bluetooth/bcm203x.c
@@ -39,7 +39,7 @@
=20
 #define VERSION "1.2"
=20
-static struct usb_device_id bcm203x_table[] =3D {
+static const struct usb_device_id bcm203x_table[] =3D {
 	/* Broadcom Blutonium (BCM2033) */
 	{ USB_DEVICE(0x0a5c, 0x2033) },
=20
--=20
1.6.6

