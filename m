From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next 3/3] net: bcmgenet: add GENET_Q16_RX_BD_CNT and hw_params->rx_bds_per_q
Date: Thu,  5 Mar 2015 17:40:14 -0800 (PST)
Message-ID: <20150306014014.ED3DF2214B6@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f201.google.com ([209.85.220.201]:36916 "EHLO
	mail-vc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754374AbbCFBkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 20:40:16 -0500
Received: by mail-vc0-f201.google.com with SMTP id le20so5611885vcb.0
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 17:40:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for supporting multiple Rx queues, add GENET_Q16_RX_BD_CNT
and hw_params->rx_bds_per_q.

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 10 ++++++++--
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  1 +
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 57271f7..d90785c 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -54,6 +54,8 @@
 /* Default highest priority queue for multi queue support */
 #define GENET_Q0_PRIORITY	0
 
+#define GENET_Q16_RX_BD_CNT	\
+	(TOTAL_DESC - priv->hw_params->rx_queues * priv->hw_params->rx_bds_per_q)
 #define GENET_Q16_TX_BD_CNT	\
 	(TOTAL_DESC - priv->hw_params->tx_queues * priv->hw_params->tx_bds_per_q)
 
@@ -2488,6 +2490,7 @@ static struct bcmgenet_hw_params bcmgenet_hw_params[] = {
 		.tx_queues = 0,
 		.tx_bds_per_q = 0,
 		.rx_queues = 0,
+		.rx_bds_per_q = 0,
 		.bp_in_en_shift = 16,
 		.bp_in_mask = 0xffff,
 		.hfb_filter_cnt = 16,
@@ -2501,6 +2504,7 @@ static struct bcmgenet_hw_params bcmgenet_hw_params[] = {
 		.tx_queues = 4,
 		.tx_bds_per_q = 32,
 		.rx_queues = 0,
+		.rx_bds_per_q = 0,
 		.bp_in_en_shift = 16,
 		.bp_in_mask = 0xffff,
 		.hfb_filter_cnt = 16,
@@ -2517,6 +2521,7 @@ static struct bcmgenet_hw_params bcmgenet_hw_params[] = {
 		.tx_queues = 4,
 		.tx_bds_per_q = 32,
 		.rx_queues = 0,
+		.rx_bds_per_q = 0,
 		.bp_in_en_shift = 17,
 		.bp_in_mask = 0x1ffff,
 		.hfb_filter_cnt = 48,
@@ -2533,6 +2538,7 @@ static struct bcmgenet_hw_params bcmgenet_hw_params[] = {
 		.tx_queues = 4,
 		.tx_bds_per_q = 32,
 		.rx_queues = 0,
+		.rx_bds_per_q = 0,
 		.bp_in_en_shift = 17,
 		.bp_in_mask = 0x1ffff,
 		.hfb_filter_cnt = 48,
@@ -2632,7 +2638,7 @@ static void bcmgenet_set_hw_params(struct bcmgenet_priv *priv)
 #endif
 
 	pr_debug("Configuration for version: %d\n"
-		"TXq: %1d, TXqBDs: %1d, RXq: %1d\n"
+		"TXq: %1d, TXqBDs: %1d, RXq: %1d, RXqBDs: %1d\n"
 		"BP << en: %2d, BP msk: 0x%05x\n"
 		"HFB count: %2d, QTAQ msk: 0x%05x\n"
 		"TBUF: 0x%04x, HFB: 0x%04x, HFBreg: 0x%04x\n"
@@ -2640,7 +2646,7 @@ static void bcmgenet_set_hw_params(struct bcmgenet_priv *priv)
 		"Words/BD: %d\n",
 		priv->version,
 		params->tx_queues, params->tx_bds_per_q,
-		params->rx_queues,
+		params->rx_queues, params->rx_bds_per_q,
 		params->bp_in_en_shift, params->bp_in_mask,
 		params->hfb_filter_cnt, params->qtag_mask,
 		params->tbuf_offset, params->hfb_offset,
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 548b7e9..5684e85 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -505,6 +505,7 @@ struct bcmgenet_hw_params {
 	u8		tx_queues;
 	u8		tx_bds_per_q;
 	u8		rx_queues;
+	u8		rx_bds_per_q;
 	u8		bp_in_en_shift;
 	u32		bp_in_mask;
 	u8		hfb_filter_cnt;
-- 
2.2.0.rc0.207.ga3a616c
