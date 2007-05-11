From: Timur Tabi <timur@freescale.com>
Subject: [PATCH] powerpc: fix Kconfig 'select' warning with UCC_FAST
Date: Thu, 10 May 2007 21:09:31 -0500
Message-ID: <11788493712639-git-send-email-timur@freescale.com>
Cc: Timur Tabi <timur@freescale.com>
To: kim.phillips@freescale.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, ismail@pardus.org.tr, schmitz@debian.org,
	zippel@linux-m68k.org, geert@linux-m68k.org,
	johannes@sipsolutions.net, benh@kernel.crashing.org,
	paulus@samba.org, galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:53760 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570AbXEKCL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 22:11:28 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The UCC_GETH Kconfig option in drivers/net/Kconfig had a line to select
the UCC_FAST option is arch/powerpc/sysdev/qe_lib/Kconfig, which is only used
on PowerPC builds.  On other architectures, this would generated a warning.
The fix is to have UCC_FAST depend on UCC_GETH.

Signed-off-by: Timur Tabi <timur@freescale.com>
---

The reason I used 'select' in the first place was because I didn't want to
have to update the definitions of UCC_FAST or UCC_SLOW every time we added
a new UCC device driver, but I guess that's unavoidable.

 arch/powerpc/sysdev/qe_lib/Kconfig |    4 +---
 drivers/net/Kconfig                |    1 -
 2 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/arch/powerpc/sysdev/qe_lib/Kconfig b/arch/powerpc/sysdev/qe_lib/Kconfig
index 887739f..f611d34 100644
--- a/arch/powerpc/sysdev/qe_lib/Kconfig
+++ b/arch/powerpc/sysdev/qe_lib/Kconfig
@@ -5,15 +5,13 @@
 config UCC_SLOW
 	bool
 	default n
-	select UCC
 	help
 	  This option provides qe_lib support to UCC slow
 	  protocols: UART, BISYNC, QMC
 
 config UCC_FAST
 	bool
-	default n
-	select UCC
+	default y if UCC_GETH
 	help
 	  This option provides qe_lib support to UCC fast
 	  protocols: HDLC, Ethernet, ATM, transparent
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index b86ccd2..5a5c026 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2276,7 +2276,6 @@ config GFAR_NAPI
 config UCC_GETH
 	tristate "Freescale QE Gigabit Ethernet"
 	depends on QUICC_ENGINE
-	select UCC_FAST
 	help
 	  This driver supports the Gigabit Ethernet mode of the QUICC Engine,
 	  which is available on some Freescale SOCs.
-- 
1.5.0.2.260.g2eb065

