From: Jarl Friis <jarl@softace.dk>
Subject: =?UTF-8?q?=5BPATCH=202/2=5D=20Using=20LP=20firmware=20for=20taking=20advantage=20of=20the=20low-power=20capabilities=2E?=
Date: Wed, 19 Sep 2012 13:18:13 +0200
Message-ID: <1348053493-22955-2-git-send-email-jarl@softace.dk>
References: <1348053493-22955-1-git-send-email-jarl@softace.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jarl Friis <jarl@softace.dk>
To: Stefano Brivio <stefano.brivio@polimi.it>,
	=?UTF-8?q?G=C3=A1bor=20Stefanik?= <netrolller.3d@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:51328 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752910Ab2ISLTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 07:19:02 -0400
Received: by mail-lb0-f174.google.com with SMTP id gj3so717247lbb.19
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 04:19:01 -0700 (PDT)
In-Reply-To: <1348053493-22955-1-git-send-email-jarl@softace.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is using the LP specific firmware to better take advantage of the
Low-Power capabilities.

Signed-off-by: Jarl Friis <jarl@softace.dk>
---
 drivers/net/wireless/b43/main.c |   16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43=
/main.c
index 202a0eb..9ee6030 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -8,6 +8,7 @@
   Copyright (c) 2005 Danny van Dyk <kugelfang@gentoo.org>
   Copyright (c) 2005 Andreas Jaggi <andreas.jaggi@waterwave.ch>
   Copyright (c) 2010-2011 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
+  Copyright (c) 2012 Jarl Friis <jarl@softace.dk>
=20
   SDIO support
   Copyright (c) 2009 Albert Herranz <albert_herranz@yahoo.es>
@@ -72,6 +73,7 @@ MODULE_FIRMWARE("b43/ucode11.fw");
 MODULE_FIRMWARE("b43/ucode13.fw");
 MODULE_FIRMWARE("b43/ucode14.fw");
 MODULE_FIRMWARE("b43/ucode15.fw");
+MODULE_FIRMWARE("b43/ucode16_lp.fw");
 MODULE_FIRMWARE("b43/ucode16_mimo.fw");
 MODULE_FIRMWARE("b43/ucode5.fw");
 MODULE_FIRMWARE("b43/ucode9.fw");
@@ -2208,6 +2210,12 @@ static int b43_try_request_fw(struct b43_request=
_fw_context *ctx)
 			else
 				goto err_no_ucode;
 			break;
+		case B43_PHYTYPE_LP:
+			if (rev >=3D 16)
+				filename =3D "ucode16_lp";
+			else
+				goto err_no_ucode;
+			break;
 		case B43_PHYTYPE_HT:
 			if (rev =3D=3D 29)
 				filename =3D "ucode29_mimo";
@@ -2277,8 +2285,10 @@ static int b43_try_request_fw(struct b43_request=
_fw_context *ctx)
 			filename =3D "lp0initvals13";
 		else if (rev =3D=3D 14)
 			filename =3D "lp0initvals14";
-		else if (rev >=3D 15)
+		else if (rev =3D=3D 15)
 			filename =3D "lp0initvals15";
+		else if (rev >=3D 16)
+			filename =3D "lp0initvals16";
 		else
 			goto err_no_initvals;
 		break;
@@ -2336,8 +2346,10 @@ static int b43_try_request_fw(struct b43_request=
_fw_context *ctx)
 			filename =3D "lp0bsinitvals13";
 		else if (rev =3D=3D 14)
 			filename =3D "lp0bsinitvals14";
-		else if (rev >=3D 15)
+		else if (rev =3D=3D 15)
 			filename =3D "lp0bsinitvals15";
+		else if (rev >=3D 16)
+			filename =3D "lp0bsinitvals16";
 		else
 			goto err_no_initvals;
 		break;
--=20
1.7.9.5
