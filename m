From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 1/2] r8169: remove rtl_ocpdr_cond.
Date: Wed, 18 Jul 2012 00:09:43 +0200
Message-ID: <3a83ad12b850c3c5b89fa9008bdd0c0782f0cf68.1342562326.git.romieu@fr.zoreil.com>
References: <cover.1342562326.git.romieu@fr.zoreil.com>
Cc: David Miller <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49893 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756353Ab2GQWWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 18:22:45 -0400
In-Reply-To: <cover.1342562326.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1342562326.git.romieu@fr.zoreil.com>
References: <cover.1342562326.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>

It is not needed for mac_ocp_{write / read}. Actually bit 31 of OCPDR
does not change and r8168_mac_ocp_read always returns ~0.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
Tested-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |   12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index c29c5fb..1f27318 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1043,13 +1043,6 @@ static void rtl_w1w0_phy_ocp(struct rtl8169_private *tp, int reg, int p, int m)
 	r8168_phy_ocp_write(tp, reg, (val | p) & ~m);
 }
 
-DECLARE_RTL_COND(rtl_ocpdr_cond)
-{
-	void __iomem *ioaddr = tp->mmio_addr;
-
-	return RTL_R32(OCPDR) & OCPAR_FLAG;
-}
-
 static void r8168_mac_ocp_write(struct rtl8169_private *tp, u32 reg, u32 data)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -1058,8 +1051,6 @@ static void r8168_mac_ocp_write(struct rtl8169_private *tp, u32 reg, u32 data)
 		return;
 
 	RTL_W32(OCPDR, OCPAR_FLAG | (reg << 15) | data);
-
-	rtl_udelay_loop_wait_low(tp, &rtl_ocpdr_cond, 25, 10);
 }
 
 static u16 r8168_mac_ocp_read(struct rtl8169_private *tp, u32 reg)
@@ -1071,8 +1062,7 @@ static u16 r8168_mac_ocp_read(struct rtl8169_private *tp, u32 reg)
 
 	RTL_W32(OCPDR, reg << 15);
 
-	return rtl_udelay_loop_wait_high(tp, &rtl_ocpdr_cond, 25, 10) ?
-		RTL_R32(OCPDR) : ~0;
+	return RTL_R32(OCPDR);
 }
 
 #define OCP_STD_PHY_BASE	0xa400
-- 
1.7.10.4
