From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH] bgmac: make bgmac depend on bcm47xx
Date: Tue, 23 Jul 2013 23:28:49 +0200
Message-ID: <1374614929-7528-1-git-send-email-hauke@hauke-m.de>
Cc: zajec5@gmail.com, netdev@vger.kernel.org, linville@tuxdriver.com,
	linux-next@vger.kernel.org, sfr@canb.auug.org.au,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:42497 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755531Ab3GWV3F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jul 2013 17:29:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bgmac uses bcm47xx_nvram.h which is only available when BCM47XX was
selected. Earlier BCMA_HOST_SOC depended on BCM47XX so this was not
build on any other archs, but that changed. We should modify this
driver to get access to the nvram or the variables through platform
data.

This fixes a build problem in linux-next reported by Stephen Rothwell:

drivers/net/ethernet/broadcom/bgmac.c:19:27: fatal error: bcm47xx_nvram.h: No such file or directory
 #include <bcm47xx_nvram.h>
                           ^

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/broadcom/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index 52c9603..2fa5b86 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -130,7 +130,7 @@ config BNX2X_SRIOV
 
 config BGMAC
 	tristate "BCMA bus GBit core support"
-	depends on BCMA_HOST_SOC && HAS_DMA
+	depends on BCMA_HOST_SOC && HAS_DMA && BCM47XX
 	select PHYLIB
 	---help---
 	  This driver supports GBit MAC and BCM4706 GBit MAC cores on BCMA bus.
-- 
1.7.10.4
