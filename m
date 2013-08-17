From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/2] sh_eth: get register layout from 'struct sh_eth_cpu_data'
Date: Sun, 18 Aug 2013 03:11:28 +0400
Message-ID: <201308180311.28814.sergei.shtylyov@cogentembedded.com>
References: <201308180308.39941.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201308180308.39941.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The register layout is a SoC characteristic, so it's wrong that it's stored
in the otherwise board specific platform data. Add 'register_type' field to
'struct sh_eth_cpu_data', initialize it properly for each SoC, and read  it
from this structure instead of the platfrom data from now on...  

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |   22 +++++++++++++++++++++-
 drivers/net/ethernet/renesas/sh_eth.h |    1 +
 2 files changed, 22 insertions(+), 1 deletion(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -378,6 +378,8 @@ static struct sh_eth_cpu_data r8a777x_da
 	.set_duplex	= sh_eth_set_duplex,
 	.set_rate	= sh_eth_set_rate_r8a777x,
 
+	.register_type	= SH_ETH_REG_FAST_RCAR,
+
 	.ecsr_value	= ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD,
 	.ecsipr_value	= ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | ECSIPR_ICDIP,
 	.eesipr_value	= 0x01ff009f,
@@ -398,6 +400,8 @@ static struct sh_eth_cpu_data r8a7790_da
 	.set_duplex	= sh_eth_set_duplex,
 	.set_rate	= sh_eth_set_rate_r8a777x,
 
+	.register_type	= SH_ETH_REG_FAST_RCAR,
+
 	.ecsr_value	= ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD,
 	.ecsipr_value	= ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | ECSIPR_ICDIP,
 	.eesipr_value	= 0x01ff009f,
@@ -435,6 +439,8 @@ static struct sh_eth_cpu_data sh7724_dat
 	.set_duplex	= sh_eth_set_duplex,
 	.set_rate	= sh_eth_set_rate_sh7724,
 
+	.register_type	= SH_ETH_REG_FAST_SH4,
+
 	.ecsr_value	= ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD,
 	.ecsipr_value	= ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | ECSIPR_ICDIP,
 	.eesipr_value	= 0x01ff009f,
@@ -473,6 +479,8 @@ static struct sh_eth_cpu_data sh7757_dat
 	.set_duplex	= sh_eth_set_duplex,
 	.set_rate	= sh_eth_set_rate_sh7757,
 
+	.register_type	= SH_ETH_REG_FAST_SH4,
+
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 	.rmcr_value	= 0x00000001,
 
@@ -541,6 +549,8 @@ static struct sh_eth_cpu_data sh7757_dat
 	.set_duplex	= sh_eth_set_duplex,
 	.set_rate	= sh_eth_set_rate_giga,
 
+	.register_type	= SH_ETH_REG_GIGABIT,
+
 	.ecsr_value	= ECSR_ICD | ECSR_MPD,
 	.ecsipr_value	= ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP,
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
@@ -599,6 +609,8 @@ static struct sh_eth_cpu_data sh7734_dat
 	.set_duplex	= sh_eth_set_duplex,
 	.set_rate	= sh_eth_set_rate_gether,
 
+	.register_type	= SH_ETH_REG_GIGABIT,
+
 	.ecsr_value	= ECSR_ICD | ECSR_MPD,
 	.ecsipr_value	= ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP,
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
@@ -626,6 +638,8 @@ static struct sh_eth_cpu_data sh7763_dat
 	.set_duplex	= sh_eth_set_duplex,
 	.set_rate	= sh_eth_set_rate_gether,
 
+	.register_type	= SH_ETH_REG_GIGABIT,
+
 	.ecsr_value	= ECSR_ICD | ECSR_MPD,
 	.ecsipr_value	= ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP,
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
@@ -663,6 +677,8 @@ static struct sh_eth_cpu_data r8a7740_da
 	.set_duplex	= sh_eth_set_duplex,
 	.set_rate	= sh_eth_set_rate_gether,
 
+	.register_type	= SH_ETH_REG_GIGABIT,
+
 	.ecsr_value	= ECSR_ICD | ECSR_MPD,
 	.ecsipr_value	= ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP,
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
@@ -685,6 +701,8 @@ static struct sh_eth_cpu_data r8a7740_da
 };
 
 static struct sh_eth_cpu_data sh7619_data = {
+	.register_type	= SH_ETH_REG_FAST_SH3_SH2,
+
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 
 	.apr		= 1,
@@ -694,6 +712,8 @@ static struct sh_eth_cpu_data sh7619_dat
 };
 
 static struct sh_eth_cpu_data sh771x_data = {
+	.register_type	= SH_ETH_REG_FAST_SH3_SH2,
+
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 	.tsu		= 1,
 };
@@ -2643,10 +2663,10 @@ static int sh_eth_drv_probe(struct platf
 	mdp->edmac_endian = pd->edmac_endian;
 	mdp->no_ether_link = pd->no_ether_link;
 	mdp->ether_link_active_low = pd->ether_link_active_low;
-	mdp->reg_offset = sh_eth_get_register_offset(pd->register_type);
 
 	/* set cpu data */
 	mdp->cd = (struct sh_eth_cpu_data *)id->driver_data;
+	mdp->reg_offset = sh_eth_get_register_offset(mdp->cd->register_type);
 	sh_eth_set_default_cpu_data(mdp->cd);
 
 	/* set function */
Index: net-next/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net-next/drivers/net/ethernet/renesas/sh_eth.h
@@ -454,6 +454,7 @@ struct sh_eth_cpu_data {
 	void (*set_rate)(struct net_device *ndev);
 
 	/* mandatory initialize value */
+	int register_type;
 	unsigned long eesipr_value;
 
 	/* optional initialize value */
