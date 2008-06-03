From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 18/39] mv643xx_eth: kill superfluous comments
Date: Tue,  3 Jun 2008 13:02:33 +0200
Message-ID: <1212490974-23719-19-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48753 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755843AbYFCMAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:41 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Half of the functions in the mv643xx_eth driver are prefixed by
useless and baroque comment blocks on _what_ those functions do (which
is obvious from the code itself) rather than why, and there's no point
in keeping those comments around.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |  552 ---------------------------------------------
 1 files changed, 0 insertions(+), 552 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 15174b9..16dee87 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -436,26 +436,6 @@ static unsigned int mv643xx_eth_port_disable_tx(struct mv643xx_eth_private *mep)
 /* rx ***********************************************************************/
 static void mv643xx_eth_free_completed_tx_descs(struct net_device *dev);
 
-/*
- * rx_return_buff - Returns a Rx buffer back to the Rx ring.
- *
- * DESCRIPTION:
- *	This routine returns a Rx buffer back to the Rx ring. It retrieves the
- *	next 'used' descriptor and attached the returned buffer to it.
- *	In case the Rx ring was in "resource error" condition, where there are
- *	no available Rx resources, the function resets the resource error flag.
- *
- * INPUT:
- *	struct mv643xx_eth_private	*mep		Ethernet Port Control srtuct.
- *	struct pkt_info		*p_pkt_info	Information on returned buffer.
- *
- * OUTPUT:
- *	New available Rx resource in Rx descriptor ring.
- *
- * RETURN:
- *	ETH_ERROR in case the routine can not access Rx desc ring.
- *	ETH_OK otherwise.
- */
 static FUNC_RET_STATUS rx_return_buff(struct mv643xx_eth_private *mep,
 						struct pkt_info *p_pkt_info)
 {
@@ -491,14 +471,6 @@ static FUNC_RET_STATUS rx_return_buff(struct mv643xx_eth_private *mep,
 	return ETH_OK;
 }
 
-/*
- * mv643xx_eth_rx_refill_descs
- *
- * Fills / refills RX queue on a certain gigabit ethernet port
- *
- * Input :	pointer to ethernet interface network device structure
- * Output :	N/A
- */
 static void mv643xx_eth_rx_refill_descs(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
@@ -537,44 +509,11 @@ static void mv643xx_eth_rx_refill_descs(struct net_device *dev)
 	}
 }
 
-/*
- * mv643xx_eth_rx_refill_descs_timer_wrapper
- *
- * Timer routine to wake up RX queue filling task. This function is
- * used only in case the RX queue is empty, and all alloc_skb has
- * failed (due to out of memory event).
- *
- * Input :	pointer to ethernet interface network device structure
- * Output :	N/A
- */
 static inline void mv643xx_eth_rx_refill_descs_timer_wrapper(unsigned long data)
 {
 	mv643xx_eth_rx_refill_descs((struct net_device *)data);
 }
 
-/*
- * port_receive - Get received information from Rx ring.
- *
- * DESCRIPTION:
- * 	This routine returns the received data to the caller. There is no
- *	data copying during routine operation. All information is returned
- *	using pointer to packet information struct passed from the caller.
- *	If the routine exhausts Rx ring resources then the resource error flag
- *	is set.
- *
- * INPUT:
- *	struct mv643xx_eth_private	*mep		Ethernet Port Control srtuct.
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
- */
 static FUNC_RET_STATUS port_receive(struct mv643xx_eth_private *mep,
 						struct pkt_info *p_pkt_info)
 {
@@ -630,17 +569,6 @@ static FUNC_RET_STATUS port_receive(struct mv643xx_eth_private *mep,
 	return ETH_OK;
 }
 
-/*
- * mv643xx_eth_receive
- *
- * This function is forward packets that are received from the port's
- * queues toward kernel core or FastRoute them to another interface.
- *
- * Input :	dev - a pointer to the required interface
- *		max - maximum number to receive (0 means unlimted)
- *
- * Output :	number of served packets
- */
 static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
@@ -710,11 +638,6 @@ static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
 }
 
 #ifdef MV643XX_ETH_NAPI
