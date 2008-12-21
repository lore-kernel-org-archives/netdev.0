From: Brice Goglin <brice@myri.com>
Subject: [PATCH net-next] myri10ge: update firmware headers to 1.4.37
Date: Sun, 21 Dec 2008 22:27:28 +0100
Message-ID: <494EB4C0.4090707@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1920 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751171AbYLUV1p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Dec 2008 16:27:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update myri10ge firmware headers to 1.4.37:
* Make each member of the error/cmd enum an initialized one, so there
  is a convenient numerical reference to look for reverse conversion.
* Add new MXGEFW_CMD_RELAX_RXBUFFER_ALIGNMENT command.
* Add new "features" field to mcp_header.

Signed-off-by: Brice Goglin <brice@myri.com>

--- net-next-2.6/drivers/net/myri10ge/myri10ge_mcp.h	2008-11-23 14:39:42.000000000 +0100
+++ linux-tmp/drivers/net/myri10ge/myri10ge_mcp.h	2008-12-21 22:07:52.000000000 +0100
@@ -111,61 +111,61 @@
 	MXGEFW_CMD_NONE = 0,
 	/* Reset the mcp, it is left in a safe state, waiting
 	 * for the driver to set all its parameters */
-	MXGEFW_CMD_RESET,
+	MXGEFW_CMD_RESET = 1,
 
 	/* get the version number of the current firmware..
 	 * (may be available in the eeprom strings..? */
-	MXGEFW_GET_MCP_VERSION,
+	MXGEFW_GET_MCP_VERSION = 2,
 
 	/* Parameters which must be set by the driver before it can
 	 * issue MXGEFW_CMD_ETHERNET_UP. They persist until the next
 	 * MXGEFW_CMD_RESET is issued */
 
-	MXGEFW_CMD_SET_INTRQ_DMA,
+	MXGEFW_CMD_SET_INTRQ_DMA = 3,
 	/* data0 = LSW of the host address
 	 * data1 = MSW of the host address
 	 * data2 = slice number if multiple slices are used
 	 */
 
-	MXGEFW_CMD_SET_BIG_BUFFER_SIZE,	/* in bytes, power of 2 */
-	MXGEFW_CMD_SET_SMALL_BUFFER_SIZE,	/* in bytes */
+	MXGEFW_CMD_SET_BIG_BUFFER_SIZE = 4,	/* in bytes, power of 2 */
+	MXGEFW_CMD_SET_SMALL_BUFFER_SIZE = 5,	/* in bytes */
 
 	/* Parameters which refer to lanai SRAM addresses where the
 	 * driver must issue PIO writes for various things */
 
-	MXGEFW_CMD_GET_SEND_OFFSET,
-	MXGEFW_CMD_GET_SMALL_RX_OFFSET,
-	MXGEFW_CMD_GET_BIG_RX_OFFSET,
+	MXGEFW_CMD_GET_SEND_OFFSET = 6,
+	MXGEFW_CMD_GET_SMALL_RX_OFFSET = 7,
+	MXGEFW_CMD_GET_BIG_RX_OFFSET = 8,
 	/* data0 = slice number if multiple slices are used */
 
-	MXGEFW_CMD_GET_IRQ_ACK_OFFSET,
-	MXGEFW_CMD_GET_IRQ_DEASSERT_OFFSET,
+	MXGEFW_CMD_GET_IRQ_ACK_OFFSET = 9,
+	MXGEFW_CMD_GET_IRQ_DEASSERT_OFFSET = 10,
 
 	/* Parameters which refer to rings stored on the MCP,
 	 * and whose size is controlled by the mcp */
 
-	MXGEFW_CMD_GET_SEND_RING_SIZE,	/* in bytes */
-	MXGEFW_CMD_GET_RX_RING_SIZE,	/* in bytes */
+	MXGEFW_CMD_GET_SEND_RING_SIZE = 11,	/* in bytes */
+	MXGEFW_CMD_GET_RX_RING_SIZE = 12,	/* in bytes */
 
 	/* Parameters which refer to rings stored in the host,
 	 * and whose size is controlled by the host.  Note that
 	 * all must be physically contiguous and must contain
 	 * a power of 2 number of entries.  */
 
