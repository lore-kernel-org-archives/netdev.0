From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/9] sh_eth: get SH771x support out of #ifdef
Date: Sat, 8 Jun 2013 03:55:08 +0400
Message-ID: <201306080355.09328.sergei.shtylyov@cogentembedded.com>
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

Get the SH771[02] data in the driver out of #ifdef by adding "sh771x-ether" to
the platform driver's ID table. Change the Ether platform device's name in the
SH platform code accordingly.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Note that in this case the driver's probe will crash anyway as the platform code
is hopelessly behind since it passes PHY ID instead of 'struct sh_eth_plat_data'
pointer as a platform data. Even if it's fixed, the driver probe will fail as
the 'struct sh_eth_cpu_data' indicates presence of TSU but the device resource
for it is absent... :-/

 arch/sh/boards/mach-se/770x/setup.c   |    8 ++++----
 drivers/net/ethernet/renesas/sh_eth.c |    7 ++++---
 2 files changed, 8 insertions(+), 7 deletions(-)

Index: net-next/arch/sh/boards/mach-se/770x/setup.c
===================================================================
--- net-next.orig/arch/sh/boards/mach-se/770x/setup.c
+++ net-next/arch/sh/boards/mach-se/770x/setup.c
@@ -128,8 +128,8 @@ static struct resource sh_eth0_resources
 };
 
 static struct platform_device sh_eth0_device = {
-	.name = "sh-eth",
-	.id	= 0,
+	.name = "sh771x-ether",
+	.id = 0,
 	.dev = {
 		.platform_data = PHY_ID,
 	},
@@ -151,8 +151,8 @@ static struct resource sh_eth1_resources
 };
 
 static struct platform_device sh_eth1_device = {
-	.name = "sh-eth",
-	.id	= 1,
+	.name = "sh771x-ether",
+	.id = 1,
 	.dev = {
 		.platform_data = PHY_ID,
 	},
Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -690,12 +690,12 @@ static struct sh_eth_cpu_data sh_eth_my_
 	.tpauser	= 1,
 	.hw_swap	= 1,
 };
-#elif defined(CONFIG_CPU_SUBTYPE_SH7710) || defined(CONFIG_CPU_SUBTYPE_SH7712)
-static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
+#endif
+
+static struct sh_eth_cpu_data sh771x_data = {
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 	.tsu		= 1,
 };
-#endif
 
 static void sh_eth_set_default_cpu_data(struct sh_eth_cpu_data *cd)
 {
@@ -2700,6 +2700,7 @@ static const struct dev_pm_ops sh_eth_de
 #endif
 
 static struct platform_device_id sh_eth_id_table[] = {
+	{ "sh771x-ether", (kernel_ulong_t)&sh771x_data },
 	{ CARDNAME },
 	{ }
 };
