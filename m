From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 13/13] r8169: more phy init for the 8168
Date: Thu, 18 Oct 2007 23:02:24 +0200
Message-ID: <20071018210224.GN31724@electric-eye.fr.zoreil.com>
References: <20071018204846.GC8594@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36938 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758288AbXJRVGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 17:06:40 -0400
Content-Disposition: inline
In-Reply-To: <20071018204846.GC8594@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Realtek's r8168 driver version 8.003.00 adds new init sequences
(they do not appear in version 8.002.00).

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   34 ++++++++++++++++++++++++++++++++++
 1 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 8ffd573..e8960f2 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1243,6 +1243,16 @@ static void rtl8169sb_hw_phy_config(void __iomem *ioaddr)
 
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
+static void rtl8168b_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0000 },
+		{ 0x10, 0xf41b },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
 
 static void rtl8168cp_hw_phy_config(void __iomem *ioaddr)
 {
@@ -1279,6 +1289,22 @@ static void rtl8168c_hw_phy_config(void __iomem *ioaddr)
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
+static void rtl8168cx_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0000 },
+		{ 0x12, 0x2300 },
+		{ 0x1f, 0x0003 },
+		{ 0x16, 0x0f0a },
+		{ 0x1f, 0x0000 },
+		{ 0x1f, 0x0002 },
+		{ 0x0c, 0x7eb8 },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
 static void rtl_hw_phy_config(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -1296,12 +1322,20 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_04:
 		rtl8169sb_hw_phy_config(ioaddr);
 		break;
+	case RTL_GIGA_MAC_VER_11:
+	case RTL_GIGA_MAC_VER_12:
+	case RTL_GIGA_MAC_VER_17:
+		rtl8168b_hw_phy_config(ioaddr);
+		break;
 	case RTL_GIGA_MAC_VER_18:
 		rtl8168cp_hw_phy_config(ioaddr);
 		break;
 	case RTL_GIGA_MAC_VER_19:
 		rtl8168c_hw_phy_config(ioaddr);
 		break;
+	case RTL_GIGA_MAC_VER_20:
+		rtl8168cx_hw_phy_config(ioaddr);
+		break;
 	default:
 		break;
 	}
-- 
1.5.2.4

