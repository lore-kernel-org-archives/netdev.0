From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 3/6] r8169: csi_ops signature change.
Date: Tue, 10 Jul 2012 00:44:07 +0200
Message-ID: <52989f0e429a97bc9075245e2e14ece2a4ebca5c.1341872752.git.romieu@fr.zoreil.com>
References: <cover.1341872752.git.romieu@fr.zoreil.com>
Cc: David Miller <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59231 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752534Ab2GIW4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 18:56:38 -0400
In-Reply-To: <cover.1341872752.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1341872752.git.romieu@fr.zoreil.com>
References: <cover.1341872752.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |   23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 5360f6d..3e07fa6 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -743,8 +743,8 @@ struct rtl8169_private {
 	} jumbo_ops;
 
 	struct csi_ops {
-		void (*write)(void __iomem *, int, int);
-		u32 (*read)(void __iomem *, int);
+		void (*write)(struct rtl8169_private *, int, int);
+		u32 (*read)(struct rtl8169_private *, int);
 	} csi_ops;
 
 	int (*set_speed)(struct net_device *, u8 aneg, u16 sp, u8 dpx, u32 adv);
@@ -4398,15 +4398,12 @@ static void rtl_hw_start_8169(struct net_device *dev)
 static void rtl_csi_write(struct rtl8169_private *tp, int addr, int value)
 {
 	if (tp->csi_ops.write)
-		tp->csi_ops.write(tp->mmio_addr, addr, value);
+		tp->csi_ops.write(tp, addr, value);
 }
 
 static u32 rtl_csi_read(struct rtl8169_private *tp, int addr)
 {
-	if (tp->csi_ops.read)
-		return tp->csi_ops.read(tp->mmio_addr, addr);
-	else
-		return ~0;
+	return tp->csi_ops.read ? tp->csi_ops.read(tp, addr) : ~0;
 }
 
 static void rtl_csi_access_enable(struct rtl8169_private *tp, u32 bits)
@@ -4427,8 +4424,9 @@ static void rtl_csi_access_enable_2(struct rtl8169_private *tp)
 	rtl_csi_access_enable(tp, 0x27000000);
 }
 
-static void r8169_csi_write(void __iomem *ioaddr, int addr, int value)
+static void r8169_csi_write(struct rtl8169_private *tp, int addr, int value)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned int i;
 
 	RTL_W32(CSIDR, value);
@@ -4442,8 +4440,9 @@ static void r8169_csi_write(void __iomem *ioaddr, int addr, int value)
 	}
 }
 
-static u32 r8169_csi_read(void __iomem *ioaddr, int addr)
+static u32 r8169_csi_read(struct rtl8169_private *tp, int addr)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	u32 value = ~0x00;
 	unsigned int i;
 
@@ -4461,8 +4460,9 @@ static u32 r8169_csi_read(void __iomem *ioaddr, int addr)
 	return value;
 }
 
-static void r8402_csi_write(void __iomem *ioaddr, int addr, int value)
+static void r8402_csi_write(struct rtl8169_private *tp, int addr, int value)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned int i;
 
 	RTL_W32(CSIDR, value);
@@ -4477,8 +4477,9 @@ static void r8402_csi_write(void __iomem *ioaddr, int addr, int value)
 	}
 }
 
-static u32 r8402_csi_read(void __iomem *ioaddr, int addr)
+static u32 r8402_csi_read(struct rtl8169_private *tp, int addr)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	u32 value = ~0x00;
 	unsigned int i;
 
-- 
1.7.10.4
