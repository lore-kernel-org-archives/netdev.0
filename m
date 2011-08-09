From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: [PATCH 1/9 v4] at91: provide macb clks with "pclk" and "hclk" name
Date: Tue,  9 Aug 2011 16:51:11 +0200
Message-ID: <1312901471-6635-1-git-send-email-plagnioj@jcrosoft.com>
References: <1312881411-2376-2-git-send-email-jamie@jamieiles.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Jamie Iles <jamie@jamieiles.com>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1312881411-2376-2-git-send-email-jamie@jamieiles.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Jamie Iles <jamie@jamieiles.com>

The macb driver expects clocks with the names "pclk" and "hclk".  We
currently provide "macb_clk" but to fit in line with other
architectures (namely AVR32), provide "pclk" and a fake "hclk".

Cc: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Signed-off-by: Jamie Iles <jamie@jamieiles.com>
Acked-by: David S. Miller <davem@davemloft.net>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
---
v4:
use clkdev

Best Regards,
J.
 arch/arm/mach-at91/at91cap9.c    |    4 +++-
 arch/arm/mach-at91/at91sam9260.c |    4 +++-
 arch/arm/mach-at91/at91sam9263.c |    4 +++-
 arch/arm/mach-at91/at91sam9g45.c |    4 +++-
 4 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/arch/arm/mach-at91/at91cap9.c b/arch/arm/mach-at91/at91cap9.c
index bfc6844..a229c5c 100644
--- a/arch/arm/mach-at91/at91cap9.c
+++ b/arch/arm/mach-at91/at91cap9.c
@@ -137,7 +137,7 @@ static struct clk pwm_clk = {
 	.type		= CLK_TYPE_PERIPHERAL,
 };
 static struct clk macb_clk = {
-	.name		= "macb_clk",
+	.name		= "pclk",
 	.pmc_mask	= 1 << AT91CAP9_ID_EMAC,
 	.type		= CLK_TYPE_PERIPHERAL,
 };
@@ -210,6 +210,8 @@ static struct clk *periph_clocks[] __initdata = {
 };
 
 static struct clk_lookup periph_clocks_lookups[] = {
+	/* One additional fake clock for macb_hclk */
+	CLKDEV_CON_ID("hclk", &macb_clk),
 	CLKDEV_CON_DEV_ID("hclk", "atmel_usba_udc", &utmi_clk),
 	CLKDEV_CON_DEV_ID("pclk", "atmel_usba_udc", &udphs_clk),
 	CLKDEV_CON_DEV_ID("mci_clk", "at91_mci.0", &mmc0_clk),
diff --git a/arch/arm/mach-at91/at91sam9260.c b/arch/arm/mach-at91/at91sam9260.c
index cb397be..dc36479 100644
--- a/arch/arm/mach-at91/at91sam9260.c
+++ b/arch/arm/mach-at91/at91sam9260.c
@@ -120,7 +120,7 @@ static struct clk ohci_clk = {
 	.type		= CLK_TYPE_PERIPHERAL,
 };
 static struct clk macb_clk = {
-	.name		= "macb_clk",
+	.name		= "pclk",
 	.pmc_mask	= 1 << AT91SAM9260_ID_EMAC,
 	.type		= CLK_TYPE_PERIPHERAL,
 };
@@ -190,6 +190,8 @@ static struct clk *periph_clocks[] __initdata = {
 };
 
 static struct clk_lookup periph_clocks_lookups[] = {
+	/* One additional fake clock for macb_hclk */
+	CLKDEV_CON_ID("hclk", &macb_clk),
 	CLKDEV_CON_DEV_ID("spi_clk", "atmel_spi.0", &spi0_clk),
 	CLKDEV_CON_DEV_ID("spi_clk", "atmel_spi.1", &spi1_clk),
 	CLKDEV_CON_DEV_ID("t0_clk", "atmel_tcb.0", &tc0_clk),
diff --git a/arch/arm/mach-at91/at91sam9263.c b/arch/arm/mach-at91/at91sam9263.c
index 044f3c9..43c144c 100644
--- a/arch/arm/mach-at91/at91sam9263.c
+++ b/arch/arm/mach-at91/at91sam9263.c
@@ -118,7 +118,7 @@ static struct clk pwm_clk = {
 	.type		= CLK_TYPE_PERIPHERAL,
 };
 static struct clk macb_clk = {
-	.name		= "macb_clk",
+	.name		= "pclk",
 	.pmc_mask	= 1 << AT91SAM9263_ID_EMAC,
 	.type		= CLK_TYPE_PERIPHERAL,
 };
@@ -182,6 +182,8 @@ static struct clk *periph_clocks[] __initdata = {
 };
 
 static struct clk_lookup periph_clocks_lookups[] = {
+	/* One additional fake clock for macb_hclk */
+	CLKDEV_CON_ID("hclk", &macb_clk),
 	CLKDEV_CON_DEV_ID("pclk", "ssc.0", &ssc0_clk),
 	CLKDEV_CON_DEV_ID("pclk", "ssc.1", &ssc1_clk),
 	CLKDEV_CON_DEV_ID("mci_clk", "at91_mci.0", &mmc0_clk),
diff --git a/arch/arm/mach-at91/at91sam9g45.c b/arch/arm/mach-at91/at91sam9g45.c
index e04c5fb..8abac30 100644
--- a/arch/arm/mach-at91/at91sam9g45.c
+++ b/arch/arm/mach-at91/at91sam9g45.c
@@ -144,7 +144,7 @@ static struct clk ac97_clk = {
 	.type		= CLK_TYPE_PERIPHERAL,
 };
 static struct clk macb_clk = {
-	.name		= "macb_clk",
+	.name		= "pclk",
 	.pmc_mask	= 1 << AT91SAM9G45_ID_EMAC,
 	.type		= CLK_TYPE_PERIPHERAL,
 };
@@ -202,6 +202,8 @@ static struct clk *periph_clocks[] __initdata = {
 };
 
 static struct clk_lookup periph_clocks_lookups[] = {
+	/* One additional fake clock for macb_hclk */
+	CLKDEV_CON_ID("hclk", &macb_clk),
 	/* One additional fake clock for ohci */
 	CLKDEV_CON_ID("ohci_clk", &uhphs_clk),
 	CLKDEV_CON_DEV_ID("ehci_clk", "atmel-ehci", &uhphs_clk),
-- 
1.7.5.4
