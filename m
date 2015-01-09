From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next v2 6/8] r8169:update pcie ephy parameters to decrease the resume time from L0s to L0
Date: Fri, 9 Jan 2015 23:26:04 +0800
Message-ID: <1420817166-9868-7-git-send-email-hau@realtek.com>
References: <1420817166-9868-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:57161 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933108AbbAIP0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 10:26:20 -0500
In-Reply-To: <1420817166-9868-1-git-send-email-hau@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For RTL8168EVL, RTL8168F, RTL8411, and RTL8105E, their pcie ephy will have bit
error check reset after receive FTS and cause pcie ephy enter recovery mode.
This will cause pcie ephy resume from L0s to L0 too slow.

This patch adjust the pcie ephy parameter to decrease the resume time from L0s
to L0.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index ade7144..483fa40 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5778,7 +5778,9 @@ static void rtl_hw_start_8168e_2(struct rtl8169_private *tp)
 	struct pci_dev *pdev = tp->pci_dev;
 	static const struct ephy_info e_info_8168e_2[] = {
 		{ 0x09, 0x0000,	0x0080 },
-		{ 0x19, 0x0000,	0x0224 }
+		{ 0x19, 0x0000,	0x0224 },
+		{ 0x00, 0x0000,	0x0008 },
+		{ 0x0c, 0x3df0,	0x0200 }
 	};
 
 	rtl_csi_access_enable_1(tp);
@@ -5850,7 +5852,9 @@ static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
 		{ 0x06, 0x00c0,	0x0020 },
 		{ 0x08, 0x0001,	0x0002 },
 		{ 0x09, 0x0000,	0x0080 },
-		{ 0x19, 0x0000,	0x0224 }
+		{ 0x19, 0x0000,	0x0224 },
+		{ 0x00, 0x0000,	0x0008 },
+		{ 0x0c, 0x3df0,	0x0200 }
 	};
 
 	rtl_hw_start_8168f(tp);
@@ -5865,17 +5869,19 @@ static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
 
 static void rtl_hw_start_8411(struct rtl8169_private *tp)
 {
-	static const struct ephy_info e_info_8168f_1[] = {
+	static const struct ephy_info e_info_8411[] = {
 		{ 0x06, 0x00c0,	0x0020 },
 		{ 0x0f, 0xffff,	0x5200 },
 		{ 0x1e, 0x0000,	0x4000 },
-		{ 0x19, 0x0000,	0x0224 }
+		{ 0x19, 0x0000,	0x0224 },
+		{ 0x00, 0x0000,	0x0008 },
+		{ 0x0c, 0x3df0,	0x0200 }
 	};
 
 	rtl_hw_start_8168f(tp);
 	rtl_pcie_state_l2l3_enable(tp, false);
 
-	rtl_ephy_init(tp, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
+	rtl_ephy_init(tp, e_info_8411, ARRAY_SIZE(e_info_8411));
 
 	rtl_w0w1_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0x0000, ERIAR_EXGMAC);
 }
@@ -6397,7 +6403,8 @@ static void rtl_hw_start_8105e_1(struct rtl8169_private *tp)
 		{ 0x03,	0, 0x0001 },
 		{ 0x19,	0, 0x0100 },
 		{ 0x19,	0, 0x0004 },
-		{ 0x0a,	0, 0x0020 }
+		{ 0x0a,	0, 0x0020 },
+		{ 0x05,	0, 0x2000 }
 	};
 
 	/* Force LAN exit from ASPM if Rx/Tx are not idle */
-- 
1.9.1
