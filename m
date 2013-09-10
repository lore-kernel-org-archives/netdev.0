From: Vladimir Murzin <murzin.v@gmail.com>
Subject: [PATCH v2] pch_gbe: fix unmet direct dependency on PTP_1588_CLOCK_PCH
Date: Tue, 10 Sep 2013 04:33:16 +0200
Message-ID: <1378780396-3694-1-git-send-email-murzin.v@gmail.com>
Cc: davem@davemloft.net, ben@decadent.org.uk,
	jeffrey.t.kirsher@intel.com, rdunlap@infradead.org,
	haicheng.lee@gmail.com, Vladimir Murzin <murzin.v@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:50807 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753Ab3IJCd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 22:33:59 -0400
Received: by mail-la0-f50.google.com with SMTP id es20so5775032lab.9
        for <netdev@vger.kernel.org>; Mon, 09 Sep 2013 19:33:57 -0700 (PDT)
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
v1->v2:
 - s/x86/X86 (pointed  by Randy)

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
+	depends on PCI && (X86 || COMPILE_TEST)
 	select MII
 	select PTP_1588_CLOCK_PCH
 	---help---
-- 
1.8.1.5
