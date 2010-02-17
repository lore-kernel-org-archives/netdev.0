From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 1/2] Staging: Octeon: Reformat a bunch of comments.
Date: Tue, 16 Feb 2010 17:25:32 -0800
Message-ID: <1266369933-1282-1-git-send-email-ddaney@caviumnetworks.com>
References: <4B7B4540.1010700@caviumnetworks.com>
Cc: David Daney <ddaney@caviumnetworks.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:6666 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933846Ab0BQBZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 20:25:45 -0500
In-Reply-To: <4B7B4540.1010700@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many of the comments didn't follow kerneldoc guidlines.

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 drivers/staging/octeon/ethernet-mdio.c   |    6 ++--
 drivers/staging/octeon/ethernet-mem.c    |   16 +++++-----
 drivers/staging/octeon/ethernet-rx.c     |   17 ++++++-----
 drivers/staging/octeon/ethernet-tx.c     |   14 +++++-----
 drivers/staging/octeon/ethernet-util.h   |   13 +++------
 drivers/staging/octeon/ethernet.c        |   42 +++++++++--------------------
 drivers/staging/octeon/octeon-ethernet.h |    7 -----
 7 files changed, 44 insertions(+), 71 deletions(-)

diff --git a/drivers/staging/octeon/ethernet-mdio.c b/drivers/staging/octeon/ethernet-mdio.c
index 05a5cc0..7e0be8d 100644
--- a/drivers/staging/octeon/ethernet-mdio.c
+++ b/drivers/staging/octeon/ethernet-mdio.c
@@ -96,11 +96,11 @@ const struct ethtool_ops cvm_oct_ethtool_ops = {
 };
 
 /**
- * IOCTL support for PHY control
- *
+ * cvm_oct_ioctl - IOCTL support for PHY control
  * @dev:    Device to change
  * @rq:     the request
  * @cmd:    the command
+ *
  * Returns Zero on success
  */
 int cvm_oct_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
@@ -153,7 +153,7 @@ static void cvm_oct_adjust_link(struct net_device *dev)
 
 
 /**
- * Setup the PHY
+ * cvm_oct_phy_setup_device - setup the PHY
  *
  * @dev:    Device to setup
  *
diff --git a/drivers/staging/octeon/ethernet-mem.c b/drivers/staging/octeon/ethernet-mem.c
index 53ed2f7..00cc91d 100644
--- a/drivers/staging/octeon/ethernet-mem.c
+++ b/drivers/staging/octeon/ethernet-mem.c
@@ -34,11 +34,12 @@
 #include "cvmx-fpa.h"
 
 /**
- * Fill the supplied hardware pool with skbuffs
- *
+ * cvm_oct_fill_hw_skbuff - fill the supplied hardware pool with skbuffs
  * @pool:     Pool to allocate an skbuff for
  * @size:     Size of the buffer needed for the pool
  * @elements: Number of buffers to allocate
+ *
+ * Returns the actual number of buffers allocated.
  */
 static int cvm_oct_fill_hw_skbuff(int pool, int size, int elements)
 {
@@ -62,8 +63,7 @@ static int cvm_oct_fill_hw_skbuff(int pool, int size, int elements)
 }
 
 /**
- * Free the supplied hardware pool of skbuffs
- *
+ * cvm_oct_free_hw_skbuff- free hardware pool skbuffs
  * @pool:     Pool to allocate an skbuff for
  * @size:     Size of the buffer needed for the pool
  * @elements: Number of buffers to allocate
@@ -91,11 +91,12 @@ static void cvm_oct_free_hw_skbuff(int pool, int size, int elements)
 }
 
 /**
- * This function fills a hardware pool with memory.
- *
+ * cvm_oct_fill_hw_memory - fill a hardware pool with memory.
  * @pool:     Pool to populate
  * @size:     Size of each buffer in the pool
  * @elements: Number of buffers to allocate
+ *
+ * Returns the actual number of buffers allocated.
  */
 static int cvm_oct_fill_hw_memory(int pool, int size, int elements)
 {
@@ -129,8 +130,7 @@ static int cvm_oct_fill_hw_memory(int pool, int size, int elements)
 }
 
 /**
- * Free memory previously allocated with cvm_oct_fill_hw_memory
- *
+ * cvm_oct_free_hw_memory - Free memory allocated by cvm_oct_fill_hw_memory
  * @pool:     FPA pool to free
  * @size:     Size of each buffer in the pool
  * @elements: Number of buffers that should be in the pool
diff --git a/drivers/staging/octeon/ethernet-rx.c b/drivers/staging/octeon/ethernet-rx.c
index b2e6ab6..cb38f9e 100644
--- a/drivers/staging/octeon/ethernet-rx.c
+++ b/drivers/staging/octeon/ethernet-rx.c
@@ -124,8 +124,9 @@ static void cvm_oct_no_more_work(void)
 }
 
 /**
- * Interrupt handler. The interrupt occurs whenever the POW
- * has packets in our group.
+ * cvm_oct_do_interrupt - interrupt handler.
+ *
+ * The interrupt occurs whenever the POW has packets in our group.
  *
  */
 static irqreturn_t cvm_oct_do_interrupt(int cpl, void *dev_id)
