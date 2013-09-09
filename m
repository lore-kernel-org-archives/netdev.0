From: Vladimir Murzin <murzin.v@gmail.com>
Subject: [PATCH] pch_gbe: fix unmet direct dependency on PTP_1588_CLOCK_PCH
Date: Mon,  9 Sep 2013 21:28:30 +0200
Message-ID: <1378754910-2254-1-git-send-email-murzin.v@gmail.com>
Cc: davem@davemloft.net, ben@decadent.org.uk,
	jeffrey.t.kirsher@intel.com, rdunlap@xenotime.net,
	haicheng.lee@gmail.com, Vladimir Murzin <murzin.v@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:65321 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754333Ab3IIT3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 15:29:20 -0400
Received: by mail-lb0-f174.google.com with SMTP id w6so5304723lbh.5
        for <netdev@vger.kernel.org>; Mon, 09 Sep 2013 12:29:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While cross-building for PPC.

warning: (PCH_GBE) selects PTP_1588_CLOCK_PCH which has unmet direct
dependencies (X86 || COMPILE_TEST)

Both PCH_GBE and PPT_1588_CLOCK_PCH is only compatible with Intel
architecture. Add dependency on x86 for PCH_GBE. Keep COMPILE_TEST to allow
building on different arches.

Signed-off-by: Vladimir Murzin <murzin.v@gmail.com>
---
 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
index cb22341..4a935ec 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
@@ -4,7 +4,7 @@
 
 config PCH_GBE
 	tristate "OKI SEMICONDUCTOR IOH(ML7223/ML7831) GbE"
-	depends on PCI
+	depends on PCI && (x86 || COMPILE_TEST)
 	select MII
 	select PTP_1588_CLOCK_PCH
 	---help---
-- 
1.8.1.5
