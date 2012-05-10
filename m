From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 3/3] staging: delete all duplicated endian crap from rtl8712 driver
Date: Wed,  9 May 2012 23:47:21 -0400
Message-ID: <1336621641-15467-4-git-send-email-paul.gortmaker@windriver.com>
References: <1336621641-15467-1-git-send-email-paul.gortmaker@windriver.com>
Cc: florian.c.schilhabel@googlemail.com, ali@internetdog.org,
	netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63203 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755807Ab2EJDsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 23:48:10 -0400
In-Reply-To: <1336621641-15467-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver had headers like big_endian.h, little_endian.h, swab.h
and yet we can throw them all in the trash can and the thing
still builds on x86-64 and ppc, just by deleting the references
to the deleted files.

Cc: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/staging/rtl8712/big_endian.h        |   94 --------------
 drivers/staging/rtl8712/generic.h           |  178 ---------------------------
 drivers/staging/rtl8712/hal_init.c          |    1 -
 drivers/staging/rtl8712/little_endian.h     |   94 --------------
 drivers/staging/rtl8712/osdep_service.h     |    2 -
 drivers/staging/rtl8712/rtl8712_cmd.c       |    1 -
 drivers/staging/rtl8712/rtl8712_xmit.c      |    1 -
 drivers/staging/rtl8712/rtl871x_byteorder.h |   32 -----
 drivers/staging/rtl8712/rtl871x_cmd.c       |    1 -
 drivers/staging/rtl8712/rtl871x_xmit.c      |    1 -
 drivers/staging/rtl8712/swab.h              |  131 --------------------
 drivers/staging/rtl8712/usb_ops.c           |    1 -
 drivers/staging/rtl8712/wifi.h              |    1 -
 drivers/staging/rtl8712/xmit_linux.c        |    1 -
 14 files changed, 0 insertions(+), 539 deletions(-)
 delete mode 100644 drivers/staging/rtl8712/big_endian.h
 delete mode 100644 drivers/staging/rtl8712/generic.h
 delete mode 100644 drivers/staging/rtl8712/little_endian.h
 delete mode 100644 drivers/staging/rtl8712/rtl871x_byteorder.h
 delete mode 100644 drivers/staging/rtl8712/swab.h

diff --git a/drivers/staging/rtl8712/big_endian.h b/drivers/staging/rtl8712/big_endian.h
deleted file mode 100644
index b16f8ec..0000000
diff --git a/drivers/staging/rtl8712/generic.h b/drivers/staging/rtl8712/generic.h
deleted file mode 100644
index 8868c9f..0000000
diff --git a/drivers/staging/rtl8712/hal_init.c b/drivers/staging/rtl8712/hal_init.c
index cc893c0..cb9d4cf 100644
--- a/drivers/staging/rtl8712/hal_init.c
+++ b/drivers/staging/rtl8712/hal_init.c
@@ -36,7 +36,6 @@
 
 #include "osdep_service.h"
 #include "drv_types.h"
-#include "rtl871x_byteorder.h"
 #include "usb_osintf.h"
 
 #define FWBUFF_ALIGN_SZ 512
diff --git a/drivers/staging/rtl8712/little_endian.h b/drivers/staging/rtl8712/little_endian.h
deleted file mode 100644
index cd57d6c..0000000
diff --git a/drivers/staging/rtl8712/osdep_service.h b/drivers/staging/rtl8712/osdep_service.h
index cabf774..f1ccc7e 100644
--- a/drivers/staging/rtl8712/osdep_service.h
+++ b/drivers/staging/rtl8712/osdep_service.h
@@ -106,8 +106,6 @@ static inline void _set_workitem(_workitem *pwork)
 	schedule_work(pwork);
 }
 
-#include "rtl871x_byteorder.h"
-
 #ifndef BIT
 	#define BIT(x)	(1 << (x))
 #endif
diff --git a/drivers/staging/rtl8712/rtl8712_cmd.c b/drivers/staging/rtl8712/rtl8712_cmd.c
index 9f6ebc4..b518505 100644
--- a/drivers/staging/rtl8712/rtl8712_cmd.c
+++ b/drivers/staging/rtl8712/rtl8712_cmd.c
@@ -50,7 +50,6 @@
 #include "drv_types.h"
 #include "recv_osdep.h"
 #include "mlme_osdep.h"
