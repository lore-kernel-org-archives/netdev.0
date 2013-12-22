From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 16/31] staging: r8188eu: Remove macro ODM_SetMACReg
Date: Sun, 22 Dec 2013 17:36:47 -0600
Message-ID: <1387755422-11443-17-git-send-email-Larry.Finger@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:50401 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756807Ab3LVXiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:38:14 -0500
Received: by mail-pa0-f54.google.com with SMTP id rd3so4707090pab.13
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 15:38:14 -0800 (PST)
In-Reply-To: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the same as macro PHY_SetBBReg.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/odm_RTL8188E.c      | 14 +++++++-------
 drivers/staging/rtl8188eu/hal/odm_interface.c     |  6 ------
 drivers/staging/rtl8188eu/include/odm_interface.h |  3 ---
 3 files changed, 7 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/odm_RTL8188E.c b/drivers/staging/rtl8188eu/hal/odm_RTL8188E.c
index 29c4780..1f0d3cf 100644
--- a/drivers/staging/rtl8188eu/hal/odm_RTL8188E.c
+++ b/drivers/staging/rtl8188eu/hal/odm_RTL8188E.c
@@ -47,7 +47,7 @@ static void odm_RX_HWAntDivInit(struct odm_dm_struct *dm_odm)
 
 	/* MAC Setting */
 	value32 = ODM_GetMACReg(dm_odm, ODM_REG_ANTSEL_PIN_11N, bMaskDWord);
-	ODM_SetMACReg(dm_odm, ODM_REG_ANTSEL_PIN_11N, bMaskDWord, value32|(BIT23|BIT25)); /* Reg4C[25]=1, Reg4C[23]=1 for pin output */
+	PHY_SetBBReg(adapter, ODM_REG_ANTSEL_PIN_11N, bMaskDWord, value32|(BIT23|BIT25)); /* Reg4C[25]=1, Reg4C[23]=1 for pin output */
 	/* Pin Settings */
 	PHY_SetBBReg(adapter, ODM_REG_PIN_CTRL_11N, BIT9|BIT8, 0);/* Reg870[8]=1'b0, Reg870[9]=1'b0	antsel antselb by HW */
 	PHY_SetBBReg(adapter, ODM_REG_RX_ANT_CTRL_11N, BIT10, 0);	/* Reg864[10]=1'b0	antsel2 by HW */
@@ -77,7 +77,7 @@ static void odm_TRX_HWAntDivInit(struct odm_dm_struct *dm_odm)
 
 	/* MAC Setting */
 	value32 = ODM_GetMACReg(dm_odm, ODM_REG_ANTSEL_PIN_11N, bMaskDWord);
-	ODM_SetMACReg(dm_odm, ODM_REG_ANTSEL_PIN_11N, bMaskDWord, value32|(BIT23|BIT25)); /* Reg4C[25]=1, Reg4C[23]=1 for pin output */
+	PHY_SetBBReg(adapter, ODM_REG_ANTSEL_PIN_11N, bMaskDWord, value32|(BIT23|BIT25)); /* Reg4C[25]=1, Reg4C[23]=1 for pin output */
 	/* Pin Settings */
 	PHY_SetBBReg(adapter, ODM_REG_PIN_CTRL_11N, BIT9|BIT8, 0);/* Reg870[8]=1'b0, Reg870[9]=1'b0		antsel antselb by HW */
 	PHY_SetBBReg(adapter, ODM_REG_RX_ANT_CTRL_11N, BIT10, 0);	/* Reg864[10]=1'b0	antsel2 by HW */
@@ -126,13 +126,13 @@ static void odm_FastAntTrainingInit(struct odm_dm_struct *dm_odm)
 
 	/* MAC Setting */
 	value32 = ODM_GetMACReg(dm_odm, 0x4c, bMaskDWord);
-	ODM_SetMACReg(dm_odm, 0x4c, bMaskDWord, value32|(BIT23|BIT25)); /* Reg4C[25]=1, Reg4C[23]=1 for pin output */
+	PHY_SetBBReg(adapter, 0x4c, bMaskDWord, value32|(BIT23|BIT25)); /* Reg4C[25]=1, Reg4C[23]=1 for pin output */
 	value32 = ODM_GetMACReg(dm_odm,  0x7B4, bMaskDWord);
