From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 03/11] r8169:change the way of setting rtl8168dp ephy parameters.
Date: Thu, 8 Jan 2015 00:40:18 +0800
Message-ID: <1420648826-12972-4-git-send-email-hau@realtek.com>
References: <1420648826-12972-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:41850 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753980AbbAGQkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 11:40:36 -0500
In-Reply-To: <1420648826-12972-1-git-send-email-hau@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original way is wrong. I correct it in this patch.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 15 ++++-----------
 1 file changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 5bfd0b9..0fc7e62 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5731,11 +5731,10 @@ static void rtl_hw_start_8168d_4(struct rtl8169_private *tp)
 	void __iomem *ioaddr = tp->mmio_addr;
 	struct pci_dev *pdev = tp->pci_dev;
 	static const struct ephy_info e_info_8168d_4[] = {
-		{ 0x0b, ~0,	0x48 },
-		{ 0x19, 0x20,	0x50 },
-		{ 0x0c, ~0,	0x20 }
+		{ 0x0b, 0x0000,	0x0048 },
+		{ 0x19, 0x0020,	0x0050 },
+		{ 0x0c, 0x0100,	0x0020 }
 	};
-	int i;
 
 	rtl_csi_access_enable_1(tp);
 
@@ -5744,13 +5743,7 @@ static void rtl_hw_start_8168d_4(struct rtl8169_private *tp)
 
 	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
-	for (i = 0; i < ARRAY_SIZE(e_info_8168d_4); i++) {
-		const struct ephy_info *e = e_info_8168d_4 + i;
-		u16 w;
-
-		w = rtl_ephy_read(tp, e->offset);
-		rtl_ephy_write(tp, 0x03, (w & e->mask) | e->bits);
-	}
+	rtl_ephy_init(tp, e_info_8168d_4, ARRAY_SIZE(e_info_8168d_4));
 
 	rtl_enable_clock_request(pdev);
 }
-- 
1.9.1
