From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Fix most checkpatch errors
Date: Mon, 26 Jul 2010 22:28:07 +0900
Message-ID: <4C4D8D67.7080008@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:44051 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752247Ab0GZNkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 09:40:07 -0400
Received: by pwi5 with SMTP id 5so41013pwi.19
        for <netdev@vger.kernel.org>; Mon, 26 Jul 2010 06:40:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tidy up whitespace and formatting to reduce from
 38 errors to 4 and 20 fewer warnings.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   88 ++++++++++++++++++++++++++--------------------------
 1 files changed, 44 insertions(+), 44 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 8b85c02..51752d8 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -61,7 +61,7 @@
  * similar to Tigon3.
  */
 
-#define RX_LE_SIZE	    	1024
+#define RX_LE_SIZE		1024
 #define RX_LE_BYTES		(RX_LE_SIZE*sizeof(struct sky2_rx_le))
 #define RX_MAX_PENDING		(RX_LE_SIZE/6 - 2)
 #define RX_DEF_PENDING		RX_MAX_PENDING
@@ -79,7 +79,7 @@
 
 #define SKY2_EEPROM_MAGIC	0x9955aabb
 
-#define RING_NEXT(x,s)	(((x)+1) & ((s)-1))
+#define RING_NEXT(x, s)	(((x)+1) & ((s)-1))
 
 static const u32 default_msg =
     NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK
@@ -103,7 +103,7 @@ static DEFINE_PCI_DEVICE_TABLE(sky2_id_table) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E00) }, /* SK-9Exx */
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E01) }, /* SK-9E21M */
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b00) },	/* DGE-560T */
-	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4001) }, 	/* DGE-550SX */
+	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4001) },	/* DGE-550SX */
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4B02) },	/* DGE-560SX */
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4B03) },	/* DGE-550T */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4340) }, /* 88E8021 */
@@ -172,7 +172,7 @@ static int gm_phy_write(struct sky2_hw *hw, unsigned port, u16 reg, u16 val)
 		udelay(10);
 	}
 
-	dev_warn(&hw->pdev->dev,"%s: phy write timeout\n", hw->dev[port]->name);
+	dev_warn(&hw->pdev->dev, "%s: phy write timeout\n", hw->dev[port]->name);
 	return -ETIMEDOUT;
 
 io_error:
@@ -276,7 +276,7 @@ static void sky2_power_aux(struct sky2_hw *hw)
 			    Y2_COR_CLK_LNK2_DIS | Y2_CLK_GAT_LNK2_DIS);
 
 	/* switch power to VAUX if supported and PME from D3cold */
