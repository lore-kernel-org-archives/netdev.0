From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 16/22] staging: rtl8723bs: Fix some indenting problems and a potential data overrun
Date: Sat,  8 Apr 2017 11:07:39 -0500
Message-ID: <20170408160745.14328-17-Larry.Finger@lwfinger.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, hadess@hadess.net, jes.sorensen@gmail.com,
        Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33333 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752659AbdDHQIQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 12:08:16 -0400
Received: by mail-oi0-f68.google.com with SMTP id t63so1022923oih.0
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 09:08:16 -0700 (PDT)
In-Reply-To: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch reports the following:

  CHECK   drivers/staging/rtl8723bs/core/rtw_wlan_util.c
drivers/staging/rtl8723bs/core/rtw_wlan_util.c:67 cckrates_included() warn: if statement not indented
drivers/staging/rtl8723bs/core/rtw_wlan_util.c:81 cckratesonly_included() warn: if statement not indented
drivers/staging/rtl8723bs/core/rtw_wlan_util.c:815 rtw_camid_alloc() warn: should '1 << (cam_id)' be a 64 bit type?

The first two are fixed with white-space changes. The third is fixed by
restricting cam_id to be less than 32.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8723bs/core/rtw_wlan_util.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/rtl8723bs/core/rtw_wlan_util.c b/drivers/staging/rtl8723bs/core/rtw_wlan_util.c
index c966241df2ea..f485f541e36d 100644
--- a/drivers/staging/rtl8723bs/core/rtw_wlan_util.c
+++ b/drivers/staging/rtl8723bs/core/rtw_wlan_util.c
@@ -65,8 +65,8 @@ int cckrates_included(unsigned char *rate, int ratelen)
 
 	for (i = 0; i < ratelen; i++) {
 		if  ((((rate[i]) & 0x7f) == 2)	|| (((rate[i]) & 0x7f) == 4) ||
-			   (((rate[i]) & 0x7f) == 11)  || (((rate[i]) & 0x7f) == 22))
-		return true;
+		     (((rate[i]) & 0x7f) == 11)  || (((rate[i]) & 0x7f) == 22))
+			return true;
 	}
 
 	return false;
@@ -79,8 +79,8 @@ int cckratesonly_included(unsigned char *rate, int ratelen)
 
 	for (i = 0; i < ratelen; i++) {
 		if  ((((rate[i]) & 0x7f) != 2) && (((rate[i]) & 0x7f) != 4) &&
-			   (((rate[i]) & 0x7f) != 11)  && (((rate[i]) & 0x7f) != 22))
-		return false;
+		     (((rate[i]) & 0x7f) != 11)  && (((rate[i]) & 0x7f) != 22))
+			return false;
 	}
 
 	return true;
@@ -811,7 +811,7 @@ s16 rtw_camid_alloc(struct adapter *adapter, struct sta_info *sta, u8 kid)
 	}
 
 bitmap_handle:
-	if (cam_id >= 0)
+	if (cam_id >= 0 && cam_id < 32)
 		cam_ctl->bitmap |= BIT(cam_id);
 
 	spin_unlock_bh(&cam_ctl->lock);
-- 
2.12.0
