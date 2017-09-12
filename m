From: Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
Subject: [PATCH net-next v2 1/2] net: phy: realtek: rename RTL8211F_PAGE_SELECT to RTL821x_PAGE_SELECT
Date: Tue, 12 Sep 2017 18:54:35 +0900
Message-ID: <1505210076-32311-1-git-send-email-hayashi.kunihiko@socionext.com>
Cc: Jassi Brar <jaswinder.singh@linaro.org>,
        Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.socionext.com ([202.248.49.38]:35968 "EHLO mx.socionext.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751286AbdILJyq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 12 Sep 2017 05:54:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This renames the definition of page select register from
RTL8211F_PAGE_SELECT to RTL821x_PAGE_SELECT to use it across models.

Signed-off-by: Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
---
Changes since v1:
 - new patch in this series
---
 drivers/net/phy/realtek.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index 9cbe645..99c3297 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -22,11 +22,11 @@
 #define RTL821x_INER		0x12
 #define RTL821x_INER_INIT	0x6400
 #define RTL821x_INSR		0x13
+#define RTL821x_PAGE_SELECT	0x1f
 #define RTL8211E_INER_LINK_STATUS 0x400
 
 #define RTL8211F_INER_LINK_STATUS 0x0010
 #define RTL8211F_INSR		0x1d
-#define RTL8211F_PAGE_SELECT	0x1f
 #define RTL8211F_TX_DELAY	0x100
 
 MODULE_DESCRIPTION("Realtek PHY driver");
@@ -46,10 +46,10 @@ static int rtl8211f_ack_interrupt(struct phy_device *phydev)
 {
 	int err;
 
-	phy_write(phydev, RTL8211F_PAGE_SELECT, 0xa43);
+	phy_write(phydev, RTL821x_PAGE_SELECT, 0xa43);
 	err = phy_read(phydev, RTL8211F_INSR);
 	/* restore to default page 0 */
-	phy_write(phydev, RTL8211F_PAGE_SELECT, 0x0);
+	phy_write(phydev, RTL821x_PAGE_SELECT, 0x0);
 
 	return (err < 0) ? err : 0;
 }
@@ -102,7 +102,7 @@ static int rtl8211f_config_init(struct phy_device *phydev)
 	if (ret < 0)
 		return ret;
 
-	phy_write(phydev, RTL8211F_PAGE_SELECT, 0xd08);
+	phy_write(phydev, RTL821x_PAGE_SELECT, 0xd08);
 	reg = phy_read(phydev, 0x11);
 
 	/* enable TX-delay for rgmii-id and rgmii-txid, otherwise disable it */
@@ -114,7 +114,7 @@ static int rtl8211f_config_init(struct phy_device *phydev)
 
 	phy_write(phydev, 0x11, reg);
 	/* restore to default page 0 */
-	phy_write(phydev, RTL8211F_PAGE_SELECT, 0x0);
+	phy_write(phydev, RTL821x_PAGE_SELECT, 0x0);
 
 	return 0;
 }
-- 
2.7.4
