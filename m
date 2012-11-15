From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 4/4] tg3: Use tp->rxq_cnt when checking RSS
 tables.
Date: Wed, 14 Nov 2012 16:44:29 -0800
Message-ID: <1352940269-23821-4-git-send-email-mchan@broadcom.com>
References: <1352940269-23821-1-git-send-email-mchan@broadcom.com>
 <1352940269-23821-2-git-send-email-mchan@broadcom.com>
 <1352940269-23821-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4036 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755462Ab2KOAa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2012 19:30:27 -0500
In-Reply-To: <1352940269-23821-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

irq_cnt is no longer reliable since rxq_cnt can be independently configured.

Update version to 3.127.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index ffff018..5cc976d 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -90,10 +90,10 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 
 #define DRV_MODULE_NAME		"tg3"
 #define TG3_MAJ_NUM			3
-#define TG3_MIN_NUM			126
+#define TG3_MIN_NUM			127
 #define DRV_MODULE_VERSION	\
 	__stringify(TG3_MAJ_NUM) "." __stringify(TG3_MIN_NUM)
-#define DRV_MODULE_RELDATE	"November 05, 2012"
+#define DRV_MODULE_RELDATE	"November 14, 2012"
 
 #define RESET_KIND_SHUTDOWN	0
 #define RESET_KIND_INIT		1
@@ -8710,14 +8710,14 @@ static void tg3_rss_check_indir_tbl(struct tg3 *tp)
 	if (!tg3_flag(tp, SUPPORT_MSIX))
 		return;
 
-	if (tp->irq_cnt <= 2) {
+	if (tp->rxq_cnt == 1) {
 		memset(&tp->rss_ind_tbl[0], 0, sizeof(tp->rss_ind_tbl));
 		return;
 	}
 
 	/* Validate table against current IRQ count */
 	for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i++) {
-		if (tp->rss_ind_tbl[i] >= tp->irq_cnt - 1)
+		if (tp->rss_ind_tbl[i] >= tp->rxq_cnt)
 			break;
 	}
 
-- 
1.7.1
