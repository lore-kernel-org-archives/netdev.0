From: Jongsung Kim <neidhard.kim@lge.com>
Subject: [PATCH v2 4/4] net: phy: realtek: cleanup code
Date: Fri, 10 May 2013 16:29:27 +0900
Message-ID: <1368170967-20589-4-git-send-email-neidhard.kim@lge.com>
References: <201305081910.27203.neidhard.kim@lge.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: r58129@freescale.com, davem@davemloft.net,
	sergei.shtylyov@cogentembedded.com, peppe.cavallaro@st.com,
	chohnstaedt@innominate.com, timur@freescale.com,
	heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com,
	neidhard.kim@lge.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201305081910.27203.neidhard.kim@lge.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch cleans up the drivers code by:

- using a consistent way to reference functions
- removing unused macro-definitions
- removing unnecessary new-lines
- making ack_interrupt functions shorter.

Signed-off-by: Jongsung Kim <neidhard.kim@lge.com>
---
 drivers/net/phy/realtek.c |   29 ++++++++++-------------------
 1 files changed, 10 insertions(+), 19 deletions(-)

diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index 6f0726a..fd09844 100644
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
 
@@ -112,8 +103,8 @@ static struct phy_driver realtek_drv[] = {
 		.read_status	= &genphy_read_status,
 		.ack_interrupt	= &rtl8201f_ack_interrupt,
 		.config_intr	= &rtl8201f_config_intr,
-		.suspend	= genphy_suspend,
-		.resume		= genphy_resume,
+		.suspend	= &genphy_suspend,
+		.resume		= &genphy_resume,
 		.driver		= { .owner = THIS_MODULE,},
 	},
 	{	/* RTL8211B */
@@ -126,8 +117,8 @@ static struct phy_driver realtek_drv[] = {
 		.read_status	= &genphy_read_status,
 		.ack_interrupt	= &rtl821x_ack_interrupt,
 		.config_intr	= &rtl8211b_config_intr,
-		.suspend	= genphy_suspend,
-		.resume		= genphy_resume,
+		.suspend	= &genphy_suspend,
+		.resume		= &genphy_resume,
 		.driver		= { .owner = THIS_MODULE,},
 	},
 	{	/* RTL8211E */
@@ -140,8 +131,8 @@ static struct phy_driver realtek_drv[] = {
 		.read_status	= &genphy_read_status,
 		.ack_interrupt	= &rtl821x_ack_interrupt,
 		.config_intr	= &rtl8211e_config_intr,
-		.suspend	= genphy_suspend,
-		.resume		= genphy_resume,
+		.suspend	= &genphy_suspend,
+		.resume		= &genphy_resume,
 		.driver		= { .owner = THIS_MODULE,},
 	},
 };
-- 
1.7.1
