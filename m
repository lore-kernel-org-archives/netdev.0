From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 34/52] sfc: Remove remnants of multi-port abstraction for MAC registers
Date: Mon, 1 Sep 2008 12:48:41 +0100
Message-ID: <20080901114840.GB7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:41184 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757843AbYIALsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:48:45 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon_hwdefs.h |   40 +++----
 drivers/net/sfc/falcon_xmac.c   |  248 +++++++++++++++++----------------------
 drivers/net/sfc/mac.h           |    4 -
 drivers/net/sfc/sfe4001.c       |    7 +-
 4 files changed, 129 insertions(+), 170 deletions(-)

diff --git a/drivers/net/sfc/falcon_hwdefs.h b/drivers/net/sfc/falcon_hwdefs.h
index 626735e..7c784f7 100644
--- a/drivers/net/sfc/falcon_hwdefs.h
+++ b/drivers/net/sfc/falcon_hwdefs.h
@@ -493,18 +493,8 @@
 #define MAC_MCAST_HASH_REG0_KER 0xca0
 #define MAC_MCAST_HASH_REG1_KER 0xcb0
 
-/* GMAC registers */
-#define FALCON_GMAC_REGBANK 0xe00
-#define FALCON_GMAC_REGBANK_SIZE 0x200
-#define FALCON_GMAC_REG_SIZE 0x10
-
-/* XMAC registers */
-#define FALCON_XMAC_REGBANK 0x1200
-#define FALCON_XMAC_REGBANK_SIZE 0x200
-#define FALCON_XMAC_REG_SIZE 0x10
-
 /* XGMAC address register low */
-#define XM_ADR_LO_REG_MAC 0x00
+#define XM_ADR_LO_REG 0x1200
 #define XM_ADR_3_LBN 24
 #define XM_ADR_3_WIDTH 8
 #define XM_ADR_2_LBN 16
@@ -515,14 +505,14 @@
 #define XM_ADR_0_WIDTH 8
 
 /* XGMAC address register high */
-#define XM_ADR_HI_REG_MAC 0x01
+#define XM_ADR_HI_REG 0x1210
 #define XM_ADR_5_LBN 8
 #define XM_ADR_5_WIDTH 8
 #define XM_ADR_4_LBN 0
 #define XM_ADR_4_WIDTH 8
 
 /* XGMAC global configuration */
-#define XM_GLB_CFG_REG_MAC 0x02
+#define XM_GLB_CFG_REG 0x1220
 #define XM_RX_STAT_EN_LBN 11
 #define XM_RX_STAT_EN_WIDTH 1
 #define XM_TX_STAT_EN_LBN 10
@@ -535,7 +525,7 @@
 #define XM_CORE_RST_WIDTH 1
 
 /* XGMAC transmit configuration */
-#define XM_TX_CFG_REG_MAC 0x03
+#define XM_TX_CFG_REG 0x1230
 #define XM_IPG_LBN 16
 #define XM_IPG_WIDTH 4
 #define XM_FCNTL_LBN 10
@@ -550,7 +540,7 @@
 #define XM_TXEN_WIDTH 1
 
 /* XGMAC receive configuration */
-#define XM_RX_CFG_REG_MAC 0x04
+#define XM_RX_CFG_REG 0x1240
 #define XM_PASS_CRC_ERR_LBN 25
 #define XM_PASS_CRC_ERR_WIDTH 1
 #define XM_ACPT_ALL_MCAST_LBN 11
@@ -563,7 +553,7 @@
 #define XM_RXEN_WIDTH 1
 
 /* XGMAC management interrupt mask register */
-#define XM_MGT_INT_MSK_REG_MAC_B0 0x5
+#define XM_MGT_INT_MSK_REG_B0 0x1250
 #define XM_MSK_PRMBLE_ERR_LBN 2
 #define XM_MSK_PRMBLE_ERR_WIDTH 1
 #define XM_MSK_RMTFLT_LBN 1
@@ -572,29 +562,29 @@
 #define XM_MSK_LCLFLT_WIDTH 1
 
 /* XGMAC flow control register */
-#define XM_FC_REG_MAC 0x7
+#define XM_FC_REG 0x1270
 #define XM_PAUSE_TIME_LBN 16
 #define XM_PAUSE_TIME_WIDTH 16
 #define XM_DIS_FCNTL_LBN 0
 #define XM_DIS_FCNTL_WIDTH 1
 
 /* XGMAC pause time count register */
-#define XM_PAUSE_TIME_REG_MAC 0x9
+#define XM_PAUSE_TIME_REG 0x1290
 
 /* XGMAC transmit parameter register */
