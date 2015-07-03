From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 1/6] net: mvneta: Fix CPU_MAP registers initialisation
Date: Fri,  3 Jul 2015 16:25:46 +0200
Message-ID: <1435933551-28696-2-git-send-email-maxime.ripard@free-electrons.com>
References: <1435933551-28696-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	<stable@kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1435933551-28696-1-git-send-email-maxime.ripard@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CPU_MAP register is duplicated for each CPUs at different addresses,
each instance being at a different address.

However, the code so far was using CONFIG_NR_CPUS to initialise the CPU_MAP
registers for each registers, while the SoCs embed at most 4 CPUs.

This is especially an issue with multi_v7_defconfig, where CONFIG_NR_CPUS
is currently set to 16, resulting in writes to registers that are not
CPU_MAP.

Fixes: c5aff18204da ("net: mvneta: driver for Marvell Armada 370/XP network unit")
Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
Cc: <stable@kernel.org> # v3.8+
---
 drivers/net/ethernet/marvell/mvneta.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index ce5f7f9cff06..b7717375ec4d 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -948,7 +948,7 @@ static void mvneta_defaults_set(struct mvneta_port *pp)
 	/* Set CPU queue access map - all CPUs have access to all RX
 	 * queues and to all TX queues
 	 */
-	for (cpu = 0; cpu < CONFIG_NR_CPUS; cpu++)
+	for_each_present_cpu(cpu)
 		mvreg_write(pp, MVNETA_CPU_MAP(cpu),
 			    (MVNETA_CPU_RXQ_ACCESS_ALL_MASK |
 			     MVNETA_CPU_TXQ_ACCESS_ALL_MASK));
-- 
2.4.5
