From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/2] r8169: multicast register update
Date: Sun, 20 Jul 2008 20:05:55 +0200
Message-ID: <20080720180555.GB31465@electric-eye.fr.zoreil.com>
References: <20080720180451.GA31465@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Marcus Sundberg <marcus@ingate.com>,
	Johan =?unknown-8bit?Q?Myr=C3=A9en?= <jem@iki.fi>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	David Miller <davem@davemloft.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:35130 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757812AbYGTSG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 14:06:58 -0400
Content-Disposition: inline
In-Reply-To: <20080720180451.GA31465@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The layout of the 8101 series is identical to that of the 8168 one,
thus allowing to pack everything not 8169 related above MAC_VER_06.
New 810x and 8168 chipsets should automagically behave correctly.

It matches code in Realtek's 1.008.00 8101 and 8.007.00 8168 drivers.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index cfe8829..2a5486f 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3032,13 +3032,7 @@ static void rtl_set_rx_mode(struct net_device *dev)
 	tmp = rtl8169_rx_config | rx_mode |
 	      (RTL_R32(RxConfig) & rtl_chip_info[tp->chipset].RxConfigMask);
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_11) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_12) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_13) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_14) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_15) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_16) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_17)) {
+	if (tp->mac_version > RTL_GIGA_MAC_VER_06) {
 		u32 data = mc_filter[0];
 
 		mc_filter[0] = swab32(mc_filter[1]);
-- 
1.5.3.3

