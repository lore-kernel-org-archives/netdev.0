From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: mv643xx(13/20): remove useless function header block comments
Date: Mon, 28 Mar 2005 16:55:40 -0700
Message-ID: <20050328235539.GM29098@xyzzy>
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

This driver was full of big function header block comments with Name,
Description, Parameter, Input, Output and ReturnValue clauses, most of
which were completely useless. The parameter tables made the code
difficult to maintain and they added no value anyway. Where the
description text was useful, I retained it in a simple comment block
above the function but (as in most cases) where even the description
added no value, I simply deleted the whole comment block.

Signed-off-by: James Chapman <jchapman@katalix.com>
Acked-by: Dale Farnsworth <dale@farnsworth.org>

Index: linux-2.5-enet/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.c
+++ linux-2.5-enet/drivers/net/mv643xx_eth.c
@@ -115,9 +115,6 @@
  *		driver internal data needed for its operations.
  *
  *		Supported Features:
- *		- This low level driver is OS independent. Allocating memory for
- *		  the descriptor rings and buffers are not within the scope of
- *		  this driver.
  *		- The user is free from Rx/Tx queue managing.
  *		- This low level driver introduce functionality API that enable
  *		  the to operate Marvell's Gigabit Ethernet Controller in a
@@ -194,7 +191,7 @@
  *		this packet.
  *
  *		Receive operation:
- *		The eth_port_receive API set the packet information struct,
+ *		The mv643xx_eth_port_receive API set the packet information struct,
  *		passed by the caller, with received information from the
  *		'current' SDMA descriptor.
  *		It is the user responsibility to return this resource back
@@ -202,7 +199,7 @@
  *		Return Rx resource is done using the eth_rx_return_buff API.
  *
  *		Transmit operation:
- *		The eth_port_send API supports Scatter-Gather which enables to
+ *		The mv643xx_eth_tx_packet API supports Scatter-Gather which enables to
  *		send a packet spanned over multiple buffers. This means that
  *		for each packet info structure given by the user and put into
  *		the Tx descriptors ring, will be transmitted only if the 'LAST'
@@ -217,7 +214,7 @@
  *
  *		EXTERNAL INTERFACE
  *
- *	Prior to calling the initialization routine eth_port_init() the user
+ *	Prior to calling the initialization routine mv643xx_eth_port_init() the user
  *	must set the following fields under mv643xx_private struct:
  *	port_num		User Ethernet port number.
  *	port_mac_addr[6]	User defined port MAC address.
@@ -246,28 +243,6 @@
  * Ethernet port setup routines
  *****************************************************************************/
 
-/*
- * eth_port_uc_addr - This function Set the port unicast address table
- *
- * DESCRIPTION:
- *	This function locates the proper entry in the Unicast table for the
- *	specified MAC nibble and sets its properties according to function
- *	parameters.
- *
- * INPUT:
- *	unsigned int	eth_port_num	Port number.
- *	unsigned char	uc_nibble	Unicast MAC Address last nibble.
- *	int 		option		0 = Add, 1 = remove address.
- *
- * OUTPUT:
- *	This function add/removes MAC addresses from the port unicast address
- *	table.
- *
- * RETURN:
- *	true is output succeeded.
- *	false if option parameter is invalid.
- *
- */
 static int mv643xx_eth_port_mac_addr(unsigned int eth_port_num, unsigned char uc_nibble,
 								int option)
 {
@@ -312,24 +287,6 @@
 	return 1;
 }
 
-/*
- * eth_port_uc_addr_get - This function retrieves the port Unicast address
- * (MAC address) from the ethernet hw registers.
- *
- * DESCRIPTION:
- *		This function retrieves the port Ethernet MAC address.
- *
- * INPUT:
- *	unsigned int	eth_port_num	Port number.
- *	char		*MacAddr	pointer where the MAC address is stored
- *
- * OUTPUT:
- *	Copy the MAC address to the location pointed to by MacAddr
- *
- * RETURN:
- *	N/A.
- *
- */
 static void mv643xx_eth_port_mac_addr_get(struct net_device *dev, unsigned char *p_addr)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
@@ -347,24 +304,6 @@
 	p_addr[5] = mac_l & 0xff;
 }
 
