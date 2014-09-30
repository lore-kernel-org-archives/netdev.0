From: Chun-Hao Lin <hau@realtek.com>
Subject: [PATCH net-next 02/10] r8169:add disable/enable RTL8168G pll function
Date: Tue, 30 Sep 2014 23:00:22 +0800
Message-ID: <1412089230-10208-2-git-send-email-hau@realtek.com>
References: <1412089230-10208-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chun-Hao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412089230-10208-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Chun-Hao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 000bd6c..6d68229 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4375,6 +4375,7 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_41:
 		rtl_w1w0_eri(tp, 0x1a8, ERIAR_MASK_1111, 0x00000000,
 			     0xfc000000, ERIAR_EXGMAC);
+		RTL_W8(PMCH, RTL_R8(PMCH) & ~0x80);
 		break;
 	}
 }
@@ -4399,8 +4400,10 @@ static void r8168_pll_power_up(struct rtl8169_private *tp)
 		break;
 	case RTL_GIGA_MAC_VER_40:
 	case RTL_GIGA_MAC_VER_41:
+		RTL_W8(PMCH, RTL_R8(PMCH) | 0xc0);
 		rtl_w1w0_eri(tp, 0x1a8, ERIAR_MASK_1111, 0xfc000000,
 			     0x00000000, ERIAR_EXGMAC);
+
 		break;
 	}
 
-- 
1.8.3.2
