From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 3/5] r8169: fix WOL setting for 8105 and 8111evl
Date: Sat, 17 Sep 2011 11:58:11 +0200
Message-ID: <20110917095811.GD21630@electric-eye.fr.zoreil.com>
References: <20110917095617.GA21630@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54292 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677Ab1IQJ6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 05:58:48 -0400
Content-Disposition: inline
In-Reply-To: <20110917095617.GA21630@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtl8105, rtl8111E, and rtl8111evl need enable RxConfig bit 1 ~ 3
for supporting wake on lan.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index b55fba7..78c1d58 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3320,9 +3320,16 @@ static void r810x_phy_power_up(struct rtl8169_private *tp)
 
 static void r810x_pll_power_down(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+
 	if (__rtl8169_get_wol(tp) & WAKE_ANY) {
 		rtl_writephy(tp, 0x1f, 0x0000);
 		rtl_writephy(tp, MII_BMCR, 0x0000);
+
+		if (tp->mac_version == RTL_GIGA_MAC_VER_29 ||
+		    tp->mac_version == RTL_GIGA_MAC_VER_30)
+			RTL_W32(RxConfig, RTL_R32(RxConfig) | AcceptBroadcast |
+				AcceptMulticast | AcceptMyPhys);
 		return;
 	}
 
@@ -3418,7 +3425,8 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 		rtl_writephy(tp, MII_BMCR, 0x0000);
 
 		if (tp->mac_version == RTL_GIGA_MAC_VER_32 ||
-		    tp->mac_version == RTL_GIGA_MAC_VER_33)
+		    tp->mac_version == RTL_GIGA_MAC_VER_33 ||
+		    tp->mac_version == RTL_GIGA_MAC_VER_34)
 			RTL_W32(RxConfig, RTL_R32(RxConfig) | AcceptBroadcast |
 				AcceptMulticast | AcceptMyPhys);
 		return;
-- 
1.7.6
