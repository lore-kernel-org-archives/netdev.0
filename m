From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: mv643xx(14/20): whitespace and indentation cleanup
Date: Mon, 28 Mar 2005 16:56:39 -0700
Message-ID: <20050328235639.GN29098@xyzzy>
References: <20050328233807.GA28423@xyzzy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, Manish Lachwani <mlachwani@mvista.com>,
        Brian Waite <brian@waitefamily.us>,
        "Steven J. Hill" <sjhill@realitydiluted.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        James Chapman <jchapman@katalix.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050328233807.GA28423@xyzzy>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Code passed through Lindent to fixup some broken indentation and to
force consistent use of tabs. Unfortunately, very long macro names
used for register accesses mean keeping to the 80 char line length
constraint is impossible so several lines have been manually fixed up
and are longer than 80 chars.

There are no functional changes in this patch.

Signed-off-by: James Chapman <jchapman@katalix.com>
Acked-by: Dale Farnsworth <dale@farnsworth.org>

Index: linux-2.5-enet/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.c
+++ linux-2.5-enet/drivers/net/mv643xx_eth.c
@@ -46,10 +46,6 @@
 #include <asm/delay.h>
 #include "mv643xx_eth.h"
 
-/*
- * The first part is the high level driver of the gigE ethernet ports.
- */
-
 /* Constants */
 #define VLAN_HLEN		4
 #define FCS_LEN			4
@@ -95,7 +91,7 @@
 
 static inline void mv643xx_eth_write(int offset, u32 data)
 {
-	void * __iomem reg_base;
+	void *__iomem reg_base;
 
 	reg_base = mv643xx_eth_shared_base - MV643XX_ETH_SHARED_REGS;
 	writel(data, reg_base + offset);
@@ -106,116 +102,117 @@
  *
  * DESCRIPTION:
  *	This file introduce low level API to Marvell's Gigabit Ethernet
- *		controller. This Gigabit Ethernet Controller driver API controls
- *		1) Operations (i.e. port init, start, reset etc').
- *		2) Data flow (i.e. port send, receive etc').
- *		Each Gigabit Ethernet port is controlled via
- *		struct mv643xx_private.
- *		This struct includes user configuration information as well as
- *		driver internal data needed for its operations.
+ *	controller. This Gigabit Ethernet Controller driver API controls
+ *	1) Operations (i.e. port init, start, reset etc').
+ *	2) Data flow (i.e. port send, receive etc').
+ *	Each Gigabit Ethernet port is controlled via
+ *	struct mv643xx_private.
+ *	This struct includes user configuration information as well as
+ *	driver internal data needed for its operations.
  *
- *		Supported Features:
- *		- The user is free from Rx/Tx queue managing.
- *		- This low level driver introduce functionality API that enable
- *		  the to operate Marvell's Gigabit Ethernet Controller in a
- *		  convenient way.
- *		- Simple Gigabit Ethernet port operation API.
- *		- Simple Gigabit Ethernet port data flow API.
- *		- Data flow and operation API support per queue functionality.
- *		- Support cached descriptors for better performance.
- *		- Enable access to all four DRAM banks and internal SRAM memory
- *		  spaces.
- *		- PHY access and control API.
- *		- Port control register configuration API.
- *		- Full control over Unicast and Multicast MAC configurations.
+ *	Supported Features:
+ *	- The user is free from Rx/Tx queue managing.
+ *	- This low level driver introduce functionality API that enable
+ *	  the to operate Marvell's Gigabit Ethernet Controller in a
+ *	  convenient way.
+ *	- Simple Gigabit Ethernet port operation API.
+ *	- Simple Gigabit Ethernet port data flow API.
+ *	- Data flow and operation API support per queue functionality.
+ *	- Support cached descriptors for better performance.
+ *	- Enable access to all four DRAM banks and internal SRAM memory
+ *	  spaces.
+ *	- PHY access and control API.
+ *	- Port control register configuration API.
+ *	- Full control over Unicast and Multicast MAC configurations.
  *
- *		Operation flow:
+ *	Operation flow:
  *
- *		Initialization phase
- *		This phase complete the initialization of the the
- *		mv643xx_private struct.
- *		User information regarding port configuration has to be set
- *		prior to calling the port initialization routine.
+ *	Initialization phase
+ *	This phase complete the initialization of the the
+ *	mv643xx_private struct.
+ *	User information regarding port configuration has to be set
+ *	prior to calling the port initialization routine.
  *
- *		In this phase any port Tx/Rx activity is halted, MIB counters
- *		are cleared, PHY address is set according to user parameter and
- *		access to DRAM and internal SRAM memory spaces.
+ *	In this phase any port Tx/Rx activity is halted, MIB counters
+ *	are cleared, PHY address is set according to user parameter and
+ *	access to DRAM and internal SRAM memory spaces.
  *
- *		Driver ring initialization
- *		Allocating memory for the descriptor rings and buffers is not
- *		within the scope of this driver. Thus, the user is required to
- *		allocate memory for the descriptors ring and buffers. Those
- *		memory parameters are used by the Rx and Tx ring initialization
- *		routines in order to curve the descriptor linked list in a form
- *		of a ring.
- *		Note: Pay special attention to alignment issues when using
- *		cached descriptors/buffers. In this phase the driver store
- *		information in the mv643xx_private struct regarding each queue
- *		ring.
+ *	Driver ring initialization
+ *	Allocating memory for the descriptor rings and buffers is not
+ *	within the scope of this driver. Thus, the user is required to
+ *	allocate memory for the descriptors ring and buffers. Those
+ *	memory parameters are used by the Rx and Tx ring initialization
+ *	routines in order to curve the descriptor linked list in a form
+ *	of a ring.
+ *	Note: Pay special attention to alignment issues when using
+ *	cached descriptors/buffers. In this phase the driver store
+ *	information in the mv643xx_private struct regarding each queue
+ *	ring.
  *
- *		Driver start
- *		This phase prepares the Ethernet port for Rx and Tx activity.
- *		It uses the information stored in the mv643xx_private struct to
- *		initialize the various port registers.
+ *	Driver start
+ *	This phase prepares the Ethernet port for Rx and Tx activity.
+ *	It uses the information stored in the mv643xx_private struct to
+ *	initialize the various port registers.
  *
- *		Data flow:
- *		All packet references to/from the driver are done using
- *		struct pkt_info.
- *		This struct is a unified struct used with Rx and Tx operations.
- *		This way the user is not required to be familiar with neither
- *		Tx nor Rx descriptors structures.
- *		The driver's descriptors rings are management by indexes.
- *		Those indexes controls the ring resources and used to indicate
- *		a SW resource error:
- *		'current'
- *		This index points to the current available resource for use. For
- *		example in Rx process this index will point to the descriptor
- *		that will be passed to the user upon calling the receive
- *		routine.  In Tx process, this index will point to the descriptor
- *		that will be assigned with the user packet info and transmitted.
- *		'used'
- *		This index points to the descriptor that need to restore its
- *		resources. For example in Rx process, using the Rx buffer return
- *		API will attach the buffer returned in packet info to the
- *		descriptor pointed by 'used'. In Tx process, using the Tx
- *		descriptor return will merely return the user packet info with
- *		the command status of the transmitted buffer pointed by the
- *		'used' index. Nevertheless, it is essential to use this routine
- *		to update the 'used' index.
- *		'first'
- *		This index supports Tx Scatter-Gather. It points to the first
- *		descriptor of a packet assembled of multiple buffers. For
- *		example when in middle of Such packet we have a Tx resource
- *		error the 'curr' index get the value of 'first' to indicate
- *		that the ring returned to its state before trying to transmit
- *		this packet.
+ *	Data flow:
+ *	All packet references to/from the driver are done using
+ *	struct pkt_info.
+ *	This struct is a unified struct used with Rx and Tx operations.
+ *	This way the user is not required to be familiar with neither
+ *	Tx nor Rx descriptors structures.
+ *	The driver's descriptors rings are management by indexes.
+ *	Those indexes controls the ring resources and used to indicate
+ *	a SW resource error:
+ *	'current'
+ *	This index points to the current available resource for use. For
+ *	example in Rx process this index will point to the descriptor
+ *	that will be passed to the user upon calling the receive
+ *	routine.  In Tx process, this index will point to the descriptor
+ *	that will be assigned with the user packet info and transmitted.
+ *	'used'
+ *	This index points to the descriptor that need to restore its
+ *	resources. For example in Rx process, using the Rx buffer return
+ *	API will attach the buffer returned in packet info to the
+ *	descriptor pointed by 'used'. In Tx process, using the Tx
+ *	descriptor return will merely return the user packet info with
+ *	the command status of the transmitted buffer pointed by the
+ *	'used' index. Nevertheless, it is essential to use this routine
+ *	to update the 'used' index.
+ *	'first'
+ *	This index supports Tx Scatter-Gather. It points to the first
+ *	descriptor of a packet assembled of multiple buffers. For
+ *	example when in middle of Such packet we have a Tx resource
+ *	error the 'curr' index get the value of 'first' to indicate
+ *	that the ring returned to its state before trying to transmit
+ *	this packet.
  *
- *		Receive operation:
- *		The mv643xx_eth_port_receive API set the packet information struct,
- *		passed by the caller, with received information from the
- *		'current' SDMA descriptor.
- *		It is the user responsibility to return this resource back
- *		to the Rx descriptor ring to enable the reuse of this source.
- *		Return Rx resource is done using the eth_rx_return_buff API.
+ *	Receive operation:
+ *	The mv643xx_eth_port_receive API set the packet information struct,
+ *	passed by the caller, with received information from the
+ *	'current' SDMA descriptor.
+ *	It is the user responsibility to return this resource back
+ *	to the Rx descriptor ring to enable the reuse of this source.
+ *	Return Rx resource is done using the eth_rx_return_buff API.
  *
- *		Transmit operation:
- *		The mv643xx_eth_tx_packet API supports Scatter-Gather which enables to
- *		send a packet spanned over multiple buffers. This means that
- *		for each packet info structure given by the user and put into
- *		the Tx descriptors ring, will be transmitted only if the 'LAST'
- *		bit will be set in the packet info command status field. This
- *		API also consider restriction regarding buffer alignments and
- *		sizes.
- *		The user must return a Tx resource after ensuring the buffer
- *		has been transmitted to enable the Tx ring indexes to update.
+ *	Transmit operation:
+ *	The mv643xx_eth_tx_packet API supports Scatter-Gather which enables to
+ *	send a packet spanned over multiple buffers. This means that
+ *	for each packet info structure given by the user and put into
+ *	the Tx descriptors ring, will be transmitted only if the 'LAST'
+ *	bit will be set in the packet info command status field. This
+ *	API also consider restriction regarding buffer alignments and
+ *	sizes.
+ *	The user must return a Tx resource after ensuring the buffer
+ *	has been transmitted to enable the Tx ring indexes to update.
  *
- *		BOARD LAYOUT
- *		This device is on-board.  No jumper diagram is necessary.
+ *	BOARD LAYOUT
+ *	This device is on-board.  No jumper diagram is necessary.
  *
- *		EXTERNAL INTERFACE
+ *	EXTERNAL INTERFACE
  *
- *	Prior to calling the initialization routine mv643xx_eth_port_init() the user
- *	must set the following fields under mv643xx_private struct:
+ *	Prior to calling the initialization routine
+ *	mv643xx_eth_port_init() the user must set the following fields
+ *	under mv643xx_private struct:
  *	port_num		User Ethernet port number.
  *	port_mac_addr[6]	User defined port MAC address.
  *	port_config		User port configuration value.
@@ -223,15 +220,15 @@
  *	port_sdma_config	User port SDMA config value.
  *	port_serial_control	User port serial control value.
  *
- *		This driver data flow is done using the struct pkt_info which
- *		is a unified struct for Rx and Tx operations:
+ *	This driver data flow is done using the struct pkt_info which
+ *	is a unified struct for Rx and Tx operations:
  *
- *		byte_cnt	Tx/Rx descriptor buffer byte count.
- *		l4i_chk		CPU provided TCP Checksum. For Tx operation
+ *	byte_cnt		Tx/Rx descriptor buffer byte count.
+ *	l4i_chk			CPU provided TCP Checksum. For Tx operation
  *				only.
- *		cmd_sts		Tx/Rx descriptor command status.
- *		buf_ptr		Tx/Rx descriptor buffer pointer.
- *		return_info	Tx/Rx user resource return information.
+ *	cmd_sts			Tx/Rx descriptor command status.
+ *	buf_ptr			Tx/Rx descriptor buffer pointer.
+ *	return_info		Tx/Rx user resource return information.
  */
 
 /* defines */
@@ -243,8 +240,8 @@
  * Ethernet port setup routines
  *****************************************************************************/
 
-static int mv643xx_eth_port_mac_addr(unsigned int eth_port_num, unsigned char uc_nibble,
-								int option)
+static int mv643xx_eth_port_mac_addr(unsigned int eth_port_num,
+				     unsigned char uc_nibble, int option)
 {
 	unsigned int unicast_reg;
 	unsigned int tbl_offset;
@@ -252,31 +249,35 @@
 
 	/* Locate the Unicast table entry */
 	uc_nibble = (0xf & uc_nibble);
-	tbl_offset = (uc_nibble / 4) * 4;	/* Register offset from unicast table base */
-	reg_offset = uc_nibble % 4;	/* Entry offset within the above register */
-
+	tbl_offset = (uc_nibble / 4) * 4;	/* Register offset from unicast 
+						 * table base
+						 */
+	reg_offset = uc_nibble % 4;		/* Entry offset within the 
+						 * above register 
+						 */
 	switch (option) {
 	case REJECT_MAC_ADDR:
 		/* Clear accepts frame bit at given unicast DA table entry */
-		unicast_reg = mv643xx_eth_read((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE
-						(eth_port_num) + tbl_offset));
+		unicast_reg =
+			mv643xx_eth_read(MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE(eth_port_num) + 
+					 tbl_offset);
 
 		unicast_reg &= (0x0E << (8 * reg_offset));
 
-		mv643xx_eth_write((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE
-				(eth_port_num) + tbl_offset), unicast_reg);
+		mv643xx_eth_write((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE(eth_port_num) + 
+				   tbl_offset), unicast_reg);
 		break;
 
 	case ACCEPT_MAC_ADDR:
 		/* Set accepts frame bit at unicast DA filter table entry */
 		unicast_reg =
-			mv643xx_eth_read((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE
-						(eth_port_num) + tbl_offset));
+			mv643xx_eth_read(MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE(eth_port_num) + 
+					 tbl_offset);
 
 		unicast_reg |= (0x01 << (8 * reg_offset));
 
-		mv643xx_eth_write((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE
-				(eth_port_num) + tbl_offset), unicast_reg);
+		mv643xx_eth_write((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE(eth_port_num) + 
+				   tbl_offset), unicast_reg);
 
 		break;
 
@@ -287,7 +288,8 @@
 	return 1;
 }
 
-static void mv643xx_eth_port_mac_addr_get(struct net_device *dev, unsigned char *p_addr)
+static void mv643xx_eth_port_mac_addr_get(struct net_device *dev,
+					  unsigned char *p_addr)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int mac_h;
@@ -314,7 +316,7 @@
 
 	mac_l = (p_addr[4] << 8) | (p_addr[5]);
 	mac_h = (p_addr[0] << 24) | (p_addr[1] << 16) | (p_addr[2] << 8) |
-							(p_addr[3] << 0);
+		(p_addr[3] << 0);
 
 	mv643xx_eth_write(MV643XX_ETH_MAC_ADDR_LOW(eth_port_num), mac_l);
 	mv643xx_eth_write(MV643XX_ETH_MAC_ADDR_HIGH(eth_port_num), mac_h);
@@ -333,33 +335,33 @@
 
 	/* Clear DA filter unicast table (Ex_dFUT) */
 	for (table_index = 0; table_index <= 0xC; table_index += 4)
-		mv643xx_eth_write((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE
-					(eth_port_num) + table_index), 0);
+		mv643xx_eth_write((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE(eth_port_num) +
+				   table_index), 0);
 
 	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
 		/* Clear DA filter special multicast table (Ex_dFSMT) */
-		mv643xx_eth_write((MV643XX_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
-					(eth_port_num) + table_index), 0);
+		mv643xx_eth_write((MV643XX_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(eth_port_num) + 
+				   table_index), 0);
 		/* Clear DA filter other multicast table (Ex_dFOMT) */
-		mv643xx_eth_write((MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE
-					(eth_port_num) + table_index), 0);
+		mv643xx_eth_write((MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE(eth_port_num) + 
+				   table_index), 0);
 	}
 }
 
 /*
- *	This routine prepares the Ethernet port for Rx and Tx activity:
- *	 1. Initialize Tx and Rx Current Descriptor Pointer for each queue that
- *	    has been initialized a descriptor's ring (using
- *	    ether_init_tx_desc_ring for Tx and ether_init_rx_desc_ring for Rx)
- *	 2. Initialize and enable the Ethernet configuration port by writing to
- *	    the port's configuration and command registers.
- *	 3. Initialize and enable the SDMA by writing to the SDMA's
- *	    configuration and command registers.  After completing these steps,
- *	    the ethernet port SDMA can starts to perform Rx and Tx activities.
+ * This routine prepares the Ethernet port for Rx and Tx activity:
+ *  1. Initialize Tx and Rx Current Descriptor Pointer for each queue that
+ *     has been initialized a descriptor's ring (using
+ *     ether_init_tx_desc_ring for Tx and ether_init_rx_desc_ring for Rx)
+ *  2. Initialize and enable the Ethernet configuration port by writing to
+ *     the port's configuration and command registers.
+ *  3. Initialize and enable the SDMA by writing to the SDMA's
+ *     configuration and command registers.  After completing these steps,
+ *     the ethernet port SDMA can starts to perform Rx and Tx activities.
  *
- *	Note: Each Rx and Tx queue descriptor's list must be initialized prior
- *	to calling this function (use mv643xx_eth_init_tx_desc_ring for Tx queues
- *	and mv643xx_eth_init_rx_desc_ring for Rx queues).
+ * Note: Each Rx and Tx queue descriptor's list must be initialized prior
+ * to calling this function (use mv643xx_eth_init_tx_desc_ring for Tx queues
+ * and mv643xx_eth_init_rx_desc_ring for Rx queues).
  */
 static void mv643xx_eth_port_start(struct net_device *dev)
 {
@@ -370,12 +372,14 @@
 	/* Assignment of Tx CTRP of given queue */
 	tx_curr_desc = mp->tx_curr_desc_q;
 	mv643xx_eth_write(MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_0(port_num),
-		(u32)((struct eth_tx_desc *)mp->tx_desc_dma + tx_curr_desc));
+			  (u32) ((struct eth_tx_desc *)mp->tx_desc_dma +
+				 tx_curr_desc));
 
 	/* Assignment of Rx CRDP of given queue */
 	rx_curr_desc = mp->rx_curr_desc_q;
 	mv643xx_eth_write(MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port_num),
