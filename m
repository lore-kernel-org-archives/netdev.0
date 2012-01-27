From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 4/7] r8169: factor out IntrMask writes.
Date: Fri, 27 Jan 2012 21:56:56 +0100
Message-ID: <20120127205656.GD24507@electric-eye.fr.zoreil.com>
References: <20120127205412.GA24152@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57439 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395Ab2A0VHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 16:07:50 -0500
Content-Disposition: inline
In-Reply-To: <20120127205412.GA24152@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 6d74931..9f9abb5 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1184,6 +1184,13 @@ static u8 rtl8168d_efuse_read(void __iomem *ioaddr, int reg_addr)
 	return value;
 }
 
+static void rtl_irq_enable(struct rtl8169_private *tp, u16 bits)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	RTL_W16(IntrMask, bits);
+}
+
 static void rtl8169_irq_mask_and_ack(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -4383,6 +4390,8 @@ static void rtl_hw_start(struct net_device *dev)
 
 	tp->hw_start(dev);
 
+	rtl_irq_enable(tp, tp->intr_event);
+
 	netif_start_queue(dev);
 }
 
@@ -4510,9 +4519,6 @@ static void rtl_hw_start_8169(struct net_device *dev)
 
 	/* no early-rx interrupts */
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
-
-	/* Enable all known interrupts by setting the interrupt mask. */
-	RTL_W16(IntrMask, tp->intr_event);
 }
 
 static void rtl_csi_access_enable(void __iomem *ioaddr, u32 bits)
@@ -4981,8 +4987,6 @@ static void rtl_hw_start_8168(struct net_device *dev)
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
-
-	RTL_W16(IntrMask, tp->intr_event);
 }
 
 #define R810X_CPCMD_QUIRK_MASK (\
@@ -5140,8 +5144,6 @@ static void rtl_hw_start_8101(struct net_device *dev)
 	rtl_set_rx_mode(dev);
 
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xf000);
-
-	RTL_W16(IntrMask, tp->intr_event);
 }
 
 static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
-- 
1.7.6.5
