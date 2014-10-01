From: Chun-Hao Lin <hau@realtek.com>
Subject: [PATCH v2 net-next 05/10] r8169:add more chips to support magic packet v2
Date: Wed, 1 Oct 2014 23:17:16 +0800
Message-ID: <1412176641-24393-5-git-send-email-hau@realtek.com>
References: <1412176641-24393-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chun-Hao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412176641-24393-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For RTL8168F RTL8168FB RTL8168G RTL8168GU RTL8411 RTL8411B RTL8402 RTL8107E,
the magic packet enable bit is changed to eri 0xde bit0.

In this patch, change magic packet enable bit of these chips to eri 0xde bit0.

Signed-off-by: Chun-Hao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index c1e9661..070724c 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1546,8 +1546,20 @@ static u32 __rtl8169_get_wol(struct rtl8169_private *tp)
 	if (options & LinkUp)
 		wolopts |= WAKE_PHY;
 	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_34:
+	case RTL_GIGA_MAC_VER_35:
+	case RTL_GIGA_MAC_VER_36:
+	case RTL_GIGA_MAC_VER_37:
+	case RTL_GIGA_MAC_VER_38:
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
+	case RTL_GIGA_MAC_VER_42:
+	case RTL_GIGA_MAC_VER_43:
+	case RTL_GIGA_MAC_VER_44:
 	case RTL_GIGA_MAC_VER_45:
 	case RTL_GIGA_MAC_VER_46:
+	case RTL_GIGA_MAC_VER_47:
+	case RTL_GIGA_MAC_VER_48:
 		if (rtl_eri_read(tp, 0xdc, ERIAR_EXGMAC) & MagicPacket_v2)
 			wolopts |= WAKE_MAGIC;
 		break;
@@ -1601,8 +1613,20 @@ static void __rtl8169_set_wol(struct rtl8169_private *tp, u32 wolopts)
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 
 	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_34:
+	case RTL_GIGA_MAC_VER_35:
+	case RTL_GIGA_MAC_VER_36:
+	case RTL_GIGA_MAC_VER_37:
+	case RTL_GIGA_MAC_VER_38:
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
+	case RTL_GIGA_MAC_VER_42:
+	case RTL_GIGA_MAC_VER_43:
+	case RTL_GIGA_MAC_VER_44:
 	case RTL_GIGA_MAC_VER_45:
 	case RTL_GIGA_MAC_VER_46:
+	case RTL_GIGA_MAC_VER_47:
+	case RTL_GIGA_MAC_VER_48:
 		tmp = ARRAY_SIZE(cfg) - 1;
 		if (wolopts & WAKE_MAGIC)
 			rtl_w1w0_eri(tp,
@@ -7666,8 +7690,20 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	RTL_W8(Config1, RTL_R8(Config1) | PMEnable);
 	RTL_W8(Config5, RTL_R8(Config5) & (BWF | MWF | UWF | LanWake | PMEStatus));
 	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_34:
+	case RTL_GIGA_MAC_VER_35:
+	case RTL_GIGA_MAC_VER_36:
+	case RTL_GIGA_MAC_VER_37:
+	case RTL_GIGA_MAC_VER_38:
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
+	case RTL_GIGA_MAC_VER_42:
+	case RTL_GIGA_MAC_VER_43:
+	case RTL_GIGA_MAC_VER_44:
 	case RTL_GIGA_MAC_VER_45:
 	case RTL_GIGA_MAC_VER_46:
+	case RTL_GIGA_MAC_VER_47:
+	case RTL_GIGA_MAC_VER_48:
 		if (rtl_eri_read(tp, 0xdc, ERIAR_EXGMAC) & MagicPacket_v2)
 			tp->features |= RTL_FEATURE_WOL;
 		if ((RTL_R8(Config3) & LinkUp) != 0)
-- 
1.8.3.2
