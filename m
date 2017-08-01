From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: bcmgenet: Add dependency on HAS_IOMEM && OF
Date: Mon, 31 Jul 2017 17:53:07 -0700
Message-ID: <20170801005307.14437-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com, jaedon.shin@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35164 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751676AbdHAAxN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 20:53:13 -0400
Received: by mail-wm0-f65.google.com with SMTP id r77so819153wmd.2
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 17:53:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver needs CONFIG_HAS_IOMEM and OF to be functional, but we still
let it build with COMPILE_TEST. This fixes the unmet dependency after
selecting MDIO_BCM_UNIMAC in commit mentioned below:

warning: (NET_DSA_BCM_SF2 && BCMGENET) selects MDIO_BCM_UNIMAC which has
unmet direct dependencies (NETDEVICES && MDIO_DEVICE && HAS_IOMEM &&
OF_MDIO)

Fixes: 9a4e79697009 ("net: bcmgenet: utilize generic Broadcom UniMAC MDIO controller driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index ec7a798c6bd1..45775399cab6 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -61,6 +61,7 @@ config BCM63XX_ENET
 
 config BCMGENET
 	tristate "Broadcom GENET internal MAC support"
+	depends on (OF && HAS_IOMEM) || COMPILE_TEST
 	select MII
 	select PHYLIB
 	select FIXED_PHY
-- 
2.9.3