-		(u32)((struct eth_rx_desc *)mp->rx_desc_dma + rx_curr_desc));
+			  (u32) ((struct eth_rx_desc *)mp->rx_desc_dma +
+				 rx_curr_desc));
 
 	/* Add the assigned Ethernet address to the port's address table */
 	mv643xx_eth_port_mac_addr_set(dev, mp->port_mac_addr);
@@ -394,10 +398,11 @@
 	/* Increase the Rx side buffer size if supporting GigE */
 	if (mp->port_serial_control & MV643XX_ETH_SET_GMII_SPEED_TO_1000)
 		mv643xx_eth_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
-			(mp->port_serial_control & 0xfff1ffff) | (0x5 << 17));
+				  (mp->port_serial_control & 0xfff1ffff) |
+				  (0x5 << 17));
 	else
 		mv643xx_eth_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
-						mp->port_serial_control);
+				  mp->port_serial_control);
 
 	mv643xx_eth_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
 			  mp->port_serial_control |
@@ -409,12 +414,12 @@
 
 	/* Enable port Rx. */
 	mv643xx_eth_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num),
-						mp->port_rx_queue_command);
+			  mp->port_rx_queue_command);
 }
 
 /*
- *	This function clears all MIB counters of a specific ethernet port.
- *	A read from the MIB counter will reset the counter.
+ * This function clears all MIB counters of a specific ethernet port.
+ * A read from the MIB counter will reset the counter.
  */
 static void mv643xx_eth_clear_mib_counters(struct net_device *dev)
 {
@@ -423,15 +428,16 @@
 	int i;
 
 	/* Perform dummy reads from MIB counters */
-	for (i = ETH_MIB_GOOD_OCTETS_RECEIVED_LOW; i < ETH_MIB_LATE_COLLISION;
-									i += 4)
-		mv643xx_eth_read(MV643XX_ETH_MIB_COUNTERS_BASE(eth_port_num) + i);
+	for (i = ETH_MIB_GOOD_OCTETS_RECEIVED_LOW;
+	     i < ETH_MIB_LATE_COLLISION; i += 4)
+		mv643xx_eth_read(MV643XX_ETH_MIB_COUNTERS_BASE(eth_port_num) +
+				 i);
 }
 
 /*
- * 	This routine resets the chip by aborting any SDMA engine activity and
- *	clearing the MIB counters. The Receiver and the Transmit unit are in
- *	idle state after this command is performed and the port is disabled.
+ * This routine resets the chip by aborting any SDMA engine activity and
+ * clearing the MIB counters. The Receiver and the Transmit unit are in
+ * idle state after this command is performed and the port is disabled.
  */
 static void mv643xx_eth_port_reset(struct net_device *dev)
 {
@@ -440,32 +446,32 @@
 	unsigned int reg_data;
 
 	/* Stop Tx port activity. Check port Tx activity. */
-	reg_data = mv643xx_eth_read(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num));
+	reg_data =
+	    mv643xx_eth_read(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num));
 
 	if (reg_data & 0xFF) {
 		/* Issue stop command for active channels only */
-		mv643xx_eth_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num),
-							(reg_data << 8));
+		mv643xx_eth_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num), 
+				  (reg_data << 8));
 
 		/* Wait for all Tx activity to terminate. */
 		/* Check port cause register that all Tx queues are stopped */
