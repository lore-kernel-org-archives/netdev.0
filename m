From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v6 net-next 5/7] net: mvneta: Only disable mvneta_bm for 64-bits
Date: Thu,  1 Dec 2016 18:03:08 +0100
Message-ID: <3bb7046c1f69d7b5930b367533f1ccbc521cb10a.1480611779.git-series.gregory.clement@free-electrons.com>
References: <cover.dd374b7aaa358be0211d7ead81129a399fa692f4.1480611779.git-series.gregory.clement@free-electrons.com>
Cc: Jisheng Zhang <jszhang@marvell.com>, Arnd Bergmann <arnd@arndb.de>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Nadav Haklai <nadavh@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Dmitri Epshtein <dima@marvell.com>,
        Yelena Krivosheev <yelena@marvell.com>
To: "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.dd374b7aaa358be0211d7ead81129a399fa692f4.1480611779.git-series.gregory.clement@free-electrons.com>
In-Reply-To: <cover.dd374b7aaa358be0211d7ead81129a399fa692f4.1480611779.git-series.gregory.clement@free-electrons.com>
References: <cover.dd374b7aaa358be0211d7ead81129a399fa692f4.1480611779.git-series.gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Actually only the mvneta_bm support is not 64-bits compatible.
The mvneta code itself can run on 64-bits architecture.

Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
Tested-by: Marcin Wojtas <mw@semihalf.com>
---
 drivers/net/ethernet/marvell/Kconfig | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index 66fd9dbb2ca7..2ccea9dd9248 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -44,6 +44,7 @@ config MVMDIO
 config MVNETA_BM_ENABLE
 	tristate "Marvell Armada 38x/XP network interface BM support"
 	depends on MVNETA
+	depends on !64BIT
 	---help---
 	  This driver supports auxiliary block of the network
 	  interface units in the Marvell ARMADA XP and ARMADA 38x SoC
@@ -58,7 +59,6 @@ config MVNETA
 	tristate "Marvell Armada 370/38x/XP network interface support"
 	depends on PLAT_ORION || COMPILE_TEST
 	depends on HAS_DMA
-	depends on !64BIT
 	select MVMDIO
 	select FIXED_PHY
 	---help---
@@ -71,6 +71,7 @@ config MVNETA
 
 config MVNETA_BM
 	tristate
+	depends on !64BIT
 	default y if MVNETA=y && MVNETA_BM_ENABLE!=n
 	default MVNETA_BM_ENABLE
 	select HWBM
-- 
git-series 0.8.10