@@ -138,10 +139,9 @@ static irqreturn_t cvm_oct_do_interrupt(int cpl, void *dev_id)
 }
 
 /**
- * This is called on receive errors, and determines if the packet
- * can be dropped early-on in cvm_oct_tasklet_rx().
- *
+ * cvm_oct_check_rcv_error - process receive errors
  * @work: Work queue entry pointing to the packet.
+ *
  * Returns Non-zero if the packet can be dropped, zero otherwise.
  */
 static inline int cvm_oct_check_rcv_error(cvmx_wqe_t *work)
@@ -224,10 +224,11 @@ static inline int cvm_oct_check_rcv_error(cvmx_wqe_t *work)
 }
 
 /**
- * The NAPI poll function.
- *
+ * cvm_oct_napi_poll - the NAPI poll function.
  * @napi: The NAPI instance, or null if called from cvm_oct_poll_controller
  * @budget: Maximum number of packets to receive.
+ *
+ * Returns the number of packets processed.
  */
 static int cvm_oct_napi_poll(struct napi_struct *napi, int budget)
 {
@@ -484,7 +485,7 @@ static int cvm_oct_napi_poll(struct napi_struct *napi, int budget)
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /**
- * This is called when the kernel needs to manually poll the
+ * cvm_oct_poll_controller - poll for receive packets
  * device.
  *
  * @dev:    Device to poll. Unused
diff --git a/drivers/staging/octeon/ethernet-tx.c b/drivers/staging/octeon/ethernet-tx.c
index 5175247..afc2b73 100644
--- a/drivers/staging/octeon/ethernet-tx.c
+++ b/drivers/staging/octeon/ethernet-tx.c
@@ -137,11 +137,11 @@ void cvm_oct_free_tx_skbs(struct net_device *dev)
 }
 
 /**
- * Packet transmit
- *
+ * cvm_oct_xmit - transmit a packet
  * @skb:    Packet to send
  * @dev:    Device info structure
- * Returns Always returns zero
+ *
+ * Returns Always returns NETDEV_TX_OK
  */
 int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 {
@@ -510,10 +510,10 @@ skip_xmit:
 }
 
 /**
- * Packet transmit to the POW
- *
+ * cvm_oct_xmit_pow - transmit a packet to the POW
  * @skb:    Packet to send
  * @dev:    Device info structure
+
  * Returns Always returns zero
  */
 int cvm_oct_xmit_pow(struct sk_buff *skb, struct net_device *dev)
@@ -661,9 +661,9 @@ int cvm_oct_xmit_pow(struct sk_buff *skb, struct net_device *dev)
 }
 
 /**
- * This function frees all skb that are currently queued for TX.
- *
+ * cvm_oct_tx_shutdown_dev - free all skb that are currently queued for TX.
  * @dev:    Device being shutdown
+ *
  */
 void cvm_oct_tx_shutdown_dev(struct net_device *dev)
 {
diff --git a/drivers/staging/octeon/ethernet-util.h b/drivers/staging/octeon/ethernet-util.h
index 37b6659..2346756 100644
--- a/drivers/staging/octeon/ethernet-util.h
+++ b/drivers/staging/octeon/ethernet-util.h
@@ -30,10 +30,9 @@
 				} while (0)
 
 /**
- * Given a packet data address, return a pointer to the
- * beginning of the packet buffer.
- *
+ * cvm_oct_get_buffer_ptr - convert packet data address to pointer
  * @packet_ptr: Packet data hardware address
+ *
  * Returns Packet buffer pointer
  */
 static inline void *cvm_oct_get_buffer_ptr(union cvmx_buf_ptr packet_ptr)
