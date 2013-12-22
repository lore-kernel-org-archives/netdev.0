From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 25/31] staging: r8188eu: Cleanup of include/hal_intf.h
Date: Sun, 22 Dec 2013 17:36:56 -0600
Message-ID: <1387755422-11443-26-git-send-email-Larry.Finger@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:51147 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756917Ab3LVXit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:38:49 -0500
Received: by mail-pa0-f53.google.com with SMTP id hz1so4704714pad.12
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 15:38:49 -0800 (PST)
In-Reply-To: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver only handles RTL8188EU with USB interface, thus several hardware
defines and macros can be removed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/rtl8188e_dm.c   |  2 --
 drivers/staging/rtl8188eu/hal/rtl8188e_mp.c   | 18 +++++++----------
 drivers/staging/rtl8188eu/hal/usb_ops_linux.c |  1 -
 drivers/staging/rtl8188eu/include/drv_types.h |  2 --
 drivers/staging/rtl8188eu/include/hal_intf.h  | 29 ---------------------------
 drivers/staging/rtl8188eu/os_dep/usb_intf.c   |  1 -
 6 files changed, 7 insertions(+), 46 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_dm.c b/drivers/staging/rtl8188eu/hal/rtl8188e_dm.c
index 1e7c926..4c934e2 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_dm.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_dm.c
@@ -63,8 +63,6 @@ static void Init_ODM_ComInfo_88E(struct adapter *Adapter)
 
 	ODM_CmnInfoInit(dm_odm, ODM_CMNINFO_PLATFORM, ODM_CE);
 
-	ODM_CmnInfoInit(dm_odm, ODM_CMNINFO_INTERFACE, Adapter->interface_type);/* RTL871X_HCI_TYPE */
-
 	ODM_CmnInfoInit(dm_odm, ODM_CMNINFO_IC_TYPE, ODM_RTL8188E);
 
 	fab_ver = ODM_TSMC;
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_mp.c b/drivers/staging/rtl8188eu/hal/rtl8188e_mp.c
index e5dc036..3d0e6c9 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_mp.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_mp.c
@@ -652,12 +652,10 @@ void Hal_SetSingleToneTx(struct adapter *pAdapter, u8 bStart)
 		/*  Start Single Tone. */
 		RT_TRACE(_module_mp_, _drv_alert_, ("SetSingleToneTx: test start\n"));
 		/*  <20120326, Kordan> To amplify the power of tone for Xtal calibration. (asked by Edlu) */
-		if (IS_HARDWARE_TYPE_8188E(pAdapter)) {
-			reg58 = PHY_QueryRFReg(pAdapter, RF_PATH_A, LNA_Low_Gain_3, bRFRegOffsetMask);
-			reg58 &= 0xFFFFFFF0;
-			reg58 += 2;
-			PHY_SetRFReg(pAdapter, RF_PATH_A, LNA_Low_Gain_3, bRFRegOffsetMask, reg58);
-		}
+		reg58 = PHY_QueryRFReg(pAdapter, RF_PATH_A, LNA_Low_Gain_3, bRFRegOffsetMask);
+		reg58 &= 0xFFFFFFF0;
+		reg58 += 2;
+		PHY_SetRFReg(pAdapter, RF_PATH_A, LNA_Low_Gain_3, bRFRegOffsetMask, reg58);
 		PHY_SetBBReg(pAdapter, rFPGA0_RFMOD, bCCKEn, 0x0);
 		PHY_SetBBReg(pAdapter, rFPGA0_RFMOD, bOFDMEn, 0x0);
 
@@ -687,11 +685,9 @@ void Hal_SetSingleToneTx(struct adapter *pAdapter, u8 bStart)
 
 		/*  <20120326, Kordan> To amplify the power of tone for Xtal calibration. (asked by Edlu) */
 		/*  <20120326, Kordan> Only in single tone mode. (asked by Edlu) */
