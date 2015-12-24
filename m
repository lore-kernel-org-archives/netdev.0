From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 2/2] r8169:Update the way of reading RTL8168H PHY register "rg_saw_cnt"
Date: Thu, 24 Dec 2015 21:15:27 +0800
Message-ID: <1450962927-19077-3-git-send-email-hau@realtek.com>
References: <1450962927-19077-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450962927-19077-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The vlaue of RTL8168H PHY register "rg_saw_cnt" only valid from bit0 to bit13.
When read this register, add bitwise-anding its value with 0x3fff.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 11cc32b..58365bc 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6136,7 +6136,7 @@ static void rtl_hw_start_8168h_1(struct rtl8169_private *tp)
 	rtl_pcie_state_l2l3_enable(tp, false);
 
 	rtl_writephy(tp, 0x1f, 0x0c42);
-	rg_saw_cnt = rtl_readphy(tp, 0x13);
+	rg_saw_cnt = (rtl_readphy(tp, 0x13) & 0x3fff);
 	rtl_writephy(tp, 0x1f, 0x0000);
 	if (rg_saw_cnt > 0) {
 		u16 sw_cnt_1ms_ini;
-- 
1.9.1