-/*
- * eth_port_uc_addr_set - This function Set the port Unicast address.
- *
- * DESCRIPTION:
- *		This function Set the port Ethernet MAC address.
- *
- * INPUT:
- *	unsigned int	eth_port_num	Port number.
- *	char *		p_addr		Address to be set
- *
- * OUTPUT:
- *	Set MAC address low and high registers. also calls eth_port_uc_addr()
- *	To set the unicast table with the proper information.
- *
- * RETURN:
- *	N/A.
- *
- */
 static void mv643xx_eth_port_mac_addr_set(struct net_device *dev,
 					  unsigned char *p_addr)
 {
@@ -386,22 +325,6 @@
 	return;
 }
 
-/*
- * eth_port_init_mac_tables - Clear all entrance in the UC, SMC and OMC tables
- *
- * DESCRIPTION:
- *	Go through all the DA filter tables (Unicast, Special Multicast &
- *	Other Multicast) and set each entry to 0.
- *
- * INPUT:
- *	unsigned int	eth_port_num	Ethernet Port number.
- *
- * OUTPUT:
- *	Multicast and Unicast packets are rejected.
- *
- * RETURN:
- *	None.
- */
 static void mv643xx_eth_port_init_mac_tables(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
@@ -424,9 +347,6 @@
 }
 
 /*
- * eth_port_start - Start the Ethernet port activity.
- *
- * DESCRIPTION:
  *	This routine prepares the Ethernet port for Rx and Tx activity:
  *	 1. Initialize Tx and Rx Current Descriptor Pointer for each queue that
  *	    has been initialized a descriptor's ring (using
@@ -438,17 +358,8 @@
  *	    the ethernet port SDMA can starts to perform Rx and Tx activities.
  *
  *	Note: Each Rx and Tx queue descriptor's list must be initialized prior
- *	to calling this function (use ether_init_tx_desc_ring for Tx queues
- *	and ether_init_rx_desc_ring for Rx queues).
- *
- * INPUT:
- *	struct net_device *dev	Ethernet port control struct
- *
- * OUTPUT:
- *	Ethernet port is ready to receive and transmit.
- *
- * RETURN:
- *	None.
+ *	to calling this function (use mv643xx_eth_init_tx_desc_ring for Tx queues
+ *	and mv643xx_eth_init_rx_desc_ring for Rx queues).
  */
 static void mv643xx_eth_port_start(struct net_device *dev)
 {
@@ -502,21 +413,8 @@
 }
 
 /*
- * eth_clear_mib_counters - Clear all MIB counters
- *
- * DESCRIPTION:
  *	This function clears all MIB counters of a specific ethernet port.
  *	A read from the MIB counter will reset the counter.
- *
- * INPUT:
- *	unsigned int	eth_port_num	Ethernet Port number.
- *
- * OUTPUT:
- *	After reading all MIB counters, the counters resets.
- *
- * RETURN:
- *	MIB counter value.
- *
  */
 static void mv643xx_eth_clear_mib_counters(struct net_device *dev)
 {
@@ -531,22 +429,9 @@
 }
 
 /*
- * eth_port_reset - Reset Ethernet port
- *
- * DESCRIPTION:
  * 	This routine resets the chip by aborting any SDMA engine activity and
  *	clearing the MIB counters. The Receiver and the Transmit unit are in
  *	idle state after this command is performed and the port is disabled.
- *
- * INPUT:
- *	unsigned int	eth_port_num	Ethernet Port number.
- *
- * OUTPUT:
- *	Channel activity is halted.
- *
- * RETURN:
- *	None.
- *
  */
 static void mv643xx_eth_port_reset(struct net_device *dev)
 {
@@ -593,22 +478,6 @@
 	mv643xx_eth_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), reg_data);
 }
 
-/*
- * ethernet_phy_get - Get the ethernet port PHY address.
- *
- * DESCRIPTION:
- *	This routine returns the given ethernet port PHY address.
- *
- * INPUT:
- *	unsigned int	eth_port_num	Ethernet Port number.
- *
- * OUTPUT:
- *	None.
- *
- * RETURN:
- *	PHY address.
- *
- */
 static int mv643xx_eth_phy_get(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
@@ -619,23 +488,6 @@
 	return ((reg_data >> (5 * mp->port_num)) & 0x1f);
 }
 
