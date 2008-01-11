From: frederic RODO <f.rodo@til-technologies.fr>
Subject: [PATCH] dm9161: add configuration for MII/RMII
Date: Fri, 11 Jan 2008 19:28:43 +0100
Message-ID: <4787B55B.6040202@til-technologies.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp25.orange.fr ([193.252.22.23]:51419 "EHLO smtp25.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759759AbYAKSaC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2008 13:30:02 -0500
Received: from smtp.til-technologies.fr (LAubervilliers-151-12-100-178.w193-252.abo.wanadoo.fr [193.252.204.178])
	by mwinf2557.orange.fr (SMTP Server) with ESMTP id F166A1C001DE
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 19:30:00 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

diff --git a/drivers/net/phy/davicom.c b/drivers/net/phy/davicom.c
index 7ed632d..6bdc32f 100644
--- a/drivers/net/phy/davicom.c
+++ b/drivers/net/phy/davicom.c
@@ -37,6 +37,7 @@

  #define MII_DM9161_SCR		0x10
  #define MII_DM9161_SCR_INIT	0x0610
+#define MII_DM9161_SCR_RMII	0x0100

  /* DM9161 Interrupt Register */
  #define MII_DM9161_INTR	0x15
@@ -103,7 +104,7 @@ static int dm9161_config_aneg(struct phy_device *phydev)

  static int dm9161_config_init(struct phy_device *phydev)
  {
-	int err;
+	int err, temp;

  	/* Isolate the PHY */
  	err = phy_write(phydev, MII_BMCR, BMCR_ISOLATE);
@@ -111,8 +112,19 @@ static int dm9161_config_init(struct phy_device 
*phydev)
  	if (err < 0)
  		return err;

-	/* Do not bypass the scrambler/descrambler */
-	err = phy_write(phydev, MII_DM9161_SCR, MII_DM9161_SCR_INIT);
+	/* Do not bypass the scrambler/descrambler , configure MII Mode */
+	switch (phydev->interface) {
+	case PHY_INTERFACE_MODE_MII:
+		temp = MII_DM9161_SCR_INIT;
+		break;
+	case PHY_INTERFACE_MODE_RMII:
+		temp =  MII_DM9161_SCR_INIT | MII_DM9161_SCR_RMII;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	err = phy_write(phydev, MII_DM9161_SCR, temp);

  	if (err < 0)
  		return err;
Signed-off-by: Frederic RODO <f.rodo@til-technologies.fr>

-------------------------------------------------------------------------
Les informations précédentes peuvent être confidentielles ou privilégiées.
Si vous n'êtes pas le destinataire prévu de ce mail, veuillez en notifier 
l'expéditeur en répondant à ce message puis supprimez-en toute trace 
de vos systèmes.

TIL Technologies
Parc du Golf, Bat 43
350 rue J.R Guilibert Gautier de la Lauzière 
13856 AIX EN PROVENCE
Tel. : +33 4 42 37 11 77
-------------------------------------------------------------------------


