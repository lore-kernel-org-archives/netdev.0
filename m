From: Dave Jones <davej@redhat.com>
Subject: [3/4] Remove unnecessary forward declarations from velocity NIC driver.
Date: Mon, 20 Jul 2009 23:35:58 -0400
Message-ID: <200907211640.n6LGeHii011454@gelk.kernelslacker.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52612 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755762AbZGUQkT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 12:40:19 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n6LGeJed001607
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 12:40:19 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n6LGeIeV025781
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 12:40:18 -0400
Received: from gelk.kernelslacker.org (vpn-10-139.bos.redhat.com [10.16.10.139])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n6LGeH51015097
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 12:40:17 -0400
Received: from gelk.kernelslacker.org (gelk.kernelslacker.org [127.0.0.1])
	by gelk.kernelslacker.org (8.14.3/8.14.3) with ESMTP id n6LGeHNY011455
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 12:40:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By moving functions to before their first call, we eliminate
the need to define forward references.

Signed-off-by: Dave Jones <davej@redhat.com>
---
 drivers/net/via-velocity.c | 3259 +++++++++++++++++++++-----------------------
 1 files changed, 1580 insertions(+), 1679 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index d6a92b7..b4bd1d3 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -92,7 +92,6 @@ static int msglevel = MSG_LEVEL_INFO;
  *	Fetch the mask bits of the selected CAM and store them into the
  *	provided mask buffer.
  */
