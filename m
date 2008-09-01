From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 20/52] sfc: Removed forced inlining of long functions
Date: Mon, 1 Sep 2008 12:47:12 +0100
Message-ID: <20080901114710.GN7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:54559 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757512AbYIALrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:47:15 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gcc will automatically inline static functions with only one caller, and
may inline other functions depending on the kernel configuration and size
of the intermediate code.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c    |    2 +-
 drivers/net/sfc/falcon.c |    8 +++---
 drivers/net/sfc/rx.c     |   42 ++++++++++++++++++++--------------------
 drivers/net/sfc/tx.c     |   47 ++++++++++++++++++++++-----------------------
 4 files changed, 49 insertions(+), 50 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 022dc36..9f1ac3a 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -158,7 +158,7 @@ static void efx_fini_channels(struct efx_nic *efx);
  * never be concurrently called more than once on the same channel,
  * though different channels may be being processed concurrently.
  */
-static inline int efx_process_channel(struct efx_channel *channel, int rx_quota)
+static int efx_process_channel(struct efx_channel *channel, int rx_quota)
 {
 	int rxdmaqs;
 	struct efx_rx_queue *rx_queue;
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index fb06971..9a13e5c 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -815,8 +815,8 @@ void falcon_generate_event(struct efx_channel *channel, efx_qword_t *event)
  * Falcon batches TX completion events; the message we receive is of
  * the form "complete all TX events up to this index".
  */
-static inline void falcon_handle_tx_event(struct efx_channel *channel,
-					  efx_qword_t *event)
+static void falcon_handle_tx_event(struct efx_channel *channel,
+				   efx_qword_t *event)
 {
 	unsigned int tx_ev_desc_ptr;
 	unsigned int tx_ev_q_label;
@@ -952,8 +952,8 @@ static void falcon_handle_rx_bad_index(struct efx_rx_queue *rx_queue,
  * Also "is multicast" and "matches multicast filter" flags can be used to
  * discard non-matching multicast packets.
  */
-static inline int falcon_handle_rx_event(struct efx_channel *channel,
-					 const efx_qword_t *event)
+static int falcon_handle_rx_event(struct efx_channel *channel,
+				  const efx_qword_t *event)
 {
 	unsigned int rx_ev_q_label, rx_ev_desc_ptr, rx_ev_byte_cnt;
 	unsigned int rx_ev_hdr_type, rx_ev_mcast_pkt;
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 17aa81e..fa1a62a 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -212,8 +212,8 @@ void efx_lro_fini(struct net_lro_mgr *lro_mgr)
  * and populates a struct efx_rx_buffer with the relevant
  * information.  Return a negative error code or 0 on success.
  */
-static inline int efx_init_rx_buffer_skb(struct efx_rx_queue *rx_queue,
-					 struct efx_rx_buffer *rx_buf)
+static int efx_init_rx_buffer_skb(struct efx_rx_queue *rx_queue,
+				  struct efx_rx_buffer *rx_buf)
 {
 	struct efx_nic *efx = rx_queue->efx;
 	struct net_device *net_dev = efx->net_dev;
@@ -252,8 +252,8 @@ static inline int efx_init_rx_buffer_skb(struct efx_rx_queue *rx_queue,
  * and populates a struct efx_rx_buffer with the relevant
  * information.  Return a negative error code or 0 on success.
  */
-static inline int efx_init_rx_buffer_page(struct efx_rx_queue *rx_queue,
-					  struct efx_rx_buffer *rx_buf)
+static int efx_init_rx_buffer_page(struct efx_rx_queue *rx_queue,
+				   struct efx_rx_buffer *rx_buf)
 {
 	struct efx_nic *efx = rx_queue->efx;
 	int bytes, space, offset;
@@ -319,8 +319,8 @@ static inline int efx_init_rx_buffer_page(struct efx_rx_queue *rx_queue,
  * and populates a struct efx_rx_buffer with the relevant
  * information.
  */
-static inline int efx_init_rx_buffer(struct efx_rx_queue *rx_queue,
-				     struct efx_rx_buffer *new_rx_buf)
+static int efx_init_rx_buffer(struct efx_rx_queue *rx_queue,
+			      struct efx_rx_buffer *new_rx_buf)
 {
 	int rc = 0;
 
@@ -340,8 +340,8 @@ static inline int efx_init_rx_buffer(struct efx_rx_queue *rx_queue,
 	return rc;
 }
 
-static inline void efx_unmap_rx_buffer(struct efx_nic *efx,
-				       struct efx_rx_buffer *rx_buf)
+static void efx_unmap_rx_buffer(struct efx_nic *efx,
+				struct efx_rx_buffer *rx_buf)
 {
 	if (rx_buf->page) {
 		EFX_BUG_ON_PARANOID(rx_buf->skb);
@@ -357,8 +357,8 @@ static inline void efx_unmap_rx_buffer(struct efx_nic *efx,
 	}
 }
 
-static inline void efx_free_rx_buffer(struct efx_nic *efx,
-				      struct efx_rx_buffer *rx_buf)
+static void efx_free_rx_buffer(struct efx_nic *efx,
+			       struct efx_rx_buffer *rx_buf)
 {
 	if (rx_buf->page) {
 		__free_pages(rx_buf->page, efx->rx_buffer_order);
@@ -369,8 +369,8 @@ static inline void efx_free_rx_buffer(struct efx_nic *efx,
 	}
 }
 
-static inline void efx_fini_rx_buffer(struct efx_rx_queue *rx_queue,
-				      struct efx_rx_buffer *rx_buf)
+static void efx_fini_rx_buffer(struct efx_rx_queue *rx_queue,
+			       struct efx_rx_buffer *rx_buf)
 {
 	efx_unmap_rx_buffer(rx_queue->efx, rx_buf);
 	efx_free_rx_buffer(rx_queue->efx, rx_buf);
@@ -506,10 +506,10 @@ void efx_rx_work(struct work_struct *data)
 		efx_schedule_slow_fill(rx_queue, 1);
 }
 
-static inline void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
-					    struct efx_rx_buffer *rx_buf,
-					    int len, bool *discard,
-					    bool *leak_packet)
+static void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
+				     struct efx_rx_buffer *rx_buf,
+				     int len, bool *discard,
+				     bool *leak_packet)
 {
 	struct efx_nic *efx = rx_queue->efx;
 	unsigned max_len = rx_buf->len - efx->type->rx_buffer_padding;
@@ -546,8 +546,8 @@ static inline void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
  * Handles driverlink veto, and passes the fragment up via
  * the appropriate LRO method
  */
-static inline void efx_rx_packet_lro(struct efx_channel *channel,
-				     struct efx_rx_buffer *rx_buf)
+static void efx_rx_packet_lro(struct efx_channel *channel,
+			      struct efx_rx_buffer *rx_buf)
 {
 	struct net_lro_mgr *lro_mgr = &channel->lro_mgr;
 	void *priv = channel;
@@ -574,9 +574,9 @@ static inline void efx_rx_packet_lro(struct efx_channel *channel,
 }
 
 /* Allocate and construct an SKB around a struct page.*/
-static inline struct sk_buff *efx_rx_mk_skb(struct efx_rx_buffer *rx_buf,
-					    struct efx_nic *efx,
-					    int hdr_len)
+static struct sk_buff *efx_rx_mk_skb(struct efx_rx_buffer *rx_buf,
+				     struct efx_nic *efx,
+				     int hdr_len)
 {
 	struct sk_buff *skb;
 
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 550856f..0e9889c 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -47,7 +47,7 @@ void efx_stop_queue(struct efx_nic *efx)
  * We want to be able to nest calls to netif_stop_queue(), since each
  * channel can have an individual stop on the queue.
  */
-inline void efx_wake_queue(struct efx_nic *efx)
+void efx_wake_queue(struct efx_nic *efx)
 {
 	local_bh_disable();
 	if (atomic_dec_and_lock(&efx->netif_stop_count,
@@ -59,8 +59,8 @@ inline void efx_wake_queue(struct efx_nic *efx)
 	local_bh_enable();
 }
 
-static inline void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
-				      struct efx_tx_buffer *buffer)
+static void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
+			       struct efx_tx_buffer *buffer)
 {
 	if (buffer->unmap_len) {
 		struct pci_dev *pci_dev = tx_queue->efx->pci_dev;
@@ -110,8 +110,8 @@ static void efx_fini_tso(struct efx_tx_queue *tx_queue);
 static void efx_tsoh_heap_free(struct efx_tx_queue *tx_queue,
 			       struct efx_tso_header *tsoh);
 
-static inline void efx_tsoh_free(struct efx_tx_queue *tx_queue,
-				 struct efx_tx_buffer *buffer)
+static void efx_tsoh_free(struct efx_tx_queue *tx_queue,
+			  struct efx_tx_buffer *buffer)
 {
 	if (buffer->tsoh) {
 		if (likely(!buffer->tsoh->unmap_len)) {
@@ -138,8 +138,8 @@ static inline void efx_tsoh_free(struct efx_tx_queue *tx_queue,
  * Returns NETDEV_TX_OK or NETDEV_TX_BUSY
  * You must hold netif_tx_lock() to call this function.
  */
-static inline int efx_enqueue_skb(struct efx_tx_queue *tx_queue,
-				  const struct sk_buff *skb)
+static int efx_enqueue_skb(struct efx_tx_queue *tx_queue,
+			   const struct sk_buff *skb)
 {
 	struct efx_nic *efx = tx_queue->efx;
 	struct pci_dev *pci_dev = efx->pci_dev;
@@ -305,8 +305,8 @@ static inline int efx_enqueue_skb(struct efx_tx_queue *tx_queue,
  * This removes packets from the TX queue, up to and including the
  * specified index.
  */
-static inline void efx_dequeue_buffers(struct efx_tx_queue *tx_queue,
-				       unsigned int index)
+static void efx_dequeue_buffers(struct efx_tx_queue *tx_queue,
+				unsigned int index)
 {
 	struct efx_nic *efx = tx_queue->efx;
 	unsigned int stop_index, read_ptr;
@@ -578,7 +578,7 @@ struct tso_state {
  * Verify that our various assumptions about sk_buffs and the conditions
  * under which TSO will be attempted hold true.
  */
-static inline void efx_tso_check_safe(const struct sk_buff *skb)
+static void efx_tso_check_safe(const struct sk_buff *skb)
 {
 	EFX_BUG_ON_PARANOID(skb->protocol != htons(ETH_P_IP));
 	EFX_BUG_ON_PARANOID(((struct ethhdr *)skb->data)->h_proto !=
@@ -772,8 +772,8 @@ static int efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
  * a single fragment, and we know it doesn't cross a page boundary.  It
  * also allows us to not worry about end-of-packet etc.
  */
-static inline void efx_tso_put_header(struct efx_tx_queue *tx_queue,
-				      struct efx_tso_header *tsoh, unsigned len)
+static void efx_tso_put_header(struct efx_tx_queue *tx_queue,
+			       struct efx_tso_header *tsoh, unsigned len)
 {
 	struct efx_tx_buffer *buffer;
 
@@ -826,7 +826,7 @@ static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
 
 
 /* Parse the SKB header and initialise state. */
-static inline void tso_start(struct tso_state *st, const struct sk_buff *skb)
+static void tso_start(struct tso_state *st, const struct sk_buff *skb)
 {
 	/* All ethernet/IP/TCP headers combined size is TCP header size
 	 * plus offset of TCP header relative to start of packet.
@@ -848,8 +848,8 @@ static inline void tso_start(struct tso_state *st, const struct sk_buff *skb)
 	st->unmap_single = false;
 }
 
-static inline int tso_get_fragment(struct tso_state *st, struct efx_nic *efx,
-				   skb_frag_t *frag)
+static int tso_get_fragment(struct tso_state *st, struct efx_nic *efx,
+			    skb_frag_t *frag)
 {
 	st->unmap_addr = pci_map_page(efx->pci_dev, frag->page,
 				      frag->page_offset, frag->size,
@@ -864,9 +864,8 @@ static inline int tso_get_fragment(struct tso_state *st, struct efx_nic *efx,
 	return -ENOMEM;
 }
 
-static inline int
-tso_get_head_fragment(struct tso_state *st, struct efx_nic *efx,
-		      const struct sk_buff *skb)
+static int tso_get_head_fragment(struct tso_state *st, struct efx_nic *efx,
+				 const struct sk_buff *skb)
 {
 	int hl = st->header_len;
 	int len = skb_headlen(skb) - hl;
@@ -894,9 +893,9 @@ tso_get_head_fragment(struct tso_state *st, struct efx_nic *efx,
  * of fragment or end-of-packet.  Return 0 on success, 1 if not enough
  * space in @tx_queue.
  */
-static inline int tso_fill_packet_with_fragment(struct efx_tx_queue *tx_queue,
-						const struct sk_buff *skb,
-						struct tso_state *st)
+static int tso_fill_packet_with_fragment(struct efx_tx_queue *tx_queue,
+					 const struct sk_buff *skb,
+					 struct tso_state *st)
 {
 	struct efx_tx_buffer *buffer;
 	int n, end_of_packet, rc;
@@ -946,9 +945,9 @@ static inline int tso_fill_packet_with_fragment(struct efx_tx_queue *tx_queue,
  * Generate a new header and prepare for the new packet.  Return 0 on
  * success, or -1 if failed to alloc header.
  */
-static inline int tso_start_new_packet(struct efx_tx_queue *tx_queue,
-				       const struct sk_buff *skb,
-				       struct tso_state *st)
+static int tso_start_new_packet(struct efx_tx_queue *tx_queue,
+				const struct sk_buff *skb,
+				struct tso_state *st)
 {
 	struct efx_tso_header *tsoh;
 	struct iphdr *tsoh_iph;
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