@@ -43,9 +42,7 @@ static inline void *cvm_oct_get_buffer_ptr(union cvmx_buf_ptr packet_ptr)
 }
 
 /**
- * Given an IPD/PKO port number, return the logical interface it is
- * on.
- *
+ * INTERFACE - convert IPD port to locgical interface
  * @ipd_port: Port to check
  *
  * Returns Logical interface
@@ -65,9 +62,7 @@ static inline int INTERFACE(int ipd_port)
 }
 
 /**
- * Given an IPD/PKO port number, return the port's index on a
- * logical interface.
- *
+ * INDEX - convert IPD/PKO port number to the port's interface index
  * @ipd_port: Port to check
  *
  * Returns Index into interface port list
diff --git a/drivers/staging/octeon/ethernet.c b/drivers/staging/octeon/ethernet.c
index 5ee60ab..45cb4c7 100644
--- a/drivers/staging/octeon/ethernet.c
+++ b/drivers/staging/octeon/ethernet.c
@@ -176,9 +176,6 @@ static void cvm_oct_periodic_worker(struct work_struct *work)
 		queue_delayed_work(cvm_oct_poll_queue, &priv->port_periodic_work, HZ);
  }
 
-/**
- * Configure common hardware for all interfaces
- */
 static __init void cvm_oct_configure_common_hw(void)
 {
 	/* Setup the FPA */
@@ -198,10 +195,10 @@ static __init void cvm_oct_configure_common_hw(void)
 }
 
 /**
- * Free a work queue entry received in a intercept callback.
+ * cvm_oct_free_work- Free a work queue entry
+ *
+ * @work_queue_entry: Work queue entry to free
  *
- * @work_queue_entry:
- *               Work queue entry to free
  * Returns Zero on success, Negative on failure.
  */
 int cvm_oct_free_work(void *work_queue_entry)
@@ -228,9 +225,9 @@ int cvm_oct_free_work(void *work_queue_entry)
 EXPORT_SYMBOL(cvm_oct_free_work);
 
 /**
- * Get the low level ethernet statistics
- *
+ * cvm_oct_common_get_stats - get the low level ethernet statistics
  * @dev:    Device to get the statistics from
+ *
  * Returns Pointer to the statistics
  */
 static struct net_device_stats *cvm_oct_common_get_stats(struct net_device *dev)
@@ -274,8 +271,7 @@ static struct net_device_stats *cvm_oct_common_get_stats(struct net_device *dev)
 }
 
 /**
- * Change the link MTU. Unimplemented
- *
+ * cvm_oct_common_change_mtu - change the link MTU
  * @dev:     Device to change
  * @new_mtu: The new MTU
  *
@@ -339,8 +335,7 @@ static int cvm_oct_common_change_mtu(struct net_device *dev, int new_mtu)
 }
 
 /**
- * Set the multicast list. Currently unimplemented.
- *
+ * cvm_oct_common_set_multicast_list - set the multicast list
  * @dev:    Device to work on
  */
 static void cvm_oct_common_set_multicast_list(struct net_device *dev)
@@ -395,10 +390,10 @@ static void cvm_oct_common_set_multicast_list(struct net_device *dev)
 }
 
 /**
- * Set the hardware MAC address for a device
- *
- * @dev:    Device to change the MAC address for
- * @addr:   Address structure to change it too. MAC address is addr + 2.
+ * cvm_oct_common_set_mac_address - set the hardware MAC address for a device
+ * @dev:    The device in question.
+ * @addr:   Address structure to change it too.
+
  * Returns Zero on success
  */
 static int cvm_oct_common_set_mac_address(struct net_device *dev, void *addr)
@@ -445,9 +440,9 @@ static int cvm_oct_common_set_mac_address(struct net_device *dev, void *addr)
 }
 
 /**
- * Per network device initialization
- *
+ * cvm_oct_common_init - per network device initialization
  * @dev:    Device to initialize
+ *
  * Returns Zero on success
  */
 int cvm_oct_common_init(struct net_device *dev)
@@ -603,12 +598,6 @@ static const struct net_device_ops cvm_oct_pow_netdev_ops = {
 
 extern void octeon_mdiobus_force_mod_depencency(void);
 
-/**
- * Module/ driver initialization. Creates the linux network
- * devices.
- *
- * Returns Zero on success
- */
 static int __init cvm_oct_init_module(void)
 {
 	int num_interfaces;
@@ -802,11 +791,6 @@ static int __init cvm_oct_init_module(void)
 	return 0;
 }
 
-/**
- * Module / driver shutdown
- *
- * Returns Zero on success
- */
 static void __exit cvm_oct_cleanup_module(void)
 {
 	int port;
diff --git a/drivers/staging/octeon/octeon-ethernet.h b/drivers/staging/octeon/octeon-ethernet.h
index db2a3cc..d581925 100644
--- a/drivers/staging/octeon/octeon-ethernet.h
+++ b/drivers/staging/octeon/octeon-ethernet.h
@@ -61,13 +61,6 @@ struct octeon_ethernet {
 	struct work_struct	port_work;	/* may be unused. */
 };
 
-/**
- * Free a work queue entry received in a intercept callback.
- *
- * @work_queue_entry:
- *               Work queue entry to free
- * Returns Zero on success, Negative on failure.
- */
 int cvm_oct_free_work(void *work_queue_entry);
 
 extern int cvm_oct_rgmii_init(struct net_device *dev);
-- 
1.6.6

