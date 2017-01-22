From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/3] sh_eth: rename EESIPR bits
Date: Sun, 22 Jan 2017 22:18:21 +0300
Message-ID: <6851530.HAKW22qnWH@wasted.cogentembedded.com>
References: <1636105.gp4aQxGd5K@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:33859 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751337AbdAVTS0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 14:18:26 -0500
Received: by mail-lf0-f47.google.com with SMTP id v186so83514224lfa.1
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 11:18:25 -0800 (PST)
In-Reply-To: <1636105.gp4aQxGd5K@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the  commit  b0ca2a21f769 ("sh_eth: Add support of SH7763 to sh_eth")
the *enum* declaring the EESIPR bits (interrupt mask) went out of sync with
the *enum* declaring the EESR bits (interrupt status) WRT  bit naming  and
formatting. I'd like to restore the consistency by using EESIPR as the bit
name prefix, renaming the *enum* to EESIPR_BIT, and (finally) renaming the
bits according to the available  Renesas SH77{34|63} manuals...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |   22 ++++++++++----------
 drivers/net/ethernet/renesas/sh_eth.h |   36 +++++++++++++++++++++-------------
 2 files changed, 34 insertions(+), 24 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -556,7 +556,7 @@ static struct sh_eth_cpu_data r8a7740_da
 
 	.ecsr_value	= ECSR_ICD | ECSR_MPD,
 	.ecsipr_value	= ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP,
-	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
+	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ECIIP | 0x003fffff,
 
 	.tx_check	= EESR_TC1 | EESR_FTC,
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
@@ -702,7 +702,7 @@ static struct sh_eth_cpu_data sh7757_dat
 
 	.register_type	= SH_ETH_REG_FAST_SH4,
 
-	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
+	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ECIIP | 0x003fffff,
 
 	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
 	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
@@ -769,7 +769,7 @@ static struct sh_eth_cpu_data sh7757_dat
 
 	.ecsr_value	= ECSR_ICD | ECSR_MPD,
 	.ecsipr_value	= ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP,
-	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
+	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ECIIP | 0x003fffff,
 
 	.tx_check	= EESR_TC1 | EESR_FTC,
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
@@ -800,7 +800,7 @@ static struct sh_eth_cpu_data sh7734_dat
 
 	.ecsr_value	= ECSR_ICD | ECSR_MPD,
 	.ecsipr_value	= ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP,
-	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003f07ff,
+	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ECIIP | 0x003f07ff,
 
 	.tx_check	= EESR_TC1 | EESR_FTC,
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
@@ -830,7 +830,7 @@ static struct sh_eth_cpu_data sh7763_dat
 
 	.ecsr_value	= ECSR_ICD | ECSR_MPD,
 	.ecsipr_value	= ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP,