-	MXGEFW_CMD_SET_INTRQ_SIZE,	/* in bytes */
+	MXGEFW_CMD_SET_INTRQ_SIZE = 13,	/* in bytes */
 #define MXGEFW_CMD_SET_INTRQ_SIZE_FLAG_NO_STRICT_SIZE_CHECK  (1 << 31)
 
 	/* command to bring ethernet interface up.  Above parameters
 	 * (plus mtu & mac address) must have been exchanged prior
 	 * to issuing this command  */
-	MXGEFW_CMD_ETHERNET_UP,
+	MXGEFW_CMD_ETHERNET_UP = 14,
 
 	/* command to bring ethernet interface down.  No further sends
 	 * or receives may be processed until an MXGEFW_CMD_ETHERNET_UP
 	 * is issued, and all interrupt queues must be flushed prior
 	 * to ack'ing this command */
 
-	MXGEFW_CMD_ETHERNET_DOWN,
+	MXGEFW_CMD_ETHERNET_DOWN = 15,
 
 	/* commands the driver may issue live, without resetting
 	 * the nic.  Note that increasing the mtu "live" should
@@ -173,40 +173,40 @@
 	 * sufficiently large to handle the new mtu.  Decreasing
 	 * the mtu live is safe */
 
-	MXGEFW_CMD_SET_MTU,
-	MXGEFW_CMD_GET_INTR_COAL_DELAY_OFFSET,	/* in microseconds */
-	MXGEFW_CMD_SET_STATS_INTERVAL,	/* in microseconds */
-	MXGEFW_CMD_SET_STATS_DMA_OBSOLETE,	/* replaced by SET_STATS_DMA_V2 */
-
-	MXGEFW_ENABLE_PROMISC,
-	MXGEFW_DISABLE_PROMISC,
-	MXGEFW_SET_MAC_ADDRESS,
+	MXGEFW_CMD_SET_MTU = 16,
+	MXGEFW_CMD_GET_INTR_COAL_DELAY_OFFSET = 17,	/* in microseconds */
+	MXGEFW_CMD_SET_STATS_INTERVAL = 18,	/* in microseconds */
+	MXGEFW_CMD_SET_STATS_DMA_OBSOLETE = 19,	/* replaced by SET_STATS_DMA_V2 */
+
+	MXGEFW_ENABLE_PROMISC = 20,
+	MXGEFW_DISABLE_PROMISC = 21,
+	MXGEFW_SET_MAC_ADDRESS = 22,
 
-	MXGEFW_ENABLE_FLOW_CONTROL,
-	MXGEFW_DISABLE_FLOW_CONTROL,
+	MXGEFW_ENABLE_FLOW_CONTROL = 23,
+	MXGEFW_DISABLE_FLOW_CONTROL = 24,
 
 	/* do a DMA test
 	 * data0,data1 = DMA address
 	 * data2       = RDMA length (MSH), WDMA length (LSH)
 	 * command return data = repetitions (MSH), 0.5-ms ticks (LSH)
 	 */
-	MXGEFW_DMA_TEST,
+	MXGEFW_DMA_TEST = 25,
 
-	MXGEFW_ENABLE_ALLMULTI,
-	MXGEFW_DISABLE_ALLMULTI,
+	MXGEFW_ENABLE_ALLMULTI = 26,
+	MXGEFW_DISABLE_ALLMULTI = 27,
 
 	/* returns MXGEFW_CMD_ERROR_MULTICAST
 	 * if there is no room in the cache
 	 * data0,MSH(data1) = multicast group address */
-	MXGEFW_JOIN_MULTICAST_GROUP,
+	MXGEFW_JOIN_MULTICAST_GROUP = 28,
 	/* returns MXGEFW_CMD_ERROR_MULTICAST
 	 * if the address is not in the cache,
 	 * or is equal to FF-FF-FF-FF-FF-FF
 	 * data0,MSH(data1) = multicast group address */
-	MXGEFW_LEAVE_MULTICAST_GROUP,
-	MXGEFW_LEAVE_ALL_MULTICAST_GROUPS,
+	MXGEFW_LEAVE_MULTICAST_GROUP = 29,
+	MXGEFW_LEAVE_ALL_MULTICAST_GROUPS = 30,
 
-	MXGEFW_CMD_SET_STATS_DMA_V2,
+	MXGEFW_CMD_SET_STATS_DMA_V2 = 31,
 	/* data0, data1 = bus addr,
 	 * data2 = sizeof(struct mcp_irq_data) from driver point of view, allows
 	 * adding new stuff to mcp_irq_data without changing the ABI
@@ -216,14 +216,14 @@
 	 * (in the upper 16 bits).
 	 */
 
