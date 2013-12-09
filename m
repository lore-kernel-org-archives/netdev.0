From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] micrel: add support for KSZ8041RNLI
Date: Tue, 10 Dec 2013 02:20:41 +0300
Message-ID: <201312100220.42153.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:49467 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856Ab3LIWUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 17:20:44 -0500
Received: by mail-la0-f47.google.com with SMTP id ep20so2081755lab.34
        for <netdev@vger.kernel.org>; Mon, 09 Dec 2013 14:20:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Renesas R-Car development boards use KSZ8041RNLI PHY which for some reason has
ID of 0x00221537 that is not documented for KSZ8041-family PHYs and does not
match the  documented ID of  0x0022151x (where 'x' is the revision).  We have
to add the new #define PHY_ID_* and new ksphy_driver[] entry, almost the same
as KSZ8041 one, differing only in the 'phy_id' and 'name' fields. 

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
This patch is atop of DaveM's 'net-next.git' repo.

 drivers/net/phy/micrel.c   |   15 +++++++++++++++
 include/linux/micrel_phy.h |    2 ++
 2 files changed, 17 insertions(+)

Index: net-next/drivers/net/phy/micrel.c
===================================================================
--- net-next.orig/drivers/net/phy/micrel.c
+++ net-next/drivers/net/phy/micrel.c
@@ -336,6 +336,21 @@ static struct phy_driver ksphy_driver[] 
 	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
 }, {
+	.phy_id		= PHY_ID_KSZ8041RNLI,
+	.phy_id_mask	= 0x00fffff0,
+	.name		= "Micrel KSZ8041RNLI",
+	.features	= PHY_BASIC_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= kszphy_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= kszphy_ack_interrupt,
+	.config_intr	= kszphy_config_intr,
+	.suspend	= genphy_suspend,
+	.resume		= genphy_resume,
+	.driver		= { .owner = THIS_MODULE,},
+}, {
 	.phy_id		= PHY_ID_KSZ8051,
 	.phy_id_mask	= 0x00fffff0,
 	.name		= "Micrel KSZ8051",
Index: net-next/include/linux/micrel_phy.h
===================================================================
--- net-next.orig/include/linux/micrel_phy.h
+++ net-next/include/linux/micrel_phy.h
@@ -22,6 +22,8 @@
 #define PHY_ID_KSZ8021		0x00221555
 #define PHY_ID_KSZ8031		0x00221556
 #define PHY_ID_KSZ8041		0x00221510
+/* undocumented */
+#define PHY_ID_KSZ8041RNLI	0x00221537
 #define PHY_ID_KSZ8051		0x00221550
 /* same id: ks8001 Rev. A/B, and ks8721 Rev 3. */
 #define PHY_ID_KSZ8001		0x0022161A
