From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 08/11] r8169:update rtl8411 pcie ephy parameter
Date: Thu, 8 Jan 2015 00:40:23 +0800
Message-ID: <1420648826-12972-9-git-send-email-hau@realtek.com>
References: <1420648826-12972-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420648826-12972-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rtl8411 may return to PCIe L0 from PCIe L0s low power mode too slow.
The following ephy parameters are for this issue.
{ 0x00, 0x0000,     0x0008 }
{ 0x0c, 0x3df0,     0x0200 }

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index bafa132..e92eece 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5869,17 +5869,19 @@ static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
 
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
-- 
1.9.1