-#include "rtl871x_byteorder.h"
 #include "rtl871x_ioctl_set.h"
 
 static void check_hw_pbc(struct _adapter *padapter)
diff --git a/drivers/staging/rtl8712/rtl8712_xmit.c b/drivers/staging/rtl8712/rtl8712_xmit.c
index 6933319..3d23514 100644
--- a/drivers/staging/rtl8712/rtl8712_xmit.c
+++ b/drivers/staging/rtl8712/rtl8712_xmit.c
@@ -30,7 +30,6 @@
 
 #include "osdep_service.h"
 #include "drv_types.h"
-#include "rtl871x_byteorder.h"
 #include "wifi.h"
 #include "osdep_intf.h"
 #include "usb_ops.h"
diff --git a/drivers/staging/rtl8712/rtl871x_byteorder.h b/drivers/staging/rtl8712/rtl871x_byteorder.h
deleted file mode 100644
index bd3703b..0000000
diff --git a/drivers/staging/rtl8712/rtl871x_cmd.c b/drivers/staging/rtl8712/rtl871x_cmd.c
index d77388b..659683e 100644
--- a/drivers/staging/rtl8712/rtl871x_cmd.c
+++ b/drivers/staging/rtl8712/rtl871x_cmd.c
@@ -50,7 +50,6 @@
 #include "drv_types.h"
 #include "recv_osdep.h"
 #include "mlme_osdep.h"
-#include "rtl871x_byteorder.h"
 
 /*
 Caller and the r8712_cmd_thread can protect cmd_q by spin_lock.
diff --git a/drivers/staging/rtl8712/rtl871x_xmit.c b/drivers/staging/rtl8712/rtl871x_xmit.c
index aa57e77..1d3f8b7 100644
--- a/drivers/staging/rtl8712/rtl871x_xmit.c
+++ b/drivers/staging/rtl8712/rtl871x_xmit.c
@@ -30,7 +30,6 @@
 
 #include "osdep_service.h"
 #include "drv_types.h"
-#include "rtl871x_byteorder.h"
 #include "wifi.h"
 #include "osdep_intf.h"
 #include "usb_ops.h"
diff --git a/drivers/staging/rtl8712/swab.h b/drivers/staging/rtl8712/swab.h
deleted file mode 100644
index f127818..0000000
diff --git a/drivers/staging/rtl8712/usb_ops.c b/drivers/staging/rtl8712/usb_ops.c
index 5a8b0eb..c03508d 100644
--- a/drivers/staging/rtl8712/usb_ops.c
+++ b/drivers/staging/rtl8712/usb_ops.c
@@ -33,7 +33,6 @@
 #include "osdep_intf.h"
 #include "usb_ops.h"
 #include "recv_osdep.h"
-#include "rtl871x_byteorder.h"
 
 static u8 usb_read8(struct intf_hdl *pintfhdl, u32 addr)
 {
diff --git a/drivers/staging/rtl8712/wifi.h b/drivers/staging/rtl8712/wifi.h
index 277398c..793443e 100644
--- a/drivers/staging/rtl8712/wifi.h
+++ b/drivers/staging/rtl8712/wifi.h
@@ -26,7 +26,6 @@
 #ifndef _WIFI_H_
 #define _WIFI_H_
 
-#include "rtl871x_byteorder.h"
 #include <linux/compiler.h>
 
 #ifdef BIT
diff --git a/drivers/staging/rtl8712/xmit_linux.c b/drivers/staging/rtl8712/xmit_linux.c
index c6943c5..65542cb 100644
--- a/drivers/staging/rtl8712/xmit_linux.c
+++ b/drivers/staging/rtl8712/xmit_linux.c
@@ -35,7 +35,6 @@
 #include "osdep_service.h"
 #include "drv_types.h"
 
-#include "rtl871x_byteorder.h"
 #include "wifi.h"
 #include "mlme_osdep.h"
 #include "xmit_osdep.h"
-- 
1.7.9.1
