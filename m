From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: add/use RMCR.RNC bit
Date: Wed, 16 Oct 2013 02:29:58 +0400
Message-ID: <201310160229.58735.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org,
	davem@davemloft.net, horms@verge.net.au
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declare 'enum EMCR_BIT' containing the single member for the RMCR.RNC bit and
replace bare numbers in the driver by  this mnemonic.

Suggested-by: David Miller <davem@davemloft.net>
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
This patch is against DaveM's 'net.git' repo but it intended for 'net-next.git'
repo -- it's  because 'net-next.git' doesn't contain the required Simon Horman's
patch yet.

 drivers/net/ethernet/renesas/sh_eth.c |    6 +++---
 drivers/net/ethernet/renesas/sh_eth.h |    3 +++
 2 files changed, 6 insertions(+), 3 deletions(-)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -483,7 +483,7 @@ static struct sh_eth_cpu_data sh7757_dat
 	.register_type	= SH_ETH_REG_FAST_SH4,
 
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
-	.rmcr_value	= 0x00000001,
+	.rmcr_value	= RMCR_RNC,
 
 	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
 	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
@@ -561,7 +561,7 @@ static struct sh_eth_cpu_data sh7757_dat
 			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
 			  EESR_TDE | EESR_ECI,
 	.fdr_value	= 0x0000072f,
-	.rmcr_value	= 0x00000001,
+	.rmcr_value	= RMCR_RNC,
 
 	.irq_flags	= IRQF_SHARED,
 	.apr		= 1,
@@ -689,7 +689,7 @@ static struct sh_eth_cpu_data r8a7740_da
 			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
 			  EESR_TDE | EESR_ECI,
 	.fdr_value	= 0x0000070f,
-	.rmcr_value	= 0x00000001,
+	.rmcr_value	= RMCR_RNC,
 
 	.apr		= 1,
 	.mpr		= 1,
Index: net/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net/drivers/net/ethernet/renesas/sh_eth.h
@@ -321,6 +321,9 @@ enum TD_STS_BIT {
 #define TD_TFP	(TD_TFP1|TD_TFP0)
 
 /* RMCR */
+enum RMCR_BIT {
+	RMCR_RNC = 0x00000001,
+};
 #define DEFAULT_RMCR_VALUE	0x00000000
 
 /* ECMR */
