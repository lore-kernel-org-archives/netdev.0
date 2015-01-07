From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 05/11] r8169:remove function rtl_hw_start_8168dp
Date: Thu, 8 Jan 2015 00:40:20 +0800
Message-ID: <1420648826-12972-6-git-send-email-hau@realtek.com>
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

RTL_GIGA_MAC_VER_31 is RTL8168DP and it use the same ephy parameter as
RTL_GIGA_MAC_VER_28. So I use function rtl_hw_start_8168d_4 to set
RTL_GIGA_MAC_VER_31 ephy parameter and remove unnecessary function
rtl_hw_start_8168dp.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 20 +-------------------
 1 file changed, 1 insertion(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 15a0f5b..48d1f78 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5711,21 +5711,6 @@ static void rtl_hw_start_8168d(struct rtl8169_private *tp)
 	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
 }
 
-static void rtl_hw_start_8168dp(struct rtl8169_private *tp)
-{
-	void __iomem *ioaddr = tp->mmio_addr;
-	struct pci_dev *pdev = tp->pci_dev;
-
-	rtl_csi_access_enable_1(tp);
-
-	if (tp->dev->mtu <= ETH_DATA_LEN)
-		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
-
-	RTL_W8(MaxTxPacketSize, TxPacketMax);
-
-	rtl_disable_clock_request(pdev);
-}
-
 static void rtl_hw_start_8168d_4(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -6272,11 +6257,8 @@ static void rtl_hw_start_8168(struct net_device *dev)
 		break;
 
 	case RTL_GIGA_MAC_VER_28:
-		rtl_hw_start_8168d_4(tp);
-		break;
-
 	case RTL_GIGA_MAC_VER_31:
-		rtl_hw_start_8168dp(tp);
+		rtl_hw_start_8168d_4(tp);
 		break;
 
 	case RTL_GIGA_MAC_VER_32:
-- 
1.9.1
