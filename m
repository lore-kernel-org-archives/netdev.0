From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH v5 4/4] ARM: shmobile: genmai: Enable r7s72100-ether
Date: Wed, 15 Jan 2014 15:12:21 +0900
Message-ID: <1389766341-14001-5-git-send-email-horms+renesas@verge.net.au>
References: <1389766341-14001-1-git-send-email-horms+renesas@verge.net.au>
Cc: linux-arm-kernel@lists.infradead.org,
	Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms+renesas@verge.net.au>,
	Simon Horman <horms@verge.net.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:41315 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980AbaAOGMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 01:12:40 -0500
In-Reply-To: <1389766341-14001-1-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Simon Horman <horms@verge.net.au>
Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Dave,

I plan to take this change through my tree.

v3 - v5
* No change

v2
* As suggested by Magnus Damm and Sergei Shtylyov
  - r7s72100 ethernet is not gigabit so do not refer to it as such

* As suggested by Sergei Shtylyov
  - set no_ether_link as there is no LINK signal documented
    in the manual
---
 arch/arm/mach-shmobile/board-genmai.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/arch/arm/mach-shmobile/board-genmai.c b/arch/arm/mach-shmobile/board-genmai.c
index 3e92e3c..a1f6fe1 100644
--- a/arch/arm/mach-shmobile/board-genmai.c
+++ b/arch/arm/mach-shmobile/board-genmai.c
@@ -20,15 +20,36 @@
 
 #include <linux/kernel.h>
 #include <linux/platform_device.h>
+#include <linux/sh_eth.h>
 #include <mach/common.h>
+#include <mach/irqs.h>
 #include <mach/r7s72100.h>
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
 
+/* Ether */
+static const struct sh_eth_plat_data ether_pdata __initconst = {
+	.phy			= 0x00, /* PD60610 */
+	.edmac_endian		= EDMAC_LITTLE_ENDIAN,
+	.phy_interface		= PHY_INTERFACE_MODE_MII,
+	.no_ether_link		= 1
+};
+
+static const struct resource ether_resources[] __initconst = {
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
+	platform_device_register_resndata(&platform_bus, "r7s72100-ether", -1,
+					  ether_resources,
+					  ARRAY_SIZE(ether_resources),
+					  &ether_pdata, sizeof(ether_pdata));
 }
 
 static const char * const genmai_boards_compat_dt[] __initconst = {
-- 
1.8.4