-		while (mv643xx_eth_read(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num))
-									& 0xFF)
+		while (mv643xx_eth_read(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num)) & 0xFF)
 			udelay(10);
 	}
 
 	/* Stop Rx port activity. Check port Rx activity. */
-	reg_data = mv643xx_eth_read(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num));
+	reg_data =
+	    mv643xx_eth_read(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num));
 
 	if (reg_data & 0xFF) {
 		/* Issue stop command for active channels only */
 		mv643xx_eth_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num),
-							(reg_data << 8));
+				  (reg_data << 8));
 
 		/* Wait for all Rx activity to terminate. */
 		/* Check port cause register that all Rx queues are stopped */
-		while (mv643xx_eth_read(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num))
-									& 0xFF)
+		while (mv643xx_eth_read(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num)) & 0xFF)
 			udelay(10);
 	}
 
@@ -473,9 +479,11 @@
 	mv643xx_eth_clear_mib_counters(dev);
 
 	/* Reset the Enable bit in the Configuration Register */
-	reg_data = mv643xx_eth_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
+	reg_data =
+		mv643xx_eth_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
 	reg_data &= ~MV643XX_ETH_SERIAL_PORT_ENABLE;
-	mv643xx_eth_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), reg_data);
+	mv643xx_eth_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
+			  reg_data);
 }
 
 static int mv643xx_eth_phy_get(struct net_device *dev)
@@ -501,7 +509,7 @@
 }
 
 static void mv643xx_eth_read_smi_reg(struct net_device *dev,
-				unsigned int phy_reg, unsigned int *value)
+				     unsigned int phy_reg, unsigned int *value)
 {
 	int phy_addr = mv643xx_eth_phy_get(dev);
 	unsigned long flags;
@@ -520,11 +528,13 @@
 		udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
-	mv643xx_eth_write(MV643XX_ETH_SMI_REG,
-		(phy_addr << 16) | (phy_reg << 21) | ETH_SMI_OPCODE_READ);
+	mv643xx_eth_write(MV643XX_ETH_SMI_REG, 
+			  (phy_addr << 16) | (phy_reg << 21) |
+			  ETH_SMI_OPCODE_READ);
 
 	/* now wait for the data to be valid */
-	for (i = 0; !(mv643xx_eth_read(MV643XX_ETH_SMI_REG) & ETH_SMI_READ_VALID); i++) {
+	for (i = 0; !(mv643xx_eth_read(MV643XX_ETH_SMI_REG) &
+		      ETH_SMI_READ_VALID); i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
 			printk(KERN_ERR "%s: PHY read timeout\n",
 			       dev->name);
@@ -560,8 +570,9 @@
 		udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
-	mv643xx_eth_write(MV643XX_ETH_SMI_REG, (phy_addr << 16) | (phy_reg << 21) |
-				ETH_SMI_OPCODE_WRITE | (value & 0xffff));
+	mv643xx_eth_write(MV643XX_ETH_SMI_REG,
+			  (phy_addr << 16) | (phy_reg << 21) |
+			  ETH_SMI_OPCODE_WRITE | (value & 0xffff));
 out:
 	spin_unlock_irqrestore(&mv643xx_eth_phy_lock, flags);
 }
@@ -577,16 +588,16 @@
 }
 
 /*
- *	This function prepares the ethernet port to start its activity:
- *	1) Completes the ethernet port driver struct initialization toward port
- *		start routine.
- *	2) Resets the device to a quiescent state in case of warm reboot.
- *	3) Enable SDMA access to all four DRAM banks as well as internal SRAM.
- *	4) Clean MAC tables. The reset status of those tables is unknown.
- *	5) Set PHY address.
- *	Note: Call this routine prior to eth_port_start routine and after
- *	setting user values in the user fields of Ethernet port control
- *	struct.
+ * This function prepares the ethernet port to start its activity:
+ * 1) Completes the ethernet port driver struct initialization toward port
+ *    start routine.
+ * 2) Resets the device to a quiescent state in case of warm reboot.
+ * 3) Enable SDMA access to all four DRAM banks as well as internal SRAM.
+ * 4) Clean MAC tables. The reset status of those tables is unknown.
+ * 5) Set PHY address.
+ * Note: Call this routine prior to eth_port_start routine and after
+ * setting user values in the user fields of Ethernet port control
+ * struct.
  */
 static void mv643xx_eth_port_init(struct net_device *dev)
 {
@@ -610,7 +621,8 @@
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 
-	return mv643xx_eth_read(MV643XX_ETH_MIB_COUNTERS_BASE(mp->port_num) + offset);
+	return mv643xx_eth_read(MV643XX_ETH_MIB_COUNTERS_BASE(mp->port_num) +
+				offset);
 }
 
 static void mv643xx_eth_update_mib_counters(struct net_device *dev)
@@ -622,15 +634,12 @@
 	p->good_octets_received +=
 	    mv643xx_eth_read_mib_counter(dev, ETH_MIB_GOOD_OCTETS_RECEIVED_LOW);
 	p->good_octets_received +=
-	    (u64) mv643xx_eth_read_mib_counter(dev,
-					       ETH_MIB_GOOD_OCTETS_RECEIVED_HIGH)
-	    << 32;
+	    (u64) mv643xx_eth_read_mib_counter(dev, ETH_MIB_GOOD_OCTETS_RECEIVED_HIGH) << 32;
 
 	for (offset = ETH_MIB_BAD_OCTETS_RECEIVED;
-			offset <= ETH_MIB_FRAMES_1024_TO_MAX_OCTETS;
-			offset += 4)
-		*(u32 *)((char *)p + offset) =
-		    mv643xx_eth_read_mib_counter(dev, offset);
+	     offset <= ETH_MIB_FRAMES_1024_TO_MAX_OCTETS; offset += 4)
+		*(u32 *) ((char *)p + offset) =
+			mv643xx_eth_read_mib_counter(dev, offset);
 
 	p->good_octets_sent +=
 	    mv643xx_eth_read_mib_counter(dev, ETH_MIB_GOOD_OCTETS_SENT_LOW);
@@ -638,15 +647,14 @@
 	    (u64) mv643xx_eth_read_mib_counter(dev, ETH_MIB_GOOD_OCTETS_SENT_HIGH) << 32;
 
 	for (offset = ETH_MIB_GOOD_FRAMES_SENT;
-			offset <= ETH_MIB_LATE_COLLISION;
-			offset += 4)
-		*(u32 *)((char *)p + offset) =
-		    mv643xx_eth_read_mib_counter(dev, offset);
+	     offset <= ETH_MIB_LATE_COLLISION; offset += 4)
+		*(u32 *) ((char *)p + offset) =
+			mv643xx_eth_read_mib_counter(dev, offset);
 }
 
 /*
- *	This function tests whether there is a PHY present on
- *	the specified port.
+ * This function tests whether there is a PHY present on
+ * the specified port.
  */
 static int mv643xx_eth_phy_detect(struct net_device *dev)
 {
@@ -660,7 +668,7 @@
 
 	mv643xx_eth_read_smi_reg(dev, 0, &phy_reg_data0);
 	if ((phy_reg_data0 & 0x1000) == auto_neg)
-		return -ENODEV;				/* change didn't take */
+		return -ENODEV;		/* change didn't take */
 
 	phy_reg_data0 ^= 0x1000;
 	mv643xx_eth_write_smi_reg(dev, 0, phy_reg_data0);
@@ -668,8 +676,8 @@
 }
 
 /*
- *	This function sets specified bits in the given ethernet
- *	configuration register.
+ * This function sets specified bits in the given ethernet
+ * configuration register.
  */
 static void mv643xx_eth_set_config_reg(struct net_device *dev,
 				       unsigned int value)
@@ -678,22 +686,24 @@
 	unsigned int eth_port_num = mp->port_num;
 	unsigned int eth_config_reg;
 
-	eth_config_reg = mv643xx_eth_read(MV643XX_ETH_PORT_CONFIG_REG(eth_port_num));
+	eth_config_reg =
+		mv643xx_eth_read(MV643XX_ETH_PORT_CONFIG_REG(eth_port_num));
 	eth_config_reg |= value;
-	mv643xx_eth_write(MV643XX_ETH_PORT_CONFIG_REG(eth_port_num), eth_config_reg);
+	mv643xx_eth_write(MV643XX_ETH_PORT_CONFIG_REG(eth_port_num),
+			  eth_config_reg);
 }
 
 /*
- *	This function returns the configuration register value of the given
- *	ethernet port.
+ * This function returns the configuration register value of the given
+ * ethernet port.
  */
 static unsigned int mv643xx_eth_get_config_reg(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int eth_config_reg;
 
-	eth_config_reg = mv643xx_eth_read(MV643XX_ETH_PORT_CONFIG_EXTEND_REG
-								(mp->port_num));
+	eth_config_reg =
+	    mv643xx_eth_read(MV643XX_ETH_PORT_CONFIG_EXTEND_REG(mp->port_num));
 	return eth_config_reg;
 }
 
