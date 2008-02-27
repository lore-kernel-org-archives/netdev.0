From: frederic Rodo <f.rodo@til-technologies.fr>
Subject: [PATCH] dm9161: add configuration for MII/RMII
Date: Wed, 27 Feb 2008 12:58:37 +0100
Message-ID: <47C5506D.9080302@til-technologies.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jgarzik@pobox.com, avictor.za@gmail.com, afleming@freescale.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp25.orange.fr ([193.252.22.22]:20751 "EHLO smtp25.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753457AbYB0L7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 06:59:46 -0500
Received: from smtp.til-technologies.fr (LAubervilliers-151-12-100-178.w193-252.abo.wanadoo.fr [193.252.204.178])
	by mwinf2522.orange.fr (SMTP Server) with ESMTP id 073AF1C0008A
	for <netdev@vger.kernel.org>; Wed, 27 Feb 2008 12:59:43 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

I've send this patch on netdev on January. It's add the MII/RMII config=
uration for davicom dm9161. Can you merge it into=20
the mainline?

thanks

diff --git a/drivers/net/phy/davicom.c b/drivers/net/phy/davicom.c
index 7ed632d..6bdc32f 100644
--- a/drivers/net/phy/davicom.c
+++ b/drivers/net/phy/davicom.c
@@ -37,6 +37,7 @@

  #define MII_DM9161_SCR        0x10
  #define MII_DM9161_SCR_INIT    0x0610
+#define MII_DM9161_SCR_RMII    0x0100

  /* DM9161 Interrupt Register */
  #define MII_DM9161_INTR    0x15
@@ -103,7 +104,7 @@ static int dm9161_config_aneg(struct phy_device *ph=
ydev)

  static int dm9161_config_init(struct phy_device *phydev)
  {
-    int err;
+    int err, temp;

      /* Isolate the PHY */
      err =3D phy_write(phydev, MII_BMCR, BMCR_ISOLATE);
@@ -111,8 +112,19 @@ static int dm9161_config_init(struct phy_device *p=
hydev)
      if (err < 0)
          return err;

-    /* Do not bypass the scrambler/descrambler */
-    err =3D phy_write(phydev, MII_DM9161_SCR, MII_DM9161_SCR_INIT);
+    /* Do not bypass the scrambler/descrambler , configure MII Mode */
+    switch (phydev->interface) {
+    case PHY_INTERFACE_MODE_MII:
+        temp =3D MII_DM9161_SCR_INIT;
+        break;
+    case PHY_INTERFACE_MODE_RMII:
+        temp =3D  MII_DM9161_SCR_INIT | MII_DM9161_SCR_RMII;
+        break;
+    default:
+        return -EINVAL;
+    }
+
+    err =3D phy_write(phydev, MII_DM9161_SCR, temp);

      if (err < 0)
          return err;
Signed-off-by: Frederic Rodo <f.rodo@til-technologies.fr>

-----------------------------------------------------------------------=
--
Les informations pr=E9c=E9dentes peuvent =EAtre confidentielles ou priv=
il=E9gi=E9es.
Si vous n'=EAtes pas le destinataire pr=E9vu de ce mail, veuillez en no=
tifier=20
l'exp=E9diteur en r=E9pondant =E0 ce message puis supprimez-en toute tr=
ace=20
de vos syst=E8mes.

TIL Technologies
Parc du Golf, Bat 43
350 rue J.R Guilibert Gautier de la Lauzi=E8re=20
13856 AIX EN PROVENCE
Tel. : +33 4 42 37 11 77
-----------------------------------------------------------------------=
--


