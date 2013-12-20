From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 01/11] staging: r8188eu: Remove pointless thread_exit macro
Date: Thu, 19 Dec 2013 22:38:33 -0600
Message-ID: <1387514323-4486-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:46784 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895Ab3LTEjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 23:39:41 -0500
Received: by mail-pa0-f41.google.com with SMTP id lf10so2135319pab.0
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 20:39:41 -0800 (PST)
In-Reply-To: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_cmd.c          | 2 +-
 drivers/staging/rtl8188eu/core/rtw_mp.c           | 2 +-
 drivers/staging/rtl8188eu/include/osdep_service.h | 2 --
 3 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_cmd.c b/drivers/staging/rtl8188eu/core/rtw_cmd.c
index f45f4ed..3e2d980 100644
--- a/drivers/staging/rtl8188eu/core/rtw_cmd.c
+++ b/drivers/staging/rtl8188eu/core/rtw_cmd.c
@@ -420,7 +420,7 @@ post_process:
 
 _func_exit_;
 
-	thread_exit();
+	complete_and_exit(NULL, 0);
 }
 
 u8 rtw_setstandby_cmd(struct adapter *padapter, uint action)
diff --git a/drivers/staging/rtl8188eu/core/rtw_mp.c b/drivers/staging/rtl8188eu/core/rtw_mp.c
index 9832dcb..0204639 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mp.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mp.c
@@ -643,7 +643,7 @@ exit:
 	pmptx->pallocated_buf = NULL;
 	pmptx->stop = 1;
 
-	thread_exit();
+	complete_and_exit(NULL, 0);
 }
 
 void fill_txdesc_for_mp(struct adapter *padapter, struct tx_desc *ptxdesc)
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index 46b34fc..ba790f0 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -62,8 +62,6 @@ struct	__queue	{
 	spinlock_t lock;
 };
 
-#define thread_exit() complete_and_exit(NULL, 0)
-
 static inline struct list_head *get_next(struct list_head *list)
 {
 	return list->next;
-- 
1.8.4
