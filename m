From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169: fix sticky accepts packet bits in RxConfig.
Date: Tue, 19 Jul 2011 17:40:25 +0200
Message-ID: <20110719154025.GA7667@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53202 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010Ab1GSPzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 11:55:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'davem-next.r8169' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git davem-next.r8169

to get the change below.

NB: it is related to but it does not solve BZ 39252.

Distance from 'davem-next' (81fc70d86527a1450560709500ca5f52e661da1f)
---------------------------------------------------------------------

1687b56679880a47164ae149530abee543f9d6b1

Diffstat
--------

 drivers/net/r8169.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

Shortlog
--------

Francois Romieu (1):
      r8169: fix sticky accepts packet bits in RxConfig.

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 3ddd339..40bcb82 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -435,6 +435,7 @@ enum rtl_register_content {
 	AcceptMulticast	= 0x04,
 	AcceptMyPhys	= 0x02,
 	AcceptAllPhys	= 0x01,
+#define RX_CONFIG_ACCEPT_MASK		0x3f
 
 	/* TxConfigBits */
 	TxInterFrameGapShift = 24,
@@ -3943,11 +3944,8 @@ err_pm_runtime_put:
 static void rtl_rx_close(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	u32 rxcfg = RTL_R32(RxConfig);
 
-	rxcfg &= ~(AcceptErr | AcceptRunt | AcceptBroadcast | AcceptMulticast |
-		   AcceptMyPhys | AcceptAllPhys);
-	RTL_W32(RxConfig, rxcfg);
+	RTL_W32(RxConfig, RTL_R32(RxConfig) & ~RX_CONFIG_ACCEPT_MASK);
 }
 
 static void rtl8169_hw_reset(struct rtl8169_private *tp)
@@ -5586,7 +5584,7 @@ static void rtl_set_rx_mode(struct net_device *dev)
 
 	spin_lock_irqsave(&tp->lock, flags);
 
-	tmp = RTL_R32(RxConfig) | rx_mode;
+	tmp = (RTL_R32(RxConfig) & ~RX_CONFIG_ACCEPT_MASK) | rx_mode;
 
 	if (tp->mac_version > RTL_GIGA_MAC_VER_06) {
 		u32 data = mc_filter[0];
-- 
Ueimor
