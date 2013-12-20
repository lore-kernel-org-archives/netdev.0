From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 10/11] staging: r8188eu: Replace wrappers ODM_delay_ms() and rtw_mdelay_os() with a simple mdelay
Date: Thu, 19 Dec 2013 22:38:42 -0600
Message-ID: <1387514323-4486-11-git-send-email-Larry.Finger@lwfinger.net>
References: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:40950 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753809Ab3LTElj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 23:41:39 -0500
Received: by mail-pa0-f52.google.com with SMTP id ld10so2126547pab.39
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 20:41:39 -0800 (PST)
In-Reply-To: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_mp.c            |  4 ++--
 drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c     | 10 +++++-----
 drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c | 12 ++++++------
 drivers/staging/rtl8188eu/hal/odm_interface.c      |  5 -----
 drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c       |  2 +-
 drivers/staging/rtl8188eu/hal/usb_halinit.c        |  2 +-
 drivers/staging/rtl8188eu/include/odm_interface.h  |  2 --
 drivers/staging/rtl8188eu/include/osdep_service.h  |  1 -
 drivers/staging/rtl8188eu/os_dep/osdep_service.c   |  5 -----
 9 files changed, 15 insertions(+), 28 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_mp.c b/drivers/staging/rtl8188eu/core/rtw_mp.c
index 76c1198..6451efd 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mp.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mp.c
@@ -858,11 +858,11 @@ static u32 rtw_GetPSDData(struct adapter *pAdapter, u32 point)
 	psd_val |= point;
 
 	rtw_write32(pAdapter, 0x808, psd_val);
-	rtw_mdelay_os(1);
+	mdelay(1);
 	psd_val |= 0x00400000;
 
 	rtw_write32(pAdapter, 0x808, psd_val);
-	rtw_mdelay_os(1);
+	mdelay(1);
 	psd_val = rtw_read32(pAdapter, 0x8B4);
 
 	psd_val &= 0x0000FFFF;
diff --git a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
index 650aefc..a317c9e 100644
--- a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
+++ b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
@@ -502,7 +502,7 @@ phy_PathA_IQK_8188E(struct adapter *adapt, bool configPathB)
 	/*  delay x ms */
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("Delay %d ms for One shot, path A LOK & IQK.\n", IQK_DELAY_TIME_88E));
 	/* PlatformStallExecution(IQK_DELAY_TIME_88E*1000); */
-	ODM_delay_ms(IQK_DELAY_TIME_88E);
+	mdelay(IQK_DELAY_TIME_88E);
 
 	/*  Check failed */
 	regeac = ODM_GetBBReg(dm_odm, rRx_Power_After_IQK_A_2, bMaskDWord);
@@ -568,7 +568,7 @@ phy_PathA_RxIQK(struct adapter *adapt, bool configPathB)
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
 		     ("Delay %d ms for One shot, path A LOK & IQK.\n",
 		     IQK_DELAY_TIME_88E));
-	ODM_delay_ms(IQK_DELAY_TIME_88E);
+	mdelay(IQK_DELAY_TIME_88E);
 
 	/*  Check failed */
 	regeac = ODM_GetBBReg(dm_odm, rRx_Power_After_IQK_A_2, bMaskDWord);
@@ -623,7 +623,7 @@ phy_PathA_RxIQK(struct adapter *adapt, bool configPathB)
 	/*  delay x ms */
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("Delay %d ms for One shot, path A LOK & IQK.\n", IQK_DELAY_TIME_88E));
 	/* PlatformStallExecution(IQK_DELAY_TIME_88E*1000); */
-	ODM_delay_ms(IQK_DELAY_TIME_88E);
+	mdelay(IQK_DELAY_TIME_88E);
 
 	/*  Check failed */
 	regeac = ODM_GetBBReg(dm_odm, rRx_Power_After_IQK_A_2, bMaskDWord);
@@ -667,7 +667,7 @@ phy_PathB_IQK_8188E(struct adapter *adapt)
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
 		     ("Delay %d ms for One shot, path B LOK & IQK.\n",
 		     IQK_DELAY_TIME_88E));
-	ODM_delay_ms(IQK_DELAY_TIME_88E);
+	mdelay(IQK_DELAY_TIME_88E);
 
 	/*  Check failed */
 	regeac = ODM_GetBBReg(dm_odm, rRx_Power_After_IQK_A_2, bMaskDWord);
@@ -1447,7 +1447,7 @@ void PHY_LCCalibrate_8188E(struct adapter *adapt)
 		return;
 
 	while (*(dm_odm->pbScanInProcess) && timecount < timeout) {
-		ODM_delay_ms(50);
+		mdelay(50);
 		timecount += 50;
 	}
 