@@ -702,13 +712,13 @@
  *****************************************************************************/
 
 /*
- *	This function prepares a Rx chained list of descriptors and packet
- *	buffers in a form of a ring. The routine must be called after port
- *	initialization routine and before port start routine.
- *	The Ethernet SDMA engine uses CPU bus addresses to access the various
- *	devices in the system (i.e. DRAM). This function uses the ethernet
- *	struct 'virtual to physical' routine (set by the user) to set the ring
- *	with physical addresses.
+ * This function prepares a Rx chained list of descriptors and packet
+ * buffers in a form of a ring. The routine must be called after port
+ * initialization routine and before port start routine.
+ * The Ethernet SDMA engine uses CPU bus addresses to access the various
+ * devices in the system (i.e. DRAM). This function uses the ethernet
+ * struct 'virtual to physical' routine (set by the user) to set the ring
+ * with physical addresses.
  */
 static void mv643xx_eth_init_rx_desc_ring(struct net_device *dev)
 {
@@ -735,13 +745,13 @@
 }
 
 /*
- *	This function prepares a Tx chained list of descriptors and packet
- *	buffers in a form of a ring. The routine must be called after port
- *	initialization routine and before port start routine.
- *	The Ethernet SDMA engine uses CPU bus addresses to access the various
- *	devices in the system (i.e. DRAM). This function uses the ethernet
- *	struct 'virtual to physical' routine (set by the user) to set the ring
- *	with physical addresses.
+ * This function prepares a Tx chained list of descriptors and packet
+ * buffers in a form of a ring. The routine must be called after port
+ * initialization routine and before port start routine.
+ * The Ethernet SDMA engine uses CPU bus addresses to access the various
+ * devices in the system (i.e. DRAM). This function uses the ethernet
+ * struct 'virtual to physical' routine (set by the user) to set the ring
+ * with physical addresses.
  */
 static void mv643xx_eth_init_tx_desc_ring(struct net_device *dev)
 {
@@ -775,7 +785,8 @@
 	unsigned int curr;
 
 	/* Stop Tx Queues */
-	mv643xx_eth_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(mp->port_num), 0x0000ff00);
+	mv643xx_eth_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(mp->port_num),
+			  0x0000ff00);
 
 	/* Free outstanding skb's on TX rings */
 	for (curr = 0; mp->tx_ring_skbs && curr < mp->tx_ring_size; curr++) {
@@ -793,7 +804,7 @@
 		iounmap(mp->p_tx_desc_area);
 	else
 		dma_free_coherent(NULL, mp->tx_desc_area_size,
-				mp->p_tx_desc_area, mp->tx_desc_dma);
+				  mp->p_tx_desc_area, mp->tx_desc_dma);
 }
 
 static void mv643xx_eth_free_rx_rings(struct net_device *dev)
@@ -802,7 +813,8 @@
 	int curr;
 
 	/* Stop RX Queues */
-	mv643xx_eth_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(mp->port_num), 0x0000ff00);
+	mv643xx_eth_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(mp->port_num),
+			  0x0000ff00);
 
 	/* Free preallocated skb's on RX rings */
 	for (curr = 0; mp->rx_ring_skbs && curr < mp->rx_ring_size; curr++) {
@@ -822,50 +834,52 @@
 		iounmap(mp->p_rx_desc_area);
 	else
 		dma_free_coherent(NULL, mp->rx_desc_area_size,
-				mp->p_rx_desc_area, mp->rx_desc_dma);
+				  mp->p_rx_desc_area, mp->rx_desc_dma);
 }
 
 #ifdef MV643XX_COAL
 
 /*
- *	This routine sets the RX coalescing interrupt mechanism parameter.
- *	This parameter is a timeout counter, that counts in 64 t_clk
- *	chunks ; that when timeout event occurs a maskable interrupt
- *	occurs.
- *	The parameter is calculated using the tClk of the MV-643xx chip
- *	and the required delay of the interrupt in usec.
+ * This routine sets the RX coalescing interrupt mechanism parameter.
+ * This parameter is a timeout counter, that counts in 64 t_clk
+ * chunks ; that when timeout event occurs a maskable interrupt
+ * occurs.
+ * The parameter is calculated using the tClk of the MV-643xx chip
+ * and the required delay of the interrupt in usec.
  */
 static unsigned int mv643xx_eth_port_set_rx_coal(unsigned int eth_port_num,
-					unsigned int t_clk, unsigned int delay)
+						 unsigned int t_clk,
+						 unsigned int delay)
 {
 	unsigned int coal = ((t_clk / 1000000) * delay) / 64;
 
 	/* Set RX Coalescing mechanism */
 	mv643xx_eth_write(MV643XX_ETH_SDMA_CONFIG_REG(eth_port_num),
-		((coal & 0x3fff) << 8) |
-		(mv643xx_eth_read(MV643XX_ETH_SDMA_CONFIG_REG(eth_port_num))
-			& 0xffc000ff));
+			  ((coal & 0x3fff) << 8) |
+			  (mv643xx_eth_read(MV643XX_ETH_SDMA_CONFIG_REG(eth_port_num))
+			   & 0xffc000ff));
 
 	return coal;
 }
 #endif
 
 /*
- *	This routine sets the TX coalescing interrupt mechanism parameter.
- *	This parameter is a timeout counter, that counts in 64 t_clk
- *	chunks ; that when timeout event occurs a maskable interrupt
- *	occurs.
- *	The parameter is calculated using the t_cLK frequency of the
- *	MV-643xx chip and the required delay in the interrupt in uSec
+ * This routine sets the TX coalescing interrupt mechanism parameter.
+ * This parameter is a timeout counter, that counts in 64 t_clk
+ * chunks ; that when timeout event occurs a maskable interrupt
+ * occurs.
+ * The parameter is calculated using the t_cLK frequency of the
+ * MV-643xx chip and the required delay in the interrupt in uSec
  */
 static unsigned int mv643xx_eth_port_set_tx_coal(unsigned int eth_port_num,
-					unsigned int t_clk, unsigned int delay)
+						 unsigned int t_clk,
+						 unsigned int delay)
 {
 	unsigned int coal;
 	coal = ((t_clk / 1000000) * delay) / 64;
 	/* Set TX Coalescing mechanism */
 	mv643xx_eth_write(MV643XX_ETH_TX_FIFO_URGENT_THRESHOLD_REG(eth_port_num),
-								coal << 4);
+			  coal << 4);
 	return coal;
 }
 
@@ -874,21 +888,21 @@
  *****************************************************************************/
 
 /*
- *	This routine send a given packet described by p_pktinfo parameter. It
- *	supports transmitting of a packet spaned over multiple buffers. The
- *	routine updates 'curr' and 'first' indexes according to the packet
- *	segment passed to the routine. In case the packet segment is first,
- *	the 'first' index is update. In any case, the 'curr' index is updated.
- *	If the routine get into Tx resource error it assigns 'curr' index as
- *	'first'. This way the function can abort Tx process of multiple
- *	descriptors per packet.
+ * This routine sends a given packet described by p_pktinfo parameter. It
+ * supports transmitting of a packet spaned over multiple buffers. The
+ * routine updates 'curr' and 'first' indexes according to the packet
+ * segment passed to the routine. In case the packet segment is first,
+ * the 'first' index is update. In any case, the 'curr' index is updated.
+ * If the routine get into Tx resource error it assigns 'curr' index as
+ * 'first'. This way the function can abort Tx process of multiple
+ * descriptors per packet.
  */
 #ifdef MV643XX_CHECKSUM_OFFLOAD_TX
 /*
  * Modified to include the first descriptor pointer in case of SG
  */
 static int mv643xx_eth_tx_packet(struct net_device *dev,
-			 struct pkt_info *p_pkt_info)
+				 struct pkt_info *p_pkt_info)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	int tx_desc_curr, tx_desc_used, tx_first_desc, tx_next_desc;
@@ -928,7 +942,7 @@
 	mp->tx_skb[tx_desc_curr] = p_pkt_info->return_info;
 
 	command = p_pkt_info->cmd_sts | ETH_ZERO_PADDING | ETH_GEN_CRC |
-							ETH_BUFFER_OWNED_BY_DMA;
+		  ETH_BUFFER_OWNED_BY_DMA;
 	if (command & ETH_TX_FIRST_DESC) {
 		tx_first_desc = tx_desc_curr;
 		mp->tx_first_desc_q = tx_first_desc;
@@ -942,11 +956,11 @@
 	}
 
 	if (netif_msg_txqueued(mp))
-		printk( KERN_DEBUG "%s: send pkt: len=%d, desc=%d, "
-			"f/l=%d/%d\n", dev->name,
-			p_pkt_info->byte_cnt, tx_desc_curr, 
-			((command & ETH_TX_FIRST_DESC) != 0),
-			((command & ETH_TX_LAST_DESC) != 0));
+		printk(KERN_DEBUG "%s: send pkt: len=%d, desc=%d, "
+		       "f/l=%d/%d\n", dev->name,
+		       p_pkt_info->byte_cnt, tx_desc_curr,
+		       ((command & ETH_TX_FIRST_DESC) != 0),
+		       ((command & ETH_TX_LAST_DESC) != 0));
 
 	if (command & ETH_TX_LAST_DESC) {
 		wmb();
@@ -981,7 +995,7 @@
 }
 #else
 static int mv643xx_eth_tx_packet(struct net_device *dev,
-			 	 struct pkt_info *p_pkt_info)
+				 struct pkt_info *p_pkt_info)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	int tx_desc_curr;
@@ -1015,7 +1029,7 @@
 	/* Set last desc with DMA ownership and interrupt enable. */
 	wmb();
 	current_descriptor->cmd_sts = command_status |
-			ETH_BUFFER_OWNED_BY_DMA | ETH_TX_ENABLE_INTERRUPT;
+		ETH_BUFFER_OWNED_BY_DMA | ETH_TX_ENABLE_INTERRUPT;
 
 	wmb();
 	ETH_ENABLE_TX_QUEUE(mp->port_num);
