From: Li Yang <leoli@freescale.com>
Subject: [PATCH 4/4] ucc_geth: Add support to local-mac-address property
Date: Tue, 06 Feb 2007 19:31:55 +0800
Message-ID: <45C8672B.1050302@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:38548 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbXBFLar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 06:30:47 -0500
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id l16BUjBx007517
	for <netdev@vger.kernel.org>; Tue, 6 Feb 2007 04:30:45 -0700 (MST)
Received: from zch01exm20.fsl.freescale.net (zch01exm20.ap.freescale.net [10.192.129.204])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id l16BUd4C014739
	for <netdev@vger.kernel.org>; Tue, 6 Feb 2007 05:30:41 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IEEE-1275 defines =93local-mac-address=94 to be a standard
property name to specify preassigned network address.
This patch adds support for it.

Signed-off-by: Li Yang <leoli@freescale.com>
---
 drivers/net/ucc_geth.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index dcec66d..62512fc 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -4053,6 +4053,7 @@ static int ucc_geth_probe(struct of_device* ofdev=
, const struct of_device_id *ma
 	static int mii_mng_configured =3D 0;
 	const phandle *ph;
 	const unsigned int *prop;
+	const void *mac_addr;
=20
 	ugeth_vdbg("%s: IN", __FUNCTION__);
=20
@@ -4178,7 +4179,12 @@ static int ucc_geth_probe(struct of_device* ofde=
v, const struct of_device_id *ma
=20
 	ugeth->ug_info =3D ug_info;
 	ugeth->dev =3D dev;
-	memcpy(dev->dev_addr, get_property(np, "mac-address", NULL), 6);
+
+	mac_addr =3D get_property(np, "mac-address", NULL);
+	if (mac_addr =3D=3D NULL)
+		mac_addr =3D get_property(np, "local-mac-address", NULL);
+	if (mac_addr)
+		memcpy(dev->dev_addr, mac_addr, 6);
=20
 	return 0;
 }

