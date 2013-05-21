From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH v4 10/12] ARM: kirkwood: remove legacy clk alias for mv643xx_eth
Date: Tue, 21 May 2013 18:41:48 +0200
Message-ID: <1369154510-4927-11-git-send-email-sebastian.hesselbarth@gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With all boards converted to DT enabled mv643xx_eth we can now
remove the clock alias for gbe clocks. The workaround for ge0/ge1 clock
gates is not removed, as Kirkwood ethernet controllers loose MAC address
stored in internal registers on gated ge0/ge1 clocks.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Note: I confirm that the above workaround is still required, i.e. when
booting DT kernel with non-DT boot loader (no local-mac-address property)
MAC address registers looses its content on clock gating.

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
 arch/arm/mach-kirkwood/board-dt.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/arch/arm/mach-kirkwood/board-dt.c b/arch/arm/mach-kirkwood/board-dt.c
index e9647b8..8db388a 100644
--- a/arch/arm/mach-kirkwood/board-dt.c
+++ b/arch/arm/mach-kirkwood/board-dt.c
@@ -66,12 +66,10 @@ static void __init kirkwood_legacy_clk_init(void)
 	 */
 	clkspec.args[0] = CGC_BIT_GE0;
 	clk = of_clk_get_from_provider(&clkspec);
-	orion_clkdev_add(NULL, "mv643xx_eth_port.0", clk);
 	clk_prepare_enable(clk);
 
 	clkspec.args[0] = CGC_BIT_GE1;
 	clk = of_clk_get_from_provider(&clkspec);
-	orion_clkdev_add(NULL, "mv643xx_eth_port.1", clk);
 	clk_prepare_enable(clk);
 }
 
-- 
1.7.10.4