-	MXGEFW_CMD_UNALIGNED_TEST,
+	MXGEFW_CMD_UNALIGNED_TEST = 32,
 	/* same than DMA_TEST (same args) but abort with UNALIGNED on unaligned
 	 * chipset */
 
-	MXGEFW_CMD_UNALIGNED_STATUS,
+	MXGEFW_CMD_UNALIGNED_STATUS = 33,
 	/* return data = boolean, true if the chipset is known to be unaligned */
 
-	MXGEFW_CMD_ALWAYS_USE_N_BIG_BUFFERS,
+	MXGEFW_CMD_ALWAYS_USE_N_BIG_BUFFERS = 34,
 	/* data0 = number of big buffers to use.  It must be 0 or a power of 2.
 	 * 0 indicates that the NIC consumes as many buffers as they are required
 	 * for packet. This is the default behavior.
@@ -233,8 +233,8 @@
 	 * the NIC to be able to receive maximum-sized packets.
 	 */
 
-	MXGEFW_CMD_GET_MAX_RSS_QUEUES,
-	MXGEFW_CMD_ENABLE_RSS_QUEUES,
+	MXGEFW_CMD_GET_MAX_RSS_QUEUES = 35,
+	MXGEFW_CMD_ENABLE_RSS_QUEUES = 36,
 	/* data0 = number of slices n (0, 1, ..., n-1) to enable
 	 * data1 = interrupt mode | use of multiple transmit queues.
 	 * 0=share one INTx/MSI.
@@ -249,18 +249,18 @@
 #define MXGEFW_SLICE_INTR_MODE_ONE_PER_SLICE   0x1
 #define MXGEFW_SLICE_ENABLE_MULTIPLE_TX_QUEUES 0x2
 
-	MXGEFW_CMD_GET_RSS_SHARED_INTERRUPT_MASK_OFFSET,
-	MXGEFW_CMD_SET_RSS_SHARED_INTERRUPT_DMA,
+	MXGEFW_CMD_GET_RSS_SHARED_INTERRUPT_MASK_OFFSET = 37,
+	MXGEFW_CMD_SET_RSS_SHARED_INTERRUPT_DMA = 38,
 	/* data0, data1 = bus address lsw, msw */
-	MXGEFW_CMD_GET_RSS_TABLE_OFFSET,
+	MXGEFW_CMD_GET_RSS_TABLE_OFFSET = 39,
 	/* get the offset of the indirection table */
-	MXGEFW_CMD_SET_RSS_TABLE_SIZE,
+	MXGEFW_CMD_SET_RSS_TABLE_SIZE = 40,
 	/* set the size of the indirection table */
-	MXGEFW_CMD_GET_RSS_KEY_OFFSET,
+	MXGEFW_CMD_GET_RSS_KEY_OFFSET = 41,
 	/* get the offset of the secret key */
-	MXGEFW_CMD_RSS_KEY_UPDATED,
+	MXGEFW_CMD_RSS_KEY_UPDATED = 42,
 	/* tell nic that the secret key's been updated */
-	MXGEFW_CMD_SET_RSS_ENABLE,
+	MXGEFW_CMD_SET_RSS_ENABLE = 43,
 	/* data0 = enable/disable rss
 	 * 0: disable rss.  nic does not distribute receive packets.
 	 * 1: enable rss.  nic distributes receive packets among queues.
@@ -277,7 +277,7 @@
 #define MXGEFW_RSS_HASH_TYPE_SRC_DST_PORT 0x5
 #define MXGEFW_RSS_HASH_TYPE_MAX 0x5
 
-	MXGEFW_CMD_GET_MAX_TSO6_HDR_SIZE,
+	MXGEFW_CMD_GET_MAX_TSO6_HDR_SIZE = 44,
 	/* Return data = the max. size of the entire headers of a IPv6 TSO packet.
 	 * If the header size of a IPv6 TSO packet is larger than the specified
 	 * value, then the driver must not use TSO.
@@ -286,7 +286,7 @@
 	 * always has enough header buffer to store maximum-sized headers.
 	 */
 
