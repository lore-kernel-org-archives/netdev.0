From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 3/3] staging: r8712u: Handle some false positives from kmemleak
Date: Fri,  3 Jun 2016 20:17:37 -0500
Message-ID: <1465003057-2590-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1465003057-2590-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:32906 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbcFDBR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 21:17:56 -0400
Received: by mail-oi0-f66.google.com with SMTP id f12so1799464oig.0
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 18:17:55 -0700 (PDT)
In-Reply-To: <1465003057-2590-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When this driver preallocates some URBs, kmemleak is unable to find that
allocated memory when it scans. When the driver is unloaded, that memory
is reclaimed, therefore, the report is a false positive.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8712/xmit_linux.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/staging/rtl8712/xmit_linux.c b/drivers/staging/rtl8712/xmit_linux.c
index 695f9b9..7f52953 100644
--- a/drivers/staging/rtl8712/xmit_linux.c
+++ b/drivers/staging/rtl8712/xmit_linux.c
@@ -31,6 +31,7 @@
 #include <linux/usb.h>
 #include <linux/ip.h>
 #include <linux/if_ether.h>
+#include <linux/kmemleak.h>
 
 #include "osdep_service.h"
 #include "drv_types.h"
@@ -132,6 +133,7 @@ int r8712_xmit_resource_alloc(struct _adapter *padapter,
 			netdev_err(padapter->pnetdev, "pxmitbuf->pxmit_urb[i] == NULL\n");
 			return _FAIL;
 		}
+		kmemleak_not_leak(pxmitbuf->pxmit_urb[i]);
 	}
 	return _SUCCESS;
 }
-- 
2.1.4
