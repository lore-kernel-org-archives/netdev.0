From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 12/31] staging: r8188eu: Remove macro ODM_SetBBReg
Date: Sun, 22 Dec 2013 17:36:43 -0600
Message-ID: <1387755422-11443-13-git-send-email-Larry.Finger@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

It is essentially a duplicate of macro PHY_SetBBReg

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c     | 176 +++++++++----------
 drivers/staging/rtl8188eu/hal/odm.c                | 194 +++++++++++----------
 drivers/staging/rtl8188eu/hal/odm_RTL8188E.c       | 136 ++++++++-------
 drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c |   8 +-
 drivers/staging/rtl8188eu/hal/odm_interface.c      |   6 -
 drivers/staging/rtl8188eu/include/odm_interface.h  |   3 -
 6 files changed, 266 insertions(+), 257 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
index a317c9e..1422118 100644
--- a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
+++ b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
@@ -428,17 +428,17 @@ odm_TXPowerTrackingCallback_ThermalMeter_8188E(
 
 						/* wtite new elements A, C, D to regC88 and regC9C, element B is always 0 */
 						value32 = (ele_D<<22) | ((ele_C&0x3F)<<16) | ele_A;
-						ODM_SetBBReg(dm_odm, rOFDM0_XBTxIQImbalance, bMaskDWord, value32);
+						PHY_SetBBReg(Adapter, rOFDM0_XBTxIQImbalance, bMaskDWord, value32);
 
 						value32 = (ele_C&0x000003C0)>>6;
-						ODM_SetBBReg(dm_odm, rOFDM0_XDTxAFE, bMaskH4Bits, value32);
+						PHY_SetBBReg(Adapter, rOFDM0_XDTxAFE, bMaskH4Bits, value32);
 
 						value32 = ((X * ele_D)>>7)&0x01;
-						ODM_SetBBReg(dm_odm, rOFDM0_ECCAThreshold, BIT28, value32);
+						PHY_SetBBReg(Adapter, rOFDM0_ECCAThreshold, BIT28, value32);
 					} else {
-						ODM_SetBBReg(dm_odm, rOFDM0_XBTxIQImbalance, bMaskDWord, OFDMSwingTable[(u8)OFDM_index[1]]);
-						ODM_SetBBReg(dm_odm, rOFDM0_XDTxAFE, bMaskH4Bits, 0x00);
-						ODM_SetBBReg(dm_odm, rOFDM0_ECCAThreshold, BIT28, 0x00);
+						PHY_SetBBReg(Adapter, rOFDM0_XBTxIQImbalance, bMaskDWord, OFDMSwingTable[(u8)OFDM_index[1]]);
+						PHY_SetBBReg(Adapter, rOFDM0_XDTxAFE, bMaskH4Bits, 0x00);
+						PHY_SetBBReg(Adapter, rOFDM0_ECCAThreshold, BIT28, 0x00);
 					}
 
 					ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
@@ -485,19 +485,19 @@ phy_PathA_IQK_8188E(struct adapter *adapt, bool configPathB)
 	/* 1 Tx IQK */
 	/* path-A IQK setting */
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("Path-A IQK setting!\n"));
-	ODM_SetBBReg(dm_odm, rTx_IQK_Tone_A, bMaskDWord, 0x10008c1c);
-	ODM_SetBBReg(dm_odm, rRx_IQK_Tone_A, bMaskDWord, 0x30008c1c);
-	ODM_SetBBReg(dm_odm, rTx_IQK_PI_A, bMaskDWord, 0x8214032a);
-	ODM_SetBBReg(dm_odm, rRx_IQK_PI_A, bMaskDWord, 0x28160000);
+	PHY_SetBBReg(adapt, rTx_IQK_Tone_A, bMaskDWord, 0x10008c1c);
+	PHY_SetBBReg(adapt, rRx_IQK_Tone_A, bMaskDWord, 0x30008c1c);
+	PHY_SetBBReg(adapt, rTx_IQK_PI_A, bMaskDWord, 0x8214032a);
+	PHY_SetBBReg(adapt, rRx_IQK_PI_A, bMaskDWord, 0x28160000);
 
 	/* LO calibration setting */
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("LO calibration setting!\n"));
-	ODM_SetBBReg(dm_odm, rIQK_AGC_Rsp, bMaskDWord, 0x00462911);
+	PHY_SetBBReg(adapt, rIQK_AGC_Rsp, bMaskDWord, 0x00462911);
 
 	/* One shot, path A LOK & IQK */
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("One shot, path A LOK & IQK!\n"));
-	ODM_SetBBReg(dm_odm, rIQK_AGC_Pts, bMaskDWord, 0xf9000000);
-	ODM_SetBBReg(dm_odm, rIQK_AGC_Pts, bMaskDWord, 0xf8000000);
+	PHY_SetBBReg(adapt, rIQK_AGC_Pts, bMaskDWord, 0xf9000000);
+	PHY_SetBBReg(adapt, rIQK_AGC_Pts, bMaskDWord, 0xf8000000);
 
 	/*  delay x ms */
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("Delay %d ms for One shot, path A LOK & IQK.\n", IQK_DELAY_TIME_88E));
@@ -533,7 +533,7 @@ phy_PathA_RxIQK(struct adapter *adapt, bool configPathB)
 	/* 1 Get TXIMR setting */
 	/* modify RXIQK mode table */
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("Path-A Rx IQK modify RXIQK mode table!\n"));
-	ODM_SetBBReg(dm_odm, rFPGA0_IQK, bMaskDWord, 0x00000000);
+	PHY_SetBBReg(adapt, rFPGA0_IQK, bMaskDWord, 0x00000000);
 	ODM_SetRFReg(dm_odm, RF_PATH_A, RF_WE_LUT, bRFRegOffsetMask, 0x800a0);
 	ODM_SetRFReg(dm_odm, RF_PATH_A, RF_RCK_OS, bRFRegOffsetMask, 0x30000);
 	ODM_SetRFReg(dm_odm, RF_PATH_A, RF_TXPA_G1, bRFRegOffsetMask, 0x0000f);
@@ -543,26 +543,26 @@ phy_PathA_RxIQK(struct adapter *adapt, bool configPathB)
 	ODM_SetRFReg(dm_odm, RF_PATH_A, 0xdf, bRFRegOffsetMask, 0x980);
 	ODM_SetRFReg(dm_odm, RF_PATH_A, 0x56, bRFRegOffsetMask, 0x51000);
 
-	ODM_SetBBReg(dm_odm, rFPGA0_IQK, bMaskDWord, 0x80800000);
+	PHY_SetBBReg(adapt, rFPGA0_IQK, bMaskDWord, 0x80800000);
 
 	/* IQK setting */
-	ODM_SetBBReg(dm_odm, rTx_IQK, bMaskDWord, 0x01007c00);
-	ODM_SetBBReg(dm_odm, rRx_IQK, bMaskDWord, 0x81004800);
+	PHY_SetBBReg(adapt, rTx_IQK, bMaskDWord, 0x01007c00);
+	PHY_SetBBReg(adapt, rRx_IQK, bMaskDWord, 0x81004800);
 
 	/* path-A IQK setting */
-	ODM_SetBBReg(dm_odm, rTx_IQK_Tone_A, bMaskDWord, 0x10008c1c);
-	ODM_SetBBReg(dm_odm, rRx_IQK_Tone_A, bMaskDWord, 0x30008c1c);
-	ODM_SetBBReg(dm_odm, rTx_IQK_PI_A, bMaskDWord, 0x82160c1f);
-	ODM_SetBBReg(dm_odm, rRx_IQK_PI_A, bMaskDWord, 0x28160000);
+	PHY_SetBBReg(adapt, rTx_IQK_Tone_A, bMaskDWord, 0x10008c1c);
+	PHY_SetBBReg(adapt, rRx_IQK_Tone_A, bMaskDWord, 0x30008c1c);
+	PHY_SetBBReg(adapt, rTx_IQK_PI_A, bMaskDWord, 0x82160c1f);
+	PHY_SetBBReg(adapt, rRx_IQK_PI_A, bMaskDWord, 0x28160000);
 
 	/* LO calibration setting */
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("LO calibration setting!\n"));
-	ODM_SetBBReg(dm_odm, rIQK_AGC_Rsp, bMaskDWord, 0x0046a911);
+	PHY_SetBBReg(adapt, rIQK_AGC_Rsp, bMaskDWord, 0x0046a911);
 
 	/* One shot, path A LOK & IQK */
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("One shot, path A LOK & IQK!\n"));
-	ODM_SetBBReg(dm_odm, rIQK_AGC_Pts, bMaskDWord, 0xf9000000);
-	ODM_SetBBReg(dm_odm, rIQK_AGC_Pts, bMaskDWord, 0xf8000000);
+	PHY_SetBBReg(adapt, rIQK_AGC_Pts, bMaskDWord, 0xf9000000);
+	PHY_SetBBReg(adapt, rIQK_AGC_Pts, bMaskDWord, 0xf8000000);
 
 	/*  delay x ms */
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
@@ -589,36 +589,36 @@ phy_PathA_RxIQK(struct adapter *adapt, bool configPathB)
 		return result;
 
 	u4tmp = 0x80007C00 | (regE94&0x3FF0000)  | ((regE9C&0x3FF0000) >> 16);
-	ODM_SetBBReg(dm_odm, rTx_IQK, bMaskDWord, u4tmp);
+	PHY_SetBBReg(adapt, rTx_IQK, bMaskDWord, u4tmp);
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("0xe40 = 0x%x u4tmp = 0x%x\n", ODM_GetBBReg(dm_odm, rTx_IQK, bMaskDWord), u4tmp));
 
 	/* 1 RX IQK */
 	/* modify RXIQK mode table */
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("Path-A Rx IQK modify RXIQK mode table 2!\n"));
-	ODM_SetBBReg(dm_odm, rFPGA0_IQK, bMaskDWord, 0x00000000);
+	PHY_SetBBReg(adapt, rFPGA0_IQK, bMaskDWord, 0x00000000);
 	ODM_SetRFReg(dm_odm, RF_PATH_A, RF_WE_LUT, bRFRegOffsetMask, 0x800a0);
 	ODM_SetRFReg(dm_odm, RF_PATH_A, RF_RCK_OS, bRFRegOffsetMask, 0x30000);
 	ODM_SetRFReg(dm_odm, RF_PATH_A, RF_TXPA_G1, bRFRegOffsetMask, 0x0000f);
 	ODM_SetRFReg(dm_odm, RF_PATH_A, RF_TXPA_G2, bRFRegOffsetMask, 0xf7ffa);
-	ODM_SetBBReg(dm_odm, rFPGA0_IQK, bMaskDWord, 0x80800000);
+	PHY_SetBBReg(adapt, rFPGA0_IQK, bMaskDWord, 0x80800000);
 
 	/* IQK setting */
-	ODM_SetBBReg(dm_odm, rRx_IQK, bMaskDWord, 0x01004800);
+	PHY_SetBBReg(adapt, rRx_IQK, bMaskDWord, 0x01004800);
 
 	/* path-A IQK setting */
-	ODM_SetBBReg(dm_odm, rTx_IQK_Tone_A, bMaskDWord, 0x38008c1c);
-	ODM_SetBBReg(dm_odm, rRx_IQK_Tone_A, bMaskDWord, 0x18008c1c);
-	ODM_SetBBReg(dm_odm, rTx_IQK_PI_A, bMaskDWord, 0x82160c05);
-	ODM_SetBBReg(dm_odm, rRx_IQK_PI_A, bMaskDWord, 0x28160c1f);
+	PHY_SetBBReg(adapt, rTx_IQK_Tone_A, bMaskDWord, 0x38008c1c);
+	PHY_SetBBReg(adapt, rRx_IQK_Tone_A, bMaskDWord, 0x18008c1c);
+	PHY_SetBBReg(adapt, rTx_IQK_PI_A, bMaskDWord, 0x82160c05);
+	PHY_SetBBReg(adapt, rRx_IQK_PI_A, bMaskDWord, 0x28160c1f);
 
 	/* LO calibration setting */
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("LO calibration setting!\n"));
-	ODM_SetBBReg(dm_odm, rIQK_AGC_Rsp, bMaskDWord, 0x0046a911);
+	PHY_SetBBReg(adapt, rIQK_AGC_Rsp, bMaskDWord, 0x0046a911);
 
 	/* One shot, path A LOK & IQK */
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("One shot, path A LOK & IQK!\n"));
-	ODM_SetBBReg(dm_odm, rIQK_AGC_Pts, bMaskDWord, 0xf9000000);
-	ODM_SetBBReg(dm_odm, rIQK_AGC_Pts, bMaskDWord, 0xf8000000);
+	PHY_SetBBReg(adapt, rIQK_AGC_Pts, bMaskDWord, 0xf9000000);
+	PHY_SetBBReg(adapt, rIQK_AGC_Pts, bMaskDWord, 0xf8000000);
 
 	/*  delay x ms */
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("Delay %d ms for One shot, path A LOK & IQK.\n", IQK_DELAY_TIME_88E));
@@ -636,7 +636,7 @@ phy_PathA_RxIQK(struct adapter *adapt, bool configPathB)
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,  ("0xea4 = 0x%x\n", regEA4));
 
 	/* reload RF 0xdf */
