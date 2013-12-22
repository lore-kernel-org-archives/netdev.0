From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 15/31] staging: r8188eu: Remove macro ODM_GetRFReg
Date: Sun, 22 Dec 2013 17:36:46 -0600
Message-ID: <1387755422-11443-16-git-send-email-Larry.Finger@lwfinger.net>
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

This one is a duplicate od macro PHY_QueryRFReg.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c    | 4 ++--
 drivers/staging/rtl8188eu/hal/odm.c               | 4 ++--
 drivers/staging/rtl8188eu/hal/odm_interface.c     | 6 ------
 drivers/staging/rtl8188eu/include/odm_interface.h | 3 ---
 4 files changed, 4 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
index 9552e4f..15e8e3f 100644
--- a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
+++ b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
@@ -173,7 +173,7 @@ odm_TXPowerTrackingCallback_ThermalMeter_8188E(
 		     ("===>dm_TXPowerTrackingCallback_ThermalMeter_8188E txpowercontrol %d\n",
 		     dm_odm->RFCalibrateInfo.TxPowerTrackControl));
 
-	ThermalValue = (u8)ODM_GetRFReg(dm_odm, RF_PATH_A, RF_T_METER_88E, 0xfc00);	/* 0x42: RF Reg[15:10] 88E */
+	ThermalValue = (u8)PHY_QueryRFReg(Adapter, RF_PATH_A, RF_T_METER_88E, 0xfc00);	/* 0x42: RF Reg[15:10] 88E */
 
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
 		     ("Readback Thermal Meter = 0x%x pre thermal meter 0x%x EEPROMthermalmeter 0x%x\n",
@@ -450,7 +450,7 @@ odm_TXPowerTrackingCallback_ThermalMeter_8188E(
 				ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
 					     ("TxPwrTracking 0xc80 = 0x%x, 0xc94 = 0x%x RF 0x24 = 0x%x\n",
 					     PHY_QueryBBReg(Adapter, 0xc80, bMaskDWord), PHY_QueryBBReg(Adapter,
-					     0xc94, bMaskDWord), ODM_GetRFReg(dm_odm, RF_PATH_A, 0x24, bRFRegOffsetMask)));
+					     0xc94, bMaskDWord), PHY_QueryRFReg(Adapter, RF_PATH_A, 0x24, bRFRegOffsetMask)));
 			}
 		}
 
diff --git a/drivers/staging/rtl8188eu/hal/odm.c b/drivers/staging/rtl8188eu/hal/odm.c
index 00b0675..e146c39 100644
--- a/drivers/staging/rtl8188eu/hal/odm.c
+++ b/drivers/staging/rtl8188eu/hal/odm.c
@@ -1992,8 +1992,8 @@ bool ODM_SingleDualAntennaDetection(struct odm_dm_struct *pDM_Odm, u8 mode)
 
 	/* 1 Backup Current RF/BB Settings */
 
-	CurrentChannel = ODM_GetRFReg(pDM_Odm, RF_PATH_A, ODM_CHANNEL, bRFRegOffsetMask);
-	RfLoopReg = ODM_GetRFReg(pDM_Odm, RF_PATH_A, 0x00, bRFRegOffsetMask);
+	CurrentChannel = PHY_QueryRFReg(adapter, RF_PATH_A, ODM_CHANNEL, bRFRegOffsetMask);
+	RfLoopReg = PHY_QueryRFReg(adapter, RF_PATH_A, 0x00, bRFRegOffsetMask);
 	PHY_SetBBReg(adapter, rFPGA0_XA_RFInterfaceOE, ODM_DPDT, Antenna_A);  /*  change to Antenna A */
 	/*  Step 1: USE IQK to transmitter single tone */
 
diff --git a/drivers/staging/rtl8188eu/hal/odm_interface.c b/drivers/staging/rtl8188eu/hal/odm_interface.c
index c2c1d55..0782bef 100644
--- a/drivers/staging/rtl8188eu/hal/odm_interface.c
+++ b/drivers/staging/rtl8188eu/hal/odm_interface.c
@@ -69,12 +69,6 @@ u32 ODM_GetMACReg(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 BitMask)
 	return PHY_QueryBBReg(Adapter, RegAddr, BitMask);
 }
 
-u32 ODM_GetRFReg(struct odm_dm_struct *pDM_Odm, enum ODM_RF_RADIO_PATH	eRFPath, u32 RegAddr, u32 BitMask)
-{
-	struct adapter *Adapter = pDM_Odm->Adapter;
-	return PHY_QueryRFReg(Adapter, (enum rf_radio_path)eRFPath, RegAddr, BitMask);
-}
-
 /*  ODM Memory relative API. */
 void ODM_AllocateMemory(struct odm_dm_struct *pDM_Odm, void **pPtr, u32 length)
 {
diff --git a/drivers/staging/rtl8188eu/include/odm_interface.h b/drivers/staging/rtl8188eu/include/odm_interface.h
index bc13b6a..e2d3e78 100644
--- a/drivers/staging/rtl8188eu/include/odm_interface.h
+++ b/drivers/staging/rtl8188eu/include/odm_interface.h
@@ -94,9 +94,6 @@ void ODM_SetMACReg(struct odm_dm_struct *pDM_Odm, u32 RegAddr,
 
 u32 ODM_GetMACReg(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 BitMask);
 
-u32 ODM_GetRFReg(struct odm_dm_struct *pDM_Odm, enum ODM_RF_RADIO_PATH eRFPath,
-		 u32 RegAddr, u32 BitMask);
-
 /*  Memory Relative Function. */
 void ODM_AllocateMemory(struct odm_dm_struct *pDM_Odm, void **pPtr, u32 length);
 void ODM_FreeMemory(struct odm_dm_struct *pDM_Odm, void *pPtr, u32 length);
-- 
1.8.4
