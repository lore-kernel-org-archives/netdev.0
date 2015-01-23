From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 1/2] ARM: EXYNOS: add fixed phy support for EXYNOS5440
Date: Fri, 23 Jan 2015 10:41:32 +0800
Message-ID: <1421980893-14475-2-git-send-email-ming.lei@canonical.com>
References: <1421980893-14475-1-git-send-email-ming.lei@canonical.com>
Cc: linux-samsung-soc@vger.kernel.org, Kukjin Kim <kgene@kernel.org>,
	netdev@vger.kernel.org, Byungho An <bh74.an@samsung.com>,
	Ike Panhc <ike.pan@canonical.com>,
	Ming Lei <ming.lei@canoncial.com>
To: linux-arm-kernel@lists.infradead.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-Reply-To: <1421980893-14475-1-git-send-email-ming.lei@canonical.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Byungho An <bh74.an@samsung.com>

This patch adds fixed phy codes for Exynos5440.
This patch can support fixed_phy.

Signed-off-by: Byungho An <bh74.an@samsung.com>
Signed-off-by: Ike Panhc <ike.pan@canonical.com>
Signed-off-by: Ming Lei <ming.lei@canoncial.com>
---
 arch/arm/mach-exynos/exynos.c |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/arch/arm/mach-exynos/exynos.c b/arch/arm/mach-exynos/exynos.c
index 78eca99b..dfd5699 100644
--- a/arch/arm/mach-exynos/exynos.c
+++ b/arch/arm/mach-exynos/exynos.c
@@ -20,6 +20,8 @@
 #include <linux/platform_device.h>
 #include <linux/pm_domain.h>
 #include <linux/irqchip.h>
+#include <linux/phy.h>
+#include <linux/phy_fixed.h>
 
 #include <asm/cacheflush.h>
 #include <asm/hardware/cache-l2x0.h>
@@ -202,8 +204,21 @@ static void __init exynos_init_irq(void)
 	exynos_map_pmu();
 }
 
+static struct fixed_phy_status fixed_phy_status __initdata = {
+       .link           = 1,
+       .speed          = 1000,
+       .duplex         = 1,
+};
+
 static void __init exynos_dt_machine_init(void)
 {
+	struct device_node *gmac_np;
+	unsigned int tmp;
+
+	/* add fixed phy in need */
+	gmac_np = of_find_compatible_node(NULL, NULL, "snps,dwmac-3.70a");
+	if (of_find_property(gmac_np, "fixed_phy", NULL))
+		tmp = fixed_phy_add(PHY_POLL, 1, &fixed_phy_status);
 	/*
 	 * This is called from smp_prepare_cpus if we've built for SMP, but
 	 * we still need to set it up for PM and firmware ops if not.
-- 
1.7.9.5