-	ODM_SetBBReg(dm_odm, rFPGA0_IQK, bMaskDWord, 0x00000000);
+	PHY_SetBBReg(adapt, rFPGA0_IQK, bMaskDWord, 0x00000000);
 	ODM_SetRFReg(dm_odm, RF_PATH_A, 0xdf, bRFRegOffsetMask, 0x180);
 
 	if (!(regeac & BIT27) &&		/* if Tx is OK, check whether Rx is OK */
@@ -660,8 +660,8 @@ phy_PathB_IQK_8188E(struct adapter *adapt)
 
 	/* One shot, path B LOK & IQK */
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("One shot, path A LOK & IQK!\n"));
-	ODM_SetBBReg(dm_odm, rIQK_AGC_Cont, bMaskDWord, 0x00000002);
-	ODM_SetBBReg(dm_odm, rIQK_AGC_Cont, bMaskDWord, 0x00000000);
+	PHY_SetBBReg(adapt, rIQK_AGC_Cont, bMaskDWord, 0x00000002);
+	PHY_SetBBReg(adapt, rIQK_AGC_Cont, bMaskDWord, 0x00000000);
 
 	/*  delay x ms */
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
@@ -724,9 +724,9 @@ static void patha_fill_iqk(struct adapter *adapt, bool iqkok, s32 result[][8], u
 		ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
 			     ("X = 0x%x, TX0_A = 0x%x, Oldval_0 0x%x\n",
 			     X, TX0_A, Oldval_0));
-		ODM_SetBBReg(dm_odm, rOFDM0_XATxIQImbalance, 0x3FF, TX0_A);
+		PHY_SetBBReg(adapt, rOFDM0_XATxIQImbalance, 0x3FF, TX0_A);
 
-		ODM_SetBBReg(dm_odm, rOFDM0_ECCAThreshold, BIT(31), ((X * Oldval_0>>7) & 0x1));
+		PHY_SetBBReg(adapt, rOFDM0_ECCAThreshold, BIT(31), ((X * Oldval_0>>7) & 0x1));
 
 		Y = result[final_candidate][1];
 		if ((Y & 0x00000200) != 0)
@@ -734,10 +734,10 @@ static void patha_fill_iqk(struct adapter *adapt, bool iqkok, s32 result[][8], u
 
 		TX0_C = (Y * Oldval_0) >> 8;
 		ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,  ("Y = 0x%x, TX = 0x%x\n", Y, TX0_C));
-		ODM_SetBBReg(dm_odm, rOFDM0_XCTxAFE, 0xF0000000, ((TX0_C&0x3C0)>>6));
-		ODM_SetBBReg(dm_odm, rOFDM0_XATxIQImbalance, 0x003F0000, (TX0_C&0x3F));
+		PHY_SetBBReg(adapt, rOFDM0_XCTxAFE, 0xF0000000, ((TX0_C&0x3C0)>>6));
+		PHY_SetBBReg(adapt, rOFDM0_XATxIQImbalance, 0x003F0000, (TX0_C&0x3F));
 
-		ODM_SetBBReg(dm_odm, rOFDM0_ECCAThreshold, BIT(29), ((Y * Oldval_0>>7) & 0x1));
+		PHY_SetBBReg(adapt, rOFDM0_ECCAThreshold, BIT(29), ((Y * Oldval_0>>7) & 0x1));
 
 		if (txonly) {
 			ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,  ("patha_fill_iqk only Tx OK\n"));
@@ -745,13 +745,13 @@ static void patha_fill_iqk(struct adapter *adapt, bool iqkok, s32 result[][8], u
 		}
 
 		reg = result[final_candidate][2];
-		ODM_SetBBReg(dm_odm, rOFDM0_XARxIQImbalance, 0x3FF, reg);
+		PHY_SetBBReg(adapt, rOFDM0_XARxIQImbalance, 0x3FF, reg);
 
 		reg = result[final_candidate][3] & 0x3F;
-		ODM_SetBBReg(dm_odm, rOFDM0_XARxIQImbalance, 0xFC00, reg);
+		PHY_SetBBReg(adapt, rOFDM0_XARxIQImbalance, 0xFC00, reg);
 
 		reg = (result[final_candidate][3] >> 6) & 0xF;
-		ODM_SetBBReg(dm_odm, rOFDM0_RxIQExtAnta, 0xF0000000, reg);
+		PHY_SetBBReg(adapt, rOFDM0_RxIQExtAnta, 0xF0000000, reg);
 	}
 }
 
@@ -775,9 +775,9 @@ static void pathb_fill_iqk(struct adapter *adapt, bool iqkok, s32 result[][8], u
 			X = X | 0xFFFFFC00;
 		TX1_A = (X * Oldval_1) >> 8;
 		ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("X = 0x%x, TX1_A = 0x%x\n", X, TX1_A));
-		ODM_SetBBReg(dm_odm, rOFDM0_XBTxIQImbalance, 0x3FF, TX1_A);
+		PHY_SetBBReg(adapt, rOFDM0_XBTxIQImbalance, 0x3FF, TX1_A);
 
-		ODM_SetBBReg(dm_odm, rOFDM0_ECCAThreshold, BIT(27), ((X * Oldval_1>>7) & 0x1));
+		PHY_SetBBReg(adapt, rOFDM0_ECCAThreshold, BIT(27), ((X * Oldval_1>>7) & 0x1));
 
 		Y = result[final_candidate][5];
 		if ((Y & 0x00000200) != 0)
@@ -785,22 +785,22 @@ static void pathb_fill_iqk(struct adapter *adapt, bool iqkok, s32 result[][8], u
 
 		TX1_C = (Y * Oldval_1) >> 8;
 		ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,  ("Y = 0x%x, TX1_C = 0x%x\n", Y, TX1_C));
-		ODM_SetBBReg(dm_odm, rOFDM0_XDTxAFE, 0xF0000000, ((TX1_C&0x3C0)>>6));
-		ODM_SetBBReg(dm_odm, rOFDM0_XBTxIQImbalance, 0x003F0000, (TX1_C&0x3F));
+		PHY_SetBBReg(adapt, rOFDM0_XDTxAFE, 0xF0000000, ((TX1_C&0x3C0)>>6));
+		PHY_SetBBReg(adapt, rOFDM0_XBTxIQImbalance, 0x003F0000, (TX1_C&0x3F));
 
-		ODM_SetBBReg(dm_odm, rOFDM0_ECCAThreshold, BIT(25), ((Y * Oldval_1>>7) & 0x1));
+		PHY_SetBBReg(adapt, rOFDM0_ECCAThreshold, BIT(25), ((Y * Oldval_1>>7) & 0x1));
 
 		if (txonly)
 			return;
 
 		reg = result[final_candidate][6];
-		ODM_SetBBReg(dm_odm, rOFDM0_XBRxIQImbalance, 0x3FF, reg);
+		PHY_SetBBReg(adapt, rOFDM0_XBRxIQImbalance, 0x3FF, reg);
 
 		reg = result[final_candidate][7] & 0x3F;
-		ODM_SetBBReg(dm_odm, rOFDM0_XBRxIQImbalance, 0xFC00, reg);
+		PHY_SetBBReg(adapt, rOFDM0_XBRxIQImbalance, 0xFC00, reg);
 
 		reg = (result[final_candidate][7] >> 6) & 0xF;
-		ODM_SetBBReg(dm_odm, rOFDM0_AGCRSSITable, 0x0000F000, reg);
+		PHY_SetBBReg(adapt, rOFDM0_AGCRSSITable, 0x0000F000, reg);
 	}
 }
 
@@ -852,7 +852,7 @@ static void reload_adda_reg(struct adapter *adapt, u32 *ADDAReg, u32 *ADDABackup
 
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("Reload ADDA power saving parameters !\n"));
 	for (i = 0; i < RegiesterNum; i++)
-		ODM_SetBBReg(dm_odm, ADDAReg[i], bMaskDWord, ADDABackup[i]);
+		PHY_SetBBReg(adapt, ADDAReg[i], bMaskDWord, ADDABackup[i]);
 }
 
 static void
@@ -890,13 +890,13 @@ _PHY_PathADDAOn(
 	pathOn = isPathAOn ? 0x04db25a4 : 0x0b1b25a4;
 	if (!is2t) {
 		pathOn = 0x0bdb25a0;
-		ODM_SetBBReg(dm_odm, ADDAReg[0], bMaskDWord, 0x0b1b25a0);
+		PHY_SetBBReg(adapt, ADDAReg[0], bMaskDWord, 0x0b1b25a0);
 	} else {
-		ODM_SetBBReg(dm_odm, ADDAReg[0], bMaskDWord, pathOn);
+		PHY_SetBBReg(adapt, ADDAReg[0], bMaskDWord, pathOn);
 	}
 
 	for (i = 1; i < IQK_ADDA_REG_NUM; i++)
-		ODM_SetBBReg(dm_odm, ADDAReg[i], bMaskDWord, pathOn);
+		PHY_SetBBReg(adapt, ADDAReg[i], bMaskDWord, pathOn);
 }
 
 void
@@ -930,9 +930,9 @@ _PHY_PathAStandBy(
 
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,  ("Path-A standby mode!\n"));
 