-/*
- * ethernet_phy_set - Set the ethernet port PHY address.
- *
- * DESCRIPTION:
- *	This routine sets the given ethernet port PHY address.
- *
- * INPUT:
- *	unsigned int	eth_port_num	Ethernet Port number.
- *	int		phy_addr	PHY address.
- *
- * OUTPUT:
- *	None.
- *
- * RETURN:
- *	None.
- *
- */
 static void mv643xx_eth_phy_set(struct net_device *dev, int phy_addr)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
@@ -648,26 +500,6 @@
 	mv643xx_eth_write(MV643XX_ETH_PHY_ADDR_REG, reg_data);
 }
 
-/*
- * eth_port_read_smi_reg - Read PHY registers
- *
- * DESCRIPTION:
- *	This routine utilize the SMI interface to interact with the PHY in
- *	order to perform PHY register read.
- *
- * INPUT:
- *	unsigned int	port_num	Ethernet Port number.
- *	unsigned int	phy_reg		PHY register address offset.
- *	unsigned int	*value		Register value buffer.
- *
- * OUTPUT:
- *	Write the value of a specified PHY register into given buffer.
- *
- * RETURN:
- *	false if the PHY is busy or read data is not in valid state.
- *	true otherwise.
- *
- */
 static void mv643xx_eth_read_smi_reg(struct net_device *dev,
 				unsigned int phy_reg, unsigned int *value)
 {
@@ -706,26 +538,6 @@
 	spin_unlock_irqrestore(&mv643xx_eth_phy_lock, flags);
 }
 
-/*
- * eth_port_write_smi_reg - Write to PHY registers
- *
- * DESCRIPTION:
- *	This routine utilize the SMI interface to interact with the PHY in
- *	order to perform writes to PHY registers.
- *
- * INPUT:
- *	unsigned int	eth_port_num	Ethernet Port number.
- *	unsigned int	phy_reg		PHY register address offset.
- *	unsigned int	value		Register value.
- *
- * OUTPUT:
- *	Write the given value to the specified PHY register.
- *
- * RETURN:
- *	false if the PHY is busy.
- *	true otherwise.
- *
- */
 static void mv643xx_eth_write_smi_reg(struct net_device *dev,
 				      unsigned int phy_reg, unsigned int value)
 {
@@ -754,22 +566,6 @@
 	spin_unlock_irqrestore(&mv643xx_eth_phy_lock, flags);
 }
 
-/*
- * ethernet_phy_reset - Reset Ethernet port PHY.
- *
- * DESCRIPTION:
- *	This routine utilizes the SMI interface to reset the ethernet port PHY.
- *
- * INPUT:
- *	unsigned int	eth_port_num	Ethernet Port number.
- *
- * OUTPUT:
- *	The PHY is reset.
- *
- * RETURN:
- *	None.
- *
- */
 static void mv643xx_eth_phy_reset(struct net_device *dev)
 {
 	unsigned int phy_reg_data;
@@ -781,9 +577,6 @@
 }
 
 /*
- * eth_port_init - Initialize the Ethernet port driver
- *
- * DESCRIPTION:
  *	This function prepares the ethernet port to start its activity:
  *	1) Completes the ethernet port driver struct initialization toward port
  *		start routine.
@@ -794,15 +587,6 @@
  *	Note: Call this routine prior to eth_port_start routine and after
  *	setting user values in the user fields of Ethernet port control
  *	struct.
- *
- * INPUT:
- *	struct net_device *dev	Ethernet port control struct
- *
- * OUTPUT:
- *	See description.
- *
- * RETURN:
- *	None.
  */
 static void mv643xx_eth_port_init(struct net_device *dev)
 {
@@ -861,22 +645,8 @@
 }
 
 /*
- * ethernet_phy_detect - Detect whether a phy is present
- *
- * DESCRIPTION:
  *	This function tests whether there is a PHY present on
  *	the specified port.
- *
- * INPUT:
- *	unsigned int	eth_port_num	Ethernet Port number.
- *
- * OUTPUT:
- *	None
- *
- * RETURN:
- *	0 on success
- *	-ENODEV on failure
- *
  */
 static int mv643xx_eth_phy_detect(struct net_device *dev)
 {
@@ -898,23 +668,8 @@
 }
 
 /*
- * ethernet_set_config_reg - Set specified bits in configuration register.
- *
- * DESCRIPTION:
  *	This function sets specified bits in the given ethernet
  *	configuration register.
- *
- * INPUT:
- *	unsigned int	eth_port_num	Ethernet Port number.
- *	unsigned int	value		32 bit value.
- *
- * OUTPUT:
- *	The set bits in the value parameter are set in the configuration
- *	register.
- *
- * RETURN:
- *	None.
- *
  */
 static void mv643xx_eth_set_config_reg(struct net_device *dev,
 				       unsigned int value)
