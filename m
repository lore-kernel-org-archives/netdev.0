From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 4/9] sh_eth: get R8A7740 support out of #ifdef
Date: Sat, 8 Jun 2013 03:57:12 +0400
Message-ID: <201306080357.12704.sergei.shtylyov@cogentembedded.com>
References: <201306080351.39018.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201306080351.39018.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Get the R8A7740 code/data in the driver out of #ifdef by adding "r8a7740-gether"
to the platform driver's ID table.  Change the GEther platform device's name in
the ARM platform code accordingly.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 arch/arm/mach-shmobile/board-armadillo800eva.c |    2 +-
 arch/arm/mach-shmobile/clock-r8a7740.c         |    2 +-
 drivers/net/ethernet/renesas/sh_eth.c          |   16 +++++++---------
 3 files changed, 9 insertions(+), 11 deletions(-)

Index: net-next/arch/arm/mach-shmobile/board-armadillo800eva.c
===================================================================
--- net-next.orig/arch/arm/mach-shmobile/board-armadillo800eva.c
+++ net-next/arch/arm/mach-shmobile/board-armadillo800eva.c
@@ -377,7 +377,7 @@ static struct resource sh_eth_resources[
 };
 
 static struct platform_device sh_eth_device = {
-	.name = "sh-eth",
+	.name = "r8a7740-gether",
 	.id = -1,
 	.dev = {
 		.platform_data = &sh_eth_platdata,
Index: net-next/arch/arm/mach-shmobile/clock-r8a7740.c
===================================================================
--- net-next.orig/arch/arm/mach-shmobile/clock-r8a7740.c
+++ net-next/arch/arm/mach-shmobile/clock-r8a7740.c
@@ -591,7 +591,7 @@ static struct clk_lookup lookups[] = {
 	CLKDEV_DEV_ID("e6860000.sdhi",          &mstp_clks[MSTP313]),
 	CLKDEV_DEV_ID("sh_mmcif",		&mstp_clks[MSTP312]),
 	CLKDEV_DEV_ID("e6bd0000.mmcif",         &mstp_clks[MSTP312]),
-	CLKDEV_DEV_ID("sh-eth",			&mstp_clks[MSTP309]),
+	CLKDEV_DEV_ID("r8a7740-gether",		&mstp_clks[MSTP309]),
 
 	CLKDEV_DEV_ID("sh_mobile_sdhi.2",	&mstp_clks[MSTP415]),
 	CLKDEV_DEV_ID("e6870000.sdhi",          &mstp_clks[MSTP415]),
Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -619,11 +619,9 @@ static struct sh_eth_cpu_data sh_eth_my_
 	.irq_flags	= IRQF_SHARED,
 #endif
 };
+#endif
 
-
-#elif defined(CONFIG_ARCH_R8A7740)
-
-static void sh_eth_chip_reset(struct net_device *ndev)
+static void sh_eth_chip_reset_r8a7740(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 
@@ -634,7 +632,7 @@ static void sh_eth_chip_reset(struct net
 	sh_eth_select_mii(ndev);
 }
 
-static void sh_eth_set_rate(struct net_device *ndev)
+static void sh_eth_set_rate_gether(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 
@@ -654,10 +652,10 @@ static void sh_eth_set_rate(struct net_d
 }
 
 /* R8A7740 */
-static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
-	.chip_reset	= sh_eth_chip_reset,
+static struct sh_eth_cpu_data r8a7740_data = {
+	.chip_reset	= sh_eth_chip_reset_r8a7740,
 	.set_duplex	= sh_eth_set_duplex,
-	.set_rate	= sh_eth_set_rate,
+	.set_rate	= sh_eth_set_rate_gether,
 
 	.ecsr_value	= ECSR_ICD | ECSR_MPD,
 	.ecsipr_value	= ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP,
@@ -680,7 +678,6 @@ static struct sh_eth_cpu_data sh_eth_my_
 	.tsu		= 1,
 	.select_mii	= 1,
 };
-#endif
 
 static struct sh_eth_cpu_data sh7619_data = {
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
@@ -2701,6 +2698,7 @@ static const struct dev_pm_ops sh_eth_de
 static struct platform_device_id sh_eth_id_table[] = {
 	{ "sh7619-ether", (kernel_ulong_t)&sh7619_data },
 	{ "sh771x-ether", (kernel_ulong_t)&sh771x_data },
+	{ "r8a7740-gether", (kernel_ulong_t)&r8a7740_data },
 	{ CARDNAME },
 	{ }
 };
