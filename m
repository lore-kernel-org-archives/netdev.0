From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 0/2] Pull request for 'davem-next.r8169' branch
Date: Wed, 18 Jul 2012 00:09:42 +0200
Message-ID: <cover.1342562326.git.romieu@fr.zoreil.com>
Cc: David Miller <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49891 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516Ab2GQWWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 18:22:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'davem-next.r8169' in repository

git://violet.fr.zoreil.com/romieu/linux davem-next.r8169

to get the changes below.

Distance from 'davem-next' (5abf7f7e0f6bdbfcac737f636497d7016d9507eb)
---------------------------------------------------------------------

82e316efbd1c68946c8760f930b81d73e9c4425a
3a83ad12b850c3c5b89fa9008bdd0c0782f0cf68

Diffstat
--------

 drivers/net/ethernet/realtek/r8169.c |   15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

Shortlog
--------

Francois Romieu (1):
      r8169: verbose error message.

Hayes Wang (1):
      r8169: remove rtl_ocpdr_cond.

Patch
-----

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index c29c5fb..be4e00f 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -865,7 +865,8 @@ static bool rtl_loop_wait(struct rtl8169_private *tp, const struct rtl_cond *c,
 		if (c->check(tp) == high)
 			return true;
 	}
-	netif_err(tp, drv, tp->dev, c->msg);
+	netif_err(tp, drv, tp->dev, "%s == %d (loop: %d, delay: %d).\n",
+		  c->msg, !high, n, d);
 	return false;
 }
 
@@ -1043,13 +1044,6 @@ static void rtl_w1w0_phy_ocp(struct rtl8169_private *tp, int reg, int p, int m)
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
@@ -1058,8 +1052,6 @@ static void r8168_mac_ocp_write(struct rtl8169_private *tp, u32 reg, u32 data)
 		return;
 
 	RTL_W32(OCPDR, OCPAR_FLAG | (reg << 15) | data);
-
-	rtl_udelay_loop_wait_low(tp, &rtl_ocpdr_cond, 25, 10);
 }
 
 static u16 r8168_mac_ocp_read(struct rtl8169_private *tp, u32 reg)
@@ -1071,8 +1063,7 @@ static u16 r8168_mac_ocp_read(struct rtl8169_private *tp, u32 reg)
 
 	RTL_W32(OCPDR, reg << 15);
 
-	return rtl_udelay_loop_wait_high(tp, &rtl_ocpdr_cond, 25, 10) ?
-		RTL_R32(OCPDR) : ~0;
+	return RTL_R32(OCPDR);
 }
 
 #define OCP_STD_PHY_BASE	0xa400
-- 
Ueimor
