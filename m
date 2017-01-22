From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 3/3] sh_eth: stop using bare numbers for EESIPR values
Date: Sun, 22 Jan 2017 22:19:36 +0300
Message-ID: <4605565.M0SEEbnHAH@wasted.cogentembedded.com>
References: <1636105.gp4aQxGd5K@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1636105.gp4aQxGd5K@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now  that we  have almost all EESIPR bits declared (and those that  are
still not are most probably reserved anyway) we can at last replace the
bare  numbers used for 'sh_eth_cpu_data::eesipr_value' initializers with
the bit names ORed together...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |   89 +++++++++++++++++++++++++++++-----
 1 file changed, 78 insertions(+), 11 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -518,7 +518,14 @@ static struct sh_eth_cpu_data r7s72100_d
 
 	.ecsr_value	= ECSR_ICD,
 	.ecsipr_value	= ECSIPR_ICDIP,
-	.eesipr_value	= 0xe77f009f,
+	.eesipr_value	= EESIPR_TWB1IP | EESIPR_TWBIP | EESIPR_TC1IP |
+			  EESIPR_TABTIP | EESIPR_RABTIP | EESIPR_RFCOFIP |
+			  EESIPR_ECIIP |
+			  EESIPR_FTCIP | EESIPR_TDEIP | EESIPR_TFUFIP |
+			  EESIPR_FRIP | EESIPR_RDEIP | EESIPR_RFOFIP |
+			  EESIPR_RMAFIP | EESIPR_RRFIP |
+			  EESIPR_RTLFIP | EESIPR_RTSFIP |
+			  EESIPR_PREIP | EESIPR_CERFIP,
 
 	.tx_check	= EESR_TC1 | EESR_FTC,
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
@@ -556,7 +563,14 @@ static struct sh_eth_cpu_data r8a7740_da
 
 	.ecsr_value	= ECSR_ICD | ECSR_MPD,
 	.ecsipr_value	= ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP,
-	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ECIIP | 0x003fffff,
+	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ECIIP |
+			  EESIPR_FTCIP | EESIPR_TDEIP | EESIPR_TFUFIP |
+			  EESIPR_FRIP | EESIPR_RDEIP | EESIPR_RFOFIP |
+			  0x0000f000 | EESIPR_CNDIP | EESIPR_DLCIP |
+			  EESIPR_CDIP | EESIPR_TROIP | EESIPR_RMAFIP |
+			  EESIPR_CEEFIP | EESIPR_CELFIP |
+			  EESIPR_RRFIP | EESIPR_RTLFIP | EESIPR_RTSFIP |
+			  EESIPR_PREIP | EESIPR_CERFIP,
 
 	.tx_check	= EESR_TC1 | EESR_FTC,
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
@@ -603,7 +617,12 @@ static struct sh_eth_cpu_data r8a777x_da
 
 	.ecsr_value	= ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD,
 	.ecsipr_value	= ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | ECSIPR_ICDIP,
-	.eesipr_value	= 0x01ff009f,
+	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ADEIP | EESIPR_ECIIP |
+			  EESIPR_FTCIP | EESIPR_TDEIP | EESIPR_TFUFIP |
+			  EESIPR_FRIP | EESIPR_RDEIP | EESIPR_RFOFIP |
+			  EESIPR_RMAFIP | EESIPR_RRFIP |
+			  EESIPR_RTLFIP | EESIPR_RTSFIP |
+			  EESIPR_PREIP | EESIPR_CERFIP,
 
 	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
 	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
@@ -626,7 +645,12 @@ static struct sh_eth_cpu_data r8a779x_da
 	.ecsr_value	= ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD | ECSR_MPD,
 	.ecsipr_value	= ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | ECSIPR_ICDIP |
 			  ECSIPR_MPDIP,
-	.eesipr_value	= 0x01ff009f,
+	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ADEIP | EESIPR_ECIIP |
+			  EESIPR_FTCIP | EESIPR_TDEIP | EESIPR_TFUFIP |
+			  EESIPR_FRIP | EESIPR_RDEIP | EESIPR_RFOFIP |
+			  EESIPR_RMAFIP | EESIPR_RRFIP |
+			  EESIPR_RTLFIP | EESIPR_RTSFIP |
+			  EESIPR_PREIP | EESIPR_CERFIP,
 
 	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
 	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
@@ -667,7 +691,12 @@ static struct sh_eth_cpu_data sh7724_dat
 
 	.ecsr_value	= ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD,
 	.ecsipr_value	= ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | ECSIPR_ICDIP,
-	.eesipr_value	= 0x01ff009f,
+	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ADEIP | EESIPR_ECIIP |
+			  EESIPR_FTCIP | EESIPR_TDEIP | EESIPR_TFUFIP |
+			  EESIPR_FRIP | EESIPR_RDEIP | EESIPR_RFOFIP |
+			  EESIPR_RMAFIP | EESIPR_RRFIP |
+			  EESIPR_RTLFIP | EESIPR_RTSFIP |
+			  EESIPR_PREIP | EESIPR_CERFIP,
 
 	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
 	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
@@ -702,7 +731,14 @@ static struct sh_eth_cpu_data sh7757_dat
 
 	.register_type	= SH_ETH_REG_FAST_SH4,
 