-#define XM_TX_PARAM_REG_MAC 0x0d
+#define XM_TX_PARAM_REG 0x012d0
 #define XM_TX_JUMBO_MODE_LBN 31
 #define XM_TX_JUMBO_MODE_WIDTH 1
 #define XM_MAX_TX_FRM_SIZE_LBN 16
 #define XM_MAX_TX_FRM_SIZE_WIDTH 14
 
 /* XGMAC receive parameter register */
-#define XM_RX_PARAM_REG_MAC 0x0e
+#define XM_RX_PARAM_REG 0x12e0
 #define XM_MAX_RX_FRM_SIZE_LBN 0
 #define XM_MAX_RX_FRM_SIZE_WIDTH 14
 
 /* XGMAC management interrupt status register */
-#define XM_MGT_INT_REG_MAC_B0 0x0f
+#define XM_MGT_INT_REG_B0 0x12f0
 #define XM_PRMBLE_ERR 2
 #define XM_PRMBLE_WIDTH 1
 #define XM_RMTFLT_LBN 1
@@ -603,7 +593,7 @@
 #define XM_LCLFLT_WIDTH 1
 
 /* XGXS/XAUI powerdown/reset register */
-#define XX_PWR_RST_REG_MAC 0x10
+#define XX_PWR_RST_REG 0x1300
 
 #define XX_PWRDND_EN_LBN 15
 #define XX_PWRDND_EN_WIDTH 1
@@ -633,7 +623,7 @@
 #define XX_RST_XX_EN_WIDTH 1
 
 /* XGXS/XAUI powerdown/reset control register */
-#define XX_SD_CTL_REG_MAC 0x11
+#define XX_SD_CTL_REG 0x1310
 #define XX_HIDRVD_LBN 15
 #define XX_HIDRVD_WIDTH 1
 #define XX_LODRVD_LBN 14
@@ -659,7 +649,7 @@
 #define XX_LPBKA_LBN 0
 #define XX_LPBKA_WIDTH 1
 
-#define XX_TXDRV_CTL_REG_MAC 0x12
+#define XX_TXDRV_CTL_REG 0x1320
 #define XX_DEQD_LBN 28
 #define XX_DEQD_WIDTH 4
 #define XX_DEQC_LBN 24
@@ -678,7 +668,7 @@
 #define XX_DTXA_WIDTH 4
 
 /* XAUI XGXS core status register */