-		if (IS_HARDWARE_TYPE_8188E(pAdapter)) {
-			reg58 = PHY_QueryRFReg(pAdapter, RF_PATH_A, LNA_Low_Gain_3, bRFRegOffsetMask);
-			reg58 &= 0xFFFFFFF0;
-			PHY_SetRFReg(pAdapter, RF_PATH_A, LNA_Low_Gain_3, bRFRegOffsetMask, reg58);
-		}
+		reg58 = PHY_QueryRFReg(pAdapter, RF_PATH_A, LNA_Low_Gain_3, bRFRegOffsetMask);
+		reg58 &= 0xFFFFFFF0;
+		PHY_SetRFReg(pAdapter, RF_PATH_A, LNA_Low_Gain_3, bRFRegOffsetMask, reg58);
 		write_bbreg(pAdapter, rFPGA0_RFMOD, bCCKEn, 0x1);
 		write_bbreg(pAdapter, rFPGA0_RFMOD, bOFDMEn, 0x1);
 		if (is92C) {
diff --git a/drivers/staging/rtl8188eu/hal/usb_ops_linux.c b/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
index 787763e..31ae21a 100644
--- a/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
+++ b/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
@@ -723,6 +723,5 @@ void rtl8188eu_set_intf_ops(struct _io_ops	*pops)
 void rtl8188eu_set_hw_type(struct adapter *adapt)
 {
 	adapt->chip_type = RTL8188E;
-	adapt->HardwareType = HARDWARE_TYPE_RTL8188EU;
 	DBG_88E("CHIP TYPE: RTL8188E\n");
 }
diff --git a/drivers/staging/rtl8188eu/include/drv_types.h b/drivers/staging/rtl8188eu/include/drv_types.h
index 00a49ef..a492a1c 100644
--- a/drivers/staging/rtl8188eu/include/drv_types.h
+++ b/drivers/staging/rtl8188eu/include/drv_types.h
@@ -225,8 +225,6 @@ struct adapter {
 	int	pid[3];/* process id from UI, 0:wps, 1:hostapd, 2:dhcpcd */
 	int	bDongle;/* build-in module or external dongle */
 	u16	chip_type;
-	u16	HardwareType;
-	u16	interface_type;/* USB,SDIO,SPI,PCI */
 
 	struct dvobj_priv *dvobj;
 	struct	mlme_priv mlmepriv;
diff --git a/drivers/staging/rtl8188eu/include/hal_intf.h b/drivers/staging/rtl8188eu/include/hal_intf.h
index 439c3c9..c274b34 100644
--- a/drivers/staging/rtl8188eu/include/hal_intf.h
+++ b/drivers/staging/rtl8188eu/include/hal_intf.h
@@ -286,39 +286,10 @@ enum rt_eeprom_type {
 #define RF_CHANGE_BY_SW		BIT31
 
 enum hardware_type {
-	HARDWARE_TYPE_RTL8180,
-	HARDWARE_TYPE_RTL8185,
-	HARDWARE_TYPE_RTL8187,
-	HARDWARE_TYPE_RTL8188,
-	HARDWARE_TYPE_RTL8190P,
-	HARDWARE_TYPE_RTL8192E,
-	HARDWARE_TYPE_RTL819xU,
-	HARDWARE_TYPE_RTL8192SE,
-	HARDWARE_TYPE_RTL8192SU,
-	HARDWARE_TYPE_RTL8192CE,
-	HARDWARE_TYPE_RTL8192CU,
-	HARDWARE_TYPE_RTL8192DE,
-	HARDWARE_TYPE_RTL8192DU,
-	HARDWARE_TYPE_RTL8723AE,
-	HARDWARE_TYPE_RTL8723AU,
-	HARDWARE_TYPE_RTL8723AS,
-	HARDWARE_TYPE_RTL8188EE,
 	HARDWARE_TYPE_RTL8188EU,
-	HARDWARE_TYPE_RTL8188ES,
 	HARDWARE_TYPE_MAX,
 };
 
-/*  RTL8188E Series */
-#define IS_HARDWARE_TYPE_8188EE(_Adapter)			\
-(((struct adapter *)_Adapter)->HardwareType == HARDWARE_TYPE_RTL8188EE)
-#define IS_HARDWARE_TYPE_8188EU(_Adapter)			\
-(((struct adapter *)_Adapter)->HardwareType == HARDWARE_TYPE_RTL8188EU)
-#define IS_HARDWARE_TYPE_8188ES(_Adapter)			\
-(((struct adapter *)_Adapter)->HardwareType == HARDWARE_TYPE_RTL8188ES)
-#define	IS_HARDWARE_TYPE_8188E(_Adapter)	\
-(IS_HARDWARE_TYPE_8188EE(_Adapter) || IS_HARDWARE_TYPE_8188EU(_Adapter) || \
- IS_HARDWARE_TYPE_8188ES(_Adapter))
-
 #define GET_EEPROM_EFUSE_PRIV(adapter) (&adapter->eeprompriv)
 
 #define is_boot_from_eeprom(adapter) (adapter->eeprompriv.EepromOrEfuse)
diff --git a/drivers/staging/rtl8188eu/os_dep/usb_intf.c b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
index 35107fd..594580b 100644
--- a/drivers/staging/rtl8188eu/os_dep/usb_intf.c
+++ b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
@@ -657,7 +657,6 @@ static struct adapter *rtw_usb_if1_init(struct dvobj_priv *dvobj,
 	padapter->hw_init_mutex = &usb_drv->hw_init_mutex;
 
 	/* step 1-1., decide the chip_type via vid/pid */
-	padapter->interface_type = RTW_USB;
 	chip_by_usb_id(padapter, pdid);
 
 	if (rtw_handle_dualmac(padapter, 1) != _SUCCESS)
-- 
1.8.4
