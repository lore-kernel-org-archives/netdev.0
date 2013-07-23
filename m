From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH v4 net-next repost 2/2] sh_eth: Add support for r8a7790 SoC
Date: Tue, 23 Jul 2013 10:18:05 +0900
Message-ID: <1374542285-19602-3-git-send-email-horms+renesas@verge.net.au>
References: <1374542285-19602-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: netdev@vger.kernel.org, linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1374542285-19602-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a copy of support for r8a7778/9 with the .rmiimode mode bit
of struct sh_eth_cpu_data set.

Also update R8A7779 to R8A777x.

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

---

v4
* s/R8A7779/R8A777x/ as requested by Sergei Shtylyov.

v3
* Add r8a7790_data rather than updating r8a777x_data.
  As requested by Sergei Shtylyov.

v2
* Split from "sh_eth: add support RMIIMODE register"
---
 drivers/net/ethernet/renesas/Kconfig  |  2 +-
 drivers/net/ethernet/renesas/sh_eth.c | 21 +++++++++++++++++++++
 2 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/Kconfig b/drivers/net/ethernet/renesas/Kconfig
index 19a8a04..a30c439 100644
--- a/drivers/net/ethernet/renesas/Kconfig
+++ b/drivers/net/ethernet/renesas/Kconfig
@@ -13,4 +13,4 @@ config SH_ETH
 	  Renesas SuperH Ethernet device driver.
 	  This driver supporting CPUs are:
 		- SH7619, SH7710, SH7712, SH7724, SH7734, SH7763, SH7757,
-		  R8A7740 and R8A7779.
+		  R8A7740, R8A777x and R8A7790.
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 87af49f..fedc0a0 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -393,6 +393,26 @@ static struct sh_eth_cpu_data r8a777x_data = {
 	.hw_swap	= 1,
 };
 
+/* R8A7790 */
+static struct sh_eth_cpu_data r8a7790_data = {
+	.set_duplex	= sh_eth_set_duplex,
+	.set_rate	= sh_eth_set_rate_r8a777x,
+
+	.ecsr_value	= ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD,
+	.ecsipr_value	= ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | ECSIPR_ICDIP,
+	.eesipr_value	= 0x01ff009f,
+
+	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
+	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE |
+			  EESR_RFRMER | EESR_TFE | EESR_TDE | EESR_ECI,
+
+	.apr		= 1,
+	.mpr		= 1,
+	.tpauser	= 1,
+	.hw_swap	= 1,
+	.rmiimode	= 1,
+};
+
 static void sh_eth_set_rate_sh7724(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -2753,6 +2773,7 @@ static struct platform_device_id sh_eth_id_table[] = {
 	{ "sh7763-gether", (kernel_ulong_t)&sh7763_data },
 	{ "r8a7740-gether", (kernel_ulong_t)&r8a7740_data },
 	{ "r8a777x-ether", (kernel_ulong_t)&r8a777x_data },
+	{ "r8a7790-ether", (kernel_ulong_t)&r8a7790_data },
 	{ }
 };
 MODULE_DEVICE_TABLE(platform, sh_eth_id_table);
-- 
1.8.2.1

