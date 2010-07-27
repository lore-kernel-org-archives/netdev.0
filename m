From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 3/8] bnx2x: move global variable load_count to
 bnx2x.h
Date: Wed, 28 Jul 2010 01:33:43 +0300
Message-ID: <1280270023.11551.97.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2722 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752910Ab0G0Wmh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 18:42:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will allow access to this global variable (used in no-mcp
mode) from different object files.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h      |    8 ++++++++
 drivers/net/bnx2x/bnx2x_main.c |    4 +---
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 237609f..4afd292 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -1373,6 +1373,14 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define BNX2X_VPD_LEN			128
 #define VENDOR_ID_LEN			4
 
+#ifdef BNX2X_MAIN
+#define BNX2X_EXTERN
+#else
+#define BNX2X_EXTERN extern
+#endif
+
+BNX2X_EXTERN int load_count[3]; /* 0-common, 1-port0, 2-port1 */
+
 /* MISC_REG_RESET_REG - this is here for the hsi to work don't touch */
 
 #endif /* bnx2x.h */
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 1e0ac8b..0beaefb 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -51,7 +51,7 @@
 #include <linux/io.h>
 #include <linux/stringify.h>
 
-
+#define BNX2X_MAIN
 #include "bnx2x.h"
 #include "bnx2x_init.h"
 #include "bnx2x_init_ops.h"
@@ -121,8 +121,6 @@ static int debug;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, " Default debug msglevel");
 
-static int load_count[3]; /* 0-common, 1-port0, 2-port1 */
-
 static struct workqueue_struct *bnx2x_wq;
 
 enum bnx2x_board_type {
-- 
1.7.1