@@ -1044,11 +1058,11 @@
 #endif
 
 /*
- *	This routine returns the transmitted packet information to the caller.
- *	It uses the 'first' index to support Tx desc return in case a transmit
- *	of a packet spanned over multiple buffer still in process.
- *	In case the Tx queue was in "resource error" condition, where there are
- *	no available Tx resources, the function resets the resource error flag.
+ * This routine returns the transmitted packet information to the caller.
+ * It uses the 'first' index to support Tx desc return in case a transmit
+ * of a packet spanned over multiple buffer still in process.
+ * In case the Tx queue was in "resource error" condition, where there are
+ * no available Tx resources, the function resets the resource error flag.
  */
 static int mv643xx_eth_tx_return_desc(struct net_device *dev,
 				      struct pkt_info *p_pkt_info)
@@ -1097,11 +1111,11 @@
 }
 
 /*
- * 	This routine returns the received data to the caller. There is no
- *	data copying during routine operation. All information is returned
- *	using pointer to packet information struct passed from the caller.
- *	If the routine exhausts Rx ring resources then the resource error flag
- *	is set.
+ * This routine returns the received data to the caller. There is no
+ * data copying during routine operation. All information is returned
+ * using pointer to packet information struct passed from the caller.
+ * If the routine exhausts Rx ring resources then the resource error flag
+ * is set.
  */
 static int mv643xx_eth_rx_packet(struct net_device *dev,
 				 struct pkt_info *p_pkt_info)
@@ -1141,8 +1155,10 @@
 		       ((command_status & ETH_RX_FIRST_DESC) != 0),
 		       ((command_status & ETH_RX_LAST_DESC) != 0));
 
-	/* Clean the return info field to indicate that the packet has been */
-	/* moved to the upper layers					    */
+	/*
+	 * Clean the return info field to indicate that the packet has been
+	 * moved to the upper layers 
+	 */
 	mp->rx_skb[rx_curr_desc] = NULL;
 
 	/* Update current index in data structure */
@@ -1157,10 +1173,10 @@
 }
 
 /*
- *	This routine returns a Rx buffer back to the Rx ring. It retrieves the
- *	next 'used' descriptor and attached the returned buffer to it.
- *	In case the Rx ring was in "resource error" condition, where there are
- *	no available Rx resources, the function resets the resource error flag.
+ * This routine returns a Rx buffer back to the Rx ring. It retrieves the
+ * next 'used' descriptor and attached the returned buffer to it.
+ * In case the Rx ring was in "resource error" condition, where there are
+ * no available Rx resources, the function resets the resource error flag.
  */
 static void mv643xx_eth_rx_return_buff(struct net_device *dev,
 				       struct pkt_info *p_pkt_info)
@@ -1186,8 +1202,8 @@
 
 	/* Return the descriptor to DMA ownership */
 	wmb();
-	p_used_rx_desc->cmd_sts =
-			ETH_BUFFER_OWNED_BY_DMA | ETH_RX_ENABLE_INTERRUPT;
+	p_used_rx_desc->cmd_sts = ETH_BUFFER_OWNED_BY_DMA |
+				  ETH_RX_ENABLE_INTERRUPT;
 	wmb();
 
 	/* Move the used descriptor pointer to the next descriptor */
@@ -1232,7 +1248,7 @@
 		pkt_info.cmd_sts = ETH_RX_ENABLE_INTERRUPT;
 		pkt_info.byte_cnt = RX_SKB_SIZE;
 		pkt_info.buf_ptr = dma_map_single(NULL, skb->data, RX_SKB_SIZE,
-							DMA_FROM_DEVICE);
+						  DMA_FROM_DEVICE);
 		pkt_info.return_info = skb;
 		mv643xx_eth_rx_return_buff(dev, &pkt_info);
 		skb_reserve(skb, 2);
@@ -1254,7 +1270,7 @@
 	else {
 		/* Return interrupts */
 		mv643xx_eth_write(MV643XX_ETH_INTERRUPT_MASK_REG(mp->port_num),
-							INT_CAUSE_UNMASK_ALL);
+				  INT_CAUSE_UNMASK_ALL);
 	}
 #endif
 }
@@ -1285,7 +1301,7 @@
 }
 
 static int mv643xx_eth_free_tx_queue(struct net_device *dev,
-					unsigned int eth_int_cause_ext)
+				     unsigned int eth_int_cause_ext)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	struct net_device_stats *stats = &mp->stats;
@@ -1301,7 +1317,8 @@
 	while (mv643xx_eth_tx_return_desc(dev, &pkt_info) == 0) {
 		if (pkt_info.cmd_sts & BIT0) {
 			if (netif_msg_tx_err(mp))
-				printk(KERN_WARNING "%s: Error in TX: cmd_sts=%08x\n",
+				printk(KERN_WARNING "%s: Error in TX: "
+				       "cmd_sts=%08x\n",
 				       dev->name, pkt_info.cmd_sts);
 			stats->tx_errors++;
 		}
@@ -1315,12 +1332,12 @@
 		if (pkt_info.return_info) {
 			if (skb_shinfo(pkt_info.return_info)->nr_frags)
 				dma_unmap_page(NULL, pkt_info.buf_ptr,
-						pkt_info.byte_cnt,
-						DMA_TO_DEVICE);
+					       pkt_info.byte_cnt,
+					       DMA_TO_DEVICE);
 			else
 				dma_unmap_single(NULL, pkt_info.buf_ptr,
-						pkt_info.byte_cnt,
-						DMA_TO_DEVICE);
+						 pkt_info.byte_cnt,
+						 DMA_TO_DEVICE);
 
 			dev_kfree_skb_irq(pkt_info.return_info);
 			released = 0;
@@ -1331,11 +1348,11 @@
 			 */
 			if (mp->tx_ring_skbs == 0)
 				panic("ERROR - TX outstanding SKBs"
-						" counter is corrupted");
+				      " counter is corrupted");
 			mp->tx_ring_skbs--;
 		} else
 			dma_unmap_page(NULL, pkt_info.buf_ptr,
-					pkt_info.byte_cnt, DMA_TO_DEVICE);
+				       pkt_info.byte_cnt, DMA_TO_DEVICE);
 	}
 
 	spin_unlock(&mp->lock);
@@ -1369,7 +1386,9 @@
 #ifdef MV643XX_NAPI
 		budget--;
 #endif
-		/* Update statistics. Note byte count includes 4 byte CRC count */
+		/* Update statistics. Note byte count includes 4 byte CRC
+		 * count 
+		 */
 		stats->rx_packets++;
 		stats->rx_bytes += pkt_info.byte_cnt;
 		skb = pkt_info.return_info;
@@ -1378,13 +1397,13 @@
 		 * the error summary bit is on, the packets needs to be dropeed.
 		 */
 		if (((pkt_info.cmd_sts
-				& (ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC)) !=
-					(ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC))
-				|| (pkt_info.cmd_sts & ETH_ERROR_SUMMARY)) {
+		      & (ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC)) !=
+		     (ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC))
+		    || (pkt_info.cmd_sts & ETH_ERROR_SUMMARY)) {
 			stats->rx_dropped++;
 			if ((pkt_info.cmd_sts & (ETH_RX_FIRST_DESC |
-							ETH_RX_LAST_DESC)) !=
-				(ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC)) {
+						 ETH_RX_LAST_DESC)) !=
+			    (ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC)) {
 				if (net_ratelimit() && netif_msg_rx_err(mp))
 					printk(KERN_WARNING "%s: Received "
 					       "packet spread on multiple "
@@ -1404,8 +1423,8 @@
 
 			if (pkt_info.cmd_sts & ETH_LAYER_4_CHECKSUM_OK) {
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
-				skb->csum = htons(
-					(pkt_info.cmd_sts & 0x0007fff8) >> 3);
+				skb->csum = htons((pkt_info.cmd_sts & 
+						   0x0007fff8) >> 3);
 			}
 			skb->protocol = eth_type_trans(skb, dev);
 #ifdef MV643XX_NAPI
@@ -1423,7 +1442,7 @@
  * Main interrupt handler for the gigbit ethernet ports
  */
 static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id,
-							struct pt_regs *regs)
+					   struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
 	struct mv643xx_private *mp = netdev_priv(dev);
@@ -1431,13 +1450,14 @@
 	unsigned int port_num = mp->port_num;
 
 	/* Read interrupt cause registers */
-	eth_int_cause = mv643xx_eth_read(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num)) &
-						INT_CAUSE_UNMASK_ALL;
+	eth_int_cause =
+		mv643xx_eth_read(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num)) &
+		INT_CAUSE_UNMASK_ALL;
 
 	if (eth_int_cause & BIT1)
-		eth_int_cause_ext = mv643xx_eth_read(
-			MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num)) &
-						INT_CAUSE_UNMASK_ALL_EXT;
+		eth_int_cause_ext =
+			mv643xx_eth_read(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num)) &
+			INT_CAUSE_UNMASK_ALL_EXT;
 
 #ifdef MV643XX_NAPI
 	if (!(eth_int_cause & 0x0007fffd)) {
@@ -1448,10 +1468,10 @@
 		 * acknowleding relevant bits.
 		 */
 		mv643xx_eth_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num),
-							~eth_int_cause);
+				  ~eth_int_cause);
 		if (eth_int_cause_ext != 0x0)
-			mv643xx_eth_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG
-					(port_num), ~eth_int_cause_ext);
+			mv643xx_eth_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 
+					  ~eth_int_cause_ext);
 
 		/* UDP change : We may need this */
 		if ((eth_int_cause_ext & 0x0000ffff) &&
@@ -1463,28 +1483,27 @@
 		if (netif_rx_schedule_prep(dev)) {
 			/* Mask all the interrupts */
 			mv643xx_eth_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num), 0);
-			mv643xx_eth_write(MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG
-								(port_num), 0);
+			mv643xx_eth_write(MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port_num), 0);
 			__netif_rx_schedule(dev);
 		}
 	}
 #else
-		if (eth_int_cause & (BIT2 | BIT11))
-			mv643xx_eth_receive_queue(dev);
+	if (eth_int_cause & (BIT2 | BIT11))
+		mv643xx_eth_receive_queue(dev);
 
