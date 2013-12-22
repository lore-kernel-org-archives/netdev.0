From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 24/31] staging: r8188eu: Additional cleanup of include/odm.h
Date: Sun, 22 Dec 2013 17:36:55 -0600
Message-ID: <1387755422-11443-25-git-send-email-Larry.Finger@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:55714 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756902Ab3LVXiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:38:46 -0500
Received: by mail-pa0-f54.google.com with SMTP id rd3so4707322pab.13
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 15:38:45 -0800 (PST)
In-Reply-To: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver only works with the USB bus. Accordingly, enum odm_interface_def
can be removed along with all code that uses ODM_ITRF_XXX, where XXX is not USB.

In enum odm_ic_type, only ODM_RTL8188E is used. Remove the enum, all references
to the others, and define the needed value.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/odm.c               | 12 +-------
 drivers/staging/rtl8188eu/hal/odm_HWConfig.c      | 35 +++++++++++------------
 drivers/staging/rtl8188eu/hal/rtl8188e_dm.c       |  5 +---
 drivers/staging/rtl8188eu/include/odm.h           | 24 +---------------
 drivers/staging/rtl8188eu/include/odm_interface.h |  2 +-
 5 files changed, 20 insertions(+), 58 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/odm.c b/drivers/staging/rtl8188eu/hal/odm.c
index c73df3b..3555ffa 100644
--- a/drivers/staging/rtl8188eu/hal/odm.c
+++ b/drivers/staging/rtl8188eu/hal/odm.c
@@ -206,18 +206,8 @@ void ODM_DMWatchdog(struct odm_dm_struct *pDM_Odm)
 	odm_FalseAlarmCounterStatistics(pDM_Odm);
 	odm_RSSIMonitorCheck(pDM_Odm);
 
-	/* For CE Platform(SPRD or Tablet) */
-	/* 8723A or 8189ES platform */
-	/* NeilChen--2012--08--24-- */
 	/* Fix Leave LPS issue */
-	if ((pDM_Odm->Adapter->pwrctrlpriv.pwr_mode != PS_MODE_ACTIVE) &&/*  in LPS mode */
-	    (pDM_Odm->SupportInterface  == ODM_ITRF_SDIO)) {
-		ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("----Step1: odm_DIG is in LPS mode\n"));
-		ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("---Step2: 8723AS is in LPS mode\n"));
-		odm_DIGbyRSSI_LPS(pDM_Odm);
-	} else {
-		odm_DIG(pDM_Odm);
-	}
+	odm_DIG(pDM_Odm);
 	odm_CCKPacketDetectionThresh(pDM_Odm);
 
 	if (*(pDM_Odm->pbPowerSaving))