-	MXGEFW_CMD_SET_TSO_MODE,
+	MXGEFW_CMD_SET_TSO_MODE = 45,
 	/* data0 = TSO mode.
 	 * 0: Linux/FreeBSD style (NIC default)
 	 * 1: NDIS/NetBSD style
@@ -294,33 +294,37 @@
 #define MXGEFW_TSO_MODE_LINUX  0
 #define MXGEFW_TSO_MODE_NDIS   1
 
-	MXGEFW_CMD_MDIO_READ,
+	MXGEFW_CMD_MDIO_READ = 46,
 	/* data0 = dev_addr (PMA/PMD or PCS ...), data1 = register/addr */
-	MXGEFW_CMD_MDIO_WRITE,
+	MXGEFW_CMD_MDIO_WRITE = 47,
 	/* data0 = dev_addr,  data1 = register/addr, data2 = value  */
 
-	MXGEFW_CMD_XFP_I2C_READ,
-	/* Starts to get a fresh copy of one byte or of the whole xfp i2c table, the
+	MXGEFW_CMD_I2C_READ = 48,
+	/* Starts to get a fresh copy of one byte or of the module i2c table, the
 	 * obtained data is cached inside the xaui-xfi chip :
-	 *   data0 : "all" flag : 0 => get one byte, 1=> get 256 bytes,
-	 *   data1 : if (data0 == 0): index of byte to refresh [ not used otherwise ]
+	 *   data0 :  0 => get one byte, 1=> get 256 bytes
+	 *   data1 :  If data0 == 0: location to refresh
+	 *               bit 7:0  register location
+	 *               bit 8:15 is the i2c slave addr (0 is interpreted as 0xA1)
+	 *               bit 23:16 is the i2c bus number (for multi-port NICs)
+	 *            If data0 == 1: unused
 	 * The operation might take ~1ms for a single byte or ~65ms when refreshing all 256 bytes
-	 * During the i2c operation,  MXGEFW_CMD_XFP_I2C_READ or MXGEFW_CMD_XFP_BYTE attempts
+	 * During the i2c operation,  MXGEFW_CMD_I2C_READ or MXGEFW_CMD_I2C_BYTE attempts
 	 *  will return MXGEFW_CMD_ERROR_BUSY
 	 */
-	MXGEFW_CMD_XFP_BYTE,
+	MXGEFW_CMD_I2C_BYTE = 49,
 	/* Return the last obtained copy of a given byte in the xfp i2c table
-	 * (copy cached during the last relevant MXGEFW_CMD_XFP_I2C_READ)
+	 * (copy cached during the last relevant MXGEFW_CMD_I2C_READ)
 	 *   data0 : index of the desired table entry
 	 *  Return data = the byte stored at the requested index in the table
 	 */
 
-	MXGEFW_CMD_GET_VPUMP_OFFSET,
+	MXGEFW_CMD_GET_VPUMP_OFFSET = 50,
 	/* Return data = NIC memory offset of mcp_vpump_public_global */
-	MXGEFW_CMD_RESET_VPUMP,
+	MXGEFW_CMD_RESET_VPUMP = 51,
 	/* Resets the VPUMP state */
 
-	MXGEFW_CMD_SET_RSS_MCP_SLOT_TYPE,
+	MXGEFW_CMD_SET_RSS_MCP_SLOT_TYPE = 52,
 	/* data0 = mcp_slot type to use.
 	 * 0 = the default 4B mcp_slot
 	 * 1 = 8B mcp_slot_8
@@ -328,7 +332,7 @@
 #define MXGEFW_RSS_MCP_SLOT_TYPE_MIN        0
 #define MXGEFW_RSS_MCP_SLOT_TYPE_WITH_HASH  1
 
-	MXGEFW_CMD_SET_THROTTLE_FACTOR,
+	MXGEFW_CMD_SET_THROTTLE_FACTOR = 53,
 	/* set the throttle factor for ethp_z8e
 	 * data0 = throttle_factor
 	 * throttle_factor = 256 * pcie-raw-speed / tx_speed
@@ -344,45 +348,50 @@
 	 * with tx_boundary == 4096, max-throttle-factor == 4095 => min-speed == 1Gb/s
 	 */
 
-	MXGEFW_CMD_VPUMP_UP,
+	MXGEFW_CMD_VPUMP_UP = 54,
 	/* Allocates VPump Connection, Send Request and Zero copy buffer address tables */
-	MXGEFW_CMD_GET_VPUMP_CLK,
+	MXGEFW_CMD_GET_VPUMP_CLK = 55,
 	/* Get the lanai clock */
 
-	MXGEFW_CMD_GET_DCA_OFFSET,
+	MXGEFW_CMD_GET_DCA_OFFSET = 56,
 	/* offset of dca control for WDMAs */
 
 	/* VMWare NetQueue commands */
