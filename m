From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/3] sh_eth: remove 'tx_error_check' field of 'struct sh_eth_cpu_data'
Date: Thu, 20 Jun 2013 02:22:56 +0400
Message-ID: <201306200222.56406.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 'tx_error_check' field of 'struct sh_eth_cpu_data' is write-only, so remove
it along with the DEFAULT_TX_ERROR_CHECK macro.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against the Dave Miller's 'net-next.git' repo plus the NAPI patches
that I've reposted yesterday.

 drivers/net/ethernet/renesas/sh_eth.c |   14 --------------
 drivers/net/ethernet/renesas/sh_eth.h |    3 ---
 2 files changed, 17 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -384,7 +384,6 @@ static struct sh_eth_cpu_data r8a777x_da
 	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
 	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE |
 			  EESR_RFRMER | EESR_TFE | EESR_TDE | EESR_ECI,
-	.tx_error_check	= EESR_TWB | EESR_TABT | EESR_TDE | EESR_TFE,
 
 	.apr		= 1,
 	.mpr		= 1,
@@ -420,7 +419,6 @@ static struct sh_eth_cpu_data sh7724_dat
 	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
 	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE |
 			  EESR_RFRMER | EESR_TFE | EESR_TDE | EESR_ECI,
-	.tx_error_check	= EESR_TWB | EESR_TABT | EESR_TDE | EESR_TFE,
 
 	.apr		= 1,
 	.mpr		= 1,
@@ -457,7 +455,6 @@ static struct sh_eth_cpu_data sh7757_dat
 	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
 	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE |
 			  EESR_RFRMER | EESR_TFE | EESR_TDE | EESR_ECI,
-	.tx_error_check	= EESR_TWB | EESR_TABT | EESR_TDE | EESR_TFE,
 
 	.irq_flags	= IRQF_SHARED,
 	.apr		= 1,
@@ -527,8 +524,6 @@ static struct sh_eth_cpu_data sh7757_dat
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT | \
 			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE | \
 			  EESR_ECI,
-	.tx_error_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_TDE | \
-			  EESR_TFE,
 	.fdr_value	= 0x0000072f,
 	.rmcr_value	= 0x00000001,
 
@@ -587,8 +582,6 @@ static struct sh_eth_cpu_data sh7734_dat
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT | \
 			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE | \
 			  EESR_ECI,
-	.tx_error_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_TDE | \
-			  EESR_TFE,
 
 	.apr		= 1,
 	.mpr		= 1,
@@ -616,8 +609,6 @@ static struct sh_eth_cpu_data sh7763_dat
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT | \
 			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE | \
 			  EESR_ECI,
-	.tx_error_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_TDE | \
-			  EESR_TFE,
 
 	.apr		= 1,
 	.mpr		= 1,
@@ -655,8 +646,6 @@ static struct sh_eth_cpu_data r8a7740_da
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT | \
 			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE | \
 			  EESR_ECI,
-	.tx_error_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_TDE | \
-			  EESR_TFE,
 
 	.apr		= 1,
 	.mpr		= 1,
@@ -706,9 +695,6 @@ static void sh_eth_set_default_cpu_data(
 
 	if (!cd->eesr_err_check)
 		cd->eesr_err_check = DEFAULT_EESR_ERR_CHECK;
-
-	if (!cd->tx_error_check)
-		cd->tx_error_check = DEFAULT_TX_ERROR_CHECK;
 }
 
 static int sh_eth_check_reset(struct net_device *ndev)
Index: net-next/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net-next/drivers/net/ethernet/renesas/sh_eth.h
@@ -261,8 +261,6 @@ enum EESR_BIT {
 #define DEFAULT_EESR_ERR_CHECK	(EESR_TWB | EESR_TABT | EESR_RABT | \
 				 EESR_RDE | EESR_RFRMER | EESR_ADE | \
 				 EESR_TFE | EESR_TDE | EESR_ECI)
-#define DEFAULT_TX_ERROR_CHECK	(EESR_TWB | EESR_TABT | EESR_ADE | EESR_TDE | \
-				 EESR_TFE)
 
 /* EESIPR */
 enum DMAC_IM_BIT {
@@ -468,7 +466,6 @@ struct sh_eth_cpu_data {
 	/* interrupt checking mask */
 	unsigned long tx_check;
 	unsigned long eesr_err_check;
-	unsigned long tx_error_check;
 
 	/* hardware features */
 	unsigned long irq_flags;	/* IRQ configuration flags */
