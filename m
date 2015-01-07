From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 02/11] r8169:update rtl8168e and rtl8168evl jumbo frame patch
Date: Thu, 8 Jan 2015 00:40:17 +0800
Message-ID: <1420648826-12972-3-git-send-email-hau@realtek.com>
References: <1420648826-12972-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:41848 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753871AbbAGQkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 11:40:35 -0500
In-Reply-To: <1420648826-12972-1-git-send-email-hau@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For RTL8168E and RTL8168EVL, these two chips do not need to change pcie max
read request size when jumbo frame is enabled.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 2f97476..5bfd0b9 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4934,7 +4934,6 @@ static void r8168e_hw_jumbo_enable(struct rtl8169_private *tp)
 	RTL_W8(MaxTxPacketSize, 0x3f);
 	RTL_W8(Config3, RTL_R8(Config3) | Jumbo_En0);
 	RTL_W8(Config4, RTL_R8(Config4) | 0x01);
-	rtl_tx_performance_tweak(tp->pci_dev, 0x2 << MAX_READ_REQUEST_SHIFT);
 }
 
 static void r8168e_hw_jumbo_disable(struct rtl8169_private *tp)
@@ -4944,7 +4943,6 @@ static void r8168e_hw_jumbo_disable(struct rtl8169_private *tp)
 	RTL_W8(MaxTxPacketSize, 0x0c);
 	RTL_W8(Config3, RTL_R8(Config3) & ~Jumbo_En0);
 	RTL_W8(Config4, RTL_R8(Config4) & ~0x01);
-	rtl_tx_performance_tweak(tp->pci_dev, 0x5 << MAX_READ_REQUEST_SHIFT);
 }
 
 static void r8168b_0_hw_jumbo_enable(struct rtl8169_private *tp)
-- 
1.9.1
