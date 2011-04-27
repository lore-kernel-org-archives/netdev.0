From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH rfc 1/5] r8169: style cleanups.
Date: Wed, 27 Apr 2011 22:36:54 +0200
Message-ID: <20110427203654.GD19708@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39960 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756121Ab1D0Upe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 16:45:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
---
 drivers/net/r8169.c |   80 +++++++++++++++++++++++---------------------------
 1 files changed, 37 insertions(+), 43 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 025dedd..0bb0c0d 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -346,7 +346,7 @@ enum rtl8168_registers {
 #define OCPAR_GPHY_READ_CMD		0x0000f060
 	RDSAR1			= 0xd0,	/* 8168c only. Undocumented on 8168dp */
 	MISC			= 0xf0,	/* 8168e only. */
-	txpla_rst			= (1 << 29)
+#define TXPLA_RST			(1 << 29)
 };
 
 enum rtl_register_content {
@@ -424,7 +424,7 @@ enum rtl_register_content {
 	BWF		= (1 << 6),	/* Accept Broadcast wakeup frame */
 	MWF		= (1 << 5),	/* Accept Multicast wakeup frame */
 	UWF		= (1 << 4),	/* Accept Unicast wakeup frame */
-	spi_en		= (1 << 3),
+	Spi_en		= (1 << 3),
 	LanWake		= (1 << 1),	/* LanWake enable/disable */
 	PMEStatus	= (1 << 0),	/* PME status can be reset by PCI RST# */
 
@@ -731,17 +731,19 @@ static void rtl8168_oob_notify(struct rtl8169_private *tp, u8 cmd)
 #define OOB_CMD_DRIVER_START	0x05
 #define OOB_CMD_DRIVER_STOP	0x06
 
+static u16 rtl8168_get_ocp_reg(struct rtl8169_private *tp)
+{
+	return (tp->mac_version == RTL_GIGA_MAC_VER_31) ? 0xb8 : 0x10;
+}
+
 static void rtl8168_driver_start(struct rtl8169_private *tp)
 {
+	u16 reg;
 	int i;
-	u32 reg;
 
 	rtl8168_oob_notify(tp, OOB_CMD_DRIVER_START);
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_31)
-		reg = 0xb8;
-	else
-		reg = 0x10;
+	reg = rtl8168_get_ocp_reg(tp);
 
 	for (i = 0; i < 10; i++) {
 		msleep(10);
@@ -752,15 +754,12 @@ static void rtl8168_driver_start(struct rtl8169_private *tp)
 
 static void rtl8168_driver_stop(struct rtl8169_private *tp)
 {
+	u16 reg;
 	int i;
-	u32 reg;
 
 	rtl8168_oob_notify(tp, OOB_CMD_DRIVER_STOP);
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_31)
-		reg = 0xb8;
-	else
-		reg = 0x10;
+	reg = rtl8168_get_ocp_reg(tp);
 
 	for (i = 0; i < 10; i++) {
 		msleep(10);
@@ -771,17 +770,9 @@ static void rtl8168_driver_stop(struct rtl8169_private *tp)
 
 static int r8168dp_check_dash(struct rtl8169_private *tp)
 {
-	u32 reg;
-
-	if (tp->mac_version == RTL_GIGA_MAC_VER_31)
-		reg = 0xb8;
-	else
-		reg = 0x10;
+	u16 reg = rtl8168_get_ocp_reg(tp);
 
-	if (ocp_read(tp, 0xF, reg) & 0x00008000)
-		return 1;
-	else
-		return 0;
+	return (ocp_read(tp, 0x0f, reg) & 0x00008000) ? 1 : 0;
 }
 
 static void r8169_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
@@ -2546,7 +2537,7 @@ static void rtl8168e_hw_phy_config(struct rtl8169_private *tp)
 	/* For impedance matching */
 	rtl_writephy(tp, 0x1f, 0x0002);
 	rtl_w1w0_phy(tp, 0x08, 0x8000, 0x7f00);
-	rtl_writephy(tp, 0x1F, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
 
 	/* PHY auto speed down */
 	rtl_writephy(tp, 0x1f, 0x0007);
@@ -2704,6 +2695,9 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_30:
 		rtl8105e_hw_phy_config(tp);
 		break;
+	case RTL_GIGA_MAC_VER_31:
+		/* None. */
+		break;
 	case RTL_GIGA_MAC_VER_32:
 		rtl8168e_1_hw_phy_config(tp);
 		break;
@@ -3134,8 +3128,8 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 		return;
 	}
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_32 ||
-	    tp->mac_version == RTL_GIGA_MAC_VER_33)
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_32) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_33))
 		rtl_ephy_write(ioaddr, 0x19, 0xff64);
 
 	if (__rtl8169_get_wol(tp) & WAKE_ANY) {
@@ -3652,12 +3646,11 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 	/* Disable interrupts */
 	rtl8169_irq_mask_and_ack(ioaddr);
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
-	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
-	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_27) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_28) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_31)) {
 		while (RTL_R8(TxPoll) & NPQ)
 			udelay(20);
-
 	}
 
 	/* Reset the chipset */
