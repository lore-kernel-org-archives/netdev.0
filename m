From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 09/10] sfc: Fix some incorrect or redundant comments
Date: Wed, 03 Feb 2010 19:31:57 +0000
Message-ID: <1265225517.2116.9.camel@achroite.uk.solarflarecom.com>
References: <1265225294.2116.1.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:28124 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757368Ab0BCTcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 14:32:00 -0500
In-Reply-To: <1265225294.2116.1.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In particular, the comment about EVQ_RPTR_REG is based on inconsistent
preliminary hardware documentation, though the following code was
fixed long before release.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c    |    4 ++--
 drivers/net/sfc/falcon.c     |    2 +-
 drivers/net/sfc/net_driver.h |   12 ++++--------
 drivers/net/sfc/nic.c        |    4 ----
 4 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 635c420..d9f9c02 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -196,7 +196,7 @@ int efx_ethtool_get_settings(struct net_device *net_dev,
 	efx->phy_op->get_settings(efx, ecmd);
 	mutex_unlock(&efx->mac_lock);
 
-	/* Falcon GMAC does not support 1000Mbps HD */
+	/* GMAC does not support 1000Mbps HD */
 	ecmd->supported &= ~SUPPORTED_1000baseT_Half;
 	/* Both MACs support pause frames (bidirectional and respond-only) */
 	ecmd->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
@@ -216,7 +216,7 @@ int efx_ethtool_set_settings(struct net_device *net_dev,
 	struct efx_nic *efx = netdev_priv(net_dev);
 	int rc;
 
-	/* Falcon GMAC does not support 1000Mbps HD */
+	/* GMAC does not support 1000Mbps HD */
 	if (ecmd->speed == SPEED_1000 && ecmd->duplex != DUPLEX_FULL) {
 		EFX_LOG(efx, "rejecting unsupported 1000Mbps HD"
 			" setting\n");
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index f63a32c..1b8d836 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1730,7 +1730,7 @@ static int falcon_set_wol(struct efx_nic *efx, u32 type)
 
 /**************************************************************************
  *
- * Revision-dependent attributes used by efx.c
+ * Revision-dependent attributes used by efx.c and nic.c
  *
  **************************************************************************
  */
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 8f951e4..ac77a25 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -101,9 +101,6 @@ do {if (net_ratelimit()) EFX_LOG(efx, fmt, ##args); } while (0)
  * Special buffers are used for the event queues and the TX and RX
  * descriptor queues for each channel.  They are *not* used for the
  * actual transmit and receive buffers.
- *
- * Note that for Falcon, TX and RX descriptor queues live in host memory.
- * Allocation and freeing procedures must take this into account.
  */
 struct efx_special_buffer {
 	void *addr;
@@ -300,7 +297,7 @@ struct efx_rx_queue {
  * @dma_addr: DMA base address of the buffer
  * @len: Buffer length, in bytes
  *
- * Falcon uses these buffers for its interrupt status registers and
+ * The NIC uses these buffers for its interrupt status registers and
  * MAC stats dumps.
  */
 struct efx_buffer {
@@ -674,7 +671,7 @@ union efx_multicast_hash {
  * @irq_status: Interrupt status buffer
  * @last_irq_cpu: Last CPU to handle interrupt.
  *	This register is written with the SMP processor ID whenever an
- *	interrupt is handled.  It is used by falcon_test_interrupt()
+ *	interrupt is handled.  It is used by efx_nic_test_interrupt()
  *	to verify that an interrupt has occurred.
  * @spi_flash: SPI flash device
  *	This field will be %NULL if no flash device is present (or for Siena).
@@ -723,8 +720,7 @@ union efx_multicast_hash {
  * @loopback_modes: Supported loopback mode bitmask
  * @loopback_selftest: Offline self-test private state
  *
- * The @priv field of the corresponding &struct net_device points to
- * this.
+ * This is stored in the private area of the &struct net_device.
  */
 struct efx_nic {
 	char name[IFNAMSIZ];
@@ -997,7 +993,7 @@ static inline void clear_bit_le(unsigned nr, unsigned char *addr)
  * that the net driver will program into the MAC as the maximum frame
  * length.
  *
- * The 10G MAC used in Falcon requires 8-byte alignment on the frame
+ * The 10G MAC requires 8-byte alignment on the frame
  * length, so we round up to the nearest 8.
  *
  * Re-clocking by the XGXS on RX can reduce an IPG to 32 bits (half an
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index 8d9696a..b06f8e3 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -623,10 +623,6 @@ void efx_nic_remove_rx(struct efx_rx_queue *rx_queue)
  *
  * This writes the EVQ_RPTR_REG register for the specified channel's
  * event queue.
- *
- * Note that EVQ_RPTR_REG contains the index of the "last read" event,
- * whereas channel->eventq_read_ptr contains the index of the "next to
- * read" event.
  */
 void efx_nic_eventq_read_ack(struct efx_channel *channel)
 {
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

