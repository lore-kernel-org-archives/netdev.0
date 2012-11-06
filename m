From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/2] tg3: Call tg3_netif_stop() from tg3_stop()
Date: Mon, 5 Nov 2012 16:26:30 -0800
Message-ID: <1352161590-1586-2-git-send-email-mchan@broadcom.com>
References: <1352161590-1586-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3432 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932070Ab2KFAME (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2012 19:12:04 -0500
In-Reply-To: <1352161590-1586-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nithin Nayak Sujir <nsujir@broadcom.com>

instead of making separate tg3_napi_disable() and netif_tx_disable() calls.

Update version to 3.126.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index b7817ca..038ce02 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -90,10 +90,10 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 
 #define DRV_MODULE_NAME		"tg3"
 #define TG3_MAJ_NUM			3
-#define TG3_MIN_NUM			125
+#define TG3_MIN_NUM			126
 #define DRV_MODULE_VERSION	\
 	__stringify(TG3_MAJ_NUM) "." __stringify(TG3_MIN_NUM)
-#define DRV_MODULE_RELDATE	"September 26, 2012"
+#define DRV_MODULE_RELDATE	"November 05, 2012"
 
 #define RESET_KIND_SHUTDOWN	0
 #define RESET_KIND_INIT		1
@@ -10430,10 +10430,8 @@ static void tg3_stop(struct tg3 *tp)
 {
 	int i;
 
-	tg3_napi_disable(tp);
 	tg3_reset_task_cancel(tp);
-
-	netif_tx_disable(tp->dev);
+	tg3_netif_stop(tp);
 
 	tg3_timer_stop(tp);
 
-- 
1.7.1
