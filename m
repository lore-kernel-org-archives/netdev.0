From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH RFC net-next 1/3] [RFC] sh_eth: Add support for r7s72100
Date: Sun, 15 Dec 2013 17:24:44 +0900
Message-ID: <1387095886-15163-2-git-send-email-horms+renesas@verge.net.au>
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

This appears to be quite similar to the r8a7740.

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
---
 drivers/net/ethernet/renesas/sh_eth.c | 37 ++++++++++++++++++++++++++++++++---
 drivers/net/ethernet/renesas/sh_eth.h |  2 +-
 2 files changed, 35 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index d256ce1..c7c1daf 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -705,6 +705,36 @@ static struct sh_eth_cpu_data r8a7740_data = {
 	.shift_rd0	= 1,
 };
 
+/* R7S72100 */
+static struct sh_eth_cpu_data r7s72100_data = {
+	.chip_reset	= sh_eth_chip_reset_r8a7740,
+	.set_duplex	= sh_eth_set_duplex,
+	.set_rate	= sh_eth_set_rate_gether,
+
+	.register_type	= SH_ETH_REG_GIGABIT,
+
+	.ecsr_value	= ECSR_LCHNG | ECSR_ICD,
+	.ecsipr_value	= ECSIPR_LCHNGIP | ECSIPR_ICDIP,
+	.eesipr_value	= 0xff7f009f,
+
+	.tx_check	= EESR_TC1 | EESR_FTC,
+	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
+			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
+			  EESR_TDE | EESR_ECI,
+	.fdr_value	= 0x0000070f,
+	.rmcr_value	= RMCR_RNC,
+
+	.apr		= 1,
+	.mpr		= 1,
+	.tpauser	= 1,
+	.hw_swap	= 1,
+	.rpadir		= 1,
+	.rpadir_value   = 2 << 16,
+	.no_trimd	= 1,
+	.tsu		= 1,
+	.shift_rd0	= 1,
+};
+
 static struct sh_eth_cpu_data sh7619_data = {
 	.register_type	= SH_ETH_REG_FAST_SH3_SH2,
 
@@ -1316,9 +1346,9 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 		/*
 		 * In case of almost all GETHER/ETHERs, the Receive Frame State
 		 * (RFS) bits in the Receive Descriptor 0 are from bit 9 to
-		 * bit 0. However, in case of the R8A7740's GETHER, the RFS
-		 * bits are from bit 25 to bit 16. So, the driver needs right
-		 * shifting by 16.
+		 * bit 0. However, in case of the R8A7740 and R7S72100's
+		 * GETHER, the RFS bits are from bit 25 to bit 16.
+		 * So, the driver needs right shifting by 16.
 		 */
 		if (mdp->cd->shift_rd0)
 			desc_status >>= 16;
@@ -2805,6 +2835,7 @@ static struct platform_device_id sh_eth_id_table[] = {
 	{ "sh7757-ether", (kernel_ulong_t)&sh7757_data },
 	{ "sh7757-gether", (kernel_ulong_t)&sh7757_data_giga },
 	{ "sh7763-gether", (kernel_ulong_t)&sh7763_data },
+	{ "r7s72100-gether", (kernel_ulong_t)&r7s72100_data },
 	{ "r8a7740-gether", (kernel_ulong_t)&r8a7740_data },
 	{ "r8a777x-ether", (kernel_ulong_t)&r8a777x_data },
 	{ "r8a7790-ether", (kernel_ulong_t)&r8a7790_data },
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index f32c169..f2d3a9f 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -180,7 +180,7 @@ enum EDSR_BIT {
 };
 #define EDSR_ENALL (EDSR_ENT|EDSR_ENR)
 
-/* GECMR : sh7734, sh7763 and r8a7740 only */
+/* GECMR : sh7734, sh7763, r8a7740 and r7s72100 only */
 enum GECMR_BIT {
 	GECMR_10 = 0x0, GECMR_100 = 0x04, GECMR_1000 = 0x01,
 };
-- 
1.8.4