@@ -929,20 +684,8 @@
 }
 
 /*
- * ethernet_get_config_reg - Get the port configuration register
- *
- * DESCRIPTION:
  *	This function returns the configuration register value of the given
  *	ethernet port.
- *
- * INPUT:
- *	unsigned int	eth_port_num	Ethernet Port number.
- *
- * OUTPUT:
- *	None.
- *
- * RETURN:
- *	Port configuration register value.
  */
 static unsigned int mv643xx_eth_get_config_reg(struct net_device *dev)
 {
@@ -959,9 +702,6 @@
  *****************************************************************************/
 
 /*
- * ether_init_rx_desc_ring - Curve a Rx chain desc list and buffer in memory.
- *
- * DESCRIPTION:
  *	This function prepares a Rx chained list of descriptors and packet
  *	buffers in a form of a ring. The routine must be called after port
  *	initialization routine and before port start routine.
@@ -969,16 +709,6 @@
  *	devices in the system (i.e. DRAM). This function uses the ethernet
  *	struct 'virtual to physical' routine (set by the user) to set the ring
  *	with physical addresses.
- *
- * INPUT:
- *	struct net_device *dev	Ethernet Port Control srtuct.
- *
- * OUTPUT:
- *	The routine updates the Ethernet port control struct with information
- *	regarding the Rx descriptors and buffers.
- *
- * RETURN:
- *	None.
  */
 static void mv643xx_eth_init_rx_desc_ring(struct net_device *dev)
 {
@@ -1005,9 +735,6 @@
 }
 
 /*
- * ether_init_tx_desc_ring - Curve a Tx chain desc list and buffer in memory.
- *
- * DESCRIPTION:
  *	This function prepares a Tx chained list of descriptors and packet
  *	buffers in a form of a ring. The routine must be called after port
  *	initialization routine and before port start routine.
@@ -1015,16 +742,6 @@
  *	devices in the system (i.e. DRAM). This function uses the ethernet
  *	struct 'virtual to physical' routine (set by the user) to set the ring
  *	with physical addresses.
- *
- * INPUT:
- *	struct net_device *dev	Ethernet Port Control srtuct.
- *
- * OUTPUT:
- *	The routine updates the Ethernet port control struct with information
- *	regarding the Tx descriptors and buffers.
- *
- * RETURN:
- *	None.
  */
 static void mv643xx_eth_init_tx_desc_ring(struct net_device *dev)
 {
@@ -1111,27 +828,12 @@
 #ifdef MV643XX_COAL
 
 /*
- * eth_port_set_rx_coal - Sets coalescing interrupt mechanism on RX path
- *
- * DESCRIPTION:
  *	This routine sets the RX coalescing interrupt mechanism parameter.
  *	This parameter is a timeout counter, that counts in 64 t_clk
  *	chunks ; that when timeout event occurs a maskable interrupt
  *	occurs.
  *	The parameter is calculated using the tClk of the MV-643xx chip
- *	, and the required delay of the interrupt in usec.
- *
- * INPUT:
- *	unsigned int eth_port_num	Ethernet port number
- *	unsigned int t_clk		t_clk of the MV-643xx chip in HZ units
- *	unsigned int delay		Delay in usec
- *
- * OUTPUT:
- *	Interrupt coalescing mechanism value is set in MV-643xx chip.
- *
- * RETURN:
- *	The interrupt coalescing value set in the gigE port.
- *
+ *	and the required delay of the interrupt in usec.
  */
 static unsigned int mv643xx_eth_port_set_rx_coal(unsigned int eth_port_num,
 					unsigned int t_clk, unsigned int delay)
@@ -1149,27 +851,12 @@
 #endif
 
 /*
- * eth_port_set_tx_coal - Sets coalescing interrupt mechanism on TX path
- *
- * DESCRIPTION:
  *	This routine sets the TX coalescing interrupt mechanism parameter.
  *	This parameter is a timeout counter, that counts in 64 t_clk
  *	chunks ; that when timeout event occurs a maskable interrupt
  *	occurs.
  *	The parameter is calculated using the t_cLK frequency of the
  *	MV-643xx chip and the required delay in the interrupt in uSec
- *
- * INPUT:
- *	unsigned int eth_port_num	Ethernet port number
- *	unsigned int t_clk		t_clk of the MV-643xx chip in HZ units
- *	unsigned int delay		Delay in uSeconds
- *
- * OUTPUT:
- *	Interrupt coalescing mechanism value is set in MV-643xx chip.
- *
- * RETURN:
- *	The interrupt coalescing value set in the gigE port.
- *
  */
 static unsigned int mv643xx_eth_port_set_tx_coal(unsigned int eth_port_num,
 					unsigned int t_clk, unsigned int delay)
@@ -1187,9 +874,6 @@
  *****************************************************************************/
 
 /*
- * eth_port_send - Send an Ethernet packet
- *
- * DESCRIPTION:
  *	This routine send a given packet described by p_pktinfo parameter. It
  *	supports transmitting of a packet spaned over multiple buffers. The
  *	routine updates 'curr' and 'first' indexes according to the packet
@@ -1198,20 +882,6 @@
  *	If the routine get into Tx resource error it assigns 'curr' index as
  *	'first'. This way the function can abort Tx process of multiple
  *	descriptors per packet.
- *
- * INPUT:
- *	struct mv643xx_private	*mp		Ethernet Port Control srtuct.
- *	struct pkt_info		*p_pkt_info	User packet buffer.
- *
- * OUTPUT:
- *	Tx ring 'curr' and 'first' indexes are updated.
- *
- * RETURN:
- *	ETH_QUEUE_FULL in case of Tx resource error.
- *	ETH_ERROR in case the routine can not access Tx desc ring.
- *	ETH_QUEUE_LAST_RESOURCE if the routine uses the last Tx resource.
- *	ETH_OK otherwise.
- *
  */
 #ifdef MV643XX_CHECKSUM_OFFLOAD_TX
 /*
@@ -1374,28 +1044,11 @@
 #endif
 
 /*
- * eth_tx_return_desc - Free all used Tx descriptors
- *
- * DESCRIPTION:
  *	This routine returns the transmitted packet information to the caller.
  *	It uses the 'first' index to support Tx desc return in case a transmit
  *	of a packet spanned over multiple buffer still in process.
  *	In case the Tx queue was in "resource error" condition, where there are
  *	no available Tx resources, the function resets the resource error flag.
- *
- * INPUT:
- *	struct mv643xx_private	*mp		Ethernet Port Control srtuct.
- *	struct pkt_info		*p_pkt_info	User packet buffer.
- *
- * OUTPUT:
- *	Tx ring 'first' and 'used' indexes are updated.
- *
- * RETURN:
- *	ETH_ERROR in case the routine can not access Tx desc ring.
- *	ETH_RETRY in case there is transmission in process.
- *	ETH_END_OF_JOB if the routine has nothing to release.
- *	ETH_OK otherwise.
- *
  */
 static int mv643xx_eth_tx_return_desc(struct net_device *dev,
 				      struct pkt_info *p_pkt_info)
@@ -1444,27 +1097,11 @@
 }
 
 /*
- * eth_port_receive - Get received information from Rx ring.
- *
- * DESCRIPTION:
  * 	This routine returns the received data to the caller. There is no
  *	data copying during routine operation. All information is returned
  *	using pointer to packet information struct passed from the caller.
  *	If the routine exhausts Rx ring resources then the resource error flag
  *	is set.
- *
- * INPUT:
- *	struct mv643xx_private	*mp		Ethernet Port Control srtuct.
- *	struct pkt_info		*p_pkt_info	User packet buffer.
- *
- * OUTPUT:
- *	Rx ring current and used indexes are updated.
- *
- * RETURN:
- *	ETH_ERROR in case the routine can not access Rx desc ring.
- *	ETH_QUEUE_FULL if Rx ring resources are exhausted.
- *	ETH_END_OF_JOB if there is no received data.
- *	ETH_OK otherwise.
  */
 static int mv643xx_eth_rx_packet(struct net_device *dev,
 				 struct pkt_info *p_pkt_info)
@@ -1520,24 +1157,10 @@
 }
 
 /*
- * eth_rx_return_buff - Returns a Rx buffer back to the Rx ring.
- *
- * DESCRIPTION:
  *	This routine returns a Rx buffer back to the Rx ring. It retrieves the
  *	next 'used' descriptor and attached the returned buffer to it.
  *	In case the Rx ring was in "resource error" condition, where there are
  *	no available Rx resources, the function resets the resource error flag.
- *
- * INPUT:
- *	struct mv643xx_private	*mp		Ethernet Port Control srtuct.
- *	struct pkt_info		*p_pkt_info	Information on returned buffer.
- *
- * OUTPUT:
- *	New available Rx resource in Rx descriptor ring.
- *
- * RETURN:
- *	ETH_ERROR in case the routine can not access Rx desc ring.
- *	ETH_OK otherwise.
  */
 static void mv643xx_eth_rx_return_buff(struct net_device *dev,
 				       struct pkt_info *p_pkt_info)
