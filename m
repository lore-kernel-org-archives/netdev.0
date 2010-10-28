From: alex@wigen.net
Subject: [PATCH] via-velocity: Codestyle fixes
Date: Thu, 28 Oct 2010 13:48:04 +1000
Message-ID: <1288237684-30783-1-git-send-email-alex@wigen.net>
Mime-Version: 1.0
Cc: linux-kernel@vger.kernel.org, alex@wigen.net
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Wigen <alex@wigen.net>

checkpatch.pl --terse --file drivers/net/via-velocity.c
Before: total: 13 errors, 106 warnings, 3537 lines checked
After: total: 0 errors, 96 warnings, 3536 lines checked

Signed-off-by: Alexander Wigen <alex@wigen.net>
---
 drivers/net/via-velocity.c |  187 ++++++++++++++++++++++----------------------
 1 files changed, 93 insertions(+), 94 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index cab96ad..05c2e1e 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -84,7 +84,7 @@ static int velocity_nics;
 static int msglevel = MSG_LEVEL_INFO;
 
 /**
- *	mac_get_cam_mask	-	Read a CAM mask
+ *	mac_get_cam_mask - Read a CAM mask
  *	@regs: register block for this velocity
  *	@mask: buffer to store mask
  *
@@ -113,7 +113,7 @@ static void mac_get_cam_mask(struct mac_regs __iomem *regs, u8 *mask)
 
 
 /**
- *	mac_set_cam_mask	-	Set a CAM mask
+ *	mac_set_cam_mask - Set a CAM mask
  *	@regs: register block for this velocity
  *	@mask: CAM mask to load
  *
@@ -156,7 +156,7 @@ static void mac_set_vlan_cam_mask(struct mac_regs __iomem *regs, u8 *mask)
 }
 
 /**
- *	mac_set_cam	-	set CAM data
+ *	mac_set_cam - set CAM data
  *	@regs: register block of this velocity
  *	@idx: Cam index
  *	@addr: 2 or 6 bytes of CAM data
@@ -211,11 +211,11 @@ static void mac_set_vlan_cam(struct mac_regs __iomem *regs, int idx,
 
 
 /**
- *	mac_wol_reset	-	reset WOL after exiting low power
+ *	mac_wol_reset - reset WOL after exiting low power
  *	@regs: register block of this velocity
  *
  *	Called after we drop out of wake on lan mode in order to
- *	reset the Wake on lan features. This function doesn't restore
+ *	reset the Wake On Lan features. This function doesn't restore
  *	the rest of the logic from the result of sleep/wakeup
  */
 static void mac_wol_reset(struct mac_regs __iomem *regs)
@@ -342,7 +342,7 @@ VELOCITY_PARAM(ValPktLen, "Receiving or Drop invalid 802.3 frame");
    1: Wake up if link status is on/off.
    2: Wake up if recevied an arp packet.
    4: Wake up if recevied any unicast packet.
-   Those value can be sumed up to support more than one option.
+   Those value can be summed up to support more than one option.
 */
 VELOCITY_PARAM(wol_opts, "Wake On Lan options");
 
