From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [net-next] net: systemport: add NET_DSA dependency
Date: Mon, 16 Oct 2017 13:32:36 +0200
Message-ID: <20171016113258.3735473-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        Sathya Perla <sathya.perla@broadcom.com>,
        Nicolas Pitre <nicolas.pitre@linaro.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The notifier cause a link error when NET_DSA is a loadable
module:

drivers/net/ethernet/broadcom/bcmsysport.o: In function `bcm_sysport_remove':
bcmsysport.c:(.text+0x1582): undefined reference to `unregister_dsa_notifier'
drivers/net/ethernet/broadcom/bcmsysport.o: In function `bcm_sysport_probe':
bcmsysport.c:(.text+0x278d): undefined reference to `register_dsa_notifier'

This adds a dependency that forces the systemport driver to be
a loadable module as well when that happens, but otherwise
allows it to be built normally when DSA is either built-in or
completely disabled.

Fixes: d156576362c0 ("net: systemport: Establish lower/upper queue mapping")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/broadcom/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index 67134ece1107..af75156919ed 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -184,6 +184,7 @@ config BGMAC_PLATFORM
 config SYSTEMPORT
 	tristate "Broadcom SYSTEMPORT internal MAC support"
 	depends on OF
+	depends on NET_DSA || !NET_DSA
 	select MII
 	select PHYLIB
 	select FIXED_PHY
-- 
2.9.0
