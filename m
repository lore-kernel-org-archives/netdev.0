From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: [PATCH] PHY: Add RTL8201CP phy_driver to realtek
Date: Mon, 11 Nov 2013 15:46:06 +0100
Message-ID: <1384181166-15501-1-git-send-email-jonas.jensen@gmail.com>
Cc: r58129@freescale.com, linux-kernel@vger.kernel.org,
	Jonas Jensen <jonas.jensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add RTL8201CP phy_driver.

Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>
---

Notes:
    RTL8201CP PHY is used on MOXA UC-711X hardware(s).
    
    Adding the ID allows the PHY to be probed (by libphy), and eventually connected from MAC code.
    
    Applies to next-20131111

 drivers/net/phy/realtek.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index 138de83..fa1d69a 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -64,6 +64,18 @@ static int rtl8211e_config_intr(struct phy_device *phydev)
 	return err;
 }
 
+/* RTL8201CP */
+static struct phy_driver rtl8201cp_driver = {
+	.phy_id         = 0x00008201,
+	.name           = "RTL8201CP Ethernet",
+	.phy_id_mask    = 0x0000ffff,
+	.features       = PHY_BASIC_FEATURES,
+	.flags          = PHY_HAS_INTERRUPT,
+	.config_aneg    = &genphy_config_aneg,
+	.read_status    = &genphy_read_status,
+	.driver         = { .owner = THIS_MODULE,},
+};
+
 /* RTL8211B */
 static struct phy_driver rtl8211b_driver = {
 	.phy_id		= 0x001cc912,
@@ -98,6 +110,9 @@ static int __init realtek_init(void)
 {
 	int ret;
 
+	ret = phy_driver_register(&rtl8201cp_driver);
+	if (ret < 0)
+		return -ENODEV;
 	ret = phy_driver_register(&rtl8211b_driver);
 	if (ret < 0)
 		return -ENODEV;
-- 
1.8.2.1
