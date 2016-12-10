From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next] net: mvneta: select GENERIC_ALLOCATOR
Date: Sat, 10 Dec 2016 11:38:32 +0100
Message-ID: <20161210103844.1465583-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We previously relied on GENERIC_ALLOCATOR to be selected by CONFIG_ARM,
but now we can compile-test the driver on other architectures that
don't select it:

drivers/net/built-in.o: In function `mvneta_bm_remove':
mvneta_bm.c:(.text+0x4ee35): undefined reference to `gen_pool_free'

This adds an explicit select for the part of the driver that has
the dependency.

Fixes: a0627f776a45 ("net: marvell: Allow drivers to be built with COMPILE_TEST")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/marvell/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index 3b8f11fe5e13..f4b7cf18fb0f 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -76,6 +76,7 @@ config MVNETA_BM
 	default y if MVNETA=y && MVNETA_BM_ENABLE!=n
 	default MVNETA_BM_ENABLE
 	select HWBM
+	select GENERIC_ALLOCATOR
 	help
 	  MVNETA_BM must not be 'm' if MVNETA=y, so this symbol ensures
 	  that all dependencies are met.
-- 
2.9.0