-	ODM_SetBBReg(dm_odm, rFPGA0_IQK, bMaskDWord, 0x0);
-	ODM_SetBBReg(dm_odm, 0x840, bMaskDWord, 0x00010000);
-	ODM_SetBBReg(dm_odm, rFPGA0_IQK, bMaskDWord, 0x80800000);
+	PHY_SetBBReg(adapt, rFPGA0_IQK, bMaskDWord, 0x0);
+	PHY_SetBBReg(adapt, 0x840, bMaskDWord, 0x00010000);
+	PHY_SetBBReg(adapt, rFPGA0_IQK, bMaskDWord, 0x80800000);
 }
 
 static void _PHY_PIModeSwitch(
@@ -947,8 +947,8 @@ static void _PHY_PIModeSwitch(
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("BB Switch to %s mode!\n", (PIMode ? "PI" : "SI")));
 
 	mode = PIMode ? 0x01000100 : 0x01000000;
-	ODM_SetBBReg(dm_odm, rFPGA0_XA_HSSIParameter1, bMaskDWord, mode);
-	ODM_SetBBReg(dm_odm, rFPGA0_XB_HSSIParameter1, bMaskDWord, mode);
+	PHY_SetBBReg(adapt, rFPGA0_XA_HSSIParameter1, bMaskDWord, mode);
+	PHY_SetBBReg(adapt, rFPGA0_XB_HSSIParameter1, bMaskDWord, mode);
 }
 
 static bool phy_SimularityCompare_8188E(
@@ -1105,19 +1105,19 @@ static void phy_IQCalibrate_8188E(struct adapter *adapt, s32 result[][8], u8 t,
 	}
 
 	/* BB setting */
-	ODM_SetBBReg(dm_odm, rFPGA0_RFMOD, BIT24, 0x00);
-	ODM_SetBBReg(dm_odm, rOFDM0_TRxPathEnable, bMaskDWord, 0x03a05600);
-	ODM_SetBBReg(dm_odm, rOFDM0_TRMuxPar, bMaskDWord, 0x000800e4);
-	ODM_SetBBReg(dm_odm, rFPGA0_XCD_RFInterfaceSW, bMaskDWord, 0x22204000);
+	PHY_SetBBReg(adapt, rFPGA0_RFMOD, BIT24, 0x00);
+	PHY_SetBBReg(adapt, rOFDM0_TRxPathEnable, bMaskDWord, 0x03a05600);
+	PHY_SetBBReg(adapt, rOFDM0_TRMuxPar, bMaskDWord, 0x000800e4);
+	PHY_SetBBReg(adapt, rFPGA0_XCD_RFInterfaceSW, bMaskDWord, 0x22204000);
 
-	ODM_SetBBReg(dm_odm, rFPGA0_XAB_RFInterfaceSW, BIT10, 0x01);
-	ODM_SetBBReg(dm_odm, rFPGA0_XAB_RFInterfaceSW, BIT26, 0x01);
-	ODM_SetBBReg(dm_odm, rFPGA0_XA_RFInterfaceOE, BIT10, 0x00);
-	ODM_SetBBReg(dm_odm, rFPGA0_XB_RFInterfaceOE, BIT10, 0x00);
+	PHY_SetBBReg(adapt, rFPGA0_XAB_RFInterfaceSW, BIT10, 0x01);
+	PHY_SetBBReg(adapt, rFPGA0_XAB_RFInterfaceSW, BIT26, 0x01);
+	PHY_SetBBReg(adapt, rFPGA0_XA_RFInterfaceOE, BIT10, 0x00);
+	PHY_SetBBReg(adapt, rFPGA0_XB_RFInterfaceOE, BIT10, 0x00);
 
 	if (is2t) {
-		ODM_SetBBReg(dm_odm, rFPGA0_XA_LSSIParameter, bMaskDWord, 0x00010000);
-		ODM_SetBBReg(dm_odm, rFPGA0_XB_LSSIParameter, bMaskDWord, 0x00010000);
+		PHY_SetBBReg(adapt, rFPGA0_XA_LSSIParameter, bMaskDWord, 0x00010000);
+		PHY_SetBBReg(adapt, rFPGA0_XB_LSSIParameter, bMaskDWord, 0x00010000);
 	}
 
 	/* MAC settings */
@@ -1125,16 +1125,16 @@ static void phy_IQCalibrate_8188E(struct adapter *adapt, s32 result[][8], u8 t,
 
 	/* Page B init */
 	/* AP or IQK */
-	ODM_SetBBReg(dm_odm, rConfig_AntA, bMaskDWord, 0x0f600000);
+	PHY_SetBBReg(adapt, rConfig_AntA, bMaskDWord, 0x0f600000);
 
 	if (is2t)
-		ODM_SetBBReg(dm_odm, rConfig_AntB, bMaskDWord, 0x0f600000);
+		PHY_SetBBReg(adapt, rConfig_AntB, bMaskDWord, 0x0f600000);
 
 	/*  IQ calibration setting */
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("IQK setting!\n"));
-	ODM_SetBBReg(dm_odm, rFPGA0_IQK, bMaskDWord, 0x80800000);
-	ODM_SetBBReg(dm_odm, rTx_IQK, bMaskDWord, 0x01007c00);
-	ODM_SetBBReg(dm_odm, rRx_IQK, bMaskDWord, 0x81004800);
+	PHY_SetBBReg(adapt, rFPGA0_IQK, bMaskDWord, 0x80800000);
+	PHY_SetBBReg(adapt, rTx_IQK, bMaskDWord, 0x01007c00);
+	PHY_SetBBReg(adapt, rRx_IQK, bMaskDWord, 0x81004800);
 
 	for (i = 0; i < retryCount; i++) {
 		PathAOK = phy_PathA_IQK_8188E(adapt, is2t);
@@ -1191,7 +1191,7 @@ static void phy_IQCalibrate_8188E(struct adapter *adapt, s32 result[][8], u8 t,
 
 	/* Back to BB mode, load original value */
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("IQK:Back to BB mode, load original value!\n"));
-	ODM_SetBBReg(dm_odm, rFPGA0_IQK, bMaskDWord, 0);
+	PHY_SetBBReg(adapt, rFPGA0_IQK, bMaskDWord, 0);
 
 	if (t != 0) {
 		if (!dm_odm->RFCalibrateInfo.bRfPiEnable) {
@@ -1208,13 +1208,13 @@ static void phy_IQCalibrate_8188E(struct adapter *adapt, s32 result[][8], u8 t,
 		reload_adda_reg(adapt, IQK_BB_REG_92C, dm_odm->RFCalibrateInfo.IQK_BB_backup, IQK_BB_REG_NUM);
 
 		/*  Restore RX initial gain */
-		ODM_SetBBReg(dm_odm, rFPGA0_XA_LSSIParameter, bMaskDWord, 0x00032ed3);
+		PHY_SetBBReg(adapt, rFPGA0_XA_LSSIParameter, bMaskDWord, 0x00032ed3);
 		if (is2t)
-			ODM_SetBBReg(dm_odm, rFPGA0_XB_LSSIParameter, bMaskDWord, 0x00032ed3);
+			PHY_SetBBReg(adapt, rFPGA0_XB_LSSIParameter, bMaskDWord, 0x00032ed3);
 
 		/* load 0xe30 IQC default value */
-		ODM_SetBBReg(dm_odm, rTx_IQK_Tone_A, bMaskDWord, 0x01008c00);
-		ODM_SetBBReg(dm_odm, rRx_IQK_Tone_A, bMaskDWord, 0x01008c00);
+		PHY_SetBBReg(adapt, rTx_IQK_Tone_A, bMaskDWord, 0x01008c00);
+		PHY_SetBBReg(adapt, rRx_IQK_Tone_A, bMaskDWord, 0x01008c00);
 	}
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("phy_IQCalibrate_8188E() <==\n"));
 }
@@ -1475,19 +1475,19 @@ static void phy_setrfpathswitch_8188e(struct adapter *adapt, bool main, bool is2
 		u8 u1btmp;
 		u1btmp = ODM_Read1Byte(dm_odm, REG_LEDCFG2) | BIT7;
 		ODM_Write1Byte(dm_odm, REG_LEDCFG2, u1btmp);
-		ODM_SetBBReg(dm_odm, rFPGA0_XAB_RFParameter, BIT13, 0x01);
+		PHY_SetBBReg(adapt, rFPGA0_XAB_RFParameter, BIT13, 0x01);
 	}
 
 	if (is2t) {	/* 92C */
 		if (main)
-			ODM_SetBBReg(dm_odm, rFPGA0_XB_RFInterfaceOE, BIT5|BIT6, 0x1);	/* 92C_Path_A */
+			PHY_SetBBReg(adapt, rFPGA0_XB_RFInterfaceOE, BIT5|BIT6, 0x1);	/* 92C_Path_A */
 		else
-			ODM_SetBBReg(dm_odm, rFPGA0_XB_RFInterfaceOE, BIT5|BIT6, 0x2);	/* BT */
+			PHY_SetBBReg(adapt, rFPGA0_XB_RFInterfaceOE, BIT5|BIT6, 0x2);	/* BT */
 	} else {			/* 88C */
 		if (main)
-			ODM_SetBBReg(dm_odm, rFPGA0_XA_RFInterfaceOE, BIT8|BIT9, 0x2);	/* Main */
+			PHY_SetBBReg(adapt, rFPGA0_XA_RFInterfaceOE, BIT8|BIT9, 0x2);	/* Main */
 		else
-			ODM_SetBBReg(dm_odm, rFPGA0_XA_RFInterfaceOE, BIT8|BIT9, 0x1);	/* Aux */
+			PHY_SetBBReg(adapt, rFPGA0_XA_RFInterfaceOE, BIT8|BIT9, 0x1);	/* Aux */
 	}
 }
 
diff --git a/drivers/staging/rtl8188eu/hal/odm.c b/drivers/staging/rtl8188eu/hal/odm.c
index dc4e389..3a45238 100644
--- a/drivers/staging/rtl8188eu/hal/odm.c
+++ b/drivers/staging/rtl8188eu/hal/odm.c
@@ -558,6 +558,7 @@ static int getIGIForDiff(int value_IGI)
 void ODM_Write_DIG(struct odm_dm_struct *pDM_Odm, u8 CurrentIGI)
 {
 	struct rtw_dig *pDM_DigTable = &pDM_Odm->DM_DigTable;
+	struct adapter *adapter = pDM_Odm->Adapter;
 
 	ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD,
 		     ("ODM_REG(IGI_A,pDM_Odm)=0x%x, ODM_BIT(IGI,pDM_Odm)=0x%x\n",
@@ -565,25 +566,25 @@ void ODM_Write_DIG(struct odm_dm_struct *pDM_Odm, u8 CurrentIGI)
 
 	if (pDM_DigTable->CurIGValue != CurrentIGI) {
 		if (pDM_Odm->SupportPlatform & (ODM_CE|ODM_MP)) {
-			ODM_SetBBReg(pDM_Odm, ODM_REG(IGI_A, pDM_Odm), ODM_BIT(IGI, pDM_Odm), CurrentIGI);
+			PHY_SetBBReg(adapter, ODM_REG(IGI_A, pDM_Odm), ODM_BIT(IGI, pDM_Odm), CurrentIGI);
 				if (pDM_Odm->SupportICType != ODM_RTL8188E)
-				ODM_SetBBReg(pDM_Odm, ODM_REG(IGI_B, pDM_Odm), ODM_BIT(IGI, pDM_Odm), CurrentIGI);
+				PHY_SetBBReg(adapter, ODM_REG(IGI_B, pDM_Odm), ODM_BIT(IGI, pDM_Odm), CurrentIGI);
 		} else if (pDM_Odm->SupportPlatform & (ODM_AP|ODM_ADSL)) {
 			switch (*(pDM_Odm->pOnePathCCA)) {
 			case ODM_CCA_2R:
-				ODM_SetBBReg(pDM_Odm, ODM_REG(IGI_A, pDM_Odm), ODM_BIT(IGI, pDM_Odm), CurrentIGI);
+				PHY_SetBBReg(adapter, ODM_REG(IGI_A, pDM_Odm), ODM_BIT(IGI, pDM_Odm), CurrentIGI);
 					if (pDM_Odm->SupportICType != ODM_RTL8188E)
-					ODM_SetBBReg(pDM_Odm, ODM_REG(IGI_B, pDM_Odm), ODM_BIT(IGI, pDM_Odm), CurrentIGI);
+					PHY_SetBBReg(adapter, ODM_REG(IGI_B, pDM_Odm), ODM_BIT(IGI, pDM_Odm), CurrentIGI);
 				break;
 			case ODM_CCA_1R_A:
-				ODM_SetBBReg(pDM_Odm, ODM_REG(IGI_A, pDM_Odm), ODM_BIT(IGI, pDM_Odm), CurrentIGI);
+				PHY_SetBBReg(adapter, ODM_REG(IGI_A, pDM_Odm), ODM_BIT(IGI, pDM_Odm), CurrentIGI);
 					if (pDM_Odm->SupportICType != ODM_RTL8188E)
-					ODM_SetBBReg(pDM_Odm, ODM_REG(IGI_B, pDM_Odm), ODM_BIT(IGI, pDM_Odm), getIGIForDiff(CurrentIGI));
+					PHY_SetBBReg(adapter, ODM_REG(IGI_B, pDM_Odm), ODM_BIT(IGI, pDM_Odm), getIGIForDiff(CurrentIGI));
 				break;
 			case ODM_CCA_1R_B:
-				ODM_SetBBReg(pDM_Odm, ODM_REG(IGI_A, pDM_Odm), ODM_BIT(IGI, pDM_Odm), getIGIForDiff(CurrentIGI));
+				PHY_SetBBReg(adapter, ODM_REG(IGI_A, pDM_Odm), ODM_BIT(IGI, pDM_Odm), getIGIForDiff(CurrentIGI));
 					if (pDM_Odm->SupportICType != ODM_RTL8188E)
-					ODM_SetBBReg(pDM_Odm, ODM_REG(IGI_B, pDM_Odm), ODM_BIT(IGI, pDM_Odm), CurrentIGI);
+					PHY_SetBBReg(adapter, ODM_REG(IGI_B, pDM_Odm), ODM_BIT(IGI, pDM_Odm), CurrentIGI);
 					break;
 				}
 		}
@@ -916,6 +917,7 @@ void odm_DIG(struct odm_dm_struct *pDM_Odm)
 
 void odm_FalseAlarmCounterStatistics(struct odm_dm_struct *pDM_Odm)
 {
+	struct adapter *adapter = pDM_Odm->Adapter;
 	u32 ret_value;
 	struct false_alarm_stats *FalseAlmCnt = &(pDM_Odm->FalseAlmCnt);
 
@@ -924,8 +926,8 @@ void odm_FalseAlarmCounterStatistics(struct odm_dm_struct *pDM_Odm)
 
 	if (pDM_Odm->SupportICType & ODM_IC_11N_SERIES) {
 		/* hold ofdm counter */
-		ODM_SetBBReg(pDM_Odm, ODM_REG_OFDM_FA_HOLDC_11N, BIT31, 1); /* hold page C counter */
-		ODM_SetBBReg(pDM_Odm, ODM_REG_OFDM_FA_RSTD_11N, BIT31, 1); /* hold page D counter */
+		PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_HOLDC_11N, BIT31, 1); /* hold page C counter */
+		PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_RSTD_11N, BIT31, 1); /* hold page D counter */
 
 		ret_value = ODM_GetBBReg(pDM_Odm, ODM_REG_OFDM_FA_TYPE1_11N, bMaskDWord);
 		FalseAlmCnt->Cnt_Fast_Fsync = (ret_value&0xffff);
@@ -950,8 +952,8 @@ void odm_FalseAlarmCounterStatistics(struct odm_dm_struct *pDM_Odm)
 		}
 
 		/* hold cck counter */
-		ODM_SetBBReg(pDM_Odm, ODM_REG_CCK_FA_RST_11N, BIT12, 1);
-		ODM_SetBBReg(pDM_Odm, ODM_REG_CCK_FA_RST_11N, BIT14, 1);
+		PHY_SetBBReg(adapter, ODM_REG_CCK_FA_RST_11N, BIT12, 1);
+		PHY_SetBBReg(adapter, ODM_REG_CCK_FA_RST_11N, BIT14, 1);
 
 		ret_value = ODM_GetBBReg(pDM_Odm, ODM_REG_CCK_FA_LSB_11N, bMaskByte0);
 		FalseAlmCnt->Cnt_Cck_fail = ret_value;
@@ -973,20 +975,20 @@ void odm_FalseAlarmCounterStatistics(struct odm_dm_struct *pDM_Odm)
 
 		if (pDM_Odm->SupportICType >= ODM_RTL8723A) {
 			/* reset false alarm counter registers */
-			ODM_SetBBReg(pDM_Odm, ODM_REG_OFDM_FA_RSTC_11N, BIT31, 1);
-			ODM_SetBBReg(pDM_Odm, ODM_REG_OFDM_FA_RSTC_11N, BIT31, 0);
-			ODM_SetBBReg(pDM_Odm, ODM_REG_OFDM_FA_RSTD_11N, BIT27, 1);
-			ODM_SetBBReg(pDM_Odm, ODM_REG_OFDM_FA_RSTD_11N, BIT27, 0);
+			PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_RSTC_11N, BIT31, 1);
+			PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_RSTC_11N, BIT31, 0);
+			PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_RSTD_11N, BIT27, 1);
+			PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_RSTD_11N, BIT27, 0);
 			/* update ofdm counter */
