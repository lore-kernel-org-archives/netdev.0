From: Tomas Winkler <tomas.winkler@intel.com>
Subject: [PATCH] imwc3200: move iwmc3200 SDIO ids to sdio_ids.h
Date: Tue, 14 Jul 2009 01:09:13 +0300
Message-ID: <1247522953-12702-1-git-send-email-tomas.winkler@intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tomas Winkler <tomas.winkler@intel.com>
To: drzeus-list@drzeus.cx, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34497 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752858AbZGMWJ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jul 2009 18:09:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. add intel's sdio vendor id to sdio_ids.h
2. move iwmc3200 sdio devices ids to sdio_ids.h

This patch is against 2.6.31-rc2
7638d5322bd89d49e013a03fe2afaeb6d214fabd

Cc:inaky.perez-gonzalez@intel.com
Cc:cindy.h.kao@intel.com
Cc:samuel.ortiz@intel.com
Cc:yi.zhu@intel.com
Cc:drzeus-list@drzeus.cx
Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>
---
 drivers/net/wimax/i2400m/sdio.c          |   10 ++++------
 drivers/net/wireless/iwmc3200wifi/sdio.c |    4 +++-
 drivers/net/wireless/iwmc3200wifi/sdio.h |    3 ---
 include/linux/mmc/sdio_ids.h             |    5 +++++
 4 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index 2538825..3dc1990 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -58,6 +58,7 @@
  */
 
 #include <linux/debugfs.h>
+#include <linux/mmc/sdio_ids.h>
 #include <linux/mmc/sdio.h>
 #include <linux/mmc/sdio_func.h>
 #include "i2400m-sdio.h"
@@ -501,14 +502,11 @@ void i2400ms_remove(struct sdio_func *func)
 	d_fnend(3, dev, "SDIO func %p\n", func);
 }
 
-enum {
-	I2400MS_INTEL_VID = 0x89,
-};
-
 static
 const struct sdio_device_id i2400ms_sdio_ids[] = {
-	/* Intel: i2400m WiMAX over SDIO */
-	{ SDIO_DEVICE(I2400MS_INTEL_VID, 0x1402) },
+	/* Intel: i2400m WiMAX (iwm3200) over SDIO */
+	{ SDIO_DEVICE(SDIO_VENDOR_ID_INTEL,
+	  SDIO_DEVICE_ID_INTEL_IWMC3200WIMAX) },
 	{ }, 			/* end: all zeroes */
 };
 MODULE_DEVICE_TABLE(sdio, i2400ms_sdio_ids);
diff --git a/drivers/net/wireless/iwmc3200wifi/sdio.c b/drivers/net/wireless/iwmc3200wifi/sdio.c
index 9166818..995a3f6 100644
--- a/drivers/net/wireless/iwmc3200wifi/sdio.c
+++ b/drivers/net/wireless/iwmc3200wifi/sdio.c
@@ -65,6 +65,7 @@
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/debugfs.h>
+#include <linux/mmc/sdio_ids.h>
 #include <linux/mmc/sdio.h>
 #include <linux/mmc/sdio_func.h>
 
@@ -492,7 +493,8 @@ static void iwm_sdio_remove(struct sdio_func *func)
 }
 
 static const struct sdio_device_id iwm_sdio_ids[] = {
-	{ SDIO_DEVICE(SDIO_VENDOR_ID_INTEL, SDIO_DEVICE_ID_IWM) },
+	{ SDIO_DEVICE(SDIO_VENDOR_ID_INTEL,
+	  SDIO_DEVICE_ID_INTEL_IWMC3200WIFI) },
 	{ /* end: all zeroes */	},
 };
 MODULE_DEVICE_TABLE(sdio, iwm_sdio_ids);
diff --git a/drivers/net/wireless/iwmc3200wifi/sdio.h b/drivers/net/wireless/iwmc3200wifi/sdio.h
index b3c156b..aab6b68 100644
--- a/drivers/net/wireless/iwmc3200wifi/sdio.h
+++ b/drivers/net/wireless/iwmc3200wifi/sdio.h
@@ -39,9 +39,6 @@
 #ifndef __IWM_SDIO_H__
 #define __IWM_SDIO_H__
 
-#define SDIO_VENDOR_ID_INTEL 0x89
-#define SDIO_DEVICE_ID_IWM   0x1403
-
 #define IWM_SDIO_DATA_ADDR           0x0
 #define IWM_SDIO_INTR_ENABLE_ADDR    0x14
 #define IWM_SDIO_INTR_STATUS_ADDR    0x13
diff --git a/include/linux/mmc/sdio_ids.h b/include/linux/mmc/sdio_ids.h
index 39751c8..b46a57a 100644
--- a/include/linux/mmc/sdio_ids.h
+++ b/include/linux/mmc/sdio_ids.h
@@ -22,6 +22,11 @@
 /*
  * Vendors and devices.  Sort key: vendor first, device next.
  */
+#define SDIO_VENDOR_ID_INTEL			0x0089
+#define SDIO_DEVICE_ID_INTEL_IWMC3200WIMAX	0x1402
+#define SDIO_DEVICE_ID_INTEL_IWMC3200WIFI	0x1403
+#define SDIO_DEVICE_ID_INTEL_IWMC3200TOP        0x1404
+#define SDIO_DEVICE_ID_INTEL_IWMC3200BT		0x1406
 
 #define SDIO_VENDOR_ID_MARVELL			0x02df
 #define SDIO_DEVICE_ID_MARVELL_LIBERTAS		0x9103
-- 
1.6.0.6

---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