-	if ( (sky2_read32(hw, B0_CTST) & Y2_VAUX_AVAIL) &&
+	if ((sky2_read32(hw, B0_CTST) & Y2_VAUX_AVAIL) &&
 	     pci_pme_capable(hw->pdev, PCI_D3cold))
 		sky2_write8(hw, B0_POWER_CTRL,
 			    (PC_VAUX_ENA | PC_VCC_ENA |
@@ -333,7 +333,7 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 	struct sky2_port *sky2 = netdev_priv(hw->dev[port]);
 	u16 ctrl, ct1000, adv, pg, ledctrl, ledover, reg;
 
-	if ( (sky2->flags & SKY2_FLAG_AUTO_SPEED) &&
+	if ((sky2->flags & SKY2_FLAG_AUTO_SPEED) &&
 	    !(hw->flags & SKY2_HW_NEWER_PHY)) {
 		u16 ectrl = gm_phy_read(hw, port, PHY_MARV_EXT_CTRL);
 
@@ -375,8 +375,8 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 			ctrl |= PHY_M_PC_MDI_XMODE(PHY_M_PC_ENA_AUTO);
 
 			/* downshift on PHY 88E1112 and 88E1149 is changed */
-			if ( (sky2->flags & SKY2_FLAG_AUTO_SPEED) &&
-			     (hw->flags & SKY2_HW_NEWER_PHY)) {
+			if ((sky2->flags & SKY2_FLAG_AUTO_SPEED) &&
+			    (hw->flags & SKY2_HW_NEWER_PHY)) {
 				/* set downshift counter to 3x and enable downshift */
 				ctrl &= ~PHY_M_PC_DSC_MSK;
 				ctrl |= PHY_M_PC_DSC(2) | PHY_M_PC_DOWN_S_ENA;
@@ -476,7 +476,7 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 			adv |= fiber_fc_adv[sky2->flow_mode];
 	} else {
 		reg |= GM_GPCR_AU_FCT_DIS;
- 		reg |= gm_fc_disable[sky2->flow_mode];
+		reg |= gm_fc_disable[sky2->flow_mode];
 
 		/* Forward pause packets to GMAC? */
 		if (sky2->flow_mode & FC_RX)
@@ -817,8 +817,8 @@ static void sky2_set_tx_stfwd(struct sky2_hw *hw, unsigned port)
 {
 	struct net_device *dev = hw->dev[port];
 
-	if ( (hw->chip_id == CHIP_ID_YUKON_EX &&
-	      hw->chip_rev != CHIP_REV_YU_EX_A0) ||
+	if ((hw->chip_id == CHIP_ID_YUKON_EX &&
+	     hw->chip_rev != CHIP_REV_YU_EX_A0) ||
 	     hw->chip_id >= CHIP_ID_YUKON_FE_P) {
 		/* Yukon-Extreme B0 and further Extreme devices */
 		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_STFW_ENA);
@@ -1078,7 +1078,7 @@ static inline struct sky2_rx_le *sky2_next_rx(struct sky2_port *sky2)
 	return le;
 }
 
-static unsigned sky2_get_rx_threshold(struct sky2_port* sky2)
+static unsigned sky2_get_rx_threshold(struct sky2_port *sky2)
 {
 	unsigned size;
 
@@ -1089,7 +1089,7 @@ static unsigned sky2_get_rx_threshold(struct sky2_port* sky2)
 	return (size - 8) / sizeof(u32);
 }
 
-static unsigned sky2_get_rx_data_size(struct sky2_port* sky2)
+static unsigned sky2_get_rx_data_size(struct sky2_port *sky2)
 {
 	struct rx_ring_info *re;
 	unsigned size;
@@ -1113,7 +1113,7 @@ static unsigned sky2_get_rx_data_size(struct sky2_port* sky2)
 }
 
 /* Build description to hardware for one receive segment */
-static void sky2_rx_add(struct sky2_port *sky2,  u8 op,
+static void sky2_rx_add(struct sky2_port *sky2, u8 op,
 			dma_addr_t map, unsigned len)
 {
 	struct sky2_rx_le *le;
@@ -1599,16 +1599,16 @@ static void sky2_hw_up(struct sky2_port *sky2)
 	tx_init(sky2);
 
 	/*
- 	 * On dual port PCI-X card, there is an problem where status
+	 * On dual port PCI-X card, there is an problem where status
 	 * can be received out of order due to split transactions
 	 */
 	if (otherdev && netif_running(otherdev) &&
- 	    (cap = pci_find_capability(hw->pdev, PCI_CAP_ID_PCIX))) {
- 		u16 cmd;
+	    (cap = pci_find_capability(hw->pdev, PCI_CAP_ID_PCIX))) {
+		u16 cmd;
 
 		cmd = sky2_pci_read16(hw, cap + PCI_X_CMD);
- 		cmd &= ~PCI_X_CMD_MAX_SPLIT;
- 		sky2_pci_write16(hw, cap + PCI_X_CMD, cmd);
+		cmd &= ~PCI_X_CMD_MAX_SPLIT;
+		sky2_pci_write16(hw, cap + PCI_X_CMD, cmd);
 	}
 
 	sky2_mac_init(hw, port);
@@ -1749,8 +1749,8 @@ static netdev_tx_t sky2_xmit_frame(struct sk_buff *skb,
 	u16 mss;
 	u8 ctrl;
 
- 	if (unlikely(tx_avail(sky2) < tx_le_req(skb)))
-  		return NETDEV_TX_BUSY;
+	if (unlikely(tx_avail(sky2) < tx_le_req(skb)))
+		return NETDEV_TX_BUSY;
 
 	len = skb_headlen(skb);
 	mapping = pci_map_single(hw->pdev, skb->data, len, PCI_DMA_TODEVICE);
@@ -1778,9 +1778,9 @@ static netdev_tx_t sky2_xmit_frame(struct sk_buff *skb,
 		if (!(hw->flags & SKY2_HW_NEW_LE))
 			mss += ETH_HLEN + ip_hdrlen(skb) + tcp_hdrlen(skb);
 
-  		if (mss != sky2->tx_last_mss) {
+		if (mss != sky2->tx_last_mss) {
 			le = get_tx_le(sky2, &slot);
-  			le->addr = cpu_to_le32(mss);
+			le->addr = cpu_to_le32(mss);
 
 			if (hw->flags & SKY2_HW_NEW_LE)
 				le->opcode = OP_MSS | HW_OWNER;
@@ -1808,8 +1808,8 @@ static netdev_tx_t sky2_xmit_frame(struct sk_buff *skb,
 	/* Handle TCP checksum offload */
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		/* On Yukon EX (some versions) encoding change. */
- 		if (hw->flags & SKY2_HW_AUTO_TX_SUM)
- 			ctrl |= CALSUM;	/* auto checksum */
+		if (hw->flags & SKY2_HW_AUTO_TX_SUM)
+			ctrl |= CALSUM;	/* auto checksum */
 		else {
 			const unsigned offset = skb_transport_offset(skb);
 			u32 tcpsum;
@@ -2430,7 +2430,7 @@ nobuf:
 static struct sk_buff *sky2_receive(struct net_device *dev,
 				    u16 length, u32 status)
 {
- 	struct sky2_port *sky2 = netdev_priv(dev);
+	struct sky2_port *sky2 = netdev_priv(dev);
 	struct rx_ring_info *re = sky2->rx_ring + sky2->rx_next;
 	struct sk_buff *skb = NULL;
 	u16 count = (status & GMR_FS_LEN) >> 16;
@@ -2751,7 +2751,7 @@ static void sky2_hw_intr(struct sky2_hw *hw)
 		pci_err = sky2_pci_read16(hw, PCI_STATUS);
 		if (net_ratelimit())
 			dev_err(&pdev->dev, "PCI hardware error (0x%x)\n",
-			        pci_err);
+				pci_err);
 
 		sky2_pci_write16(hw, PCI_STATUS,
 				      pci_err | PCI_STATUS_ERROR_BITS);
@@ -3019,7 +3019,7 @@ static int __devinit sky2_init(struct sky2_hw *hw)
 	hw->chip_id = sky2_read8(hw, B2_CHIP_ID);
 	hw->chip_rev = (sky2_read8(hw, B2_MAC_CFG) & CFG_CHIP_R_MSK) >> 4;
 
-	switch(hw->chip_id) {
+	switch (hw->chip_id) {
 	case CHIP_ID_YUKON_XL:
 		hw->flags = SKY2_HW_GIGABIT | SKY2_HW_NEWER_PHY;
 		if (hw->chip_rev < CHIP_REV_YU_XL_A2)
@@ -3543,13 +3543,13 @@ static const struct sky2_stat {
 	{ "tx_mac_pause",  GM_TXF_MPAUSE },
 	{ "rx_mac_pause",  GM_RXF_MPAUSE },
 	{ "collisions",    GM_TXF_COL },
-	{ "late_collision",GM_TXF_LAT_COL },
-	{ "aborted", 	   GM_TXF_ABO_COL },
+	{ "late_collision", GM_TXF_LAT_COL },
+	{ "aborted",	   GM_TXF_ABO_COL },
 	{ "single_collisions", GM_TXF_SNG_COL },
 	{ "multi_collisions", GM_TXF_MUL_COL },
 
 	{ "rx_short",      GM_RXF_SHT },
-	{ "rx_runt", 	   GM_RXE_FRAG },
+	{ "rx_runt",	   GM_RXE_FRAG },
 	{ "rx_64_byte_packets", GM_RXF_64B },
 	{ "rx_65_to_127_byte_packets", GM_RXF_127B },
 	{ "rx_128_to_255_byte_packets", GM_RXF_255B },
@@ -3690,7 +3690,7 @@ static int sky2_set_mac_address(struct net_device *dev, void *p)
 	return 0;
 }
 
-static void inline sky2_add_filter(u8 filter[8], const u8 *addr)
+static inline void sky2_add_filter(u8 filter[8], const u8 *addr)
 {
 	u32 bit;
 
@@ -3916,7 +3916,7 @@ static int sky2_set_coalesce(struct net_device *dev,
 		return -EINVAL;
 	if (ecmd->rx_max_coalesced_frames > RX_MAX_PENDING)
 		return -EINVAL;
-	if (ecmd->rx_max_coalesced_frames_irq >RX_MAX_PENDING)
+	if (ecmd->rx_max_coalesced_frames_irq > RX_MAX_PENDING)
 		return -EINVAL;
 
 	if (ecmd->tx_coalesce_usecs == 0)
@@ -4095,14 +4095,14 @@ static int sky2_get_eeprom_len(struct net_device *dev)
 	u16 reg2;
 
 	reg2 = sky2_pci_read16(hw, PCI_DEV_REG2);
-	return 1 << ( ((reg2 & PCI_VPD_ROM_SZ) >> 14) + 8);
+	return 1 << (((reg2 & PCI_VPD_ROM_SZ) >> 14) + 8);
 }
 
 static int sky2_vpd_wait(const struct sky2_hw *hw, int cap, u16 busy)
 {
 	unsigned long start = jiffies;
 
-	while ( (sky2_pci_read16(hw, cap + PCI_VPD_ADDR) & PCI_VPD_ADDR_F) == busy) {
+	while ((sky2_pci_read16(hw, cap + PCI_VPD_ADDR) & PCI_VPD_ADDR_F) == busy) {
 		/* Can take up to 10.6 ms for write */
 		if (time_after(jiffies, start + HZ/4)) {
 			dev_err(&hw->pdev->dev, "VPD cycle timed out\n");
@@ -4225,7 +4225,7 @@ static const struct ethtool_ops sky2_ethtool_ops = {
 	.get_eeprom_len	= sky2_get_eeprom_len,
 	.get_eeprom	= sky2_get_eeprom,
 	.set_eeprom	= sky2_set_eeprom,
-	.set_sg 	= ethtool_op_set_sg,
+	.set_sg		= ethtool_op_set_sg,
 	.set_tx_csum	= sky2_set_tx_csum,
 	.set_tso	= sky2_set_tso,
 	.get_rx_csum	= sky2_get_rx_csum,
@@ -4278,7 +4278,7 @@ static void sky2_show_vpd(struct seq_file *seq, struct sky2_hw *hw)
 	u16 reg2;
 
 	reg2 = sky2_pci_read16(hw, PCI_DEV_REG2);
-	vpd_size = 1 << ( ((reg2 & PCI_VPD_ROM_SZ) >> 14) + 8);
+	vpd_size = 1 << (((reg2 & PCI_VPD_ROM_SZ) >> 14) + 8);
 
 	seq_printf(seq, "%s Product Data\n", pci_name(hw->pdev));
 	buf = kmalloc(vpd_size, GFP_KERNEL);
@@ -4381,7 +4381,7 @@ static int sky2_debug_show(struct seq_file *seq, void *v)
 			seq_printf(seq, "%u:", idx);
 		sop = 0;
 
-		switch(le->opcode & ~HW_OWNER) {
+		switch (le->opcode & ~HW_OWNER) {
 		case OP_ADDR64:
 			seq_printf(seq, " %#x:", a);
 			break;
@@ -4450,7 +4450,7 @@ static int sky2_device_event(struct notifier_block *unused,
 	if (dev->netdev_ops->ndo_open != sky2_up || !sky2_debug)
 		return NOTIFY_DONE;
 
-	switch(event) {
+	switch (event) {
 	case NETDEV_CHANGENAME:
 		if (sky2->debugfs) {
 			sky2->debugfs = debugfs_rename(sky2_debug, sky2->debugfs,
@@ -4645,7 +4645,7 @@ static int __devinit sky2_test_msi(struct sky2_hw *hw)
 	struct pci_dev *pdev = hw->pdev;
 	int err;
 
-	init_waitqueue_head (&hw->msi_wait);
+	init_waitqueue_head(&hw->msi_wait);
 
 	sky2_write32(hw, B0_IMSK, Y2_IS_IRQ_SW);
 
@@ -4682,7 +4682,7 @@ static const char *sky2_name(u8 chipid, char *buf, int sz)
 {
 	const char *name[] = {
 		"XL",		/* 0xb3 */
-		"EC Ultra", 	/* 0xb4 */
+		"EC Ultra",	/* 0xb4 */
 		"Extreme",	/* 0xb5 */
 		"EC",		/* 0xb6 */
 		"FE",		/* 0xb7 */
@@ -4762,7 +4762,7 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 	 * this driver uses software swapping.
 	 */
 	reg &= ~PCI_REV_DESC;
-	err = pci_write_config_dword(pdev,PCI_DEV_REG2, reg);
+	err = pci_write_config_dword(pdev, PCI_DEV_REG2, reg);
 	if (err) {
 		dev_err(&pdev->dev, "PCI write config failed\n");
 		goto err_out_free_regions;
@@ -4814,10 +4814,10 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 	if (!disable_msi && pci_enable_msi(pdev) == 0) {
 		err = sky2_test_msi(hw);
 		if (err == -EOPNOTSUPP)
- 			pci_disable_msi(pdev);
+			pci_disable_msi(pdev);
 		else if (err)
 			goto err_out_free_netdev;
- 	}
+	}
 
 	err = register_netdev(dev);
 	if (err) {
-- 
1.5.6.5

