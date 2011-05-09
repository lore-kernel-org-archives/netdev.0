From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 3/8] r8169: rtl8169_set_speed_xmii cleanup.
Date: Mon, 9 May 2011 21:04:08 +0200
Message-ID: <20110509190408.GC20687@electric-eye.fr.zoreil.com>
References: <20110509190446.GA6053@electric-eye.fr.zoreil.com> <20110509190205.GA20677@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Ciprian Docan <docan@eden.rutgers.edu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50160 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753294Ab1EITNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 15:13:47 -0400
Content-Disposition: inline
In-Reply-To: <20110509190205.GA20677@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shorten chipset version test.

No functional change.

Careful readers will notice that the 'supports_gmii' flag is deduced
from the device PCI id. Though less specific than the chipset related
RTL_GIGA_MAC_VER_XY, it is good enough to detect a GMII deprieved 810x.
Some features push for a device specific configuration (improved jumbo
frame support for instance). 'supports_gmii' will follow this path
if / when the device PCI id test stops working.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
---
 drivers/net/r8169.c |   11 +----------
 1 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 976bb31..182c794 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1258,16 +1258,7 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		giga_ctrl &= ~(ADVERTISE_1000FULL | ADVERTISE_1000HALF);
 
 		/* The 8100e/8101e/8102e do Fast Ethernet only. */
-		if (tp->mac_version != RTL_GIGA_MAC_VER_07 &&
-		    tp->mac_version != RTL_GIGA_MAC_VER_08 &&
-		    tp->mac_version != RTL_GIGA_MAC_VER_09 &&
-		    tp->mac_version != RTL_GIGA_MAC_VER_10 &&
-		    tp->mac_version != RTL_GIGA_MAC_VER_13 &&
-		    tp->mac_version != RTL_GIGA_MAC_VER_14 &&
-		    tp->mac_version != RTL_GIGA_MAC_VER_15 &&
-		    tp->mac_version != RTL_GIGA_MAC_VER_16 &&
-		    tp->mac_version != RTL_GIGA_MAC_VER_29 &&
-		    tp->mac_version != RTL_GIGA_MAC_VER_30) {
+		if (tp->mii.supports_gmii) {
 			if (adv & ADVERTISED_1000baseT_Half)
 				giga_ctrl |= ADVERTISE_1000HALF;
 			if (adv & ADVERTISED_1000baseT_Full)
-- 
1.7.4.4