@@ -4117,10 +4110,10 @@ static void rtl_hw_start_8168e(void __iomem *ioaddr, struct pci_dev *pdev)
 	rtl_disable_clock_request(pdev);
 
 	/* Reset tx FIFO pointer */
-	RTL_W32(MISC, RTL_R32(MISC) | txpla_rst);
-	RTL_W32(MISC, RTL_R32(MISC) & ~txpla_rst);
+	RTL_W32(MISC, RTL_R32(MISC) | TXPLA_RST);
+	RTL_W32(MISC, RTL_R32(MISC) & ~TXPLA_RST);
 
-	RTL_W8(Config5, RTL_R8(Config5) & ~spi_en);
+	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
 }
 
 static void rtl_hw_start_8168(struct net_device *dev)
@@ -4142,8 +4135,8 @@ static void rtl_hw_start_8168(struct net_device *dev)
 	RTL_W16(IntrMitigate, 0x5151);
 
 	/* Work around for RxFIFO overflow. */
-	if (tp->mac_version == RTL_GIGA_MAC_VER_11 ||
-	    tp->mac_version == RTL_GIGA_MAC_VER_22) {
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_11) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_22)) {
 		tp->intr_event |= RxFIFOOver | PCSTimeout;
 		tp->intr_event &= ~RxOverflow;
 	}
@@ -4204,6 +4197,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_28:
 		rtl_hw_start_8168d_4(ioaddr, pdev);
 		break;
+
 	case RTL_GIGA_MAC_VER_31:
 		rtl_hw_start_8168dp(ioaddr, pdev);
 		break;
@@ -5414,15 +5408,15 @@ static int rtl8169_runtime_idle(struct device *device)
 }
 
 static const struct dev_pm_ops rtl8169_pm_ops = {
-	.suspend = rtl8169_suspend,
-	.resume = rtl8169_resume,
-	.freeze = rtl8169_suspend,
-	.thaw = rtl8169_resume,
-	.poweroff = rtl8169_suspend,
-	.restore = rtl8169_resume,
-	.runtime_suspend = rtl8169_runtime_suspend,
-	.runtime_resume = rtl8169_runtime_resume,
-	.runtime_idle = rtl8169_runtime_idle,
+	.suspend		= rtl8169_suspend,
+	.resume			= rtl8169_resume,
+	.freeze			= rtl8169_suspend,
+	.thaw			= rtl8169_resume,
+	.poweroff		= rtl8169_suspend,
+	.restore		= rtl8169_resume,
+	.runtime_suspend	= rtl8169_runtime_suspend,
+	.runtime_resume		= rtl8169_runtime_resume,
+	.runtime_idle		= rtl8169_runtime_idle,
 };
 
 #define RTL8169_PM_OPS	(&rtl8169_pm_ops)
-- 
1.7.4.4

