From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH] Change S390 anti-dependency to CONFIG_GENERIC_HARDIRQS dependency
Date: Tue, 14 Oct 2008 17:28:13 -0500
Message-ID: <1224023293-8592-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:52607 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbYJNW2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 18:28:18 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw02.freescale.net (8.12.11/de01egw02) with ESMTP id m9EMSFT7022387
	for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 15:28:15 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id m9EMSExK025314
	for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 17:28:14 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PHY Lib and DSA expect request_irq and other such functions to exist.
S390 doesn't support those functions, however we should mark the actual
dependency, which is generic hardirq support, rather than explicitly
depend on !S390.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
This makes more sense to me, but I could be missing something?

 drivers/net/phy/Kconfig |    2 +-
 net/dsa/Kconfig         |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index d55932a..73027a0 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -4,7 +4,7 @@
 
 menuconfig PHYLIB
 	tristate "PHY Device support and infrastructure"
-	depends on !S390
+	depends on GENERIC_HARDIRQS
 	depends on NET_ETHERNET
 	help
 	  Ethernet controllers are usually attached to PHY
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index 49211b3..ea9c5aa 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -1,7 +1,7 @@
 menuconfig NET_DSA
 	bool "Distributed Switch Architecture support"
 	default n
-	depends on EXPERIMENTAL && !S390
+	depends on EXPERIMENTAL && GENERIC_HARDIRQS
 	select PHYLIB
 	---help---
 	  This allows you to use hardware switch chips that use
-- 
1.5.4.GIT