-	ODM_SetMACReg(dm_odm, 0x7b4, bMaskDWord, value32|(BIT16|BIT17)); /* Reg7B4[16]=1 enable antenna training, Reg7B4[17]=1 enable A2 match */
+	PHY_SetBBReg(adapter, 0x7b4, bMaskDWord, value32|(BIT16|BIT17)); /* Reg7B4[16]=1 enable antenna training, Reg7B4[17]=1 enable A2 match */
 
 	/* Match MAC ADDR */
-	ODM_SetMACReg(dm_odm, 0x7b4, 0xFFFF, 0);
-	ODM_SetMACReg(dm_odm, 0x7b0, bMaskDWord, 0);
+	PHY_SetBBReg(adapter, 0x7b4, 0xFFFF, 0);
+	PHY_SetBBReg(adapter, 0x7b0, bMaskDWord, 0);
 
 	PHY_SetBBReg(adapter, 0x870, BIT9|BIT8, 0);/* Reg870[8]=1'b0, Reg870[9]=1'b0		antsel antselb by HW */
 	PHY_SetBBReg(adapter, 0x864, BIT10, 0);	/* Reg864[10]=1'b0	antsel2 by HW */
@@ -218,7 +218,7 @@ void ODM_UpdateRxIdleAnt_88E(struct odm_dm_struct *dm_odm, u8 Ant)
 			PHY_SetBBReg(adapter, ODM_REG_RX_ANT_CTRL_11N, BIT5|BIT4|BIT3, DefaultAnt);	/* Default RX */
 			PHY_SetBBReg(adapter, ODM_REG_RX_ANT_CTRL_11N, BIT8|BIT7|BIT6, OptionalAnt);		/* Optional RX */
 			PHY_SetBBReg(adapter, ODM_REG_ANTSEL_CTRL_11N, BIT14|BIT13|BIT12, DefaultAnt);	/* Default TX */
-			ODM_SetMACReg(dm_odm, ODM_REG_RESP_TX_11N, BIT6|BIT7, DefaultAnt);	/* Resp Tx */
+			PHY_SetBBReg(adapter, ODM_REG_RESP_TX_11N, BIT6|BIT7, DefaultAnt);	/* Resp Tx */
 		} else if (dm_odm->AntDivType == CGCS_RX_HW_ANTDIV) {
 			PHY_SetBBReg(adapter, ODM_REG_RX_ANT_CTRL_11N, BIT5|BIT4|BIT3, DefaultAnt);	/* Default RX */
 			PHY_SetBBReg(adapter, ODM_REG_RX_ANT_CTRL_11N, BIT8|BIT7|BIT6, OptionalAnt);		/* Optional RX */
diff --git a/drivers/staging/rtl8188eu/hal/odm_interface.c b/drivers/staging/rtl8188eu/hal/odm_interface.c
index 0782bef..715becb 100644
--- a/drivers/staging/rtl8188eu/hal/odm_interface.c
+++ b/drivers/staging/rtl8188eu/hal/odm_interface.c
@@ -57,12 +57,6 @@ void ODM_Write4Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 Data)
 	rtw_write32(Adapter, RegAddr, Data);
 }
 
-void ODM_SetMACReg(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 BitMask, u32 Data)
-{
-	struct adapter *Adapter = pDM_Odm->Adapter;
-	PHY_SetBBReg(Adapter, RegAddr, BitMask, Data);
-}
-
 u32 ODM_GetMACReg(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 BitMask)
 {
 	struct adapter *Adapter = pDM_Odm->Adapter;
diff --git a/drivers/staging/rtl8188eu/include/odm_interface.h b/drivers/staging/rtl8188eu/include/odm_interface.h
index e2d3e78..073879a 100644
--- a/drivers/staging/rtl8188eu/include/odm_interface.h
+++ b/drivers/staging/rtl8188eu/include/odm_interface.h
@@ -89,9 +89,6 @@ void ODM_Write2Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u16 Data);
 
 void ODM_Write4Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 Data);
 
-void ODM_SetMACReg(struct odm_dm_struct *pDM_Odm, u32 RegAddr,
-		   u32 BitMask, u32 Data);
-
 u32 ODM_GetMACReg(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 BitMask);
 
 /*  Memory Relative Function. */
-- 
1.8.4
