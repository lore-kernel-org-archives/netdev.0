From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next 1/2] bnxt_en: add CONFIG_NET_SWITCHDEV dependency
Date: Tue, 25 Jul 2017 17:29:51 +0200
Message-ID: <20170725153046.44726-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Thomas Gleixner <tglx@linutronix.de>,
        Edward Cree <ecree@solarflare.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Nicolas Pitre <nicolas.pitre@linaro.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        Sathya Perla <sathya.perla@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Without CONFIG_SWITCHDEV, we run into a compile-time error:

drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c: In function 'bnxt_vf_rep_netdev_init':
drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c:305:7: error: 'struct net_device' has no member named 'switchdev_ops'; did you mean 'netdev_ops'?

This adds a Kconfig dependency to prevent running into this invalid
configuration.

Fixes: c124a62ff2dd ("bnxt_en: add support for port_attr_get and and get_phys_port_name")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/broadcom/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index 285f8bc25682..095bb816ab48 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -194,6 +194,7 @@ config BNXT
 	tristate "Broadcom NetXtreme-C/E support"
 	depends on PCI
 	depends on MAY_USE_DEVLINK
+	depends on NET_SWITCHDEV
 	select FW_LOADER
 	select LIBCRC32C
 	---help---
-- 
2.9.0
