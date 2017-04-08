From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 03/22] staging: rtl8723bs: Fix dereference before check warning in os_dep/recv_linux.c
Date: Sat,  8 Apr 2017 11:07:26 -0500
Message-ID: <20170408160745.14328-4-Larry.Finger@lwfinger.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, hadess@hadess.net, jes.sorensen@gmail.com,
        Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34819 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752520AbdDHQIF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 12:08:05 -0400
Received: by mail-oi0-f66.google.com with SMTP id g204so6268658oib.2
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 09:08:05 -0700 (PDT)
In-Reply-To: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch lists the following warning:

  CHECK   drivers/staging/rtl8723bs/os_dep/recv_linux.c
drivers/staging/rtl8723bs/os_dep/recv_linux.c:353 rtw_recv_indicatepkt() warn: variable dereferenced before check 'precv_frame' (see line 312)

This warning is fixed by removing the test at line 353.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8723bs/os_dep/recv_linux.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/staging/rtl8723bs/os_dep/recv_linux.c b/drivers/staging/rtl8723bs/os_dep/recv_linux.c
index c677a5216b54..e731ab4e2bd7 100644
--- a/drivers/staging/rtl8723bs/os_dep/recv_linux.c
+++ b/drivers/staging/rtl8723bs/os_dep/recv_linux.c
@@ -350,8 +350,7 @@ int rtw_recv_indicatepkt(struct adapter *padapter, union recv_frame *precv_frame
 _recv_indicatepkt_drop:
 
 	 /* enqueue back to free_recv_queue */
-	 if (precv_frame)
-		 rtw_free_recvframe(precv_frame, pfree_recv_queue);
+	 rtw_free_recvframe(precv_frame, pfree_recv_queue);
 
 	 DBG_COUNTER(padapter->rx_logs.os_indicate_err);
 	 return _FAIL;
-- 
2.12.0
