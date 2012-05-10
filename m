From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 1/3] staging: wean rtl8712 off of its ancient duplicate of if_ether.h
Date: Wed,  9 May 2012 23:47:19 -0400
Message-ID: <1336621641-15467-2-git-send-email-paul.gortmaker@windriver.com>
References: <1336621641-15467-1-git-send-email-paul.gortmaker@windriver.com>
Cc: florian.c.schilhabel@googlemail.com, ali@internetdog.org,
	netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63166 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755807Ab2EJDsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 23:48:01 -0400
In-Reply-To: <1336621641-15467-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver should not be carrying around ancient copies of
headers like <linux/if_ether.h> for its own use.  Mapping it
onto the mainline one uncovers no build issues.

Cc: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/staging/rtl8712/if_ether.h     |  141 --------------------------------
 drivers/staging/rtl8712/rtl8712_recv.c |    3 +-
 drivers/staging/rtl8712/rtl871x_recv.c |    2 +-
 drivers/staging/rtl8712/xmit_linux.c   |    2 +-
 4 files changed, 4 insertions(+), 144 deletions(-)
 delete mode 100644 drivers/staging/rtl8712/if_ether.h

diff --git a/drivers/staging/rtl8712/if_ether.h b/drivers/staging/rtl8712/if_ether.h
deleted file mode 100644
index 2bbe527..0000000
diff --git a/drivers/staging/rtl8712/rtl8712_recv.c b/drivers/staging/rtl8712/rtl8712_recv.c
index fa6dc9c..b2a7714 100644
--- a/drivers/staging/rtl8712/rtl8712_recv.c
+++ b/drivers/staging/rtl8712/rtl8712_recv.c
@@ -28,12 +28,13 @@
 
 #define _RTL8712_RECV_C_
 
+#include <linux/if_ether.h>
+
 #include "osdep_service.h"
 #include "drv_types.h"
 #include "recv_osdep.h"
 #include "mlme_osdep.h"
 #include "ip.h"
-#include "if_ether.h"
 #include "ethernet.h"
 #include "usb_ops.h"
 #include "wifi.h"
diff --git a/drivers/staging/rtl8712/rtl871x_recv.c b/drivers/staging/rtl8712/rtl871x_recv.c
index 5b03b40..7376abb 100644
--- a/drivers/staging/rtl8712/rtl871x_recv.c
+++ b/drivers/staging/rtl8712/rtl871x_recv.c
@@ -29,6 +29,7 @@
 #define _RTL871X_RECV_C_
 
 #include <linux/slab.h>
+#include <linux/if_ether.h>
 #include <linux/kmemleak.h>
 
 #include "osdep_service.h"
@@ -36,7 +37,6 @@
 #include "recv_osdep.h"
 #include "mlme_osdep.h"
 #include "ip.h"
-#include "if_ether.h"
 #include "ethernet.h"
 #include "usb_ops.h"
 #include "wifi.h"
diff --git a/drivers/staging/rtl8712/xmit_linux.c b/drivers/staging/rtl8712/xmit_linux.c
index c970362..d27f652 100644
--- a/drivers/staging/rtl8712/xmit_linux.c
+++ b/drivers/staging/rtl8712/xmit_linux.c
@@ -29,12 +29,12 @@
 #define _XMIT_OSDEP_C_
 
 #include <linux/usb.h>
+#include <linux/if_ether.h>
 
 #include "osdep_service.h"
 #include "drv_types.h"
 
 
-#include "if_ether.h"
 #include "ip.h"
 #include "rtl871x_byteorder.h"
 #include "wifi.h"
-- 
1.7.9.1