-			ODM_SetBBReg(pDM_Odm, ODM_REG_OFDM_FA_HOLDC_11N, BIT31, 0); /* update page C counter */
-			ODM_SetBBReg(pDM_Odm, ODM_REG_OFDM_FA_RSTD_11N, BIT31, 0); /* update page D counter */
+			PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_HOLDC_11N, BIT31, 0); /* update page C counter */
+			PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_RSTD_11N, BIT31, 0); /* update page D counter */
 
 			/* reset CCK CCA counter */
-			ODM_SetBBReg(pDM_Odm, ODM_REG_CCK_FA_RST_11N, BIT13|BIT12, 0);
-			ODM_SetBBReg(pDM_Odm, ODM_REG_CCK_FA_RST_11N, BIT13|BIT12, 2);
+			PHY_SetBBReg(adapter, ODM_REG_CCK_FA_RST_11N, BIT13|BIT12, 0);
+			PHY_SetBBReg(adapter, ODM_REG_CCK_FA_RST_11N, BIT13|BIT12, 2);
 			/* reset CCK FA counter */
-			ODM_SetBBReg(pDM_Odm, ODM_REG_CCK_FA_RST_11N, BIT15|BIT14, 0);
-			ODM_SetBBReg(pDM_Odm, ODM_REG_CCK_FA_RST_11N, BIT15|BIT14, 2);
+			PHY_SetBBReg(adapter, ODM_REG_CCK_FA_RST_11N, BIT15|BIT14, 0);
+			PHY_SetBBReg(adapter, ODM_REG_CCK_FA_RST_11N, BIT15|BIT14, 2);
 		}
 
 		ODM_RT_TRACE(pDM_Odm, ODM_COMP_FA_CNT, ODM_DBG_LOUD, ("Enter odm_FalseAlarmCounterStatistics\n"));
@@ -1006,11 +1008,11 @@ void odm_FalseAlarmCounterStatistics(struct odm_dm_struct *pDM_Odm)
 		FalseAlmCnt->Cnt_all = FalseAlmCnt->Cnt_Ofdm_fail + FalseAlmCnt->Cnt_Cck_fail;
 
 		/*  reset OFDM FA coutner */
-		ODM_SetBBReg(pDM_Odm, ODM_REG_OFDM_FA_RST_11AC, BIT17, 1);
-		ODM_SetBBReg(pDM_Odm, ODM_REG_OFDM_FA_RST_11AC, BIT17, 0);
+		PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_RST_11AC, BIT17, 1);
+		PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_RST_11AC, BIT17, 0);
 		/*  reset CCK FA counter */
-		ODM_SetBBReg(pDM_Odm, ODM_REG_CCK_FA_RST_11AC, BIT15, 0);
-		ODM_SetBBReg(pDM_Odm, ODM_REG_CCK_FA_RST_11AC, BIT15, 1);
+		PHY_SetBBReg(adapter, ODM_REG_CCK_FA_RST_11AC, BIT15, 0);
+		PHY_SetBBReg(adapter, ODM_REG_CCK_FA_RST_11AC, BIT15, 1);
 	}
 	ODM_RT_TRACE(pDM_Odm, ODM_COMP_FA_CNT, ODM_DBG_LOUD, ("Cnt_Cck_fail=%d\n", FalseAlmCnt->Cnt_Cck_fail));
 	ODM_RT_TRACE(pDM_Odm, ODM_COMP_FA_CNT, ODM_DBG_LOUD, ("Cnt_Ofdm_fail=%d\n", FalseAlmCnt->Cnt_Ofdm_fail));
