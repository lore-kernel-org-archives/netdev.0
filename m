From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next v2 4/8] r8169:rtl8168dp rev.c pcie ephy setting is the same as rtl8168dp rev.b
Date: Fri, 9 Jan 2015 23:26:02 +0800
Message-ID: <1420817166-9868-5-git-send-email-hau@realtek.com>
References: <1420817166-9868-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:57159 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932480AbbAIP0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 10:26:18 -0500
In-Reply-To: <1420817166-9868-1-git-send-email-hau@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thease two chips should use the same pcie ephy parameters. So only need
function rtl_hw_start_8168d_4. Function rtl_hw_start_8168dp is uncessary.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 20 +-------------------
 1 file changed, 1 insertion(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 540a6b8..928e35a 100644
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
@@ -6271,11 +6256,8 @@ static void rtl_hw_start_8168(struct net_device *dev)
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
