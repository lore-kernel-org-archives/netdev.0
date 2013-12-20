From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 11/11] staging: r8188eu: Replace wrappers ODM_StallExecution,
 ODM_delay_us, and rtw_udelay_os
Date: Thu, 19 Dec 2013 22:38:43 -0600
Message-ID: <1387514323-4486-12-git-send-email-Larry.Finger@lwfinger.net>
References: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
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

Each instance may bre replaced by udelay

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_efuse.c         |  2 +-
 drivers/staging/rtl8188eu/hal/HalPwrSeqCmd.c       |  6 +++---
 drivers/staging/rtl8188eu/hal/odm.c                | 10 ++++-----
 drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c | 24 +++++++++++-----------
 drivers/staging/rtl8188eu/hal/odm_interface.c      | 10 ---------
 drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c  |  2 +-
 drivers/staging/rtl8188eu/hal/rtl8188e_phycfg.c    |  6 +++---
 drivers/staging/rtl8188eu/hal/rtl8188e_rf6052.c    |  8 ++++----
 drivers/staging/rtl8188eu/include/odm_interface.h  |  4 ----
 drivers/staging/rtl8188eu/include/osdep_service.h  |  2 --
 drivers/staging/rtl8188eu/os_dep/osdep_service.c   |  5 -----
 11 files changed, 29 insertions(+), 50 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_efuse.c b/drivers/staging/rtl8188eu/core/rtw_efuse.c
