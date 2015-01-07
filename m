From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 01/11] r8169:change rtl8168dp jumbo frame patch
Date: Thu, 8 Jan 2015 00:40:16 +0800
Message-ID: <1420648826-12972-2-git-send-email-hau@realtek.com>
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

For RTL8168DP, its jumbo frame patch is the same as RTL8168DP. So use RTL8168C
jumbo frame patch instead and reomve function "r8168dp_hw_jumbo_enable" and
"r8168dp_hw_jumbo_disable".

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 28 ++++++----------------------
 1 file changed, 6 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 14a1c5c..2f97476 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4927,20 +4927,6 @@ static void r8168c_hw_jumbo_disable(struct rtl8169_private *tp)
 	rtl_tx_performance_tweak(tp->pci_dev, 0x5 << MAX_READ_REQUEST_SHIFT);
 }
 
-static void r8168dp_hw_jumbo_enable(struct rtl8169_private *tp)
-{
-	void __iomem *ioaddr = tp->mmio_addr;
-
-	RTL_W8(Config3, RTL_R8(Config3) | Jumbo_En0);
-}
-
-static void r8168dp_hw_jumbo_disable(struct rtl8169_private *tp)
-{
-	void __iomem *ioaddr = tp->mmio_addr;
-
-	RTL_W8(Config3, RTL_R8(Config3) & ~Jumbo_En0);
-}
-
 static void r8168e_hw_jumbo_enable(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -5014,16 +5000,13 @@ static void rtl_init_jumbo_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_24:
 	case RTL_GIGA_MAC_VER_25:
 	case RTL_GIGA_MAC_VER_26:
-		ops->disable	= r8168c_hw_jumbo_disable;
-		ops->enable	= r8168c_hw_jumbo_enable;
-		break;
 	case RTL_GIGA_MAC_VER_27:
 	case RTL_GIGA_MAC_VER_28:
-		ops->disable	= r8168dp_hw_jumbo_disable;
-		ops->enable	= r8168dp_hw_jumbo_enable;
+	case RTL_GIGA_MAC_VER_31:
+		ops->disable	= r8168c_hw_jumbo_disable;
+		ops->enable	= r8168c_hw_jumbo_enable;
 		break;
-	case RTL_GIGA_MAC_VER_31: /* Wild guess. Needs info from Realtek. */
-	case RTL_GIGA_MAC_VER_32:
+	case RTL_GIGA_MAC_VER_32: /* Wild guess. Needs info from Realtek. */
 	case RTL_GIGA_MAC_VER_33:
 	case RTL_GIGA_MAC_VER_34:
 		ops->disable	= r8168e_hw_jumbo_disable;
@@ -5758,7 +5741,8 @@ static void rtl_hw_start_8168d_4(struct rtl8169_private *tp)
 
 	rtl_csi_access_enable_1(tp);
 
-	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	if (tp->dev->mtu <= ETH_DATA_LEN)
+		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
 	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
-- 
1.9.1
