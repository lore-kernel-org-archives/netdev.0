From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/1] r8169: fix static initializers.
Date: Fri, 17 Jun 2011 23:01:24 +0200
Message-ID: <20110617210124.GA2347@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43463 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901Ab1FQVOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 17:14:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'davem.r8169' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git davem.r8169

to get the change below.

Distance from 'davem' (eeb1497277d6b1a0a34ed36b97e18f2bd7d6de0d)
----------------------------------------------------------------

3744100e05c4e403ed21c99cd389c7e784664e4b

Diffstat
--------

 drivers/net/r8169.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

Shortlog
--------

Francois Romieu (1):
      r8169: fix static initializers.

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index ef1ce2e..05d8178 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1621,7 +1621,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 	 *
 	 * (RTL_R32(TxConfig) & 0x700000) == 0x200000 ? 8101Eb : 8101Ec
 	 */
-	static const struct {
+	static const struct rtl_mac_info {
 		u32 mask;
 		u32 val;
 		int mac_version;
@@ -1689,7 +1689,8 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 
 		/* Catch-all */
 		{ 0x00000000, 0x00000000,	RTL_GIGA_MAC_NONE   }
-	}, *p = mac_info;
+	};
+	const struct rtl_mac_info *p = mac_info;
 	u32 reg;
 
 	reg = RTL_R32(TxConfig);
@@ -3681,7 +3682,7 @@ static void rtl_set_rx_max_size(void __iomem *ioaddr, unsigned int rx_buf_sz)
 
 static void rtl8169_set_magic_reg(void __iomem *ioaddr, unsigned mac_version)
 {
-	static const struct {
+	static const struct rtl_cfg2_info {
 		u32 mac_version;
 		u32 clk;
 		u32 val;
@@ -3690,7 +3691,8 @@ static void rtl8169_set_magic_reg(void __iomem *ioaddr, unsigned mac_version)
 		{ RTL_GIGA_MAC_VER_05, PCI_Clock_66MHz, 0x000fffff },
 		{ RTL_GIGA_MAC_VER_06, PCI_Clock_33MHz, 0x00ffff00 }, // 8110SCe
 		{ RTL_GIGA_MAC_VER_06, PCI_Clock_66MHz, 0x00ffffff }
-	}, *p = cfg2_info;
+	};
+	const struct rtl_cfg2_info *p = cfg2_info;
 	unsigned int i;
 	u32 clk;
 
-- 
Ueimor