diff --git a/drivers/staging/rtl8188eu/hal/odm_HWConfig.c b/drivers/staging/rtl8188eu/hal/odm_HWConfig.c
index 42f07ce..a452c7d 100644
--- a/drivers/staging/rtl8188eu/hal/odm_HWConfig.c
+++ b/drivers/staging/rtl8188eu/hal/odm_HWConfig.c
@@ -43,25 +43,22 @@ static s32 odm_SignalScaleMapping_92CSeries(struct odm_dm_struct *dm_odm, s32 Cu
 {
 	s32 RetSig = 0;
 
-	if ((dm_odm->SupportInterface  == ODM_ITRF_USB) ||
-	    (dm_odm->SupportInterface  == ODM_ITRF_SDIO)) {
-		if (CurrSig >= 51 && CurrSig <= 100)
-			RetSig = 100;
-		else if (CurrSig >= 41 && CurrSig <= 50)
-			RetSig = 80 + ((CurrSig - 40)*2);
-		else if (CurrSig >= 31 && CurrSig <= 40)
-			RetSig = 66 + (CurrSig - 30);
-		else if (CurrSig >= 21 && CurrSig <= 30)
-			RetSig = 54 + (CurrSig - 20);
-		else if (CurrSig >= 10 && CurrSig <= 20)
-			RetSig = 42 + (((CurrSig - 10) * 2) / 3);
-		else if (CurrSig >= 5 && CurrSig <= 9)
-			RetSig = 22 + (((CurrSig - 5) * 3) / 2);
-		else if (CurrSig >= 1 && CurrSig <= 4)
-			RetSig = 6 + (((CurrSig - 1) * 3) / 2);
-		else
-			RetSig = CurrSig;
-	}
+	if (CurrSig >= 51 && CurrSig <= 100)
+		RetSig = 100;
+	else if (CurrSig >= 41 && CurrSig <= 50)
+		RetSig = 80 + ((CurrSig - 40)*2);
+	else if (CurrSig >= 31 && CurrSig <= 40)
+		RetSig = 66 + (CurrSig - 30);
+	else if (CurrSig >= 21 && CurrSig <= 30)
+		RetSig = 54 + (CurrSig - 20);
+	else if (CurrSig >= 10 && CurrSig <= 20)
+		RetSig = 42 + (((CurrSig - 10) * 2) / 3);
+	else if (CurrSig >= 5 && CurrSig <= 9)
+		RetSig = 22 + (((CurrSig - 5) * 3) / 2);
+	else if (CurrSig >= 1 && CurrSig <= 4)
+		RetSig = 6 + (((CurrSig - 1) * 3) / 2);
+	else
+		RetSig = CurrSig;
 	return RetSig;
 }
 
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_dm.c b/drivers/staging/rtl8188eu/hal/rtl8188e_dm.c
index ec0028d..1e7c926 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_dm.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_dm.c
@@ -63,10 +63,7 @@ static void Init_ODM_ComInfo_88E(struct adapter *Adapter)
 
 	ODM_CmnInfoInit(dm_odm, ODM_CMNINFO_PLATFORM, ODM_CE);
 
-	if (Adapter->interface_type == RTW_GSPI)
-		ODM_CmnInfoInit(dm_odm, ODM_CMNINFO_INTERFACE, ODM_ITRF_SDIO);
-	else
-		ODM_CmnInfoInit(dm_odm, ODM_CMNINFO_INTERFACE, Adapter->interface_type);/* RTL871X_HCI_TYPE */
+	ODM_CmnInfoInit(dm_odm, ODM_CMNINFO_INTERFACE, Adapter->interface_type);/* RTL871X_HCI_TYPE */
 
 	ODM_CmnInfoInit(dm_odm, ODM_CMNINFO_IC_TYPE, ODM_RTL8188E);
 
diff --git a/drivers/staging/rtl8188eu/include/odm.h b/drivers/staging/rtl8188eu/include/odm.h
index 8e15847..cc5d0b2 100644
--- a/drivers/staging/rtl8188eu/include/odm.h
+++ b/drivers/staging/rtl8188eu/include/odm.h
@@ -454,29 +454,7 @@ enum odm_ability_def {
 	ODM_RF_CALIBRATION		= BIT26,
 };
 
-/* 	ODM_CMNINFO_INTERFACE */
-enum odm_interface_def {
-	ODM_ITRF_PCIE	=	0x1,
-	ODM_ITRF_USB	=	0x2,
-	ODM_ITRF_SDIO	=	0x4,
-	ODM_ITRF_ALL	=	0x7,
-};
-
-/*  ODM_CMNINFO_IC_TYPE */
-enum odm_ic_type {
-	ODM_RTL8192S	=	BIT0,
-	ODM_RTL8192C	=	BIT1,
-	ODM_RTL8192D	=	BIT2,
-	ODM_RTL8723A	=	BIT3,
-	ODM_RTL8188E	=	BIT4,
-	ODM_RTL8812	=	BIT5,
-	ODM_RTL8821	=	BIT6,
-};
-
-#define ODM_IC_11N_SERIES						\
-	(ODM_RTL8192S | ODM_RTL8192C | ODM_RTL8192D |			\
-	 ODM_RTL8723A | ODM_RTL8188E)
-#define ODM_IC_11AC_SERIES		(ODM_RTL8812)
+#define ODM_RTL8188E		BIT4
 
 /* ODM_CMNINFO_CUT_VER */
 enum odm_cut_version {
diff --git a/drivers/staging/rtl8188eu/include/odm_interface.h b/drivers/staging/rtl8188eu/include/odm_interface.h
index 7cefb97..22f451e 100644
--- a/drivers/staging/rtl8188eu/include/odm_interface.h
+++ b/drivers/staging/rtl8188eu/include/odm_interface.h
@@ -51,7 +51,7 @@ ODM_REG(DIG,_pDM_Odm)
 
 #define _cat(_name, _ic_type, _func)					\
 	(								\
-		((_ic_type) & ODM_IC_11N_SERIES) ? _func##_11N(_name) :	\
+		(_ic_type) ? _func##_11N(_name) :			\
 		_func##_11AC(_name)					\
 	)
 
-- 
1.8.4
