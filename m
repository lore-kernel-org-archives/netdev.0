From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 12/12] net: axienet: Fix kernel-doc warnings
Date: Tue,  5 May 2015 11:26:05 +0200
Message-ID: <d38bee299b8daeb4fbd267d8864be6edd168e37e.1430817941.git.michal.simek@xilinx.com>
References: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
Cc: =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
	monstr@monstr.eu, John Linn <John.Linn@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:36555 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031468AbbEEJ0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 05:26:41 -0400
Received: by wgiu9 with SMTP id u9so12642874wgi.3
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 02:26:40 -0700 (PDT)
In-Reply-To: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
In-Reply-To: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
References: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch remove kernel-doc warnings.

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/xilinx/xilinx_axienet.h      |  6 +++-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 38 ++++++++++++++---------
 drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c |  6 ++--
 3 files changed, 32 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet.h b/drivers/net/ethernet/xilinx/xilinx_axienet.h
index 2aa6857f930e..7cb9abac95c8 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet.h
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet.h
@@ -411,6 +411,10 @@ struct axidma_bd {
  *		  supported, the maximum frame size would be 9k. Else it is
  *		  1522 bytes (assuming support for basic VLAN)
  * @rxmem:	Stores rx memory size for jumbo frame handling.
+ * @csum_offload_on_tx_path:	Stores the checksum selection on TX side.
+ * @csum_offload_on_rx_path:	Stores the checksum selection on RX side.
+ * @coalesce_count_rx:	Store the irq coalesce on RX side.
+ * @coalesce_count_tx:	Store the irq coalesce on TX side.
  */
 struct axienet_local {
 	struct net_device *ndev;
@@ -474,7 +478,7 @@ struct axienet_option {
  * @lp:         Pointer to axienet local structure
  * @offset:     Address offset from the base address of Axi Ethernet core
  *
- * returns: The contents of the Axi Ethernet register
+ * Return: The contents of the Axi Ethernet register
  *
  * This function returns the contents of the corresponding register.
  */
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 1781265e3dc3..4208dd7ef101 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -117,7 +117,7 @@ static struct axienet_option axienet_options[] = {
  * @lp:		Pointer to axienet local structure
  * @reg:	Address offset from the base address of the Axi DMA core
  *
- * returns: The contents of the Axi DMA register
+ * Return: The contents of the Axi DMA register
  *
  * This function returns the contents of the corresponding Axi DMA register.
  */
@@ -179,8 +179,7 @@ static void axienet_dma_bd_release(struct net_device *ndev)
  * axienet_dma_bd_init - Setup buffer descriptor rings for Axi DMA
  * @ndev:	Pointer to the net_device structure
  *
- * returns: 0, on success
- *	    -ENOMEM, on failure
+ * Return: 0, on success -ENOMEM, on failure
  *
  * This function is called to initialize the Rx and Tx DMA descriptor
  * rings. This initializes the descriptors with required default values
@@ -320,7 +319,7 @@ static void axienet_set_mac_address(struct net_device *ndev, void *address)
  * @ndev:	Pointer to the net_device structure
  * @p:		6 byte Address to be written as MAC address
  *
- * returns: 0 for all conditions. Presently, there is no failure case.
+ * Return: 0 for all conditions. Presently, there is no failure case.
  *
  * This function is called to initialize the MAC address of the Axi Ethernet
  * core. It calls the core specific axienet_set_mac_address. This is the
@@ -622,7 +621,7 @@ static void axienet_start_xmit_done(struct net_device *ndev)
  * @lp:		Pointer to the axienet_local structure
  * @num_frag:	The number of BDs to check for
  *
- * returns: 0, on success
+ * Return: 0, on success
  *	    NETDEV_TX_BUSY, if any of the descriptors are not free
  *
  * This function is invoked before BDs are allocated and transmission starts.
@@ -645,7 +644,7 @@ static inline int axienet_check_tx_bd_space(struct axienet_local *lp,
  * @skb:	sk_buff pointer that contains data to be Txed.
  * @ndev:	Pointer to net_device structure.
  *
- * returns: NETDEV_TX_OK, on success
+ * Return: NETDEV_TX_OK, on success
  *	    NETDEV_TX_BUSY, if any of the descriptors are not free
  *
  * This function is invoked from upper layers to initiate transmission. The
@@ -800,7 +799,7 @@ static void axienet_recv(struct net_device *ndev)
  * @irq:	irq number
  * @_ndev:	net_device pointer
  *
- * returns: IRQ_HANDLED for all cases.
+ * Return: IRQ_HANDLED for all cases.
  *
  * This is the Axi DMA Tx done Isr. It invokes "axienet_start_xmit_done"
  * to complete the BD processing.
@@ -849,7 +848,7 @@ out:
  * @irq:	irq number
  * @_ndev:	net_device pointer
  *
- * returns: IRQ_HANDLED for all cases.
+ * Return: IRQ_HANDLED for all cases.
  *
  * This is the Axi DMA Rx Isr. It invokes "axienet_recv" to complete the BD
  * processing.
@@ -899,7 +898,7 @@ static void axienet_dma_err_handler(unsigned long data);
  * axienet_open - Driver open routine.
  * @ndev:	Pointer to net_device structure
  *
- * returns: 0, on success.
+ * Return: 0, on success.
  *	    -ENODEV, if PHY cannot be connected to
  *	    non-zero error value on failure
  *
@@ -980,7 +979,7 @@ err_tx_irq:
  * axienet_stop - Driver stop routine.
  * @ndev:	Pointer to net_device structure
  *
- * returns: 0, on success.
+ * Return: 0, on success.
  *
  * This is the driver stop routine. It calls phy_disconnect to stop the PHY
  * device. It also removes the interrupt handlers and disables the interrupts.
@@ -1020,7 +1019,7 @@ static int axienet_stop(struct net_device *ndev)
  * @ndev:	Pointer to net_device structure
  * @new_mtu:	New mtu value to be applied
  *
- * returns: Always returns 0 (success).
+ * Return: Always returns 0 (success).
  *
  * This is the change mtu driver routine. It checks if the Axi Ethernet
  * hardware supports jumbo frames before changing the mtu. This can be
@@ -1087,6 +1086,8 @@ static const struct net_device_ops axienet_netdev_ops = {
  * not be found, the function returns -ENODEV. This function calls the
  * relevant PHY ethtool API to get the PHY settings.
  * Issue "ethtool ethX" under linux prompt to execute this function.
+ *
+ * Return: 0 on success, -ENODEV if PHY doesn't exist
  */
 static int axienet_ethtools_get_settings(struct net_device *ndev,
 					 struct ethtool_cmd *ecmd)
@@ -1108,6 +1109,8 @@ static int axienet_ethtools_get_settings(struct net_device *ndev,
  * relevant PHY ethtool API to set the PHY.
  * Issue e.g. "ethtool -s ethX speed 1000" under linux prompt to execute this
  * function.
+ *
+ * Return: 0 on success, -ENODEV if PHY doesn't exist
  */
 static int axienet_ethtools_set_settings(struct net_device *ndev,
 					 struct ethtool_cmd *ecmd)
@@ -1142,6 +1145,8 @@ static void axienet_ethtools_get_drvinfo(struct net_device *ndev,
  *
  * This implements ethtool command for getting the total register length
  * information.
+ *
+ * Return: the total regs length
  */
 static int axienet_ethtools_get_regs_len(struct net_device *ndev)
 {
@@ -1228,11 +1233,13 @@ axienet_ethtools_get_pauseparam(struct net_device *ndev,
  * axienet_ethtools_set_pauseparam - Set device pause parameter(flow control)
  *				     settings.
  * @ndev:	Pointer to net_device structure
- * @epauseparam:Pointer to ethtool_pauseparam structure
+ * @epauseparm:Pointer to ethtool_pauseparam structure
  *
  * This implements ethtool command for enabling flow control on Rx and Tx
  * paths. Issue "ethtool -A ethX tx on|off" under linux prompt to execute this
  * function.
+ *
+ * Return: 0 on success, -EFAULT if device is running
  */
 static int
 axienet_ethtools_set_pauseparam(struct net_device *ndev,
@@ -1269,6 +1276,8 @@ axienet_ethtools_set_pauseparam(struct net_device *ndev,
  * This implements ethtool command for getting the DMA interrupt coalescing
  * count on Tx and Rx paths. Issue "ethtool -c ethX" under linux prompt to
  * execute this function.
+ *
+ * Return: 0 always
  */
 static int axienet_ethtools_get_coalesce(struct net_device *ndev,
 					 struct ethtool_coalesce *ecoalesce)
@@ -1292,6 +1301,8 @@ static int axienet_ethtools_get_coalesce(struct net_device *ndev,
  * This implements ethtool command for setting the DMA interrupt coalescing
  * count on Tx and Rx paths. Issue "ethtool -C ethX rx-frames 5" under linux
  * prompt to execute this function.
+ *
+ * Return: 0, on success, Non-zero error value on failure.
  */
 static int axienet_ethtools_set_coalesce(struct net_device *ndev,
 					 struct ethtool_coalesce *ecoalesce)
@@ -1481,9 +1492,8 @@ static void axienet_dma_err_handler(unsigned long data)
 /**
  * axienet_probe - Axi Ethernet probe function.
  * @pdev:	Pointer to platform device structure.
- * @match:	Pointer to device id structure
  *
- * returns: 0, on success
+ * Return: 0, on success
  *	    Non-zero error value on failure.
  *
  * This is the probe routine for Axi Ethernet driver. This is called before
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c b/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c
index 315136db37c9..2a5a16834c01 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c
@@ -37,7 +37,7 @@ int axienet_mdio_wait_until_ready(struct axienet_local *lp)
  * @phy_id:	Address of the PHY device
  * @reg:	PHY register to read
  *
- * returns:	The register contents on success, -ETIMEDOUT on a timeout
+ * Return:	The register contents on success, -ETIMEDOUT on a timeout
  *
  * Reads the contents of the requested register from the requested PHY
  * address by first writing the details into MCR register. After a while
@@ -80,7 +80,7 @@ static int axienet_mdio_read(struct mii_bus *bus, int phy_id, int reg)
  * @reg:	PHY register to write to
  * @val:	Value to be written into the register
  *
- * returns:	0 on success, -ETIMEDOUT on a timeout
+ * Return:	0 on success, -ETIMEDOUT on a timeout
  *
  * Writes the value to the requested register by first writing the value
  * into MWD register. The the MCR register is then appropriately setup
@@ -119,7 +119,7 @@ static int axienet_mdio_write(struct mii_bus *bus, int phy_id, int reg,
  * @lp:		Pointer to axienet local data structure.
  * @np:		Pointer to device node
  *
- * returns:	0 on success, -ETIMEDOUT on a timeout, -ENOMEM when
+ * Return:	0 on success, -ETIMEDOUT on a timeout, -ENOMEM when
  *		mdiobus_alloc (to allocate memory for mii bus structure) fails.
  *
  * Sets up the MDIO interface by initializing the MDIO clock and enabling the
-- 
2.3.5
