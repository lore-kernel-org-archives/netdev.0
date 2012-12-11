From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 3/7] bna: TX Intr Coalescing Fix
Date: Tue, 11 Dec 2012 14:24:52 -0800
Message-ID: <1355264696-8927-4-git-send-email-rmody@brocade.com>
References: <1355264696-8927-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bhutchings@solarflare.com>, <David.Laight@ACULAB.COM>,
	<adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:38628 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754786Ab2LKWZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 17:25:34 -0500
In-Reply-To: <1355264696-8927-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change Details:
        For Tx IB, IPM was enabled with inter_pkt_timeo of 0. This caused the
Tx IB not to generate interrupt till inter_pkt_count of packets have been
received. Correct definition for BFI_TX_INTERPKT_TIMEO & BFI_TX_INTERPKT_COUNT

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bna_hw_defs.h |    3 ++-
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c   |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bna_hw_defs.h b/drivers/net/ethernet/brocade/bna/bna_hw_defs.h
index b8c4e21..af3f7bb 100644
--- a/drivers/net/ethernet/brocade/bna/bna_hw_defs.h
+++ b/drivers/net/ethernet/brocade/bna/bna_hw_defs.h
@@ -46,7 +46,8 @@
 #define BFI_MAX_INTERPKT_COUNT		0xFF
 #define BFI_MAX_INTERPKT_TIMEO		0xF	/* in 0.5us units */
 #define BFI_TX_COALESCING_TIMEO		20	/* 20 * 5 = 100us */
-#define BFI_TX_INTERPKT_COUNT		32
+#define BFI_TX_INTERPKT_COUNT		12	/* Pkt Cnt = 12 */
+#define BFI_TX_INTERPKT_TIMEO		15	/* 15 * 0.5 = 7.5us */
 #define	BFI_RX_COALESCING_TIMEO		12	/* 12 * 5 = 60us */
 #define	BFI_RX_INTERPKT_COUNT		6	/* Pkt Cnt = 6 */
 #define	BFI_RX_INTERPKT_TIMEO		3	/* 3 * 0.5 = 1.5us */
diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index bb5467b..4df6d4b 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -3569,7 +3569,7 @@ bna_tx_create(struct bna *bna, struct bnad *bnad,
 		if (intr_info->intr_type == BNA_INTR_T_INTX)
 			txq->ib.intr_vector = (1 <<  txq->ib.intr_vector);
 		txq->ib.coalescing_timeo = tx_cfg->coalescing_timeo;
-		txq->ib.interpkt_timeo = 0; /* Not used */
+		txq->ib.interpkt_timeo = BFI_TX_INTERPKT_TIMEO;
 		txq->ib.interpkt_count = BFI_TX_INTERPKT_COUNT;
 
 		/* TCB */
-- 
1.7.1
