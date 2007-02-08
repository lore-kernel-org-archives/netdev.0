From: Li Yang <leoli@freescale.com>
Subject: [PATCH 3/3] ucc_geth: Add support to local-mac-address property
Date: Thu, 08 Feb 2007 17:35:54 +0800
Message-ID: <45CAEEFA.9060501@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:55315 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965720AbXBHJen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 04:34:43 -0500
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw01.freescale.net (8.12.11/de01egw01) with ESMTP id l189YfbT027241
	for <netdev@vger.kernel.org>; Thu, 8 Feb 2007 02:34:41 -0700 (MST)
Received: from zch01exm20.fsl.freescale.net (zch01exm20.ap.freescale.net [10.192.129.204])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id l189YdCx027367
	for <netdev@vger.kernel.org>; Thu, 8 Feb 2007 03:34:40 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IEEE-1275 defines =93local-mac-address=94 to be a standard
property name to specify preassigned network address.
This patch adds support for it.

Signed-off-by: Li Yang <leoli@freescale.com>=20
---
 drivers/net/ucc_geth.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index ce0eab9..cf93383 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -4070,6 +4070,7 @@ static int ucc_geth_probe(struct of_device* ofdev=
, const struct of_device_id *ma
 	static int mii_mng_configured =3D 0;
 	const phandle *ph;
 	const unsigned int *prop;
+	const void *mac_addr;
=20
 	ugeth_vdbg("%s: IN", __FUNCTION__);
=20
@@ -4195,7 +4196,12 @@ static int ucc_geth_probe(struct of_device* ofde=
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