-	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003f07ff,
+	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ECIIP | 0x003f07ff,
 
 	.tx_check	= EESR_TC1 | EESR_FTC,
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
@@ -851,7 +851,7 @@ static struct sh_eth_cpu_data sh7763_dat
 static struct sh_eth_cpu_data sh7619_data = {
 	.register_type	= SH_ETH_REG_FAST_SH3_SH2,
 
-	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
+	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ECIIP | 0x003fffff,
 
 	.apr		= 1,
 	.mpr		= 1,
@@ -862,7 +862,7 @@ static struct sh_eth_cpu_data sh7619_dat
 static struct sh_eth_cpu_data sh771x_data = {
 	.register_type	= SH_ETH_REG_FAST_SH3_SH2,
 
-	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
+	.eesipr_value	= EESIPR_RFCOFIP | EESIPR_ECIIP | 0x003fffff,
 	.tsu		= 1,
 };
 
@@ -1547,10 +1547,10 @@ static void sh_eth_emac_interrupt(struct
 			sh_eth_rcv_snd_disable(ndev);
 		} else {
 			/* Link Up */
-			sh_eth_modify(ndev, EESIPR, DMAC_M_ECI, 0);
+			sh_eth_modify(ndev, EESIPR, EESIPR_ECIIP, 0);
 			/* clear int */
 			sh_eth_modify(ndev, ECSR, 0, 0);
-			sh_eth_modify(ndev, EESIPR, DMAC_M_ECI, DMAC_M_ECI);
+			sh_eth_modify(ndev, EESIPR, EESIPR_ECIIP, EESIPR_ECIIP);
 			/* enable tx and rx */
 			sh_eth_rcv_snd_enable(ndev);
 		}
@@ -1652,7 +1652,7 @@ static irqreturn_t sh_eth_interrupt(int
 	 * bit...
 	 */
 	intr_enable = sh_eth_read(ndev, EESIPR);
-	intr_status &= intr_enable | DMAC_M_ECI;
+	intr_status &= intr_enable | EESIPR_ECIIP;
 	if (intr_status & (EESR_RX_CHECK | cd->tx_check | EESR_ECI |
 			   cd->eesr_err_check))
 		ret = IRQ_HANDLED;
@@ -3199,7 +3199,7 @@ static int sh_eth_wol_setup(struct net_d
 	/* Only allow ECI interrupts */
 	synchronize_irq(ndev->irq);
 	napi_disable(&mdp->napi);
-	sh_eth_write(ndev, DMAC_M_ECI, EESIPR);
+	sh_eth_write(ndev, EESIPR_ECIIP, EESIPR);
 
 	/* Enable MagicPacket */
 	sh_eth_modify(ndev, ECMR, 0, ECMR_MPDE);
Index: net-next/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net-next/drivers/net/ethernet/renesas/sh_eth.h
@@ -268,19 +268,29 @@ enum EESR_BIT {
 				 EESR_TFE | EESR_TDE)
 
 /* EESIPR */
-enum DMAC_IM_BIT {
-	DMAC_M_TWB = 0x40000000, DMAC_M_TABT = 0x04000000,
-	DMAC_M_RABT = 0x02000000,
-	DMAC_M_RFRMER = 0x01000000, DMAC_M_ADF = 0x00800000,
-	DMAC_M_ECI = 0x00400000, DMAC_M_FTC = 0x00200000,
-	DMAC_M_TDE = 0x00100000, DMAC_M_TFE = 0x00080000,
-	DMAC_M_FRC = 0x00040000, DMAC_M_RDE = 0x00020000,
-	DMAC_M_RFE = 0x00010000, DMAC_M_TINT4 = 0x00000800,
-	DMAC_M_TINT3 = 0x00000400, DMAC_M_TINT2 = 0x00000200,
-	DMAC_M_TINT1 = 0x00000100, DMAC_M_RINT8 = 0x00000080,
-	DMAC_M_RINT5 = 0x00000010, DMAC_M_RINT4 = 0x00000008,
-	DMAC_M_RINT3 = 0x00000004, DMAC_M_RINT2 = 0x00000002,
-	DMAC_M_RINT1 = 0x00000001,
+enum EESIPR_BIT {
+	EESIPR_TWBIP	= 0x40000000,
+	EESIPR_TABTIP	= 0x04000000,
+	EESIPR_RABTIP	= 0x02000000,
+	EESIPR_RFCOFIP	= 0x01000000,
+	EESIPR_ADEIP	= 0x00800000,
+	EESIPR_ECIIP	= 0x00400000,
+	EESIPR_FTCIP	= 0x00200000,
+	EESIPR_TDEIP	= 0x00100000,
+	EESIPR_TFUFIP	= 0x00080000,
+	EESIPR_FRIP	= 0x00040000,
+	EESIPR_RDEIP	= 0x00020000,
+	EESIPR_RFOFIP	= 0x00010000,
+	EESIPR_CNDIP	= 0x00000800,
+	EESIPR_DLCIP	= 0x00000400,
+	EESIPR_CDIP	= 0x00000200,
+	EESIPR_TROIP	= 0x00000100,
+	EESIPR_RMAFIP	= 0x00000080,
+	EESIPR_RRFIP	= 0x00000010,
+	EESIPR_RTLFIP	= 0x00000008,
+	EESIPR_RTSFIP	= 0x00000004,
+	EESIPR_PREIP	= 0x00000002,
+	EESIPR_CERFIP	= 0x00000001,
 };
 
 /* Receive descriptor 0 bits */