-	MXGEFW_CMD_NETQ_GET_FILTERS_PER_QUEUE,
-	MXGEFW_CMD_NETQ_ADD_FILTER,
+	MXGEFW_CMD_NETQ_GET_FILTERS_PER_QUEUE = 57,
+	MXGEFW_CMD_NETQ_ADD_FILTER = 58,
 	/* data0 = filter_id << 16 | queue << 8 | type */
 	/* data1 = MS4 of MAC Addr */
 	/* data2 = LS2_MAC << 16 | VLAN_tag */
-	MXGEFW_CMD_NETQ_DEL_FILTER,
+	MXGEFW_CMD_NETQ_DEL_FILTER = 59,
 	/* data0 = filter_id */
-	MXGEFW_CMD_NETQ_QUERY1,
-	MXGEFW_CMD_NETQ_QUERY2,
-	MXGEFW_CMD_NETQ_QUERY3,
-	MXGEFW_CMD_NETQ_QUERY4,
-
+	MXGEFW_CMD_NETQ_QUERY1 = 60,
+	MXGEFW_CMD_NETQ_QUERY2 = 61,
+	MXGEFW_CMD_NETQ_QUERY3 = 62,
+	MXGEFW_CMD_NETQ_QUERY4 = 63,
+
+	MXGEFW_CMD_RELAX_RXBUFFER_ALIGNMENT = 64,
+	/* When set, small receive buffers can cross page boundaries.
+	 * Both small and big receive buffers may start at any address.
+	 * This option has performance implications, so use with caution.
+	 */
 };
 
 enum myri10ge_mcp_cmd_status {
 	MXGEFW_CMD_OK = 0,
-	MXGEFW_CMD_UNKNOWN,
-	MXGEFW_CMD_ERROR_RANGE,
-	MXGEFW_CMD_ERROR_BUSY,
-	MXGEFW_CMD_ERROR_EMPTY,
-	MXGEFW_CMD_ERROR_CLOSED,
-	MXGEFW_CMD_ERROR_HASH_ERROR,
-	MXGEFW_CMD_ERROR_BAD_PORT,
-	MXGEFW_CMD_ERROR_RESOURCES,
-	MXGEFW_CMD_ERROR_MULTICAST,
-	MXGEFW_CMD_ERROR_UNALIGNED,
-	MXGEFW_CMD_ERROR_NO_MDIO,
-	MXGEFW_CMD_ERROR_XFP_FAILURE,
-	MXGEFW_CMD_ERROR_XFP_ABSENT,
-	MXGEFW_CMD_ERROR_BAD_PCIE_LINK
+	MXGEFW_CMD_UNKNOWN = 1,
+	MXGEFW_CMD_ERROR_RANGE = 2,
+	MXGEFW_CMD_ERROR_BUSY = 3,
+	MXGEFW_CMD_ERROR_EMPTY = 4,
+	MXGEFW_CMD_ERROR_CLOSED = 5,
+	MXGEFW_CMD_ERROR_HASH_ERROR = 6,
+	MXGEFW_CMD_ERROR_BAD_PORT = 7,
+	MXGEFW_CMD_ERROR_RESOURCES = 8,
+	MXGEFW_CMD_ERROR_MULTICAST = 9,
+	MXGEFW_CMD_ERROR_UNALIGNED = 10,
+	MXGEFW_CMD_ERROR_NO_MDIO = 11,
+	MXGEFW_CMD_ERROR_I2C_FAILURE = 12,
+	MXGEFW_CMD_ERROR_I2C_ABSENT = 13,
+	MXGEFW_CMD_ERROR_BAD_PCIE_LINK = 14
 };
 
 #define MXGEFW_OLD_IRQ_DATA_LEN 40
--- net-next-2.6/drivers/net/myri10ge/myri10ge_mcp_gen_header.h	2008-11-24 08:34:16.000000000 +0100
+++ linux-tmp/drivers/net/myri10ge/myri10ge_mcp_gen_header.h	2008-12-21 22:07:53.000000000 +0100
@@ -42,6 +42,7 @@
 	unsigned short handoff_id_caps;	/* bitfield: new mcp must have superset */
 	unsigned msix_table_addr;	/* start address of msix table in firmware */
 	unsigned bss_addr;	/* start of bss */
+	unsigned features;
 	/* 8 */
 };
 


