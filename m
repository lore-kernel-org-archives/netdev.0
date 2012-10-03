From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH] tg3: Fix sparse warnings.
Date: Tue, 2 Oct 2012 20:31:14 -0700
Message-ID: <1349235074-18927-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1911 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751904Ab2JCDRt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2012 23:17:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/ethernet/broadcom/tg3.c:8121:8: warning: symbol 'i' shadows an earlier one
drivers/net/ethernet/broadcom/tg3.c:8003:6: originally declared here
drivers/net/ethernet/broadcom/tg3.c:785:5: warning: symbol 'tg3_ape_scratchpad_read' was not declared. Should it be static?
drivers/net/ethernet/broadcom/tg3.c:7781:19: warning: Using plain integer as NULL pointer
drivers/net/ethernet/broadcom/tg3.c:10231:31: error: bad constant expression

Reported-by: Fengguang Wu <fenguang.wu@intel.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 008ea14..b0624c2 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -782,7 +782,8 @@ static int tg3_ape_wait_for_event(struct tg3 *tp, u32 timeout_us)
 	return i == timeout_us / 10;
 }
 
-int tg3_ape_scratchpad_read(struct tg3 *tp, u32 *data, u32 base_off, u32 len)
+static int tg3_ape_scratchpad_read(struct tg3 *tp, u32 *data, u32 base_off,
+				   u32 len)
 {
 	int err;
 	u32 i, bufoff, msgoff, maxlen, apedata;
@@ -7778,7 +7779,7 @@ static int tg3_alloc_consistent(struct tg3 *tp)
 		sblk = tnapi->hw_status;
 
 		if (tg3_flag(tp, ENABLE_RSS)) {
-			u16 *prodptr = 0;
+			u16 *prodptr = NULL;
 
 			/*
 			 * When RSS is enabled, the status block format changes
@@ -8118,11 +8119,11 @@ static int tg3_chip_reset(struct tg3 *tp)
 		u16 val16;
 
 		if (tp->pci_chip_rev_id == CHIPREV_ID_5750_A0) {
-			int i;
+			int j;
 			u32 cfg_val;
 
 			/* Wait for link training to complete.  */
-			for (i = 0; i < 5000; i++)
+			for (j = 0; j < 5000; j++)
 				udelay(100);
 
 			pci_read_config_dword(tp->pdev, 0xc4, &cfg_val);
@@ -10228,7 +10229,7 @@ static u32 tg3_irq_count(struct tg3 *tp)
 static bool tg3_enable_msix(struct tg3 *tp)
 {
 	int i, rc;
-	struct msix_entry msix_ent[tp->irq_max];
+	struct msix_entry msix_ent[TG3_IRQ_MAX_VECS];
 
 	tp->txq_cnt = tp->txq_req;
 	tp->rxq_cnt = tp->rxq_req;
-- 
1.6.4.GIT