-	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ECIIP | 0x003fffff,
+	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ECIIP |
+			  EESIPR_FTCIP | EESIPR_TDEIP | EESIPR_TFUFIP |
+			  EESIPR_FRIP | EESIPR_RDEIP | EESIPR_RFOFIP |
+			  0x0000f000 | EESIPR_CNDIP | EESIPR_DLCIP |
+			  EESIPR_CDIP | EESIPR_TROIP | EESIPR_RMAFIP |
+			  EESIPR_CEEFIP | EESIPR_CELFIP |
+			  EESIPR_RRFIP | EESIPR_RTLFIP | EESIPR_RTSFIP |
+			  EESIPR_PREIP | EESIPR_CERFIP,
 
 	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
 	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
@@ -769,7 +805,14 @@ static struct sh_eth_cpu_data sh7757_dat
 
 	.ecsr_value	= ECSR_ICD | ECSR_MPD,
 	.ecsipr_value	= ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP,
-	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ECIIP | 0x003fffff,
+	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ECIIP |
+			  EESIPR_FTCIP | EESIPR_TDEIP | EESIPR_TFUFIP |
+			  EESIPR_FRIP | EESIPR_RDEIP | EESIPR_RFOFIP |
+			  0x0000f000 | EESIPR_CNDIP | EESIPR_DLCIP |
+			  EESIPR_CDIP | EESIPR_TROIP | EESIPR_RMAFIP |
+			  EESIPR_CEEFIP | EESIPR_CELFIP |
+			  EESIPR_RRFIP | EESIPR_RTLFIP | EESIPR_RTSFIP |
+			  EESIPR_PREIP | EESIPR_CERFIP,
 
 	.tx_check	= EESR_TC1 | EESR_FTC,
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
@@ -800,7 +843,12 @@ static struct sh_eth_cpu_data sh7734_dat
 
 	.ecsr_value	= ECSR_ICD | ECSR_MPD,
 	.ecsipr_value	= ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP,
-	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ECIIP | 0x003f07ff,
+	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ECIIP |
+			  EESIPR_FTCIP | EESIPR_TDEIP | EESIPR_TFUFIP |
+			  EESIPR_FRIP | EESIPR_RDEIP | EESIPR_RFOFIP |
+			  EESIPR_RMAFIP | EESIPR_CEEFIP | EESIPR_CELFIP |
+			  EESIPR_RRFIP | EESIPR_RTLFIP | EESIPR_RTSFIP |
+			  EESIPR_PREIP | EESIPR_CERFIP,
 
 	.tx_check	= EESR_TC1 | EESR_FTC,
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
@@ -830,7 +878,12 @@ static struct sh_eth_cpu_data sh7763_dat
 
 	.ecsr_value	= ECSR_ICD | ECSR_MPD,
 	.ecsipr_value	= ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP,
-	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ECIIP | 0x003f07ff,
+	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ECIIP |
+			  EESIPR_FTCIP | EESIPR_TDEIP | EESIPR_TFUFIP |
+			  EESIPR_FRIP | EESIPR_RDEIP | EESIPR_RFOFIP |
+			  EESIPR_RMAFIP | EESIPR_CEEFIP | EESIPR_CELFIP |
+			  EESIPR_RRFIP | EESIPR_RTLFIP | EESIPR_RTSFIP |
+			  EESIPR_PREIP | EESIPR_CERFIP,
 
 	.tx_check	= EESR_TC1 | EESR_FTC,
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
@@ -851,7 +904,14 @@ static struct sh_eth_cpu_data sh7763_dat
 static struct sh_eth_cpu_data sh7619_data = {
 	.register_type	= SH_ETH_REG_FAST_SH3_SH2,
 
-	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ECIIP | 0x003fffff,
+	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ECIIP |
+			  EESIPR_FTCIP | EESIPR_TDEIP | EESIPR_TFUFIP |
+			  EESIPR_FRIP | EESIPR_RDEIP | EESIPR_RFOFIP |
+			  0x0000f000 | EESIPR_CNDIP | EESIPR_DLCIP |
+			  EESIPR_CDIP | EESIPR_TROIP | EESIPR_RMAFIP |
+			  EESIPR_CEEFIP | EESIPR_CELFIP |
+			  EESIPR_RRFIP | EESIPR_RTLFIP | EESIPR_RTSFIP |
+			  EESIPR_PREIP | EESIPR_CERFIP,
 
 	.apr		= 1,
 	.mpr		= 1,
@@ -862,7 +922,14 @@ static struct sh_eth_cpu_data sh7619_dat
 static struct sh_eth_cpu_data sh771x_data = {
 	.register_type	= SH_ETH_REG_FAST_SH3_SH2,
 
-	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ECIIP | 0x003fffff,
+	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ECIIP |
+			  EESIPR_FTCIP | EESIPR_TDEIP | EESIPR_TFUFIP |
+			  EESIPR_FRIP | EESIPR_RDEIP | EESIPR_RFOFIP |
+			  0x0000f000 | EESIPR_CNDIP | EESIPR_DLCIP |
+			  EESIPR_CDIP | EESIPR_TROIP | EESIPR_RMAFIP |
+			  EESIPR_CEEFIP | EESIPR_CELFIP |
+			  EESIPR_RRFIP | EESIPR_RTLFIP | EESIPR_RTSFIP |
+			  EESIPR_PREIP | EESIPR_CERFIP,
 	.tsu		= 1,
 };
 
