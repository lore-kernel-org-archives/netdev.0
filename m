From: Peter Robinson <pbrobinson@gmail.com>
Subject: [PATCH] net: arc_emac: add dependencies on associated arches and compile test
Date: Mon, 28 Nov 2016 07:12:37 +0000
Message-ID: <20161128071237.9016-1-pbrobinson@gmail.com>
Cc: Peter Robinson <pbrobinson@gmail.com>
To: Xing Zheng <zhengxing@rock-chips.com>,
        Alexander Kochetkov <al.kochet@gmail.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34399 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750878AbcK1HNC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 02:13:02 -0500
Received: by mail-pf0-f195.google.com with SMTP id y68so5963883pfb.1
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 23:13:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add dependencies on the architectures that support these devices and
add compile test to ensure ongoing code build coverage.

Signed-off-by: Peter Robinson <pbrobinson@gmail.com>
---
 drivers/net/ethernet/arc/Kconfig | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/arc/Kconfig b/drivers/net/ethernet/arc/Kconfig
index 6890451..e743ddf 100644
--- a/drivers/net/ethernet/arc/Kconfig
+++ b/drivers/net/ethernet/arc/Kconfig
@@ -17,13 +17,14 @@ if NET_VENDOR_ARC
 
 config ARC_EMAC_CORE
 	tristate
+	depends on ARC || ARCH_ROCKCHIP || COMPILE_TEST
 	select MII
 	select PHYLIB
 
 config ARC_EMAC
 	tristate "ARC EMAC support"
 	select ARC_EMAC_CORE
-	depends on OF_IRQ && OF_NET && HAS_DMA
+	depends on OF_IRQ && OF_NET && HAS_DMA && (ARC || COMPILE_TEST)
 	---help---
 	  On some legacy ARC (Synopsys) FPGA boards such as ARCAngel4/ML50x
 	  non-standard on-chip ethernet device ARC EMAC 10/100 is used.
@@ -32,7 +33,7 @@ config ARC_EMAC
 config EMAC_ROCKCHIP
 	tristate "Rockchip EMAC support"
 	select ARC_EMAC_CORE
-	depends on OF_IRQ && OF_NET && REGULATOR && HAS_DMA
+	depends on OF_IRQ && OF_NET && REGULATOR && HAS_DMA && (ARCH_ROCKCHIP || COMPILE_TEST)
 	---help---
 	  Support for Rockchip RK3036/RK3066/RK3188 EMAC ethernet controllers.
 	  This selects Rockchip SoC glue layer support for the
-- 
2.9.3
