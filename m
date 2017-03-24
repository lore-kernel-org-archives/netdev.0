From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: bcm_sf2: Add missing OF_MDIO dependency
Date: Fri, 24 Mar 2017 14:57:22 -0700
Message-ID: <20170324215722.6664-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35377 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933254AbdCXWEI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 18:04:08 -0400
Received: by mail-qt0-f193.google.com with SMTP id r5so446423qtb.2
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 15:04:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bcm_sf2 does require the MDIO_BCM_UNIMAC driver which is now dependent
on OF_MDIO but also internally uses of_mdio.c provided routines which
are guarted with OF_MDIO.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Fixes: 90eff9096c01 ("net: phy: Allow splitting MDIO bus/device support from PHYs")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index 065984670ff1..564b267c8428 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -11,7 +11,7 @@ config NET_DSA_MV88E6060
 
 config NET_DSA_BCM_SF2
 	tristate "Broadcom Starfighter 2 Ethernet switch support"
-	depends on HAS_IOMEM && NET_DSA
+	depends on HAS_IOMEM && NET_DSA && OF_MDIO
 	select NET_DSA_TAG_BRCM
 	select FIXED_PHY
 	select BCM7XXX_PHY
-- 
2.9.3
