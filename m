From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 7/7 net-next] tg3: Change default number of tx rings to
 1.
Date: Wed, 26 Sep 2012 15:32:49 -0700
Message-ID: <1348698769-760-7-git-send-email-mchan@broadcom.com>
References: <1348698769-760-1-git-send-email-mchan@broadcom.com>
 <1348698769-760-2-git-send-email-mchan@broadcom.com>
 <1348698769-760-3-git-send-email-mchan@broadcom.com>
 <1348698769-760-4-git-send-email-mchan@broadcom.com>
 <1348698769-760-5-git-send-email-mchan@broadcom.com>
 <1348698769-760-6-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4310 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752866Ab2IZWUE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2012 18:20:04 -0400
In-Reply-To: <1348698769-760-6-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hardware tx scheduling can cause some starvation of a tx ring with small
packets if other tx rings have jumbo or TSO packets.  The default setting
of 1 TX ring gives the best overall performance in many common traffic
scenarios.  The user can change it using ethttol -L if desired.

Update version to 3.125.

Reviewed-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 74eea2f..3dff2ef 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -92,10 +92,10 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 
 #define DRV_MODULE_NAME		"tg3"
 #define TG3_MAJ_NUM			3
-#define TG3_MIN_NUM			124
+#define TG3_MIN_NUM			125
 #define DRV_MODULE_VERSION	\
 	__stringify(TG3_MAJ_NUM) "." __stringify(TG3_MIN_NUM)
-#define DRV_MODULE_RELDATE	"March 21, 2012"
+#define DRV_MODULE_RELDATE	"September 26, 2012"
 
 #define RESET_KIND_SHUTDOWN	0
 #define RESET_KIND_INIT		1
@@ -10245,10 +10245,9 @@ static bool tg3_enable_msix(struct tg3 *tp)
 		tp->rxq_cnt = netif_get_num_default_rss_queues();
 	if (tp->rxq_cnt > tp->rxq_max)
 		tp->rxq_cnt = tp->rxq_max;
-	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) &&
-	    !tp->txq_req)
-		tp->txq_cnt = min(tp->rxq_cnt, tp->txq_max);
+
+	if (!tp->txq_req)
+		tp->txq_cnt = 1;
 
 	tp->irq_cnt = tg3_irq_count(tp);
 
-- 
1.7.1
