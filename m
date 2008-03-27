From: Bryan Wu <cooloney@kernel.org>
Subject: [PATCH 1/2] Blackfin EMAC driver: finish removing remnants of old BF537_PORT_H option
Date: Wed, 26 Mar 2008 18:21:57 -0700
Message-ID: <1206580918-24720-2-git-send-email-cooloney@kernel.org>
Cc: Mike Frysinger <vapier.adi@gmail.com>,
	Bryan Wu <cooloney@kernel.org>
To: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:46704 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755631AbYCZKV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 06:21:58 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier.adi@gmail.com>

Signed-off-by: Mike Frysinger <vapier.adi@gmail.com>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 arch/blackfin/mach-bf537/head.S |   12 ------------
 drivers/net/Kconfig             |    2 +-
 2 files changed, 1 insertions(+), 13 deletions(-)

diff --git a/arch/blackfin/mach-bf537/head.S b/arch/blackfin/mach-bf537/head.S
index 3014fe8..ac85fdf 100644
--- a/arch/blackfin/mach-bf537/head.S
+++ b/arch/blackfin/mach-bf537/head.S
@@ -180,18 +180,6 @@ ENTRY(__start)
 	SSYNC;
 #endif
 
-#ifdef CONFIG_BF537_PORT_H
-	p0.h = hi(PORTH_FER);
-	p0.l = lo(PORTH_FER);
-	R0.L = W[P0]; /* Read */
-	SSYNC;
-	R0 = 0x0000;
-	W[P0] = R0.L; /* Write */
-	SSYNC;
-	W[P0] = R0.L; /* Disable peripheral function of PORTH */
-	SSYNC;
-#endif
-
 	/* Initialise UART - when booting from u-boot, the UART is not disabled
 	 * so if we dont initalize here, our serial console gets hosed */
 	p0.h = hi(UART_LCR);
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index fe7b5ec..c52e9d8 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -820,7 +820,7 @@ config ULTRA32
 
 config BFIN_MAC
 	tristate "Blackfin 527/536/537 on-chip mac support"
-	depends on NET_ETHERNET && (BF527 || BF537 || BF536) && (!BF537_PORT_H)
+	depends on NET_ETHERNET && (BF527 || BF537 || BF536)
 	select CRC32
 	select MII
 	select PHYLIB
-- 
1.5.4.3