diff --git a/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c b/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c
index 48cea29..4f8c3bb 100644
--- a/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c
+++ b/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c
@@ -27,9 +27,9 @@ void odm_ConfigRFReg_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr,
     if (Addr == 0xffe) {
 		msleep(50);
 	} else if (Addr == 0xfd) {
-		ODM_delay_ms(5);
+		mdelay(5);
 	} else if (Addr == 0xfc) {
-		ODM_delay_ms(1);
+		mdelay(1);
 	} else if (Addr == 0xfb) {
 		ODM_delay_us(50);
 	} else if (Addr == 0xfa) {
@@ -85,9 +85,9 @@ void odm_ConfigBB_PHY_REG_PG_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr,
 	if (Addr == 0xfe) {
 		msleep(50);
 	} else if (Addr == 0xfd) {
-		ODM_delay_ms(5);
+		mdelay(5);
 	} else if (Addr == 0xfc) {
-		ODM_delay_ms(1);
+		mdelay(1);
 	} else if (Addr == 0xfb) {
 		ODM_delay_us(50);
 	} else if (Addr == 0xfa) {
@@ -107,9 +107,9 @@ void odm_ConfigBB_PHY_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr, u32 Bitmask
 	if (Addr == 0xfe) {
 		msleep(50);
 	} else if (Addr == 0xfd) {
-		ODM_delay_ms(5);
+		mdelay(5);
 	} else if (Addr == 0xfc) {
-		ODM_delay_ms(1);
+		mdelay(1);
 	} else if (Addr == 0xfb) {
 		ODM_delay_us(50);
 	} else if (Addr == 0xfa) {
diff --git a/drivers/staging/rtl8188eu/hal/odm_interface.c b/drivers/staging/rtl8188eu/hal/odm_interface.c
index fa30811..4510270 100644
--- a/drivers/staging/rtl8188eu/hal/odm_interface.c
+++ b/drivers/staging/rtl8188eu/hal/odm_interface.c
@@ -152,11 +152,6 @@ void ODM_StallExecution(u32 usDelay)
 	rtw_udelay_os(usDelay);
 }
 
-void ODM_delay_ms(u32 ms)
-{
-	rtw_mdelay_os(ms);
-}
-
 void ODM_delay_us(u32 us)
 {
 	rtw_udelay_os(us);
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c b/drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c
index 8be2ad7..b409b69 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c
@@ -656,7 +656,7 @@ _func_enter_;
 			DLBcnCount++;
 			do {
 				rtw_yield_os();
-				/* rtw_mdelay_os(10); */
+				/* mdelay(10); */
 				/*  check rsvd page download OK. */
 				rtw_hal_get_hwreg(adapt, HW_VAR_BCN_VALID, (u8 *)(&bcn_valid));
 				poll++;
diff --git a/drivers/staging/rtl8188eu/hal/usb_halinit.c b/drivers/staging/rtl8188eu/hal/usb_halinit.c
index b867bbb..b24ad49 100644
--- a/drivers/staging/rtl8188eu/hal/usb_halinit.c
+++ b/drivers/staging/rtl8188eu/hal/usb_halinit.c
@@ -1894,7 +1894,7 @@ _func_enter_;
 				/* RQPN Load 0 */
 				rtw_write16(Adapter, REG_RQPN_NPQ, 0x0);
 				rtw_write32(Adapter, REG_RQPN, 0x80000000);
-				rtw_mdelay_os(10);
+				mdelay(10);
 			}
 		}
 		break;
diff --git a/drivers/staging/rtl8188eu/include/odm_interface.h b/drivers/staging/rtl8188eu/include/odm_interface.h
index 0585463..34ba46b 100644
--- a/drivers/staging/rtl8188eu/include/odm_interface.h
+++ b/drivers/staging/rtl8188eu/include/odm_interface.h
@@ -137,8 +137,6 @@ void ODM_IsWorkItemScheduled(void *pRtWorkItem);
 /*  ODM Timer relative API. */
 void ODM_StallExecution(u32 usDelay);
 
-void ODM_delay_ms(u32 ms);
-
 void ODM_delay_us(u32 us);
 
 void ODM_sleep_us(u32 us);
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index a4ba79a..a97486e 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -279,7 +279,6 @@ void rtw_usleep_os(int us);
 
 u32  rtw_atoi(u8 *s);
 
-void rtw_mdelay_os(int ms);
 void rtw_udelay_os(int us);
 
 void rtw_yield_os(void);
diff --git a/drivers/staging/rtl8188eu/os_dep/osdep_service.c b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
index bf1cd69..985735b 100644
--- a/drivers/staging/rtl8188eu/os_dep/osdep_service.c
+++ b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
@@ -253,11 +253,6 @@ void rtw_usleep_os(int us)
 		msleep((us/1000) + 1);
 }
 
-void rtw_mdelay_os(int ms)
-{
-	mdelay((unsigned long)ms);
-}
-
 void rtw_udelay_os(int us)
 {
 	udelay((unsigned long)us);
-- 
1.8.4