@@ -1575,14 +1198,9 @@
 }
 
 /*
- * mv643xx_eth_rx_task_timer_wrapper
- *
  * Timer routine to wake up RX queue filling task. This function is
  * used only in case the RX queue is empty, and all alloc_skb has
  * failed (due to out of memory event).
- *
- * Input :	pointer to ethernet interface network device structure
- * Output :	N/A
  */
 static void mv643xx_eth_rx_task_timer_wrapper(unsigned long data)
 {
@@ -1594,12 +1212,7 @@
 }
 
 /*
- * mv643xx_eth_rx_task
- *
  * Fills / refills RX queue on a certain gigabit ethernet port
- *
- * Input :	pointer to ethernet interface network device structure
- * Output :	N/A
  */
 static void mv643xx_eth_rx_task(void *data)
 {
@@ -1647,12 +1260,7 @@
 }
 
 /*
- * mv643xx_eth_tx_timeout
- *
  * Called upon a timeout on transmitting a packet
- *
- * Input :	pointer to ethernet interface network device structure.
- * Output :	N/A
  */
 static void mv643xx_eth_tx_timeout(struct net_device *dev)
 {
@@ -1666,8 +1274,6 @@
 }
 
 /*
- * mv643xx_eth_tx_timeout_task
- *
  * Actual routine to reset the adapter when a timeout on Tx has occurred
  */
 static void mv643xx_eth_tx_timeout_task(struct net_device *dev)
