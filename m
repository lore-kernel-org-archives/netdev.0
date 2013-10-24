From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH NEXT 3/5] staging: r8188eu: Fix sparse warnings in rtl8188e.cmd.c
Date: Wed, 23 Oct 2013 22:31:35 -0500
Message-ID: <1382585497-6787-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1382585497-6787-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:46403 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148Ab3JXDb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 23:31:56 -0400
Received: by mail-oa0-f50.google.com with SMTP id j6so1203720oag.9
        for <netdev@vger.kernel.org>; Wed, 23 Oct 2013 20:31:55 -0700 (PDT)
In-Reply-To: <1382585497-6787-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparse displays the following:

  CHECK   drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:285:15: warning: incorrect type in assignment (different base types)
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:285:15:    expected unsigned short [usertype] *fctrl
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:285:15:    got restricted __le16 *<noident>
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:368:15: warning: incorrect type in assignment (different base types)
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:368:15:    expected unsigned short [usertype] *fctrl
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:368:15:    got restricted __le16 *<noident>
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:403:15: warning: incorrect type in assignment (different base types)
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:403:15:    expected unsigned short [usertype] *fctrl
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:403:15:    got restricted __le16 *<noident>
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:465:15: warning: incorrect type in assignment (different base types)
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:465:15:    expected unsigned short [usertype] *fctrl
drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c:465:15:    got restricted __le16 *<noident>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c b/drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c
index 0b0c68c..8be2ad7 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c
@@ -273,7 +273,7 @@ void rtl8188e_set_FwMediaStatus_cmd(struct adapter *adapt, __le16 mstatus_rpt)
 static void ConstructBeacon(struct adapter *adapt, u8 *pframe, u32 *pLength)
 {
 	struct rtw_ieee80211_hdr	*pwlanhdr;
-	u16 *fctrl;
+	__le16 *fctrl;
 	u32 rate_len, pktlen;
 	struct mlme_ext_priv *pmlmeext = &(adapt->mlmeextpriv);
 	struct mlme_ext_info	*pmlmeinfo = &(pmlmeext->mlmext_info);
@@ -360,7 +360,7 @@ static void ConstructPSPoll(struct adapter *adapt, u8 *pframe, u32 *pLength)
 	struct rtw_ieee80211_hdr	*pwlanhdr;
 	struct mlme_ext_priv *pmlmeext = &(adapt->mlmeextpriv);
 	struct mlme_ext_info	*pmlmeinfo = &(pmlmeext->mlmext_info);
-	u16 *fctrl;
+	__le16 *fctrl;
 
 	pwlanhdr = (struct rtw_ieee80211_hdr *)pframe;
 
@@ -391,7 +391,7 @@ static void ConstructNullFunctionData(struct adapter *adapt, u8 *pframe,
 	u8 bForcePowerSave)
 {
 	struct rtw_ieee80211_hdr	*pwlanhdr;
-	u16 *fctrl;
+	__le16 *fctrl;
 	u32 pktlen;
 	struct mlme_priv *pmlmepriv = &adapt->mlmepriv;
 	struct wlan_network		*cur_network = &pmlmepriv->cur_network;
@@ -450,7 +450,7 @@ static void ConstructNullFunctionData(struct adapter *adapt, u8 *pframe,
 static void ConstructProbeRsp(struct adapter *adapt, u8 *pframe, u32 *pLength, u8 *StaAddr, bool bHideSSID)
 {
 	struct rtw_ieee80211_hdr	*pwlanhdr;
-	u16 *fctrl;
+	__le16 *fctrl;
 	u8 *mac, *bssid;
 	u32 pktlen;
 	struct mlme_ext_priv *pmlmeext = &(adapt->mlmeextpriv);
-- 
1.8.4
