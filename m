From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH v4 09/12] ARM: dove: remove legacy mv643xx_eth setup
Date: Tue, 21 May 2013 18:41:47 +0200
Message-ID: <1369154510-4927-10-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:35093 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827Ab3EUQmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 12:42:20 -0400
In-Reply-To: <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With DT support for mv643xx_eth we do not need legacy platform_data
based setup for DT enabled boards anymore.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Cc: David Miller <davem@davemloft.net>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Cc: Jason Cooper <jason@lakedaemon.net>
Cc: Andrew Lunn <andrew@lunn.ch>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org
---
 arch/arm/mach-dove/board-dt.c |    9 ---------
 1 file changed, 9 deletions(-)

diff --git a/arch/arm/mach-dove/board-dt.c b/arch/arm/mach-dove/board-dt.c
index 0b14280..048e942 100644
--- a/arch/arm/mach-dove/board-dt.c
+++ b/arch/arm/mach-dove/board-dt.c
@@ -34,10 +34,6 @@ static void __init dove_legacy_clk_init(void)
 	clkspec.np = np;
 	clkspec.args_count = 1;
 
-	clkspec.args[0] = CLOCK_GATING_BIT_GBE;
-	orion_clkdev_add(NULL, "mv643xx_eth_port.0",
-			 of_clk_get_from_provider(&clkspec));
-
 	clkspec.args[0] = CLOCK_GATING_BIT_PCIE0;
 	orion_clkdev_add("0", "pcie",
 			 of_clk_get_from_provider(&clkspec));
@@ -53,10 +49,6 @@ static void __init dove_of_clk_init(void)
 	dove_legacy_clk_init();
 }
 
-static struct mv643xx_eth_platform_data dove_dt_ge00_data = {
-	.phy_addr = MV643XX_ETH_PHY_ADDR_DEFAULT,
-};
-
 static void __init dove_dt_init(void)
 {
 	pr_info("Dove 88AP510 SoC\n");
@@ -70,7 +62,6 @@ static void __init dove_dt_init(void)
 	dove_of_clk_init();
 
 	/* Internal devices not ported to DT yet */
-	dove_ge00_init(&dove_dt_ge00_data);
 	dove_pcie_init(1, 1);
 
 	of_platform_populate(NULL, of_default_bus_match_table, NULL, NULL);
-- 
1.7.10.4
