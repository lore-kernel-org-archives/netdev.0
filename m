From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/2] sh_eth: fix unhandled RFE interrupt
Date: Fri, 21 Jun 2013 01:12:21 +0400
Message-ID: <201306210112.22352.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:41190 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965319Ab3FTVMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 17:12:22 -0400
Received: by mail-la0-f41.google.com with SMTP id fn20so6228904lab.28
        for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 14:12:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EESR.RFE (receive FIFO overflow) interrupt is enabled by the driver on all SoCs
and sh_eth_error() handles it but it's not present in any initializer/assignment
of the 'eesr_err_check' field of 'struct sh_eth_cpu_data'. This leads to that
interrupt not being handled and cleared, and finally to disabling IRQ and the
driver being non-functional.

Modify DEFAULT_EESR_ERR_CHECK macro and all explicit initializers of the above
mentioned field to contain the EESR.RFE bit. Remove useless backslashes from the
initializers, while at it.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against Dave Miller's 'net.git' repo.
The bug is 100% reproducible (with added NAPI support) while running certain
'netperf' test.

 drivers/net/ethernet/renesas/sh_eth.c |   33 ++++++++++++++++++---------------
 drivers/net/ethernet/renesas/sh_eth.h |    2 +-
 2 files changed, 19 insertions(+), 16 deletions(-)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -380,8 +380,9 @@ static struct sh_eth_cpu_data sh_eth_my_
 	.eesipr_value	= 0x01ff009f,
 
 	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
-	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE |
-			  EESR_RFRMER | EESR_TFE | EESR_TDE | EESR_ECI,
+	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
+			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE |
+			  EESR_ECI,
 	.tx_error_check	= EESR_TWB | EESR_TABT | EESR_TDE | EESR_TFE,
 
 	.apr		= 1,
@@ -427,8 +428,9 @@ static struct sh_eth_cpu_data sh_eth_my_
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x01ff009f,
 
 	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
-	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE |
-			  EESR_RFRMER | EESR_TFE | EESR_TDE | EESR_ECI,
+	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
+			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE |
+			  EESR_ECI,
 	.tx_error_check	= EESR_TWB | EESR_TABT | EESR_TDE | EESR_TFE,
 
 	.apr		= 1,
@@ -478,8 +480,9 @@ static struct sh_eth_cpu_data sh_eth_my_
 	.rmcr_value	= 0x00000001,
 
 	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
-	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE |
-			  EESR_RFRMER | EESR_TFE | EESR_TDE | EESR_ECI,
+	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
+			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE |
+			  EESR_ECI,
 	.tx_error_check	= EESR_TWB | EESR_TABT | EESR_TDE | EESR_TFE,
 
 	.apr		= 1,
@@ -592,9 +595,9 @@ static struct sh_eth_cpu_data sh_eth_my_
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 
 	.tx_check	= EESR_TC1 | EESR_FTC,
-	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT | \
-			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE | \
-			  EESR_ECI,
+	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
+			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
+			  EESR_TDE | EESR_ECI,
 	.tx_error_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_TDE | \
 			  EESR_TFE,
 	.fdr_value	= 0x0000072f,
@@ -674,9 +677,9 @@ static struct sh_eth_cpu_data sh_eth_my_
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 
 	.tx_check	= EESR_TC1 | EESR_FTC,
-	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT | \
-			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE | \
-			  EESR_ECI,
+	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
+			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
+			  EESR_TDE | EESR_ECI,
 	.tx_error_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_TDE | \
 			  EESR_TFE,
 
@@ -811,9 +814,9 @@ static struct sh_eth_cpu_data sh_eth_my_
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 
 	.tx_check	= EESR_TC1 | EESR_FTC,
-	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT | \
-			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE | \
-			  EESR_ECI,
+	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
+			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
+			  EESR_TDE | EESR_ECI,
 	.tx_error_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_TDE | \
 			  EESR_TFE,
 
Index: net/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net/drivers/net/ethernet/renesas/sh_eth.h
@@ -253,7 +253,7 @@ enum EESR_BIT {
 
 #define DEFAULT_TX_CHECK	(EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | \
 				 EESR_RTO)
-#define DEFAULT_EESR_ERR_CHECK	(EESR_TWB | EESR_TABT | EESR_RABT | \
+#define DEFAULT_EESR_ERR_CHECK	(EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE | \
 				 EESR_RDE | EESR_RFRMER | EESR_ADE | \
 				 EESR_TFE | EESR_TDE | EESR_ECI)
 #define DEFAULT_TX_ERROR_CHECK	(EESR_TWB | EESR_TABT | EESR_ADE | EESR_TDE | \
