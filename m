From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 10/13] r8169: phy init for the 8168
Date: Thu, 18 Oct 2007 23:02:02 +0200
Message-ID: <20071018210202.GK31724@electric-eye.fr.zoreil.com>
References: <20071018204846.GC8594@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40521 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751869AbXJRVGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 17:06:20 -0400
Content-Disposition: inline
In-Reply-To: <20071018204846.GC8594@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The values have been extracted from Realtek's r8168 driver
version 8.002.00.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   52 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index aed36b7..cb7bb7f 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1168,6 +1168,19 @@ static void rtl8169_print_mac_version(struct rtl8169_private *tp)
 	dprintk("mac_version = 0x%02x\n", tp->mac_version);
 }
 
+struct phy_reg {
+	u16 reg;
+	u16 val;
+};
+
+static void rtl_phy_write(void __iomem *ioaddr, struct phy_reg *regs, int len)
+{
+	while (len-- > 0) {
+		mdio_write(ioaddr, regs->reg, regs->val);
+		regs++;
+	}
+}
+
 static void rtl8169s_hw_phy_config(void __iomem *ioaddr)
 {
 	struct {
@@ -1227,6 +1240,39 @@ static void rtl8169sb_hw_phy_config(void __iomem *ioaddr)
 	mdio_write(ioaddr, 31, 0x0000);
 }
 
+static void rtl8168cp_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0000 },
+		{ 0x1d, 0x0f00 },
+		{ 0x1f, 0x0002 },
+		{ 0x0c, 0x1ec8 },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
+static void rtl8168c_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0002 },
+		{ 0x00, 0x88d4 },
+		{ 0x01, 0x82b1 },
+		{ 0x03, 0x7002 },
+		{ 0x08, 0x9e30 },
+		{ 0x09, 0x01f0 },
+		{ 0x0a, 0x5500 },
+		{ 0x0c, 0x00c8 },
+		{ 0x1f, 0x0003 },
+		{ 0x12, 0xc096 },
+		{ 0x16, 0x000a },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
 static void rtl_hw_phy_config(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -1244,6 +1290,12 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_04:
 		rtl8169sb_hw_phy_config(ioaddr);
 		break;
+	case RTL_GIGA_MAC_VER_18:
+		rtl8168cp_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_19:
+		rtl8168c_hw_phy_config(ioaddr);
+		break;
 	default:
 		break;
 	}
-- 
1.5.2.4