-		/*
-		 * After forwarded received packets to upper layer, add a task
-		 * in an interrupts enabled context that refills the RX ring
-		 * with skb's.
-		 */
+	/*
+	 * After forwarded received packets to upper layer, add a task
+	 * in an interrupts enabled context that refills the RX ring
+	 * with skb's.
+	 */
 #ifdef MV643XX_RX_QUEUE_FILL_ON_TASK
-		/* Unmask all interrupts on ethernet port */
-		mv643xx_eth_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
-							INT_CAUSE_MASK_ALL);
-		queue_task(&mp->rx_task, &tq_immediate);
-		mark_bh(IMMEDIATE_BH);
+	/* Unmask all interrupts on ethernet port */
+	mv643xx_eth_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
+			  INT_CAUSE_MASK_ALL);
+	queue_task(&mp->rx_task, &tq_immediate);
+	mark_bh(IMMEDIATE_BH);
 #else
-		mp->rx_task.func(dev);
+	mp->rx_task.func(dev);
 #endif
 #endif
 	/* PHY status changed */
@@ -1498,23 +1517,24 @@
 			printk(KERN_DEBUG "%s: link phy regs: "
 			       "supported=%x advert=%x "
 			       "autoneg=%x speed=%d duplex=%d\n",
-			       dev->name, 
+			       dev->name,
 			       cmd.supported, cmd.advertising,
 			       cmd.autoneg, cmd.speed, cmd.duplex);
 
-		if(mii_link_ok(&mp->mii) && !netif_carrier_ok(dev)) {
+		if (mii_link_ok(&mp->mii) && !netif_carrier_ok(dev)) {
 			if (netif_msg_ifup(mp))
-				printk(KERN_INFO "%s: link up, %sMbps, %s-duplex\n",
-				       dev->name,
+				printk(KERN_INFO "%s: link up, %sMbps, "
+				       "%s-duplex\n", dev->name,
 				       cmd.speed == SPEED_1000 ? "1000" :
 				       cmd.speed == SPEED_100 ? "100" : "10",
-				       cmd.duplex == DUPLEX_FULL ? "full" : "half");
+				       cmd.duplex == DUPLEX_FULL ? "full" :
+				       "half");
 
 			netif_wake_queue(dev);
 			/* Start TX queue */
 			mv643xx_eth_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num), 1);
 
-		} else if(!mii_link_ok(&mp->mii) && netif_carrier_ok(dev)) {
+		} else if (!mii_link_ok(&mp->mii) && netif_carrier_ok(dev)) {
 			netif_stop_queue(dev);
 			if (netif_msg_ifdown(mp))
 				printk(KERN_INFO "%s: link down\n", dev->name);
@@ -1543,12 +1563,12 @@
 		if (pkt_info.return_info) {
 			if (skb_shinfo(pkt_info.return_info)->nr_frags)
 				dma_unmap_page(NULL, pkt_info.buf_ptr,
-						pkt_info.byte_cnt,
-						DMA_TO_DEVICE);
+					       pkt_info.byte_cnt,
+					       DMA_TO_DEVICE);
 			else
 				dma_unmap_single(NULL, pkt_info.buf_ptr,
-						pkt_info.byte_cnt,
-						DMA_TO_DEVICE);
+						 pkt_info.byte_cnt,
+						 DMA_TO_DEVICE);
 
 			dev_kfree_skb_irq(pkt_info.return_info);
 
@@ -1556,11 +1576,11 @@
 				mp->tx_ring_skbs--;
 		} else
 			dma_unmap_page(NULL, pkt_info.buf_ptr,
-					pkt_info.byte_cnt, DMA_TO_DEVICE);
+				       pkt_info.byte_cnt, DMA_TO_DEVICE);
 	}
 
 	if (netif_queue_stopped(dev) &&
-			mp->tx_ring_size > mp->tx_ring_skbs + MAX_DESCS_PER_SKB)
+	    mp->tx_ring_size > mp->tx_ring_skbs + MAX_DESCS_PER_SKB)
 		netif_wake_queue(dev);
 }
 
@@ -1583,8 +1603,8 @@
 	}
 #endif
 
-	if ((mv643xx_eth_read(MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port_num)))
-						!= (u32) mp->rx_used_desc_q) {
+	if ((mv643xx_eth_read(MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port_num))) != 
+	    (u32) mp->rx_used_desc_q) {
 		orig_budget = *budget;
 		if (orig_budget > dev->quota)
 			orig_budget = dev->quota;
@@ -1602,9 +1622,9 @@
 		mv643xx_eth_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
 		mv643xx_eth_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
 		mv643xx_eth_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
-						INT_CAUSE_UNMASK_ALL);
+				  INT_CAUSE_UNMASK_ALL);
 		mv643xx_eth_write(MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port_num),
-						INT_CAUSE_UNMASK_ALL_EXT);
+				  INT_CAUSE_UNMASK_ALL_EXT);
 		spin_unlock_irqrestore(&mp->lock, flags);
 	}
 
@@ -1632,7 +1652,7 @@
 
 	/* This is a hard error, log it. */
 	if ((mp->tx_ring_size - mp->tx_ring_skbs) <=
-					(skb_shinfo(skb)->nr_frags + 1)) {
+	    (skb_shinfo(skb)->nr_frags + 1)) {
 		netif_stop_queue(dev);
 		printk(KERN_ERR "%s: Trying to transmit when queue full!\n", 
 		       dev->name);
@@ -1651,18 +1671,20 @@
 	/* Update packet info data structure -- DMA owned, first last */
 #ifdef MV643XX_CHECKSUM_OFFLOAD_TX
 	if (!skb_shinfo(skb)->nr_frags) {
-linear:
+	linear:
 		if (skb->ip_summed != CHECKSUM_HW) {
 			pkt_info.cmd_sts = ETH_TX_ENABLE_INTERRUPT |
-					ETH_TX_FIRST_DESC | ETH_TX_LAST_DESC;
+					   ETH_TX_FIRST_DESC | ETH_TX_LAST_DESC;
 			pkt_info.l4i_chk = 0;
 		} else {
 			u32 ipheader = skb->nh.iph->ihl << 11;
 
 			pkt_info.cmd_sts = ETH_TX_ENABLE_INTERRUPT |
-					ETH_TX_FIRST_DESC | ETH_TX_LAST_DESC |
-					ETH_GEN_TCP_UDP_CHECKSUM |
-					ETH_GEN_IP_V_4_CHECKSUM | ipheader;
+					   ETH_TX_FIRST_DESC |
+					   ETH_TX_LAST_DESC |
+					   ETH_GEN_TCP_UDP_CHECKSUM |
+					   ETH_GEN_IP_V_4_CHECKSUM |
+					   ipheader;
 			/* CPU already calculated pseudo header checksum. */
 			if (skb->nh.iph->protocol == IPPROTO_UDP) {
 				pkt_info.cmd_sts |= ETH_UDP_FRAME;
@@ -1678,7 +1700,7 @@
 		}
 		pkt_info.byte_cnt = skb->len;
 		pkt_info.buf_ptr = dma_map_single(NULL, skb->data, skb->len,
-							DMA_TO_DEVICE);
+						  DMA_TO_DEVICE);
 		pkt_info.return_info = skb;
 		mp->tx_ring_skbs++;
 		status = mv643xx_eth_tx_packet(dev, &pkt_info);
@@ -1715,8 +1737,8 @@
 		/* first frag which is skb header */
 		pkt_info.byte_cnt = skb_headlen(skb);
 		pkt_info.buf_ptr = dma_map_single(NULL, skb->data,
-							skb_headlen(skb),
-							DMA_TO_DEVICE);
+						  skb_headlen(skb),
+						  DMA_TO_DEVICE);
 		pkt_info.l4i_chk = 0;
 		pkt_info.return_info = 0;
 		pkt_info.cmd_sts = ETH_TX_FIRST_DESC;
@@ -1724,7 +1746,8 @@
 		if (skb->ip_summed == CHECKSUM_HW) {
 			ipheader = skb->nh.iph->ihl << 11;
 			pkt_info.cmd_sts |= ETH_GEN_TCP_UDP_CHECKSUM |
-					ETH_GEN_IP_V_4_CHECKSUM | ipheader;
+					    ETH_GEN_IP_V_4_CHECKSUM |
+					    ipheader;
 			/* CPU already calculated pseudo header checksum. */
 			if (skb->nh.iph->protocol == IPPROTO_UDP) {
 				pkt_info.cmd_sts |= ETH_UDP_FRAME;
@@ -1754,7 +1777,7 @@
 			/* Last Frag enables interrupt and frees the skb */
 			if (frag == (skb_shinfo(skb)->nr_frags - 1)) {
 				pkt_info.cmd_sts |= ETH_TX_ENABLE_INTERRUPT |
-							ETH_TX_LAST_DESC;
+						    ETH_TX_LAST_DESC;
 				pkt_info.return_info = skb;
 				mp->tx_ring_skbs++;
 			} else {
@@ -1777,11 +1800,11 @@
 	}
 #else
 	pkt_info.cmd_sts = ETH_TX_ENABLE_INTERRUPT | ETH_TX_FIRST_DESC |
-							ETH_TX_LAST_DESC;
+		ETH_TX_LAST_DESC;
 	pkt_info.l4i_chk = 0;
 	pkt_info.byte_cnt = skb->len;
 	pkt_info.buf_ptr = dma_map_single(NULL, skb->data, skb->len,
-								DMA_TO_DEVICE);
+					  DMA_TO_DEVICE);
 	pkt_info.return_info = skb;
 	mp->tx_ring_skbs++;
 	status = mv643xx_eth_tx_packet(dev, &pkt_info);
@@ -1826,7 +1849,8 @@
 	unsigned int size;
 
 	/* Stop RX Queues */
-	mv643xx_eth_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num), 0x0000ff00);
+	mv643xx_eth_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num),
+			  0x0000ff00);
 
 	/* Clear the ethernet port interrupts */
 	mv643xx_eth_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
@@ -1834,11 +1858,11 @@
 
 	/* Unmask RX buffer and TX end interrupt */
 	mv643xx_eth_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
-						INT_CAUSE_UNMASK_ALL);
+			  INT_CAUSE_UNMASK_ALL);
 
 	/* Unmask phy and link status changes interrupts */
 	mv643xx_eth_write(MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port_num),
