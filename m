From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH] ptp: fix kconfig dependency warnings
Date: Thu, 08 May 2014 14:54:42 -0700
Message-ID: <536BFD22.3020505@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:53848 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753994AbaEHVyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 17:54:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix kconfig warnings:

PTP_1588_CLOCK selects NET_PTP_CLASSIFY, which depends on NET,
so PTP_1588_CLOCK should also depend on NET.

PTP_1588_CLOCK_PCH selects PTP_1588_CLOCK so the former should
depend on NET.

warning: (IXP4XX_ETH && PTP_1588_CLOCK) selects NET_PTP_CLASSIFY which has unmet direct dependencies (NET)

warning: (SFC && TILE_NET && BFIN_MAC_USE_HWSTAMP && TIGON3 && FEC && E1000E && IGB && IXGBE && I40E && MLX4_EN && SXGBE_ETH && STMMAC_ETH && TI_CPTS && PTP_1588_CLOCK_GIANFAR && PTP_1588_CLOCK_IXP46X && DP83640_PHY && PTP_1588_CLOCK_PCH) selects PTP_1588_CLOCK which has unmet direct dependencies (NET)
[This warning is caused by the new 'depends on NET' in PTP_1588_CLOCK.]

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 drivers/ptp/Kconfig |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Found in linux-next but applies to mainline.

--- linux-next-20140508.orig/drivers/ptp/Kconfig
+++ linux-next-20140508/drivers/ptp/Kconfig
@@ -6,6 +6,7 @@ menu "PTP clock support"
 
 config PTP_1588_CLOCK
 	tristate "PTP clock support"
+	depends on NET
 	select PPS
 	select NET_PTP_CLASSIFY
 	help
@@ -74,7 +75,7 @@ config DP83640_PHY
 config PTP_1588_CLOCK_PCH
 	tristate "Intel PCH EG20T as PTP clock"
 	depends on X86 || COMPILE_TEST
-	depends on HAS_IOMEM
+	depends on HAS_IOMEM && NET
 	select PTP_1588_CLOCK
 	help
 	  This driver adds support for using the PCH EG20T as a PTP
