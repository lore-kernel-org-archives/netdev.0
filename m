From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] mISDN: mark symbols static where possible
Date: Mon, 29 Aug 2016 20:31:11 +0800
Message-ID: <1472473871-16207-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get 3 warnings when build kernel with W=1:
drivers/isdn/hardware/mISDN/avmfritz.c:288:1: warning: no previous prototype for 'write_ctrl' [-Wmissing-prototypes]
drivers/isdn/hardware/mISDN/avmfritz.c:745:1: warning: no previous prototype for 'clear_pending_hdlc_ints' [-Wmissing-prototypes]
drivers/isdn/hardware/mISDN/avmfritz.c:966:1: warning: no previous prototype for 'setup_fritz' [-Wmissing-prototypes]

In fact, these functions are only used in the file in which they are
declared and don't need a declaration, but can be made static.
so this patch marks these functions with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/isdn/hardware/mISDN/avmfritz.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/avmfritz.c b/drivers/isdn/hardware/mISDN/avmfritz.c
index 292991c..e3fa1cd 100644
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -284,7 +284,7 @@ __write_ctrl_pciv2(struct fritzcard *fc, struct hdlc_hw *hdlc, u32 channel) {
 					  AVM_HDLC_STATUS_1));
 }
 
-void
+static void
 write_ctrl(struct bchannel *bch, int which) {
 	struct fritzcard *fc = bch->hw;
 	struct hdlc_hw *hdlc;
@@ -741,7 +741,7 @@ inithdlc(struct fritzcard *fc)
 	modehdlc(&fc->bch[1], -1);
 }
 
-void
+static void
 clear_pending_hdlc_ints(struct fritzcard *fc)
 {
 	u32 val;
@@ -962,7 +962,7 @@ avm_dctrl(struct mISDNchannel *ch, u32 cmd, void *arg)
 	return err;
 }
 
-int
+static int
 setup_fritz(struct fritzcard *fc)
 {
 	u32 val, ver;
-- 
2.7.4
