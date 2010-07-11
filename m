From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 5/8] tg3: Report driver version to firmware
Date: Sun, 11 Jul 2010 12:31:44 -0700
Message-ID: <1278876707-21390-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1310 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754725Ab0GKTcD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jul 2010 15:32:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the code so that the driver version can be reported
to the firmware in addition to the current use.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    8 ++++++--
 drivers/net/tg3.h |    4 +++-
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index c91049b..e6da16a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -18,6 +18,7 @@
 
 #include <linux/module.h>
 #include <linux/moduleparam.h>
+#include <linux/stringify.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/compiler.h>
@@ -67,7 +68,10 @@
 #include "tg3.h"
 
 #define DRV_MODULE_NAME		"tg3"
-#define DRV_MODULE_VERSION	"3.111"
+#define TG3_MAJ_NUM			3
+#define TG3_MIN_NUM			111
+#define DRV_MODULE_VERSION	\
+	__stringify(TG3_MAJ_NUM) "." __stringify(TG3_MIN_NUM)
 #define DRV_MODULE_RELDATE	"June 5, 2010"
 
 #define TG3_DEF_MAC_MODE	0
@@ -6629,7 +6633,7 @@ static void tg3_ape_driver_state_change(struct tg3 *tp, int kind)
 		apedata = tg3_ape_read32(tp, TG3_APE_HOST_INIT_COUNT);
 		tg3_ape_write32(tp, TG3_APE_HOST_INIT_COUNT, ++apedata);
 		tg3_ape_write32(tp, TG3_APE_HOST_DRIVER_ID,
-				APE_HOST_DRIVER_ID_MAGIC);
+			APE_HOST_DRIVER_ID_MAGIC(TG3_MAJ_NUM, TG3_MIN_NUM));
 		tg3_ape_write32(tp, TG3_APE_HOST_BEHAVIOR,
 				APE_HOST_BEHAV_NO_PHYLOCK);
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index b72ac52..be7ab91 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2193,7 +2193,9 @@
 #define  APE_HOST_SEG_LEN_MAGIC		 0x0000001c
 #define TG3_APE_HOST_INIT_COUNT		0x4208
 #define TG3_APE_HOST_DRIVER_ID		0x420c
-#define  APE_HOST_DRIVER_ID_MAGIC	 0xf0035100
+#define  APE_HOST_DRIVER_ID_LINUX	 0xf0000000
+#define  APE_HOST_DRIVER_ID_MAGIC(maj, min)	\
+	(APE_HOST_DRIVER_ID_LINUX | (maj & 0xff) << 16 | (min & 0xff) << 8)
 #define TG3_APE_HOST_BEHAVIOR		0x4210
 #define  APE_HOST_BEHAV_NO_PHYLOCK	 0x00000001
 #define TG3_APE_HOST_HEARTBEAT_INT_MS	0x4214
-- 
1.6.4.4


