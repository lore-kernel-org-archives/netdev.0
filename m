From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 14/16] sfc: Remove redundant casts to and from void *
Date: Fri, 16 May 2008 21:20:00 +0100
Message-ID: <20080516202000.GG28241@solarflare.com>
References: <20080516201005.GS28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:53592 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754297AbYEPUXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 16:23:50 -0400
Content-Disposition: inline
In-Reply-To: <20080516201005.GS28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c      |    2 +-
 drivers/net/sfc/falcon.c   |   18 +++++++++---------
 drivers/net/sfc/rx.c       |    8 ++++----
 drivers/net/sfc/selftest.c |    4 ++--
 drivers/net/sfc/xfp_phy.c  |    2 +-
 5 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 11ee0d4..4497606 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1490,7 +1490,7 @@ static void efx_set_multicast_list(struct net_device *net_dev)
 static int efx_netdev_event(struct notifier_block *this,
 			    unsigned long event, void *ptr)
 {
-	struct net_device *net_dev = (struct net_device *)ptr;
+	struct net_device *net_dev = ptr;
 
 	if (net_dev->open == efx_net_open && event == NETDEV_CHANGENAME) {
 		struct efx_nic *efx = net_dev->priv;
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index ac14460..d3f749c 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1396,7 +1396,7 @@ static inline void falcon_irq_ack_a1(struct efx_nic *efx)
 static irqreturn_t falcon_fatal_interrupt(struct efx_nic *efx)
 {
 	struct falcon_nic_data *nic_data = efx->nic_data;
-	efx_oword_t *int_ker = (efx_oword_t *) efx->irq_status.addr;
+	efx_oword_t *int_ker = efx->irq_status.addr;
 	efx_oword_t fatal_intr;
 	int error, mem_perr;
 	static int n_int_errors;
@@ -1442,8 +1442,8 @@ out:
  */
 static irqreturn_t falcon_legacy_interrupt_b0(int irq, void *dev_id)
 {
-	struct efx_nic *efx = (struct efx_nic *)dev_id;
-	efx_oword_t *int_ker = (efx_oword_t *) efx->irq_status.addr;
+	struct efx_nic *efx = dev_id;
+	efx_oword_t *int_ker = efx->irq_status.addr;
 	struct efx_channel *channel;
 	efx_dword_t reg;
 	u32 queues;
@@ -1480,8 +1480,8 @@ static irqreturn_t falcon_legacy_interrupt_b0(int irq, void *dev_id)
 
 static irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id)
 {
-	struct efx_nic *efx = (struct efx_nic *)dev_id;
-	efx_oword_t *int_ker = (efx_oword_t *) efx->irq_status.addr;
+	struct efx_nic *efx = dev_id;
+	efx_oword_t *int_ker = efx->irq_status.addr;
 	struct efx_channel *channel;
 	int syserr;
 	int queues;
@@ -1533,9 +1533,9 @@ static irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id)
  */
 static irqreturn_t falcon_msi_interrupt(int irq, void *dev_id)
 {
-	struct efx_channel *channel = (struct efx_channel *)dev_id;
+	struct efx_channel *channel = dev_id;
 	struct efx_nic *efx = channel->efx;
-	efx_oword_t *int_ker = (efx_oword_t *) efx->irq_status.addr;
+	efx_oword_t *int_ker = efx->irq_status.addr;
 	int syserr;
 
 	efx->last_irq_cpu = raw_smp_processor_id();
@@ -1932,7 +1932,7 @@ static int falcon_gmii_wait(struct efx_nic *efx)
 static void falcon_mdio_write(struct net_device *net_dev, int phy_id,
 			      int addr, int value)
 {
-	struct efx_nic *efx = (struct efx_nic *)net_dev->priv;
+	struct efx_nic *efx = net_dev->priv;
 	unsigned int phy_id2 = phy_id & FALCON_PHY_ID_ID_MASK;
 	efx_oword_t reg;
 
@@ -2000,7 +2000,7 @@ static void falcon_mdio_write(struct net_device *net_dev, int phy_id,
  * could be read, -1 will be returned. */
 static int falcon_mdio_read(struct net_device *net_dev, int phy_id, int addr)
 {
-	struct efx_nic *efx = (struct efx_nic *)net_dev->priv;
+	struct efx_nic *efx = net_dev->priv;
 	unsigned int phy_addr = phy_id & FALCON_PHY_ID_ID_MASK;
 	efx_oword_t reg;
 	int value = -1;
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 88f87ef..601b001 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -109,7 +109,7 @@ static inline unsigned int efx_rx_buf_size(struct efx_nic *efx)
 static int efx_lro_get_skb_hdr(struct sk_buff *skb, void **ip_hdr,
 			       void **tcpudp_hdr, u64 *hdr_flags, void *priv)
 {
-	struct efx_channel *channel = (struct efx_channel *)priv;
+	struct efx_channel *channel = priv;
 	struct iphdr *iph;
 	struct tcphdr *th;
 
@@ -134,12 +134,12 @@ static int efx_get_frag_hdr(struct skb_frag_struct *frag, void **mac_hdr,
 			    void **ip_hdr, void **tcpudp_hdr, u64 *hdr_flags,
 			    void *priv)
 {
-	struct efx_channel *channel = (struct efx_channel *)priv;
+	struct efx_channel *channel = priv;
 	struct ethhdr *eh;
 	struct iphdr *iph;
 
 	/* We support EtherII and VLAN encapsulated IPv4 */
-	eh = (struct ethhdr *)(page_address(frag->page) + frag->page_offset);
+	eh = page_address(frag->page) + frag->page_offset;
 	*mac_hdr = eh;
 
 	if (eh->h_proto == htons(ETH_P_IP)) {
@@ -283,7 +283,7 @@ static inline int efx_init_rx_buffer_page(struct efx_rx_queue *rx_queue,
 
 		rx_queue->buf_page = rx_buf->page;
 		rx_queue->buf_dma_addr = dma_addr;
-		rx_queue->buf_data = ((char *) page_address(rx_buf->page) +
+		rx_queue->buf_data = (page_address(rx_buf->page) +
 				      EFX_PAGE_IP_ALIGN);
 	}
 
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 2fb69d8..c98f350 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -290,7 +290,7 @@ void efx_loopback_rx_packet(struct efx_nic *efx,
 
 	payload = &state->payload;
 	
-	received = (struct efx_loopback_payload *)(char *) buf_ptr;
+	received = (struct efx_loopback_payload *) buf_ptr;
 	received->ip.saddr = payload->ip.saddr;
 	received->ip.check = payload->ip.check;
 	
@@ -700,7 +700,7 @@ int efx_offline_test(struct efx_nic *efx,
 	 * "flushing" so all inflight packets are dropped */
 	BUG_ON(efx->loopback_selftest);
 	state->flush = 1;
-	efx->loopback_selftest = (void *)state;
+	efx->loopback_selftest = state;
 
 	rc = efx_test_loopbacks(efx, tests, loopback_modes);
 
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index 3b9f9dd..cf75fab 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -85,7 +85,7 @@ static int xfp_phy_init(struct efx_nic *efx)
 	int rc;
 
 	phy_data = kzalloc(sizeof(struct xfp_phy_data), GFP_KERNEL);
-	efx->phy_data = (void *) phy_data;
+	efx->phy_data = phy_data;
 
 	EFX_INFO(efx, "XFP: PHY ID reg %x (OUI %x model %x revision"
 		 " %x)\n", devid, MDIO_ID_OUI(devid), MDIO_ID_MODEL(devid),

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