-
 static void mac_get_cam_mask(struct mac_regs __iomem *regs, u8 *mask)
 {
 	int i;
@@ -121,7 +120,6 @@ static void mac_get_cam_mask(struct mac_regs __iomem *regs, u8 *mask)
  *
  *	Store a new mask into a CAM
  */
-
 static void mac_set_cam_mask(struct mac_regs __iomem *regs, u8 *mask)
 {
 	int i;
@@ -166,7 +164,6 @@ static void mac_set_vlan_cam_mask(struct mac_regs __iomem *regs, u8 *mask)
  *
  *	Load an address or vlan tag into a CAM
  */
-
 static void mac_set_cam(struct mac_regs __iomem *regs, int idx, const u8 *addr)
 {
 	int i;
@@ -222,7 +219,6 @@ static void mac_set_vlan_cam(struct mac_regs __iomem *regs, int idx,
  *	reset the Wake on lan features. This function doesn't restore
  *	the rest of the logic from the result of sleep/wakeup
  */
-
 static void mac_wol_reset(struct mac_regs __iomem *regs)
 {
 
@@ -241,7 +237,6 @@ static void mac_wol_reset(struct mac_regs __iomem *regs)
 	writew(0xFFFF, &regs->WOLSRClr);
 }
 
-static int velocity_mii_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
 static const struct ethtool_ops velocity_ethtool_ops;
 
 /*
@@ -369,76 +364,14 @@ static int rx_copybreak = 200;
 module_param(rx_copybreak, int, 0644);
 MODULE_PARM_DESC(rx_copybreak, "Copy breakpoint for copy-only-tiny-frames");
 
-static void velocity_init_info(struct pci_dev *pdev, struct velocity_info *vptr,
-			       const struct velocity_info_tbl *info);
-static int velocity_get_pci_info(struct velocity_info *, struct pci_dev *pdev);
-static void velocity_print_info(struct velocity_info *vptr);
-static int velocity_open(struct net_device *dev);
-static int velocity_change_mtu(struct net_device *dev, int mtu);
-static int velocity_xmit(struct sk_buff *skb, struct net_device *dev);
-static irqreturn_t velocity_intr(int irq, void *dev_instance);
-static void velocity_set_multi(struct net_device *dev);
-static struct net_device_stats *velocity_get_stats(struct net_device *dev);
-static int velocity_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
-static int velocity_close(struct net_device *dev);
-static int velocity_receive_frame(struct velocity_info *, int idx);
-static int velocity_alloc_rx_buf(struct velocity_info *, int idx);
-static void velocity_free_rd_ring(struct velocity_info *vptr);
-static void velocity_free_tx_buf(struct velocity_info *vptr, struct velocity_td_info *);
-static int velocity_soft_reset(struct velocity_info *vptr);
-static void mii_init(struct velocity_info *vptr, u32 mii_status);
-static u32 velocity_get_link(struct net_device *dev);
-static u32 velocity_get_opt_media_mode(struct velocity_info *vptr);
-static void velocity_print_link_status(struct velocity_info *vptr);
-static void safe_disable_mii_autopoll(struct mac_regs __iomem *regs);
-static void velocity_shutdown(struct velocity_info *vptr);
-static void enable_flow_control_ability(struct velocity_info *vptr);
-static void enable_mii_autopoll(struct mac_regs __iomem *regs);
-static int velocity_mii_read(struct mac_regs __iomem *, u8 byIdx, u16 *pdata);
-static int velocity_mii_write(struct mac_regs __iomem *, u8 byMiiAddr, u16 data);
-static u32 mii_check_media_mode(struct mac_regs __iomem *regs);
-static u32 check_connection_type(struct mac_regs __iomem *regs);
-static int velocity_set_media_mode(struct velocity_info *vptr, u32 mii_status);
-
 #ifdef CONFIG_PM
-
-static int velocity_suspend(struct pci_dev *pdev, pm_message_t state);
-static int velocity_resume(struct pci_dev *pdev);
-
 static DEFINE_SPINLOCK(velocity_dev_list_lock);
 static LIST_HEAD(velocity_dev_list);
-
-#endif
-
-#if defined(CONFIG_PM) && defined(CONFIG_INET)
-
-static int velocity_netdev_event(struct notifier_block *nb, unsigned long notification, void *ptr);
-
-static struct notifier_block velocity_inetaddr_notifier = {
-      .notifier_call	= velocity_netdev_event,
-};
-
-static void velocity_register_notifier(void)
-{
-	register_inetaddr_notifier(&velocity_inetaddr_notifier);
-}
-
-static void velocity_unregister_notifier(void)
-{
-	unregister_inetaddr_notifier(&velocity_inetaddr_notifier);
-}
-
-#else
-
-#define velocity_register_notifier()	do {} while (0)
-#define velocity_unregister_notifier()	do {} while (0)
-
 #endif
 
 /*
  *	Internal board variants. At the moment we have only one
  */
-
 static struct velocity_info_tbl chip_info_table[] = {
 	{CHIP_TYPE_VT6110, "VIA Networking Velocity Family Gigabit Ethernet Adapter", 1, 0x00FFFFFFUL},
 	{ }
@@ -448,7 +381,6 @@ static struct velocity_info_tbl chip_info_table[] = {
  *	Describe the PCI device identifiers that we support in this
  *	device driver. Used for hotplug autoloading.
  */
-
 static const struct pci_device_id velocity_id_table[] __devinitdata = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_VIA, PCI_DEVICE_ID_VIA_612X) },
 	{ }
@@ -463,7 +395,6 @@ MODULE_DEVICE_TABLE(pci, velocity_id_table);
  *	Given a chip identifier return a suitable description. Returns
  *	a pointer a static string valid while the driver is loaded.
  */
-
 static const char __devinit *get_chip_name(enum chip_type chip_id)
 {
 	int i;
@@ -481,7 +412,6 @@ static const char __devinit *get_chip_name(enum chip_type chip_id)
  *	unload for each active device that is present. Disconnects
  *	the device from the network layer and frees all the resources
  */
-
 static void __devexit velocity_remove1(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
@@ -519,7 +449,6 @@ static void __devexit velocity_remove1(struct pci_dev *pdev)
  *	all the verification and checking as well as reporting so that
  *	we don't duplicate code for each option.
  */
-
 static void __devinit velocity_set_int_opt(int *opt, int val, int min, int max, int def, char *name, const char *devname)
 {
 	if (val == -1)
@@ -548,7 +477,6 @@ static void __devinit velocity_set_int_opt(int *opt, int val, int min, int max,
  *	all the verification and checking as well as reporting so that
  *	we don't duplicate code for each option.
  */
-
 static void __devinit velocity_set_bool_opt(u32 *opt, int val, int def, u32 flag, char *name, const char *devname)
 {
 	(*opt) &= (~flag);
@@ -574,7 +502,6 @@ static void __devinit velocity_set_bool_opt(u32 *opt, int val, int def, u32 flag
  *	Turn the module and command options into a single structure
  *	for the current device
  */
-
 static void __devinit velocity_get_options(struct velocity_opt *opts, int index, const char *devname)
 {
 
@@ -600,7 +527,6 @@ static void __devinit velocity_get_options(struct velocity_opt *opts, int index,
  *	Initialize the content addressable memory used for filters. Load
  *	appropriately according to the presence of VLAN
  */
-
 static void velocity_init_cam_filter(struct velocity_info *vptr)
 {
 	struct mac_regs __iomem *regs = vptr->mac_regs;
@@ -673,7 +599,6 @@ static void velocity_init_rx_ring_indexes(struct velocity_info *vptr)
  *	Reset the ownership and status for the receive ring side.
  *	Hand all the receive queue to the NIC.
  */
-
 static void velocity_rx_reset(struct velocity_info *vptr)
 {
 
@@ -695,6 +620,647 @@ static void velocity_rx_reset(struct velocity_info *vptr)
 }
 
 /**
+ *	velocity_get_opt_media_mode	-	get media selection
+ *	@vptr: velocity adapter
+ *
+ *	Get the media mode stored in EEPROM or module options and load
+ *	mii_status accordingly. The requested link state information
+ *	is also returned.
+ */
+static u32 velocity_get_opt_media_mode(struct velocity_info *vptr)
+{
+	u32 status = 0;
+
+	switch (vptr->options.spd_dpx) {
+	case SPD_DPX_AUTO:
+		status = VELOCITY_AUTONEG_ENABLE;
+		break;
+	case SPD_DPX_100_FULL:
+		status = VELOCITY_SPEED_100 | VELOCITY_DUPLEX_FULL;
+		break;
+	case SPD_DPX_10_FULL:
+		status = VELOCITY_SPEED_10 | VELOCITY_DUPLEX_FULL;
+		break;
+	case SPD_DPX_100_HALF:
+		status = VELOCITY_SPEED_100;
+		break;
+	case SPD_DPX_10_HALF:
+		status = VELOCITY_SPEED_10;
+		break;
+	}
+	vptr->mii_status = status;
+	return status;
+}
+
+/**
+ *	safe_disable_mii_autopoll	-	autopoll off
+ *	@regs: velocity registers
+ *
+ *	Turn off the autopoll and wait for it to disable on the chip
+ */
+static void safe_disable_mii_autopoll(struct mac_regs __iomem *regs)
+{
+	u16 ww;
+
+	/*  turn off MAUTO */
+	writeb(0, &regs->MIICR);
+	for (ww = 0; ww < W_MAX_TIMEOUT; ww++) {
+		udelay(1);
+		if (BYTE_REG_BITS_IS_ON(MIISR_MIDLE, &regs->MIISR))
+			break;
+	}
+}
+
+/**
+ *	enable_mii_autopoll	-	turn on autopolling
+ *	@regs: velocity registers
+ *
+ *	Enable the MII link status autopoll feature on the Velocity
+ *	hardware. Wait for it to enable.
+ */
+static void enable_mii_autopoll(struct mac_regs __iomem *regs)
+{
+	int ii;
+
+	writeb(0, &(regs->MIICR));
+	writeb(MIIADR_SWMPL, &regs->MIIADR);
+
+	for (ii = 0; ii < W_MAX_TIMEOUT; ii++) {
+		udelay(1);
+		if (BYTE_REG_BITS_IS_ON(MIISR_MIDLE, &regs->MIISR))
+			break;
+	}
+
+	writeb(MIICR_MAUTO, &regs->MIICR);
+
+	for (ii = 0; ii < W_MAX_TIMEOUT; ii++) {
+		udelay(1);
+		if (!BYTE_REG_BITS_IS_ON(MIISR_MIDLE, &regs->MIISR))
+			break;
+	}
+
+}
+
+/**
+ *	velocity_mii_read	-	read MII data
+ *	@regs: velocity registers
+ *	@index: MII register index
+ *	@data: buffer for received data
+ *
+ *	Perform a single read of an MII 16bit register. Returns zero
+ *	on success or -ETIMEDOUT if the PHY did not respond.
+ */
+static int velocity_mii_read(struct mac_regs __iomem *regs, u8 index, u16 *data)
+{
+	u16 ww;
+
+	/*
+	 *	Disable MIICR_MAUTO, so that mii addr can be set normally
+	 */
+	safe_disable_mii_autopoll(regs);
+
+	writeb(index, &regs->MIIADR);
+
+	BYTE_REG_BITS_ON(MIICR_RCMD, &regs->MIICR);
+
+	for (ww = 0; ww < W_MAX_TIMEOUT; ww++) {
+		if (!(readb(&regs->MIICR) & MIICR_RCMD))
+			break;
+	}
+
+	*data = readw(&regs->MIIDATA);
+
+	enable_mii_autopoll(regs);
+	if (ww == W_MAX_TIMEOUT)
+		return -ETIMEDOUT;
+	return 0;
+}
+
+
+/**
+ *	mii_check_media_mode	-	check media state
+ *	@regs: velocity registers
+ *
+ *	Check the current MII status and determine the link status
+ *	accordingly
+ */
+static u32 mii_check_media_mode(struct mac_regs __iomem *regs)
+{
+	u32 status = 0;
+	u16 ANAR;
+
+	if (!MII_REG_BITS_IS_ON(BMSR_LNK, MII_REG_BMSR, regs))
+		status |= VELOCITY_LINK_FAIL;
+
+	if (MII_REG_BITS_IS_ON(G1000CR_1000FD, MII_REG_G1000CR, regs))
+		status |= VELOCITY_SPEED_1000 | VELOCITY_DUPLEX_FULL;
+	else if (MII_REG_BITS_IS_ON(G1000CR_1000, MII_REG_G1000CR, regs))
+		status |= (VELOCITY_SPEED_1000);
+	else {
+		velocity_mii_read(regs, MII_REG_ANAR, &ANAR);
+		if (ANAR & ANAR_TXFD)
+			status |= (VELOCITY_SPEED_100 | VELOCITY_DUPLEX_FULL);
+		else if (ANAR & ANAR_TX)
+			status |= VELOCITY_SPEED_100;
+		else if (ANAR & ANAR_10FD)
+			status |= (VELOCITY_SPEED_10 | VELOCITY_DUPLEX_FULL);
+		else
+			status |= (VELOCITY_SPEED_10);
+	}
+
+	if (MII_REG_BITS_IS_ON(BMCR_AUTO, MII_REG_BMCR, regs)) {
+		velocity_mii_read(regs, MII_REG_ANAR, &ANAR);
+		if ((ANAR & (ANAR_TXFD | ANAR_TX | ANAR_10FD | ANAR_10))
+		    == (ANAR_TXFD | ANAR_TX | ANAR_10FD | ANAR_10)) {
+			if (MII_REG_BITS_IS_ON(G1000CR_1000 | G1000CR_1000FD, MII_REG_G1000CR, regs))
+				status |= VELOCITY_AUTONEG_ENABLE;
+		}
+	}
+
+	return status;
+}
+
+/**
+ *	velocity_mii_write	-	write MII data
+ *	@regs: velocity registers
+ *	@index: MII register index
+ *	@data: 16bit data for the MII register
+ *
+ *	Perform a single write to an MII 16bit register. Returns zero
+ *	on success or -ETIMEDOUT if the PHY did not respond.
+ */
+static int velocity_mii_write(struct mac_regs __iomem *regs, u8 mii_addr, u16 data)
+{
+	u16 ww;
+
+	/*
+	 *	Disable MIICR_MAUTO, so that mii addr can be set normally
+	 */
+	safe_disable_mii_autopoll(regs);
+
+	/* MII reg offset */
+	writeb(mii_addr, &regs->MIIADR);
+	/* set MII data */
+	writew(data, &regs->MIIDATA);
+
+	/* turn on MIICR_WCMD */
+	BYTE_REG_BITS_ON(MIICR_WCMD, &regs->MIICR);
+
+	/* W_MAX_TIMEOUT is the timeout period */
+	for (ww = 0; ww < W_MAX_TIMEOUT; ww++) {
+		udelay(5);
+		if (!(readb(&regs->MIICR) & MIICR_WCMD))
+			break;
+	}
+	enable_mii_autopoll(regs);
+
+	if (ww == W_MAX_TIMEOUT)
+		return -ETIMEDOUT;
+	return 0;
+}
+
+/**
+ *	set_mii_flow_control	-	flow control setup
+ *	@vptr: velocity interface
+ *
+ *	Set up the flow control on this interface according to
+ *	the supplied user/eeprom options.
+ */
+static void set_mii_flow_control(struct velocity_info *vptr)
+{
+	/*Enable or Disable PAUSE in ANAR */
+	switch (vptr->options.flow_cntl) {
+	case FLOW_CNTL_TX:
+		MII_REG_BITS_OFF(ANAR_PAUSE, MII_REG_ANAR, vptr->mac_regs);
+		MII_REG_BITS_ON(ANAR_ASMDIR, MII_REG_ANAR, vptr->mac_regs);
+		break;
+
+	case FLOW_CNTL_RX:
+		MII_REG_BITS_ON(ANAR_PAUSE, MII_REG_ANAR, vptr->mac_regs);
+		MII_REG_BITS_ON(ANAR_ASMDIR, MII_REG_ANAR, vptr->mac_regs);
+		break;
+
+	case FLOW_CNTL_TX_RX:
+		MII_REG_BITS_ON(ANAR_PAUSE, MII_REG_ANAR, vptr->mac_regs);
+		MII_REG_BITS_ON(ANAR_ASMDIR, MII_REG_ANAR, vptr->mac_regs);
+		break;
+
+	case FLOW_CNTL_DISABLE:
+		MII_REG_BITS_OFF(ANAR_PAUSE, MII_REG_ANAR, vptr->mac_regs);
+		MII_REG_BITS_OFF(ANAR_ASMDIR, MII_REG_ANAR, vptr->mac_regs);
+		break;
+	default:
+		break;
+	}
+}
+
+/**
+ *	mii_set_auto_on		-	autonegotiate on
+ *	@vptr: velocity
+ *
+ *	Enable autonegotation on this interface
+ */
+static void mii_set_auto_on(struct velocity_info *vptr)
+{
+	if (MII_REG_BITS_IS_ON(BMCR_AUTO, MII_REG_BMCR, vptr->mac_regs))
+		MII_REG_BITS_ON(BMCR_REAUTO, MII_REG_BMCR, vptr->mac_regs);
+	else
+		MII_REG_BITS_ON(BMCR_AUTO, MII_REG_BMCR, vptr->mac_regs);
+}
+
+static u32 check_connection_type(struct mac_regs __iomem *regs)
+{
+	u32 status = 0;
+	u8 PHYSR0;
+	u16 ANAR;
+	PHYSR0 = readb(&regs->PHYSR0);
+
+	/*
+	   if (!(PHYSR0 & PHYSR0_LINKGD))
+	   status|=VELOCITY_LINK_FAIL;
+	 */
+
+	if (PHYSR0 & PHYSR0_FDPX)
+		status |= VELOCITY_DUPLEX_FULL;
+
+	if (PHYSR0 & PHYSR0_SPDG)
+		status |= VELOCITY_SPEED_1000;
+	else if (PHYSR0 & PHYSR0_SPD10)
+		status |= VELOCITY_SPEED_10;
+	else
+		status |= VELOCITY_SPEED_100;
+
+	if (MII_REG_BITS_IS_ON(BMCR_AUTO, MII_REG_BMCR, regs)) {
+		velocity_mii_read(regs, MII_REG_ANAR, &ANAR);
+		if ((ANAR & (ANAR_TXFD | ANAR_TX | ANAR_10FD | ANAR_10))
+		    == (ANAR_TXFD | ANAR_TX | ANAR_10FD | ANAR_10)) {
+			if (MII_REG_BITS_IS_ON(G1000CR_1000 | G1000CR_1000FD, MII_REG_G1000CR, regs))
+				status |= VELOCITY_AUTONEG_ENABLE;
+		}
+	}
+
+	return status;
+}
+
+
+
+/**
+ *	velocity_set_media_mode		-	set media mode
+ *	@mii_status: old MII link state
+ *
+ *	Check the media link state and configure the flow control
+ *	PHY and also velocity hardware setup accordingly. In particular
+ *	we need to set up CD polling and frame bursting.
+ */
+static int velocity_set_media_mode(struct velocity_info *vptr, u32 mii_status)
+{
+	u32 curr_status;
+	struct mac_regs __iomem *regs = vptr->mac_regs;
+
+	vptr->mii_status = mii_check_media_mode(vptr->mac_regs);
+	curr_status = vptr->mii_status & (~VELOCITY_LINK_FAIL);
+
+	/* Set mii link status */
+	set_mii_flow_control(vptr);
+
+	/*
+	   Check if new status is consisent with current status
+	   if (((mii_status & curr_status) & VELOCITY_AUTONEG_ENABLE)
+	   || (mii_status==curr_status)) {
+	   vptr->mii_status=mii_check_media_mode(vptr->mac_regs);
+	   vptr->mii_status=check_connection_type(vptr->mac_regs);
+	   VELOCITY_PRT(MSG_LEVEL_INFO, "Velocity link no change\n");
+	   return 0;
+	   }
+	 */
+
+	if (PHYID_GET_PHY_ID(vptr->phy_id) == PHYID_CICADA_CS8201)
+		MII_REG_BITS_ON(AUXCR_MDPPS, MII_REG_AUXCR, vptr->mac_regs);
+
+	/*
+	 *	If connection type is AUTO
+	 */
+	if (mii_status & VELOCITY_AUTONEG_ENABLE) {
+		VELOCITY_PRT(MSG_LEVEL_INFO, "Velocity is AUTO mode\n");
+		/* clear force MAC mode bit */
+		BYTE_REG_BITS_OFF(CHIPGCR_FCMODE, &regs->CHIPGCR);
+		/* set duplex mode of MAC according to duplex mode of MII */
+		MII_REG_BITS_ON(ANAR_TXFD | ANAR_TX | ANAR_10FD | ANAR_10, MII_REG_ANAR, vptr->mac_regs);
+		MII_REG_BITS_ON(G1000CR_1000FD | G1000CR_1000, MII_REG_G1000CR, vptr->mac_regs);
+		MII_REG_BITS_ON(BMCR_SPEED1G, MII_REG_BMCR, vptr->mac_regs);
+
+		/* enable AUTO-NEGO mode */
+		mii_set_auto_on(vptr);
+	} else {
+		u16 ANAR;
+		u8 CHIPGCR;
+
+		/*
+		 * 1. if it's 3119, disable frame bursting in halfduplex mode
+		 *    and enable it in fullduplex mode
+		 * 2. set correct MII/GMII and half/full duplex mode in CHIPGCR
+		 * 3. only enable CD heart beat counter in 10HD mode
+		 */
+
+		/* set force MAC mode bit */
+		BYTE_REG_BITS_ON(CHIPGCR_FCMODE, &regs->CHIPGCR);
+
+		CHIPGCR = readb(&regs->CHIPGCR);
+		CHIPGCR &= ~CHIPGCR_FCGMII;
+
+		if (mii_status & VELOCITY_DUPLEX_FULL) {
+			CHIPGCR |= CHIPGCR_FCFDX;
+			writeb(CHIPGCR, &regs->CHIPGCR);
+			VELOCITY_PRT(MSG_LEVEL_INFO, "set Velocity to forced full mode\n");
+			if (vptr->rev_id < REV_ID_VT3216_A0)
+				BYTE_REG_BITS_OFF(TCR_TB2BDIS, &regs->TCR);
+		} else {
+			CHIPGCR &= ~CHIPGCR_FCFDX;
+			VELOCITY_PRT(MSG_LEVEL_INFO, "set Velocity to forced half mode\n");
+			writeb(CHIPGCR, &regs->CHIPGCR);
+			if (vptr->rev_id < REV_ID_VT3216_A0)
+				BYTE_REG_BITS_ON(TCR_TB2BDIS, &regs->TCR);
+		}
+
+		MII_REG_BITS_OFF(G1000CR_1000FD | G1000CR_1000, MII_REG_G1000CR, vptr->mac_regs);
+
+		if (!(mii_status & VELOCITY_DUPLEX_FULL) && (mii_status & VELOCITY_SPEED_10))
+			BYTE_REG_BITS_OFF(TESTCFG_HBDIS, &regs->TESTCFG);
+		else
+			BYTE_REG_BITS_ON(TESTCFG_HBDIS, &regs->TESTCFG);
+
+		/* MII_REG_BITS_OFF(BMCR_SPEED1G, MII_REG_BMCR, vptr->mac_regs); */
+		velocity_mii_read(vptr->mac_regs, MII_REG_ANAR, &ANAR);
+		ANAR &= (~(ANAR_TXFD | ANAR_TX | ANAR_10FD | ANAR_10));
+		if (mii_status & VELOCITY_SPEED_100) {
+			if (mii_status & VELOCITY_DUPLEX_FULL)
+				ANAR |= ANAR_TXFD;
+			else
+				ANAR |= ANAR_TX;
+		} else {
+			if (mii_status & VELOCITY_DUPLEX_FULL)
+				ANAR |= ANAR_10FD;
+			else
+				ANAR |= ANAR_10;
+		}
+		velocity_mii_write(vptr->mac_regs, MII_REG_ANAR, ANAR);
+		/* enable AUTO-NEGO mode */
+		mii_set_auto_on(vptr);
+		/* MII_REG_BITS_ON(BMCR_AUTO, MII_REG_BMCR, vptr->mac_regs); */
+	}
+	/* vptr->mii_status=mii_check_media_mode(vptr->mac_regs); */
+	/* vptr->mii_status=check_connection_type(vptr->mac_regs); */
+	return VELOCITY_LINK_CHANGE;
+}
+
+/**
+ *	velocity_print_link_status	-	link status reporting
+ *	@vptr: velocity to report on
+ *
+ *	Turn the link status of the velocity card into a kernel log
+ *	description of the new link state, detailing speed and duplex
+ *	status
+ */
+static void velocity_print_link_status(struct velocity_info *vptr)
+{
+
+	if (vptr->mii_status & VELOCITY_LINK_FAIL) {
+		VELOCITY_PRT(MSG_LEVEL_INFO, KERN_NOTICE "%s: failed to detect cable link\n", vptr->dev->name);
+	} else if (vptr->options.spd_dpx == SPD_DPX_AUTO) {
+		VELOCITY_PRT(MSG_LEVEL_INFO, KERN_NOTICE "%s: Link auto-negotiation", vptr->dev->name);
+
+		if (vptr->mii_status & VELOCITY_SPEED_1000)
+			VELOCITY_PRT(MSG_LEVEL_INFO, " speed 1000M bps");
+		else if (vptr->mii_status & VELOCITY_SPEED_100)
+			VELOCITY_PRT(MSG_LEVEL_INFO, " speed 100M bps");
+		else
+			VELOCITY_PRT(MSG_LEVEL_INFO, " speed 10M bps");
+
+		if (vptr->mii_status & VELOCITY_DUPLEX_FULL)
+			VELOCITY_PRT(MSG_LEVEL_INFO, " full duplex\n");
+		else
+			VELOCITY_PRT(MSG_LEVEL_INFO, " half duplex\n");
+	} else {
+		VELOCITY_PRT(MSG_LEVEL_INFO, KERN_NOTICE "%s: Link forced", vptr->dev->name);
+		switch (vptr->options.spd_dpx) {
+		case SPD_DPX_100_HALF:
+			VELOCITY_PRT(MSG_LEVEL_INFO, " speed 100M bps half duplex\n");
+			break;
+		case SPD_DPX_100_FULL:
+			VELOCITY_PRT(MSG_LEVEL_INFO, " speed 100M bps full duplex\n");
+			break;
+		case SPD_DPX_10_HALF:
+			VELOCITY_PRT(MSG_LEVEL_INFO, " speed 10M bps half duplex\n");
+			break;
+		case SPD_DPX_10_FULL:
+			VELOCITY_PRT(MSG_LEVEL_INFO, " speed 10M bps full duplex\n");
+			break;
+		default:
+			break;
+		}
+	}
+}
+
+/**
+ *	enable_flow_control_ability	-	flow control
+ *	@vptr: veloity to configure
+ *
+ *	Set up flow control according to the flow control options
+ *	determined by the eeprom/configuration.
+ */
+static void enable_flow_control_ability(struct velocity_info *vptr)
+{
+
+	struct mac_regs __iomem *regs = vptr->mac_regs;
+
+	switch (vptr->options.flow_cntl) {
+
+	case FLOW_CNTL_DEFAULT:
+		if (BYTE_REG_BITS_IS_ON(PHYSR0_RXFLC, &regs->PHYSR0))
+			writel(CR0_FDXRFCEN, &regs->CR0Set);
+		else
+			writel(CR0_FDXRFCEN, &regs->CR0Clr);
+
+		if (BYTE_REG_BITS_IS_ON(PHYSR0_TXFLC, &regs->PHYSR0))
+			writel(CR0_FDXTFCEN, &regs->CR0Set);
+		else
+			writel(CR0_FDXTFCEN, &regs->CR0Clr);
+		break;
+
+	case FLOW_CNTL_TX:
+		writel(CR0_FDXTFCEN, &regs->CR0Set);
+		writel(CR0_FDXRFCEN, &regs->CR0Clr);
+		break;
+
+	case FLOW_CNTL_RX:
+		writel(CR0_FDXRFCEN, &regs->CR0Set);
+		writel(CR0_FDXTFCEN, &regs->CR0Clr);
+		break;
+
+	case FLOW_CNTL_TX_RX:
+		writel(CR0_FDXTFCEN, &regs->CR0Set);
+		writel(CR0_FDXRFCEN, &regs->CR0Set);
+		break;
+
+	case FLOW_CNTL_DISABLE:
+		writel(CR0_FDXRFCEN, &regs->CR0Clr);
+		writel(CR0_FDXTFCEN, &regs->CR0Clr);
+		break;
+
+	default:
+		break;
+	}
+
+}
+
+/**
+ *	velocity_soft_reset	-	soft reset
+ *	@vptr: velocity to reset
+ *
+ *	Kick off a soft reset of the velocity adapter and then poll
+ *	until the reset sequence has completed before returning.
+ */
+static int velocity_soft_reset(struct velocity_info *vptr)
+{
+	struct mac_regs __iomem *regs = vptr->mac_regs;
+	int i = 0;
+
+	writel(CR0_SFRST, &regs->CR0Set);
+
+	for (i = 0; i < W_MAX_TIMEOUT; i++) {
+		udelay(5);
+		if (!DWORD_REG_BITS_IS_ON(CR0_SFRST, &regs->CR0Set))
+			break;
+	}
+
+	if (i == W_MAX_TIMEOUT) {
+		writel(CR0_FORSRST, &regs->CR0Set);
+		/* FIXME: PCI POSTING */
+		/* delay 2ms */
+		mdelay(2);
+	}
+	return 0;
+}
+
+/**
+ *	velocity_set_multi	-	filter list change callback
+ *	@dev: network device
+ *
+ *	Called by the network layer when the filter lists need to change
+ *	for a velocity adapter. Reload the CAMs with the new address
+ *	filter ruleset.
+ */
+static void velocity_set_multi(struct net_device *dev)
+{
+	struct velocity_info *vptr = netdev_priv(dev);
+	struct mac_regs __iomem *regs = vptr->mac_regs;
+	u8 rx_mode;
+	int i;
+	struct dev_mc_list *mclist;
+
+	if (dev->flags & IFF_PROMISC) {	/* Set promiscuous. */
+		writel(0xffffffff, &regs->MARCAM[0]);
+		writel(0xffffffff, &regs->MARCAM[4]);
+		rx_mode = (RCR_AM | RCR_AB | RCR_PROM);
+	} else if ((dev->mc_count > vptr->multicast_limit)
+		   || (dev->flags & IFF_ALLMULTI)) {
+		writel(0xffffffff, &regs->MARCAM[0]);
+		writel(0xffffffff, &regs->MARCAM[4]);
+		rx_mode = (RCR_AM | RCR_AB);
+	} else {
+		int offset = MCAM_SIZE - vptr->multicast_limit;
+		mac_get_cam_mask(regs, vptr->mCAMmask);
+
+		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count; i++, mclist = mclist->next) {
+			mac_set_cam(regs, i + offset, mclist->dmi_addr);
+			vptr->mCAMmask[(offset + i) / 8] |= 1 << ((offset + i) & 7);
+		}
+
+		mac_set_cam_mask(regs, vptr->mCAMmask);
+		rx_mode = RCR_AM | RCR_AB | RCR_AP;
+	}
+	if (dev->mtu > 1500)
+		rx_mode |= RCR_AL;
+
+	BYTE_REG_BITS_ON(rx_mode, &regs->RCR);
+
+}
+
+/*
+ * MII access , media link mode setting functions
+ */
+
+/**
+ *	mii_init	-	set up MII
+ *	@vptr: velocity adapter
+ *	@mii_status:  links tatus
+ *
+ *	Set up the PHY for the current link state.
+ */
+static void mii_init(struct velocity_info *vptr, u32 mii_status)
+{
+	u16 BMCR;
+
+	switch (PHYID_GET_PHY_ID(vptr->phy_id)) {
+	case PHYID_CICADA_CS8201:
+		/*
+		 *	Reset to hardware default
+		 */
+		MII_REG_BITS_OFF((ANAR_ASMDIR | ANAR_PAUSE), MII_REG_ANAR, vptr->mac_regs);
+		/*
+		 *	Turn on ECHODIS bit in NWay-forced full mode and turn it
+		 *	off it in NWay-forced half mode for NWay-forced v.s.
+		 *	legacy-forced issue.
+		 */
+		if (vptr->mii_status & VELOCITY_DUPLEX_FULL)
+			MII_REG_BITS_ON(TCSR_ECHODIS, MII_REG_TCSR, vptr->mac_regs);
+		else
+			MII_REG_BITS_OFF(TCSR_ECHODIS, MII_REG_TCSR, vptr->mac_regs);
+		/*
+		 *	Turn on Link/Activity LED enable bit for CIS8201
+		 */
+		MII_REG_BITS_ON(PLED_LALBE, MII_REG_PLED, vptr->mac_regs);
+		break;
+	case PHYID_VT3216_32BIT:
+	case PHYID_VT3216_64BIT:
+		/*
+		 *	Reset to hardware default
+		 */
+		MII_REG_BITS_ON((ANAR_ASMDIR | ANAR_PAUSE), MII_REG_ANAR, vptr->mac_regs);
+		/*
+		 *	Turn on ECHODIS bit in NWay-forced full mode and turn it
+		 *	off it in NWay-forced half mode for NWay-forced v.s.
+		 *	legacy-forced issue
+		 */
+		if (vptr->mii_status & VELOCITY_DUPLEX_FULL)
+			MII_REG_BITS_ON(TCSR_ECHODIS, MII_REG_TCSR, vptr->mac_regs);
+		else
+			MII_REG_BITS_OFF(TCSR_ECHODIS, MII_REG_TCSR, vptr->mac_regs);
+		break;
+
+	case PHYID_MARVELL_1000:
+	case PHYID_MARVELL_1000S:
+		/*
+		 *	Assert CRS on Transmit
+		 */
+		MII_REG_BITS_ON(PSCR_ACRSTX, MII_REG_PSCR, vptr->mac_regs);
+		/*
+		 *	Reset to hardware default
+		 */
+		MII_REG_BITS_ON((ANAR_ASMDIR | ANAR_PAUSE), MII_REG_ANAR, vptr->mac_regs);
+		break;
+	default:
+		;
+	}
+	velocity_mii_read(vptr->mac_regs, MII_REG_BMCR, &BMCR);
+	if (BMCR & BMCR_ISO) {
+		BMCR &= ~BMCR_ISO;
+		velocity_mii_write(vptr->mac_regs, MII_REG_BMCR, BMCR);
+	}
+}
+
+
+/**
  *	velocity_init_registers	-	initialise MAC registers
  *	@vptr: velocity to init
  *	@type: type of initialisation (hot or cold)
@@ -702,7 +1268,6 @@ static void velocity_rx_reset(struct velocity_info *vptr)
  *	Initialise the MAC on a reset or on first set up on the
  *	hardware.
  */
-
 static void velocity_init_registers(struct velocity_info *vptr,
 				    enum velocity_init_type type)
 {
@@ -818,288 +1383,29 @@ static void velocity_init_registers(struct velocity_info *vptr,
 	}
 }
 
-/**
- *	velocity_soft_reset	-	soft reset
- *	@vptr: velocity to reset
- *
- *	Kick off a soft reset of the velocity adapter and then poll
- *	until the reset sequence has completed before returning.
- */
-
-static int velocity_soft_reset(struct velocity_info *vptr)
+static void velocity_give_many_rx_descs(struct velocity_info *vptr)
 {
 	struct mac_regs __iomem *regs = vptr->mac_regs;
-	int i = 0;
-
-	writel(CR0_SFRST, &regs->CR0Set);
-
-	for (i = 0; i < W_MAX_TIMEOUT; i++) {
-		udelay(5);
-		if (!DWORD_REG_BITS_IS_ON(CR0_SFRST, &regs->CR0Set))
-			break;
-	}
-
-	if (i == W_MAX_TIMEOUT) {
-		writel(CR0_FORSRST, &regs->CR0Set);
-		/* FIXME: PCI POSTING */
-		/* delay 2ms */
-		mdelay(2);
-	}
-	return 0;
-}
-
-static const struct net_device_ops velocity_netdev_ops = {
-	.ndo_open		= velocity_open,
-	.ndo_stop		= velocity_close,
-	.ndo_start_xmit		= velocity_xmit,
-	.ndo_get_stats		= velocity_get_stats,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address 	= eth_mac_addr,
-	.ndo_set_multicast_list	= velocity_set_multi,
-	.ndo_change_mtu		= velocity_change_mtu,
-	.ndo_do_ioctl		= velocity_ioctl,
-	.ndo_vlan_rx_add_vid	= velocity_vlan_rx_add_vid,
-	.ndo_vlan_rx_kill_vid	= velocity_vlan_rx_kill_vid,
-	.ndo_vlan_rx_register	= velocity_vlan_rx_register,
-};
-
-/**
- *	velocity_found1		-	set up discovered velocity card
- *	@pdev: PCI device
- *	@ent: PCI device table entry that matched
- *
- *	Configure a discovered adapter from scratch. Return a negative
- *	errno error code on failure paths.
- */
-
-static int __devinit velocity_found1(struct pci_dev *pdev, const struct pci_device_id *ent)
-{
-	static int first = 1;
-	struct net_device *dev;
-	int i;
-	const char *drv_string;
-	const struct velocity_info_tbl *info = &chip_info_table[ent->driver_data];
-	struct velocity_info *vptr;
-	struct mac_regs __iomem *regs;
-	int ret = -ENOMEM;
-
-	/* FIXME: this driver, like almost all other ethernet drivers,
-	 * can support more than MAX_UNITS.
-	 */
-	if (velocity_nics >= MAX_UNITS) {
-		dev_notice(&pdev->dev, "already found %d NICs.\n",
-			   velocity_nics);
-		return -ENODEV;
-	}
-
-	dev = alloc_etherdev(sizeof(struct velocity_info));
-	if (!dev) {
-		dev_err(&pdev->dev, "allocate net device failed.\n");
-		goto out;
-	}
-
-	/* Chain it all together */
-
-	SET_NETDEV_DEV(dev, &pdev->dev);
-	vptr = netdev_priv(dev);
-
-
-	if (first) {
-		printk(KERN_INFO "%s Ver. %s\n",
-			VELOCITY_FULL_DRV_NAM, VELOCITY_VERSION);
-		printk(KERN_INFO "Copyright (c) 2002, 2003 VIA Networking Technologies, Inc.\n");
-		printk(KERN_INFO "Copyright (c) 2004 Red Hat Inc.\n");
-		first = 0;
-	}
-
-	velocity_init_info(pdev, vptr, info);
-
-	vptr->dev = dev;
-
-	dev->irq = pdev->irq;
-
-	ret = pci_enable_device(pdev);
-	if (ret < 0)
-		goto err_free_dev;
-
-	ret = velocity_get_pci_info(vptr, pdev);
-	if (ret < 0) {
-		/* error message already printed */
-		goto err_disable;
-	}
-
-	ret = pci_request_regions(pdev, VELOCITY_NAME);
-	if (ret < 0) {
-		dev_err(&pdev->dev, "No PCI resources.\n");
-		goto err_disable;
-	}
-
-	regs = ioremap(vptr->memaddr, VELOCITY_IO_SIZE);
-	if (regs == NULL) {
-		ret = -EIO;
-		goto err_release_res;
-	}
-
-	vptr->mac_regs = regs;
-
-	mac_wol_reset(regs);
-
-	dev->base_addr = vptr->ioaddr;
-
-	for (i = 0; i < 6; i++)
-		dev->dev_addr[i] = readb(&regs->PAR[i]);
-
-
-	drv_string = dev_driver_string(&pdev->dev);
-
-	velocity_get_options(&vptr->options, velocity_nics, drv_string);
-
-	/*
-	 *	Mask out the options cannot be set to the chip
-	 */
-
-	vptr->options.flags &= info->flags;
+	int avail, dirty, unusable;
 
 	/*
-	 *	Enable the chip specified capbilities
+	 * RD number must be equal to 4X per hardware spec
+	 * (programming guide rev 1.20, p.13)
 	 */
+	if (vptr->rx.filled < 4)
+		return;
 
-	vptr->flags = vptr->options.flags | (info->flags & 0xFF000000UL);
-
-	vptr->wol_opts = vptr->options.wol_opts;
-	vptr->flags |= VELOCITY_FLAGS_WOL_ENABLED;
-
-	vptr->phy_id = MII_GET_PHY_ID(vptr->mac_regs);
-
-	dev->irq = pdev->irq;
-	dev->netdev_ops = &velocity_netdev_ops;
-	dev->ethtool_ops = &velocity_ethtool_ops;
-
-	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER |
-		NETIF_F_HW_VLAN_RX;
-
-	if (vptr->flags & VELOCITY_FLAGS_TX_CSUM)
-		dev->features |= NETIF_F_IP_CSUM;
-
-	ret = register_netdev(dev);
-	if (ret < 0)
-		goto err_iounmap;
-
-	if (!velocity_get_link(dev)) {
-		netif_carrier_off(dev);
-		vptr->mii_status |= VELOCITY_LINK_FAIL;
-	}
-
-	velocity_print_info(vptr);
-	pci_set_drvdata(pdev, dev);
-
-	/* and leave the chip powered down */
-
-	pci_set_power_state(pdev, PCI_D3hot);
-#ifdef CONFIG_PM
-	{
-		unsigned long flags;
-
-		spin_lock_irqsave(&velocity_dev_list_lock, flags);
-		list_add(&vptr->list, &velocity_dev_list);
-		spin_unlock_irqrestore(&velocity_dev_list_lock, flags);
-	}
-#endif
-	velocity_nics++;
-out:
-	return ret;
-
-err_iounmap:
-	iounmap(regs);
-err_release_res:
-	pci_release_regions(pdev);
-err_disable:
-	pci_disable_device(pdev);
-err_free_dev:
-	free_netdev(dev);
-	goto out;
-}
-
-/**
- *	velocity_print_info	-	per driver data
- *	@vptr: velocity
- *
- *	Print per driver data as the kernel driver finds Velocity
- *	hardware
- */
-
-static void __devinit velocity_print_info(struct velocity_info *vptr)
-{
-	struct net_device *dev = vptr->dev;
-
-	printk(KERN_INFO "%s: %s\n", dev->name, get_chip_name(vptr->chip_id));
-	printk(KERN_INFO "%s: Ethernet Address: %2.2X:%2.2X:%2.2X:%2.2X:%2.2X:%2.2X\n",
-		dev->name,
-		dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-		dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
-}
-
-/**
- *	velocity_init_info	-	init private data
- *	@pdev: PCI device
- *	@vptr: Velocity info
- *	@info: Board type
- *
- *	Set up the initial velocity_info struct for the device that has been
- *	discovered.
- */
-
-static void __devinit velocity_init_info(struct pci_dev *pdev,
-					 struct velocity_info *vptr,
-					 const struct velocity_info_tbl *info)
-{
-	memset(vptr, 0, sizeof(struct velocity_info));
-
-	vptr->pdev = pdev;
-	vptr->chip_id = info->chip_id;
-	vptr->tx.numq = info->txqueue;
-	vptr->multicast_limit = MCAM_SIZE;
-	spin_lock_init(&vptr->lock);
-	INIT_LIST_HEAD(&vptr->list);
-}
-
-/**
- *	velocity_get_pci_info	-	retrieve PCI info for device
- *	@vptr: velocity device
- *	@pdev: PCI device it matches
- *
- *	Retrieve the PCI configuration space data that interests us from
- *	the kernel PCI layer
- */
-
-static int __devinit velocity_get_pci_info(struct velocity_info *vptr, struct pci_dev *pdev)
-{
-	vptr->rev_id = pdev->revision;
-
-	pci_set_master(pdev);
-
-	vptr->ioaddr = pci_resource_start(pdev, 0);
-	vptr->memaddr = pci_resource_start(pdev, 1);
-
-	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_IO)) {
-		dev_err(&pdev->dev,
-			   "region #0 is not an I/O resource, aborting.\n");
-		return -EINVAL;
-	}
-
-	if ((pci_resource_flags(pdev, 1) & IORESOURCE_IO)) {
-		dev_err(&pdev->dev,
-			   "region #1 is an I/O resource, aborting.\n");
-		return -EINVAL;
-	}
+	wmb();
 
-	if (pci_resource_len(pdev, 1) < VELOCITY_IO_SIZE) {
-		dev_err(&pdev->dev, "region #1 is too small.\n");
-		return -EINVAL;
+	unusable = vptr->rx.filled & 0x0003;
+	dirty = vptr->rx.dirty - unusable;
+	for (avail = vptr->rx.filled & 0xfffc; avail; avail--) {
+		dirty = (dirty > 0) ? dirty - 1 : vptr->options.numrx - 1;
+		vptr->rx.ring[dirty].rdesc0.len |= OWNED_BY_NIC;
 	}
-	vptr->pdev = pdev;
 
-	return 0;
+	writew(vptr->rx.filled & 0xfffc, &regs->RBRDU);
+	vptr->rx.filled = unusable;
 }
 
 /**
@@ -1109,7 +1415,6 @@ static int __devinit velocity_get_pci_info(struct velocity_info *vptr, struct pc
  *	Allocate PCI mapped DMA rings for the receive and transmit layer
  *	to use.
  */
-
 static int velocity_init_dma_rings(struct velocity_info *vptr)
 {
 	struct velocity_opt *opt = &vptr->options;
@@ -1150,46 +1455,50 @@ static int velocity_init_dma_rings(struct velocity_info *vptr)
 	return 0;
 }
 
+static void velocity_set_rxbufsize(struct velocity_info *vptr, int mtu)
+{
+	vptr->rx.buf_sz = (mtu <= ETH_DATA_LEN) ? PKT_BUF_SZ : mtu + 32;
+}
+
 /**
- *	velocity_free_dma_rings	-	free PCI ring pointers
- *	@vptr: Velocity to free from
+ *	velocity_alloc_rx_buf	-	allocate aligned receive buffer
+ *	@vptr: velocity
+ *	@idx: ring index
  *
- *	Clean up the PCI ring buffers allocated to this velocity.
+ *	Allocate a new full sized buffer for the reception of a frame and
+ *	map it into PCI space for the hardware to use. The hardware
+ *	requires *64* byte alignment of the buffer which makes life
+ *	less fun than would be ideal.
  */
-
-static void velocity_free_dma_rings(struct velocity_info *vptr)
+static int velocity_alloc_rx_buf(struct velocity_info *vptr, int idx)
 {
-	const int size = vptr->options.numrx * sizeof(struct rx_desc) +
-		vptr->options.numtx * sizeof(struct tx_desc) * vptr->tx.numq;
-
-	pci_free_consistent(vptr->pdev, size, vptr->rx.ring, vptr->rx.pool_dma);
-}
+	struct rx_desc *rd = &(vptr->rx.ring[idx]);
+	struct velocity_rd_info *rd_info = &(vptr->rx.info[idx]);
 
-static void velocity_give_many_rx_descs(struct velocity_info *vptr)
-{
-	struct mac_regs __iomem *regs = vptr->mac_regs;
-	int avail, dirty, unusable;
+	rd_info->skb = dev_alloc_skb(vptr->rx.buf_sz + 64);
+	if (rd_info->skb == NULL)
+		return -ENOMEM;
 
 	/*
-	 * RD number must be equal to 4X per hardware spec
-	 * (programming guide rev 1.20, p.13)
+	 *	Do the gymnastics to get the buffer head for data at
+	 *	64byte alignment.
 	 */
-	if (vptr->rx.filled < 4)
-		return;
-
-	wmb();
+	skb_reserve(rd_info->skb, (unsigned long) rd_info->skb->data & 63);
+	rd_info->skb_dma = pci_map_single(vptr->pdev, rd_info->skb->data,
+					vptr->rx.buf_sz, PCI_DMA_FROMDEVICE);
 
-	unusable = vptr->rx.filled & 0x0003;
-	dirty = vptr->rx.dirty - unusable;
-	for (avail = vptr->rx.filled & 0xfffc; avail; avail--) {
-		dirty = (dirty > 0) ? dirty - 1 : vptr->options.numrx - 1;
-		vptr->rx.ring[dirty].rdesc0.len |= OWNED_BY_NIC;
-	}
+	/*
+	 *	Fill in the descriptor to match
+	 */
 
-	writew(vptr->rx.filled & 0xfffc, &regs->RBRDU);
-	vptr->rx.filled = unusable;
+	*((u32 *) & (rd->rdesc0)) = 0;
+	rd->size = cpu_to_le16(vptr->rx.buf_sz) | RX_INTEN;
+	rd->pa_low = cpu_to_le32(rd_info->skb_dma);
+	rd->pa_high = 0;
+	return 0;
 }
 
+
 static int velocity_rx_refill(struct velocity_info *vptr)
 {
 	int dirty = vptr->rx.dirty, done = 0;
@@ -1217,42 +1526,6 @@ static int velocity_rx_refill(struct velocity_info *vptr)
 	return done;
 }
 
-static void velocity_set_rxbufsize(struct velocity_info *vptr, int mtu)
-{
-	vptr->rx.buf_sz = (mtu <= ETH_DATA_LEN) ? PKT_BUF_SZ : mtu + 32;
-}
-
-/**
- *	velocity_init_rd_ring	-	set up receive ring
- *	@vptr: velocity to configure
- *
- *	Allocate and set up the receive buffers for each ring slot and
- *	assign them to the network adapter.
- */
-
-static int velocity_init_rd_ring(struct velocity_info *vptr)
-{
-	int ret = -ENOMEM;
-
-	vptr->rx.info = kcalloc(vptr->options.numrx,
-				sizeof(struct velocity_rd_info), GFP_KERNEL);
-	if (!vptr->rx.info)
-		goto out;
-
-	velocity_init_rx_ring_indexes(vptr);
-
-	if (velocity_rx_refill(vptr) != vptr->options.numrx) {
-		VELOCITY_PRT(MSG_LEVEL_ERR, KERN_ERR
-			"%s: failed to allocate RX buffer.\n", vptr->dev->name);
-		velocity_free_rd_ring(vptr);
-		goto out;
-	}
-
-	ret = 0;
-out:
-	return ret;
-}
-
 /**
  *	velocity_free_rd_ring	-	free receive ring
  *	@vptr: velocity to clean up
@@ -1260,7 +1533,6 @@ out:
  *	Free the receive buffers for each ring slot and any
  *	attached socket buffers that need to go away.
  */
-
 static void velocity_free_rd_ring(struct velocity_info *vptr)
 {
 	int i;
@@ -1288,6 +1560,38 @@ static void velocity_free_rd_ring(struct velocity_info *vptr)
 	vptr->rx.info = NULL;
 }
 
+
+
+/**
+ *	velocity_init_rd_ring	-	set up receive ring
+ *	@vptr: velocity to configure
+ *
+ *	Allocate and set up the receive buffers for each ring slot and
+ *	assign them to the network adapter.
+ */
+static int velocity_init_rd_ring(struct velocity_info *vptr)
+{
+	int ret = -ENOMEM;
+
+	vptr->rx.info = kcalloc(vptr->options.numrx,
+				sizeof(struct velocity_rd_info), GFP_KERNEL);
+	if (!vptr->rx.info)
+		goto out;
+
+	velocity_init_rx_ring_indexes(vptr);
+
+	if (velocity_rx_refill(vptr) != vptr->options.numrx) {
+		VELOCITY_PRT(MSG_LEVEL_ERR, KERN_ERR
+			"%s: failed to allocate RX buffer.\n", vptr->dev->name);
+		velocity_free_rd_ring(vptr);
+		goto out;
+	}
+
+	ret = 0;
+out:
+	return ret;
+}
+
 /**
  *	velocity_init_td_ring	-	set up transmit ring
  *	@vptr:	velocity
@@ -1296,7 +1600,6 @@ static void velocity_free_rd_ring(struct velocity_info *vptr)
  *	Returns zero on success or a negative posix errno code for
  *	failure.
  */
-
 static int velocity_init_td_ring(struct velocity_info *vptr)
 {
 	dma_addr_t curr;
@@ -1320,10 +1623,81 @@ static int velocity_init_td_ring(struct velocity_info *vptr)
 	return 0;
 }
 
+/**
+ *	velocity_free_dma_rings	-	free PCI ring pointers
+ *	@vptr: Velocity to free from
+ *
+ *	Clean up the PCI ring buffers allocated to this velocity.
+ */
+static void velocity_free_dma_rings(struct velocity_info *vptr)
+{
+	const int size = vptr->options.numrx * sizeof(struct rx_desc) +
+		vptr->options.numtx * sizeof(struct tx_desc) * vptr->tx.numq;
+
+	pci_free_consistent(vptr->pdev, size, vptr->rx.ring, vptr->rx.pool_dma);
+}
+
+
+static int velocity_init_rings(struct velocity_info *vptr, int mtu)
+{
+	int ret;
+
+	velocity_set_rxbufsize(vptr, mtu);
+
+	ret = velocity_init_dma_rings(vptr);
+	if (ret < 0)
+		goto out;
+
+	ret = velocity_init_rd_ring(vptr);
+	if (ret < 0)
+		goto err_free_dma_rings_0;
+
+	ret = velocity_init_td_ring(vptr);
+	if (ret < 0)
+		goto err_free_rd_ring_1;
+out:
+	return ret;
+
+err_free_rd_ring_1:
+	velocity_free_rd_ring(vptr);
+err_free_dma_rings_0:
+	velocity_free_dma_rings(vptr);
+	goto out;
+}
+
+/**
+ *	velocity_free_tx_buf	-	free transmit buffer
+ *	@vptr: velocity
+ *	@tdinfo: buffer
+ *
+ *	Release an transmit buffer. If the buffer was preallocated then
+ *	recycle it, if not then unmap the buffer.
+ */
+static void velocity_free_tx_buf(struct velocity_info *vptr, struct velocity_td_info *tdinfo)
+{
+	struct sk_buff *skb = tdinfo->skb;
+	int i;
+	int pktlen;
+
+	/*
+	 *	Don't unmap the pre-allocated tx_bufs
+	 */
+	if (tdinfo->skb_dma) {
+
+		pktlen = max_t(unsigned int, skb->len, ETH_ZLEN);
+		for (i = 0; i < tdinfo->nskb_dma; i++) {
+			pci_unmap_single(vptr->pdev, tdinfo->skb_dma[i], pktlen, PCI_DMA_TODEVICE);
+			tdinfo->skb_dma[i] = 0;
+		}
+	}
+	dev_kfree_skb_irq(skb);
+	tdinfo->skb = NULL;
+}
+
+
 /*
  *	FIXME: could we merge this with velocity_free_tx_buf ?
  */
-
 static void velocity_free_td_ring_entry(struct velocity_info *vptr,
 							 int q, int n)
 {
@@ -1353,7 +1727,6 @@ static void velocity_free_td_ring_entry(struct velocity_info *vptr,
  *	Free up the transmit ring for this particular velocity adapter.
  *	We free the ring contents but not the ring itself.
  */
-
 static void velocity_free_td_ring(struct velocity_info *vptr)
 {
 	int i, j;
@@ -1369,61 +1742,167 @@ static void velocity_free_td_ring(struct velocity_info *vptr)
 	}
 }
 
+
+static void velocity_free_rings(struct velocity_info *vptr)
+{
+	velocity_free_td_ring(vptr);
+	velocity_free_rd_ring(vptr);
+	velocity_free_dma_rings(vptr);
+}
+
 /**
- *	velocity_rx_srv		-	service RX interrupt
+ *	velocity_error	-	handle error from controller
  *	@vptr: velocity
- *	@status: adapter status (unused)
+ *	@status: card status
+ *
+ *	Process an error report from the hardware and attempt to recover
+ *	the card itself. At the moment we cannot recover from some
+ *	theoretically impossible errors but this could be fixed using
+ *	the pci_device_failed logic to bounce the hardware
  *
- *	Walk the receive ring of the velocity adapter and remove
- *	any received packets from the receive queue. Hand the ring
- *	slots back to the adapter for reuse.
  */
-
-static int velocity_rx_srv(struct velocity_info *vptr, int status)
+static void velocity_error(struct velocity_info *vptr, int status)
 {
-	struct net_device_stats *stats = &vptr->dev->stats;
-	int rd_curr = vptr->rx.curr;
-	int works = 0;
 
-	do {
-		struct rx_desc *rd = vptr->rx.ring + rd_curr;
+	if (status & ISR_TXSTLI) {
+		struct mac_regs __iomem *regs = vptr->mac_regs;
 
-		if (!vptr->rx.info[rd_curr].skb)
-			break;
+		printk(KERN_ERR "TD structure error TDindex=%hx\n", readw(&regs->TDIdx[0]));
+		BYTE_REG_BITS_ON(TXESR_TDSTR, &regs->TXESR);
+		writew(TRDCSR_RUN, &regs->TDCSRClr);
+		netif_stop_queue(vptr->dev);
 
-		if (rd->rdesc0.len & OWNED_BY_NIC)
-			break;
+		/* FIXME: port over the pci_device_failed code and use it
+		   here */
+	}
 
-		rmb();
+	if (status & ISR_SRCI) {
+		struct mac_regs __iomem *regs = vptr->mac_regs;
+		int linked;
+
+		if (vptr->options.spd_dpx == SPD_DPX_AUTO) {
+			vptr->mii_status = check_connection_type(regs);
 
+			/*
+			 *	If it is a 3119, disable frame bursting in
+			 *	halfduplex mode and enable it in fullduplex
+			 *	 mode
+			 */
+			if (vptr->rev_id < REV_ID_VT3216_A0) {
+				if (vptr->mii_status | VELOCITY_DUPLEX_FULL)
+					BYTE_REG_BITS_ON(TCR_TB2BDIS, &regs->TCR);
+				else
+					BYTE_REG_BITS_OFF(TCR_TB2BDIS, &regs->TCR);
+			}
+			/*
+			 *	Only enable CD heart beat counter in 10HD mode
+			 */
+			if (!(vptr->mii_status & VELOCITY_DUPLEX_FULL) && (vptr->mii_status & VELOCITY_SPEED_10))
+				BYTE_REG_BITS_OFF(TESTCFG_HBDIS, &regs->TESTCFG);
+			else
+				BYTE_REG_BITS_ON(TESTCFG_HBDIS, &regs->TESTCFG);
+		}
 		/*
-		 *	Don't drop CE or RL error frame although RXOK is off
+		 *	Get link status from PHYSR0
 		 */
-		if (rd->rdesc0.RSR & (RSR_RXOK | RSR_CE | RSR_RL)) {
-			if (velocity_receive_frame(vptr, rd_curr) < 0)
-				stats->rx_dropped++;
-		} else {
-			if (rd->rdesc0.RSR & RSR_CRC)
-				stats->rx_crc_errors++;
-			if (rd->rdesc0.RSR & RSR_FAE)
-				stats->rx_frame_errors++;
+		linked = readb(&regs->PHYSR0) & PHYSR0_LINKGD;
 
-			stats->rx_dropped++;
+		if (linked) {
+			vptr->mii_status &= ~VELOCITY_LINK_FAIL;
+			netif_carrier_on(vptr->dev);
+		} else {
+			vptr->mii_status |= VELOCITY_LINK_FAIL;
+			netif_carrier_off(vptr->dev);
 		}
 
-		rd->size |= RX_INTEN;
+		velocity_print_link_status(vptr);
+		enable_flow_control_ability(vptr);
 
-		rd_curr++;
-		if (rd_curr >= vptr->options.numrx)
-			rd_curr = 0;
-	} while (++works <= 15);
+		/*
+		 *	Re-enable auto-polling because SRCI will disable
+		 *	auto-polling
+		 */
 
-	vptr->rx.curr = rd_curr;
+		enable_mii_autopoll(regs);
 
-	if ((works > 0) && (velocity_rx_refill(vptr) > 0))
-		velocity_give_many_rx_descs(vptr);
+		if (vptr->mii_status & VELOCITY_LINK_FAIL)
+			netif_stop_queue(vptr->dev);
+		else
+			netif_wake_queue(vptr->dev);
 
-	VAR_USED(stats);
+	};
+	if (status & ISR_MIBFI)
+		velocity_update_hw_mibs(vptr);
+	if (status & ISR_LSTEI)
+		mac_rx_queue_wake(vptr->mac_regs);
+}
+
+/**
+ *	tx_srv		-	transmit interrupt service
+ *	@vptr; Velocity
+ *	@status:
+ *
+ *	Scan the queues looking for transmitted packets that
+ *	we can complete and clean up. Update any statistics as
+ *	necessary/
+ */
+static int velocity_tx_srv(struct velocity_info *vptr, u32 status)
+{
+	struct tx_desc *td;
+	int qnum;
+	int full = 0;
+	int idx;
+	int works = 0;
+	struct velocity_td_info *tdinfo;
+	struct net_device_stats *stats = &vptr->dev->stats;
+
+	for (qnum = 0; qnum < vptr->tx.numq; qnum++) {
+		for (idx = vptr->tx.tail[qnum]; vptr->tx.used[qnum] > 0;
+			idx = (idx + 1) % vptr->options.numtx) {
+
+			/*
+			 *	Get Tx Descriptor
+			 */
+			td = &(vptr->tx.rings[qnum][idx]);
+			tdinfo = &(vptr->tx.infos[qnum][idx]);
+
+			if (td->tdesc0.len & OWNED_BY_NIC)
+				break;
+
+			if ((works++ > 15))
+				break;
+
+			if (td->tdesc0.TSR & TSR0_TERR) {
+				stats->tx_errors++;
+				stats->tx_dropped++;
+				if (td->tdesc0.TSR & TSR0_CDH)
+					stats->tx_heartbeat_errors++;
+				if (td->tdesc0.TSR & TSR0_CRS)
+					stats->tx_carrier_errors++;
+				if (td->tdesc0.TSR & TSR0_ABT)
+					stats->tx_aborted_errors++;
+				if (td->tdesc0.TSR & TSR0_OWC)
+					stats->tx_window_errors++;
+			} else {
+				stats->tx_packets++;
+				stats->tx_bytes += tdinfo->skb->len;
+			}
+			velocity_free_tx_buf(vptr, tdinfo);
+			vptr->tx.used[qnum]--;
+		}
+		vptr->tx.tail[qnum] = idx;
+
+		if (AVAIL_TD(vptr, qnum) < 1)
+			full = 1;
+	}
+	/*
+	 *	Look to see if we should kick the transmit network
+	 *	layer for more work.
+	 */
+	if (netif_queue_stopped(vptr->dev) && (full == 0)
+	    && (!(vptr->mii_status & VELOCITY_LINK_FAIL))) {
+		netif_wake_queue(vptr->dev);
+	}
 	return works;
 }
 
@@ -1435,7 +1914,6 @@ static int velocity_rx_srv(struct velocity_info *vptr, int status)
  *	Process the status bits for the received packet and determine
  *	if the checksum was computed and verified by the hardware
  */
-
 static inline void velocity_rx_csum(struct rx_desc *rd, struct sk_buff *skb)
 {
 	skb->ip_summed = CHECKSUM_NONE;
@@ -1502,6 +1980,7 @@ static inline void velocity_iph_realign(struct velocity_info *vptr,
 	}
 }
 
+
 /**
  *	velocity_receive_frame	-	received packet processor
  *	@vptr: velocity we are handling
@@ -1510,7 +1989,6 @@ static inline void velocity_iph_realign(struct velocity_info *vptr,
  *	A packet has arrived. We process the packet and if appropriate
  *	pass the frame up the network stack
  */
-
 static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 {
 	void (*pci_action)(struct pci_dev *, dma_addr_t, size_t, int);
@@ -1572,314 +2050,118 @@ static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 	return 0;
 }
 
+
 /**
- *	velocity_alloc_rx_buf	-	allocate aligned receive buffer
+ *	velocity_rx_srv		-	service RX interrupt
  *	@vptr: velocity
- *	@idx: ring index
+ *	@status: adapter status (unused)
  *
- *	Allocate a new full sized buffer for the reception of a frame and
- *	map it into PCI space for the hardware to use. The hardware
- *	requires *64* byte alignment of the buffer which makes life
- *	less fun than would be ideal.
+ *	Walk the receive ring of the velocity adapter and remove
+ *	any received packets from the receive queue. Hand the ring
+ *	slots back to the adapter for reuse.
  */
-
-static int velocity_alloc_rx_buf(struct velocity_info *vptr, int idx)
+static int velocity_rx_srv(struct velocity_info *vptr, int status)
 {
-	struct rx_desc *rd = &(vptr->rx.ring[idx]);
-	struct velocity_rd_info *rd_info = &(vptr->rx.info[idx]);
-
-	rd_info->skb = dev_alloc_skb(vptr->rx.buf_sz + 64);
-	if (rd_info->skb == NULL)
-		return -ENOMEM;
+	struct net_device_stats *stats = &vptr->dev->stats;
+	int rd_curr = vptr->rx.curr;
+	int works = 0;
 
-	/*
-	 *	Do the gymnastics to get the buffer head for data at
-	 *	64byte alignment.
-	 */
-	skb_reserve(rd_info->skb, (unsigned long) rd_info->skb->data & 63);
-	rd_info->skb_dma = pci_map_single(vptr->pdev, rd_info->skb->data,
-					vptr->rx.buf_sz, PCI_DMA_FROMDEVICE);
+	do {
+		struct rx_desc *rd = vptr->rx.ring + rd_curr;
 
-	/*
-	 *	Fill in the descriptor to match
-	 */
+		if (!vptr->rx.info[rd_curr].skb)
+			break;
 
-	*((u32 *) & (rd->rdesc0)) = 0;
-	rd->size = cpu_to_le16(vptr->rx.buf_sz) | RX_INTEN;
-	rd->pa_low = cpu_to_le32(rd_info->skb_dma);
-	rd->pa_high = 0;
-	return 0;
-}
+		if (rd->rdesc0.len & OWNED_BY_NIC)
+			break;
 
-/**
- *	tx_srv		-	transmit interrupt service
- *	@vptr; Velocity
- *	@status:
- *
- *	Scan the queues looking for transmitted packets that
- *	we can complete and clean up. Update any statistics as
- *	necessary/
- */
+		rmb();
 
-static int velocity_tx_srv(struct velocity_info *vptr, u32 status)
-{
-	struct tx_desc *td;
-	int qnum;
-	int full = 0;
-	int idx;
-	int works = 0;
-	struct velocity_td_info *tdinfo;
-	struct net_device_stats *stats = &vptr->dev->stats;
+		/*
+		 *	Don't drop CE or RL error frame although RXOK is off
+		 */
+		if (rd->rdesc0.RSR & (RSR_RXOK | RSR_CE | RSR_RL)) {
+			if (velocity_receive_frame(vptr, rd_curr) < 0)
+				stats->rx_dropped++;
+		} else {
+			if (rd->rdesc0.RSR & RSR_CRC)
+				stats->rx_crc_errors++;
+			if (rd->rdesc0.RSR & RSR_FAE)
+				stats->rx_frame_errors++;
 
-	for (qnum = 0; qnum < vptr->tx.numq; qnum++) {
-		for (idx = vptr->tx.tail[qnum]; vptr->tx.used[qnum] > 0;
-			idx = (idx + 1) % vptr->options.numtx) {
+			stats->rx_dropped++;
+		}
 
-			/*
-			 *	Get Tx Descriptor
-			 */
-			td = &(vptr->tx.rings[qnum][idx]);
-			tdinfo = &(vptr->tx.infos[qnum][idx]);
+		rd->size |= RX_INTEN;
 
-			if (td->tdesc0.len & OWNED_BY_NIC)
-				break;
+		rd_curr++;
+		if (rd_curr >= vptr->options.numrx)
+			rd_curr = 0;
+	} while (++works <= 15);
 
-			if ((works++ > 15))
-				break;
+	vptr->rx.curr = rd_curr;
 
-			if (td->tdesc0.TSR & TSR0_TERR) {
-				stats->tx_errors++;
-				stats->tx_dropped++;
-				if (td->tdesc0.TSR & TSR0_CDH)
-					stats->tx_heartbeat_errors++;
-				if (td->tdesc0.TSR & TSR0_CRS)
-					stats->tx_carrier_errors++;
-				if (td->tdesc0.TSR & TSR0_ABT)
-					stats->tx_aborted_errors++;
-				if (td->tdesc0.TSR & TSR0_OWC)
-					stats->tx_window_errors++;
-			} else {
-				stats->tx_packets++;
-				stats->tx_bytes += tdinfo->skb->len;
-			}
-			velocity_free_tx_buf(vptr, tdinfo);
-			vptr->tx.used[qnum]--;
-		}
-		vptr->tx.tail[qnum] = idx;
+	if ((works > 0) && (velocity_rx_refill(vptr) > 0))
+		velocity_give_many_rx_descs(vptr);
 
-		if (AVAIL_TD(vptr, qnum) < 1)
-			full = 1;
-	}
-	/*
-	 *	Look to see if we should kick the transmit network
-	 *	layer for more work.
-	 */
-	if (netif_queue_stopped(vptr->dev) && (full == 0)
-	    && (!(vptr->mii_status & VELOCITY_LINK_FAIL))) {
-		netif_wake_queue(vptr->dev);
-	}
+	VAR_USED(stats);
 	return works;
 }
 
-/**
- *	velocity_print_link_status	-	link status reporting
- *	@vptr: velocity to report on
- *
- *	Turn the link status of the velocity card into a kernel log
- *	description of the new link state, detailing speed and duplex
- *	status
- */
-
-static void velocity_print_link_status(struct velocity_info *vptr)
-{
-
-	if (vptr->mii_status & VELOCITY_LINK_FAIL) {
-		VELOCITY_PRT(MSG_LEVEL_INFO, KERN_NOTICE "%s: failed to detect cable link\n", vptr->dev->name);
-	} else if (vptr->options.spd_dpx == SPD_DPX_AUTO) {
-		VELOCITY_PRT(MSG_LEVEL_INFO, KERN_NOTICE "%s: Link auto-negotiation", vptr->dev->name);
-
-		if (vptr->mii_status & VELOCITY_SPEED_1000)
-			VELOCITY_PRT(MSG_LEVEL_INFO, " speed 1000M bps");
-		else if (vptr->mii_status & VELOCITY_SPEED_100)
-			VELOCITY_PRT(MSG_LEVEL_INFO, " speed 100M bps");
-		else
-			VELOCITY_PRT(MSG_LEVEL_INFO, " speed 10M bps");
-
-		if (vptr->mii_status & VELOCITY_DUPLEX_FULL)
-			VELOCITY_PRT(MSG_LEVEL_INFO, " full duplex\n");
-		else
-			VELOCITY_PRT(MSG_LEVEL_INFO, " half duplex\n");
-	} else {
-		VELOCITY_PRT(MSG_LEVEL_INFO, KERN_NOTICE "%s: Link forced", vptr->dev->name);
-		switch (vptr->options.spd_dpx) {
-		case SPD_DPX_100_HALF:
-			VELOCITY_PRT(MSG_LEVEL_INFO, " speed 100M bps half duplex\n");
-			break;
-		case SPD_DPX_100_FULL:
-			VELOCITY_PRT(MSG_LEVEL_INFO, " speed 100M bps full duplex\n");
-			break;
-		case SPD_DPX_10_HALF:
-			VELOCITY_PRT(MSG_LEVEL_INFO, " speed 10M bps half duplex\n");
-			break;
-		case SPD_DPX_10_FULL:
-			VELOCITY_PRT(MSG_LEVEL_INFO, " speed 10M bps full duplex\n");
-			break;
-		default:
-			break;
-		}
-	}
-}
 
 /**
- *	velocity_error	-	handle error from controller
- *	@vptr: velocity
- *	@status: card status
- *
- *	Process an error report from the hardware and attempt to recover
- *	the card itself. At the moment we cannot recover from some
- *	theoretically impossible errors but this could be fixed using
- *	the pci_device_failed logic to bounce the hardware
+ *	velocity_intr		-	interrupt callback
+ *	@irq: interrupt number
+ *	@dev_instance: interrupting device
  *
+ *	Called whenever an interrupt is generated by the velocity
+ *	adapter IRQ line. We may not be the source of the interrupt
+ *	and need to identify initially if we are, and if not exit as
+ *	efficiently as possible.
  */
-
-static void velocity_error(struct velocity_info *vptr, int status)
+static irqreturn_t velocity_intr(int irq, void *dev_instance)
 {
+	struct net_device *dev = dev_instance;
+	struct velocity_info *vptr = netdev_priv(dev);
+	u32 isr_status;
+	int max_count = 0;
 
-	if (status & ISR_TXSTLI) {
-		struct mac_regs __iomem *regs = vptr->mac_regs;
 
-		printk(KERN_ERR "TD structure error TDindex=%hx\n", readw(&regs->TDIdx[0]));
-		BYTE_REG_BITS_ON(TXESR_TDSTR, &regs->TXESR);
-		writew(TRDCSR_RUN, &regs->TDCSRClr);
-		netif_stop_queue(vptr->dev);
+	spin_lock(&vptr->lock);
+	isr_status = mac_read_isr(vptr->mac_regs);
 
-		/* FIXME: port over the pci_device_failed code and use it
-		   here */
+	/* Not us ? */
+	if (isr_status == 0) {
+		spin_unlock(&vptr->lock);
+		return IRQ_NONE;
 	}
 
-	if (status & ISR_SRCI) {
-		struct mac_regs __iomem *regs = vptr->mac_regs;
-		int linked;
-
-		if (vptr->options.spd_dpx == SPD_DPX_AUTO) {
-			vptr->mii_status = check_connection_type(regs);
-
-			/*
-			 *	If it is a 3119, disable frame bursting in
-			 *	halfduplex mode and enable it in fullduplex
-			 *	 mode
-			 */
-			if (vptr->rev_id < REV_ID_VT3216_A0) {
-				if (vptr->mii_status | VELOCITY_DUPLEX_FULL)
-					BYTE_REG_BITS_ON(TCR_TB2BDIS, &regs->TCR);
-				else
-					BYTE_REG_BITS_OFF(TCR_TB2BDIS, &regs->TCR);
-			}
-			/*
-			 *	Only enable CD heart beat counter in 10HD mode
-			 */
-			if (!(vptr->mii_status & VELOCITY_DUPLEX_FULL) && (vptr->mii_status & VELOCITY_SPEED_10))
-				BYTE_REG_BITS_OFF(TESTCFG_HBDIS, &regs->TESTCFG);
-			else
-				BYTE_REG_BITS_ON(TESTCFG_HBDIS, &regs->TESTCFG);
-		}
-		/*
-		 *	Get link status from PHYSR0
-		 */
-		linked = readb(&regs->PHYSR0) & PHYSR0_LINKGD;
-
-		if (linked) {
-			vptr->mii_status &= ~VELOCITY_LINK_FAIL;
-			netif_carrier_on(vptr->dev);
-		} else {
-			vptr->mii_status |= VELOCITY_LINK_FAIL;
-			netif_carrier_off(vptr->dev);
-		}
-
-		velocity_print_link_status(vptr);
-		enable_flow_control_ability(vptr);
-
-		/*
-		 *	Re-enable auto-polling because SRCI will disable
-		 *	auto-polling
-		 */
-
-		enable_mii_autopoll(regs);
-
-		if (vptr->mii_status & VELOCITY_LINK_FAIL)
-			netif_stop_queue(vptr->dev);
-		else
-			netif_wake_queue(vptr->dev);
-
-	};
-	if (status & ISR_MIBFI)
-		velocity_update_hw_mibs(vptr);
-	if (status & ISR_LSTEI)
-		mac_rx_queue_wake(vptr->mac_regs);
-}
-
-/**
- *	velocity_free_tx_buf	-	free transmit buffer
- *	@vptr: velocity
- *	@tdinfo: buffer
- *
- *	Release an transmit buffer. If the buffer was preallocated then
- *	recycle it, if not then unmap the buffer.
- */
-
-static void velocity_free_tx_buf(struct velocity_info *vptr, struct velocity_td_info *tdinfo)
-{
-	struct sk_buff *skb = tdinfo->skb;
-	int i;
-	int pktlen;
+	mac_disable_int(vptr->mac_regs);
 
 	/*
-	 *	Don't unmap the pre-allocated tx_bufs
+	 *	Keep processing the ISR until we have completed
+	 *	processing and the isr_status becomes zero
 	 */
-	if (tdinfo->skb_dma) {
 
-		pktlen = max_t(unsigned int, skb->len, ETH_ZLEN);
-		for (i = 0; i < tdinfo->nskb_dma; i++) {
-			pci_unmap_single(vptr->pdev, tdinfo->skb_dma[i], pktlen, PCI_DMA_TODEVICE);
-			tdinfo->skb_dma[i] = 0;
+	while (isr_status != 0) {
+		mac_write_isr(vptr->mac_regs, isr_status);
+		if (isr_status & (~(ISR_PRXI | ISR_PPRXI | ISR_PTXI | ISR_PPTXI)))
+			velocity_error(vptr, isr_status);
+		if (isr_status & (ISR_PRXI | ISR_PPRXI))
+			max_count += velocity_rx_srv(vptr, isr_status);
+		if (isr_status & (ISR_PTXI | ISR_PPTXI))
+			max_count += velocity_tx_srv(vptr, isr_status);
+		isr_status = mac_read_isr(vptr->mac_regs);
+		if (max_count > vptr->options.int_works) {
+			printk(KERN_WARNING "%s: excessive work at interrupt.\n",
+				dev->name);
+			max_count = 0;
 		}
 	}
-	dev_kfree_skb_irq(skb);
-	tdinfo->skb = NULL;
-}
-
-static int velocity_init_rings(struct velocity_info *vptr, int mtu)
-{
-	int ret;
-
-	velocity_set_rxbufsize(vptr, mtu);
-
-	ret = velocity_init_dma_rings(vptr);
-	if (ret < 0)
-		goto out;
-
-	ret = velocity_init_rd_ring(vptr);
-	if (ret < 0)
-		goto err_free_dma_rings_0;
-
-	ret = velocity_init_td_ring(vptr);
-	if (ret < 0)
-		goto err_free_rd_ring_1;
-out:
-	return ret;
+	spin_unlock(&vptr->lock);
+	mac_enable_int(vptr->mac_regs);
+	return IRQ_HANDLED;
 
-err_free_rd_ring_1:
-	velocity_free_rd_ring(vptr);
-err_free_dma_rings_0:
-	velocity_free_dma_rings(vptr);
-	goto out;
-}
-
-static void velocity_free_rings(struct velocity_info *vptr)
-{
-	velocity_free_td_ring(vptr);
-	velocity_free_rd_ring(vptr);
-	velocity_free_dma_rings(vptr);
 }
 
 /**
@@ -1892,7 +2174,6 @@ static void velocity_free_rings(struct velocity_info *vptr)
  *	All the ring allocation and set up is done on open for this
  *	adapter to minimise memory usage when inactive
  */
-
 static int velocity_open(struct net_device *dev)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
@@ -1926,6 +2207,24 @@ out:
 }
 
 /**
+ *	velocity_shutdown	-	shut down the chip
+ *	@vptr: velocity to deactivate
+ *
+ *	Shuts down the internal operations of the velocity and
+ *	disables interrupts, autopolling, transmit and receive
+ */
+static void velocity_shutdown(struct velocity_info *vptr)
+{
+	struct mac_regs __iomem *regs = vptr->mac_regs;
+	mac_disable_int(regs);
+	writel(CR0_STOP, &regs->CR0Set);
+	writew(0xFFFF, &regs->TDCSRClr);
+	writeb(0xFF, &regs->RDCSRClr);
+	safe_disable_mii_autopoll(regs);
+	mac_clear_isr(regs);
+}
+
+/**
  *	velocity_change_mtu	-	MTU change callback
  *	@dev: network device
  *	@new_mtu: desired MTU
@@ -1934,7 +2233,6 @@ out:
  *	this interface. It gets called on a change by the network layer.
  *	Return zero for success or negative posix error code.
  */
-
 static int velocity_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
@@ -2008,22 +2306,127 @@ out_0:
 }
 
 /**
- *	velocity_shutdown	-	shut down the chip
- *	@vptr: velocity to deactivate
+ *	velocity_mii_ioctl		-	MII ioctl handler
+ *	@dev: network device
+ *	@ifr: the ifreq block for the ioctl
+ *	@cmd: the command
  *
- *	Shuts down the internal operations of the velocity and
- *	disables interrupts, autopolling, transmit and receive
+ *	Process MII requests made via ioctl from the network layer. These
+ *	are used by tools like kudzu to interrogate the link state of the
+ *	hardware
  */
-
-static void velocity_shutdown(struct velocity_info *vptr)
+static int velocity_mii_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
+	struct velocity_info *vptr = netdev_priv(dev);
 	struct mac_regs __iomem *regs = vptr->mac_regs;
-	mac_disable_int(regs);
-	writel(CR0_STOP, &regs->CR0Set);
-	writew(0xFFFF, &regs->TDCSRClr);
-	writeb(0xFF, &regs->RDCSRClr);
-	safe_disable_mii_autopoll(regs);
-	mac_clear_isr(regs);
+	unsigned long flags;
+	struct mii_ioctl_data *miidata = if_mii(ifr);
+	int err;
+
+	switch (cmd) {
+	case SIOCGMIIPHY:
+		miidata->phy_id = readb(&regs->MIIADR) & 0x1f;
+		break;
+	case SIOCGMIIREG:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+		if (velocity_mii_read(vptr->mac_regs, miidata->reg_num & 0x1f, &(miidata->val_out)) < 0)
+			return -ETIMEDOUT;
+		break;
+	case SIOCSMIIREG:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+		spin_lock_irqsave(&vptr->lock, flags);
+		err = velocity_mii_write(vptr->mac_regs, miidata->reg_num & 0x1f, miidata->val_in);
+		spin_unlock_irqrestore(&vptr->lock, flags);
+		check_connection_type(vptr->mac_regs);
+		if (err)
+			return err;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+	return 0;
+}
+
+
+/**
+ *	velocity_ioctl		-	ioctl entry point
+ *	@dev: network device
+ *	@rq: interface request ioctl
+ *	@cmd: command code
+ *
+ *	Called when the user issues an ioctl request to the network
+ *	device in question. The velocity interface supports MII.
+ */
+static int velocity_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+	struct velocity_info *vptr = netdev_priv(dev);
+	int ret;
+
+	/* If we are asked for information and the device is power
+	   saving then we need to bring the device back up to talk to it */
+
+	if (!netif_running(dev))
+		pci_set_power_state(vptr->pdev, PCI_D0);
+
+	switch (cmd) {
+	case SIOCGMIIPHY:	/* Get address of MII PHY in use. */
+	case SIOCGMIIREG:	/* Read MII PHY register. */
+	case SIOCSMIIREG:	/* Write to MII PHY register. */
+		ret = velocity_mii_ioctl(dev, rq, cmd);
+		break;
+
+	default:
+		ret = -EOPNOTSUPP;
+	}
+	if (!netif_running(dev))
+		pci_set_power_state(vptr->pdev, PCI_D3hot);
+
+
+	return ret;
+}
+
+/**
+ *	velocity_get_status	-	statistics callback
+ *	@dev: network device
+ *
+ *	Callback from the network layer to allow driver statistics
+ *	to be resynchronized with hardware collected state. In the
+ *	case of the velocity we need to pull the MIB counters from
+ *	the hardware into the counters before letting the network
+ *	layer display them.
+ */
+static struct net_device_stats *velocity_get_stats(struct net_device *dev)
+{
+	struct velocity_info *vptr = netdev_priv(dev);
+
+	/* If the hardware is down, don't touch MII */
+	if (!netif_running(dev))
+		return &dev->stats;
+
+	spin_lock_irq(&vptr->lock);
+	velocity_update_hw_mibs(vptr);
+	spin_unlock_irq(&vptr->lock);
+
+	dev->stats.rx_packets = vptr->mib_counter[HW_MIB_ifRxAllPkts];
+	dev->stats.rx_errors = vptr->mib_counter[HW_MIB_ifRxErrorPkts];
+	dev->stats.rx_length_errors = vptr->mib_counter[HW_MIB_ifInRangeLengthErrors];
+
+//  unsigned long   rx_dropped;     /* no space in linux buffers    */
+	dev->stats.collisions = vptr->mib_counter[HW_MIB_ifTxEtherCollisions];
+	/* detailed rx_errors: */
+//  unsigned long   rx_length_errors;
+//  unsigned long   rx_over_errors;     /* receiver ring buff overflow  */
+	dev->stats.rx_crc_errors = vptr->mib_counter[HW_MIB_ifRxPktCRCE];
+//  unsigned long   rx_frame_errors;    /* recv'd frame alignment error */
+//  unsigned long   rx_fifo_errors;     /* recv'r fifo overrun      */
+//  unsigned long   rx_missed_errors;   /* receiver missed packet   */
+
+	/* detailed tx_errors */
+//  unsigned long   tx_fifo_errors;
+
+	return &dev->stats;
 }
 
 /**
@@ -2033,7 +2436,6 @@ static void velocity_shutdown(struct velocity_info *vptr)
  *	Callback from the network layer when the velocity is being
  *	deactivated by the network layer
  */
-
 static int velocity_close(struct net_device *dev)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
@@ -2063,7 +2465,6 @@ static int velocity_close(struct net_device *dev)
  *	Called by the networ layer to request a packet is queued to
  *	the velocity. Returns zero on success.
  */
-
 static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
@@ -2075,7 +2476,6 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 	__le16 len;
 	int index;
 
-
 	if (skb_padto(skb, ETH_ZLEN))
 		goto out;
 	pktlen = max_t(unsigned int, skb->len, ETH_ZLEN);
@@ -2145,782 +2545,535 @@ out:
 	return NETDEV_TX_OK;
 }
 
+
+static const struct net_device_ops velocity_netdev_ops = {
+	.ndo_open		= velocity_open,
+	.ndo_stop		= velocity_close,
+	.ndo_start_xmit		= velocity_xmit,
+	.ndo_get_stats		= velocity_get_stats,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_set_multicast_list	= velocity_set_multi,
+	.ndo_change_mtu		= velocity_change_mtu,
+	.ndo_do_ioctl		= velocity_ioctl,
+	.ndo_vlan_rx_add_vid	= velocity_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= velocity_vlan_rx_kill_vid,
+	.ndo_vlan_rx_register	= velocity_vlan_rx_register,
+};
+
 /**
- *	velocity_intr		-	interrupt callback
- *	@irq: interrupt number
- *	@dev_instance: interrupting device
+ *	velocity_init_info	-	init private data
+ *	@pdev: PCI device
+ *	@vptr: Velocity info
+ *	@info: Board type
  *
- *	Called whenever an interrupt is generated by the velocity
- *	adapter IRQ line. We may not be the source of the interrupt
- *	and need to identify initially if we are, and if not exit as
- *	efficiently as possible.
+ *	Set up the initial velocity_info struct for the device that has been
+ *	discovered.
  */
-
-static irqreturn_t velocity_intr(int irq, void *dev_instance)
+static void __devinit velocity_init_info(struct pci_dev *pdev,
+					 struct velocity_info *vptr,
+					 const struct velocity_info_tbl *info)
 {
-	struct net_device *dev = dev_instance;
-	struct velocity_info *vptr = netdev_priv(dev);
-	u32 isr_status;
-	int max_count = 0;
-
-
-	spin_lock(&vptr->lock);
-	isr_status = mac_read_isr(vptr->mac_regs);
-
-	/* Not us ? */
-	if (isr_status == 0) {
-		spin_unlock(&vptr->lock);
-		return IRQ_NONE;
-	}
-
-	mac_disable_int(vptr->mac_regs);
-
-	/*
-	 *	Keep processing the ISR until we have completed
-	 *	processing and the isr_status becomes zero
-	 */
-
-	while (isr_status != 0) {
-		mac_write_isr(vptr->mac_regs, isr_status);
-		if (isr_status & (~(ISR_PRXI | ISR_PPRXI | ISR_PTXI | ISR_PPTXI)))
-			velocity_error(vptr, isr_status);
-		if (isr_status & (ISR_PRXI | ISR_PPRXI))
-			max_count += velocity_rx_srv(vptr, isr_status);
-		if (isr_status & (ISR_PTXI | ISR_PPTXI))
-			max_count += velocity_tx_srv(vptr, isr_status);
-		isr_status = mac_read_isr(vptr->mac_regs);
-		if (max_count > vptr->options.int_works) {
-			printk(KERN_WARNING "%s: excessive work at interrupt.\n",
-				dev->name);
-			max_count = 0;
-		}
-	}
-	spin_unlock(&vptr->lock);
-	mac_enable_int(vptr->mac_regs);
-	return IRQ_HANDLED;
+	memset(vptr, 0, sizeof(struct velocity_info));
 
+	vptr->pdev = pdev;
+	vptr->chip_id = info->chip_id;
+	vptr->tx.numq = info->txqueue;
+	vptr->multicast_limit = MCAM_SIZE;
+	spin_lock_init(&vptr->lock);
+	INIT_LIST_HEAD(&vptr->list);
 }
 
-
 /**
- *	velocity_set_multi	-	filter list change callback
- *	@dev: network device
+ *	velocity_get_pci_info	-	retrieve PCI info for device
+ *	@vptr: velocity device
+ *	@pdev: PCI device it matches
  *
- *	Called by the network layer when the filter lists need to change
- *	for a velocity adapter. Reload the CAMs with the new address
- *	filter ruleset.
+ *	Retrieve the PCI configuration space data that interests us from
+ *	the kernel PCI layer
  */
-
-static void velocity_set_multi(struct net_device *dev)
+static int __devinit velocity_get_pci_info(struct velocity_info *vptr, struct pci_dev *pdev)
 {
-	struct velocity_info *vptr = netdev_priv(dev);
-	struct mac_regs __iomem *regs = vptr->mac_regs;
-	u8 rx_mode;
-	int i;
-	struct dev_mc_list *mclist;
+	vptr->rev_id = pdev->revision;
 
-	if (dev->flags & IFF_PROMISC) {	/* Set promiscuous. */
-		writel(0xffffffff, &regs->MARCAM[0]);
-		writel(0xffffffff, &regs->MARCAM[4]);
-		rx_mode = (RCR_AM | RCR_AB | RCR_PROM);
-	} else if ((dev->mc_count > vptr->multicast_limit)
-		   || (dev->flags & IFF_ALLMULTI)) {
-		writel(0xffffffff, &regs->MARCAM[0]);
-		writel(0xffffffff, &regs->MARCAM[4]);
-		rx_mode = (RCR_AM | RCR_AB);
-	} else {
-		int offset = MCAM_SIZE - vptr->multicast_limit;
-		mac_get_cam_mask(regs, vptr->mCAMmask);
+	pci_set_master(pdev);
 
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count; i++, mclist = mclist->next) {
-			mac_set_cam(regs, i + offset, mclist->dmi_addr);
-			vptr->mCAMmask[(offset + i) / 8] |= 1 << ((offset + i) & 7);
-		}
+	vptr->ioaddr = pci_resource_start(pdev, 0);
+	vptr->memaddr = pci_resource_start(pdev, 1);
 
-		mac_set_cam_mask(regs, vptr->mCAMmask);
-		rx_mode = RCR_AM | RCR_AB | RCR_AP;
+	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_IO)) {
+		dev_err(&pdev->dev,
+			   "region #0 is not an I/O resource, aborting.\n");
+		return -EINVAL;
 	}
-	if (dev->mtu > 1500)
-		rx_mode |= RCR_AL;
 
-	BYTE_REG_BITS_ON(rx_mode, &regs->RCR);
+	if ((pci_resource_flags(pdev, 1) & IORESOURCE_IO)) {
+		dev_err(&pdev->dev,
+			   "region #1 is an I/O resource, aborting.\n");
+		return -EINVAL;
+	}
 
+	if (pci_resource_len(pdev, 1) < VELOCITY_IO_SIZE) {
+		dev_err(&pdev->dev, "region #1 is too small.\n");
+		return -EINVAL;
+	}
+	vptr->pdev = pdev;
+
+	return 0;
 }
 
 /**
- *	velocity_get_status	-	statistics callback
- *	@dev: network device
+ *	velocity_print_info	-	per driver data
+ *	@vptr: velocity
  *
- *	Callback from the network layer to allow driver statistics
- *	to be resynchronized with hardware collected state. In the
- *	case of the velocity we need to pull the MIB counters from
- *	the hardware into the counters before letting the network
- *	layer display them.
+ *	Print per driver data as the kernel driver finds Velocity
+ *	hardware
  */
-
-static struct net_device_stats *velocity_get_stats(struct net_device *dev)
+static void __devinit velocity_print_info(struct velocity_info *vptr)
 {
-	struct velocity_info *vptr = netdev_priv(dev);
-
-	/* If the hardware is down, don't touch MII */
-	if (!netif_running(dev))
-		return &dev->stats;
-
-	spin_lock_irq(&vptr->lock);
-	velocity_update_hw_mibs(vptr);
-	spin_unlock_irq(&vptr->lock);
-
-	dev->stats.rx_packets = vptr->mib_counter[HW_MIB_ifRxAllPkts];
-	dev->stats.rx_errors = vptr->mib_counter[HW_MIB_ifRxErrorPkts];
-	dev->stats.rx_length_errors = vptr->mib_counter[HW_MIB_ifInRangeLengthErrors];
-
-//  unsigned long   rx_dropped;     /* no space in linux buffers    */
-	dev->stats.collisions = vptr->mib_counter[HW_MIB_ifTxEtherCollisions];
-	/* detailed rx_errors: */
-//  unsigned long   rx_length_errors;
-//  unsigned long   rx_over_errors;     /* receiver ring buff overflow  */
-	dev->stats.rx_crc_errors = vptr->mib_counter[HW_MIB_ifRxPktCRCE];
-//  unsigned long   rx_frame_errors;    /* recv'd frame alignment error */
-//  unsigned long   rx_fifo_errors;     /* recv'r fifo overrun      */
-//  unsigned long   rx_missed_errors;   /* receiver missed packet   */
-
-	/* detailed tx_errors */
-//  unsigned long   tx_fifo_errors;
+	struct net_device *dev = vptr->dev;
 
-	return &dev->stats;
+	printk(KERN_INFO "%s: %s\n", dev->name, get_chip_name(vptr->chip_id));
+	printk(KERN_INFO "%s: Ethernet Address: %2.2X:%2.2X:%2.2X:%2.2X:%2.2X:%2.2X\n",
+		dev->name,
+		dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
+		dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
 }
 
-
-/**
- *	velocity_ioctl		-	ioctl entry point
- *	@dev: network device
- *	@rq: interface request ioctl
- *	@cmd: command code
- *
- *	Called when the user issues an ioctl request to the network
- *	device in question. The velocity interface supports MII.
- */
-
-static int velocity_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+static u32 velocity_get_link(struct net_device *dev)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
-	int ret;
-
-	/* If we are asked for information and the device is power
-	   saving then we need to bring the device back up to talk to it */
-
-	if (!netif_running(dev))
-		pci_set_power_state(vptr->pdev, PCI_D0);
-
-	switch (cmd) {
-	case SIOCGMIIPHY:	/* Get address of MII PHY in use. */
-	case SIOCGMIIREG:	/* Read MII PHY register. */
-	case SIOCSMIIREG:	/* Write to MII PHY register. */
-		ret = velocity_mii_ioctl(dev, rq, cmd);
-		break;
-
-	default:
-		ret = -EOPNOTSUPP;
-	}
-	if (!netif_running(dev))
-		pci_set_power_state(vptr->pdev, PCI_D3hot);
-
-
-	return ret;
+	struct mac_regs __iomem *regs = vptr->mac_regs;
+	return BYTE_REG_BITS_IS_ON(PHYSR0_LINKGD, &regs->PHYSR0) ? 1 : 0;
 }
 
-/*
- *	Definition for our device driver. The PCI layer interface
- *	uses this to handle all our card discover and plugging
- */
-
-static struct pci_driver velocity_driver = {
-      .name	= VELOCITY_NAME,
-      .id_table	= velocity_id_table,
-      .probe	= velocity_found1,
-      .remove	= __devexit_p(velocity_remove1),
-#ifdef CONFIG_PM
-      .suspend	= velocity_suspend,
-      .resume	= velocity_resume,
-#endif
-};
 
 /**
- *	velocity_init_module	-	load time function
+ *	velocity_found1		-	set up discovered velocity card
+ *	@pdev: PCI device
+ *	@ent: PCI device table entry that matched
  *
- *	Called when the velocity module is loaded. The PCI driver
- *	is registered with the PCI layer, and in turn will call
- *	the probe functions for each velocity adapter installed
- *	in the system.
+ *	Configure a discovered adapter from scratch. Return a negative
+ *	errno error code on failure paths.
  */
-
-static int __init velocity_init_module(void)
+static int __devinit velocity_found1(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
-	int ret;
+	static int first = 1;
+	struct net_device *dev;
+	int i;
+	const char *drv_string;
+	const struct velocity_info_tbl *info = &chip_info_table[ent->driver_data];
+	struct velocity_info *vptr;
+	struct mac_regs __iomem *regs;
+	int ret = -ENOMEM;
 
-	velocity_register_notifier();
-	ret = pci_register_driver(&velocity_driver);
-	if (ret < 0)
-		velocity_unregister_notifier();
-	return ret;
-}
+	/* FIXME: this driver, like almost all other ethernet drivers,
+	 * can support more than MAX_UNITS.
+	 */
+	if (velocity_nics >= MAX_UNITS) {
+		dev_notice(&pdev->dev, "already found %d NICs.\n",
+			   velocity_nics);
+		return -ENODEV;
+	}
 
-/**
- *	velocity_cleanup	-	module unload
- *
- *	When the velocity hardware is unloaded this function is called.
- *	It will clean up the notifiers and the unregister the PCI
- *	driver interface for this hardware. This in turn cleans up
- *	all discovered interfaces before returning from the function
- */
+	dev = alloc_etherdev(sizeof(struct velocity_info));
+	if (!dev) {
+		dev_err(&pdev->dev, "allocate net device failed.\n");
+		goto out;
+	}
 
-static void __exit velocity_cleanup_module(void)
-{
-	velocity_unregister_notifier();
-	pci_unregister_driver(&velocity_driver);
-}
+	/* Chain it all together */
 
-module_init(velocity_init_module);
-module_exit(velocity_cleanup_module);
+	SET_NETDEV_DEV(dev, &pdev->dev);
+	vptr = netdev_priv(dev);
 
 
-/*
- * MII access , media link mode setting functions
- */
+	if (first) {
+		printk(KERN_INFO "%s Ver. %s\n",
+			VELOCITY_FULL_DRV_NAM, VELOCITY_VERSION);
+		printk(KERN_INFO "Copyright (c) 2002, 2003 VIA Networking Technologies, Inc.\n");
+		printk(KERN_INFO "Copyright (c) 2004 Red Hat Inc.\n");
+		first = 0;
+	}
 
+	velocity_init_info(pdev, vptr, info);
 
-/**
- *	mii_init	-	set up MII
- *	@vptr: velocity adapter
- *	@mii_status:  links tatus
- *
- *	Set up the PHY for the current link state.
- */
+	vptr->dev = dev;
 
-static void mii_init(struct velocity_info *vptr, u32 mii_status)
-{
-	u16 BMCR;
+	dev->irq = pdev->irq;
 
-	switch (PHYID_GET_PHY_ID(vptr->phy_id)) {
-	case PHYID_CICADA_CS8201:
-		/*
-		 *	Reset to hardware default
-		 */
-		MII_REG_BITS_OFF((ANAR_ASMDIR | ANAR_PAUSE), MII_REG_ANAR, vptr->mac_regs);
-		/*
-		 *	Turn on ECHODIS bit in NWay-forced full mode and turn it
-		 *	off it in NWay-forced half mode for NWay-forced v.s.
-		 *	legacy-forced issue.
-		 */
-		if (vptr->mii_status & VELOCITY_DUPLEX_FULL)
-			MII_REG_BITS_ON(TCSR_ECHODIS, MII_REG_TCSR, vptr->mac_regs);
-		else
-			MII_REG_BITS_OFF(TCSR_ECHODIS, MII_REG_TCSR, vptr->mac_regs);
-		/*
-		 *	Turn on Link/Activity LED enable bit for CIS8201
-		 */
-		MII_REG_BITS_ON(PLED_LALBE, MII_REG_PLED, vptr->mac_regs);
-		break;
-	case PHYID_VT3216_32BIT:
-	case PHYID_VT3216_64BIT:
-		/*
-		 *	Reset to hardware default
-		 */
-		MII_REG_BITS_ON((ANAR_ASMDIR | ANAR_PAUSE), MII_REG_ANAR, vptr->mac_regs);
-		/*
-		 *	Turn on ECHODIS bit in NWay-forced full mode and turn it
-		 *	off it in NWay-forced half mode for NWay-forced v.s.
-		 *	legacy-forced issue
-		 */
-		if (vptr->mii_status & VELOCITY_DUPLEX_FULL)
-			MII_REG_BITS_ON(TCSR_ECHODIS, MII_REG_TCSR, vptr->mac_regs);
-		else
-			MII_REG_BITS_OFF(TCSR_ECHODIS, MII_REG_TCSR, vptr->mac_regs);
-		break;
+	ret = pci_enable_device(pdev);
+	if (ret < 0)
+		goto err_free_dev;
 
-	case PHYID_MARVELL_1000:
-	case PHYID_MARVELL_1000S:
-		/*
-		 *	Assert CRS on Transmit
-		 */
-		MII_REG_BITS_ON(PSCR_ACRSTX, MII_REG_PSCR, vptr->mac_regs);
-		/*
-		 *	Reset to hardware default
-		 */
-		MII_REG_BITS_ON((ANAR_ASMDIR | ANAR_PAUSE), MII_REG_ANAR, vptr->mac_regs);
-		break;
-	default:
-		;
-	}
-	velocity_mii_read(vptr->mac_regs, MII_REG_BMCR, &BMCR);
-	if (BMCR & BMCR_ISO) {
-		BMCR &= ~BMCR_ISO;
-		velocity_mii_write(vptr->mac_regs, MII_REG_BMCR, BMCR);
+	ret = velocity_get_pci_info(vptr, pdev);
+	if (ret < 0) {
+		/* error message already printed */
+		goto err_disable;
 	}
-}
 
-/**
- *	safe_disable_mii_autopoll	-	autopoll off
- *	@regs: velocity registers
- *
- *	Turn off the autopoll and wait for it to disable on the chip
- */
-
-static void safe_disable_mii_autopoll(struct mac_regs __iomem *regs)
-{
-	u16 ww;
-
-	/*  turn off MAUTO */
-	writeb(0, &regs->MIICR);
-	for (ww = 0; ww < W_MAX_TIMEOUT; ww++) {
-		udelay(1);
-		if (BYTE_REG_BITS_IS_ON(MIISR_MIDLE, &regs->MIISR))
-			break;
+	ret = pci_request_regions(pdev, VELOCITY_NAME);
+	if (ret < 0) {
+		dev_err(&pdev->dev, "No PCI resources.\n");
+		goto err_disable;
 	}
-}
 
-/**
- *	enable_mii_autopoll	-	turn on autopolling
- *	@regs: velocity registers
- *
- *	Enable the MII link status autopoll feature on the Velocity
- *	hardware. Wait for it to enable.
- */
-
-static void enable_mii_autopoll(struct mac_regs __iomem *regs)
-{
-	int ii;
+	regs = ioremap(vptr->memaddr, VELOCITY_IO_SIZE);
+	if (regs == NULL) {
+		ret = -EIO;
+		goto err_release_res;
+	}
 
-	writeb(0, &(regs->MIICR));
-	writeb(MIIADR_SWMPL, &regs->MIIADR);
+	vptr->mac_regs = regs;
 
-	for (ii = 0; ii < W_MAX_TIMEOUT; ii++) {
-		udelay(1);
-		if (BYTE_REG_BITS_IS_ON(MIISR_MIDLE, &regs->MIISR))
-			break;
-	}
+	mac_wol_reset(regs);
 
-	writeb(MIICR_MAUTO, &regs->MIICR);
+	dev->base_addr = vptr->ioaddr;
 
-	for (ii = 0; ii < W_MAX_TIMEOUT; ii++) {
-		udelay(1);
-		if (!BYTE_REG_BITS_IS_ON(MIISR_MIDLE, &regs->MIISR))
-			break;
-	}
+	for (i = 0; i < 6; i++)
+		dev->dev_addr[i] = readb(&regs->PAR[i]);
 
-}
 
-/**
- *	velocity_mii_read	-	read MII data
- *	@regs: velocity registers
- *	@index: MII register index
- *	@data: buffer for received data
- *
- *	Perform a single read of an MII 16bit register. Returns zero
- *	on success or -ETIMEDOUT if the PHY did not respond.
- */
+	drv_string = dev_driver_string(&pdev->dev);
 
-static int velocity_mii_read(struct mac_regs __iomem *regs, u8 index, u16 *data)
-{
-	u16 ww;
+	velocity_get_options(&vptr->options, velocity_nics, drv_string);
 
 	/*
-	 *	Disable MIICR_MAUTO, so that mii addr can be set normally
+	 *	Mask out the options cannot be set to the chip
 	 */
-	safe_disable_mii_autopoll(regs);
 
-	writeb(index, &regs->MIIADR);
-
-	BYTE_REG_BITS_ON(MIICR_RCMD, &regs->MIICR);
+	vptr->options.flags &= info->flags;
 
-	for (ww = 0; ww < W_MAX_TIMEOUT; ww++) {
-		if (!(readb(&regs->MIICR) & MIICR_RCMD))
-			break;
-	}
+	/*
+	 *	Enable the chip specified capbilities
+	 */
 
-	*data = readw(&regs->MIIDATA);
+	vptr->flags = vptr->options.flags | (info->flags & 0xFF000000UL);
 
-	enable_mii_autopoll(regs);
-	if (ww == W_MAX_TIMEOUT)
-		return -ETIMEDOUT;
-	return 0;
-}
+	vptr->wol_opts = vptr->options.wol_opts;
+	vptr->flags |= VELOCITY_FLAGS_WOL_ENABLED;
 
-/**
- *	velocity_mii_write	-	write MII data
- *	@regs: velocity registers
- *	@index: MII register index
- *	@data: 16bit data for the MII register
- *
- *	Perform a single write to an MII 16bit register. Returns zero
- *	on success or -ETIMEDOUT if the PHY did not respond.
- */
+	vptr->phy_id = MII_GET_PHY_ID(vptr->mac_regs);
 
-static int velocity_mii_write(struct mac_regs __iomem *regs, u8 mii_addr, u16 data)
-{
-	u16 ww;
+	dev->irq = pdev->irq;
+	dev->netdev_ops = &velocity_netdev_ops;
+	dev->ethtool_ops = &velocity_ethtool_ops;
 
-	/*
-	 *	Disable MIICR_MAUTO, so that mii addr can be set normally
-	 */
-	safe_disable_mii_autopoll(regs);
+	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER |
+		NETIF_F_HW_VLAN_RX;
 
-	/* MII reg offset */
-	writeb(mii_addr, &regs->MIIADR);
-	/* set MII data */
-	writew(data, &regs->MIIDATA);
+	if (vptr->flags & VELOCITY_FLAGS_TX_CSUM)
+		dev->features |= NETIF_F_IP_CSUM;
 
-	/* turn on MIICR_WCMD */
-	BYTE_REG_BITS_ON(MIICR_WCMD, &regs->MIICR);
+	ret = register_netdev(dev);
+	if (ret < 0)
+		goto err_iounmap;
 
-	/* W_MAX_TIMEOUT is the timeout period */
-	for (ww = 0; ww < W_MAX_TIMEOUT; ww++) {
-		udelay(5);
-		if (!(readb(&regs->MIICR) & MIICR_WCMD))
-			break;
+	if (!velocity_get_link(dev)) {
+		netif_carrier_off(dev);
+		vptr->mii_status |= VELOCITY_LINK_FAIL;
 	}
-	enable_mii_autopoll(regs);
 
-	if (ww == W_MAX_TIMEOUT)
-		return -ETIMEDOUT;
-	return 0;
-}
+	velocity_print_info(vptr);
+	pci_set_drvdata(pdev, dev);
 
-/**
- *	velocity_get_opt_media_mode	-	get media selection
- *	@vptr: velocity adapter
- *
- *	Get the media mode stored in EEPROM or module options and load
- *	mii_status accordingly. The requested link state information
- *	is also returned.
- */
+	/* and leave the chip powered down */
 
-static u32 velocity_get_opt_media_mode(struct velocity_info *vptr)
-{
-	u32 status = 0;
+	pci_set_power_state(pdev, PCI_D3hot);
+#ifdef CONFIG_PM
+	{
+		unsigned long flags;
 
-	switch (vptr->options.spd_dpx) {
-	case SPD_DPX_AUTO:
-		status = VELOCITY_AUTONEG_ENABLE;
-		break;
-	case SPD_DPX_100_FULL:
-		status = VELOCITY_SPEED_100 | VELOCITY_DUPLEX_FULL;
-		break;
-	case SPD_DPX_10_FULL:
-		status = VELOCITY_SPEED_10 | VELOCITY_DUPLEX_FULL;
-		break;
-	case SPD_DPX_100_HALF:
-		status = VELOCITY_SPEED_100;
-		break;
-	case SPD_DPX_10_HALF:
-		status = VELOCITY_SPEED_10;
-		break;
+		spin_lock_irqsave(&velocity_dev_list_lock, flags);
+		list_add(&vptr->list, &velocity_dev_list);
+		spin_unlock_irqrestore(&velocity_dev_list_lock, flags);
 	}
-	vptr->mii_status = status;
-	return status;
-}
-
-/**
- *	mii_set_auto_on		-	autonegotiate on
- *	@vptr: velocity
- *
- *	Enable autonegotation on this interface
- */
+#endif
+	velocity_nics++;
+out:
+	return ret;
 
-static void mii_set_auto_on(struct velocity_info *vptr)
-{
-	if (MII_REG_BITS_IS_ON(BMCR_AUTO, MII_REG_BMCR, vptr->mac_regs))
-		MII_REG_BITS_ON(BMCR_REAUTO, MII_REG_BMCR, vptr->mac_regs);
-	else
-		MII_REG_BITS_ON(BMCR_AUTO, MII_REG_BMCR, vptr->mac_regs);
+err_iounmap:
+	iounmap(regs);
+err_release_res:
+	pci_release_regions(pdev);
+err_disable:
+	pci_disable_device(pdev);
+err_free_dev:
+	free_netdev(dev);
+	goto out;
 }
 
 
-/*
-static void mii_set_auto_off(struct velocity_info *vptr)
-{
-    MII_REG_BITS_OFF(BMCR_AUTO, MII_REG_BMCR, vptr->mac_regs);
-}
-*/
-
 /**
- *	set_mii_flow_control	-	flow control setup
- *	@vptr: velocity interface
+ *	wol_calc_crc		-	WOL CRC
+ *	@pattern: data pattern
+ *	@mask_pattern: mask
  *
- *	Set up the flow control on this interface according to
- *	the supplied user/eeprom options.
+ *	Compute the wake on lan crc hashes for the packet header
+ *	we are interested in.
  */
-
-static void set_mii_flow_control(struct velocity_info *vptr)
+static u16 wol_calc_crc(int size, u8 *pattern, u8 *mask_pattern)
 {
-	/*Enable or Disable PAUSE in ANAR */
-	switch (vptr->options.flow_cntl) {
-	case FLOW_CNTL_TX:
-		MII_REG_BITS_OFF(ANAR_PAUSE, MII_REG_ANAR, vptr->mac_regs);
-		MII_REG_BITS_ON(ANAR_ASMDIR, MII_REG_ANAR, vptr->mac_regs);
-		break;
+	u16 crc = 0xFFFF;
+	u8 mask;
+	int i, j;
 
-	case FLOW_CNTL_RX:
-		MII_REG_BITS_ON(ANAR_PAUSE, MII_REG_ANAR, vptr->mac_regs);
-		MII_REG_BITS_ON(ANAR_ASMDIR, MII_REG_ANAR, vptr->mac_regs);
-		break;
+	for (i = 0; i < size; i++) {
+		mask = mask_pattern[i];
 
-	case FLOW_CNTL_TX_RX:
-		MII_REG_BITS_ON(ANAR_PAUSE, MII_REG_ANAR, vptr->mac_regs);
-		MII_REG_BITS_ON(ANAR_ASMDIR, MII_REG_ANAR, vptr->mac_regs);
-		break;
+		/* Skip this loop if the mask equals to zero */
+		if (mask == 0x00)
+			continue;
 
-	case FLOW_CNTL_DISABLE:
-		MII_REG_BITS_OFF(ANAR_PAUSE, MII_REG_ANAR, vptr->mac_regs);
-		MII_REG_BITS_OFF(ANAR_ASMDIR, MII_REG_ANAR, vptr->mac_regs);
-		break;
-	default:
-		break;
+		for (j = 0; j < 8; j++) {
+			if ((mask & 0x01) == 0) {
+				mask >>= 1;
+				continue;
+			}
+			mask >>= 1;
+			crc = crc_ccitt(crc, &(pattern[i * 8 + j]), 1);
+		}
 	}
+	/*	Finally, invert the result once to get the correct data */
+	crc = ~crc;
+	return bitrev32(crc) >> 16;
 }
 
 /**
- *	velocity_set_media_mode		-	set media mode
- *	@mii_status: old MII link state
+ *	velocity_set_wol	-	set up for wake on lan
+ *	@vptr: velocity to set WOL status on
  *
- *	Check the media link state and configure the flow control
- *	PHY and also velocity hardware setup accordingly. In particular
- *	we need to set up CD polling and frame bursting.
+ *	Set a card up for wake on lan either by unicast or by
+ *	ARP packet.
+ *
+ *	FIXME: check static buffer is safe here
  */
-
-static int velocity_set_media_mode(struct velocity_info *vptr, u32 mii_status)
+static int velocity_set_wol(struct velocity_info *vptr)
 {
-	u32 curr_status;
 	struct mac_regs __iomem *regs = vptr->mac_regs;
+	static u8 buf[256];
+	int i;
 
-	vptr->mii_status = mii_check_media_mode(vptr->mac_regs);
-	curr_status = vptr->mii_status & (~VELOCITY_LINK_FAIL);
+	static u32 mask_pattern[2][4] = {
+		{0x00203000, 0x000003C0, 0x00000000, 0x0000000}, /* ARP */
+		{0xfffff000, 0xffffffff, 0xffffffff, 0x000ffff}	 /* Magic Packet */
+	};
 
-	/* Set mii link status */
-	set_mii_flow_control(vptr);
+	writew(0xFFFF, &regs->WOLCRClr);
+	writeb(WOLCFG_SAB | WOLCFG_SAM, &regs->WOLCFGSet);
+	writew(WOLCR_MAGIC_EN, &regs->WOLCRSet);
 
 	/*
-	   Check if new status is consisent with current status
-	   if (((mii_status & curr_status) & VELOCITY_AUTONEG_ENABLE)
-	   || (mii_status==curr_status)) {
-	   vptr->mii_status=mii_check_media_mode(vptr->mac_regs);
-	   vptr->mii_status=check_connection_type(vptr->mac_regs);
-	   VELOCITY_PRT(MSG_LEVEL_INFO, "Velocity link no change\n");
-	   return 0;
-	   }
+	   if (vptr->wol_opts & VELOCITY_WOL_PHY)
+	   writew((WOLCR_LINKON_EN|WOLCR_LINKOFF_EN), &regs->WOLCRSet);
 	 */
 
-	if (PHYID_GET_PHY_ID(vptr->phy_id) == PHYID_CICADA_CS8201)
-		MII_REG_BITS_ON(AUXCR_MDPPS, MII_REG_AUXCR, vptr->mac_regs);
+	if (vptr->wol_opts & VELOCITY_WOL_UCAST)
+		writew(WOLCR_UNICAST_EN, &regs->WOLCRSet);
 
-	/*
-	 *	If connection type is AUTO
-	 */
-	if (mii_status & VELOCITY_AUTONEG_ENABLE) {
-		VELOCITY_PRT(MSG_LEVEL_INFO, "Velocity is AUTO mode\n");
-		/* clear force MAC mode bit */
-		BYTE_REG_BITS_OFF(CHIPGCR_FCMODE, &regs->CHIPGCR);
-		/* set duplex mode of MAC according to duplex mode of MII */
-		MII_REG_BITS_ON(ANAR_TXFD | ANAR_TX | ANAR_10FD | ANAR_10, MII_REG_ANAR, vptr->mac_regs);
-		MII_REG_BITS_ON(G1000CR_1000FD | G1000CR_1000, MII_REG_G1000CR, vptr->mac_regs);
-		MII_REG_BITS_ON(BMCR_SPEED1G, MII_REG_BMCR, vptr->mac_regs);
+	if (vptr->wol_opts & VELOCITY_WOL_ARP) {
+		struct arp_packet *arp = (struct arp_packet *) buf;
+		u16 crc;
+		memset(buf, 0, sizeof(struct arp_packet) + 7);
 
-		/* enable AUTO-NEGO mode */
-		mii_set_auto_on(vptr);
-	} else {
-		u16 ANAR;
-		u8 CHIPGCR;
+		for (i = 0; i < 4; i++)
+			writel(mask_pattern[0][i], &regs->ByteMask[0][i]);
 
-		/*
-		 * 1. if it's 3119, disable frame bursting in halfduplex mode
-		 *    and enable it in fullduplex mode
-		 * 2. set correct MII/GMII and half/full duplex mode in CHIPGCR
-		 * 3. only enable CD heart beat counter in 10HD mode
-		 */
+		arp->type = htons(ETH_P_ARP);
+		arp->ar_op = htons(1);
 
-		/* set force MAC mode bit */
-		BYTE_REG_BITS_ON(CHIPGCR_FCMODE, &regs->CHIPGCR);
+		memcpy(arp->ar_tip, vptr->ip_addr, 4);
 
-		CHIPGCR = readb(&regs->CHIPGCR);
-		CHIPGCR &= ~CHIPGCR_FCGMII;
+		crc = wol_calc_crc((sizeof(struct arp_packet) + 7) / 8, buf,
+				(u8 *) & mask_pattern[0][0]);
 
-		if (mii_status & VELOCITY_DUPLEX_FULL) {
-			CHIPGCR |= CHIPGCR_FCFDX;
-			writeb(CHIPGCR, &regs->CHIPGCR);
-			VELOCITY_PRT(MSG_LEVEL_INFO, "set Velocity to forced full mode\n");
-			if (vptr->rev_id < REV_ID_VT3216_A0)
-				BYTE_REG_BITS_OFF(TCR_TB2BDIS, &regs->TCR);
-		} else {
-			CHIPGCR &= ~CHIPGCR_FCFDX;
-			VELOCITY_PRT(MSG_LEVEL_INFO, "set Velocity to forced half mode\n");
-			writeb(CHIPGCR, &regs->CHIPGCR);
-			if (vptr->rev_id < REV_ID_VT3216_A0)
-				BYTE_REG_BITS_ON(TCR_TB2BDIS, &regs->TCR);
-		}
+		writew(crc, &regs->PatternCRC[0]);
+		writew(WOLCR_ARP_EN, &regs->WOLCRSet);
+	}
+
+	BYTE_REG_BITS_ON(PWCFG_WOLTYPE, &regs->PWCFGSet);
+	BYTE_REG_BITS_ON(PWCFG_LEGACY_WOLEN, &regs->PWCFGSet);
+
+	writew(0x0FFF, &regs->WOLSRClr);
+
+	if (vptr->mii_status & VELOCITY_AUTONEG_ENABLE) {
+		if (PHYID_GET_PHY_ID(vptr->phy_id) == PHYID_CICADA_CS8201)
+			MII_REG_BITS_ON(AUXCR_MDPPS, MII_REG_AUXCR, vptr->mac_regs);
 
 		MII_REG_BITS_OFF(G1000CR_1000FD | G1000CR_1000, MII_REG_G1000CR, vptr->mac_regs);
+	}
 
-		if (!(mii_status & VELOCITY_DUPLEX_FULL) && (mii_status & VELOCITY_SPEED_10))
-			BYTE_REG_BITS_OFF(TESTCFG_HBDIS, &regs->TESTCFG);
-		else
-			BYTE_REG_BITS_ON(TESTCFG_HBDIS, &regs->TESTCFG);
+	if (vptr->mii_status & VELOCITY_SPEED_1000)
+		MII_REG_BITS_ON(BMCR_REAUTO, MII_REG_BMCR, vptr->mac_regs);
 
-		/* MII_REG_BITS_OFF(BMCR_SPEED1G, MII_REG_BMCR, vptr->mac_regs); */
-		velocity_mii_read(vptr->mac_regs, MII_REG_ANAR, &ANAR);
-		ANAR &= (~(ANAR_TXFD | ANAR_TX | ANAR_10FD | ANAR_10));
-		if (mii_status & VELOCITY_SPEED_100) {
-			if (mii_status & VELOCITY_DUPLEX_FULL)
-				ANAR |= ANAR_TXFD;
-			else
-				ANAR |= ANAR_TX;
-		} else {
-			if (mii_status & VELOCITY_DUPLEX_FULL)
-				ANAR |= ANAR_10FD;
-			else
-				ANAR |= ANAR_10;
-		}
-		velocity_mii_write(vptr->mac_regs, MII_REG_ANAR, ANAR);
-		/* enable AUTO-NEGO mode */
-		mii_set_auto_on(vptr);
-		/* MII_REG_BITS_ON(BMCR_AUTO, MII_REG_BMCR, vptr->mac_regs); */
+	BYTE_REG_BITS_ON(CHIPGCR_FCMODE, &regs->CHIPGCR);
+
+	{
+		u8 GCR;
+		GCR = readb(&regs->CHIPGCR);
+		GCR = (GCR & ~CHIPGCR_FCGMII) | CHIPGCR_FCFDX;
+		writeb(GCR, &regs->CHIPGCR);
 	}
-	/* vptr->mii_status=mii_check_media_mode(vptr->mac_regs); */
-	/* vptr->mii_status=check_connection_type(vptr->mac_regs); */
-	return VELOCITY_LINK_CHANGE;
+
+	BYTE_REG_BITS_OFF(ISR_PWEI, &regs->ISR);
+	/* Turn on SWPTAG just before entering power mode */
+	BYTE_REG_BITS_ON(STICKHW_SWPTAG, &regs->STICKHW);
+	/* Go to bed ..... */
+	BYTE_REG_BITS_ON((STICKHW_DS1 | STICKHW_DS0), &regs->STICKHW);
+
+	return 0;
 }
 
 /**
- *	mii_check_media_mode	-	check media state
- *	@regs: velocity registers
+ *	velocity_save_context	-	save registers
+ *	@vptr: velocity
+ *	@context: buffer for stored context
  *
- *	Check the current MII status and determine the link status
- *	accordingly
+ *	Retrieve the current configuration from the velocity hardware
+ *	and stash it in the context structure, for use by the context
+ *	restore functions. This allows us to save things we need across
+ *	power down states
  */
-
-static u32 mii_check_media_mode(struct mac_regs __iomem *regs)
+static void velocity_save_context(struct velocity_info *vptr, struct velocity_context *context)
 {
-	u32 status = 0;
-	u16 ANAR;
+	struct mac_regs __iomem *regs = vptr->mac_regs;
+	u16 i;
+	u8 __iomem *ptr = (u8 __iomem *)regs;
 
-	if (!MII_REG_BITS_IS_ON(BMSR_LNK, MII_REG_BMSR, regs))
-		status |= VELOCITY_LINK_FAIL;
+	for (i = MAC_REG_PAR; i < MAC_REG_CR0_CLR; i += 4)
+		*((u32 *) (context->mac_reg + i)) = readl(ptr + i);
 
-	if (MII_REG_BITS_IS_ON(G1000CR_1000FD, MII_REG_G1000CR, regs))
-		status |= VELOCITY_SPEED_1000 | VELOCITY_DUPLEX_FULL;
-	else if (MII_REG_BITS_IS_ON(G1000CR_1000, MII_REG_G1000CR, regs))
-		status |= (VELOCITY_SPEED_1000);
-	else {
-		velocity_mii_read(regs, MII_REG_ANAR, &ANAR);
-		if (ANAR & ANAR_TXFD)
-			status |= (VELOCITY_SPEED_100 | VELOCITY_DUPLEX_FULL);
-		else if (ANAR & ANAR_TX)
-			status |= VELOCITY_SPEED_100;
-		else if (ANAR & ANAR_10FD)
-			status |= (VELOCITY_SPEED_10 | VELOCITY_DUPLEX_FULL);
-		else
-			status |= (VELOCITY_SPEED_10);
-	}
+	for (i = MAC_REG_MAR; i < MAC_REG_TDCSR_CLR; i += 4)
+		*((u32 *) (context->mac_reg + i)) = readl(ptr + i);
 
-	if (MII_REG_BITS_IS_ON(BMCR_AUTO, MII_REG_BMCR, regs)) {
-		velocity_mii_read(regs, MII_REG_ANAR, &ANAR);
-		if ((ANAR & (ANAR_TXFD | ANAR_TX | ANAR_10FD | ANAR_10))
-		    == (ANAR_TXFD | ANAR_TX | ANAR_10FD | ANAR_10)) {
-			if (MII_REG_BITS_IS_ON(G1000CR_1000 | G1000CR_1000FD, MII_REG_G1000CR, regs))
-				status |= VELOCITY_AUTONEG_ENABLE;
-		}
-	}
+	for (i = MAC_REG_RDBASE_LO; i < MAC_REG_FIFO_TEST0; i += 4)
+		*((u32 *) (context->mac_reg + i)) = readl(ptr + i);
 
-	return status;
 }
 
-static u32 check_connection_type(struct mac_regs __iomem *regs)
-{
-	u32 status = 0;
-	u8 PHYSR0;
-	u16 ANAR;
-	PHYSR0 = readb(&regs->PHYSR0);
 
-	/*
-	   if (!(PHYSR0 & PHYSR0_LINKGD))
-	   status|=VELOCITY_LINK_FAIL;
-	 */
+static int velocity_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct velocity_info *vptr = netdev_priv(dev);
+	unsigned long flags;
 
-	if (PHYSR0 & PHYSR0_FDPX)
-		status |= VELOCITY_DUPLEX_FULL;
+	if (!netif_running(vptr->dev))
+		return 0;
 
-	if (PHYSR0 & PHYSR0_SPDG)
-		status |= VELOCITY_SPEED_1000;
-	else if (PHYSR0 & PHYSR0_SPD10)
-		status |= VELOCITY_SPEED_10;
-	else
-		status |= VELOCITY_SPEED_100;
+	netif_device_detach(vptr->dev);
 
-	if (MII_REG_BITS_IS_ON(BMCR_AUTO, MII_REG_BMCR, regs)) {
-		velocity_mii_read(regs, MII_REG_ANAR, &ANAR);
-		if ((ANAR & (ANAR_TXFD | ANAR_TX | ANAR_10FD | ANAR_10))
-		    == (ANAR_TXFD | ANAR_TX | ANAR_10FD | ANAR_10)) {
-			if (MII_REG_BITS_IS_ON(G1000CR_1000 | G1000CR_1000FD, MII_REG_G1000CR, regs))
-				status |= VELOCITY_AUTONEG_ENABLE;
-		}
+	spin_lock_irqsave(&vptr->lock, flags);
+	pci_save_state(pdev);
+#ifdef ETHTOOL_GWOL
+	if (vptr->flags & VELOCITY_FLAGS_WOL_ENABLED) {
+		velocity_get_ip(vptr);
+		velocity_save_context(vptr, &vptr->context);
+		velocity_shutdown(vptr);
+		velocity_set_wol(vptr);
+		pci_enable_wake(pdev, PCI_D3hot, 1);
+		pci_set_power_state(pdev, PCI_D3hot);
+	} else {
+		velocity_save_context(vptr, &vptr->context);
+		velocity_shutdown(vptr);
+		pci_disable_device(pdev);
+		pci_set_power_state(pdev, pci_choose_state(pdev, state));
 	}
-
-	return status;
+#else
+	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+#endif
+	spin_unlock_irqrestore(&vptr->lock, flags);
+	return 0;
 }
 
 /**
- *	enable_flow_control_ability	-	flow control
- *	@vptr: veloity to configure
+ *	velocity_restore_context	-	restore registers
+ *	@vptr: velocity
+ *	@context: buffer for stored context
  *
- *	Set up flow control according to the flow control options
- *	determined by the eeprom/configuration.
+ *	Reload the register configuration from the velocity context
+ *	created by velocity_save_context.
  */
-
-static void enable_flow_control_ability(struct velocity_info *vptr)
+static void velocity_restore_context(struct velocity_info *vptr, struct velocity_context *context)
 {
-
 	struct mac_regs __iomem *regs = vptr->mac_regs;
+	int i;
+	u8 __iomem *ptr = (u8 __iomem *)regs;
 
-	switch (vptr->options.flow_cntl) {
+	for (i = MAC_REG_PAR; i < MAC_REG_CR0_SET; i += 4)
+		writel(*((u32 *) (context->mac_reg + i)), ptr + i);
 
-	case FLOW_CNTL_DEFAULT:
-		if (BYTE_REG_BITS_IS_ON(PHYSR0_RXFLC, &regs->PHYSR0))
-			writel(CR0_FDXRFCEN, &regs->CR0Set);
-		else
-			writel(CR0_FDXRFCEN, &regs->CR0Clr);
+	/* Just skip cr0 */
+	for (i = MAC_REG_CR1_SET; i < MAC_REG_CR0_CLR; i++) {
+		/* Clear */
+		writeb(~(*((u8 *) (context->mac_reg + i))), ptr + i + 4);
+		/* Set */
+		writeb(*((u8 *) (context->mac_reg + i)), ptr + i);
+	}
 
-		if (BYTE_REG_BITS_IS_ON(PHYSR0_TXFLC, &regs->PHYSR0))
-			writel(CR0_FDXTFCEN, &regs->CR0Set);
-		else
-			writel(CR0_FDXTFCEN, &regs->CR0Clr);
-		break;
+	for (i = MAC_REG_MAR; i < MAC_REG_IMR; i += 4)
+		writel(*((u32 *) (context->mac_reg + i)), ptr + i);
 
-	case FLOW_CNTL_TX:
-		writel(CR0_FDXTFCEN, &regs->CR0Set);
-		writel(CR0_FDXRFCEN, &regs->CR0Clr);
-		break;
+	for (i = MAC_REG_RDBASE_LO; i < MAC_REG_FIFO_TEST0; i += 4)
+		writel(*((u32 *) (context->mac_reg + i)), ptr + i);
 
-	case FLOW_CNTL_RX:
-		writel(CR0_FDXRFCEN, &regs->CR0Set);
-		writel(CR0_FDXTFCEN, &regs->CR0Clr);
-		break;
+	for (i = MAC_REG_TDCSR_SET; i <= MAC_REG_RDCSR_SET; i++)
+		writeb(*((u8 *) (context->mac_reg + i)), ptr + i);
+}
 
-	case FLOW_CNTL_TX_RX:
-		writel(CR0_FDXTFCEN, &regs->CR0Set);
-		writel(CR0_FDXRFCEN, &regs->CR0Set);
-		break;
+static int velocity_resume(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct velocity_info *vptr = netdev_priv(dev);
+	unsigned long flags;
+	int i;
 
-	case FLOW_CNTL_DISABLE:
-		writel(CR0_FDXRFCEN, &regs->CR0Clr);
-		writel(CR0_FDXTFCEN, &regs->CR0Clr);
-		break;
+	if (!netif_running(vptr->dev))
+		return 0;
 
-	default:
-		break;
+	pci_set_power_state(pdev, PCI_D0);
+	pci_enable_wake(pdev, 0, 0);
+	pci_restore_state(pdev);
+
+	mac_wol_reset(vptr->mac_regs);
+
+	spin_lock_irqsave(&vptr->lock, flags);
+	velocity_restore_context(vptr, &vptr->context);
+	velocity_init_registers(vptr, VELOCITY_INIT_WOL);
+	mac_disable_int(vptr->mac_regs);
+
+	velocity_tx_srv(vptr, 0);
+
+	for (i = 0; i < vptr->tx.numq; i++) {
+		if (vptr->tx.used[i])
+			mac_tx_queue_wake(vptr->mac_regs, i);
 	}
 
+	mac_enable_int(vptr->mac_regs);
+	spin_unlock_irqrestore(&vptr->lock, flags);
+	netif_device_attach(vptr->dev);
+
+	return 0;
 }
 
 
+/*
+ *	Definition for our device driver. The PCI layer interface
+ *	uses this to handle all our card discover and plugging
+ */
+static struct pci_driver velocity_driver = {
+      .name	= VELOCITY_NAME,
+      .id_table	= velocity_id_table,
+      .probe	= velocity_found1,
+      .remove	= __devexit_p(velocity_remove1),
+#ifdef CONFIG_PM
+      .suspend	= velocity_suspend,
+      .resume	= velocity_resume,
+#endif
+};
+
+
 /**
  *	velocity_ethtool_up	-	pre hook for ethtool
  *	@dev: network device
@@ -2928,7 +3081,6 @@ static void enable_flow_control_ability(struct velocity_info *vptr)
  *	Called before an ethtool operation. We need to make sure the
  *	chip is out of D3 state before we poke at it.
  */
-
 static int velocity_ethtool_up(struct net_device *dev)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
@@ -2944,7 +3096,6 @@ static int velocity_ethtool_up(struct net_device *dev)
  *	Called after an ethtool operation. Restore the chip back to D3
  *	state if it isn't running.
  */
-
 static void velocity_ethtool_down(struct net_device *dev)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
@@ -3009,13 +3160,6 @@ static int velocity_set_settings(struct net_device *dev, struct ethtool_cmd *cmd
 	return ret;
 }
 
-static u32 velocity_get_link(struct net_device *dev)
-{
-	struct velocity_info *vptr = netdev_priv(dev);
-	struct mac_regs __iomem *regs = vptr->mac_regs;
-	return BYTE_REG_BITS_IS_ON(PHYSR0_LINKGD, &regs->PHYSR0) ? 1 : 0;
-}
-
 static void velocity_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
@@ -3094,331 +3238,88 @@ static const struct ethtool_ops velocity_ethtool_ops = {
 	.complete	=	velocity_ethtool_down
 };
 
-/**
- *	velocity_mii_ioctl		-	MII ioctl handler
- *	@dev: network device
- *	@ifr: the ifreq block for the ioctl
- *	@cmd: the command
- *
- *	Process MII requests made via ioctl from the network layer. These
- *	are used by tools like kudzu to interrogate the link state of the
- *	hardware
- */
+#ifdef CONFIG_PM
 
-static int velocity_mii_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+#ifdef CONFIG_INET
+static int velocity_netdev_event(struct notifier_block *nb, unsigned long notification, void *ptr)
 {
-	struct velocity_info *vptr = netdev_priv(dev);
-	struct mac_regs __iomem *regs = vptr->mac_regs;
+	struct in_ifaddr *ifa = (struct in_ifaddr *) ptr;
+	struct net_device *dev = ifa->ifa_dev->dev;
+	struct velocity_info *vptr;
 	unsigned long flags;
-	struct mii_ioctl_data *miidata = if_mii(ifr);
-	int err;
 
-	switch (cmd) {
-	case SIOCGMIIPHY:
-		miidata->phy_id = readb(&regs->MIIADR) & 0x1f;
-		break;
-	case SIOCGMIIREG:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-		if (velocity_mii_read(vptr->mac_regs, miidata->reg_num & 0x1f, &(miidata->val_out)) < 0)
-			return -ETIMEDOUT;
-		break;
-	case SIOCSMIIREG:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-		spin_lock_irqsave(&vptr->lock, flags);
-		err = velocity_mii_write(vptr->mac_regs, miidata->reg_num & 0x1f, miidata->val_in);
-		spin_unlock_irqrestore(&vptr->lock, flags);
-		check_connection_type(vptr->mac_regs);
-		if (err)
-			return err;
-		break;
-	default:
-		return -EOPNOTSUPP;
+	if (dev_net(dev) != &init_net)
+		return NOTIFY_DONE;
+
+	spin_lock_irqsave(&velocity_dev_list_lock, flags);
+	list_for_each_entry(vptr, &velocity_dev_list, list) {
+		if (vptr->dev == dev) {
+			velocity_get_ip(vptr);
+			break;
+		}
 	}
-	return 0;
-}
+	spin_unlock_irqrestore(&velocity_dev_list_lock, flags);
 
-#ifdef CONFIG_PM
+	return NOTIFY_DONE;
+}
+#endif	/* CONFIG_INET */
 
-/**
- *	velocity_save_context	-	save registers
- *	@vptr: velocity
- *	@context: buffer for stored context
- *
- *	Retrieve the current configuration from the velocity hardware
- *	and stash it in the context structure, for use by the context
- *	restore functions. This allows us to save things we need across
- *	power down states
- */
+#if defined(CONFIG_PM) && defined(CONFIG_INET)
+static struct notifier_block velocity_inetaddr_notifier = {
+      .notifier_call	= velocity_netdev_event,
+};
 
-static void velocity_save_context(struct velocity_info *vptr, struct velocity_context *context)
+static void velocity_register_notifier(void)
 {
-	struct mac_regs __iomem *regs = vptr->mac_regs;
-	u16 i;
-	u8 __iomem *ptr = (u8 __iomem *)regs;
-
-	for (i = MAC_REG_PAR; i < MAC_REG_CR0_CLR; i += 4)
-		*((u32 *) (context->mac_reg + i)) = readl(ptr + i);
-
-	for (i = MAC_REG_MAR; i < MAC_REG_TDCSR_CLR; i += 4)
-		*((u32 *) (context->mac_reg + i)) = readl(ptr + i);
-
-	for (i = MAC_REG_RDBASE_LO; i < MAC_REG_FIFO_TEST0; i += 4)
-		*((u32 *) (context->mac_reg + i)) = readl(ptr + i);
-
+	register_inetaddr_notifier(&velocity_inetaddr_notifier);
 }
 
-/**
- *	velocity_restore_context	-	restore registers
- *	@vptr: velocity
- *	@context: buffer for stored context
- *
- *	Reload the register configuration from the velocity context
- *	created by velocity_save_context.
- */
-
-static void velocity_restore_context(struct velocity_info *vptr, struct velocity_context *context)
+static void velocity_unregister_notifier(void)
 {
-	struct mac_regs __iomem *regs = vptr->mac_regs;
-	int i;
-	u8 __iomem *ptr = (u8 __iomem *)regs;
-
-	for (i = MAC_REG_PAR; i < MAC_REG_CR0_SET; i += 4)
-		writel(*((u32 *) (context->mac_reg + i)), ptr + i);
+	unregister_inetaddr_notifier(&velocity_inetaddr_notifier);
+}
 
-	/* Just skip cr0 */
-	for (i = MAC_REG_CR1_SET; i < MAC_REG_CR0_CLR; i++) {
-		/* Clear */
-		writeb(~(*((u8 *) (context->mac_reg + i))), ptr + i + 4);
-		/* Set */
-		writeb(*((u8 *) (context->mac_reg + i)), ptr + i);
-	}
+#else
 
-	for (i = MAC_REG_MAR; i < MAC_REG_IMR; i += 4)
-		writel(*((u32 *) (context->mac_reg + i)), ptr + i);
+#define velocity_register_notifier()	do {} while (0)
+#define velocity_unregister_notifier()	do {} while (0)
 
-	for (i = MAC_REG_RDBASE_LO; i < MAC_REG_FIFO_TEST0; i += 4)
-		writel(*((u32 *) (context->mac_reg + i)), ptr + i);
+#endif	/* defined(CONFIG_PM) && defined(CONFIG_INET) */
 
-	for (i = MAC_REG_TDCSR_SET; i <= MAC_REG_RDCSR_SET; i++)
-		writeb(*((u8 *) (context->mac_reg + i)), ptr + i);
-}
+#endif	/* CONFIG_PM */
 
 /**
- *	wol_calc_crc		-	WOL CRC
- *	@pattern: data pattern
- *	@mask_pattern: mask
+ *	velocity_init_module	-	load time function
  *
- *	Compute the wake on lan crc hashes for the packet header
- *	we are interested in.
+ *	Called when the velocity module is loaded. The PCI driver
+ *	is registered with the PCI layer, and in turn will call
+ *	the probe functions for each velocity adapter installed
+ *	in the system.
  */
-
-static u16 wol_calc_crc(int size, u8 *pattern, u8 *mask_pattern)
+static int __init velocity_init_module(void)
 {
-	u16 crc = 0xFFFF;
-	u8 mask;
-	int i, j;
-
-	for (i = 0; i < size; i++) {
-		mask = mask_pattern[i];
-
-		/* Skip this loop if the mask equals to zero */
-		if (mask == 0x00)
-			continue;
+	int ret;
 
-		for (j = 0; j < 8; j++) {
-			if ((mask & 0x01) == 0) {
-				mask >>= 1;
-				continue;
-			}
-			mask >>= 1;
-			crc = crc_ccitt(crc, &(pattern[i * 8 + j]), 1);
-		}
-	}
-	/*	Finally, invert the result once to get the correct data */
-	crc = ~crc;
-	return bitrev32(crc) >> 16;
+	velocity_register_notifier();
+	ret = pci_register_driver(&velocity_driver);
+	if (ret < 0)
+		velocity_unregister_notifier();
+	return ret;
 }
 
 /**
- *	velocity_set_wol	-	set up for wake on lan
- *	@vptr: velocity to set WOL status on
- *
- *	Set a card up for wake on lan either by unicast or by
- *	ARP packet.
+ *	velocity_cleanup	-	module unload
  *
- *	FIXME: check static buffer is safe here
+ *	When the velocity hardware is unloaded this function is called.
+ *	It will clean up the notifiers and the unregister the PCI
+ *	driver interface for this hardware. This in turn cleans up
+ *	all discovered interfaces before returning from the function
  */
-
-static int velocity_set_wol(struct velocity_info *vptr)
-{
-	struct mac_regs __iomem *regs = vptr->mac_regs;
-	static u8 buf[256];
-	int i;
-
-	static u32 mask_pattern[2][4] = {
-		{0x00203000, 0x000003C0, 0x00000000, 0x0000000}, /* ARP */
-		{0xfffff000, 0xffffffff, 0xffffffff, 0x000ffff}	 /* Magic Packet */
-	};
-
-	writew(0xFFFF, &regs->WOLCRClr);
-	writeb(WOLCFG_SAB | WOLCFG_SAM, &regs->WOLCFGSet);
-	writew(WOLCR_MAGIC_EN, &regs->WOLCRSet);
-
-	/*
-	   if (vptr->wol_opts & VELOCITY_WOL_PHY)
-	   writew((WOLCR_LINKON_EN|WOLCR_LINKOFF_EN), &regs->WOLCRSet);
-	 */
-
-	if (vptr->wol_opts & VELOCITY_WOL_UCAST)
-		writew(WOLCR_UNICAST_EN, &regs->WOLCRSet);
-
-	if (vptr->wol_opts & VELOCITY_WOL_ARP) {
-		struct arp_packet *arp = (struct arp_packet *) buf;
-		u16 crc;
-		memset(buf, 0, sizeof(struct arp_packet) + 7);
-
-		for (i = 0; i < 4; i++)
-			writel(mask_pattern[0][i], &regs->ByteMask[0][i]);
-
-		arp->type = htons(ETH_P_ARP);
-		arp->ar_op = htons(1);
-
-		memcpy(arp->ar_tip, vptr->ip_addr, 4);
-
-		crc = wol_calc_crc((sizeof(struct arp_packet) + 7) / 8, buf,
-				(u8 *) & mask_pattern[0][0]);
-
-		writew(crc, &regs->PatternCRC[0]);
-		writew(WOLCR_ARP_EN, &regs->WOLCRSet);
-	}
-
-	BYTE_REG_BITS_ON(PWCFG_WOLTYPE, &regs->PWCFGSet);
-	BYTE_REG_BITS_ON(PWCFG_LEGACY_WOLEN, &regs->PWCFGSet);
-
-	writew(0x0FFF, &regs->WOLSRClr);
-
-	if (vptr->mii_status & VELOCITY_AUTONEG_ENABLE) {
-		if (PHYID_GET_PHY_ID(vptr->phy_id) == PHYID_CICADA_CS8201)
-			MII_REG_BITS_ON(AUXCR_MDPPS, MII_REG_AUXCR, vptr->mac_regs);
-
-		MII_REG_BITS_OFF(G1000CR_1000FD | G1000CR_1000, MII_REG_G1000CR, vptr->mac_regs);
-	}
-
-	if (vptr->mii_status & VELOCITY_SPEED_1000)
-		MII_REG_BITS_ON(BMCR_REAUTO, MII_REG_BMCR, vptr->mac_regs);
-
-	BYTE_REG_BITS_ON(CHIPGCR_FCMODE, &regs->CHIPGCR);
-
-	{
-		u8 GCR;
-		GCR = readb(&regs->CHIPGCR);
-		GCR = (GCR & ~CHIPGCR_FCGMII) | CHIPGCR_FCFDX;
-		writeb(GCR, &regs->CHIPGCR);
-	}
-
-	BYTE_REG_BITS_OFF(ISR_PWEI, &regs->ISR);
-	/* Turn on SWPTAG just before entering power mode */
-	BYTE_REG_BITS_ON(STICKHW_SWPTAG, &regs->STICKHW);
-	/* Go to bed ..... */
-	BYTE_REG_BITS_ON((STICKHW_DS1 | STICKHW_DS0), &regs->STICKHW);
-
-	return 0;
-}
-
-static int velocity_suspend(struct pci_dev *pdev, pm_message_t state)
-{
-	struct net_device *dev = pci_get_drvdata(pdev);
-	struct velocity_info *vptr = netdev_priv(dev);
-	unsigned long flags;
-
-	if (!netif_running(vptr->dev))
-		return 0;
-
-	netif_device_detach(vptr->dev);
-
-	spin_lock_irqsave(&vptr->lock, flags);
-	pci_save_state(pdev);
-#ifdef ETHTOOL_GWOL
-	if (vptr->flags & VELOCITY_FLAGS_WOL_ENABLED) {
-		velocity_get_ip(vptr);
-		velocity_save_context(vptr, &vptr->context);
-		velocity_shutdown(vptr);
-		velocity_set_wol(vptr);
-		pci_enable_wake(pdev, PCI_D3hot, 1);
-		pci_set_power_state(pdev, PCI_D3hot);
-	} else {
-		velocity_save_context(vptr, &vptr->context);
-		velocity_shutdown(vptr);
-		pci_disable_device(pdev);
-		pci_set_power_state(pdev, pci_choose_state(pdev, state));
-	}
-#else
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
-#endif
-	spin_unlock_irqrestore(&vptr->lock, flags);
-	return 0;
-}
-
-static int velocity_resume(struct pci_dev *pdev)
-{
-	struct net_device *dev = pci_get_drvdata(pdev);
-	struct velocity_info *vptr = netdev_priv(dev);
-	unsigned long flags;
-	int i;
-
-	if (!netif_running(vptr->dev))
-		return 0;
-
-	pci_set_power_state(pdev, PCI_D0);
-	pci_enable_wake(pdev, 0, 0);
-	pci_restore_state(pdev);
-
-	mac_wol_reset(vptr->mac_regs);
-
-	spin_lock_irqsave(&vptr->lock, flags);
-	velocity_restore_context(vptr, &vptr->context);
-	velocity_init_registers(vptr, VELOCITY_INIT_WOL);
-	mac_disable_int(vptr->mac_regs);
-
-	velocity_tx_srv(vptr, 0);
-
-	for (i = 0; i < vptr->tx.numq; i++) {
-		if (vptr->tx.used[i])
-			mac_tx_queue_wake(vptr->mac_regs, i);
-	}
-
-	mac_enable_int(vptr->mac_regs);
-	spin_unlock_irqrestore(&vptr->lock, flags);
-	netif_device_attach(vptr->dev);
-
-	return 0;
-}
-
-#ifdef CONFIG_INET
-
-static int velocity_netdev_event(struct notifier_block *nb, unsigned long notification, void *ptr)
+static void __exit velocity_cleanup_module(void)
 {
-	struct in_ifaddr *ifa = (struct in_ifaddr *) ptr;
-	struct net_device *dev = ifa->ifa_dev->dev;
-	struct velocity_info *vptr;
-	unsigned long flags;
-
-	if (dev_net(dev) != &init_net)
-		return NOTIFY_DONE;
-
-	spin_lock_irqsave(&velocity_dev_list_lock, flags);
-	list_for_each_entry(vptr, &velocity_dev_list, list) {
-		if (vptr->dev == dev) {
-			velocity_get_ip(vptr);
-			break;
-		}
-	}
-	spin_unlock_irqrestore(&velocity_dev_list_lock, flags);
-
-	return NOTIFY_DONE;
+	velocity_unregister_notifier();
+	pci_unregister_driver(&velocity_driver);
 }
 
-#endif
-#endif
+module_init(velocity_init_module);
+module_exit(velocity_cleanup_module);
-- 
1.6.2.5