index 806f56f..6149e3a 100644
--- a/drivers/staging/rtl8188eu/core/rtw_efuse.c
+++ b/drivers/staging/rtl8188eu/core/rtw_efuse.c
@@ -204,7 +204,7 @@ ReadEFuseByte(
 	/*  This fix the problem that Efuse read error in high temperature condition. */
 	/*  Designer says that there shall be some delay after ready bit is set, or the */
 	/*  result will always stay on last data we read. */
-	rtw_udelay_os(50);
+	udelay(50);
 	value32 = rtw_read32(Adapter, EFUSE_CTRL);
 
 	*pbuf = (u8)(value32 & 0xff);
diff --git a/drivers/staging/rtl8188eu/hal/HalPwrSeqCmd.c b/drivers/staging/rtl8188eu/hal/HalPwrSeqCmd.c
index 5700dbc..50f9513 100644
--- a/drivers/staging/rtl8188eu/hal/HalPwrSeqCmd.c
+++ b/drivers/staging/rtl8188eu/hal/HalPwrSeqCmd.c
@@ -100,7 +100,7 @@ u8 HalPwrSeqCmdParsing(struct adapter *padapter, u8 cut_vers, u8 fab_vers,
 					if (value == (GET_PWR_CFG_VALUE(pwrcfgcmd) & GET_PWR_CFG_MASK(pwrcfgcmd)))
 						poll_bit = true;
 					else
-						rtw_udelay_os(10);
+						udelay(10);
 
 					if (poll_count++ > max_poll_count) {
 						DBG_88E("Fail to polling Offset[%#x]\n", offset);
@@ -111,9 +111,9 @@ u8 HalPwrSeqCmdParsing(struct adapter *padapter, u8 cut_vers, u8 fab_vers,
 			case PWR_CMD_DELAY:
 				RT_TRACE(_module_hal_init_c_ , _drv_info_, ("HalPwrSeqCmdParsing: PWR_CMD_DELAY\n"));
 				if (GET_PWR_CFG_VALUE(pwrcfgcmd) == PWRSEQ_DELAY_US)
-					rtw_udelay_os(GET_PWR_CFG_OFFSET(pwrcfgcmd));
+					udelay(GET_PWR_CFG_OFFSET(pwrcfgcmd));
 				else
-					rtw_udelay_os(GET_PWR_CFG_OFFSET(pwrcfgcmd)*1000);
+					udelay(GET_PWR_CFG_OFFSET(pwrcfgcmd)*1000);
 				break;
 			case PWR_CMD_END:
 				/*  When this command is parsed, end the process */
diff --git a/drivers/staging/rtl8188eu/hal/odm.c b/drivers/staging/rtl8188eu/hal/odm.c
index 285475f..dc4e389 100644
--- a/drivers/staging/rtl8188eu/hal/odm.c
+++ b/drivers/staging/rtl8188eu/hal/odm.c
@@ -1868,7 +1868,7 @@ u32 GetPSDData(struct odm_dm_struct *pDM_Odm, unsigned int point, u8 initial_gai
 	/* Start PSD calculation, Reg808[22]=0->1 */
 	ODM_SetBBReg(pDM_Odm, 0x808, BIT22, 1);
 	/* Need to wait for HW PSD report */
-	ODM_StallExecution(30);
+	udelay(30);
 	ODM_SetBBReg(pDM_Odm, 0x808, BIT22, 0);
 	/* Read PSD report, Reg8B4[15:0] */
 	psd_report = ODM_GetBBReg(pDM_Odm, 0x8B4, bMaskDWord) & 0x0000FFFF;
@@ -1986,7 +1986,7 @@ bool ODM_SingleDualAntennaDetection(struct odm_dm_struct *pDM_Odm, u8 mode)
 	ODM_SetBBReg(pDM_Odm, rFPGA0_XA_RFInterfaceOE, ODM_DPDT, Antenna_A);  /*  change to Antenna A */
 	/*  Step 1: USE IQK to transmitter single tone */
 
-	ODM_StallExecution(10);
+	udelay(10);
 
 	/* Store A Path Register 88c, c08, 874, c50 */
 	Reg88c = ODM_GetBBReg(pDM_Odm, rFPGA0_AnalogParameter4, bMaskDWord);
@@ -2048,7 +2048,7 @@ bool ODM_SingleDualAntennaDetection(struct odm_dm_struct *pDM_Odm, u8 mode)
 	/* IQK Single tone start */
 	ODM_SetBBReg(pDM_Odm, rFPGA0_IQK, bMaskDWord, 0x80800000);
 	ODM_SetBBReg(pDM_Odm, rIQK_AGC_Pts, bMaskDWord, 0xf8000000);
-	ODM_StallExecution(1000);
+	udelay(1000);
 	PSD_report_tmp = 0x0;
 
 	for (n = 0; n < 2; n++) {
@@ -2060,7 +2060,7 @@ bool ODM_SingleDualAntennaDetection(struct odm_dm_struct *pDM_Odm, u8 mode)
 	PSD_report_tmp = 0x0;
 
 	ODM_SetBBReg(pDM_Odm, rFPGA0_XA_RFInterfaceOE, 0x300, Antenna_B);  /*  change to Antenna B */
-	ODM_StallExecution(10);
+	udelay(10);
 
 
 	for (n = 0; n < 2; n++) {
@@ -2071,7 +2071,7 @@ bool ODM_SingleDualAntennaDetection(struct odm_dm_struct *pDM_Odm, u8 mode)
 
 	/*  change to open case */
 	ODM_SetBBReg(pDM_Odm, rFPGA0_XA_RFInterfaceOE, 0x300, 0);  /*  change to Ant A and B all open case */
-	ODM_StallExecution(10);
+	udelay(10);
 
 	for (n = 0; n < 2; n++) {
 		PSD_report_tmp =  GetPSDData(pDM_Odm, 14, initial_gain);
diff --git a/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c b/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c
index 4f8c3bb..00bc934 100644
--- a/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c
+++ b/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c
@@ -31,15 +31,15 @@ void odm_ConfigRFReg_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr,
 	} else if (Addr == 0xfc) {
 		mdelay(1);
 	} else if (Addr == 0xfb) {
-		ODM_delay_us(50);
+		udelay(50);
 	} else if (Addr == 0xfa) {
-		ODM_delay_us(5);
+		udelay(5);
 	} else if (Addr == 0xf9) {
-		ODM_delay_us(1);
+		udelay(1);
 	} else {
 		ODM_SetRFReg(pDM_Odm, RF_PATH, RegAddr, bRFRegOffsetMask, Data);
 		/*  Add 1us delay between BB/RF register setting. */
-		ODM_delay_us(1);
+		udelay(1);
 	}
 }
 
@@ -72,7 +72,7 @@ void odm_ConfigBB_AGC_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr, u32 Bitmask
 {
 	ODM_SetBBReg(pDM_Odm, Addr, Bitmask, Data);
 	/*  Add 1us delay between BB/RF register setting. */
-	ODM_delay_us(1);
+	udelay(1);
 
 	ODM_RT_TRACE(pDM_Odm, ODM_COMP_INIT, ODM_DBG_TRACE,
 		     ("===> ODM_ConfigBBWithHeaderFile: [AGC_TAB] %08X %08X\n",
@@ -89,11 +89,11 @@ void odm_ConfigBB_PHY_REG_PG_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr,
 	} else if (Addr == 0xfc) {
 		mdelay(1);
 	} else if (Addr == 0xfb) {
-		ODM_delay_us(50);
+		udelay(50);
 	} else if (Addr == 0xfa) {
-		ODM_delay_us(5);
+		udelay(5);
 	} else if (Addr == 0xf9) {
-		ODM_delay_us(1);
+		udelay(1);
 	} else{
 		ODM_RT_TRACE(pDM_Odm, ODM_COMP_INIT, ODM_DBG_LOUD,
 			     ("===> @@@@@@@ ODM_ConfigBBWithHeaderFile: [PHY_REG] %08X %08X %08X\n",
@@ -111,18 +111,18 @@ void odm_ConfigBB_PHY_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr, u32 Bitmask
 	} else if (Addr == 0xfc) {
 		mdelay(1);
 	} else if (Addr == 0xfb) {
-		ODM_delay_us(50);
+		udelay(50);
 	} else if (Addr == 0xfa) {
-		ODM_delay_us(5);
+		udelay(5);
 	} else if (Addr == 0xf9) {
-		ODM_delay_us(1);
+		udelay(1);
 	} else {
 		if (Addr == 0xa24)
 			pDM_Odm->RFCalibrateInfo.RegA24 = Data;
 		ODM_SetBBReg(pDM_Odm, Addr, Bitmask, Data);
 
 		/*  Add 1us delay between BB/RF register setting. */
-		ODM_delay_us(1);
+		udelay(1);
 		ODM_RT_TRACE(pDM_Odm, ODM_COMP_INIT, ODM_DBG_TRACE,
 			     ("===> ODM_ConfigBBWithHeaderFile: [PHY_REG] %08X %08X\n",
 			     Addr, Data));
diff --git a/drivers/staging/rtl8188eu/hal/odm_interface.c b/drivers/staging/rtl8188eu/hal/odm_interface.c
index 4510270..e7fee79 100644
--- a/drivers/staging/rtl8188eu/hal/odm_interface.c
+++ b/drivers/staging/rtl8188eu/hal/odm_interface.c
@@ -147,16 +147,6 @@ void ODM_IsWorkItemScheduled(void *pRtWorkItem)
 }
 
 /*  ODM Timer relative API. */
-void ODM_StallExecution(u32 usDelay)
-{
-	rtw_udelay_os(usDelay);
-}
-
-void ODM_delay_us(u32 us)
-{
-	rtw_udelay_os(us);
-}
-
 void ODM_sleep_us(u32 us)
 {
 	rtw_usleep_os(us);
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c b/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
index 0a0bc41..d81193b 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
@@ -574,7 +574,7 @@ static s32 _FWFreeToGo(struct adapter *padapter)
 			DBG_88E("%s: Polling FW ready success!! REG_MCUFWDL:0x%08x\n", __func__, value32);
 			return _SUCCESS;
 		}
-		rtw_udelay_os(5);
+		udelay(5);
 	} while (counter++ < POLLING_READY_TIMEOUT_COUNT);
 
 	DBG_88E("%s: Polling FW ready fail!! REG_MCUFWDL:0x%08x\n", __func__, value32);
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_phycfg.c b/drivers/staging/rtl8188eu/hal/rtl8188e_phycfg.c
index 68bb96d..8079fc6 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_phycfg.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_phycfg.c
@@ -190,12 +190,12 @@ phy_RFSerialRead(
 	tmplong2 = (tmplong2 & (~bLSSIReadAddress)) | (NewOffset<<23) | bLSSIReadEdge;	/* T65 RF */
 
 	PHY_SetBBReg(Adapter, rFPGA0_XA_HSSIParameter2, bMaskDWord, tmplong&(~bLSSIReadEdge));
-	rtw_udelay_os(10);/*  PlatformStallExecution(10); */
+	udelay(10);/*  PlatformStallExecution(10); */
 
 	PHY_SetBBReg(Adapter, pPhyReg->rfHSSIPara2, bMaskDWord, tmplong2);
-	rtw_udelay_os(100);/* PlatformStallExecution(100); */
+	udelay(100);/* PlatformStallExecution(100); */
 
-	rtw_udelay_os(10);/* PlatformStallExecution(10); */
+	udelay(10);/* PlatformStallExecution(10); */
 
 	if (eRFPath == RF_PATH_A)
 		RfPiEnable = (u8)PHY_QueryBBReg(Adapter, rFPGA0_XA_HSSIParameter1, BIT8);
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_rf6052.c b/drivers/staging/rtl8188eu/hal/rtl8188e_rf6052.c
index 299e03e..2999da7 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_rf6052.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_rf6052.c
@@ -502,18 +502,18 @@ static int phy_RF6052_Config_ParaFile(struct adapter *Adapter)
 		}
 		/*----Set RF_ENV enable----*/
 		PHY_SetBBReg(Adapter, pPhyReg->rfintfe, bRFSI_RFENV<<16, 0x1);
-		rtw_udelay_os(1);/* PlatformStallExecution(1); */
+		udelay(1);/* PlatformStallExecution(1); */
 
 		/*----Set RF_ENV output high----*/
 		PHY_SetBBReg(Adapter, pPhyReg->rfintfo, bRFSI_RFENV, 0x1);
-		rtw_udelay_os(1);/* PlatformStallExecution(1); */
+		udelay(1);/* PlatformStallExecution(1); */
 
 		/* Set bit number of Address and Data for RF register */
 		PHY_SetBBReg(Adapter, pPhyReg->rfHSSIPara2, b3WireAddressLength, 0x0);	/*  Set 1 to 4 bits for 8255 */
-		rtw_udelay_os(1);/* PlatformStallExecution(1); */
+		udelay(1);/* PlatformStallExecution(1); */
 
 		PHY_SetBBReg(Adapter, pPhyReg->rfHSSIPara2, b3WireDataLength, 0x0);	/*  Set 0 to 12  bits for 8255 */
-		rtw_udelay_os(1);/* PlatformStallExecution(1); */
+		udelay(1);/* PlatformStallExecution(1); */
 
 		/*----Initialize RF fom connfiguration file----*/
 		switch (eRFPath) {
diff --git a/drivers/staging/rtl8188eu/include/odm_interface.h b/drivers/staging/rtl8188eu/include/odm_interface.h
index 34ba46b..5e05d9e 100644
--- a/drivers/staging/rtl8188eu/include/odm_interface.h
+++ b/drivers/staging/rtl8188eu/include/odm_interface.h
@@ -135,10 +135,6 @@ void ODM_ScheduleWorkItem(void *pRtWorkItem);
 void ODM_IsWorkItemScheduled(void *pRtWorkItem);
 
 /*  ODM Timer relative API. */
-void ODM_StallExecution(u32 usDelay);
-
-void ODM_delay_us(u32 us);
-
 void ODM_sleep_us(u32 us);
 
 void ODM_SetTimer(struct odm_dm_struct *pDM_Odm, struct timer_list *pTimer,
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index a97486e..6085181 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -279,8 +279,6 @@ void rtw_usleep_os(int us);
 
 u32  rtw_atoi(u8 *s);
 
-void rtw_udelay_os(int us);
-
 void rtw_yield_os(void);
 
 static inline unsigned char _cancel_timer_ex(struct timer_list *ptimer)
diff --git a/drivers/staging/rtl8188eu/os_dep/osdep_service.c b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
index 985735b..e62f120 100644
--- a/drivers/staging/rtl8188eu/os_dep/osdep_service.c
+++ b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
@@ -253,11 +253,6 @@ void rtw_usleep_os(int us)
 		msleep((us/1000) + 1);
 }
 
-void rtw_udelay_os(int us)
-{
-	udelay((unsigned long)us);
-}
-
 void rtw_yield_os(void)
 {
 	yield();
-- 
1.8.4
