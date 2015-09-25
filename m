From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v2 4/7] net: mvneta: Fix CPU_MAP registers initialisation
Date: Fri, 25 Sep 2015 18:09:35 +0200
Message-ID: <1443197378-30717-5-git-send-email-gregory.clement@free-electrons.com>
References: <1443197378-30717-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Willy Tarreau <w@1wt.eu>, linux-arm-kernel@lists.infradead.org,
	<stable@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>,
	Jason Cooper <jason@lakedaemon.net>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1443197378-30717-1-git-send-email-gregory.clement@free-electrons.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maxime Ripard <maxime.ripard@free-electrons.com>

The CPU_MAP register is duplicated for each CPUs at different addresses,
each instance being at a different address.

However, the code so far was using CONFIG_NR_CPUS to initialise the CPU_MAP
registers for each registers, while the SoCs embed at most 4 CPUs.

This is especially an issue with multi_v7_defconfig, where CONFIG_NR_CPUS
is currently set to 16, resulting in writes to registers that are not
CPU_MAP.

Fixes: c5aff18204da ("net: mvneta: driver for Marvell Armada 370/XP network unit")
Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
Cc: <stable@vger.kernel.org> # v3.8+
Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index fe2299ac4f5c..ea587d964c46 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -949,7 +949,7 @@ static void mvneta_defaults_set(struct mvneta_port *pp)
 	/* Set CPU queue access map - all CPUs have access to all RX
 	 * queues and to all TX queues
 	 */
-	for (cpu = 0; cpu < CONFIG_NR_CPUS; cpu++)
+	for_each_present_cpu(cpu)
 		mvreg_write(pp, MVNETA_CPU_MAP(cpu),
 			    (MVNETA_CPU_RXQ_ACCESS_ALL_MASK |
 			     MVNETA_CPU_TXQ_ACCESS_ALL_MASK));
-- 
2.1.0
