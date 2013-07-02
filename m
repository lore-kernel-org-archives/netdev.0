From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH v6 4/7] ARM: dove: remove legacy mv643xx_eth setup
Date: Tue,  2 Jul 2013 13:00:21 +0200
Message-ID: <1372762824-12202-5-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1372762824-12202-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Russell King <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372762824-12202-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With DT support for mv643xx_eth we do not need legacy platform_data
based setup for DT enabled boards anymore.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Changelog:
v5->v6:
- rebase for v3.11-rc1

Cc: Russell King <linux@arm.linux.org.uk>
Cc: Jason Cooper <jason@lakedaemon.net>
Cc: Andrew Lunn <andrew@lunn.ch>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 arch/arm/mach-dove/board-dt.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/arch/arm/mach-dove/board-dt.c b/arch/arm/mach-dove/board-dt.c
index f3755ac..b5ccc1c 100644
--- a/arch/arm/mach-dove/board-dt.c
+++ b/arch/arm/mach-dove/board-dt.c
@@ -33,10 +33,6 @@ static void __init dove_legacy_clk_init(void)
 	clkspec.np = np;
 	clkspec.args_count = 1;
 
-	clkspec.args[0] = CLOCK_GATING_BIT_GBE;
-	orion_clkdev_add(NULL, "mv643xx_eth_port.0",
-			 of_clk_get_from_provider(&clkspec));
-
 	clkspec.args[0] = CLOCK_GATING_BIT_PCIE0;
 	orion_clkdev_add("0", "pcie",
 			 of_clk_get_from_provider(&clkspec));
@@ -52,10 +48,6 @@ static void __init dove_of_clk_init(void)
 	dove_legacy_clk_init();
 }
 
-static struct mv643xx_eth_platform_data dove_dt_ge00_data = {
-	.phy_addr = MV643XX_ETH_PHY_ADDR_DEFAULT,
-};
-
 static void __init dove_dt_init(void)
 {
 	pr_info("Dove 88AP510 SoC\n");
@@ -69,7 +61,6 @@ static void __init dove_dt_init(void)
 	dove_of_clk_init();
 
 	/* Internal devices not ported to DT yet */
-	dove_ge00_init(&dove_dt_ge00_data);
 	dove_pcie_init(1, 1);
 
 	of_platform_populate(NULL, of_default_bus_match_table, NULL, NULL);
-- 
1.7.2.5
