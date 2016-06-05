From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] staging: r8188eu: Remove some false positives from kmemleak
Date: Sun,  5 Jun 2016 10:20:59 -0500
Message-ID: <1465140059-20189-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33475 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbcFEPVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 11:21:06 -0400
Received: by mail-oi0-f65.google.com with SMTP id f12so6811118oig.0
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 08:21:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When this driver preallocates some SKBs, kmemleak is unable to find that
allocated memory when it scans. When the driver is unloaded, that memory
is released; therefore, the report is a false positive.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/rtl8188eu_recv.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/staging/rtl8188eu/hal/rtl8188eu_recv.c b/drivers/staging/rtl8188eu/hal/rtl8188eu_recv.c
index 255d6f2..093a998 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188eu_recv.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188eu_recv.c
@@ -13,6 +13,7 @@
  *
  ******************************************************************************/
 #define _RTL8188EU_RECV_C_
+#include <linux/kmemleak.h>
 #include <osdep_service.h>
 #include <drv_types.h>
 #include <recv_osdep.h>
@@ -72,6 +73,7 @@ int	rtl8188eu_init_recv_priv(struct adapter *padapter)
 					MAX_RECVBUF_SZ + RECVBUFF_ALIGN_SZ,
 					GFP_KERNEL);
 			if (pskb) {
+				kmemleak_not_leak(pskb);
 				pskb->dev = padapter->pnetdev;
 				tmpaddr = (size_t)pskb->data;
 				alignm = tmpaddr & (RECVBUFF_ALIGN_SZ-1);
-- 
2.1.4
