From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 1/2] r8169:prevent enable hardware tx/rx too early
Date: Tue, 2 Dec 2014 16:48:30 +0800
Message-ID: <1417510111-3568-2-git-send-email-hau@realtek.com>
References: <1417510111-3568-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417510111-3568-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For RTL8168G/GU/H/EP and RTL8411B remove enable tx/rx from its own hw_start
function. This will prevent enable tx/rx before complete hardware tx/rx
setting.

Tx/Rx will be enabled in the end of function rtl_hw_start_8168.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index cf154f7..7f4515f 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5934,7 +5934,6 @@ static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
 	rtl_w0w1_eri(tp, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
 	rtl_eri_write(tp, 0x2f8, ERIAR_MASK_0011, 0x1d8f, ERIAR_EXGMAC);
 
-	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 	RTL_W32(MISC, RTL_R32(MISC) & ~RXDV_GATED_EN);
 	RTL_W8(MaxTxPacketSize, EarlySize);
 
@@ -6027,7 +6026,6 @@ static void rtl_hw_start_8168h_1(struct rtl8169_private *tp)
 
 	rtl_eri_write(tp, 0x5f0, ERIAR_MASK_0011, 0x4f87, ERIAR_EXGMAC);
 
-	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 	RTL_W32(MISC, RTL_R32(MISC) & ~RXDV_GATED_EN);
 	RTL_W8(MaxTxPacketSize, EarlySize);
 
@@ -6109,7 +6107,6 @@ static void rtl_hw_start_8168ep(struct rtl8169_private *tp)
 
 	rtl_eri_write(tp, 0x5f0, ERIAR_MASK_0011, 0x4f87, ERIAR_EXGMAC);
 
-	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 	RTL_W32(MISC, RTL_R32(MISC) & ~RXDV_GATED_EN);
 	RTL_W8(MaxTxPacketSize, EarlySize);
 
-- 
1.9.1
