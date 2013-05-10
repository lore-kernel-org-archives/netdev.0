From: Jongsung Kim <neidhard.kim@lge.com>
Subject: [PATCH v2 1/4] net: phy: realtek: simplify multiple drivers registration
Date: Fri, 10 May 2013 16:29:24 +0900
Message-ID: <1368170967-20589-1-git-send-email-neidhard.kim@lge.com>
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

Use the phy_drivers_register and phy_drivers_unregister to
simplify registration and error handling. The two existing
phy_driver structures are converted to an array of the
structures to do this.

Signed-off-by: Jongsung Kim <neidhard.kim@lge.com>
---
 drivers/net/phy/realtek.c |   65 ++++++++++++++++++++-------------------------
 1 files changed, 29 insertions(+), 36 deletions(-)

diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index 8e7af83..f902107 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -64,50 +64,43 @@ static int rtl8211e_config_intr(struct phy_device *phydev)
 	return err;
 }
 
-/* RTL8211B */
-static struct phy_driver rtl8211b_driver = {
-	.phy_id		= 0x001cc912,
-	.name		= "RTL8211B Gigabit Ethernet",
-	.phy_id_mask	= 0x001fffff,
-	.features	= PHY_GBIT_FEATURES,
-	.flags		= PHY_HAS_INTERRUPT,
-	.config_aneg	= &genphy_config_aneg,
-	.read_status	= &genphy_read_status,
-	.ack_interrupt	= &rtl821x_ack_interrupt,
-	.config_intr	= &rtl8211b_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
-};
-
-/* RTL8211E */
-static struct phy_driver rtl8211e_driver = {
-	.phy_id		= 0x001cc915,
-	.name		= "RTL8211E Gigabit Ethernet",
-	.phy_id_mask	= 0x001fffff,
-	.features	= PHY_GBIT_FEATURES,
-	.flags		= PHY_HAS_INTERRUPT,
-	.config_aneg	= &genphy_config_aneg,
-	.read_status	= &genphy_read_status,
-	.ack_interrupt	= &rtl821x_ack_interrupt,
-	.config_intr	= &rtl8211e_config_intr,
-	.suspend	= genphy_suspend,
-	.resume		= genphy_resume,
-	.driver		= { .owner = THIS_MODULE,},
+static struct phy_driver realtek_drv[] = {
+	{	/* RTL8211B */
+		.phy_id		= 0x001cc912,
+		.name		= "RTL8211B Gigabit Ethernet",
+		.phy_id_mask	= 0x001fffff,
+		.features	= PHY_GBIT_FEATURES,
+		.flags		= PHY_HAS_INTERRUPT,
+		.config_aneg	= &genphy_config_aneg,
+		.read_status	= &genphy_read_status,
+		.ack_interrupt	= &rtl821x_ack_interrupt,
+		.config_intr	= &rtl8211b_config_intr,
+		.driver		= { .owner = THIS_MODULE,},
+	},
+	{	/* RTL8211E */
+		.phy_id		= 0x001cc915,
+		.name		= "RTL8211E Gigabit Ethernet",
+		.phy_id_mask	= 0x001fffff,
+		.features	= PHY_GBIT_FEATURES,
+		.flags		= PHY_HAS_INTERRUPT,
+		.config_aneg	= &genphy_config_aneg,
+		.read_status	= &genphy_read_status,
+		.ack_interrupt	= &rtl821x_ack_interrupt,
+		.config_intr	= &rtl8211e_config_intr,
+		.suspend	= genphy_suspend,
+		.resume		= genphy_resume,
+		.driver		= { .owner = THIS_MODULE,},
+	},
 };
 
 static int __init realtek_init(void)
 {
-	int ret;
-
-	ret = phy_driver_register(&rtl8211b_driver);
-	if (ret < 0)
-		return -ENODEV;
-	return phy_driver_register(&rtl8211e_driver);
+	return phy_drivers_register(realtek_drv, ARRAY_SIZE(realtek_drv));
 }
 
 static void __exit realtek_exit(void)
 {
-	phy_driver_unregister(&rtl8211b_driver);
-	phy_driver_unregister(&rtl8211e_driver);
+	phy_drivers_unregister(realtek_drv, ARRAY_SIZE(realtek_drv));
 }
 
 module_init(realtek_init);
-- 
1.7.1
