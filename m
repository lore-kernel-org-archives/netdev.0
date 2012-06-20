From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169: RxConfig hack for the 8168evl.
Date: Thu, 21 Jun 2012 00:09:18 +0200
Message-ID: <20120620220918.GA2785@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, thomas.pi@arcor.de
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:47622 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757760Ab2FTWTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 18:19:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 8168evl (RTL_GIGA_MAC_VER_34) based Gigabyte GA-990FXA motherboards
are very prone to NETDEV watchdog problems without this change. See
https://bugzilla.kernel.org/show_bug.cgi?id=42899 for instance.

I don't know why it *works*. It's depressingly effective though.

For the record:
- the problem may go along IOMMU (AMD-Vi) errors but it really looks
  like a red herring.
- the patch sets the RX_MULTI_EN bit. If the 8168c doc is any guide,
  the chipset now fetches several Rx descriptors at a time.
- long ago the driver ignored the RX_MULTI_EN bit.
  e542a2269f232d61270ceddd42b73a4348dee2bb changed the RxConfig
  settings. Whatever the problem it's now labeled a regression.
- Realtek's own driver can identify two different 8168evl devices
  (CFG_METHOD_16 and CFG_METHOD_17) where the r8169 driver only
  sees one. It sucks.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---

 Hayes, any hindsight ?

 drivers/net/ethernet/realtek/r8169.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 7260aa7..d7a04e0 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3894,6 +3894,7 @@ static void rtl_init_rxcfg(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_22:
 	case RTL_GIGA_MAC_VER_23:
 	case RTL_GIGA_MAC_VER_24:
+	case RTL_GIGA_MAC_VER_34:
 		RTL_W32(RxConfig, RX128_INT_EN | RX_MULTI_EN | RX_DMA_BURST);
 		break;
 	default:
-- 
1.7.10.2