@@ -370,7 +370,7 @@ static DEFINE_PCI_DEVICE_TABLE(velocity_id_table) = {
 MODULE_DEVICE_TABLE(pci, velocity_id_table);
 
 /**
- *	get_chip_name	- 	identifier to name
+ *	get_chip_name - identifier to name
  *	@id: chip identifier
  *
  *	Given a chip identifier return a suitable description. Returns
@@ -386,7 +386,7 @@ static const char __devinit *get_chip_name(enum chip_type chip_id)
 }
 
 /**
- *	velocity_remove1	-	device unplug
+ *	velocity_remove1 - device unplug
  *	@pdev: PCI device being removed
  *
  *	Device unload callback. Called on an unplug or on module
@@ -409,7 +409,7 @@ static void __devexit velocity_remove1(struct pci_dev *pdev)
 }
 
 /**
- *	velocity_set_int_opt	-	parser for integer options
+ *	velocity_set_int_opt - parser for integer options
  *	@opt: pointer to option value
  *	@val: value the user requested (or -1 for default)
  *	@min: lowest value allowed
@@ -438,7 +438,7 @@ static void __devinit velocity_set_int_opt(int *opt, int val, int min, int max,
 }
 
 /**
- *	velocity_set_bool_opt	-	parser for boolean options
+ *	velocity_set_bool_opt - parser for boolean options
  *	@opt: pointer to option value
  *	@val: value the user requested (or -1 for default)
  *	@def: default value (yes/no)
@@ -467,7 +467,7 @@ static void __devinit velocity_set_bool_opt(u32 *opt, int val, int def, u32 flag
 }
 
 /**
- *	velocity_get_options	-	set options on device
+ *	velocity_get_options - set options on device
  *	@opts: option structure for the device
  *	@index: index of option to use in module options array
  *	@devname: device name
@@ -492,7 +492,7 @@ static void __devinit velocity_get_options(struct velocity_opt *opts, int index,
 }
 
 /**
- *	velocity_init_cam_filter	-	initialise CAM
+ *	velocity_init_cam_filter - initialize CAM
  *	@vptr: velocity to program
  *
  *	Initialize the content addressable memory used for filters. Load
@@ -507,8 +507,8 @@ static void velocity_init_cam_filter(struct velocity_info *vptr)
 	WORD_REG_BITS_ON(MCFG_VIDFR, &regs->MCFG);
 
 	/* Disable all CAMs */
-	memset(vptr->vCAMmask, 0, sizeof(u8) * 8);
-	memset(vptr->mCAMmask, 0, sizeof(u8) * 8);
+	memset(vptr->vCAMmask, 0, sizeof(u8) *8);
+	memset(vptr->mCAMmask, 0, sizeof(u8) *8);
 	mac_set_vlan_cam_mask(regs, vptr->vCAMmask);
 	mac_set_cam_mask(regs, vptr->mCAMmask);
 
@@ -564,7 +564,7 @@ static void velocity_init_rx_ring_indexes(struct velocity_info *vptr)
 }
 
 /**
- *	velocity_rx_reset	-	handle a receive reset
+ *	velocity_rx_reset - handle a receive reset
  *	@vptr: velocity we are resetting
  *
  *	Reset the ownership and status for the receive ring side.
@@ -591,7 +591,7 @@ static void velocity_rx_reset(struct velocity_info *vptr)
 }
 
 /**
- *	velocity_get_opt_media_mode	-	get media selection
+ *	velocity_get_opt_media_mode - get media selection
  *	@vptr: velocity adapter
  *
  *	Get the media mode stored in EEPROM or module options and load
@@ -627,7 +627,7 @@ static u32 velocity_get_opt_media_mode(struct velocity_info *vptr)
 }
 
 /**
- *	safe_disable_mii_autopoll	-	autopoll off
+ *	safe_disable_mii_autopoll - autopoll off
  *	@regs: velocity registers
  *
  *	Turn off the autopoll and wait for it to disable on the chip
@@ -646,7 +646,7 @@ static void safe_disable_mii_autopoll(struct mac_regs __iomem *regs)
 }
 
 /**
- *	enable_mii_autopoll	-	turn on autopolling
+ *	enable_mii_autopoll - turn on autopolling
  *	@regs: velocity registers
  *
  *	Enable the MII link status autopoll feature on the Velocity
@@ -676,7 +676,7 @@ static void enable_mii_autopoll(struct mac_regs __iomem *regs)
 }
 
 /**
- *	velocity_mii_read	-	read MII data
+ *	velocity_mii_read - read MII data
  *	@regs: velocity registers
  *	@index: MII register index
  *	@data: buffer for received data
@@ -712,7 +712,7 @@ static int velocity_mii_read(struct mac_regs __iomem *regs, u8 index, u16 *data)
 
 
 /**
- *	mii_check_media_mode	-	check media state
+ *	mii_check_media_mode - check media state
  *	@regs: velocity registers
  *
  *	Check the current MII status and determine the link status
@@ -755,7 +755,7 @@ static u32 mii_check_media_mode(struct mac_regs __iomem *regs)
 }
 
 /**
- *	velocity_mii_write	-	write MII data
+ *	velocity_mii_write - write MII data
  *	@regs: velocity registers
  *	@index: MII register index
  *	@data: 16bit data for the MII register
@@ -794,7 +794,7 @@ static int velocity_mii_write(struct mac_regs __iomem *regs, u8 mii_addr, u16 da
 }
 
 /**
- *	set_mii_flow_control	-	flow control setup
+ *	set_mii_flow_control - flow control setup
  *	@vptr: velocity interface
  *
  *	Set up the flow control on this interface according to
@@ -829,10 +829,10 @@ static void set_mii_flow_control(struct velocity_info *vptr)
 }
 
 /**
- *	mii_set_auto_on		-	autonegotiate on
+ *	mii_set_auto_on - autonegotiate on
  *	@vptr: velocity
  *
- *	Enable autonegotation on this interface
+ *	Enable autonegotiation on this interface
  */
 static void mii_set_auto_on(struct velocity_info *vptr)
 {
@@ -879,7 +879,7 @@ static u32 check_connection_type(struct mac_regs __iomem *regs)
 
 
 /**
- *	velocity_set_media_mode		-	set media mode
+ *	velocity_set_media_mode - set media mode
  *	@mii_status: old MII link state
  *
  *	Check the media link state and configure the flow control
@@ -999,7 +999,7 @@ static int velocity_set_media_mode(struct velocity_info *vptr, u32 mii_status)
 }
 
 /**
- *	velocity_print_link_status	-	link status reporting
+ *	velocity_print_link_status - link status reporting
  *	@vptr: velocity to report on
  *
  *	Turn the link status of the velocity card into a kernel log
@@ -1050,7 +1050,7 @@ static void velocity_print_link_status(struct velocity_info *vptr)
 }
 
 /**
- *	enable_flow_control_ability	-	flow control
+ *	enable_flow_control_ability - flow control
  *	@vptr: veloity to configure
  *
  *	Set up flow control according to the flow control options
@@ -1102,7 +1102,7 @@ static void enable_flow_control_ability(struct velocity_info *vptr)
 }
 
 /**
- *	velocity_soft_reset	-	soft reset
+ *	velocity_soft_reset - soft reset
  *	@vptr: velocity to reset
  *
  *	Kick off a soft reset of the velocity adapter and then poll
@@ -1131,7 +1131,7 @@ static int velocity_soft_reset(struct velocity_info *vptr)
 }
 
 /**
- *	velocity_set_multi	-	filter list change callback
+ *	velocity_set_multi - filter list change callback
  *	@dev: network device
  *
  *	Called by the network layer when the filter lists need to change
@@ -1181,7 +1181,7 @@ static void velocity_set_multi(struct net_device *dev)
  */
 
 /**
- *	mii_init	-	set up MII
+ *	mii_init - set up MII
  *	@vptr: velocity adapter
  *	@mii_status:  links tatus
  *
@@ -1250,7 +1250,7 @@ static void mii_init(struct velocity_info *vptr, u32 mii_status)
 }
 
 /**
- * setup_queue_timers	-	Setup interrupt timers
+ * setup_queue_timers - Setup interrupt timers
  *
  * Setup interrupt frequency during suppression (timeout if the frame
  * count isn't filled).
@@ -1273,7 +1273,7 @@ static void setup_queue_timers(struct velocity_info *vptr)
 	}
 }
 /**
- * setup_adaptive_interrupts  -  Setup interrupt suppression
+ * setup_adaptive_interrupts - Setup interrupt suppression
  *
  * @vptr velocity adapter
  *
@@ -1311,11 +1311,11 @@ static void setup_adaptive_interrupts(struct velocity_info *vptr)
 }
 
 /**
- *	velocity_init_registers	-	initialise MAC registers
+ *	velocity_init_registers - initialise MAC registers
  *	@vptr: velocity to init
  *	@type: type of initialisation (hot or cold)
  *
- *	Initialise the MAC on a reset or on first set up on the
+ *	Initialize the MAC on a reset or on first set up on the
  *	hardware.
  */
 static void velocity_init_registers(struct velocity_info *vptr,
@@ -1459,7 +1459,7 @@ static void velocity_give_many_rx_descs(struct velocity_info *vptr)
 }
 
 /**
- *	velocity_init_dma_rings	-	set up DMA rings
+ *	velocity_init_dma_rings - set up DMA rings
  *	@vptr: Velocity to set up
  *
  *	Allocate PCI mapped DMA rings for the receive and transmit layer
@@ -1511,7 +1511,7 @@ static void velocity_set_rxbufsize(struct velocity_info *vptr, int mtu)
 }
 
 /**
- *	velocity_alloc_rx_buf	-	allocate aligned receive buffer
+ *	velocity_alloc_rx_buf - allocate aligned receive buffer
  *	@vptr: velocity
  *	@idx: ring index
  *
@@ -1542,7 +1542,7 @@ static int velocity_alloc_rx_buf(struct velocity_info *vptr, int idx)
 	 *	Fill in the descriptor to match
 	 */
 
-	*((u32 *) & (rd->rdesc0)) = 0;
+	*((u32 *) &(rd->rdesc0)) = 0;
 	rd->size = cpu_to_le16(vptr->rx.buf_sz) | RX_INTEN;
 	rd->pa_low = cpu_to_le32(rd_info->skb_dma);
 	rd->pa_high = 0;
@@ -1578,7 +1578,7 @@ static int velocity_rx_refill(struct velocity_info *vptr)
 }
 
 /**
- *	velocity_free_rd_ring	-	free receive ring
+ *	velocity_free_rd_ring - free receive ring
  *	@vptr: velocity to clean up
  *
  *	Free the receive buffers for each ring slot and any
@@ -1614,7 +1614,7 @@ static void velocity_free_rd_ring(struct velocity_info *vptr)
 
 
 /**
- *	velocity_init_rd_ring	-	set up receive ring
+ *	velocity_init_rd_ring - set up receive ring
  *	@vptr: velocity to configure
  *
  *	Allocate and set up the receive buffers for each ring slot and
@@ -1644,7 +1644,7 @@ out:
 }
 
 /**
- *	velocity_init_td_ring	-	set up transmit ring
+ *	velocity_init_td_ring - set up transmit ring
  *	@vptr:	velocity
  *
  *	Set up the transmit ring and chain the ring pointers together.
@@ -1673,7 +1673,7 @@ static int velocity_init_td_ring(struct velocity_info *vptr)
 }
 
 /**
- *	velocity_free_dma_rings	-	free PCI ring pointers
+ *	velocity_free_dma_rings - free PCI ring pointers
  *	@vptr: Velocity to free from
  *
  *	Clean up the PCI ring buffers allocated to this velocity.
@@ -1681,7 +1681,7 @@ static int velocity_init_td_ring(struct velocity_info *vptr)
 static void velocity_free_dma_rings(struct velocity_info *vptr)
 {
 	const int size = vptr->options.numrx * sizeof(struct rx_desc) +
-		vptr->options.numtx * sizeof(struct tx_desc) * vptr->tx.numq;
+		vptr->options.numtx * sizeof(struct tx_desc) *vptr->tx.numq;
 
 	pci_free_consistent(vptr->pdev, size, vptr->rx.ring, vptr->rx.pool_dma);
 }
@@ -1715,7 +1715,7 @@ err_free_dma_rings_0:
 }
 
 /**
- *	velocity_free_tx_buf	-	free transmit buffer
+ *	velocity_free_tx_buf - free transmit buffer
  *	@vptr: velocity
  *	@tdinfo: buffer
  *
@@ -1776,7 +1776,7 @@ static void velocity_free_td_ring_entry(struct velocity_info *vptr,
 }
 
 /**
- *	velocity_free_td_ring	-	free td ring
+ *	velocity_free_td_ring - free td ring
  *	@vptr: velocity
  *
  *	Free up the transmit ring for this particular velocity adapter.
@@ -1806,7 +1806,7 @@ static void velocity_free_rings(struct velocity_info *vptr)
 }
 
 /**
- *	velocity_error	-	handle error from controller
+ *	velocity_error - handle error from controller
  *	@vptr: velocity
  *	@status: card status
  *
@@ -1895,7 +1895,7 @@ static void velocity_error(struct velocity_info *vptr, int status)
 }
 
 /**
- *	tx_srv		-	transmit interrupt service
+ *	tx_srv - transmit interrupt service
  *	@vptr; Velocity
  *
  *	Scan the queues looking for transmitted packets that
@@ -1963,7 +1963,7 @@ static int velocity_tx_srv(struct velocity_info *vptr)
 }
 
 /**
- *	velocity_rx_csum	-	checksum process
+ *	velocity_rx_csum - checksum process
  *	@rd: receive packet descriptor
  *	@skb: network layer packet buffer
  *
@@ -1987,14 +1987,14 @@ static inline void velocity_rx_csum(struct rx_desc *rd, struct sk_buff *skb)
 }
 
 /**
- *	velocity_rx_copy	-	in place Rx copy for small packets
+ *	velocity_rx_copy - in place Rx copy for small packets
  *	@rx_skb: network layer packet buffer candidate
  *	@pkt_size: received data size
  *	@rd: receive packet descriptor
  *	@dev: network device
  *
  *	Replace the current skb that is scheduled for Rx processing by a
- *	shorter, immediatly allocated skb, if the received packet is small
+ *	shorter, immediately allocated skb, if the received packet is small
  *	enough. This function returns a negative value if the received
  *	packet is too big or if memory is exhausted.
  */
