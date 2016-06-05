From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] staging: r8188eu: Fix crash caused by commit 99aded71b52c
Date: Sun,  5 Jun 2016 02:30:56 -0500
Message-ID: <1465111856-4398-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Jacky Boen <aqiank@gmail.com>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:32927 "EHLO
	mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbcFEHbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 03:31:05 -0400
Received: by mail-oi0-f67.google.com with SMTP id f12so5855284oig.0
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 00:31:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 99aded71b52cfdfa22721c42e42efdd13a02f0a6 ("Staging: drivers: rtl8188eu:
use sizeof(*ptr) instead of sizeof(struct)") introduces an error in that the
sizeof(struct hal_data_8188e) is 18712, while the sizeof(*adapt->HalData) is
only 1! As a result, the system panics.

Fixes: 99aded71b52cfdfa22721c42e42efdd13a02f0a6 ("Staging: drivers: rtl8188eu: use sizeof(*ptr) instead of sizeof(struct)")
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Jacky Boen <aqiank@gmail.com>
---
 drivers/staging/rtl8188eu/hal/usb_halinit.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/rtl8188eu/hal/usb_halinit.c b/drivers/staging/rtl8188eu/hal/usb_halinit.c
index 87ea3b8..363f3a3 100644
--- a/drivers/staging/rtl8188eu/hal/usb_halinit.c
+++ b/drivers/staging/rtl8188eu/hal/usb_halinit.c
@@ -2072,7 +2072,8 @@ void rtl8188eu_set_hal_ops(struct adapter *adapt)
 {
 	struct hal_ops	*halfunc = &adapt->HalFunc;
 
-	adapt->HalData = kzalloc(sizeof(*adapt->HalData), GFP_KERNEL);
+
+	adapt->HalData = kzalloc(sizeof(struct hal_data_8188e), GFP_KERNEL);
 	if (!adapt->HalData)
 		DBG_88E("cant not alloc memory for HAL DATA\n");
 
-- 
2.1.4
