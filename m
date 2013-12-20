From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/2] staging: r8188eu: Restore line that was incorrectly removed
Date: Fri, 20 Dec 2013 14:58:44 -0600
Message-ID: <1387573126-28907-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1387573126-28907-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:53130 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753529Ab3LTU7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 15:59:05 -0500
Received: by mail-pa0-f52.google.com with SMTP id ld10so3138797pab.39
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 12:59:04 -0800 (PST)
In-Reply-To: <1387573126-28907-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A line in the P2P code had been removed in the process of converting the vendor
driver to a form suitable for the kernel. The output of this call was ignored,
and the initial analysis incorrectly determined that the call had no other
effect.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_p2p.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/staging/rtl8188eu/core/rtw_p2p.c b/drivers/staging/rtl8188eu/core/rtw_p2p.c
index 402fd21..6e8c06e 100644
--- a/drivers/staging/rtl8188eu/core/rtw_p2p.c
+++ b/drivers/staging/rtl8188eu/core/rtw_p2p.c
@@ -1496,6 +1496,7 @@ static void find_phase_handler(struct adapter *padapter)
 {
 	struct wifidirect_info  *pwdinfo = &padapter->wdinfo;
 	struct ndis_802_11_ssid	ssid;
+	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 
 _func_enter_;
 
@@ -1505,6 +1506,9 @@ _func_enter_;
 
 	rtw_p2p_set_state(pwdinfo, P2P_STATE_FIND_PHASE_SEARCH);
 
+        spin_lock_bh(&pmlmepriv->lock);
+        rtw_sitesurvey_cmd(padapter, &ssid, 1, NULL, 0);
+        spin_unlock_bh(&pmlmepriv->lock);
 _func_exit_;
 }
 
-- 
1.8.4