@@ -2018,7 +2018,7 @@ static int velocity_rx_copy(struct sk_buff **rx_skb, int pkt_size,
 }
 
 /**
- *	velocity_iph_realign	-	IP header alignment
+ *	velocity_iph_realign - IP header alignment
  *	@vptr: velocity we are handling
  *	@skb: network layer packet buffer
  *	@pkt_size: received data size
@@ -2037,7 +2037,7 @@ static inline void velocity_iph_realign(struct velocity_info *vptr,
 
 
 /**
- *	velocity_receive_frame	-	received packet processor
+ *	velocity_receive_frame - received packet processor
  *	@vptr: velocity we are handling
  *	@idx: ring index
  *
@@ -2107,7 +2107,7 @@ static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 
 
 /**
- *	velocity_rx_srv		-	service RX interrupt
+ *	velocity_rx_srv - service RX interrupt
  *	@vptr: velocity
  *
  *	Walk the receive ring of the velocity adapter and remove
@@ -2191,7 +2191,7 @@ static int velocity_poll(struct napi_struct *napi, int budget)
 }
 
 /**
- *	velocity_intr		-	interrupt callback
+ *	velocity_intr - interrupt callback
  *	@irq: interrupt number
  *	@dev_instance: interrupting device
  *
@@ -2232,14 +2232,14 @@ static irqreturn_t velocity_intr(int irq, void *dev_instance)
 }
 
 /**
- *	velocity_open		-	interface activation callback
+ *	velocity_open - interface activation callback
  *	@dev: network layer device to open
  *
  *	Called when the network layer brings the interface up. Returns
  *	a negative posix error code on failure, or zero on success.
  *
  *	All the ring allocation and set up is done on open for this
- *	adapter to minimise memory usage when inactive
+ *	adapter to minimize memory usage when inactive
  */
 static int velocity_open(struct net_device *dev)
 {
@@ -2275,7 +2275,7 @@ out:
 }
 
 /**
- *	velocity_shutdown	-	shut down the chip
+ *	velocity_shutdown - shut down the chip
  *	@vptr: velocity to deactivate
  *
  *	Shuts down the internal operations of the velocity and
@@ -2293,7 +2293,7 @@ static void velocity_shutdown(struct velocity_info *vptr)
 }
 
 /**
- *	velocity_change_mtu	-	MTU change callback
+ *	velocity_change_mtu - MTU change callback
  *	@dev: network device
  *	@new_mtu: desired MTU
  *
@@ -2374,7 +2374,7 @@ out_0:
 }
 
 /**
- *	velocity_mii_ioctl		-	MII ioctl handler
+ *	velocity_mii_ioctl - MII ioctl handler
  *	@dev: network device
  *	@ifr: the ifreq block for the ioctl
  *	@cmd: the command
@@ -2415,7 +2415,7 @@ static int velocity_mii_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd
 
 
 /**
- *	velocity_ioctl		-	ioctl entry point
+ *	velocity_ioctl - ioctl entry point
  *	@dev: network device
  *	@rq: interface request ioctl
  *	@cmd: command code
@@ -2452,7 +2452,7 @@ static int velocity_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 }
 
 /**
- *	velocity_get_status	-	statistics callback
+ *	velocity_get_status - statistics callback
  *	@dev: network device
  *
  *	Callback from the network layer to allow driver statistics
@@ -2477,24 +2477,24 @@ static struct net_device_stats *velocity_get_stats(struct net_device *dev)
 	dev->stats.rx_errors = vptr->mib_counter[HW_MIB_ifRxErrorPkts];
 	dev->stats.rx_length_errors = vptr->mib_counter[HW_MIB_ifInRangeLengthErrors];
 
-//  unsigned long   rx_dropped;     /* no space in linux buffers    */
+/*  unsigned long   rx_dropped;     /* no space in linux buffers    */
 	dev->stats.collisions = vptr->mib_counter[HW_MIB_ifTxEtherCollisions];
 	/* detailed rx_errors: */
