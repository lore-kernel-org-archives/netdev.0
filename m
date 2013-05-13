From: Jongsung Kim <neidhard.kim@lge.com>
Subject: [PATCH v3 4/4] net: phy: realtek: cleanup code
Date: Mon, 13 May 2013 18:58:40 +0900
Message-ID: <1368439120-26322-4-git-send-email-neidhard.kim@lge.com>
References: <518CD784.1030709@cogentembedded.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jongsung Kim <neidhard.kim@lge.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: davem@davemloft.net, peppe.cavallaro@st.com,
	chohnstaedt@innominate.com, heiko.carstens@de.ibm.com,
	schwidefsky@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lgeamrelo02.lge.com ([156.147.1.126]:61889 "EHLO
	LGEAMRELO02.lge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060Ab3EMKOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 May 2013 06:14:37 -0400
In-Reply-To: <518CD784.1030709@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch cleans up the drivers code by:

- using a consistent way to reference functions
- removing unused macro-definitions
- removing unnecessary new-lines
- making ack_interrupt functions shorter.

Changes in v3:
* don't use the '&' to reference functions (pointed by Sergei Shtylyov)

Changes in v2:
* separated patch (pointed by Francois Romieu and Sergei Shtylyov)
* make functions shorter (pointed by Sergei Shtylyov)

Signed-off-by: Jongsung Kim <neidhard.kim@lge.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
---
 drivers/net/phy/realtek.c |   41 ++++++++++++++++-------------------------
 1 files changed, 16 insertions(+), 25 deletions(-)

diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index 6f0726a..b55aea2 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -21,9 +21,6 @@
 #define RTL8201F_INER		0x13
 #define RTL8201F_INER_MASK	0x3800
 
-#define RTL821x_PHYSR		0x11
-#define RTL821x_PHYSR_DUPLEX	0x2000
-#define RTL821x_PHYSR_SPEED	0xc000
 #define RTL821x_INER		0x12
 #define RTL821x_INER_INIT	0x6400
 #define RTL821x_INSR		0x13
@@ -36,18 +33,14 @@ MODULE_LICENSE("GPL");
 
 static int rtl8201f_ack_interrupt(struct phy_device *phydev)
 {
-	int err;
-
-	err = phy_read(phydev, RTL8201F_INSR);
+	int err = phy_read(phydev, RTL8201F_INSR);
 
 	return (err < 0) ? err : 0;
 }
 
 static int rtl821x_ack_interrupt(struct phy_device *phydev)
 {
-	int err;
-
-	err = phy_read(phydev, RTL821x_INSR);
+	int err = phy_read(phydev, RTL821x_INSR);
 
 	return (err < 0) ? err : 0;
 }
@@ -80,8 +73,7 @@ static int rtl8211b_config_intr(struct phy_device *phydev)
 	int err;
 
 	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
-		err = phy_write(phydev, RTL821x_INER,
-				RTL821x_INER_INIT);
+		err = phy_write(phydev, RTL821x_INER, RTL821x_INER_INIT);
 	else
 		err = phy_write(phydev, RTL821x_INER, 0);
 
@@ -93,8 +85,7 @@ static int rtl8211e_config_intr(struct phy_device *phydev)
 	int err;
 
 	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
-		err = phy_write(phydev, RTL821x_INER,
-				RTL8211E_INER_LINK_STAT);
+		err = phy_write(phydev, RTL821x_INER, RTL8211E_INER_LINK_STAT);
 	else
 		err = phy_write(phydev, RTL821x_INER, 0);
 
@@ -108,10 +99,10 @@ static struct phy_driver realtek_drv[] = {
 		.phy_id_mask	= 0x001fffff,
 		.features	= PHY_BASIC_FEATURES,
 		.flags		= PHY_HAS_INTERRUPT,
-		.config_aneg	= &genphy_config_aneg,
-		.read_status	= &genphy_read_status,
-		.ack_interrupt	= &rtl8201f_ack_interrupt,
-		.config_intr	= &rtl8201f_config_intr,
+		.config_aneg	= genphy_config_aneg,
+		.read_status	= genphy_read_status,
+		.ack_interrupt	= rtl8201f_ack_interrupt,
+		.config_intr	= rtl8201f_config_intr,
 		.suspend	= genphy_suspend,
 		.resume		= genphy_resume,
 		.driver		= { .owner = THIS_MODULE,},
@@ -122,10 +113,10 @@ static struct phy_driver realtek_drv[] = {
 		.phy_id_mask	= 0x001fffff,
 		.features	= PHY_GBIT_FEATURES,
 		.flags		= PHY_HAS_INTERRUPT,
-		.config_aneg	= &genphy_config_aneg,
-		.read_status	= &genphy_read_status,
-		.ack_interrupt	= &rtl821x_ack_interrupt,
-		.config_intr	= &rtl8211b_config_intr,
+		.config_aneg	= genphy_config_aneg,
+		.read_status	= genphy_read_status,
+		.ack_interrupt	= rtl821x_ack_interrupt,
+		.config_intr	= rtl8211b_config_intr,
 		.suspend	= genphy_suspend,
 		.resume		= genphy_resume,
 		.driver		= { .owner = THIS_MODULE,},
@@ -136,10 +127,10 @@ static struct phy_driver realtek_drv[] = {
 		.phy_id_mask	= 0x001fffff,
 		.features	= PHY_GBIT_FEATURES,
 		.flags		= PHY_HAS_INTERRUPT,
-		.config_aneg	= &genphy_config_aneg,
-		.read_status	= &genphy_read_status,
-		.ack_interrupt	= &rtl821x_ack_interrupt,
-		.config_intr	= &rtl8211e_config_intr,
+		.config_aneg	= genphy_config_aneg,
+		.read_status	= genphy_read_status,
+		.ack_interrupt	= rtl821x_ack_interrupt,
+		.config_intr	= rtl8211e_config_intr,
 		.suspend	= genphy_suspend,
 		.resume		= genphy_resume,
 		.driver		= { .owner = THIS_MODULE,},
-- 
1.7.1
