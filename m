From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 3/6] r8169: phy init for the 8169sce
Date: Tue, 11 Aug 2009 07:43:29 +0200
Message-ID: <20090811054329.GD16446@electric-eye.fr.zoreil.com>
References: <20090811054039.GA16446@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: edward_hsu@realtek.com.tw, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60940 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750904AbZHKLvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 07:51:03 -0400
Content-Disposition: inline
In-Reply-To: <20090811054039.GA16446@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Synced with Realtek's 6.011.00 r8169 driver.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   56 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 56 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 6c4b879..8672288 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1389,6 +1389,59 @@ static void rtl8169sb_hw_phy_config(void __iomem *ioaddr)
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
+static void rtl8169sce_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0001 },
+		{ 0x04, 0x0000 },
+		{ 0x03, 0x00a1 },
+		{ 0x02, 0x0008 },
+		{ 0x01, 0x0120 },
+		{ 0x00, 0x1000 },
+		{ 0x04, 0x0800 },
+		{ 0x04, 0x9000 },
+		{ 0x03, 0x802f },
+		{ 0x02, 0x4f02 },
+		{ 0x01, 0x0409 },
+		{ 0x00, 0xf099 },
+		{ 0x04, 0x9800 },
+		{ 0x04, 0xa000 },
+		{ 0x03, 0xdf01 },
+		{ 0x02, 0xdf20 },
+		{ 0x01, 0xff95 },
+		{ 0x00, 0xba00 },
+		{ 0x04, 0xa800 },
+		{ 0x04, 0xf000 },
+		{ 0x03, 0xdf01 },
+		{ 0x02, 0xdf20 },
+		{ 0x01, 0x101a },
+		{ 0x00, 0xa0ff },
+		{ 0x04, 0xf800 },
+		{ 0x04, 0x0000 },
+		{ 0x1f, 0x0000 },
+
+		{ 0x1f, 0x0001 },
+		{ 0x0b, 0x8480 },
+		{ 0x1f, 0x0000 },
+
+		{ 0x1f, 0x0001 },
+		{ 0x18, 0x67c7 },
+		{ 0x04, 0x2000 },
+		{ 0x03, 0x002f },
+		{ 0x02, 0x4360 },
+		{ 0x01, 0x0109 },
+		{ 0x00, 0x3022 },
+		{ 0x04, 0x2800 },
+		{ 0x1f, 0x0000 },
+
+		{ 0x1f, 0x0001 },
+		{ 0x17, 0x0cc0 },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
 static void rtl8168bb_hw_phy_config(void __iomem *ioaddr)
 {
 	struct phy_reg phy_reg_init[] = {
@@ -1628,6 +1681,9 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_04:
 		rtl8169sb_hw_phy_config(ioaddr);
 		break;
+	case RTL_GIGA_MAC_VER_06:
+		rtl8169sce_hw_phy_config(ioaddr);
+		break;
 	case RTL_GIGA_MAC_VER_07:
 	case RTL_GIGA_MAC_VER_08:
 	case RTL_GIGA_MAC_VER_09:
-- 
1.6.2.5