-						INT_CAUSE_UNMASK_ALL_EXT);
+			  INT_CAUSE_UNMASK_ALL_EXT);
 
 	/* Set the MAC Address */
 	memcpy(mp->port_mac_addr, dev->dev_addr, 6);
@@ -1856,13 +1880,13 @@
 
 	/* Allocate RX and TX skb rings */
 	mp->rx_skb = kmalloc(sizeof(*mp->rx_skb) * mp->rx_ring_size,
-								GFP_KERNEL);
+			     GFP_KERNEL);
 	if (!mp->rx_skb) {
 		printk(KERN_ERR "%s: Cannot allocate Rx skb ring\n", dev->name);
 		return -ENOMEM;
 	}
 	mp->tx_skb = kmalloc(sizeof(*mp->tx_skb) * mp->tx_ring_size,
-								GFP_KERNEL);
+			     GFP_KERNEL);
 	if (!mp->tx_skb) {
 		printk(KERN_ERR "%s: Cannot allocate Tx skb ring\n", dev->name);
 		kfree(mp->rx_skb);
@@ -1876,7 +1900,7 @@
 
 	if (mp->tx_sram_size) {
 		mp->p_tx_desc_area = ioremap(mp->tx_sram_addr,
-							mp->tx_sram_size);
+					     mp->tx_sram_size);
 		mp->tx_desc_dma = mp->tx_sram_addr;
 	} else
 		mp->p_tx_desc_area = dma_alloc_coherent(NULL, size,
@@ -1885,7 +1909,7 @@
 
 	if (!mp->p_tx_desc_area) {
 		printk(KERN_ERR "%s: Cannot allocate Tx Ring (size %d bytes)\n",
-							dev->name, size);
+		       dev->name, size);
 		kfree(mp->rx_skb);
 		kfree(mp->tx_skb);
 		return -ENOMEM;
@@ -1902,7 +1926,7 @@
 
 	if (mp->rx_sram_size) {
 		mp->p_rx_desc_area = ioremap(mp->rx_sram_addr,
-							mp->rx_sram_size);
+					     mp->rx_sram_size);
 		mp->rx_desc_dma = mp->rx_sram_addr;
 	} else
 		mp->p_rx_desc_area = dma_alloc_coherent(NULL, size,
@@ -1911,12 +1935,12 @@
 
 	if (!mp->p_rx_desc_area) {
 		printk(KERN_ERR "%s: Cannot allocate Rx ring (size %d bytes)\n",
-							dev->name, size);
+		       dev->name, size);
 		if (mp->rx_sram_size)
 			iounmap(mp->p_rx_desc_area);
 		else
 			dma_free_coherent(NULL, mp->tx_desc_area_size,
-					mp->p_tx_desc_area, mp->tx_desc_dma);
+					  mp->p_tx_desc_area, mp->tx_desc_dma);
 		kfree(mp->rx_skb);
 		kfree(mp->tx_skb);
 		return -ENOMEM;
@@ -1933,11 +1957,11 @@
 
 #ifdef MV643XX_COAL
 	mp->rx_int_coal =
-		mv643xx_eth_port_set_rx_coal(port_num, 133000000, MV643XX_RX_COAL);
+	    mv643xx_eth_port_set_rx_coal(port_num, 133000000, MV643XX_RX_COAL);
 #endif
 
 	mp->tx_int_coal =
-		mv643xx_eth_port_set_tx_coal(port_num, 133000000, MV643XX_TX_COAL);
+	    mv643xx_eth_port_set_tx_coal(port_num, 133000000, MV643XX_TX_COAL);
 
 	netif_start_queue(dev);
 
@@ -2135,11 +2159,10 @@
 	spin_lock_irq(&mp->lock);
 
 	err = request_irq(dev->irq, mv643xx_eth_int_handler,
-			SA_SHIRQ | SA_SAMPLE_RANDOM, dev->name, dev);
+			  SA_SHIRQ | SA_SAMPLE_RANDOM, dev->name, dev);
 
 	if (err) {
-		printk(KERN_ERR "%s: Cannot assign IRQ number\n",
-		       dev->name);
+		printk(KERN_ERR "%s: Cannot assign IRQ number\n", dev->name);
 		err = -EAGAIN;
 		goto out;
 	}
@@ -2212,12 +2235,12 @@
 	if (netif_running(dev)) {
 		if (mv643xx_eth_real_stop(dev))
 			printk(KERN_ERR
-				"%s: Fatal error on stopping device\n",
-				dev->name);
+			       "%s: Fatal error on stopping device\n",
+			       dev->name);
 		if (mv643xx_eth_real_open(dev))
 			printk(KERN_ERR
-				"%s: Fatal error on opening device\n",
-				dev->name);
+			       "%s: Fatal error on opening device\n",
+			       dev->name);
 	}
 
 	spin_unlock_irqrestore(&mp->lock, flags);
@@ -2235,53 +2258,68 @@
 };
 
 #define MV643XX_STAT(m) sizeof(((struct mv643xx_private *)0)->m), \
-		      offsetof(struct mv643xx_private, m)
+			offsetof(struct mv643xx_private, m)
 
 static const struct mv643xx_stats mv643xx_gstrings_stats[] = {
-	{ "rx_packets", MV643XX_STAT(stats.rx_packets) },
-	{ "tx_packets", MV643XX_STAT(stats.tx_packets) },
-	{ "rx_bytes", MV643XX_STAT(stats.rx_bytes) },
-	{ "tx_bytes", MV643XX_STAT(stats.tx_bytes) },
-	{ "rx_errors", MV643XX_STAT(stats.rx_errors) },
-	{ "tx_errors", MV643XX_STAT(stats.tx_errors) },
-	{ "rx_dropped", MV643XX_STAT(stats.rx_dropped) },
-	{ "tx_dropped", MV643XX_STAT(stats.tx_dropped) },
-	{ "good_octets_received", MV643XX_STAT(mib_counters.good_octets_received) },
-	{ "bad_octets_received", MV643XX_STAT(mib_counters.bad_octets_received) },
-	{ "internal_mac_transmit_err", MV643XX_STAT(mib_counters.internal_mac_transmit_err) },
-	{ "good_frames_received", MV643XX_STAT(mib_counters.good_frames_received) },
-	{ "bad_frames_received", MV643XX_STAT(mib_counters.bad_frames_received) },
-	{ "broadcast_frames_received", MV643XX_STAT(mib_counters.broadcast_frames_received) },
-	{ "multicast_frames_received", MV643XX_STAT(mib_counters.multicast_frames_received) },
-	{ "frames_64_octets", MV643XX_STAT(mib_counters.frames_64_octets) },
-	{ "frames_65_to_127_octets", MV643XX_STAT(mib_counters.frames_65_to_127_octets) },
-	{ "frames_128_to_255_octets", MV643XX_STAT(mib_counters.frames_128_to_255_octets) },
-	{ "frames_256_to_511_octets", MV643XX_STAT(mib_counters.frames_256_to_511_octets) },
-	{ "frames_512_to_1023_octets", MV643XX_STAT(mib_counters.frames_512_to_1023_octets) },
-	{ "frames_1024_to_max_octets", MV643XX_STAT(mib_counters.frames_1024_to_max_octets) },
-	{ "good_octets_sent", MV643XX_STAT(mib_counters.good_octets_sent) },
-	{ "good_frames_sent", MV643XX_STAT(mib_counters.good_frames_sent) },
-	{ "excessive_collision", MV643XX_STAT(mib_counters.excessive_collision) },
-	{ "multicast_frames_sent", MV643XX_STAT(mib_counters.multicast_frames_sent) },
-	{ "broadcast_frames_sent", MV643XX_STAT(mib_counters.broadcast_frames_sent) },
-	{ "unrec_mac_control_received", MV643XX_STAT(mib_counters.unrec_mac_control_received) },
-	{ "fc_sent", MV643XX_STAT(mib_counters.fc_sent) },
-	{ "good_fc_received", MV643XX_STAT(mib_counters.good_fc_received) },
-	{ "bad_fc_received", MV643XX_STAT(mib_counters.bad_fc_received) },
-	{ "undersize_received", MV643XX_STAT(mib_counters.undersize_received) },
-	{ "fragments_received", MV643XX_STAT(mib_counters.fragments_received) },
-	{ "oversize_received", MV643XX_STAT(mib_counters.oversize_received) },
-	{ "jabber_received", MV643XX_STAT(mib_counters.jabber_received) },
-	{ "mac_receive_error", MV643XX_STAT(mib_counters.mac_receive_error) },
-	{ "bad_crc_event", MV643XX_STAT(mib_counters.bad_crc_event) },
-	{ "collision", MV643XX_STAT(mib_counters.collision) },
-	{ "late_collision", MV643XX_STAT(mib_counters.late_collision) },
+	{"rx_packets", MV643XX_STAT(stats.rx_packets)},
+	{"tx_packets", MV643XX_STAT(stats.tx_packets)},
+	{"rx_bytes", MV643XX_STAT(stats.rx_bytes)},
+	{"tx_bytes", MV643XX_STAT(stats.tx_bytes)},
+	{"rx_errors", MV643XX_STAT(stats.rx_errors)},
+	{"tx_errors", MV643XX_STAT(stats.tx_errors)},
+	{"rx_dropped", MV643XX_STAT(stats.rx_dropped)},
+	{"tx_dropped", MV643XX_STAT(stats.tx_dropped)},
+	{"good_octets_received",
+	 MV643XX_STAT(mib_counters.good_octets_received)},
+	{"bad_octets_received",
+	 MV643XX_STAT(mib_counters.bad_octets_received)},
+	{"internal_mac_transmit_err",
+	 MV643XX_STAT(mib_counters.internal_mac_transmit_err)},
+	{"good_frames_received",
+	 MV643XX_STAT(mib_counters.good_frames_received)},
+	{"bad_frames_received", MV643XX_STAT(mib_counters.bad_frames_received)},
+	{"broadcast_frames_received",
+	 MV643XX_STAT(mib_counters.broadcast_frames_received)},
+	{"multicast_frames_received",
+	 MV643XX_STAT(mib_counters.multicast_frames_received)},
+	{"frames_64_octets", MV643XX_STAT(mib_counters.frames_64_octets)},
+	{"frames_65_to_127_octets",
+	 MV643XX_STAT(mib_counters.frames_65_to_127_octets)},
+	{"frames_128_to_255_octets",
+	 MV643XX_STAT(mib_counters.frames_128_to_255_octets)},
+	{"frames_256_to_511_octets",
+	 MV643XX_STAT(mib_counters.frames_256_to_511_octets)},
+	{"frames_512_to_1023_octets",
+	 MV643XX_STAT(mib_counters.frames_512_to_1023_octets)},
+	{"frames_1024_to_max_octets",
+	 MV643XX_STAT(mib_counters.frames_1024_to_max_octets)},
+	{"good_octets_sent", MV643XX_STAT(mib_counters.good_octets_sent)},
+	{"good_frames_sent", MV643XX_STAT(mib_counters.good_frames_sent)},
+	{"excessive_collision", MV643XX_STAT(mib_counters.excessive_collision)},
+	{"multicast_frames_sent",
+	 MV643XX_STAT(mib_counters.multicast_frames_sent)},
+	{"broadcast_frames_sent",
+	 MV643XX_STAT(mib_counters.broadcast_frames_sent)},
+	{"unrec_mac_control_received",
+	 MV643XX_STAT(mib_counters.unrec_mac_control_received)},
+	{"fc_sent", MV643XX_STAT(mib_counters.fc_sent)},
+	{"good_fc_received", MV643XX_STAT(mib_counters.good_fc_received)},
+	{"bad_fc_received", MV643XX_STAT(mib_counters.bad_fc_received)},
+	{"undersize_received", MV643XX_STAT(mib_counters.undersize_received)},
+	{"fragments_received", MV643XX_STAT(mib_counters.fragments_received)},
+	{"oversize_received", MV643XX_STAT(mib_counters.oversize_received)},
+	{"jabber_received", MV643XX_STAT(mib_counters.jabber_received)},
+	{"mac_receive_error", MV643XX_STAT(mib_counters.mac_receive_error)},
+	{"bad_crc_event", MV643XX_STAT(mib_counters.bad_crc_event)},
+	{"collision", MV643XX_STAT(mib_counters.collision)},
+	{"late_collision", MV643XX_STAT(mib_counters.late_collision)},
 };
 
 #define MV643XX_STATS_LEN	\
 	sizeof(mv643xx_gstrings_stats) / sizeof(struct mv643xx_stats)
 
