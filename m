From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH 4/6] isdn/hisax: clean function declaration in hscx.c up
Date: Sat, 24 Sep 2016 13:24:22 +0800
Message-ID: <1474694662-7527-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get 1 warning when building kernel with W=1:
drivers/isdn/hisax/hscx.c:175:1: warning: no previous prototype for 'open_hscxstate' [-Wmissing-prototypes]

In fact, this function is declared in
drivers/isdn/hisax/elsa_ser.c, but should be
declard in a header file, thus can be recognized in other file.

So this patch moves the declaration into drivers/isdn/hisax/hscx.h.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/isdn/hisax/elsa_ser.c | 2 +-
 drivers/isdn/hisax/hscx.h     | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/isdn/hisax/elsa_ser.c b/drivers/isdn/hisax/elsa_ser.c
index a2a358c..34ccc18 100644
--- a/drivers/isdn/hisax/elsa_ser.c
+++ b/drivers/isdn/hisax/elsa_ser.c
@@ -10,6 +10,7 @@
 #include <linux/serial.h>
 #include <linux/serial_reg.h>
 #include <linux/slab.h>
+#include "hscx.h"
 
 #define MAX_MODEM_BUF	256
 #define WAKEUP_CHARS	(MAX_MODEM_BUF / 2)
@@ -419,7 +420,6 @@ static void rs_interrupt_elsa(struct IsdnCardState *cs)
 #endif
 }
 
-extern int open_hscxstate(struct IsdnCardState *cs, struct BCState *bcs);
 extern void modehscx(struct BCState *bcs, int mode, int bc);
 extern void hscx_l2l1(struct PStack *st, int pr, void *arg);
 
diff --git a/drivers/isdn/hisax/hscx.h b/drivers/isdn/hisax/hscx.h
index 1148b4b..fa7bf16 100644
--- a/drivers/isdn/hisax/hscx.h
+++ b/drivers/isdn/hisax/hscx.h
@@ -39,3 +39,4 @@ extern void modehscx(struct BCState *bcs, int mode, int bc);
 extern void clear_pending_hscx_ints(struct IsdnCardState *cs);
 extern void inithscx(struct IsdnCardState *cs);
 extern void inithscxisac(struct IsdnCardState *cs, int part);
+int open_hscxstate(struct IsdnCardState *cs, struct BCState *bcs);
-- 
2.7.4
