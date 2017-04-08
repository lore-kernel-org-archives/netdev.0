From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 12/22] staging: rtl8723bs: Fix possible usage of NULL pointer in core/rtw_debug.c
Date: Sat,  8 Apr 2017 11:07:35 -0500
Message-ID: <20170408160745.14328-13-Larry.Finger@lwfinger.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, hadess@hadess.net, jes.sorensen@gmail.com,
        Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34168 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752598AbdDHQIM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 12:08:12 -0400
Received: by mail-oi0-f65.google.com with SMTP id w197so6121484oiw.1
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 09:08:12 -0700 (PDT)
In-Reply-To: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch reports the following:

  CHECK   drivers/staging/rtl8723bs/core/rtw_debug.c
drivers/staging/rtl8723bs/core/rtw_debug.c:454 proc_get_survey_info() error: we previously assumed 'phead' could be null (see line 453)
drivers/staging/rtl8723bs/core/rtw_debug.c:455 proc_get_survey_info() warn: variable dereferenced before check 'phead' (see line 454)

In the code, there are two successive calls to get_head(). The second
is removed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8723bs/core/rtw_debug.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/staging/rtl8723bs/core/rtw_debug.c b/drivers/staging/rtl8723bs/core/rtw_debug.c
index d34747b29309..51cef55d3f76 100644
--- a/drivers/staging/rtl8723bs/core/rtw_debug.c
+++ b/drivers/staging/rtl8723bs/core/rtw_debug.c
@@ -451,7 +451,6 @@ int proc_get_survey_info(struct seq_file *m, void *v)
 	spin_lock_bh(&(pmlmepriv->scanned_queue.lock));
 	phead = get_list_head(queue);
 	plist = phead ? get_next(phead) : NULL;
-	plist = get_next(phead);
 	if ((!phead) || (!plist)) {
 		spin_unlock_bh(&(pmlmepriv->scanned_queue.lock));
 		return 0;
-- 
2.12.0
