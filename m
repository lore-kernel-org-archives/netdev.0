From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH] bna: bnad_udelay macro cleanup
Date: Wed, 22 Dec 2010 23:05:49 -0800
Message-ID: <1293087949-17613-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rasesh Mody <rmody@brocade.com>, Debashis Dutt <ddutt@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:39803 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751467Ab0LWHF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Dec 2010 02:05:59 -0500
Received: from pps.filterd (m0000700 [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.14.4/8.14.4) with SMTP id oBN75voq023502
	for <netdev@vger.kernel.org>; Wed, 22 Dec 2010 23:05:57 -0800
Received: from hq1-exedge.brocade.com (hq1-exedge.brocade.com [144.49.141.11])
	by mx0b-000f0801.pphosted.com with ESMTP id tbwb3r2uv-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 22 Dec 2010 23:05:57 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
	- Removed unnecessary bnad_udelay macro for ia64

Signed-off-by: Debashis Dutt <ddutt@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bnad.c |    4 ++--
 drivers/net/bna/bnad.h |    6 ------
 2 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index 277dbe0..12d1d7a 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -925,7 +925,7 @@ bnad_cb_tx_cleanup(struct bnad *bnad, struct bna_tcb *tcb)
 {
 	/* Delay only once for the whole Tx Path Shutdown */
 	if (!test_and_set_bit(BNAD_RF_TX_SHUTDOWN_DELAYED, &bnad->run_flags))
-		bnad_udelay(BNAD_TXRX_SYNC_UDELAY);
+		udelay(BNAD_TXRX_SYNC_UDELAY);
 }
 
 static void
@@ -938,7 +938,7 @@ bnad_cb_rx_cleanup(struct bnad *bnad,
 		clear_bit(BNAD_RXQ_STARTED, &ccb->rcb[1]->flags);
 
 	if (!test_and_set_bit(BNAD_RF_RX_SHUTDOWN_DELAYED, &bnad->run_flags))
-		bnad_udelay(BNAD_TXRX_SYNC_UDELAY);
+		udelay(BNAD_TXRX_SYNC_UDELAY);
 }
 
 static void
diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index 24fd983..8b1d515 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -336,10 +336,4 @@ extern void bnad_netdev_hwstats_fill(struct bnad *bnad,
 	(((_bnad)->cfg_flags & BNAD_CF_DIM_ENABLED) && 		\
 	(test_bit(BNAD_RF_DIM_TIMER_RUNNING, &((_bnad)->run_flags))))
 
-#if defined(__ia64__)
-#define bnad_udelay	udelay
-#else
-#define bnad_udelay	__udelay
-#endif
-
 #endif /* __BNAD_H__ */
-- 
1.7.1

