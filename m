From: =?UTF-8?q?Michel=20D=C3=A4nzer?= <michel@daenzer.net>
Subject: [PATCH] r8169: Enable RX_MULTI_EN for RTL_GIGA_MAC_VER_40
Date: Tue, 15 Jul 2014 15:41:40 +0900
Message-ID: <1405406500-1208-1-git-send-email-michel@daenzer.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Without this, the ethernet port on my ASUS A88X Pro mainboard stops
working sometimes, with messages like these in dmesg:

AMD-Vi: Event logged [IO_PAGE_FAULT device=3D05:00.0 domain=3D0x001e ad=
dress=3D0x0000000000003000 flags=3D0x0050]
Signed-off-by: Michel D=C3=A4nzer <michel@daenzer.net>
---
 drivers/net/ethernet/realtek/r8169.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/etherne=
t/realtek/r8169.c
index be425ad..e577566 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4239,6 +4239,8 @@ static void rtl_init_rxcfg(struct rtl8169_private=
 *tp)
 		RTL_W32(RxConfig, RX128_INT_EN | RX_MULTI_EN | RX_DMA_BURST);
 		break;
 	case RTL_GIGA_MAC_VER_40:
+		RTL_W32(RxConfig, RX128_INT_EN | RX_MULTI_EN | RX_DMA_BURST | RX_EAR=
LY_OFF);
+		break;
 	case RTL_GIGA_MAC_VER_41:
 	case RTL_GIGA_MAC_VER_42:
 	case RTL_GIGA_MAC_VER_43:
--=20
2.0.0
