From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] staging: r8188eu: Fix scheduling while atomic splat
Date: Sun,  5 Jun 2016 14:11:19 -0500
Message-ID: <1465153879-18948-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	navin patidar <navin.patidar@gmail.com>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:36784 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654AbcFETL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 15:11:27 -0400
Received: by mail-oi0-f68.google.com with SMTP id n3so5226039oig.3
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 12:11:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit fadbe0cd5292851608e2e01b91d9295fa287b9fe ("staging: rtl8188eu:
Remove rtw_zmalloc(), wrapper for kzalloc()") changed all allocation
calls to be GFP_KERNEL even though the original wrapper was testing
to determine if the caller was in atomic mode. Most of the mistakes
were corrected with commit 33dc85c3c667209c930b2dac5ccbc2a365e06b7a
("staging: r8188eu: Fix scheduling while atomic error introduced in
commit fadbe0cd"); however, two kzalloc calls were missed as the
call only happens when the driver is shutting down.

Fixes: fadbe0cd5292851608e2e01b91d9295fa287b9fe ("staging: rtl8188eu: Remove rtw_zmalloc(), wrapper for kzalloc()")
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: navin patidar <navin.patidar@gmail.com>
---
 drivers/staging/rtl8188eu/core/rtw_cmd.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_cmd.c b/drivers/staging/rtl8188eu/core/rtw_cmd.c
index 7748523..32d3a9c 100644
--- a/drivers/staging/rtl8188eu/core/rtw_cmd.c
+++ b/drivers/staging/rtl8188eu/core/rtw_cmd.c
@@ -670,13 +670,13 @@ u8 rtw_addbareq_cmd(struct adapter *padapter, u8 tid, u8 *addr)
 	u8	res = _SUCCESS;
 
 
-	ph2c = kzalloc(sizeof(struct cmd_obj), GFP_KERNEL);
+	ph2c = kzalloc(sizeof(struct cmd_obj), GFP_ATOMIC);
 	if (!ph2c) {
 		res = _FAIL;
 		goto exit;
 	}
 
-	paddbareq_parm = kzalloc(sizeof(struct addBaReq_parm), GFP_KERNEL);
+	paddbareq_parm = kzalloc(sizeof(struct addBaReq_parm), GFP_ATOMIC);
 	if (!paddbareq_parm) {
 		kfree(ph2c);
 		res = _FAIL;
-- 
2.1.4
