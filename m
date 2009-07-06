From: Guo-Fu Tseng <cooldavid@cooldavid.org>
Subject: [PATCH net-2.6 1/7] jme: Some minor coding style consistency modifications
Date: Mon, 6 Jul 2009 22:36:30 +0800
Message-ID: <20090706145548.9CCA5122E3@cooldavid.org>
Cc: "netdev" <netdev@vger.kernel.org>,
	"Ethan Hsiao" <ethanhsiao@jmicron.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([220.133.139.86]:39379 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753959AbZGFOzq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2009 10:55:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Making coding style more consistent.

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 1e3c63d..abf82cd 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -554,7 +554,7 @@ jme_free_tx_resources(struct jme_adapter *jme)
 {
 	int i;
 	struct jme_ring *txring = &(jme->txring[0]);
-	struct jme_buffer_info *txbi = txring->bufinf;
+	struct jme_buffer_info *txbi;
 
 	if (txring->alloc) {
 		for (i = 0 ; i < jme->tx_ring_size ; ++i) {
@@ -653,7 +653,7 @@ jme_disable_tx_engine(struct jme_adapter *jme)
 static void
 jme_set_clean_rxdesc(struct jme_adapter *jme, int i)
 {
-	struct jme_ring *rxring = jme->rxring;
+	struct jme_ring *rxring = &(jme->rxring[0]);
 	register struct rxdesc *rxdesc = rxring->desc;
 	struct jme_buffer_info *rxbi = rxring->bufinf;
 	rxdesc += i;
@@ -790,9 +790,9 @@ jme_enable_rx_engine(struct jme_adapter *jme)
 	/*
 	 * Setup RX DMA Bass Address
 	 */
-	jwrite32(jme, JME_RXDBA_LO, (__u64)jme->rxring[0].dma & 0xFFFFFFFFUL);
+	jwrite32(jme, JME_RXDBA_LO, (__u64)(jme->rxring[0].dma) & 0xFFFFFFFFUL);
 	jwrite32(jme, JME_RXDBA_HI, (__u64)(jme->rxring[0].dma) >> 32);
-	jwrite32(jme, JME_RXNDA, (__u64)jme->rxring[0].dma & 0xFFFFFFFFUL);
+	jwrite32(jme, JME_RXNDA, (__u64)(jme->rxring[0].dma) & 0xFFFFFFFFUL);
 
 	/*
 	 * Setup RX Descriptor Count
@@ -1296,7 +1296,7 @@ jme_rx_empty_tasklet(unsigned long arg)
 static void
 jme_wake_queue_if_stopped(struct jme_adapter *jme)
 {
-	struct jme_ring *txring = jme->txring;
+	struct jme_ring *txring = &(jme->txring[0]);
 
 	smp_wmb();
 	if (unlikely(netif_queue_stopped(jme->dev) &&
@@ -1668,7 +1668,7 @@ static int
 jme_alloc_txdesc(struct jme_adapter *jme,
 			struct sk_buff *skb)
 {
-	struct jme_ring *txring = jme->txring;
+	struct jme_ring *txring = &(jme->txring[0]);
 	int idx, nr_alloc, mask = jme->tx_ring_mask;
 
 	idx = txring->next_to_use;
@@ -1722,7 +1722,7 @@ jme_fill_tx_map(struct pci_dev *pdev,
 static void
 jme_map_tx_skb(struct jme_adapter *jme, struct sk_buff *skb, int idx)
 {
-	struct jme_ring *txring = jme->txring;
+	struct jme_ring *txring = &(jme->txring[0]);
 	struct txdesc *txdesc = txring->desc, *ctxdesc;
 	struct jme_buffer_info *txbi = txring->bufinf, *ctxbi;
 	u8 hidma = jme->dev->features & NETIF_F_HIGHDMA;
@@ -1835,7 +1835,7 @@ jme_tx_vlan(struct sk_buff *skb, __le16 *vlan, u8 *flags)
 static int
 jme_fill_tx_desc(struct jme_adapter *jme, struct sk_buff *skb, int idx)
 {
-	struct jme_ring *txring = jme->txring;
+	struct jme_ring *txring = &(jme->txring[0]);
 	struct txdesc *txdesc;
 	struct jme_buffer_info *txbi;
 	u8 flags;
@@ -1883,7 +1883,7 @@ jme_fill_tx_desc(struct jme_adapter *jme, struct sk_buff *skb, int idx)
 static void
 jme_stop_queue_if_full(struct jme_adapter *jme)
 {
-	struct jme_ring *txring = jme->txring;
+	struct jme_ring *txring = &(jme->txring[0]);
 	struct jme_buffer_info *txbi = txring->bufinf;
 	int idx = atomic_read(&txring->next_to_clean);
 
-- 
1.6.0.6