-/*
- * mv643xx_eth_poll
- *
- * This function is used in case of NAPI
- */
 static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 {
 	struct mv643xx_eth_private *mep = container_of(napi, struct mv643xx_eth_private, napi);
@@ -747,13 +670,6 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 
 
 /* tx ***********************************************************************/
-/**
- * has_tiny_unaligned_frags - check if skb has any small, unaligned fragments
- *
- * Hardware can't handle unaligned fragments smaller than 9 bytes.
- * This helper function detects that case.
- */
-
 static inline unsigned int has_tiny_unaligned_frags(struct sk_buff *skb)
 {
 	unsigned int frag;
@@ -767,9 +683,6 @@ static inline unsigned int has_tiny_unaligned_frags(struct sk_buff *skb)
 	return 0;
 }
 
-/**
- * alloc_tx_desc_index - return the index of the next available tx desc
- */
 static int alloc_tx_desc_index(struct mv643xx_eth_private *mep)
 {
 	int tx_desc_curr;
@@ -784,12 +697,6 @@ static int alloc_tx_desc_index(struct mv643xx_eth_private *mep)
 	return tx_desc_curr;
 }
 
-/**
- * tx_fill_frag_descs - fill tx hw descriptors for an skb's fragments.
- *
- * Ensure the data for each fragment to be transmitted is mapped properly,
- * then fill in descriptors in the tx hw queue.
- */
 static void tx_fill_frag_descs(struct mv643xx_eth_private *mep,
 				   struct sk_buff *skb)
 {
@@ -828,12 +735,6 @@ static inline __be16 sum16_as_be(__sum16 sum)
 	return (__force __be16)sum;
 }
 
-/**
- * tx_submit_descs_for_skb - submit data from an skb to the tx hw
- *
- * Ensure the data for an skb to be transmitted is mapped properly,
- * then fill in descriptors in the tx hw queue and start the hardware.
- */
 static void tx_submit_descs_for_skb(struct mv643xx_eth_private *mep,
 					struct sk_buff *skb)
 {
@@ -897,10 +798,6 @@ static void tx_submit_descs_for_skb(struct mv643xx_eth_private *mep,
 	mep->tx_desc_count += nr_frags + 1;
 }
 
-/**
- * mv643xx_eth_start_xmit - queue an skb to the hardware for transmission
- *
- */
 static int mv643xx_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
@@ -942,26 +839,6 @@ static int mv643xx_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 /* mii management interface *************************************************/
 static int phy_addr_get(struct mv643xx_eth_private *mep);
 
-/*
- * read_smi_reg - Read PHY registers
- *
- * DESCRIPTION:
- *	This routine utilize the SMI interface to interact with the PHY in
- *	order to perform PHY register read.
- *
- * INPUT:
- *	struct mv643xx_eth_private *mep	Ethernet Port.
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
 static void read_smi_reg(struct mv643xx_eth_private *mep,
 				unsigned int phy_reg, unsigned int *value)
 {
@@ -998,26 +875,6 @@ out:
 	spin_unlock_irqrestore(&mep->shared_smi->phy_lock, flags);
 }
 
-/*
- * write_smi_reg - Write to PHY registers
- *
- * DESCRIPTION:
- *	This routine utilize the SMI interface to interact with the PHY in
- *	order to perform writes to PHY registers.
- *
- * INPUT:
- *	struct mv643xx_eth_private *mep	Ethernet Port.
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
 static void write_smi_reg(struct mv643xx_eth_private *mep,
 				   unsigned int phy_reg, unsigned int value)
 {
@@ -1046,23 +903,6 @@ out:
 
 
 /* mib counters *************************************************************/
-/*
- * clear_mib_counters - Clear all MIB counters
- *
- * DESCRIPTION:
- *	This function clears all MIB counters of a specific ethernet port.
- *	A read from the MIB counter will reset the counter.
- *
- * INPUT:
- *	struct mv643xx_eth_private *mep	Ethernet Port.
- *
- * OUTPUT:
- *	After reading all MIB counters, the counters resets.
- *
- * RETURN:
- *	MIB counter value.
- *
- */
 static void clear_mib_counters(struct mv643xx_eth_private *mep)
 {
 	unsigned int port_num = mep->port_num;
@@ -1277,9 +1117,6 @@ static const struct ethtool_ops mv643xx_eth_ethtool_ops = {
 
 
 /* address handling *********************************************************/
-/*
- * uc_addr_get - Read the MAC address from the port's hw registers
- */
 static void uc_addr_get(struct mv643xx_eth_private *mep, unsigned char *p_addr)
 {
 	unsigned int port_num = mep->port_num;
@@ -1297,22 +1134,6 @@ static void uc_addr_get(struct mv643xx_eth_private *mep, unsigned char *p_addr)
 	p_addr[5] = mac_l & 0xff;
 }
 
-/*
- * init_mac_tables - Clear all entrance in the UC, SMC and OMC tables
- *
- * DESCRIPTION:
- *	Go through all the DA filter tables (Unicast, Special Multicast &
- *	Other Multicast) and set each entry to 0.
- *
- * INPUT:
- *	struct mv643xx_eth_private *mep	Ethernet Port.
- *
- * OUTPUT:
- *	Multicast and Unicast packets are rejected.
- *
- * RETURN:
- *	None.
- */
 static void init_mac_tables(struct mv643xx_eth_private *mep)
 {
 	unsigned int port_num = mep->port_num;
@@ -1330,15 +1151,6 @@ static void init_mac_tables(struct mv643xx_eth_private *mep)
 	}
 }
 
-/*
- * The entries in each table are indexed by a hash of a packet's MAC
- * address.  One bit in each entry determines whether the packet is
- * accepted.  There are 4 entries (each 8 bits wide) in each register
- * of the table.  The bits in each entry are defined as follows:
- *	0	Accept=1, Drop=0
- *	3-1	Queue			(ETH_Q0=0)
- *	7-4	Reserved = 0;
- */
 static void set_filter_table_entry(struct mv643xx_eth_private *mep,
 					    int table, unsigned char entry)
 {
@@ -1355,9 +1167,6 @@ static void set_filter_table_entry(struct mv643xx_eth_private *mep,
 	wrl(mep, table + tbl_offset, table_reg);
 }
 
-/*
- * uc_addr_set - Write a MAC address into the port's hw registers
- */
 static void uc_addr_set(struct mv643xx_eth_private *mep, unsigned char *p_addr)
 {
 	unsigned int port_num = mep->port_num;
@@ -1377,14 +1186,6 @@ static void uc_addr_set(struct mv643xx_eth_private *mep, unsigned char *p_addr)
 	set_filter_table_entry(mep, table, p_addr[5] & 0x0f);
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
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
@@ -1393,17 +1194,6 @@ static void mv643xx_eth_update_mac_address(struct net_device *dev)
 	uc_addr_set(mep, dev->dev_addr);
 }
 
-/*
- * mv643xx_eth_set_mac_address
- *
- * Change the interface's mac address.
- * No special hardware thing should be done because interface is always
- * put in promiscuous mode.
- *
- * Input :	pointer to ethernet interface network device structure and
- *		a pointer to the designated entry to be added to the cache.
- * Output :	zero upon success, negative upon failure
- */
 static int mv643xx_eth_set_mac_address(struct net_device *dev, void *addr)
 {
 	int i;
@@ -1415,20 +1205,6 @@ static int mv643xx_eth_set_mac_address(struct net_device *dev, void *addr)
 	return 0;
 }
 
-/*
- * mc_addr - Multicast address settings.
- *
- * The MV device supports multicast using two tables:
- * 1) Special Multicast Table for MAC addresses of the form
- *    0x01-00-5E-00-00-XX (where XX is between 0x00 and 0x_FF).
- *    The MAC DA[7:0] bits are used as a pointer to the Special Multicast
- *    Table entries in the DA-Filter table.
- * 2) Other Multicast Table for multicast of another type. A CRC-8bit
- *    is used as an index to the Other Multicast Table entries in the
- *    DA-Filter table.  This function calculates the CRC-8bit value.
- * In either case, set_filter_table_entry() is then called
- * to set to set the actual table entry.
- */
 static void mc_addr(struct mv643xx_eth_private *mep, unsigned char *p_addr)
 {
 	unsigned int port_num = mep->port_num;
@@ -1519,9 +1295,6 @@ static void mc_addr(struct mv643xx_eth_private *mep, unsigned char *p_addr)
 	set_filter_table_entry(mep, table, crc_result);
 }
 
-/*
- * Set the entire multicast list based on dev->mc_list.
- */
 static void set_multicast_list(struct net_device *dev)
 {
 
@@ -1579,14 +1352,6 @@ static void set_multicast_list(struct net_device *dev)
 			mc_addr(mep, mc_list->dmi_addr);
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
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
@@ -1604,28 +1369,6 @@ static void mv643xx_eth_set_rx_mode(struct net_device *dev)
 
 
 /* rx/tx queue initialisation ***********************************************/
-/*
- * ether_init_rx_desc_ring - Curve a Rx chain desc list and buffer in memory.
- *
- * DESCRIPTION:
- *	This function prepares a Rx chained list of descriptors and packet
- *	buffers in a form of a ring. The routine must be called after port
- *	initialization routine and before port start routine.
- *	The Ethernet SDMA engine uses CPU bus addresses to access the various
- *	devices in the system (i.e. DRAM). This function uses the ethernet
- *	struct 'virtual to physical' routine (set by the user) to set the ring
- *	with physical addresses.
- *
- * INPUT:
- *	struct mv643xx_eth_private *mep	Ethernet Port Control srtuct.
- *
- * OUTPUT:
- *	The routine updates the Ethernet port control struct with information
- *	regarding the Rx descriptors and buffers.
- *
- * RETURN:
- *	None.
- */
 static void ether_init_rx_desc_ring(struct mv643xx_eth_private *mep)
 {
 	volatile struct rx_desc *p_rx_desc;
@@ -1675,28 +1418,6 @@ static void mv643xx_eth_free_rx_rings(struct net_device *dev)
 				mep->p_rx_desc_area, mep->rx_desc_dma);
 }
 
-/*
- * ether_init_tx_desc_ring - Curve a Tx chain desc list and buffer in memory.
- *
- * DESCRIPTION:
- *	This function prepares a Tx chained list of descriptors and packet
- *	buffers in a form of a ring. The routine must be called after port
- *	initialization routine and before port start routine.
- *	The Ethernet SDMA engine uses CPU bus addresses to access the various
- *	devices in the system (i.e. DRAM). This function uses the ethernet
- *	struct 'virtual to physical' routine (set by the user) to set the ring
- *	with physical addresses.
- *
- * INPUT:
- *	struct mv643xx_eth_private *mep	Ethernet Port Control srtuct.
- *
- * OUTPUT:
- *	The routine updates the Ethernet port control struct with information
- *	regarding the Tx descriptors and buffers.
- *
- * RETURN:
- *	None.
- */
 static void ether_init_tx_desc_ring(struct mv643xx_eth_private *mep)
 {
 	int tx_desc_num = mep->tx_ring_size;
@@ -1716,11 +1437,6 @@ static void ether_init_tx_desc_ring(struct mv643xx_eth_private *mep)
 	mep->tx_desc_area_size = tx_desc_num * sizeof(struct tx_desc);
 }
 
-/**
- * mv643xx_eth_free_tx_descs - Free the tx desc data for completed descriptors
- *
- * If force is non-zero, frees uncompleted descriptors as well
- */
 static int mv643xx_eth_free_tx_descs(struct net_device *dev, int force)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
@@ -1819,7 +1535,6 @@ static void mv643xx_eth_free_tx_rings(struct net_device *dev)
 /* netdev ops and related ***************************************************/
 static void port_reset(struct mv643xx_eth_private *mep);
 
-/* Set the mv643xx port configuration register for the speed/duplex mode. */
 static void mv643xx_eth_update_pscr(struct net_device *dev,
 				    struct ethtool_cmd *ecmd)
 {
@@ -1865,17 +1580,6 @@ static void mv643xx_eth_update_pscr(struct net_device *dev,
 	}
 }
 
-/*
- * mv643xx_eth_int_handler
- *
- * Main interrupt handler for the gigbit ethernet ports
- *
- * Input :	irq	- irq number (not used)
- *		dev_id	- a pointer to the required interface's data structure
- *		regs	- not used
- * Output :	N/A
- */
-
 static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
@@ -1938,22 +1642,6 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-/*
- * phy_reset - Reset Ethernet port PHY.
- *
- * DESCRIPTION:
- *	This routine utilizes the SMI interface to reset the ethernet port PHY.
- *
- * INPUT:
- *	struct mv643xx_eth_private *mep	Ethernet Port.
- *
- * OUTPUT:
- *	The PHY is reset.
- *
- * RETURN:
- *	None.
- *
- */
 static void phy_reset(struct mv643xx_eth_private *mep)
 {
 	unsigned int phy_reg_data;
@@ -1970,33 +1658,6 @@ static void phy_reset(struct mv643xx_eth_private *mep)
 	} while (phy_reg_data & 0x8000);
 }
 
-/*
- * port_start - Start the Ethernet port activity.
- *
- * DESCRIPTION:
- *	This routine prepares the Ethernet port for Rx and Tx activity:
- *	 1. Initialize Tx and Rx Current Descriptor Pointer for each queue that
- *	    has been initialized a descriptor's ring (using
- *	    ether_init_tx_desc_ring for Tx and ether_init_rx_desc_ring for Rx)
- *	 2. Initialize and enable the Ethernet configuration port by writing to
- *	    the port's configuration and command registers.
- *	 3. Initialize and enable the SDMA by writing to the SDMA's
- *	    configuration and command registers.  After completing these steps,
- *	    the ethernet port SDMA can starts to perform Rx and Tx activities.
- *
- *	Note: Each Rx and Tx queue descriptor's list must be initialized prior
- *	to calling this function (use ether_init_tx_desc_ring for Tx queues
- *	and ether_init_rx_desc_ring for Rx queues).
- *
- * INPUT:
- *	dev - a pointer to the required interface
- *
- * OUTPUT:
- *	Ethernet port is ready to receive and transmit.
- *
- * RETURN:
- *	None.
- */
 static void port_start(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
@@ -2061,29 +1722,6 @@ static void port_start(struct net_device *dev)
 }
 
 #ifdef MV643XX_ETH_COAL
-
-/*
- * set_rx_coal - Sets coalescing interrupt mechanism on RX path
- *
- * DESCRIPTION:
- *	This routine sets the RX coalescing interrupt mechanism parameter.
- *	This parameter is a timeout counter, that counts in 64 t_clk
- *	chunks ; that when timeout event occurs a maskable interrupt
- *	occurs.
- *	The parameter is calculated using the tClk of the MV-643xx chip
- *	, and the required delay of the interrupt in usec.
- *
- * INPUT:
- *	struct mv643xx_eth_private *mep	Ethernet port
- *	unsigned int delay		Delay in usec
- *
- * OUTPUT:
- *	Interrupt coalescing mechanism value is set in MV-643xx chip.
- *
- * RETURN:
- *	The interrupt coalescing value set in the gigE port.
- *
- */
 static unsigned int set_rx_coal(struct mv643xx_eth_private *mep,
 					unsigned int delay)
 {
@@ -2100,28 +1738,6 @@ static unsigned int set_rx_coal(struct mv643xx_eth_private *mep,
 }
 #endif
 
-/*
- * set_tx_coal - Sets coalescing interrupt mechanism on TX path
- *
- * DESCRIPTION:
- *	This routine sets the TX coalescing interrupt mechanism parameter.
- *	This parameter is a timeout counter, that counts in 64 t_clk
- *	chunks ; that when timeout event occurs a maskable interrupt
- *	occurs.
- *	The parameter is calculated using the t_cLK frequency of the
- *	MV-643xx chip and the required delay in the interrupt in uSec
- *
- * INPUT:
- *	struct mv643xx_eth_private *mep	Ethernet port
- *	unsigned int delay		Delay in uSeconds
- *
- * OUTPUT:
- *	Interrupt coalescing mechanism value is set in MV-643xx chip.
- *
- * RETURN:
- *	The interrupt coalescing value set in the gigE port.
- *
- */
 static unsigned int set_tx_coal(struct mv643xx_eth_private *mep,
 					unsigned int delay)
 {
@@ -2133,30 +1749,6 @@ static unsigned int set_tx_coal(struct mv643xx_eth_private *mep,
 	return coal;
 }
 
-/*
- * port_init - Initialize the Ethernet port driver
- *
- * DESCRIPTION:
- *	This function prepares the ethernet port to start its activity:
- *	1) Completes the ethernet port driver struct initialization toward port
- *		start routine.
- *	2) Resets the device to a quiescent state in case of warm reboot.
- *	3) Enable SDMA access to all four DRAM banks as well as internal SRAM.
- *	4) Clean MAC tables. The reset status of those tables is unknown.
- *	5) Set PHY address.
- *	Note: Call this routine prior to port_start routine and after
- *	setting user values in the user fields of Ethernet port control
- *	struct.
- *
- * INPUT:
- *	struct mv643xx_eth_private *mep	Ethernet port control struct
- *
- * OUTPUT:
- *	See description.
- *
- * RETURN:
- *	None.
- */
 static void port_init(struct mv643xx_eth_private *mep)
 {
 	mep->rx_resource_err = 0;
@@ -2166,19 +1758,6 @@ static void port_init(struct mv643xx_eth_private *mep)
 	init_mac_tables(mep);
 }
 
-/*
- * mv643xx_eth_open
- *
- * This function is called when openning the network device. The function
- * should initialize all the hardware, initialize cyclic Rx/Tx
- * descriptors chain and buffers and allocate an IRQ to the network
- * device.
- *
- * Input :	a pointer to the network device structure
- *
- * Output :	zero of success , nonzero if fails.
- */
-
 static int mv643xx_eth_open(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
@@ -2311,24 +1890,6 @@ out_free_irq:
 	return err;
 }
 
-/*
- * port_reset - Reset Ethernet port
- *
- * DESCRIPTION:
- * 	This routine resets the chip by aborting any SDMA engine activity and
- *	clearing the MIB counters. The Receiver and the Transmit unit are in
- *	idle state after this command is performed and the port is disabled.
- *
- * INPUT:
- *	struct mv643xx_eth_private *mep	Ethernet Port.
- *
- * OUTPUT:
- *	Channel activity is halted.
- *
- * RETURN:
- *	None.
- *
- */
 static void port_reset(struct mv643xx_eth_private *mep)
 {
 	unsigned int port_num = mep->port_num;
@@ -2348,16 +1909,6 @@ static void port_reset(struct mv643xx_eth_private *mep)
 	wrl(mep, PORT_SERIAL_CONTROL(port_num), reg_data);
 }
 
-/*
- * mv643xx_eth_stop
- *
- * This function is used when closing the network device.
- * It updates the hardware,
- * release all memory that holds buffers and descriptors and release the IRQ.
- * Input :	a pointer to the device structure
- * Output :	zero if success , nonzero if fails
- */
-
 static int mv643xx_eth_stop(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
@@ -2391,13 +1942,6 @@ static int mv643xx_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr, int c
 	return generic_mii_ioctl(&mep->mii, if_mii(ifr), cmd, NULL);
 }
 
-/*
- * Changes MTU (maximum transfer unit) of the gigabit ethenret port
- *
- * Input :	pointer to ethernet interface network device structure
- *		new mtu size
- * Output :	0 upon success, -EINVAL upon failure
- */
 static int mv643xx_eth_change_mtu(struct net_device *dev, int new_mtu)
 {
 	if ((new_mtu > 9500) || (new_mtu < 64))
@@ -2422,11 +1966,6 @@ static int mv643xx_eth_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
-/*
- * mv643xx_eth_tx_timeout_task
- *
- * Actual routine to reset the adapter when a timeout on Tx has occurred
- */
 static void mv643xx_eth_tx_timeout_task(struct work_struct *ugly)
 {
 	struct mv643xx_eth_private *mep = container_of(ugly, struct mv643xx_eth_private,
@@ -2445,14 +1984,6 @@ static void mv643xx_eth_tx_timeout_task(struct work_struct *ugly)
 		netif_wake_queue(dev);
 }
 
-/*
- * mv643xx_eth_tx_timeout
- *
- * Called upon a timeout on transmitting a packet
- *
- * Input :	pointer to ethernet interface network device structure.
- * Output :	N/A
- */
 static void mv643xx_eth_tx_timeout(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
@@ -2479,9 +2010,6 @@ static void mv643xx_eth_netpoll(struct net_device *netdev)
 }
 #endif
 
-/*
- * Wrappers for MII support library.
- */
 static int mv643xx_eth_mdio_read(struct net_device *dev, int phy_id, int location)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
@@ -2598,23 +2126,6 @@ static struct platform_driver mv643xx_eth_shared_driver = {
 	},
 };
 
-/*
- * phy_addr_set - Set the ethernet port PHY address.
- *
- * DESCRIPTION:
- *	This routine sets the given ethernet port PHY address.
- *
- * INPUT:
- *	struct mv643xx_eth_private *mep	Ethernet Port.
- *	int		phy_addr	PHY address.
- *
- * OUTPUT:
- *	None.
- *
- * RETURN:
- *	None.
- *
- */
 static void phy_addr_set(struct mv643xx_eth_private *mep, int phy_addr)
 {
 	u32 reg_data;
@@ -2626,22 +2137,6 @@ static void phy_addr_set(struct mv643xx_eth_private *mep, int phy_addr)
 	wrl(mep, PHY_ADDR, reg_data);
 }
 
-/*
- * phy_addr_get - Get the ethernet port PHY address.
- *
- * DESCRIPTION:
- *	This routine returns the given ethernet port PHY address.
- *
- * INPUT:
- *	struct mv643xx_eth_private *mep	Ethernet Port.
- *
- * OUTPUT:
- *	None.
- *
- * RETURN:
- *	PHY address.
- *
- */
 static int phy_addr_get(struct mv643xx_eth_private *mep)
 {
 	unsigned int reg_data;
@@ -2651,24 +2146,6 @@ static int phy_addr_get(struct mv643xx_eth_private *mep)
 	return ((reg_data >> (5 * mep->port_num)) & 0x1f);
 }
 
-/*
- * phy_detect - Detect whether a phy is present
- *
- * DESCRIPTION:
- *	This function tests whether there is a PHY present on
- *	the specified port.
- *
- * INPUT:
- *	struct mv643xx_eth_private *mep	Ethernet Port.
- *
- * OUTPUT:
- *	None
- *
- * RETURN:
- *	0 on success
- *	-ENODEV on failure
- *
- */
 static int phy_detect(struct mv643xx_eth_private *mep)
 {
 	unsigned int phy_reg_data0;
@@ -2717,17 +2194,6 @@ static void mv643xx_init_ethtool_cmd(struct net_device *dev, int phy_address,
 	}
 }
 
-/*/
- * mv643xx_eth_probe
- *
- * First function called after registering the network device.
- * It's purpose is to initialize the device as an ethernet device,
- * fill the ethernet device structure with pointers * to functions,
- * and set the MAC address of the interface
- *
- * Input :	struct device *
- * Output :	-ENOMEM if failed , 0 if success
- */
 static int mv643xx_eth_probe(struct platform_device *pdev)
 {
 	struct mv643xx_eth_platform_data *pd;
@@ -2940,15 +2406,6 @@ static struct platform_driver mv643xx_eth_driver = {
 	},
 };
 
-/*
- * mv643xx_eth_init_module
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
@@ -2962,15 +2419,6 @@ static int __init mv643xx_eth_init_module(void)
 	return rc;
 }
 
-/*
- * mv643xx_eth_cleanup_module
- *
- * Registers the network drivers into the Linux kernel
- *
- * Input :	N/A
- *
- * Output :	N/A
- */
 static void __exit mv643xx_eth_cleanup_module(void)
 {
 	platform_driver_unregister(&mv643xx_eth_driver);
-- 
1.5.3.4

