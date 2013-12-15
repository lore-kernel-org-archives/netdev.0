From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH RFC 3/3] [RFC] ARM: shmobile: genmai: Enable r7s72100-gether
Date: Sun, 15 Dec 2013 17:24:46 +0900
Message-ID: <1387095886-15163-4-git-send-email-horms+renesas@verge.net.au>
References: <1387095886-15163-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1387095886-15163-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

---
 arch/arm/mach-shmobile/board-genmai.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/arch/arm/mach-shmobile/board-genmai.c b/arch/arm/mach-shmobile/board-genmai.c
index 3e92e3c..838325b 100644
--- a/arch/arm/mach-shmobile/board-genmai.c
+++ b/arch/arm/mach-shmobile/board-genmai.c
@@ -20,15 +20,35 @@
 
 #include <linux/kernel.h>
 #include <linux/platform_device.h>
+#include <linux/sh_eth.h>
 #include <mach/common.h>
+#include <mach/irqs.h>
 #include <mach/r7s72100.h>
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
 
+/* GEther */
+static const struct sh_eth_plat_data gether_pdata __initconst = {
+	.phy			= 0x00, /* PD60610 */
+	.edmac_endian		= EDMAC_LITTLE_ENDIAN,
+	.phy_interface		= PHY_INTERFACE_MODE_MII,
+};
+
+static const struct resource gether_resources[] __initconst = {
+	DEFINE_RES_MEM(0xe8203000, 0x800),
+	DEFINE_RES_MEM(0xe8204800, 0x200),
+	DEFINE_RES_IRQ(gic_iid(359)),
+};
+
 static void __init genmai_add_standard_devices(void)
 {
 	r7s72100_clock_init();
 	r7s72100_add_dt_devices();
+
+	platform_device_register_resndata(&platform_bus, "r7s72100-gether", -1,
+					  gether_resources,
+					  ARRAY_SIZE(gether_resources),
+					  &gether_pdata, sizeof(gether_pdata));
 }
 
 static const char * const genmai_boards_compat_dt[] __initconst = {
-- 
1.8.4