-static int mv643xx_eth_mdio_read(struct net_device *dev, int phy_id, int location)
+static int mv643xx_eth_mdio_read(struct net_device *dev, int phy_id,
+				 int location)
 {
 	int val;
 
@@ -2289,13 +2327,14 @@
 	return val;
 }
 
-static void mv643xx_eth_mdio_write(struct net_device *dev, int phy_id, int location, int val)
+static void mv643xx_eth_mdio_write(struct net_device *dev, int phy_id,
+				   int location, int val)
 {
 	mv643xx_eth_write_smi_reg(dev, location, val);
 }
 
-static int
-mv643xx_eth_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+static int mv643xx_eth_get_settings(struct net_device *netdev,
+				    struct ethtool_cmd *ecmd)
 {
 	int rc;
 	struct mv643xx_private *mp = netdev_priv(netdev);
@@ -2310,19 +2349,17 @@
 	return rc;
 }
 
-static void
-mv643xx_eth_get_drvinfo(struct net_device *netdev,
-                       struct ethtool_drvinfo *drvinfo)
+static void mv643xx_eth_get_drvinfo(struct net_device *netdev,
+				    struct ethtool_drvinfo *drvinfo)
 {
-	strncpy(drvinfo->driver,  mv643xx_driver_name, 32);
+	strncpy(drvinfo->driver, mv643xx_driver_name, 32);
 	strncpy(drvinfo->version, mv643xx_driver_version, 32);
 	strncpy(drvinfo->fw_version, "N/A", 32);
 	strncpy(drvinfo->bus_info, "mv643xx", 32);
 	drvinfo->n_stats = MV643XX_STATS_LEN;
 }
 
-static int 
-mv643xx_eth_get_stats_count(struct net_device *netdev)
+static int mv643xx_eth_get_stats_count(struct net_device *netdev)
 {
 	return MV643XX_STATS_LEN;
 }
@@ -2335,25 +2372,24 @@
 
 	mv643xx_eth_update_mib_counters(dev);
 
-	for(i = 0; i < MV643XX_STATS_LEN; i++) {
-		char *p = (char *)mp+mv643xx_gstrings_stats[i].stat_offset;	
-		data[i] = (mv643xx_gstrings_stats[i].sizeof_stat == 
-			sizeof(uint64_t)) ? *(uint64_t *)p : *(uint32_t *)p;
+	for (i = 0; i < MV643XX_STATS_LEN; i++) {
+		char *p = (char *)mp + mv643xx_gstrings_stats[i].stat_offset;
+		data[i] = (mv643xx_gstrings_stats[i].sizeof_stat ==
+			   sizeof(uint64_t)) ? *(uint64_t *) p : *(uint32_t *) p;
 	}
 }
 
-static void 
-mv643xx_eth_get_strings(struct net_device *netdev, uint32_t stringset, uint8_t *data)
+static void mv643xx_eth_get_strings(struct net_device *netdev, 
+				    uint32_t stringset, uint8_t *data)
 {
 	int i;
 
-	switch(stringset) {
+	switch (stringset) {
 	case ETH_SS_STATS:
-		for (i=0; i < MV643XX_STATS_LEN; i++) {
-			memcpy(data + i * ETH_GSTRING_LEN, 
-			mv643xx_gstrings_stats[i].stat_string,
-			ETH_GSTRING_LEN);
-		}
+		for (i = 0; i < MV643XX_STATS_LEN; i++)
+			memcpy(data + i * ETH_GSTRING_LEN,
+			       mv643xx_gstrings_stats[i].stat_string,
+			       ETH_GSTRING_LEN);
 		break;
 	}
 }
@@ -2383,7 +2419,8 @@
 	return mii_nway_restart(&mp->mii);
 }
 
-static int mv643xx_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+static int mv643xx_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr,
+				int cmd)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 
@@ -2391,18 +2428,18 @@
 }
 
 static struct ethtool_ops mv643xx_ethtool_ops = {
-	.get_settings           = mv643xx_eth_get_settings,
-	.set_settings           = mv643xx_eth_set_settings,
-	.get_drvinfo            = mv643xx_eth_get_drvinfo,
-	.get_link		= mv643xx_eth_get_link,
-	.get_sg			= ethtool_op_get_sg,
-	.set_sg			= ethtool_op_set_sg,
-	.get_strings            = mv643xx_eth_get_strings,
-	.get_stats_count        = mv643xx_eth_get_stats_count,
-	.get_ethtool_stats      = mv643xx_eth_get_ethtool_stats,
-	.get_msglevel		= mv643xx_eth_get_msglevel,
-	.set_msglevel		= mv643xx_eth_set_msglevel,
-	.nway_reset		= mv643xx_eth_nway_restart,
+	.get_settings = mv643xx_eth_get_settings,
+	.set_settings = mv643xx_eth_set_settings,
+	.get_drvinfo = mv643xx_eth_get_drvinfo,
+	.get_link = mv643xx_eth_get_link,
+	.get_sg = ethtool_op_get_sg,
+	.set_sg = ethtool_op_set_sg,
+	.get_strings = mv643xx_eth_get_strings,
+	.get_stats_count = mv643xx_eth_get_stats_count,
+	.get_ethtool_stats = mv643xx_eth_get_ethtool_stats,
+	.get_msglevel = mv643xx_eth_get_msglevel,
+	.set_msglevel = mv643xx_eth_set_msglevel,
+	.nway_reset = mv643xx_eth_nway_restart,
 };
 
 /*
@@ -2436,7 +2473,7 @@
 
 	/* By default, log probe, interface up/down and error events */
 	mp->msg_enable = NETIF_MSG_PROBE | NETIF_MSG_IFUP | NETIF_MSG_IFDOWN |
-		NETIF_MSG_TX_ERR | NETIF_MSG_RX_ERR;
+			 NETIF_MSG_TX_ERR | NETIF_MSG_RX_ERR;
 
 	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
 	BUG_ON(!res);
@@ -2479,7 +2516,7 @@
 
 	/* Configure the timeout task */
 	INIT_WORK(&mp->tx_timeout_task,
-			(void (*)(void *))mv643xx_eth_tx_timeout_task, dev);
+		  (void (*)(void *))mv643xx_eth_tx_timeout_task, dev);
 
 	spin_lock_init(&mp->lock);
 
@@ -2562,17 +2599,17 @@
 
 	if (dev->features & NETIF_F_SG)
 		if (netif_msg_probe(mp))
-			printk(KERN_NOTICE "%s: Scatter Gather Enabled\n", 
+			printk(KERN_NOTICE "%s: Scatter Gather Enabled\n",
 			       dev->name);
 
 	if (dev->features & NETIF_F_IP_CSUM)
 		if (netif_msg_probe(mp))
-			printk(KERN_NOTICE "%s: TX TCP/IP Checksumming Supported\n",
-			       dev->name);
+			printk(KERN_NOTICE "%s: TX TCP/IP Checksumming "
+			       "Supported\n", dev->name);
 
 #ifdef MV643XX_CHECKSUM_OFFLOAD_TX
 	if (netif_msg_probe(mp))
-		printk(KERN_NOTICE "%s: RX TCP/UDP Checksum Offload ON\n", 
+		printk(KERN_NOTICE "%s: RX TCP/UDP Checksum Offload ON\n",
 		       dev->name);
 #endif
 
@@ -2619,7 +2656,7 @@
 		return -ENODEV;
 
 	mv643xx_eth_shared_base = ioremap(res->start,
-						MV643XX_ETH_SHARED_REGS_SIZE);
+					  MV643XX_ETH_SHARED_REGS_SIZE);
 	if (mv643xx_eth_shared_base == NULL)
 		return -ENOMEM;
 
@@ -2672,6 +2709,6 @@
 module_exit(mv643xx_eth_cleanup_module);
 
 MODULE_LICENSE("GPL");
-MODULE_AUTHOR(	"Rabeeh Khoury, Assaf Hoffman, Matthew Dharm, Manish Lachwani"
-		" and Dale Farnsworth");
+MODULE_AUTHOR("Rabeeh Khoury, Assaf Hoffman, Matthew Dharm, Manish Lachwani"
+	      " and Dale Farnsworth");
 MODULE_DESCRIPTION("Ethernet driver for Marvell MV643XX");
