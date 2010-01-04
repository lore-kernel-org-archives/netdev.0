From: =?UTF-8?B?TsOpbWV0aCBNw6FydG9u?= <nm127@freemail.hu>
Subject: [PATCH] 8139too: make PCI device ids constant
Date: Tue, 05 Jan 2010 00:03:02 +0100
Message-ID: <4B4273A6.4020102@freemail.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Julia Lawall <julia@diku.dk>, cocci@diku.dk
To: Jeff Garzik <jgarzik@pobox.com>,
	Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail02d.mail.t-online.hu ([84.2.42.7]:53624 "EHLO
	mail02d.mail.t-online.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753025Ab0ADXDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 18:03:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: M=C3=A1rton N=C3=A9meth <nm127@freemail.hu>

The id_table field of the struct pci_driver is constant in <linux/pci.h=
>
so it is worth to make pci_device_id also constant.

The semantic match that finds this kind of pattern is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r@
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
---
diff -u -p a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
--- a/drivers/net/pci-skeleton.c 2009-12-27 12:20:35.000000000 +0100
+++ b/drivers/net/pci-skeleton.c 2010-01-03 21:08:03.000000000 +0100
@@ -211,7 +211,7 @@ static struct {
 };


-static struct pci_device_id netdrv_pci_tbl[] =3D {
+static const struct pci_device_id netdrv_pci_tbl[] =3D {
 	{0x10ec, 0x8139, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x10ec, 0x8138, PCI_ANY_ID, PCI_ANY_ID, 0, 0, NETDRV_CB },
 	{0x1113, 0x1211, PCI_ANY_ID, PCI_ANY_ID, 0, 0, SMC1211TX },
diff -u -p a/drivers/net/8139too.c b/drivers/net/8139too.c
--- a/drivers/net/8139too.c 2009-12-27 12:20:30.000000000 +0100
+++ b/drivers/net/8139too.c 2010-01-03 21:25:05.000000000 +0100
@@ -231,7 +231,7 @@ static const struct {
 };


-static struct pci_device_id rtl8139_pci_tbl[] =3D {
+static const struct pci_device_id rtl8139_pci_tbl[] =3D {
 	{0x10ec, 0x8139, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x10ec, 0x8138, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x1113, 0x1211, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