@@ -1097,6 +1099,7 @@ void odm_DynamicBBPowerSaving(struct odm_dm_struct *pDM_Odm)
 
 void odm_1R_CCA(struct odm_dm_struct *pDM_Odm)
 {
+	struct adapter *adapter = pDM_Odm->Adapter;
 	struct rtl_ps *pDM_PSTable = &pDM_Odm->DM_PSTable;
 
 	if (pDM_Odm->RSSI_Min != 0xFF) {
@@ -1118,11 +1121,11 @@ void odm_1R_CCA(struct odm_dm_struct *pDM_Odm)
 	if (pDM_PSTable->PreCCAState != pDM_PSTable->CurCCAState) {
 		if (pDM_PSTable->CurCCAState == CCA_1R) {
 			if (pDM_Odm->RFType == ODM_2T2R)
-				ODM_SetBBReg(pDM_Odm, 0xc04, bMaskByte0, 0x13);
+				PHY_SetBBReg(adapter, 0xc04, bMaskByte0, 0x13);
 			else
-				ODM_SetBBReg(pDM_Odm, 0xc04, bMaskByte0, 0x23);
+				PHY_SetBBReg(adapter, 0xc04, bMaskByte0, 0x23);
 		} else {
-			ODM_SetBBReg(pDM_Odm, 0xc04, bMaskByte0, 0x33);
+			PHY_SetBBReg(adapter, 0xc04, bMaskByte0, 0x33);
 		}
 		pDM_PSTable->PreCCAState = pDM_PSTable->CurCCAState;
 	}
@@ -1130,6 +1133,7 @@ void odm_1R_CCA(struct odm_dm_struct *pDM_Odm)
 
 void ODM_RF_Saving(struct odm_dm_struct *pDM_Odm, u8 bForceInNormal)
 {
+	struct adapter *adapter = pDM_Odm->Adapter;
 	struct rtl_ps *pDM_PSTable = &pDM_Odm->DM_PSTable;
 	u8 Rssi_Up_bound = 30;
 	u8 Rssi_Low_bound = 25;
@@ -1171,23 +1175,23 @@ void ODM_RF_Saving(struct odm_dm_struct *pDM_Odm, u8 bForceInNormal)
 			/*  <tynli_note> 8723 RSSI report will be wrong. Set 0x874[5]=1 when enter BB power saving mode. */
 			/*  Suggested by SD3 Yu-Nan. 2011.01.20. */
 			if (pDM_Odm->SupportICType == ODM_RTL8723A)
-				ODM_SetBBReg(pDM_Odm, 0x874  , BIT5, 0x1); /* Reg874[5]=1b'1 */
-			ODM_SetBBReg(pDM_Odm, 0x874  , 0x1C0000, 0x2); /* Reg874[20:18]=3'b010 */
-			ODM_SetBBReg(pDM_Odm, 0xc70, BIT3, 0); /* RegC70[3]=1'b0 */
-			ODM_SetBBReg(pDM_Odm, 0x85c, 0xFF000000, 0x63); /* Reg85C[31:24]=0x63 */
-			ODM_SetBBReg(pDM_Odm, 0x874, 0xC000, 0x2); /* Reg874[15:14]=2'b10 */
-			ODM_SetBBReg(pDM_Odm, 0xa74, 0xF000, 0x3); /* RegA75[7:4]=0x3 */
-			ODM_SetBBReg(pDM_Odm, 0x818, BIT28, 0x0); /* Reg818[28]=1'b0 */
-			ODM_SetBBReg(pDM_Odm, 0x818, BIT28, 0x1); /* Reg818[28]=1'b1 */
+				PHY_SetBBReg(adapter, 0x874  , BIT5, 0x1); /* Reg874[5]=1b'1 */
+			PHY_SetBBReg(adapter, 0x874  , 0x1C0000, 0x2); /* Reg874[20:18]=3'b010 */
+			PHY_SetBBReg(adapter, 0xc70, BIT3, 0); /* RegC70[3]=1'b0 */
+			PHY_SetBBReg(adapter, 0x85c, 0xFF000000, 0x63); /* Reg85C[31:24]=0x63 */
+			PHY_SetBBReg(adapter, 0x874, 0xC000, 0x2); /* Reg874[15:14]=2'b10 */
+			PHY_SetBBReg(adapter, 0xa74, 0xF000, 0x3); /* RegA75[7:4]=0x3 */
+			PHY_SetBBReg(adapter, 0x818, BIT28, 0x0); /* Reg818[28]=1'b0 */
+			PHY_SetBBReg(adapter, 0x818, BIT28, 0x1); /* Reg818[28]=1'b1 */
 		} else {
-			ODM_SetBBReg(pDM_Odm, 0x874  , 0x1CC000, pDM_PSTable->Reg874);
-			ODM_SetBBReg(pDM_Odm, 0xc70, BIT3, pDM_PSTable->RegC70);
-			ODM_SetBBReg(pDM_Odm, 0x85c, 0xFF000000, pDM_PSTable->Reg85C);
-			ODM_SetBBReg(pDM_Odm, 0xa74, 0xF000, pDM_PSTable->RegA74);
-			ODM_SetBBReg(pDM_Odm, 0x818, BIT28, 0x0);
+			PHY_SetBBReg(adapter, 0x874  , 0x1CC000, pDM_PSTable->Reg874);
+			PHY_SetBBReg(adapter, 0xc70, BIT3, pDM_PSTable->RegC70);
+			PHY_SetBBReg(adapter, 0x85c, 0xFF000000, pDM_PSTable->Reg85C);
+			PHY_SetBBReg(adapter, 0xa74, 0xF000, pDM_PSTable->RegA74);
+			PHY_SetBBReg(adapter, 0x818, BIT28, 0x0);
 
 			if (pDM_Odm->SupportICType == ODM_RTL8723A)
-				ODM_SetBBReg(pDM_Odm, 0x874, BIT5, 0x0); /* Reg874[5]=1b'0 */
+				PHY_SetBBReg(adapter, 0x874, BIT5, 0x0); /* Reg874[5]=1b'0 */
 		}
 		pDM_PSTable->PreRFState = pDM_PSTable->CurRFState;
 	}
@@ -1860,16 +1864,17 @@ dm_CheckEdcaTurbo_EXIT:
 
 u32 GetPSDData(struct odm_dm_struct *pDM_Odm, unsigned int point, u8 initial_gain_psd)
 {
+	struct adapter *adapter = pDM_Odm->Adapter;
 	u32 psd_report;
 
 	/* Set DCO frequency index, offset=(40MHz/SamplePts)*point */
-	ODM_SetBBReg(pDM_Odm, 0x808, 0x3FF, point);
+	PHY_SetBBReg(adapter, 0x808, 0x3FF, point);
 
 	/* Start PSD calculation, Reg808[22]=0->1 */
-	ODM_SetBBReg(pDM_Odm, 0x808, BIT22, 1);
+	PHY_SetBBReg(adapter, 0x808, BIT22, 1);
 	/* Need to wait for HW PSD report */
 	udelay(30);
-	ODM_SetBBReg(pDM_Odm, 0x808, BIT22, 0);
+	PHY_SetBBReg(adapter, 0x808, BIT22, 0);
 	/* Read PSD report, Reg8B4[15:0] */
 	psd_report = ODM_GetBBReg(pDM_Odm, 0x8B4, bMaskDWord) & 0x0000FFFF;
 
@@ -1924,6 +1929,7 @@ void ODM_SingleDualAntennaDefaultSetting(struct odm_dm_struct *pDM_Odm)
 
 static void odm_PHY_SaveAFERegisters(struct odm_dm_struct *pDM_Odm, u32 *AFEReg, u32 *AFEBackup, u32 RegisterNum)
 {
+	struct adapter *adapter = pDM_Odm->Adapter;
 	u32 i;
 
 	/* RTPRINT(FINIT, INIT_IQK, ("Save ADDA parameters.\n")); */
@@ -1933,10 +1939,11 @@ static void odm_PHY_SaveAFERegisters(struct odm_dm_struct *pDM_Odm, u32 *AFEReg,
 
 static void odm_PHY_ReloadAFERegisters(struct odm_dm_struct *pDM_Odm, u32 *AFEReg, u32 *AFEBackup, u32 RegiesterNum)
 {
+	struct adapter *adapter = pDM_Odm->Adapter;
 	u32 i;
 
 	for (i = 0; i < RegiesterNum; i++)
-		ODM_SetBBReg(pDM_Odm, AFEReg[i], bMaskDWord, AFEBackup[i]);
+		PHY_SetBBReg(adapter, AFEReg[i], bMaskDWord, AFEBackup[i]);
 }
 
 /* 2 8723A ANT DETECT */
@@ -1945,6 +1952,7 @@ static void odm_PHY_ReloadAFERegisters(struct odm_dm_struct *pDM_Odm, u32 *AFERe
 /* 	This function is cooperated with BB team Neil. */
 bool ODM_SingleDualAntennaDetection(struct odm_dm_struct *pDM_Odm, u8 mode)
 {
+	struct adapter *adapter = pDM_Odm->Adapter;
 	struct sw_ant_switch *pDM_SWAT_Table = &pDM_Odm->DM_SWAT_Table;
 	u32 CurrentChannel, RfLoopReg;
 	u8 n;
@@ -1972,18 +1980,18 @@ bool ODM_SingleDualAntennaDetection(struct odm_dm_struct *pDM_Odm, u8 mode)
 
 	if (pDM_Odm->SupportICType == ODM_RTL8192C) {
 		/* Which path in ADC/DAC is turnned on for PSD: both I/Q */
-		ODM_SetBBReg(pDM_Odm, 0x808, BIT10|BIT11, 0x3);
+		PHY_SetBBReg(adapter, 0x808, BIT10|BIT11, 0x3);
 		/* Ageraged number: 8 */
-		ODM_SetBBReg(pDM_Odm, 0x808, BIT12|BIT13, 0x1);
+		PHY_SetBBReg(adapter, 0x808, BIT12|BIT13, 0x1);
 		/* pts = 128; */
-		ODM_SetBBReg(pDM_Odm, 0x808, BIT14|BIT15, 0x0);
+		PHY_SetBBReg(adapter, 0x808, BIT14|BIT15, 0x0);
 	}
 
 	/* 1 Backup Current RF/BB Settings */
 
 	CurrentChannel = ODM_GetRFReg(pDM_Odm, RF_PATH_A, ODM_CHANNEL, bRFRegOffsetMask);
 	RfLoopReg = ODM_GetRFReg(pDM_Odm, RF_PATH_A, 0x00, bRFRegOffsetMask);
-	ODM_SetBBReg(pDM_Odm, rFPGA0_XA_RFInterfaceOE, ODM_DPDT, Antenna_A);  /*  change to Antenna A */
+	PHY_SetBBReg(adapter, rFPGA0_XA_RFInterfaceOE, ODM_DPDT, Antenna_A);  /*  change to Antenna A */
 	/*  Step 1: USE IQK to transmitter single tone */
 
 	udelay(10);
@@ -1998,56 +2006,56 @@ bool ODM_SingleDualAntennaDetection(struct odm_dm_struct *pDM_Odm, u8 mode)
 	odm_PHY_SaveAFERegisters(pDM_Odm, AFE_REG_8723A, AFE_Backup, 16);
 
 	/* Set PSD 128 pts */
-	ODM_SetBBReg(pDM_Odm, rFPGA0_PSDFunction, BIT14|BIT15, 0x0);  /* 128 pts */
+	PHY_SetBBReg(adapter, rFPGA0_PSDFunction, BIT14|BIT15, 0x0);  /* 128 pts */
 
 	/*  To SET CH1 to do */
 	ODM_SetRFReg(pDM_Odm, RF_PATH_A, ODM_CHANNEL, bRFRegOffsetMask, 0x01);     /* Channel 1 */
 
 	/*  AFE all on step */
-	ODM_SetBBReg(pDM_Odm, rRx_Wait_CCA, bMaskDWord, 0x6FDB25A4);
-	ODM_SetBBReg(pDM_Odm, rTx_CCK_RFON, bMaskDWord, 0x6FDB25A4);
-	ODM_SetBBReg(pDM_Odm, rTx_CCK_BBON, bMaskDWord, 0x6FDB25A4);
-	ODM_SetBBReg(pDM_Odm, rTx_OFDM_RFON, bMaskDWord, 0x6FDB25A4);
-	ODM_SetBBReg(pDM_Odm, rTx_OFDM_BBON, bMaskDWord, 0x6FDB25A4);
-	ODM_SetBBReg(pDM_Odm, rTx_To_Rx, bMaskDWord, 0x6FDB25A4);
-	ODM_SetBBReg(pDM_Odm, rTx_To_Tx, bMaskDWord, 0x6FDB25A4);
-	ODM_SetBBReg(pDM_Odm, rRx_CCK, bMaskDWord, 0x6FDB25A4);
-	ODM_SetBBReg(pDM_Odm, rRx_OFDM, bMaskDWord, 0x6FDB25A4);
-	ODM_SetBBReg(pDM_Odm, rRx_Wait_RIFS, bMaskDWord, 0x6FDB25A4);
-	ODM_SetBBReg(pDM_Odm, rRx_TO_Rx, bMaskDWord, 0x6FDB25A4);
-	ODM_SetBBReg(pDM_Odm, rStandby, bMaskDWord, 0x6FDB25A4);
-	ODM_SetBBReg(pDM_Odm, rSleep, bMaskDWord, 0x6FDB25A4);
-	ODM_SetBBReg(pDM_Odm, rPMPD_ANAEN, bMaskDWord, 0x6FDB25A4);
-	ODM_SetBBReg(pDM_Odm, rFPGA0_XCD_SwitchControl, bMaskDWord, 0x6FDB25A4);
-	ODM_SetBBReg(pDM_Odm, rBlue_Tooth, bMaskDWord, 0x6FDB25A4);
+	PHY_SetBBReg(adapter, rRx_Wait_CCA, bMaskDWord, 0x6FDB25A4);
+	PHY_SetBBReg(adapter, rTx_CCK_RFON, bMaskDWord, 0x6FDB25A4);
+	PHY_SetBBReg(adapter, rTx_CCK_BBON, bMaskDWord, 0x6FDB25A4);
+	PHY_SetBBReg(adapter, rTx_OFDM_RFON, bMaskDWord, 0x6FDB25A4);
+	PHY_SetBBReg(adapter, rTx_OFDM_BBON, bMaskDWord, 0x6FDB25A4);
+	PHY_SetBBReg(adapter, rTx_To_Rx, bMaskDWord, 0x6FDB25A4);
+	PHY_SetBBReg(adapter, rTx_To_Tx, bMaskDWord, 0x6FDB25A4);
+	PHY_SetBBReg(adapter, rRx_CCK, bMaskDWord, 0x6FDB25A4);
+	PHY_SetBBReg(adapter, rRx_OFDM, bMaskDWord, 0x6FDB25A4);
+	PHY_SetBBReg(adapter, rRx_Wait_RIFS, bMaskDWord, 0x6FDB25A4);
+	PHY_SetBBReg(adapter, rRx_TO_Rx, bMaskDWord, 0x6FDB25A4);
+	PHY_SetBBReg(adapter, rStandby, bMaskDWord, 0x6FDB25A4);
+	PHY_SetBBReg(adapter, rSleep, bMaskDWord, 0x6FDB25A4);
+	PHY_SetBBReg(adapter, rPMPD_ANAEN, bMaskDWord, 0x6FDB25A4);
+	PHY_SetBBReg(adapter, rFPGA0_XCD_SwitchControl, bMaskDWord, 0x6FDB25A4);
+	PHY_SetBBReg(adapter, rBlue_Tooth, bMaskDWord, 0x6FDB25A4);
 
 	/*  3 wire Disable */
-	ODM_SetBBReg(pDM_Odm, rFPGA0_AnalogParameter4, bMaskDWord, 0xCCF000C0);
+	PHY_SetBBReg(adapter, rFPGA0_AnalogParameter4, bMaskDWord, 0xCCF000C0);
 
 	/* BB IQK Setting */
-	ODM_SetBBReg(pDM_Odm, rOFDM0_TRMuxPar, bMaskDWord, 0x000800E4);
-	ODM_SetBBReg(pDM_Odm, rFPGA0_XCD_RFInterfaceSW, bMaskDWord, 0x22208000);
+	PHY_SetBBReg(adapter, rOFDM0_TRMuxPar, bMaskDWord, 0x000800E4);
+	PHY_SetBBReg(adapter, rFPGA0_XCD_RFInterfaceSW, bMaskDWord, 0x22208000);
 
 	/* IQK setting tone@ 4.34Mhz */
-	ODM_SetBBReg(pDM_Odm, rTx_IQK_Tone_A, bMaskDWord, 0x10008C1C);
-	ODM_SetBBReg(pDM_Odm, rTx_IQK, bMaskDWord, 0x01007c00);
+	PHY_SetBBReg(adapter, rTx_IQK_Tone_A, bMaskDWord, 0x10008C1C);
+	PHY_SetBBReg(adapter, rTx_IQK, bMaskDWord, 0x01007c00);
 
 
 	/* Page B init */
-	ODM_SetBBReg(pDM_Odm, rConfig_AntA, bMaskDWord, 0x00080000);
-	ODM_SetBBReg(pDM_Odm, rConfig_AntA, bMaskDWord, 0x0f600000);
-	ODM_SetBBReg(pDM_Odm, rRx_IQK, bMaskDWord, 0x01004800);
-	ODM_SetBBReg(pDM_Odm, rRx_IQK_Tone_A, bMaskDWord, 0x10008c1f);
-	ODM_SetBBReg(pDM_Odm, rTx_IQK_PI_A, bMaskDWord, 0x82150008);
-	ODM_SetBBReg(pDM_Odm, rRx_IQK_PI_A, bMaskDWord, 0x28150008);
-	ODM_SetBBReg(pDM_Odm, rIQK_AGC_Rsp, bMaskDWord, 0x001028d0);
+	PHY_SetBBReg(adapter, rConfig_AntA, bMaskDWord, 0x00080000);
+	PHY_SetBBReg(adapter, rConfig_AntA, bMaskDWord, 0x0f600000);
+	PHY_SetBBReg(adapter, rRx_IQK, bMaskDWord, 0x01004800);
+	PHY_SetBBReg(adapter, rRx_IQK_Tone_A, bMaskDWord, 0x10008c1f);
+	PHY_SetBBReg(adapter, rTx_IQK_PI_A, bMaskDWord, 0x82150008);
+	PHY_SetBBReg(adapter, rRx_IQK_PI_A, bMaskDWord, 0x28150008);
+	PHY_SetBBReg(adapter, rIQK_AGC_Rsp, bMaskDWord, 0x001028d0);
 
 	/* RF loop Setting */
 	ODM_SetRFReg(pDM_Odm, RF_PATH_A, 0x0, 0xFFFFF, 0x50008);
 
 	/* IQK Single tone start */
-	ODM_SetBBReg(pDM_Odm, rFPGA0_IQK, bMaskDWord, 0x80800000);
-	ODM_SetBBReg(pDM_Odm, rIQK_AGC_Pts, bMaskDWord, 0xf8000000);
+	PHY_SetBBReg(adapter, rFPGA0_IQK, bMaskDWord, 0x80800000);
+	PHY_SetBBReg(adapter, rIQK_AGC_Pts, bMaskDWord, 0xf8000000);
 	udelay(1000);
 	PSD_report_tmp = 0x0;
 
@@ -2059,7 +2067,7 @@ bool ODM_SingleDualAntennaDetection(struct odm_dm_struct *pDM_Odm, u8 mode)
 
 	PSD_report_tmp = 0x0;
 
-	ODM_SetBBReg(pDM_Odm, rFPGA0_XA_RFInterfaceOE, 0x300, Antenna_B);  /*  change to Antenna B */
+	PHY_SetBBReg(adapter, rFPGA0_XA_RFInterfaceOE, 0x300, Antenna_B);  /*  change to Antenna B */
 	udelay(10);
 
 
@@ -2070,7 +2078,7 @@ bool ODM_SingleDualAntennaDetection(struct odm_dm_struct *pDM_Odm, u8 mode)
 	}
 
 	/*  change to open case */
-	ODM_SetBBReg(pDM_Odm, rFPGA0_XA_RFInterfaceOE, 0x300, 0);  /*  change to Ant A and B all open case */
+	PHY_SetBBReg(adapter, rFPGA0_XA_RFInterfaceOE, 0x300, 0);  /*  change to Ant A and B all open case */
 	udelay(10);
 
 	for (n = 0; n < 2; n++) {
@@ -2080,16 +2088,16 @@ bool ODM_SingleDualAntennaDetection(struct odm_dm_struct *pDM_Odm, u8 mode)
 	}
 
 	/* Close IQK Single Tone function */
-	ODM_SetBBReg(pDM_Odm, rFPGA0_IQK, bMaskDWord, 0x00000000);
+	PHY_SetBBReg(adapter, rFPGA0_IQK, bMaskDWord, 0x00000000);
 	PSD_report_tmp = 0x0;
 
 	/* 1 Return to antanna A */
-	ODM_SetBBReg(pDM_Odm, rFPGA0_XA_RFInterfaceOE, 0x300, Antenna_A);
-	ODM_SetBBReg(pDM_Odm, rFPGA0_AnalogParameter4, bMaskDWord, Reg88c);
-	ODM_SetBBReg(pDM_Odm, rOFDM0_TRMuxPar, bMaskDWord, Regc08);
-	ODM_SetBBReg(pDM_Odm, rFPGA0_XCD_RFInterfaceSW, bMaskDWord, Reg874);
-	ODM_SetBBReg(pDM_Odm, rOFDM0_XAAGCCore1, 0x7F, 0x40);
-	ODM_SetBBReg(pDM_Odm, rOFDM0_XAAGCCore1, bMaskDWord, Regc50);
+	PHY_SetBBReg(adapter, rFPGA0_XA_RFInterfaceOE, 0x300, Antenna_A);
+	PHY_SetBBReg(adapter, rFPGA0_AnalogParameter4, bMaskDWord, Reg88c);
+	PHY_SetBBReg(adapter, rOFDM0_TRMuxPar, bMaskDWord, Regc08);
+	PHY_SetBBReg(adapter, rFPGA0_XCD_RFInterfaceSW, bMaskDWord, Reg874);
+	PHY_SetBBReg(adapter, rOFDM0_XAAGCCore1, 0x7F, 0x40);
+	PHY_SetBBReg(adapter, rOFDM0_XAAGCCore1, bMaskDWord, Regc50);
 	ODM_SetRFReg(pDM_Odm, RF_PATH_A, RF_CHNLBW, bRFRegOffsetMask, CurrentChannel);
 	ODM_SetRFReg(pDM_Odm, RF_PATH_A, 0x00, bRFRegOffsetMask, RfLoopReg);
 
@@ -2142,12 +2150,12 @@ bool ODM_SingleDualAntennaDetection(struct odm_dm_struct *pDM_Odm, u8 mode)
 			if (AntB_report > (AntA_report+2)) {
 				pDM_SWAT_Table->ANTA_ON = false;
 				pDM_SWAT_Table->ANTB_ON = true;
-				ODM_SetBBReg(pDM_Odm,  rFPGA0_XA_RFInterfaceOE, 0x300, Antenna_B);
+				PHY_SetBBReg(adapter,  rFPGA0_XA_RFInterfaceOE, 0x300, Antenna_B);
 				ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("ODM_SingleDualAntennaDetection(): Single Antenna B\n"));
 			} else if (AntA_report > (AntB_report+2)) {
 				pDM_SWAT_Table->ANTA_ON = true;
 				pDM_SWAT_Table->ANTB_ON = false;
-				ODM_SetBBReg(pDM_Odm,  rFPGA0_XA_RFInterfaceOE, 0x300, Antenna_A);
+				PHY_SetBBReg(adapter,  rFPGA0_XA_RFInterfaceOE, 0x300, Antenna_A);
 				ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("ODM_SingleDualAntennaDetection(): Single Antenna A\n"));
 			} else {
 				pDM_SWAT_Table->ANTA_ON = true;
diff --git a/drivers/staging/rtl8188eu/hal/odm_RTL8188E.c b/drivers/staging/rtl8188eu/hal/odm_RTL8188E.c
index 58410f3..29c4780 100644
--- a/drivers/staging/rtl8188eu/hal/odm_RTL8188E.c
+++ b/drivers/staging/rtl8188eu/hal/odm_RTL8188E.c
@@ -34,12 +34,13 @@ void ODM_DIG_LowerBound_88E(struct odm_dm_struct *dm_odm)
 
 static void odm_RX_HWAntDivInit(struct odm_dm_struct *dm_odm)
 {
+	struct adapter *adapter = dm_odm->Adapter;
 	u32	value32;
 
 	if (*(dm_odm->mp_mode) == 1) {
 		dm_odm->AntDivType = CGCS_RX_SW_ANTDIV;
-		ODM_SetBBReg(dm_odm, ODM_REG_IGI_A_11N, BIT7, 0); /*  disable HW AntDiv */
-		ODM_SetBBReg(dm_odm, ODM_REG_LNA_SWITCH_11N, BIT31, 1);  /*  1:CG, 0:CS */
+		PHY_SetBBReg(adapter, ODM_REG_IGI_A_11N, BIT7, 0); /*  disable HW AntDiv */
+		PHY_SetBBReg(adapter, ODM_REG_LNA_SWITCH_11N, BIT31, 1);  /*  1:CG, 0:CS */
 		return;
 	}
 	ODM_RT_TRACE(dm_odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("odm_RX_HWAntDivInit()\n"));
@@ -48,27 +49,28 @@ static void odm_RX_HWAntDivInit(struct odm_dm_struct *dm_odm)
 	value32 = ODM_GetMACReg(dm_odm, ODM_REG_ANTSEL_PIN_11N, bMaskDWord);
 	ODM_SetMACReg(dm_odm, ODM_REG_ANTSEL_PIN_11N, bMaskDWord, value32|(BIT23|BIT25)); /* Reg4C[25]=1, Reg4C[23]=1 for pin output */
 	/* Pin Settings */
-	ODM_SetBBReg(dm_odm, ODM_REG_PIN_CTRL_11N, BIT9|BIT8, 0);/* Reg870[8]=1'b0, Reg870[9]=1'b0	antsel antselb by HW */
-	ODM_SetBBReg(dm_odm, ODM_REG_RX_ANT_CTRL_11N, BIT10, 0);	/* Reg864[10]=1'b0	antsel2 by HW */
-	ODM_SetBBReg(dm_odm, ODM_REG_LNA_SWITCH_11N, BIT22, 1);	/* Regb2c[22]=1'b0	disable CS/CG switch */
-	ODM_SetBBReg(dm_odm, ODM_REG_LNA_SWITCH_11N, BIT31, 1);	/* Regb2c[31]=1'b1	output at CG only */
+	PHY_SetBBReg(adapter, ODM_REG_PIN_CTRL_11N, BIT9|BIT8, 0);/* Reg870[8]=1'b0, Reg870[9]=1'b0	antsel antselb by HW */
+	PHY_SetBBReg(adapter, ODM_REG_RX_ANT_CTRL_11N, BIT10, 0);	/* Reg864[10]=1'b0	antsel2 by HW */
+	PHY_SetBBReg(adapter, ODM_REG_LNA_SWITCH_11N, BIT22, 1);	/* Regb2c[22]=1'b0	disable CS/CG switch */
+	PHY_SetBBReg(adapter, ODM_REG_LNA_SWITCH_11N, BIT31, 1);	/* Regb2c[31]=1'b1	output at CG only */
 	/* OFDM Settings */
-	ODM_SetBBReg(dm_odm, ODM_REG_ANTDIV_PARA1_11N, bMaskDWord, 0x000000a0);
+	PHY_SetBBReg(adapter, ODM_REG_ANTDIV_PARA1_11N, bMaskDWord, 0x000000a0);
 	/* CCK Settings */
-	ODM_SetBBReg(dm_odm, ODM_REG_BB_PWR_SAV4_11N, BIT7, 1); /* Fix CCK PHY status report issue */
-	ODM_SetBBReg(dm_odm, ODM_REG_CCK_ANTDIV_PARA2_11N, BIT4, 1); /* CCK complete HW AntDiv within 64 samples */
+	PHY_SetBBReg(adapter, ODM_REG_BB_PWR_SAV4_11N, BIT7, 1); /* Fix CCK PHY status report issue */
+	PHY_SetBBReg(adapter, ODM_REG_CCK_ANTDIV_PARA2_11N, BIT4, 1); /* CCK complete HW AntDiv within 64 samples */
 	ODM_UpdateRxIdleAnt_88E(dm_odm, MAIN_ANT);
-	ODM_SetBBReg(dm_odm, ODM_REG_ANT_MAPPING1_11N, 0xFFFF, 0x0201);	/* antenna mapping table */
+	PHY_SetBBReg(adapter, ODM_REG_ANT_MAPPING1_11N, 0xFFFF, 0x0201);	/* antenna mapping table */
 }
 
 static void odm_TRX_HWAntDivInit(struct odm_dm_struct *dm_odm)
 {
+	struct adapter *adapter = dm_odm->Adapter;
 	u32	value32;
 
 	if (*(dm_odm->mp_mode) == 1) {
 		dm_odm->AntDivType = CGCS_RX_SW_ANTDIV;
-		ODM_SetBBReg(dm_odm, ODM_REG_IGI_A_11N, BIT7, 0); /*  disable HW AntDiv */
-		ODM_SetBBReg(dm_odm, ODM_REG_RX_ANT_CTRL_11N, BIT5|BIT4|BIT3, 0); /* Default RX   (0/1) */
+		PHY_SetBBReg(adapter, ODM_REG_IGI_A_11N, BIT7, 0); /*  disable HW AntDiv */
+		PHY_SetBBReg(adapter, ODM_REG_RX_ANT_CTRL_11N, BIT5|BIT4|BIT3, 0); /* Default RX   (0/1) */
 		return;
 	}
 	ODM_RT_TRACE(dm_odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("odm_TRX_HWAntDivInit()\n"));
@@ -77,30 +79,31 @@ static void odm_TRX_HWAntDivInit(struct odm_dm_struct *dm_odm)
 	value32 = ODM_GetMACReg(dm_odm, ODM_REG_ANTSEL_PIN_11N, bMaskDWord);
 	ODM_SetMACReg(dm_odm, ODM_REG_ANTSEL_PIN_11N, bMaskDWord, value32|(BIT23|BIT25)); /* Reg4C[25]=1, Reg4C[23]=1 for pin output */
 	/* Pin Settings */
-	ODM_SetBBReg(dm_odm, ODM_REG_PIN_CTRL_11N, BIT9|BIT8, 0);/* Reg870[8]=1'b0, Reg870[9]=1'b0		antsel antselb by HW */
-	ODM_SetBBReg(dm_odm, ODM_REG_RX_ANT_CTRL_11N, BIT10, 0);	/* Reg864[10]=1'b0	antsel2 by HW */
-	ODM_SetBBReg(dm_odm, ODM_REG_LNA_SWITCH_11N, BIT22, 0);	/* Regb2c[22]=1'b0	disable CS/CG switch */
-	ODM_SetBBReg(dm_odm, ODM_REG_LNA_SWITCH_11N, BIT31, 1);	/* Regb2c[31]=1'b1	output at CG only */
+	PHY_SetBBReg(adapter, ODM_REG_PIN_CTRL_11N, BIT9|BIT8, 0);/* Reg870[8]=1'b0, Reg870[9]=1'b0		antsel antselb by HW */
+	PHY_SetBBReg(adapter, ODM_REG_RX_ANT_CTRL_11N, BIT10, 0);	/* Reg864[10]=1'b0	antsel2 by HW */
+	PHY_SetBBReg(adapter, ODM_REG_LNA_SWITCH_11N, BIT22, 0);	/* Regb2c[22]=1'b0	disable CS/CG switch */
+	PHY_SetBBReg(adapter, ODM_REG_LNA_SWITCH_11N, BIT31, 1);	/* Regb2c[31]=1'b1	output at CG only */
 	/* OFDM Settings */
-	ODM_SetBBReg(dm_odm, ODM_REG_ANTDIV_PARA1_11N, bMaskDWord, 0x000000a0);
+	PHY_SetBBReg(adapter, ODM_REG_ANTDIV_PARA1_11N, bMaskDWord, 0x000000a0);
 	/* CCK Settings */
-	ODM_SetBBReg(dm_odm, ODM_REG_BB_PWR_SAV4_11N, BIT7, 1); /* Fix CCK PHY status report issue */
-	ODM_SetBBReg(dm_odm, ODM_REG_CCK_ANTDIV_PARA2_11N, BIT4, 1); /* CCK complete HW AntDiv within 64 samples */
+	PHY_SetBBReg(adapter, ODM_REG_BB_PWR_SAV4_11N, BIT7, 1); /* Fix CCK PHY status report issue */
+	PHY_SetBBReg(adapter, ODM_REG_CCK_ANTDIV_PARA2_11N, BIT4, 1); /* CCK complete HW AntDiv within 64 samples */
 	/* Tx Settings */
-	ODM_SetBBReg(dm_odm, ODM_REG_TX_ANT_CTRL_11N, BIT21, 0); /* Reg80c[21]=1'b0		from TX Reg */
+	PHY_SetBBReg(adapter, ODM_REG_TX_ANT_CTRL_11N, BIT21, 0); /* Reg80c[21]=1'b0		from TX Reg */
 	ODM_UpdateRxIdleAnt_88E(dm_odm, MAIN_ANT);
 
 	/* antenna mapping table */
 	if (!dm_odm->bIsMPChip) { /* testchip */
-		ODM_SetBBReg(dm_odm, ODM_REG_RX_DEFUALT_A_11N, BIT10|BIT9|BIT8, 1);	/* Reg858[10:8]=3'b001 */
-		ODM_SetBBReg(dm_odm, ODM_REG_RX_DEFUALT_A_11N, BIT13|BIT12|BIT11, 2);	/* Reg858[13:11]=3'b010 */
+		PHY_SetBBReg(adapter, ODM_REG_RX_DEFUALT_A_11N, BIT10|BIT9|BIT8, 1);	/* Reg858[10:8]=3'b001 */
+		PHY_SetBBReg(adapter, ODM_REG_RX_DEFUALT_A_11N, BIT13|BIT12|BIT11, 2);	/* Reg858[13:11]=3'b010 */
 	} else { /* MPchip */
-		ODM_SetBBReg(dm_odm, ODM_REG_ANT_MAPPING1_11N, bMaskDWord, 0x0201);	/* Reg914=3'b010, Reg915=3'b001 */
+		PHY_SetBBReg(adapter, ODM_REG_ANT_MAPPING1_11N, bMaskDWord, 0x0201);	/* Reg914=3'b010, Reg915=3'b001 */
 	}
 }
 
 static void odm_FastAntTrainingInit(struct odm_dm_struct *dm_odm)
 {
+	struct adapter *adapter = dm_odm->Adapter;
 	u32	value32, i;
 	struct fast_ant_train *dm_fat_tbl = &dm_odm->DM_FatTable;
 	u32	AntCombination = 2;
@@ -131,52 +134,52 @@ static void odm_FastAntTrainingInit(struct odm_dm_struct *dm_odm)
 	ODM_SetMACReg(dm_odm, 0x7b4, 0xFFFF, 0);
 	ODM_SetMACReg(dm_odm, 0x7b0, bMaskDWord, 0);
 
-	ODM_SetBBReg(dm_odm, 0x870, BIT9|BIT8, 0);/* Reg870[8]=1'b0, Reg870[9]=1'b0		antsel antselb by HW */
-	ODM_SetBBReg(dm_odm, 0x864, BIT10, 0);	/* Reg864[10]=1'b0	antsel2 by HW */
-	ODM_SetBBReg(dm_odm, 0xb2c, BIT22, 0);	/* Regb2c[22]=1'b0	disable CS/CG switch */
-	ODM_SetBBReg(dm_odm, 0xb2c, BIT31, 1);	/* Regb2c[31]=1'b1	output at CG only */
-	ODM_SetBBReg(dm_odm, 0xca4, bMaskDWord, 0x000000a0);
+	PHY_SetBBReg(adapter, 0x870, BIT9|BIT8, 0);/* Reg870[8]=1'b0, Reg870[9]=1'b0		antsel antselb by HW */
+	PHY_SetBBReg(adapter, 0x864, BIT10, 0);	/* Reg864[10]=1'b0	antsel2 by HW */
+	PHY_SetBBReg(adapter, 0xb2c, BIT22, 0);	/* Regb2c[22]=1'b0	disable CS/CG switch */
+	PHY_SetBBReg(adapter, 0xb2c, BIT31, 1);	/* Regb2c[31]=1'b1	output at CG only */
+	PHY_SetBBReg(adapter, 0xca4, bMaskDWord, 0x000000a0);
 
 	/* antenna mapping table */
 	if (AntCombination == 2) {
 		if (!dm_odm->bIsMPChip) { /* testchip */
-			ODM_SetBBReg(dm_odm, 0x858, BIT10|BIT9|BIT8, 1);	/* Reg858[10:8]=3'b001 */
-			ODM_SetBBReg(dm_odm, 0x858, BIT13|BIT12|BIT11, 2);	/* Reg858[13:11]=3'b010 */
+			PHY_SetBBReg(adapter, 0x858, BIT10|BIT9|BIT8, 1);	/* Reg858[10:8]=3'b001 */
+			PHY_SetBBReg(adapter, 0x858, BIT13|BIT12|BIT11, 2);	/* Reg858[13:11]=3'b010 */
 		} else { /* MPchip */
-			ODM_SetBBReg(dm_odm, 0x914, bMaskByte0, 1);
-			ODM_SetBBReg(dm_odm, 0x914, bMaskByte1, 2);
+			PHY_SetBBReg(adapter, 0x914, bMaskByte0, 1);
+			PHY_SetBBReg(adapter, 0x914, bMaskByte1, 2);
 		}
 	} else if (AntCombination == 7) {
 		if (!dm_odm->bIsMPChip) { /* testchip */
-			ODM_SetBBReg(dm_odm, 0x858, BIT10|BIT9|BIT8, 0);	/* Reg858[10:8]=3'b000 */
-			ODM_SetBBReg(dm_odm, 0x858, BIT13|BIT12|BIT11, 1);	/* Reg858[13:11]=3'b001 */
-			ODM_SetBBReg(dm_odm, 0x878, BIT16, 0);
-			ODM_SetBBReg(dm_odm, 0x858, BIT15|BIT14, 2);	/* Reg878[0],Reg858[14:15])=3'b010 */
-			ODM_SetBBReg(dm_odm, 0x878, BIT19|BIT18|BIT17, 3);/* Reg878[3:1]=3b'011 */
-			ODM_SetBBReg(dm_odm, 0x878, BIT22|BIT21|BIT20, 4);/* Reg878[6:4]=3b'100 */
-			ODM_SetBBReg(dm_odm, 0x878, BIT25|BIT24|BIT23, 5);/* Reg878[9:7]=3b'101 */
-			ODM_SetBBReg(dm_odm, 0x878, BIT28|BIT27|BIT26, 6);/* Reg878[12:10]=3b'110 */
-			ODM_SetBBReg(dm_odm, 0x878, BIT31|BIT30|BIT29, 7);/* Reg878[15:13]=3b'111 */
+			PHY_SetBBReg(adapter, 0x858, BIT10|BIT9|BIT8, 0);	/* Reg858[10:8]=3'b000 */
+			PHY_SetBBReg(adapter, 0x858, BIT13|BIT12|BIT11, 1);	/* Reg858[13:11]=3'b001 */
+			PHY_SetBBReg(adapter, 0x878, BIT16, 0);
+			PHY_SetBBReg(adapter, 0x858, BIT15|BIT14, 2);	/* Reg878[0],Reg858[14:15])=3'b010 */
+			PHY_SetBBReg(adapter, 0x878, BIT19|BIT18|BIT17, 3);/* Reg878[3:1]=3b'011 */
+			PHY_SetBBReg(adapter, 0x878, BIT22|BIT21|BIT20, 4);/* Reg878[6:4]=3b'100 */
+			PHY_SetBBReg(adapter, 0x878, BIT25|BIT24|BIT23, 5);/* Reg878[9:7]=3b'101 */
+			PHY_SetBBReg(adapter, 0x878, BIT28|BIT27|BIT26, 6);/* Reg878[12:10]=3b'110 */
+			PHY_SetBBReg(adapter, 0x878, BIT31|BIT30|BIT29, 7);/* Reg878[15:13]=3b'111 */
 		} else { /* MPchip */
-			ODM_SetBBReg(dm_odm, 0x914, bMaskByte0, 0);
-			ODM_SetBBReg(dm_odm, 0x914, bMaskByte1, 1);
-			ODM_SetBBReg(dm_odm, 0x914, bMaskByte2, 2);
-			ODM_SetBBReg(dm_odm, 0x914, bMaskByte3, 3);
-			ODM_SetBBReg(dm_odm, 0x918, bMaskByte0, 4);
-			ODM_SetBBReg(dm_odm, 0x918, bMaskByte1, 5);
-			ODM_SetBBReg(dm_odm, 0x918, bMaskByte2, 6);
-			ODM_SetBBReg(dm_odm, 0x918, bMaskByte3, 7);
+			PHY_SetBBReg(adapter, 0x914, bMaskByte0, 0);
+			PHY_SetBBReg(adapter, 0x914, bMaskByte1, 1);
+			PHY_SetBBReg(adapter, 0x914, bMaskByte2, 2);
+			PHY_SetBBReg(adapter, 0x914, bMaskByte3, 3);
+			PHY_SetBBReg(adapter, 0x918, bMaskByte0, 4);
+			PHY_SetBBReg(adapter, 0x918, bMaskByte1, 5);
+			PHY_SetBBReg(adapter, 0x918, bMaskByte2, 6);
+			PHY_SetBBReg(adapter, 0x918, bMaskByte3, 7);
 		}
 	}
 
 	/* Default Ant Setting when no fast training */
-	ODM_SetBBReg(dm_odm, 0x80c, BIT21, 1); /* Reg80c[21]=1'b1		from TX Info */
-	ODM_SetBBReg(dm_odm, 0x864, BIT5|BIT4|BIT3, 0);	/* Default RX */
-	ODM_SetBBReg(dm_odm, 0x864, BIT8|BIT7|BIT6, 1);	/* Optional RX */
+	PHY_SetBBReg(adapter, 0x80c, BIT21, 1); /* Reg80c[21]=1'b1		from TX Info */
+	PHY_SetBBReg(adapter, 0x864, BIT5|BIT4|BIT3, 0);	/* Default RX */
+	PHY_SetBBReg(adapter, 0x864, BIT8|BIT7|BIT6, 1);	/* Optional RX */
 
 	/* Enter Traing state */
-	ODM_SetBBReg(dm_odm, 0x864, BIT2|BIT1|BIT0, (AntCombination-1));	/* Reg864[2:0]=3'd6	ant combination=reg864[2:0]+1 */
-	ODM_SetBBReg(dm_odm, 0xc50, BIT7, 1);	/* RegC50[7]=1'b1		enable HW AntDiv */
+	PHY_SetBBReg(adapter, 0x864, BIT2|BIT1|BIT0, (AntCombination-1));	/* Reg864[2:0]=3'd6	ant combination=reg864[2:0]+1 */
+	PHY_SetBBReg(adapter, 0xc50, BIT7, 1);	/* RegC50[7]=1'b1		enable HW AntDiv */
 }
 
 void ODM_AntennaDiversityInit_88E(struct odm_dm_struct *dm_odm)
@@ -198,6 +201,7 @@ void ODM_AntennaDiversityInit_88E(struct odm_dm_struct *dm_odm)
 void ODM_UpdateRxIdleAnt_88E(struct odm_dm_struct *dm_odm, u8 Ant)
 {
 	struct fast_ant_train *dm_fat_tbl = &dm_odm->DM_FatTable;
+	struct adapter *adapter = dm_odm->Adapter;
 	u32	DefaultAnt, OptionalAnt;
 
 	if (dm_fat_tbl->RxIdleAnt != Ant) {
@@ -211,13 +215,13 @@ void ODM_UpdateRxIdleAnt_88E(struct odm_dm_struct *dm_odm, u8 Ant)
 		}
 
 		if (dm_odm->AntDivType == CG_TRX_HW_ANTDIV) {
-			ODM_SetBBReg(dm_odm, ODM_REG_RX_ANT_CTRL_11N, BIT5|BIT4|BIT3, DefaultAnt);	/* Default RX */
-			ODM_SetBBReg(dm_odm, ODM_REG_RX_ANT_CTRL_11N, BIT8|BIT7|BIT6, OptionalAnt);		/* Optional RX */
-			ODM_SetBBReg(dm_odm, ODM_REG_ANTSEL_CTRL_11N, BIT14|BIT13|BIT12, DefaultAnt);	/* Default TX */
+			PHY_SetBBReg(adapter, ODM_REG_RX_ANT_CTRL_11N, BIT5|BIT4|BIT3, DefaultAnt);	/* Default RX */
+			PHY_SetBBReg(adapter, ODM_REG_RX_ANT_CTRL_11N, BIT8|BIT7|BIT6, OptionalAnt);		/* Optional RX */
+			PHY_SetBBReg(adapter, ODM_REG_ANTSEL_CTRL_11N, BIT14|BIT13|BIT12, DefaultAnt);	/* Default TX */
 			ODM_SetMACReg(dm_odm, ODM_REG_RESP_TX_11N, BIT6|BIT7, DefaultAnt);	/* Resp Tx */
 		} else if (dm_odm->AntDivType == CGCS_RX_HW_ANTDIV) {
-			ODM_SetBBReg(dm_odm, ODM_REG_RX_ANT_CTRL_11N, BIT5|BIT4|BIT3, DefaultAnt);	/* Default RX */
-			ODM_SetBBReg(dm_odm, ODM_REG_RX_ANT_CTRL_11N, BIT8|BIT7|BIT6, OptionalAnt);		/* Optional RX */
+			PHY_SetBBReg(adapter, ODM_REG_RX_ANT_CTRL_11N, BIT5|BIT4|BIT3, DefaultAnt);	/* Default RX */
+			PHY_SetBBReg(adapter, ODM_REG_RX_ANT_CTRL_11N, BIT8|BIT7|BIT6, OptionalAnt);		/* Optional RX */
 		}
 	}
 	dm_fat_tbl->RxIdleAnt = Ant;
@@ -343,16 +347,18 @@ static void odm_HWAntDiv(struct odm_dm_struct *dm_odm)
 void ODM_AntennaDiversity_88E(struct odm_dm_struct *dm_odm)
 {
 	struct fast_ant_train *dm_fat_tbl = &dm_odm->DM_FatTable;
+	struct adapter *adapter = dm_odm->Adapter;
+
 	if ((dm_odm->SupportICType != ODM_RTL8188E) || (!(dm_odm->SupportAbility & ODM_BB_ANT_DIV)))
 		return;
 	if (!dm_odm->bLinked) {
 		ODM_RT_TRACE(dm_odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("ODM_AntennaDiversity_88E(): No Link.\n"));
 		if (dm_fat_tbl->bBecomeLinked) {
 			ODM_RT_TRACE(dm_odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("Need to Turn off HW AntDiv\n"));
-			ODM_SetBBReg(dm_odm, ODM_REG_IGI_A_11N, BIT7, 0);	/* RegC50[7]=1'b1		enable HW AntDiv */
-			ODM_SetBBReg(dm_odm, ODM_REG_CCK_ANTDIV_PARA1_11N, BIT15, 0); /* Enable CCK AntDiv */
+			PHY_SetBBReg(adapter, ODM_REG_IGI_A_11N, BIT7, 0);	/* RegC50[7]=1'b1		enable HW AntDiv */
+			PHY_SetBBReg(adapter, ODM_REG_CCK_ANTDIV_PARA1_11N, BIT15, 0); /* Enable CCK AntDiv */
 			if (dm_odm->AntDivType == CG_TRX_HW_ANTDIV)
-				ODM_SetBBReg(dm_odm, ODM_REG_TX_ANT_CTRL_11N, BIT21, 0); /* Reg80c[21]=1'b0		from TX Reg */
+				PHY_SetBBReg(adapter, ODM_REG_TX_ANT_CTRL_11N, BIT21, 0); /* Reg80c[21]=1'b0		from TX Reg */
 			dm_fat_tbl->bBecomeLinked = dm_odm->bLinked;
 		}
 		return;
@@ -360,10 +366,10 @@ void ODM_AntennaDiversity_88E(struct odm_dm_struct *dm_odm)
 		if (!dm_fat_tbl->bBecomeLinked) {
 			ODM_RT_TRACE(dm_odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("Need to Turn on HW AntDiv\n"));
 			/* Because HW AntDiv is disabled before Link, we enable HW AntDiv after link */
-			ODM_SetBBReg(dm_odm, ODM_REG_IGI_A_11N, BIT7, 1);	/* RegC50[7]=1'b1		enable HW AntDiv */
-			ODM_SetBBReg(dm_odm, ODM_REG_CCK_ANTDIV_PARA1_11N, BIT15, 1); /* Enable CCK AntDiv */
+			PHY_SetBBReg(adapter, ODM_REG_IGI_A_11N, BIT7, 1);	/* RegC50[7]=1'b1		enable HW AntDiv */
+			PHY_SetBBReg(adapter, ODM_REG_CCK_ANTDIV_PARA1_11N, BIT15, 1); /* Enable CCK AntDiv */
 			if (dm_odm->AntDivType == CG_TRX_HW_ANTDIV)
-				ODM_SetBBReg(dm_odm, ODM_REG_TX_ANT_CTRL_11N, BIT21, 1); /* Reg80c[21]=1'b1		from TX Info */
+				PHY_SetBBReg(adapter, ODM_REG_TX_ANT_CTRL_11N, BIT21, 1); /* Reg80c[21]=1'b1		from TX Info */
 			dm_fat_tbl->bBecomeLinked = dm_odm->bLinked;
 		}
 	}
diff --git a/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c b/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c
index 00bc934..eae8358 100644
--- a/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c
+++ b/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c
@@ -70,7 +70,9 @@ void odm_ConfigMAC_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr, u8 Data)
 
 void odm_ConfigBB_AGC_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr, u32 Bitmask, u32 Data)
 {
-	ODM_SetBBReg(pDM_Odm, Addr, Bitmask, Data);
+	struct adapter *adapter = pDM_Odm->Adapter;
+
+	PHY_SetBBReg(adapter, Addr, Bitmask, Data);
 	/*  Add 1us delay between BB/RF register setting. */
 	udelay(1);
 
@@ -104,6 +106,8 @@ void odm_ConfigBB_PHY_REG_PG_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr,
 
 void odm_ConfigBB_PHY_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr, u32 Bitmask, u32 Data)
 {
+	struct adapter *adapter = pDM_Odm->Adapter;
+
 	if (Addr == 0xfe) {
 		msleep(50);
 	} else if (Addr == 0xfd) {
@@ -119,7 +123,7 @@ void odm_ConfigBB_PHY_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr, u32 Bitmask
 	} else {
 		if (Addr == 0xa24)
 			pDM_Odm->RFCalibrateInfo.RegA24 = Data;
-		ODM_SetBBReg(pDM_Odm, Addr, Bitmask, Data);
+		PHY_SetBBReg(adapter, Addr, Bitmask, Data);
 
 		/*  Add 1us delay between BB/RF register setting. */
 		udelay(1);
diff --git a/drivers/staging/rtl8188eu/hal/odm_interface.c b/drivers/staging/rtl8188eu/hal/odm_interface.c
index 780cb11..8ac7690 100644
--- a/drivers/staging/rtl8188eu/hal/odm_interface.c
+++ b/drivers/staging/rtl8188eu/hal/odm_interface.c
@@ -69,12 +69,6 @@ u32 ODM_GetMACReg(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 BitMask)
 	return PHY_QueryBBReg(Adapter, RegAddr, BitMask);
 }
 
-void ODM_SetBBReg(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 BitMask, u32 Data)
-{
-	struct adapter *Adapter = pDM_Odm->Adapter;
-	PHY_SetBBReg(Adapter, RegAddr, BitMask, Data);
-}
-
 u32 ODM_GetBBReg(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 BitMask)
 {
 	struct adapter *Adapter = pDM_Odm->Adapter;
diff --git a/drivers/staging/rtl8188eu/include/odm_interface.h b/drivers/staging/rtl8188eu/include/odm_interface.h
index c088c85..c649164 100644
--- a/drivers/staging/rtl8188eu/include/odm_interface.h
+++ b/drivers/staging/rtl8188eu/include/odm_interface.h
@@ -94,9 +94,6 @@ void ODM_SetMACReg(struct odm_dm_struct *pDM_Odm, u32 RegAddr,
 
 u32 ODM_GetMACReg(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 BitMask);
 
-void ODM_SetBBReg(struct odm_dm_struct *pDM_Odm, u32 RegAddr,
-		  u32 BitMask, u32 Data);
-
 u32 ODM_GetBBReg(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 BitMask);
 
 void ODM_SetRFReg(struct odm_dm_struct *pDM_Odm, enum ODM_RF_RADIO_PATH eRFPath,
-- 
1.8.4
