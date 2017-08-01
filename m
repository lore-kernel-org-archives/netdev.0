From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next] net: bcmgenet: drop COMPILE_TEST dependency
Date: Tue,  1 Aug 2017 13:50:56 +0200
Message-ID: <20170801115121.1246540-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Michael Chan <michael.chan@broadcom.com>,
        Sathya Perla <sathya.perla@broadcom.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The last patch added the dependency on 'OF && HAS_IOMEM' but left
COMPILE_TEST as an alternative, which kind of defeats the purpose
of adding the dependency, we still get randconfig build warnings:

warning: (NET_DSA_BCM_SF2 && BCMGENET) selects MDIO_BCM_UNIMAC which has unmet direct dependencies (NETDEVICES && MDIO_BUS && HAS_IOMEM && OF_MDIO)

For compile-testing purposes, we don't really need this anyway,
as CONFIG_OF can be enabled on all architectures, and HAS_IOMEM
is present on all architectures we do meaningful compile-testing on
(the exception being arch/um).

This makes both OF and HAS_IOMEM hard dependencies.

Fixes: 5af74bb4fcf8 ("net: bcmgenet: Add dependency on HAS_IOMEM && OF")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/broadcom/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index 45775399cab6..1456cb18f830 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -61,7 +61,7 @@ config BCM63XX_ENET
 
 config BCMGENET
 	tristate "Broadcom GENET internal MAC support"
-	depends on (OF && HAS_IOMEM) || COMPILE_TEST
+	depends on OF && HAS_IOMEM
 	select MII
 	select PHYLIB
 	select FIXED_PHY
-- 
2.9.0