-//  unsigned long   rx_length_errors;
-//  unsigned long   rx_over_errors;     /* receiver ring buff overflow  */
+/*  unsigned long   rx_length_errors;
+/*  unsigned long   rx_over_errors;     /* receiver ring buff overflow  */
 	dev->stats.rx_crc_errors = vptr->mib_counter[HW_MIB_ifRxPktCRCE];
-//  unsigned long   rx_frame_errors;    /* recv'd frame alignment error */
-//  unsigned long   rx_fifo_errors;     /* recv'r fifo overrun      */
-//  unsigned long   rx_missed_errors;   /* receiver missed packet   */
+/*  unsigned long   rx_frame_errors;    /* recv'd frame alignment error */
+/*  unsigned long   rx_fifo_errors;     /* recv'r fifo overrun      */
+/*  unsigned long   rx_missed_errors;   /* receiver missed packet   */
 
 	/* detailed tx_errors */
-//  unsigned long   tx_fifo_errors;
+/*  unsigned long   tx_fifo_errors;
 
 	return &dev->stats;
 }
 
 /**
- *	velocity_close		-	close adapter callback
+ *	velocity_close - close adapter callback
  *	@dev: network device
  *
  *	Callback from the network layer when the velocity is being
@@ -2523,11 +2523,11 @@ static int velocity_close(struct net_device *dev)
 }
 
 /**
- *	velocity_xmit		-	transmit packet callback
+ *	velocity_xmit - transmit packet callback
  *	@skb: buffer to transmit
  *	@dev: network device
  *
- *	Called by the networ layer to request a packet is queued to
+ *	Called by the network layer to request a packet is queued to
  *	the velocity. Returns zero on success.
  */
 static netdev_tx_t velocity_xmit(struct sk_buff *skb,
@@ -2636,7 +2636,7 @@ static const struct net_device_ops velocity_netdev_ops = {
 	.ndo_start_xmit		= velocity_xmit,
 	.ndo_get_stats		= velocity_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_set_multicast_list	= velocity_set_multi,
 	.ndo_change_mtu		= velocity_change_mtu,
 	.ndo_do_ioctl		= velocity_ioctl,
@@ -2646,7 +2646,7 @@ static const struct net_device_ops velocity_netdev_ops = {
 };
 
 /**
- *	velocity_init_info	-	init private data
+ *	velocity_init_info - init private data
  *	@pdev: PCI device
  *	@vptr: Velocity info
  *	@info: Board type
@@ -2668,7 +2668,7 @@ static void __devinit velocity_init_info(struct pci_dev *pdev,
 }
 
 /**
- *	velocity_get_pci_info	-	retrieve PCI info for device
+ *	velocity_get_pci_info - retrieve PCI info for device
  *	@vptr: velocity device
  *	@pdev: PCI device it matches
  *
@@ -2706,7 +2706,7 @@ static int __devinit velocity_get_pci_info(struct velocity_info *vptr, struct pc
 }
 
 /**
- *	velocity_print_info	-	per driver data
+ *	velocity_print_info - per driver data
  *	@vptr: velocity
  *
  *	Print per driver data as the kernel driver finds Velocity
@@ -2730,7 +2730,7 @@ static u32 velocity_get_link(struct net_device *dev)
 
 
 /**
- *	velocity_found1		-	set up discovered velocity card
+ *	velocity_found1 - set up discovered velocity card
  *	@pdev: PCI device
  *	@ent: PCI device table entry that matched
  *
@@ -2877,7 +2877,7 @@ err_free_dev:
 
 #ifdef CONFIG_PM
 /**
- *	wol_calc_crc		-	WOL CRC
+ *	wol_calc_crc - WOL CRC
  *	@pattern: data pattern
  *	@mask_pattern: mask
  *
@@ -2912,7 +2912,7 @@ static u16 wol_calc_crc(int size, u8 *pattern, u8 *mask_pattern)
 }
 
 /**
- *	velocity_set_wol	-	set up for wake on lan
+ *	velocity_set_wol - set up for wake on lan
  *	@vptr: velocity to set WOL status on
  *
  *	Set a card up for wake on lan either by unicast or by
@@ -2957,7 +2957,7 @@ static int velocity_set_wol(struct velocity_info *vptr)
 		memcpy(arp->ar_tip, vptr->ip_addr, 4);
 
 		crc = wol_calc_crc((sizeof(struct arp_packet) + 7) / 8, buf,
-				(u8 *) & mask_pattern[0][0]);
+				(u8 *) &mask_pattern[0][0]);
 
 		writew(crc, &regs->PatternCRC[0]);
 		writew(WOLCR_ARP_EN, &regs->WOLCRSet);
@@ -2997,7 +2997,7 @@ static int velocity_set_wol(struct velocity_info *vptr)
 }
 
 /**
- *	velocity_save_context	-	save registers
+ *	velocity_save_context - save registers
  *	@vptr: velocity
  *	@context: buffer for stored context
  *
@@ -3058,7 +3058,7 @@ static int velocity_suspend(struct pci_dev *pdev, pm_message_t state)
 }
 
 /**
- *	velocity_restore_context	-	restore registers
+ *	velocity_restore_context - restore registers
  *	@vptr: velocity
  *	@context: buffer for stored context
  *
@@ -3133,19 +3133,19 @@ static int velocity_resume(struct pci_dev *pdev)
  *	uses this to handle all our card discover and plugging
  */
 static struct pci_driver velocity_driver = {
-      .name	= VELOCITY_NAME,
-      .id_table	= velocity_id_table,
-      .probe	= velocity_found1,
-      .remove	= __devexit_p(velocity_remove1),
+	.name	= VELOCITY_NAME,
+	.id_table	= velocity_id_table,
+	.probe	= velocity_found1,
+	.remove	= __devexit_p(velocity_remove1),
 #ifdef CONFIG_PM
-      .suspend	= velocity_suspend,
-      .resume	= velocity_resume,
+	.suspend	= velocity_suspend,
+	.resume	= velocity_resume,
 #endif
 };
 
 
 /**
- *	velocity_ethtool_up	-	pre hook for ethtool
+ *	velocity_ethtool_up - pre hook for ethtool
  *	@dev: network device
  *
  *	Called before an ethtool operation. We need to make sure the
@@ -3160,7 +3160,7 @@ static int velocity_ethtool_up(struct net_device *dev)
 }
 
 /**
- *	velocity_ethtool_down	-	post hook for ethtool
+ *	velocity_ethtool_down - post hook for ethtool
  *	@dev: network device
  *
  *	Called after an ethtool operation. Restore the chip back to D3
@@ -3352,8 +3352,7 @@ static int get_pending_timer_val(int val)
 	int mult_bits = val >> 6;
 	int mult = 1;
 
-	switch (mult_bits)
-	{
+	switch (mult_bits) {
 	case 1:
 		mult = 4; break;
 	case 2:
@@ -3454,7 +3453,7 @@ static const struct ethtool_ops velocity_ethtool_ops = {
 	.set_wol	=	velocity_ethtool_set_wol,
 	.get_msglevel	=	velocity_get_msglevel,
 	.set_msglevel	=	velocity_set_msglevel,
-	.set_sg 	=	ethtool_op_set_sg,
+	.set_sg	=	ethtool_op_set_sg,
 	.get_link	=	velocity_get_link,
 	.get_coalesce	=	velocity_get_coalesce,
 	.set_coalesce	=	velocity_set_coalesce,
@@ -3480,7 +3479,7 @@ static int velocity_netdev_event(struct notifier_block *nb, unsigned long notifi
 
 #if defined(CONFIG_PM) && defined(CONFIG_INET)
 static struct notifier_block velocity_inetaddr_notifier = {
-      .notifier_call	= velocity_netdev_event,
+	.notifier_call	= velocity_netdev_event,
 };
 
 static void velocity_register_notifier(void)
@@ -3501,7 +3500,7 @@ static void velocity_unregister_notifier(void)
 #endif	/* defined(CONFIG_PM) && defined(CONFIG_INET) */
 
 /**
- *	velocity_init_module	-	load time function
+ *	velocity_init_module - load time function
  *
  *	Called when the velocity module is loaded. The PCI driver
  *	is registered with the PCI layer, and in turn will call
@@ -3520,7 +3519,7 @@ static int __init velocity_init_module(void)
 }
 
 /**
- *	velocity_cleanup	-	module unload
+ *	velocity_cleanup - module unload
  *
  *	When the velocity hardware is unloaded this function is called.
  *	It will clean up the notifiers and the unregister the PCI
-- 
1.7.3.2