@@ -1678,13 +1284,6 @@
 	netif_device_attach(dev);
 }
 
-/*
- * mv643xx_eth_free_tx_queue
- *
- * Input :	dev - a pointer to the required interface
- *
- * Output :	0 if was able to release skb , nonzero otherwise
- */
 static int mv643xx_eth_free_tx_queue(struct net_device *dev,
 					unsigned int eth_int_cause_ext)
 {
@@ -1745,15 +1344,8 @@
 }
 
 /*
- * mv643xx_eth_receive
- *
  * This function is forward packets that are received from the port's
- * queues toward kernel core or FastRoute them to another interface.
- *
- * Input :	dev - a pointer to the required interface
- *		max - maximum number to receive (0 means unlimted)
- *
- * Output :	number of served packets
+ * queues toward kernel core.
  */
 #ifdef MV643XX_NAPI
 static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
@@ -1828,16 +1420,8 @@
 }
 
 /*
- * mv643xx_eth_int_handler
- *
  * Main interrupt handler for the gigbit ethernet ports
- *
- * Input :	irq	- irq number (not used)
- *		dev_id	- a pointer to the required interface's data structure
- *		regs	- not used
- * Output :	N/A
  */
-
 static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id,
 							struct pt_regs *regs)
 {
@@ -1981,8 +1565,6 @@
 }
 
 /*
- * mv643xx_poll
- *
  * This function is used in case of NAPI
  */
 static int mv643xx_eth_poll(struct net_device *dev, int *budget)
@@ -2031,15 +1613,8 @@
 #endif
 
 /*
- * mv643xx_eth_start_xmit
- *
  * This function is queues a packet in the Tx descriptor for
  * required port.
- *
- * Input :	skb - a pointer to socket buffer
- *		dev - a pointer to the required port
- *
- * Output :	zero upon success
  */
 static int mv643xx_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
@@ -2241,7 +1816,9 @@
  * net_device interface functions
  *****************************************************************************/
 
-/* Helper function for mv643xx_eth_open */
+/* 
+ * Helper function for mv643xx_eth_open
+ */
 static int mv643xx_eth_real_open(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
@@ -2368,17 +1945,10 @@
 }
 
 /*
- * mv643xx_eth_stop
- *
  * This function is used when closing the network device.
  * It updates the hardware,
  * release all memory that holds buffers and descriptors and release the IRQ.
- * Input :	a pointer to the device structure
- * Output :	zero if success , nonzero if fails
  */
