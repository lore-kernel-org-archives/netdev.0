From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH 2/4] net: jme: use kzalloc() instead of kmalloc+memset
Date: Wed,  9 Sep 2015 10:38:03 +0200
Message-ID: <1441787886-7214-3-git-send-email-linux@rasmusvillemoes.dk>
References: <1441787886-7214-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Guo-Fu Tseng <cooldavid@cooldavid.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441787886-7214-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using kzalloc saves a tiny bit on .text.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 drivers/net/ethernet/jme.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 6e9a792097d3..060dd3922974 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -583,7 +583,7 @@ jme_setup_tx_resources(struct jme_adapter *jme)
 	atomic_set(&txring->next_to_clean, 0);
 	atomic_set(&txring->nr_free, jme->tx_ring_size);
 
-	txring->bufinf		= kmalloc(sizeof(struct jme_buffer_info) *
+	txring->bufinf		= kzalloc(sizeof(struct jme_buffer_info) *
 					jme->tx_ring_size, GFP_ATOMIC);
 	if (unlikely(!(txring->bufinf)))
 		goto err_free_txring;
@@ -592,8 +592,6 @@ jme_setup_tx_resources(struct jme_adapter *jme)
 	 * Initialize Transmit Descriptors
 	 */
 	memset(txring->alloc, 0, TX_RING_ALLOC_SIZE(jme->tx_ring_size));
-	memset(txring->bufinf, 0,
-		sizeof(struct jme_buffer_info) * jme->tx_ring_size);
 
 	return 0;
 
@@ -845,7 +843,7 @@ jme_setup_rx_resources(struct jme_adapter *jme)
 	rxring->next_to_use	= 0;
 	atomic_set(&rxring->next_to_clean, 0);
 
-	rxring->bufinf		= kmalloc(sizeof(struct jme_buffer_info) *
+	rxring->bufinf		= kzalloc(sizeof(struct jme_buffer_info) *
 					jme->rx_ring_size, GFP_ATOMIC);
 	if (unlikely(!(rxring->bufinf)))
 		goto err_free_rxring;
@@ -853,8 +851,6 @@ jme_setup_rx_resources(struct jme_adapter *jme)
 	/*
 	 * Initiallize Receive Descriptors
 	 */
-	memset(rxring->bufinf, 0,
-		sizeof(struct jme_buffer_info) * jme->rx_ring_size);
 	for (i = 0 ; i < jme->rx_ring_size ; ++i) {
 		if (unlikely(jme_make_new_rx_buf(jme, i))) {
 			jme_free_rx_resources(jme);
-- 
2.1.3