-#define XX_CORE_STAT_REG_MAC 0x16
+#define XX_CORE_STAT_REG 0x1360
 #define XX_FORCE_SIG_LBN 24
 #define XX_FORCE_SIG_WIDTH 8
 #define XX_FORCE_SIG_DECODE_FORCED 0xff
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index 5620d9d..a9ae06a 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -23,48 +23,20 @@
 
 /**************************************************************************
  *
- * MAC register access
- *
- **************************************************************************/
-
-/* Offset of an XMAC register within Falcon */
-#define FALCON_XMAC_REG(mac_reg)					\
-	(FALCON_XMAC_REGBANK + ((mac_reg) * FALCON_XMAC_REG_SIZE))
-
-void falcon_xmac_writel(struct efx_nic *efx,
-			 efx_dword_t *value, unsigned int mac_reg)
-{
-	efx_oword_t temp;
-
-	EFX_POPULATE_OWORD_1(temp, MAC_DATA, EFX_DWORD_FIELD(*value, MAC_DATA));
-	falcon_write(efx, &temp, FALCON_XMAC_REG(mac_reg));
-}
-
-void falcon_xmac_readl(struct efx_nic *efx,
-		       efx_dword_t *value, unsigned int mac_reg)
-{
-	efx_oword_t temp;
-
-	falcon_read(efx, &temp, FALCON_XMAC_REG(mac_reg));
-	EFX_POPULATE_DWORD_1(*value, MAC_DATA, EFX_OWORD_FIELD(temp, MAC_DATA));
-}
-
-/**************************************************************************
- *
  * MAC operations
  *
  *************************************************************************/
 static int falcon_reset_xmac(struct efx_nic *efx)
 {
-	efx_dword_t reg;
+	efx_oword_t reg;
 	int count;
 
-	EFX_POPULATE_DWORD_1(reg, XM_CORE_RST, 1);
-	falcon_xmac_writel(efx, &reg, XM_GLB_CFG_REG_MAC);
+	EFX_POPULATE_OWORD_1(reg, XM_CORE_RST, 1);
+	falcon_write(efx, &reg, XM_GLB_CFG_REG);
 
 	for (count = 0; count < 10000; count++) {	/* wait upto 100ms */
-		falcon_xmac_readl(efx, &reg, XM_GLB_CFG_REG_MAC);
-		if (EFX_DWORD_FIELD(reg, XM_CORE_RST) == 0)
+		falcon_read(efx, &reg, XM_GLB_CFG_REG);
+		if (EFX_OWORD_FIELD(reg, XM_CORE_RST) == 0)
 			return 0;
 		udelay(10);
 	}
@@ -76,25 +48,25 @@ static int falcon_reset_xmac(struct efx_nic *efx)
 /* Configure the XAUI driver that is an output from Falcon */
 static void falcon_setup_xaui(struct efx_nic *efx)
 {
-	efx_dword_t sdctl, txdrv;
+	efx_oword_t sdctl, txdrv;
 
 	/* Move the XAUI into low power, unless there is no PHY, in
 	 * which case the XAUI will have to drive a cable. */
 	if (efx->phy_type == PHY_TYPE_NONE)
 		return;
 
-	falcon_xmac_readl(efx, &sdctl, XX_SD_CTL_REG_MAC);
-	EFX_SET_DWORD_FIELD(sdctl, XX_HIDRVD, XX_SD_CTL_DRV_DEFAULT);
-	EFX_SET_DWORD_FIELD(sdctl, XX_LODRVD, XX_SD_CTL_DRV_DEFAULT);
-	EFX_SET_DWORD_FIELD(sdctl, XX_HIDRVC, XX_SD_CTL_DRV_DEFAULT);
-	EFX_SET_DWORD_FIELD(sdctl, XX_LODRVC, XX_SD_CTL_DRV_DEFAULT);
-	EFX_SET_DWORD_FIELD(sdctl, XX_HIDRVB, XX_SD_CTL_DRV_DEFAULT);
-	EFX_SET_DWORD_FIELD(sdctl, XX_LODRVB, XX_SD_CTL_DRV_DEFAULT);
-	EFX_SET_DWORD_FIELD(sdctl, XX_HIDRVA, XX_SD_CTL_DRV_DEFAULT);
-	EFX_SET_DWORD_FIELD(sdctl, XX_LODRVA, XX_SD_CTL_DRV_DEFAULT);
-	falcon_xmac_writel(efx, &sdctl, XX_SD_CTL_REG_MAC);
-
-	EFX_POPULATE_DWORD_8(txdrv,
+	falcon_read(efx, &sdctl, XX_SD_CTL_REG);
+	EFX_SET_OWORD_FIELD(sdctl, XX_HIDRVD, XX_SD_CTL_DRV_DEFAULT);
+	EFX_SET_OWORD_FIELD(sdctl, XX_LODRVD, XX_SD_CTL_DRV_DEFAULT);
+	EFX_SET_OWORD_FIELD(sdctl, XX_HIDRVC, XX_SD_CTL_DRV_DEFAULT);
+	EFX_SET_OWORD_FIELD(sdctl, XX_LODRVC, XX_SD_CTL_DRV_DEFAULT);
+	EFX_SET_OWORD_FIELD(sdctl, XX_HIDRVB, XX_SD_CTL_DRV_DEFAULT);
+	EFX_SET_OWORD_FIELD(sdctl, XX_LODRVB, XX_SD_CTL_DRV_DEFAULT);
+	EFX_SET_OWORD_FIELD(sdctl, XX_HIDRVA, XX_SD_CTL_DRV_DEFAULT);
+	EFX_SET_OWORD_FIELD(sdctl, XX_LODRVA, XX_SD_CTL_DRV_DEFAULT);
+	falcon_write(efx, &sdctl, XX_SD_CTL_REG);
+
+	EFX_POPULATE_OWORD_8(txdrv,
 			     XX_DEQD, XX_TXDRV_DEQ_DEFAULT,
 			     XX_DEQC, XX_TXDRV_DEQ_DEFAULT,
 			     XX_DEQB, XX_TXDRV_DEQ_DEFAULT,
@@ -103,67 +75,67 @@ static void falcon_setup_xaui(struct efx_nic *efx)
 			     XX_DTXC, XX_TXDRV_DTX_DEFAULT,
 			     XX_DTXB, XX_TXDRV_DTX_DEFAULT,
 			     XX_DTXA, XX_TXDRV_DTX_DEFAULT);
-	falcon_xmac_writel(efx, &txdrv, XX_TXDRV_CTL_REG_MAC);
+	falcon_write(efx, &txdrv, XX_TXDRV_CTL_REG);
 }
 
 static void falcon_hold_xaui_in_rst(struct efx_nic *efx)
 {
-	efx_dword_t reg;
-
-	EFX_ZERO_DWORD(reg);
-	EFX_SET_DWORD_FIELD(reg, XX_PWRDNA_EN, 1);
-	EFX_SET_DWORD_FIELD(reg, XX_PWRDNB_EN, 1);
-	EFX_SET_DWORD_FIELD(reg, XX_PWRDNC_EN, 1);
-	EFX_SET_DWORD_FIELD(reg, XX_PWRDND_EN, 1);
-	EFX_SET_DWORD_FIELD(reg, XX_RSTPLLAB_EN, 1);
-	EFX_SET_DWORD_FIELD(reg, XX_RSTPLLCD_EN, 1);
-	EFX_SET_DWORD_FIELD(reg, XX_RESETA_EN, 1);
-	EFX_SET_DWORD_FIELD(reg, XX_RESETB_EN, 1);
-	EFX_SET_DWORD_FIELD(reg, XX_RESETC_EN, 1);
-	EFX_SET_DWORD_FIELD(reg, XX_RESETD_EN, 1);
-	EFX_SET_DWORD_FIELD(reg, XX_RSTXGXSRX_EN, 1);
-	EFX_SET_DWORD_FIELD(reg, XX_RSTXGXSTX_EN, 1);
-	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	efx_oword_t reg;
+
+	EFX_ZERO_OWORD(reg);
+	EFX_SET_OWORD_FIELD(reg, XX_PWRDNA_EN, 1);
+	EFX_SET_OWORD_FIELD(reg, XX_PWRDNB_EN, 1);
+	EFX_SET_OWORD_FIELD(reg, XX_PWRDNC_EN, 1);
+	EFX_SET_OWORD_FIELD(reg, XX_PWRDND_EN, 1);
+	EFX_SET_OWORD_FIELD(reg, XX_RSTPLLAB_EN, 1);
+	EFX_SET_OWORD_FIELD(reg, XX_RSTPLLCD_EN, 1);
+	EFX_SET_OWORD_FIELD(reg, XX_RESETA_EN, 1);
+	EFX_SET_OWORD_FIELD(reg, XX_RESETB_EN, 1);
+	EFX_SET_OWORD_FIELD(reg, XX_RESETC_EN, 1);
+	EFX_SET_OWORD_FIELD(reg, XX_RESETD_EN, 1);
+	EFX_SET_OWORD_FIELD(reg, XX_RSTXGXSRX_EN, 1);
+	EFX_SET_OWORD_FIELD(reg, XX_RSTXGXSTX_EN, 1);
+	falcon_write(efx, &reg, XX_PWR_RST_REG);
 	udelay(10);
 }
 
 static int _falcon_reset_xaui_a(struct efx_nic *efx)
 {
-	efx_dword_t reg;
+	efx_oword_t reg;
 
 	falcon_hold_xaui_in_rst(efx);
-	falcon_xmac_readl(efx, &reg, XX_PWR_RST_REG_MAC);
+	falcon_read(efx, &reg, XX_PWR_RST_REG);
 
 	/* Follow the RAMBUS XAUI data reset sequencing
 	 * Channels A and B first: power down, reset PLL, reset, clear
 	 */
-	EFX_SET_DWORD_FIELD(reg, XX_PWRDNA_EN, 0);
-	EFX_SET_DWORD_FIELD(reg, XX_PWRDNB_EN, 0);
-	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	EFX_SET_OWORD_FIELD(reg, XX_PWRDNA_EN, 0);
+	EFX_SET_OWORD_FIELD(reg, XX_PWRDNB_EN, 0);
+	falcon_write(efx, &reg, XX_PWR_RST_REG);
 	udelay(10);
 
-	EFX_SET_DWORD_FIELD(reg, XX_RSTPLLAB_EN, 0);
-	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	EFX_SET_OWORD_FIELD(reg, XX_RSTPLLAB_EN, 0);
+	falcon_write(efx, &reg, XX_PWR_RST_REG);
 	udelay(10);
 
-	EFX_SET_DWORD_FIELD(reg, XX_RESETA_EN, 0);
-	EFX_SET_DWORD_FIELD(reg, XX_RESETB_EN, 0);
-	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	EFX_SET_OWORD_FIELD(reg, XX_RESETA_EN, 0);
+	EFX_SET_OWORD_FIELD(reg, XX_RESETB_EN, 0);
+	falcon_write(efx, &reg, XX_PWR_RST_REG);
 	udelay(10);
 
 	/* Channels C and D: power down, reset PLL, reset, clear */
-	EFX_SET_DWORD_FIELD(reg, XX_PWRDNC_EN, 0);
-	EFX_SET_DWORD_FIELD(reg, XX_PWRDND_EN, 0);
-	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	EFX_SET_OWORD_FIELD(reg, XX_PWRDNC_EN, 0);
+	EFX_SET_OWORD_FIELD(reg, XX_PWRDND_EN, 0);
+	falcon_write(efx, &reg, XX_PWR_RST_REG);
 	udelay(10);
 
-	EFX_SET_DWORD_FIELD(reg, XX_RSTPLLCD_EN, 0);
-	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	EFX_SET_OWORD_FIELD(reg, XX_RSTPLLCD_EN, 0);
+	falcon_write(efx, &reg, XX_PWR_RST_REG);
 	udelay(10);
 
-	EFX_SET_DWORD_FIELD(reg, XX_RESETC_EN, 0);
-	EFX_SET_DWORD_FIELD(reg, XX_RESETD_EN, 0);
-	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	EFX_SET_OWORD_FIELD(reg, XX_RESETC_EN, 0);
+	EFX_SET_OWORD_FIELD(reg, XX_RESETD_EN, 0);
+	falcon_write(efx, &reg, XX_PWR_RST_REG);
 	udelay(10);
 
 	/* Setup XAUI */
@@ -171,8 +143,8 @@ static int _falcon_reset_xaui_a(struct efx_nic *efx)
 	udelay(10);
 
 	/* Take XGXS out of reset */
-	EFX_ZERO_DWORD(reg);
-	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	EFX_ZERO_OWORD(reg);
+	falcon_write(efx, &reg, XX_PWR_RST_REG);
 	udelay(10);
 
 	return 0;
@@ -180,16 +152,16 @@ static int _falcon_reset_xaui_a(struct efx_nic *efx)
 
 static int _falcon_reset_xaui_b(struct efx_nic *efx)
 {
-	efx_dword_t reg;
+	efx_oword_t reg;
 	int count;
 
 	EFX_POPULATE_DWORD_1(reg, XX_RST_XX_EN, 1);
-	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	falcon_write(efx, &reg, XX_PWR_RST_REG);
 
 	/* Give some time for the link to establish */
 	for (count = 0; count < 1000; count++) { /* wait upto 10ms */
-		falcon_xmac_readl(efx, &reg, XX_PWR_RST_REG_MAC);
-		if (EFX_DWORD_FIELD(reg, XX_RST_XX_EN) == 0) {
+		falcon_read(efx, &reg, XX_PWR_RST_REG);
+		if (EFX_OWORD_FIELD(reg, XX_RST_XX_EN) == 0) {
 			falcon_setup_xaui(efx);
 			return 0;
 		}
@@ -215,17 +187,17 @@ int falcon_reset_xaui(struct efx_nic *efx)
 
 static bool falcon_xgmii_status(struct efx_nic *efx)
 {
-	efx_dword_t reg;
+	efx_oword_t reg;
 
 	if (falcon_rev(efx) < FALCON_REV_B0)
 		return true;
 
 	/* The ISR latches, so clear it and re-read */
-	falcon_xmac_readl(efx, &reg, XM_MGT_INT_REG_MAC_B0);
-	falcon_xmac_readl(efx, &reg, XM_MGT_INT_REG_MAC_B0);
+	falcon_read(efx, &reg, XM_MGT_INT_REG_B0);
+	falcon_read(efx, &reg, XM_MGT_INT_REG_B0);
 
-	if (EFX_DWORD_FIELD(reg, XM_LCLFLT) ||
-	    EFX_DWORD_FIELD(reg, XM_RMTFLT)) {
+	if (EFX_OWORD_FIELD(reg, XM_LCLFLT) ||
+	    EFX_OWORD_FIELD(reg, XM_RMTFLT)) {
 		EFX_INFO(efx, "MGT_INT: "EFX_DWORD_FMT"\n", EFX_DWORD_VAL(reg));
 		return false;
 	}
@@ -235,19 +207,19 @@ static bool falcon_xgmii_status(struct efx_nic *efx)
 
 static void falcon_mask_status_intr(struct efx_nic *efx, bool enable)
 {
-	efx_dword_t reg;
+	efx_oword_t reg;
 
 	if ((falcon_rev(efx) < FALCON_REV_B0) || LOOPBACK_INTERNAL(efx))
 		return;
 
 	/* Flush the ISR */
 	if (enable)
-		falcon_xmac_readl(efx, &reg, XM_MGT_INT_REG_MAC_B0);
+		falcon_read(efx, &reg, XM_MGT_INT_REG_B0);
 
-	EFX_POPULATE_DWORD_2(reg,
+	EFX_POPULATE_OWORD_2(reg,
 			     XM_MSK_RMTFLT, !enable,
 			     XM_MSK_LCLFLT, !enable);
-	falcon_xmac_writel(efx, &reg, XM_MGT_INT_MSK_REG_MAC_B0);
+	falcon_write(efx, &reg, XM_MGT_INT_MSK_REG_B0);
 }
 
 int falcon_init_xmac(struct efx_nic *efx)
@@ -281,7 +253,7 @@ int falcon_init_xmac(struct efx_nic *efx)
 
 bool falcon_xaui_link_ok(struct efx_nic *efx)
 {
-	efx_dword_t reg;
+	efx_oword_t reg;
 	bool align_done, link_ok = false;
 	int sync_status;
 
@@ -289,18 +261,18 @@ bool falcon_xaui_link_ok(struct efx_nic *efx)
 		return true;
 
 	/* Read link status */
-	falcon_xmac_readl(efx, &reg, XX_CORE_STAT_REG_MAC);
+	falcon_read(efx, &reg, XX_CORE_STAT_REG);
 
-	align_done = EFX_DWORD_FIELD(reg, XX_ALIGN_DONE);
-	sync_status = EFX_DWORD_FIELD(reg, XX_SYNC_STAT);
+	align_done = EFX_OWORD_FIELD(reg, XX_ALIGN_DONE);
+	sync_status = EFX_OWORD_FIELD(reg, XX_SYNC_STAT);
 	if (align_done && (sync_status == XX_SYNC_STAT_DECODE_SYNCED))
 		link_ok = true;
 
 	/* Clear link status ready for next read */
-	EFX_SET_DWORD_FIELD(reg, XX_COMMA_DET, XX_COMMA_DET_RESET);
-	EFX_SET_DWORD_FIELD(reg, XX_CHARERR, XX_CHARERR_RESET);
-	EFX_SET_DWORD_FIELD(reg, XX_DISPERR, XX_DISPERR_RESET);
-	falcon_xmac_writel(efx, &reg, XX_CORE_STAT_REG_MAC);
+	EFX_SET_OWORD_FIELD(reg, XX_COMMA_DET, XX_COMMA_DET_RESET);
+	EFX_SET_OWORD_FIELD(reg, XX_CHARERR, XX_CHARERR_RESET);
+	EFX_SET_OWORD_FIELD(reg, XX_DISPERR, XX_DISPERR_RESET);
+	falcon_write(efx, &reg, XX_CORE_STAT_REG);
 
 	/* If the link is up, then check the phy side of the xaui link
 	 * (error conditions from the wire side propoagate back through
@@ -321,7 +293,7 @@ bool falcon_xaui_link_ok(struct efx_nic *efx)
 static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 {
 	unsigned int max_frame_len;
-	efx_dword_t reg;
+	efx_oword_t reg;
 	bool rx_fc = !!(efx->flow_control & EFX_FC_RX);
 
 	/* Configure MAC  - cut-thru mode is hard wired on */
@@ -329,7 +301,7 @@ static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 			     XM_RX_JUMBO_MODE, 1,
 			     XM_TX_STAT_EN, 1,
 			     XM_RX_STAT_EN, 1);
-	falcon_xmac_writel(efx, &reg, XM_GLB_CFG_REG_MAC);
+	falcon_write(efx, &reg, XM_GLB_CFG_REG);
 
 	/* Configure TX */
 	EFX_POPULATE_DWORD_6(reg,
@@ -339,7 +311,7 @@ static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 			     XM_TXCRC, 1,
 			     XM_FCNTL, 1,
 			     XM_IPG, 0x3);
-	falcon_xmac_writel(efx, &reg, XM_TX_CFG_REG_MAC);
+	falcon_write(efx, &reg, XM_TX_CFG_REG);
 
 	/* Configure RX */
 	EFX_POPULATE_DWORD_5(reg,
@@ -348,21 +320,21 @@ static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 			     XM_ACPT_ALL_MCAST, 1,
 			     XM_ACPT_ALL_UCAST, efx->promiscuous,
 			     XM_PASS_CRC_ERR, 1);
-	falcon_xmac_writel(efx, &reg, XM_RX_CFG_REG_MAC);
+	falcon_write(efx, &reg, XM_RX_CFG_REG);
 
 	/* Set frame length */
 	max_frame_len = EFX_MAX_FRAME_LEN(efx->net_dev->mtu);
 	EFX_POPULATE_DWORD_1(reg, XM_MAX_RX_FRM_SIZE, max_frame_len);
-	falcon_xmac_writel(efx, &reg, XM_RX_PARAM_REG_MAC);
+	falcon_write(efx, &reg, XM_RX_PARAM_REG);
 	EFX_POPULATE_DWORD_2(reg,
 			     XM_MAX_TX_FRM_SIZE, max_frame_len,
 			     XM_TX_JUMBO_MODE, 1);
-	falcon_xmac_writel(efx, &reg, XM_TX_PARAM_REG_MAC);
+	falcon_write(efx, &reg, XM_TX_PARAM_REG);
 
 	EFX_POPULATE_DWORD_2(reg,
 			     XM_PAUSE_TIME, 0xfffe, /* MAX PAUSE TIME */
 			     XM_DIS_FCNTL, !rx_fc);
-	falcon_xmac_writel(efx, &reg, XM_FC_REG_MAC);
+	falcon_write(efx, &reg, XM_FC_REG);
 
 	/* Set MAC address */
 	EFX_POPULATE_DWORD_4(reg,
@@ -370,16 +342,16 @@ static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 			     XM_ADR_1, efx->net_dev->dev_addr[1],
 			     XM_ADR_2, efx->net_dev->dev_addr[2],
 			     XM_ADR_3, efx->net_dev->dev_addr[3]);
-	falcon_xmac_writel(efx, &reg, XM_ADR_LO_REG_MAC);
+	falcon_write(efx, &reg, XM_ADR_LO_REG);
 	EFX_POPULATE_DWORD_2(reg,
 			     XM_ADR_4, efx->net_dev->dev_addr[4],
 			     XM_ADR_5, efx->net_dev->dev_addr[5]);
-	falcon_xmac_writel(efx, &reg, XM_ADR_HI_REG_MAC);
+	falcon_write(efx, &reg, XM_ADR_HI_REG);
 }
 
 static void falcon_reconfigure_xgxs_core(struct efx_nic *efx)
 {
-	efx_dword_t reg;
+	efx_oword_t reg;
 	bool xgxs_loopback = (efx->loopback_mode == LOOPBACK_XGXS);
 	bool xaui_loopback = (efx->loopback_mode == LOOPBACK_XAUI);
 	bool xgmii_loopback = (efx->loopback_mode == LOOPBACK_XGMII);
@@ -390,44 +362,44 @@ static void falcon_reconfigure_xgxs_core(struct efx_nic *efx)
 		bool old_xgmii_loopback, old_xgxs_loopback, old_xaui_loopback;
 		bool reset_xgxs;
 
-		falcon_xmac_readl(efx, &reg, XX_CORE_STAT_REG_MAC);
-		old_xgxs_loopback = EFX_DWORD_FIELD(reg, XX_XGXS_LB_EN);
-		old_xgmii_loopback = EFX_DWORD_FIELD(reg, XX_XGMII_LB_EN);
+		falcon_read(efx, &reg, XX_CORE_STAT_REG);
+		old_xgxs_loopback = EFX_OWORD_FIELD(reg, XX_XGXS_LB_EN);
+		old_xgmii_loopback = EFX_OWORD_FIELD(reg, XX_XGMII_LB_EN);
 
-		falcon_xmac_readl(efx, &reg, XX_SD_CTL_REG_MAC);
-		old_xaui_loopback = EFX_DWORD_FIELD(reg, XX_LPBKA);
+		falcon_read(efx, &reg, XX_SD_CTL_REG);
+		old_xaui_loopback = EFX_OWORD_FIELD(reg, XX_LPBKA);
 
 		/* The PHY driver may have turned XAUI off */
 		reset_xgxs = ((xgxs_loopback != old_xgxs_loopback) ||
 			      (xaui_loopback != old_xaui_loopback) ||
 			      (xgmii_loopback != old_xgmii_loopback));
 		if (reset_xgxs) {
-			falcon_xmac_readl(efx, &reg, XX_PWR_RST_REG_MAC);
-			EFX_SET_DWORD_FIELD(reg, XX_RSTXGXSTX_EN, 1);
-			EFX_SET_DWORD_FIELD(reg, XX_RSTXGXSRX_EN, 1);
-			falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+			falcon_read(efx, &reg, XX_PWR_RST_REG);
+			EFX_SET_OWORD_FIELD(reg, XX_RSTXGXSTX_EN, 1);
+			EFX_SET_OWORD_FIELD(reg, XX_RSTXGXSRX_EN, 1);
+			falcon_write(efx, &reg, XX_PWR_RST_REG);
 			udelay(1);
-			EFX_SET_DWORD_FIELD(reg, XX_RSTXGXSTX_EN, 0);
-			EFX_SET_DWORD_FIELD(reg, XX_RSTXGXSRX_EN, 0);
-			falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+			EFX_SET_OWORD_FIELD(reg, XX_RSTXGXSTX_EN, 0);
+			EFX_SET_OWORD_FIELD(reg, XX_RSTXGXSRX_EN, 0);
+			falcon_write(efx, &reg, XX_PWR_RST_REG);
 			udelay(1);
 		}
 	}
 
-	falcon_xmac_readl(efx, &reg, XX_CORE_STAT_REG_MAC);
-	EFX_SET_DWORD_FIELD(reg, XX_FORCE_SIG,
+	falcon_read(efx, &reg, XX_CORE_STAT_REG);
+	EFX_SET_OWORD_FIELD(reg, XX_FORCE_SIG,
 			    (xgxs_loopback || xaui_loopback) ?
 			    XX_FORCE_SIG_DECODE_FORCED : 0);
-	EFX_SET_DWORD_FIELD(reg, XX_XGXS_LB_EN, xgxs_loopback);
-	EFX_SET_DWORD_FIELD(reg, XX_XGMII_LB_EN, xgmii_loopback);
-	falcon_xmac_writel(efx, &reg, XX_CORE_STAT_REG_MAC);
-
-	falcon_xmac_readl(efx, &reg, XX_SD_CTL_REG_MAC);
-	EFX_SET_DWORD_FIELD(reg, XX_LPBKD, xaui_loopback);
-	EFX_SET_DWORD_FIELD(reg, XX_LPBKC, xaui_loopback);
-	EFX_SET_DWORD_FIELD(reg, XX_LPBKB, xaui_loopback);
-	EFX_SET_DWORD_FIELD(reg, XX_LPBKA, xaui_loopback);
-	falcon_xmac_writel(efx, &reg, XX_SD_CTL_REG_MAC);
+	EFX_SET_OWORD_FIELD(reg, XX_XGXS_LB_EN, xgxs_loopback);
+	EFX_SET_OWORD_FIELD(reg, XX_XGMII_LB_EN, xgmii_loopback);
+	falcon_write(efx, &reg, XX_CORE_STAT_REG);
+
+	falcon_read(efx, &reg, XX_SD_CTL_REG);
+	EFX_SET_OWORD_FIELD(reg, XX_LPBKD, xaui_loopback);
+	EFX_SET_OWORD_FIELD(reg, XX_LPBKC, xaui_loopback);
+	EFX_SET_OWORD_FIELD(reg, XX_LPBKB, xaui_loopback);
+	EFX_SET_OWORD_FIELD(reg, XX_LPBKA, xaui_loopback);
+	falcon_write(efx, &reg, XX_SD_CTL_REG);
 }
 
 
diff --git a/drivers/net/sfc/mac.h b/drivers/net/sfc/mac.h
index edd07d4..a31571c 100644
--- a/drivers/net/sfc/mac.h
+++ b/drivers/net/sfc/mac.h
@@ -13,10 +13,6 @@
 
 #include "net_driver.h"
 
-extern void falcon_xmac_writel(struct efx_nic *efx,
-			       efx_dword_t *value, unsigned int mac_reg);
-extern void falcon_xmac_readl(struct efx_nic *efx,
-			      efx_dword_t *value, unsigned int mac_reg);
 extern int falcon_init_xmac(struct efx_nic *efx);
 extern void falcon_reconfigure_xmac(struct efx_nic *efx);
 extern void falcon_update_stats_xmac(struct efx_nic *efx);
diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index d90fab5..b7005da 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -19,6 +19,7 @@
 #include "boards.h"
 #include "falcon.h"
 #include "falcon_hwdefs.h"
+#include "falcon_io.h"
 #include "mac.h"
 
 /**************************************************************************
@@ -128,17 +129,17 @@ static int sfe4001_poweron(struct efx_nic *efx)
 	unsigned int i, j;
 	int rc;
 	u8 out;
-	efx_dword_t reg;
+	efx_oword_t reg;
 
 	/* Ensure that XGXS and XAUI SerDes are held in reset */
-	EFX_POPULATE_DWORD_7(reg, XX_PWRDNA_EN, 1,
+	EFX_POPULATE_OWORD_7(reg, XX_PWRDNA_EN, 1,
 			     XX_PWRDNB_EN, 1,
 			     XX_RSTPLLAB_EN, 1,
 			     XX_RESETA_EN, 1,
 			     XX_RESETB_EN, 1,
 			     XX_RSTXGXSRX_EN, 1,
 			     XX_RSTXGXSTX_EN, 1);
-	falcon_xmac_writel(efx, &reg, XX_PWR_RST_REG_MAC);
+	falcon_write(efx, &reg, XX_PWR_RST_REG);
 	udelay(10);
 
 	/* Clear any previous over-temperature alert */
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