-
-/* Helper function for mv643xx_eth_stop */
-
 static int mv643xx_eth_real_stop(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
@@ -2405,14 +1975,6 @@
 	return 0;
 }
 
-/*
- * mv643xx_eth_update_mac_address
- *
- * Update the MAC address of the port in the address table
- *
- * Input :	pointer to ethernet interface network device structure
- * Output :	N/A
- */
 static void mv643xx_eth_update_mac_address(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
@@ -2422,14 +1984,6 @@
 	mv643xx_eth_port_mac_addr_set(dev, mp->port_mac_addr);
 }
 
-/*
- * mv643xx_eth_set_rx_mode
- *
- * Change from promiscuos to regular rx mode
- *
- * Input :	pointer to ethernet interface network device structure
- * Output :	N/A
- */
 static void mv643xx_eth_set_rx_mode(struct net_device *dev)
 {
 	u32 config_reg;
@@ -2443,15 +1997,9 @@
 }
 
 /*
- * mv643xx_eth_set_mac_address
- *
  * Change the interface's mac address.
  * No special hardware thing should be done because interface is always
  * put in promiscuous mode.
- *
- * Input :	pointer to ethernet interface network device structure and
- *		a pointer to the designated entry to be added to the cache.
- * Output :	zero upon success, negative upon failure
  */
 static int mv643xx_eth_set_mac_address(struct net_device *dev, void *addr)
 {
@@ -2574,18 +2122,11 @@
 }
 
 /*
- * mv643xx_eth_open
- *
  * This function is called when openning the network device. The function
  * should initialize all the hardware, initialize cyclic Rx/Tx
  * descriptors chain and buffers and allocate an IRQ to the network
  * device.
- *
- * Input :	a pointer to the network device structure
- *
- * Output :	zero of success , nonzero if fails.
  */
-
 static int mv643xx_eth_open(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
@@ -2639,16 +2180,6 @@
 	return 0;
 }
 
-/*
- * mv643xx_eth_get_stats
- *
- * Returns a pointer to the interface statistics.
- *
- * Input :	dev - a pointer to the required interface
- *
- * Output :	a pointer to the interface's statistics
- */
-
 static struct net_device_stats *mv643xx_eth_get_stats(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
@@ -2658,10 +2189,6 @@
 
 /*
  * Changes MTU (maximum transfer unit) of the gigabit ethenret port
- *
- * Input :	pointer to ethernet interface network device structure
- *		new mtu size
- * Output :	0 upon success, -EINVAL upon failure
  */
 static int mv643xx_eth_change_mtu(struct net_device *dev, int new_mtu)
 {
@@ -2754,9 +2281,6 @@
 #define MV643XX_STATS_LEN	\
 	sizeof(mv643xx_gstrings_stats) / sizeof(struct mv643xx_stats)
 
-/*
- * Wrappers for MII support library.
- */
 static int mv643xx_eth_mdio_read(struct net_device *dev, int phy_id, int location)
 {
 	int val;
@@ -2882,15 +2406,10 @@
 };
 
 /*
- * mv643xx_eth_probe
- *
  * First function called after registering the network device.
  * It's purpose is to initialize the device as an ethernet device,
  * fill the ethernet device structure with pointers * to functions,
  * and set the MAC address of the interface
- *
- * Input :	struct device *
- * Output :	-ENOMEM if failed , 0 if success
  */
 static int mv643xx_eth_probe(struct device *ddev)
 {
@@ -3130,15 +2649,6 @@
 	.remove = mv643xx_eth_shared_remove,
 };
 
-/*
- * mv643xx_init_module
- *
- * Registers the network drivers into the Linux kernel
- *
- * Input :	N/A
- *
- * Output :	N/A
- */
 static int __init mv643xx_eth_init_module(void)
 {
 	int rc;
@@ -3152,15 +2662,6 @@
 	return rc;
 }
 
-/*
- * mv643xx_cleanup_module
- *
- * Registers the network drivers into the Linux kernel
- *
- * Input :	N/A
- *
- * Output :	N/A
- */
 static void __exit mv643xx_eth_cleanup_module(void)
 {
 	driver_unregister(&mv643xx_eth_driver);
