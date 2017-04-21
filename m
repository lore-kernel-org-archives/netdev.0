From: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
Subject: [PATCH 1/4] net: phy: realtek: change macro name for
 page select register
Date: Sat, 22 Apr 2017 07:24:33 +0800
Message-ID: <20170421232436.10924-2-icenowy@aosc.io>
References: <20170421232436.10924-1-icenowy@aosc.io>
Reply-To: icenowy-h8G6r0blFSE@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-sunxi+bncBDS6XAN6ZADRBWVJ5LDQKGQERSDMNTY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170421232436.10924-1-icenowy-h8G6r0blFSE@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

From: Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>

The page select register also exists on RTL8211E PHY (although it
behaves slightly differently).

Change the register macro name to remove the F.

Signed-off-by: Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
---
 drivers/net/phy/realtek.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index 9cbe645e3d89..d820d00addf6 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -22,11 +22,13 @@
 #define RTL821x_INER		0x12
 #define RTL821x_INER_INIT	0x6400
 #define RTL821x_INSR		0x13
+
+#define RTL8211_PAGE_SELECT	0x1f
+
 #define RTL8211E_INER_LINK_STATUS 0x400
 
 #define RTL8211F_INER_LINK_STATUS 0x0010
 #define RTL8211F_INSR		0x1d
-#define RTL8211F_PAGE_SELECT	0x1f
 #define RTL8211F_TX_DELAY	0x100
 
 MODULE_DESCRIPTION("Realtek PHY driver");
@@ -46,10 +48,10 @@ static int rtl8211f_ack_interrupt(struct phy_device *phydev)
 {
 	int err;
 
-	phy_write(phydev, RTL8211F_PAGE_SELECT, 0xa43);
+	phy_write(phydev, RTL8211_PAGE_SELECT, 0xa43);
 	err = phy_read(phydev, RTL8211F_INSR);
 	/* restore to default page 0 */
-	phy_write(phydev, RTL8211F_PAGE_SELECT, 0x0);
+	phy_write(phydev, RTL8211_PAGE_SELECT, 0x0);
 
 	return (err < 0) ? err : 0;
 }
@@ -102,7 +104,7 @@ static int rtl8211f_config_init(struct phy_device *phydev)
 	if (ret < 0)
 		return ret;
 
-	phy_write(phydev, RTL8211F_PAGE_SELECT, 0xd08);
+	phy_write(phydev, RTL8211_PAGE_SELECT, 0xd08);
 	reg = phy_read(phydev, 0x11);
 
 	/* enable TX-delay for rgmii-id and rgmii-txid, otherwise disable it */
@@ -114,7 +116,7 @@ static int rtl8211f_config_init(struct phy_device *phydev)
 
 	phy_write(phydev, 0x11, reg);
 	/* restore to default page 0 */
-	phy_write(phydev, RTL8211F_PAGE_SELECT, 0x0);
+	phy_write(phydev, RTL8211_PAGE_SELECT, 0x0);
 
 	return 0;
 }
-- 
2.12.2
