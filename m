From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-2.6 PATCH] e100: cosmetic cleanup
Date: Wed, 31 Dec 2008 15:31:50 -0800
Message-ID: <20081231233057.23132.43080.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:34090 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752364AbYLaXcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2008 18:32:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Add missing space after if, switch, for and while keywords.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e100.c |  268 ++++++++++++++++++++++++++--------------------------
 1 files changed, 134 insertions(+), 134 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 9f38b16..134b2d6 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -658,12 +658,12 @@ static int e100_self_test(struct nic *nic)
 	e100_disable_irq(nic);
 
 	/* Check results of self-test */
-	if(nic->mem->selftest.result != 0) {
+	if (nic->mem->selftest.result != 0) {
 		DPRINTK(HW, ERR, "Self-test failed: result=0x%08X\n",
 			nic->mem->selftest.result);
 		return -ETIMEDOUT;
 	}
-	if(nic->mem->selftest.signature == 0) {
+	if (nic->mem->selftest.signature == 0) {
 		DPRINTK(HW, ERR, "Self-test failed: timed out\n");
 		return -ETIMEDOUT;
 	}
@@ -684,13 +684,13 @@ static void e100_eeprom_write(struct nic *nic, u16 addr_len, u16 addr, __le16 da
 	cmd_addr_data[2] = op_ewds << (addr_len - 2);
 
 	/* Bit-bang cmds to write word to eeprom */
-	for(j = 0; j < 3; j++) {
+	for (j = 0; j < 3; j++) {
 
 		/* Chip select */
 		iowrite8(eecs | eesk, &nic->csr->eeprom_ctrl_lo);
 		e100_write_flush(nic); udelay(4);
 
-		for(i = 31; i >= 0; i--) {
+		for (i = 31; i >= 0; i--) {
 			ctrl = (cmd_addr_data[j] & (1 << i)) ?
 				eecs | eedi : eecs;
 			iowrite8(ctrl, &nic->csr->eeprom_ctrl_lo);
@@ -723,7 +723,7 @@ static __le16 e100_eeprom_read(struct nic *nic, u16 *addr_len, u16 addr)
 	e100_write_flush(nic); udelay(4);
 
 	/* Bit-bang to read word from eeprom */
-	for(i = 31; i >= 0; i--) {
+	for (i = 31; i >= 0; i--) {
 		ctrl = (cmd_addr_data & (1 << i)) ? eecs | eedi : eecs;
 		iowrite8(ctrl, &nic->csr->eeprom_ctrl_lo);
 		e100_write_flush(nic); udelay(4);
@@ -734,7 +734,7 @@ static __le16 e100_eeprom_read(struct nic *nic, u16 *addr_len, u16 addr)
 		/* Eeprom drives a dummy zero to EEDO after receiving
 		 * complete address.  Use this to adjust addr_len. */
 		ctrl = ioread8(&nic->csr->eeprom_ctrl_lo);
-		if(!(ctrl & eedo) && i > 16) {
+		if (!(ctrl & eedo) && i > 16) {
 			*addr_len -= (i - 16);
 			i = 17;
 		}
@@ -758,9 +758,9 @@ static int e100_eeprom_load(struct nic *nic)
 	e100_eeprom_read(nic, &addr_len, 0);
 	nic->eeprom_wc = 1 << addr_len;
 
-	for(addr = 0; addr < nic->eeprom_wc; addr++) {
+	for (addr = 0; addr < nic->eeprom_wc; addr++) {
 		nic->eeprom[addr] = e100_eeprom_read(nic, &addr_len, addr);
-		if(addr < nic->eeprom_wc - 1)
+		if (addr < nic->eeprom_wc - 1)
 			checksum += le16_to_cpu(nic->eeprom[addr]);
 	}
 
@@ -784,15 +784,15 @@ static int e100_eeprom_save(struct nic *nic, u16 start, u16 count)
 	e100_eeprom_read(nic, &addr_len, 0);
 	nic->eeprom_wc = 1 << addr_len;
 
-	if(start + count >= nic->eeprom_wc)
+	if (start + count >= nic->eeprom_wc)
 		return -EINVAL;
 
-	for(addr = start; addr < start + count; addr++)
+	for (addr = start; addr < start + count; addr++)
 		e100_eeprom_write(nic, addr_len, addr, nic->eeprom[addr]);
 
 	/* The checksum, stored in the last word, is calculated such that
 	 * the sum of words should be 0xBABA */
-	for(addr = 0; addr < nic->eeprom_wc - 1; addr++)
+	for (addr = 0; addr < nic->eeprom_wc - 1; addr++)
 		checksum += le16_to_cpu(nic->eeprom[addr]);
 	nic->eeprom[nic->eeprom_wc - 1] = cpu_to_le16(0xBABA - checksum);
 	e100_eeprom_write(nic, addr_len, nic->eeprom_wc - 1,
@@ -812,19 +812,19 @@ static int e100_exec_cmd(struct nic *nic, u8 cmd, dma_addr_t dma_addr)
 	spin_lock_irqsave(&nic->cmd_lock, flags);
 
 	/* Previous command is accepted when SCB clears */
-	for(i = 0; i < E100_WAIT_SCB_TIMEOUT; i++) {
-		if(likely(!ioread8(&nic->csr->scb.cmd_lo)))
+	for (i = 0; i < E100_WAIT_SCB_TIMEOUT; i++) {
+		if (likely(!ioread8(&nic->csr->scb.cmd_lo)))
 			break;
 		cpu_relax();
-		if(unlikely(i > E100_WAIT_SCB_FAST))
+		if (unlikely(i > E100_WAIT_SCB_FAST))
 			udelay(5);
 	}
-	if(unlikely(i == E100_WAIT_SCB_TIMEOUT)) {
+	if (unlikely(i == E100_WAIT_SCB_TIMEOUT)) {
 		err = -EAGAIN;
 		goto err_unlock;
 	}
 
-	if(unlikely(cmd != cuc_resume))
+	if (unlikely(cmd != cuc_resume))
 		iowrite32(dma_addr, &nic->csr->scb.gen_ptr);
 	iowrite8(cmd, &nic->csr->scb.cmd_lo);
 
@@ -843,7 +843,7 @@ static int e100_exec_cb(struct nic *nic, struct sk_buff *skb,
 
 	spin_lock_irqsave(&nic->cb_lock, flags);
 
-	if(unlikely(!nic->cbs_avail)) {
+	if (unlikely(!nic->cbs_avail)) {
 		err = -ENOMEM;
 		goto err_unlock;
 	}
@@ -853,7 +853,7 @@ static int e100_exec_cb(struct nic *nic, struct sk_buff *skb,
 	nic->cbs_avail--;
 	cb->skb = skb;
 
-	if(unlikely(!nic->cbs_avail))
+	if (unlikely(!nic->cbs_avail))
 		err = -ENOSPC;
 
 	cb_prepare(nic, cb, skb);
@@ -864,15 +864,15 @@ static int e100_exec_cb(struct nic *nic, struct sk_buff *skb,
 	wmb();
 	cb->prev->command &= cpu_to_le16(~cb_s);
 
-	while(nic->cb_to_send != nic->cb_to_use) {
-		if(unlikely(e100_exec_cmd(nic, nic->cuc_cmd,
+	while (nic->cb_to_send != nic->cb_to_use) {
+		if (unlikely(e100_exec_cmd(nic, nic->cuc_cmd,
 			nic->cb_to_send->dma_addr))) {
 			/* Ok, here's where things get sticky.  It's
 			 * possible that we can't schedule the command
 			 * because the controller is too busy, so
 			 * let's just queue the command and try again
 			 * when another command is scheduled. */
-			if(err == -ENOSPC) {
+			if (err == -ENOSPC) {
 				//request a reset
 				schedule_work(&nic->tx_timeout_task);
 			}
@@ -945,7 +945,7 @@ static void e100_get_defaults(struct nic *nic)
 
 	/* MAC type is encoded as rev ID; exception: ICH is treated as 82559 */
 	nic->mac = (nic->flags & ich) ? mac_82559_D101M : nic->pdev->revision;
-	if(nic->mac == mac_unknown)
+	if (nic->mac == mac_unknown)
 		nic->mac = mac_82557_D100_A;
 
 	nic->params.rfds = rfds;
@@ -1008,23 +1008,23 @@ static void e100_configure(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 	config->adaptive_ifs = nic->adaptive_ifs;
 	config->loopback = nic->loopback;
 
-	if(nic->mii.force_media && nic->mii.full_duplex)
+	if (nic->mii.force_media && nic->mii.full_duplex)
 		config->full_duplex_force = 0x1;	/* 1=force, 0=auto */
 
-	if(nic->flags & promiscuous || nic->loopback) {
+	if (nic->flags & promiscuous || nic->loopback) {
 		config->rx_save_bad_frames = 0x1;	/* 1=save, 0=discard */
 		config->rx_discard_short_frames = 0x0;	/* 1=discard, 0=save */
 		config->promiscuous_mode = 0x1;		/* 1=on, 0=off */
 	}
 
-	if(nic->flags & multicast_all)
+	if (nic->flags & multicast_all)
 		config->multicast_all = 0x1;		/* 1=accept, 0=no */
 
 	/* disable WoL when up */
-	if(netif_running(nic->netdev) || !(nic->flags & wol_magic))
+	if (netif_running(nic->netdev) || !(nic->flags & wol_magic))
 		config->magic_packet_disable = 0x1;	/* 1=off, 0=on */
 
-	if(nic->mac >= mac_82558_D101_A4) {
+	if (nic->mac >= mac_82558_D101_A4) {
 		config->fc_disable = 0x1;	/* 1=Tx fc off, 0=Tx fc on */
 		config->mwi_enable = 0x1;	/* 1=enable, 0=disable */
 		config->standard_tcb = 0x0;	/* 1=standard, 0=extended */
@@ -1369,21 +1369,21 @@ static int e100_phy_init(struct nic *nic)
 	u16 bmcr, stat, id_lo, id_hi, cong;
 
 	/* Discover phy addr by searching addrs in order {1,0,2,..., 31} */
-	for(addr = 0; addr < 32; addr++) {
+	for (addr = 0; addr < 32; addr++) {
 		nic->mii.phy_id = (addr == 0) ? 1 : (addr == 1) ? 0 : addr;
 		bmcr = mdio_read(netdev, nic->mii.phy_id, MII_BMCR);
 		stat = mdio_read(netdev, nic->mii.phy_id, MII_BMSR);
 		stat = mdio_read(netdev, nic->mii.phy_id, MII_BMSR);
-		if(!((bmcr == 0xFFFF) || ((stat == 0) && (bmcr == 0))))
+		if (!((bmcr == 0xFFFF) || ((stat == 0) && (bmcr == 0))))
 			break;
 	}
 	DPRINTK(HW, DEBUG, "phy_addr = %d\n", nic->mii.phy_id);
-	if(addr == 32)
+	if (addr == 32)
 		return -EAGAIN;
 
 	/* Selected the phy and isolate the rest */
-	for(addr = 0; addr < 32; addr++) {
-		if(addr != nic->mii.phy_id) {
+	for (addr = 0; addr < 32; addr++) {
+		if (addr != nic->mii.phy_id) {
 			mdio_write(netdev, addr, MII_BMCR, BMCR_ISOLATE);
 		} else {
 			bmcr = mdio_read(netdev, addr, MII_BMCR);
@@ -1400,7 +1400,7 @@ static int e100_phy_init(struct nic *nic)
 
 	/* Handle National tx phys */
 #define NCS_PHY_MODEL_MASK	0xFFF0FFFF
-	if((nic->phy & NCS_PHY_MODEL_MASK) == phy_nsc_tx) {
+	if ((nic->phy & NCS_PHY_MODEL_MASK) == phy_nsc_tx) {
 		/* Disable congestion control */
 		cong = mdio_read(netdev, nic->mii.phy_id, MII_NSC_CONG);
 		cong |= NSC_CONG_TXREADY;
@@ -1408,7 +1408,7 @@ static int e100_phy_init(struct nic *nic)
 		mdio_write(netdev, nic->mii.phy_id, MII_NSC_CONG, cong);
 	}
 
-	if((nic->mac >= mac_82550_D102) || ((nic->flags & ich) &&
+	if ((nic->mac >= mac_82550_D102) || ((nic->flags & ich) &&
 	   (mdio_read(netdev, nic->mii.phy_id, MII_TPISTATUS) & 0x8000) &&
 		!(nic->eeprom[eeprom_cnfg_mdix] & eeprom_mdix_enabled))) {
 		/* enable/disable MDI/MDI-X auto-switching. */
@@ -1426,25 +1426,25 @@ static int e100_hw_init(struct nic *nic)
 	e100_hw_reset(nic);
 
 	DPRINTK(HW, ERR, "e100_hw_init\n");
-	if(!in_interrupt() && (err = e100_self_test(nic)))
+	if (!in_interrupt() && (err = e100_self_test(nic)))
 		return err;
 
-	if((err = e100_phy_init(nic)))
+	if ((err = e100_phy_init(nic)))
 		return err;
-	if((err = e100_exec_cmd(nic, cuc_load_base, 0)))
+	if ((err = e100_exec_cmd(nic, cuc_load_base, 0)))
 		return err;
-	if((err = e100_exec_cmd(nic, ruc_load_base, 0)))
+	if ((err = e100_exec_cmd(nic, ruc_load_base, 0)))
 		return err;
 	if ((err = e100_exec_cb_wait(nic, NULL, e100_setup_ucode)))
 		return err;
-	if((err = e100_exec_cb(nic, NULL, e100_configure)))
+	if ((err = e100_exec_cb(nic, NULL, e100_configure)))
 		return err;
-	if((err = e100_exec_cb(nic, NULL, e100_setup_iaaddr)))
+	if ((err = e100_exec_cb(nic, NULL, e100_setup_iaaddr)))
 		return err;
-	if((err = e100_exec_cmd(nic, cuc_dump_addr,
+	if ((err = e100_exec_cmd(nic, cuc_dump_addr,
 		nic->dma_addr + offsetof(struct mem, stats))))
 		return err;
-	if((err = e100_exec_cmd(nic, cuc_dump_reset, 0)))
+	if ((err = e100_exec_cmd(nic, cuc_dump_reset, 0)))
 		return err;
 
 	e100_disable_irq(nic);
@@ -1460,7 +1460,7 @@ static void e100_multi(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 
 	cb->command = cpu_to_le16(cb_multi);
 	cb->u.multi.count = cpu_to_le16(count * ETH_ALEN);
-	for(i = 0; list && i < count; i++, list = list->next)
+	for (i = 0; list && i < count; i++, list = list->next)
 		memcpy(&cb->u.multi.addr[i*ETH_ALEN], &list->dmi_addr,
 			ETH_ALEN);
 }
@@ -1472,12 +1472,12 @@ static void e100_set_multicast_list(struct net_device *netdev)
 	DPRINTK(HW, DEBUG, "mc_count=%d, flags=0x%04X\n",
 		netdev->mc_count, netdev->flags);
 
-	if(netdev->flags & IFF_PROMISC)
+	if (netdev->flags & IFF_PROMISC)
 		nic->flags |= promiscuous;
 	else
 		nic->flags &= ~promiscuous;
 
-	if(netdev->flags & IFF_ALLMULTI ||
+	if (netdev->flags & IFF_ALLMULTI ||
 		netdev->mc_count > E100_MAX_MULTICAST_ADDRS)
 		nic->flags |= multicast_all;
 	else
@@ -1500,7 +1500,7 @@ static void e100_update_stats(struct nic *nic)
 	 * complete, so we're always waiting for results of the
 	 * previous command. */
 
-	if(*complete == cpu_to_le32(cuc_dump_reset_complete)) {
+	if (*complete == cpu_to_le32(cuc_dump_reset_complete)) {
 		*complete = 0;
 		nic->tx_frames = le32_to_cpu(s->tx_good_frames);
 		nic->tx_collisions = le32_to_cpu(s->tx_total_collisions);
@@ -1527,12 +1527,12 @@ static void e100_update_stats(struct nic *nic)
 			le32_to_cpu(s->tx_single_collisions);
 		nic->tx_multiple_collisions +=
 			le32_to_cpu(s->tx_multiple_collisions);
-		if(nic->mac >= mac_82558_D101_A4) {
+		if (nic->mac >= mac_82558_D101_A4) {
 			nic->tx_fc_pause += le32_to_cpu(s->fc_xmt_pause);
 			nic->rx_fc_pause += le32_to_cpu(s->fc_rcv_pause);
 			nic->rx_fc_unsupported +=
 				le32_to_cpu(s->fc_rcv_unsupported);
-			if(nic->mac >= mac_82559_D101M) {
+			if (nic->mac >= mac_82559_D101M) {
 				nic->tx_tco_frames +=
 					le16_to_cpu(s->xmt_tco_frames);
 				nic->rx_tco_frames +=
@@ -1542,7 +1542,7 @@ static void e100_update_stats(struct nic *nic)
 	}
 
 
-	if(e100_exec_cmd(nic, cuc_dump_reset, 0))
+	if (e100_exec_cmd(nic, cuc_dump_reset, 0))
 		DPRINTK(TX_ERR, DEBUG, "exec cuc_dump_reset failed\n");
 }
 
@@ -1551,19 +1551,19 @@ static void e100_adjust_adaptive_ifs(struct nic *nic, int speed, int duplex)
 	/* Adjust inter-frame-spacing (IFS) between two transmits if
 	 * we're getting collisions on a half-duplex connection. */
 
-	if(duplex == DUPLEX_HALF) {
+	if (duplex == DUPLEX_HALF) {
 		u32 prev = nic->adaptive_ifs;
 		u32 min_frames = (speed == SPEED_100) ? 1000 : 100;
 
-		if((nic->tx_frames / 32 < nic->tx_collisions) &&
+		if ((nic->tx_frames / 32 < nic->tx_collisions) &&
 		   (nic->tx_frames > min_frames)) {
-			if(nic->adaptive_ifs < 60)
+			if (nic->adaptive_ifs < 60)
 				nic->adaptive_ifs += 5;
 		} else if (nic->tx_frames < min_frames) {
-			if(nic->adaptive_ifs >= 5)
+			if (nic->adaptive_ifs >= 5)
 				nic->adaptive_ifs -= 5;
 		}
-		if(nic->adaptive_ifs != prev)
+		if (nic->adaptive_ifs != prev)
 			e100_exec_cb(nic, NULL, e100_configure);
 	}
 }
@@ -1579,12 +1579,12 @@ static void e100_watchdog(unsigned long data)
 
 	mii_ethtool_gset(&nic->mii, &cmd);
 
-	if(mii_link_ok(&nic->mii) && !netif_carrier_ok(nic->netdev)) {
+	if (mii_link_ok(&nic->mii) && !netif_carrier_ok(nic->netdev)) {
 		printk(KERN_INFO "e100: %s NIC Link is Up %s Mbps %s Duplex\n",
 		       nic->netdev->name,
 		       cmd.speed == SPEED_100 ? "100" : "10",
 		       cmd.duplex == DUPLEX_FULL ? "Full" : "Half");
-	} else if(!mii_link_ok(&nic->mii) && netif_carrier_ok(nic->netdev)) {
+	} else if (!mii_link_ok(&nic->mii) && netif_carrier_ok(nic->netdev)) {
 		printk(KERN_INFO "e100: %s NIC Link is Down\n",
 		       nic->netdev->name);
 	}
@@ -1604,11 +1604,11 @@ static void e100_watchdog(unsigned long data)
 	e100_update_stats(nic);
 	e100_adjust_adaptive_ifs(nic, cmd.speed, cmd.duplex);
 
-	if(nic->mac <= mac_82557_D100_C)
+	if (nic->mac <= mac_82557_D100_C)
 		/* Issue a multicast command to workaround a 557 lock up */
 		e100_set_multicast_list(nic->netdev);
 
-	if(nic->flags & ich && cmd.speed==SPEED_10 && cmd.duplex==DUPLEX_HALF)
+	if (nic->flags & ich && cmd.speed==SPEED_10 && cmd.duplex==DUPLEX_HALF)
 		/* Need SW workaround for ICH[x] 10Mbps/half duplex Tx hang. */
 		nic->flags |= ich_10h_workaround;
 	else
@@ -1623,7 +1623,7 @@ static void e100_xmit_prepare(struct nic *nic, struct cb *cb,
 {
 	cb->command = nic->tx_command;
 	/* interrupt every 16 packets regardless of delay */
-	if((nic->cbs_avail & ~15) == nic->cbs_avail)
+	if ((nic->cbs_avail & ~15) == nic->cbs_avail)
 		cb->command |= cpu_to_le16(cb_i);
 	cb->u.tcb.tbd_array = cb->dma_addr + offsetof(struct cb, u.tcb.tbd);
 	cb->u.tcb.tcb_byte_count = 0;
@@ -1640,18 +1640,18 @@ static int e100_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	struct nic *nic = netdev_priv(netdev);
 	int err;
 
-	if(nic->flags & ich_10h_workaround) {
+	if (nic->flags & ich_10h_workaround) {
 		/* SW workaround for ICH[x] 10Mbps/half duplex Tx hang.
 		   Issue a NOP command followed by a 1us delay before
 		   issuing the Tx command. */
-		if(e100_exec_cmd(nic, cuc_nop, 0))
+		if (e100_exec_cmd(nic, cuc_nop, 0))
 			DPRINTK(TX_ERR, DEBUG, "exec cuc_nop failed\n");
 		udelay(1);
 	}
 
 	err = e100_exec_cb(nic, skb, e100_xmit_prepare);
 
-	switch(err) {
+	switch (err) {
 	case -ENOSPC:
 		/* We queued the skb, but now we're out of space. */
 		DPRINTK(TX_ERR, DEBUG, "No space for CB\n");
@@ -1677,14 +1677,14 @@ static int e100_tx_clean(struct nic *nic)
 	spin_lock(&nic->cb_lock);
 
 	/* Clean CBs marked complete */
-	for(cb = nic->cb_to_clean;
+	for (cb = nic->cb_to_clean;
 	    cb->status & cpu_to_le16(cb_complete);
 	    cb = nic->cb_to_clean = cb->next) {
 		DPRINTK(TX_DONE, DEBUG, "cb[%d]->status = 0x%04X\n",
 		        (int)(((void*)cb - (void*)nic->cbs)/sizeof(struct cb)),
 		        cb->status);
 
-		if(likely(cb->skb != NULL)) {
+		if (likely(cb->skb != NULL)) {
 			dev->stats.tx_packets++;
 			dev->stats.tx_bytes += cb->skb->len;
 
@@ -1703,7 +1703,7 @@ static int e100_tx_clean(struct nic *nic)
 	spin_unlock(&nic->cb_lock);
 
 	/* Recover from running out of Tx resources in xmit_frame */
-	if(unlikely(tx_cleaned && netif_queue_stopped(nic->netdev)))
+	if (unlikely(tx_cleaned && netif_queue_stopped(nic->netdev)))
 		netif_wake_queue(nic->netdev);
 
 	return tx_cleaned;
@@ -1711,10 +1711,10 @@ static int e100_tx_clean(struct nic *nic)
 
 static void e100_clean_cbs(struct nic *nic)
 {
-	if(nic->cbs) {
-		while(nic->cbs_avail != nic->params.cbs.count) {
+	if (nic->cbs) {
+		while (nic->cbs_avail != nic->params.cbs.count) {
 			struct cb *cb = nic->cb_to_clean;
-			if(cb->skb) {
+			if (cb->skb) {
 				pci_unmap_single(nic->pdev,
 					le32_to_cpu(cb->u.tcb.tbd.buf_addr),
 					le16_to_cpu(cb->u.tcb.tbd.size),
@@ -1746,10 +1746,10 @@ static int e100_alloc_cbs(struct nic *nic)
 
 	nic->cbs = pci_alloc_consistent(nic->pdev,
 		sizeof(struct cb) * count, &nic->cbs_dma_addr);
-	if(!nic->cbs)
+	if (!nic->cbs)
 		return -ENOMEM;
 
-	for(cb = nic->cbs, i = 0; i < count; cb++, i++) {
+	for (cb = nic->cbs, i = 0; i < count; cb++, i++) {
 		cb->next = (i + 1 < count) ? cb + 1 : nic->cbs;
 		cb->prev = (i == 0) ? nic->cbs + count - 1 : cb - 1;
 
@@ -1767,14 +1767,14 @@ static int e100_alloc_cbs(struct nic *nic)
 
 static inline void e100_start_receiver(struct nic *nic, struct rx *rx)
 {
-	if(!nic->rxs) return;
-	if(RU_SUSPENDED != nic->ru_running) return;
+	if (!nic->rxs) return;
+	if (RU_SUSPENDED != nic->ru_running) return;
 
 	/* handle init time starts */
-	if(!rx) rx = nic->rxs;
+	if (!rx) rx = nic->rxs;
 
 	/* (Re)start RU if suspended or idle and RFA is non-NULL */
-	if(rx->skb) {
+	if (rx->skb) {
 		e100_exec_cmd(nic, ruc_start, rx->dma_addr);
 		nic->ru_running = RU_RUNNING;
 	}
@@ -1783,7 +1783,7 @@ static inline void e100_start_receiver(struct nic *nic, struct rx *rx)
 #define RFD_BUF_LEN (sizeof(struct rfd) + VLAN_ETH_FRAME_LEN)
 static int e100_rx_alloc_skb(struct nic *nic, struct rx *rx)
 {
-	if(!(rx->skb = netdev_alloc_skb(nic->netdev, RFD_BUF_LEN + NET_IP_ALIGN)))
+	if (!(rx->skb = netdev_alloc_skb(nic->netdev, RFD_BUF_LEN + NET_IP_ALIGN)))
 		return -ENOMEM;
 
 	/* Align, init, and map the RFD. */
@@ -1820,7 +1820,7 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 	struct rfd *rfd = (struct rfd *)skb->data;
 	u16 rfd_status, actual_size;
 
-	if(unlikely(work_done && *work_done >= work_to_do))
+	if (unlikely(work_done && *work_done >= work_to_do))
 		return -EAGAIN;
 
 	/* Need to sync before taking a peek at cb_complete bit */
@@ -1847,7 +1847,7 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 
 	/* Get actual data size */
 	actual_size = le16_to_cpu(rfd->actual_size) & 0x3FFF;
-	if(unlikely(actual_size > RFD_BUF_LEN - sizeof(struct rfd)))
+	if (unlikely(actual_size > RFD_BUF_LEN - sizeof(struct rfd)))
 		actual_size = RFD_BUF_LEN - sizeof(struct rfd);
 
 	/* Get data */
@@ -1872,10 +1872,10 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 	skb_put(skb, actual_size);
 	skb->protocol = eth_type_trans(skb, nic->netdev);
 
-	if(unlikely(!(rfd_status & cb_ok))) {
+	if (unlikely(!(rfd_status & cb_ok))) {
 		/* Don't indicate if hardware indicates errors */
 		dev_kfree_skb_any(skb);
-	} else if(actual_size > ETH_DATA_LEN + VLAN_ETH_HLEN) {
+	} else if (actual_size > ETH_DATA_LEN + VLAN_ETH_HLEN) {
 		/* Don't indicate oversized frames */
 		nic->rx_over_length_errors++;
 		dev_kfree_skb_any(skb);
@@ -1883,7 +1883,7 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += actual_size;
 		netif_receive_skb(skb);
-		if(work_done)
+		if (work_done)
 			(*work_done)++;
 	}
 
@@ -1901,7 +1901,7 @@ static void e100_rx_clean(struct nic *nic, unsigned int *work_done,
 	struct rfd *old_before_last_rfd, *new_before_last_rfd;
 
 	/* Indicate newly arrived packets */
-	for(rx = nic->rx_to_clean; rx->skb; rx = nic->rx_to_clean = rx->next) {
+	for (rx = nic->rx_to_clean; rx->skb; rx = nic->rx_to_clean = rx->next) {
 		err = e100_rx_indicate(nic, rx, work_done, work_to_do);
 		/* Hit quota or no more to clean */
 		if (-EAGAIN == err || -ENODATA == err)
@@ -1922,8 +1922,8 @@ static void e100_rx_clean(struct nic *nic, unsigned int *work_done,
 	old_before_last_rfd = (struct rfd *)old_before_last_rx->skb->data;
 
 	/* Alloc new skbs to refill list */
-	for(rx = nic->rx_to_use; !rx->skb; rx = nic->rx_to_use = rx->next) {
-		if(unlikely(e100_rx_alloc_skb(nic, rx)))
+	for (rx = nic->rx_to_use; !rx->skb; rx = nic->rx_to_use = rx->next) {
+		if (unlikely(e100_rx_alloc_skb(nic, rx)))
 			break; /* Better luck next time (see watchdog) */
 	}
 
@@ -1959,11 +1959,11 @@ static void e100_rx_clean(struct nic *nic, unsigned int *work_done,
 			PCI_DMA_BIDIRECTIONAL);
 	}
 
-	if(restart_required) {
+	if (restart_required) {
 		// ack the rnr?
 		iowrite8(stat_ack_rnr, &nic->csr->scb.stat_ack);
 		e100_start_receiver(nic, nic->rx_to_clean);
-		if(work_done)
+		if (work_done)
 			(*work_done)++;
 	}
 }
@@ -1975,9 +1975,9 @@ static void e100_rx_clean_list(struct nic *nic)
 
 	nic->ru_running = RU_UNINITIALIZED;
 
-	if(nic->rxs) {
-		for(rx = nic->rxs, i = 0; i < count; rx++, i++) {
-			if(rx->skb) {
+	if (nic->rxs) {
+		for (rx = nic->rxs, i = 0; i < count; rx++, i++) {
+			if (rx->skb) {
 				pci_unmap_single(nic->pdev, rx->dma_addr,
 					RFD_BUF_LEN, PCI_DMA_BIDIRECTIONAL);
 				dev_kfree_skb(rx->skb);
@@ -1999,13 +1999,13 @@ static int e100_rx_alloc_list(struct nic *nic)
 	nic->rx_to_use = nic->rx_to_clean = NULL;
 	nic->ru_running = RU_UNINITIALIZED;
 
-	if(!(nic->rxs = kcalloc(count, sizeof(struct rx), GFP_ATOMIC)))
+	if (!(nic->rxs = kcalloc(count, sizeof(struct rx), GFP_ATOMIC)))
 		return -ENOMEM;
 
-	for(rx = nic->rxs, i = 0; i < count; rx++, i++) {
+	for (rx = nic->rxs, i = 0; i < count; rx++, i++) {
 		rx->next = (i + 1 < count) ? rx + 1 : nic->rxs;
 		rx->prev = (i == 0) ? nic->rxs + count - 1 : rx - 1;
-		if(e100_rx_alloc_skb(nic, rx)) {
+		if (e100_rx_alloc_skb(nic, rx)) {
 			e100_rx_clean_list(nic);
 			return -ENOMEM;
 		}
@@ -2038,7 +2038,7 @@ static irqreturn_t e100_intr(int irq, void *dev_id)
 
 	DPRINTK(INTR, DEBUG, "stat_ack = 0x%02X\n", stat_ack);
 
-	if(stat_ack == stat_ack_not_ours ||	/* Not our interrupt */
+	if (stat_ack == stat_ack_not_ours ||	/* Not our interrupt */
 	   stat_ack == stat_ack_not_present)	/* Hardware is ejected */
 		return IRQ_NONE;
 
@@ -2046,10 +2046,10 @@ static irqreturn_t e100_intr(int irq, void *dev_id)
 	iowrite8(stat_ack, &nic->csr->scb.stat_ack);
 
 	/* We hit Receive No Resource (RNR); restart RU after cleaning */
-	if(stat_ack & stat_ack_rnr)
+	if (stat_ack & stat_ack_rnr)
 		nic->ru_running = RU_SUSPENDED;
 
-	if(likely(netif_rx_schedule_prep(&nic->napi))) {
+	if (likely(netif_rx_schedule_prep(&nic->napi))) {
 		e100_disable_irq(nic);
 		__netif_rx_schedule(&nic->napi);
 	}
@@ -2102,7 +2102,7 @@ static int e100_set_mac_address(struct net_device *netdev, void *p)
 
 static int e100_change_mtu(struct net_device *netdev, int new_mtu)
 {
-	if(new_mtu < ETH_ZLEN || new_mtu > ETH_DATA_LEN)
+	if (new_mtu < ETH_ZLEN || new_mtu > ETH_DATA_LEN)
 		return -EINVAL;
 	netdev->mtu = new_mtu;
 	return 0;
@@ -2121,16 +2121,16 @@ static int e100_up(struct nic *nic)
 {
 	int err;
 
-	if((err = e100_rx_alloc_list(nic)))
+	if ((err = e100_rx_alloc_list(nic)))
 		return err;
-	if((err = e100_alloc_cbs(nic)))
+	if ((err = e100_alloc_cbs(nic)))
 		goto err_rx_clean_list;
-	if((err = e100_hw_init(nic)))
+	if ((err = e100_hw_init(nic)))
 		goto err_clean_cbs;
 	e100_set_multicast_list(nic->netdev);
 	e100_start_receiver(nic, NULL);
 	mod_timer(&nic->watchdog, jiffies);
-	if((err = request_irq(nic->pdev->irq, e100_intr, IRQF_SHARED,
+	if ((err = request_irq(nic->pdev->irq, e100_intr, IRQF_SHARED,
 		nic->netdev->name, nic->netdev)))
 		goto err_no_irq;
 	netif_wake_queue(nic->netdev);
@@ -2192,26 +2192,26 @@ static int e100_loopback_test(struct nic *nic, enum loopback loopback_mode)
 	 * in loopback mode, and the test passes if the received
 	 * packet compares byte-for-byte to the transmitted packet. */
 
-	if((err = e100_rx_alloc_list(nic)))
+	if ((err = e100_rx_alloc_list(nic)))
 		return err;
-	if((err = e100_alloc_cbs(nic)))
+	if ((err = e100_alloc_cbs(nic)))
 		goto err_clean_rx;
 
 	/* ICH PHY loopback is broken so do MAC loopback instead */
-	if(nic->flags & ich && loopback_mode == lb_phy)
+	if (nic->flags & ich && loopback_mode == lb_phy)
 		loopback_mode = lb_mac;
 
 	nic->loopback = loopback_mode;
-	if((err = e100_hw_init(nic)))
+	if ((err = e100_hw_init(nic)))
 		goto err_loopback_none;
 
-	if(loopback_mode == lb_phy)
+	if (loopback_mode == lb_phy)
 		mdio_write(nic->netdev, nic->mii.phy_id, MII_BMCR,
 			BMCR_LOOPBACK);
 
 	e100_start_receiver(nic, NULL);
 
-	if(!(skb = netdev_alloc_skb(nic->netdev, ETH_DATA_LEN))) {
+	if (!(skb = netdev_alloc_skb(nic->netdev, ETH_DATA_LEN))) {
 		err = -ENOMEM;
 		goto err_loopback_none;
 	}
@@ -2224,7 +2224,7 @@ static int e100_loopback_test(struct nic *nic, enum loopback loopback_mode)
 	pci_dma_sync_single_for_cpu(nic->pdev, nic->rx_to_clean->dma_addr,
 			RFD_BUF_LEN, PCI_DMA_BIDIRECTIONAL);
 
-	if(memcmp(nic->rx_to_clean->skb->data + sizeof(struct rfd),
+	if (memcmp(nic->rx_to_clean->skb->data + sizeof(struct rfd),
 	   skb->data, ETH_DATA_LEN))
 		err = -EAGAIN;
 
@@ -2301,7 +2301,7 @@ static void e100_get_regs(struct net_device *netdev,
 	buff[0] = ioread8(&nic->csr->scb.cmd_hi) << 24 |
 		ioread8(&nic->csr->scb.cmd_lo) << 16 |
 		ioread16(&nic->csr->scb.status);
-	for(i = E100_PHY_REGS; i >= 0; i--)
+	for (i = E100_PHY_REGS; i >= 0; i--)
 		buff[1 + E100_PHY_REGS - i] =
 			mdio_read(netdev, nic->mii.phy_id, i);
 	memset(nic->mem->dump_buf, 0, sizeof(nic->mem->dump_buf));
@@ -2326,7 +2326,7 @@ static int e100_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	    !device_can_wakeup(&nic->pdev->dev))
 		return -EOPNOTSUPP;
 
-	if(wol->wolopts)
+	if (wol->wolopts)
 		nic->flags |= wol_magic;
 	else
 		nic->flags &= ~wol_magic;
@@ -2385,7 +2385,7 @@ static int e100_set_eeprom(struct net_device *netdev,
 {
 	struct nic *nic = netdev_priv(netdev);
 
-	if(eeprom->magic != E100_EEPROM_MAGIC)
+	if (eeprom->magic != E100_EEPROM_MAGIC)
 		return -EINVAL;
 
 	memcpy(&((u8 *)nic->eeprom)[eeprom->offset], bytes, eeprom->len);
@@ -2421,7 +2421,7 @@ static int e100_set_ringparam(struct net_device *netdev,
 	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
 		return -EINVAL;
 
-	if(netif_running(netdev))
+	if (netif_running(netdev))
 		e100_down(nic);
 	rfds->count = max(ring->rx_pending, rfds->min);
 	rfds->count = min(rfds->count, rfds->max);
@@ -2429,7 +2429,7 @@ static int e100_set_ringparam(struct net_device *netdev,
 	cbs->count = min(cbs->count, cbs->max);
 	DPRINTK(DRV, INFO, "Ring Param settings: rx: %d, tx %d\n",
 	        rfds->count, cbs->count);
-	if(netif_running(netdev))
+	if (netif_running(netdev))
 		e100_up(nic);
 
 	return 0;
@@ -2454,12 +2454,12 @@ static void e100_diag_test(struct net_device *netdev,
 	memset(data, 0, E100_TEST_LEN * sizeof(u64));
 	data[0] = !mii_link_ok(&nic->mii);
 	data[1] = e100_eeprom_load(nic);
-	if(test->flags & ETH_TEST_FL_OFFLINE) {
+	if (test->flags & ETH_TEST_FL_OFFLINE) {
 
 		/* save speed, duplex & autoneg settings */
 		err = mii_ethtool_gset(&nic->mii, &cmd);
 
-		if(netif_running(netdev))
+		if (netif_running(netdev))
 			e100_down(nic);
 		data[2] = e100_self_test(nic);
 		data[3] = e100_loopback_test(nic, lb_mac);
@@ -2468,10 +2468,10 @@ static void e100_diag_test(struct net_device *netdev,
 		/* restore speed, duplex & autoneg settings */
 		err = mii_ethtool_sset(&nic->mii, &cmd);
 
-		if(netif_running(netdev))
+		if (netif_running(netdev))
 			e100_up(nic);
 	}
-	for(i = 0; i < E100_TEST_LEN; i++)
+	for (i = 0; i < E100_TEST_LEN; i++)
 		test->flags |= data[i] ? ETH_TEST_FL_FAILED : 0;
 
 	msleep_interruptible(4 * 1000);
@@ -2481,7 +2481,7 @@ static int e100_phys_id(struct net_device *netdev, u32 data)
 {
 	struct nic *nic = netdev_priv(netdev);
 
-	if(!data || data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ))
+	if (!data || data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ))
 		data = (u32)(MAX_SCHEDULE_TIMEOUT / HZ);
 	mod_timer(&nic->blink_timer, jiffies);
 	msleep_interruptible(data * 1000);
@@ -2524,7 +2524,7 @@ static void e100_get_ethtool_stats(struct net_device *netdev,
 	struct nic *nic = netdev_priv(netdev);
 	int i;
 
-	for(i = 0; i < E100_NET_STATS_LEN; i++)
+	for (i = 0; i < E100_NET_STATS_LEN; i++)
 		data[i] = ((unsigned long *)&netdev->stats)[i];
 
 	data[i++] = nic->tx_deferred;
@@ -2539,7 +2539,7 @@ static void e100_get_ethtool_stats(struct net_device *netdev,
 
 static void e100_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 {
-	switch(stringset) {
+	switch (stringset) {
 	case ETH_SS_TEST:
 		memcpy(data, *e100_gstrings_test, sizeof(e100_gstrings_test));
 		break;
@@ -2589,7 +2589,7 @@ static int e100_alloc(struct nic *nic)
 
 static void e100_free(struct nic *nic)
 {
-	if(nic->mem) {
+	if (nic->mem) {
 		pci_free_consistent(nic->pdev, sizeof(struct mem),
 			nic->mem, nic->dma_addr);
 		nic->mem = NULL;
@@ -2602,7 +2602,7 @@ static int e100_open(struct net_device *netdev)
 	int err = 0;
 
 	netif_carrier_off(netdev);
-	if((err = e100_up(nic)))
+	if ((err = e100_up(nic)))
 		DPRINTK(IFUP, ERR, "Cannot open interface, aborting.\n");
 	return err;
 }
@@ -2635,8 +2635,8 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	struct nic *nic;
 	int err;
 
-	if(!(netdev = alloc_etherdev(sizeof(struct nic)))) {
-		if(((1 << debug) - 1) & NETIF_MSG_PROBE)
+	if (!(netdev = alloc_etherdev(sizeof(struct nic)))) {
+		if (((1 << debug) - 1) & NETIF_MSG_PROBE)
 			printk(KERN_ERR PFX "Etherdev alloc failed, abort.\n");
 		return -ENOMEM;
 	}
@@ -2653,24 +2653,24 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	nic->msg_enable = (1 << debug) - 1;
 	pci_set_drvdata(pdev, netdev);
 
-	if((err = pci_enable_device(pdev))) {
+	if ((err = pci_enable_device(pdev))) {
 		DPRINTK(PROBE, ERR, "Cannot enable PCI device, aborting.\n");
 		goto err_out_free_dev;
 	}
 
-	if(!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
+	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
 		DPRINTK(PROBE, ERR, "Cannot find proper PCI device "
 			"base address, aborting.\n");
 		err = -ENODEV;
 		goto err_out_disable_pdev;
 	}
 
-	if((err = pci_request_regions(pdev, DRV_NAME))) {
+	if ((err = pci_request_regions(pdev, DRV_NAME))) {
 		DPRINTK(PROBE, ERR, "Cannot obtain PCI resources, aborting.\n");
 		goto err_out_disable_pdev;
 	}
 
-	if((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
+	if ((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
 		DPRINTK(PROBE, ERR, "No usable DMA configuration, aborting.\n");
 		goto err_out_free_res;
 	}
@@ -2681,13 +2681,13 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 		DPRINTK(PROBE, INFO, "using i/o access mode\n");
 
 	nic->csr = pci_iomap(pdev, (use_io ? 1 : 0), sizeof(struct csr));
-	if(!nic->csr) {
+	if (!nic->csr) {
 		DPRINTK(PROBE, ERR, "Cannot map device registers, aborting.\n");
 		err = -ENOMEM;
 		goto err_out_free_res;
 	}
 
-	if(ent->driver_data)
+	if (ent->driver_data)
 		nic->flags |= ich;
 	else
 		nic->flags &= ~ich;
@@ -2715,12 +2715,12 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 
 	INIT_WORK(&nic->tx_timeout_task, e100_tx_timeout_task);
 
-	if((err = e100_alloc(nic))) {
+	if ((err = e100_alloc(nic))) {
 		DPRINTK(PROBE, ERR, "Cannot alloc driver memory, aborting.\n");
 		goto err_out_iounmap;
 	}
 
-	if((err = e100_eeprom_load(nic)))
+	if ((err = e100_eeprom_load(nic)))
 		goto err_out_free;
 
 	e100_phy_init(nic);
@@ -2740,7 +2740,7 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	}
 
 	/* Wol magic packet can be enabled from eeprom */
-	if((nic->mac >= mac_82558_D101_A4) &&
+	if ((nic->mac >= mac_82558_D101_A4) &&
 	   (nic->eeprom[eeprom_id] & eeprom_id_wol)) {
 		nic->flags |= wol_magic;
 		device_set_wakeup_enable(&pdev->dev, true);
@@ -2750,7 +2750,7 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	pci_pme_active(pdev, false);
 
 	strcpy(netdev->name, "eth%d");
-	if((err = register_netdev(netdev))) {
+	if ((err = register_netdev(netdev))) {
 		DPRINTK(PROBE, ERR, "Cannot register net device, aborting.\n");
 		goto err_out_free;
 	}
@@ -2779,7 +2779,7 @@ static void __devexit e100_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 
-	if(netdev) {
+	if (netdev) {
 		struct nic *nic = netdev_priv(netdev);
 		unregister_netdev(netdev);
 		e100_free(nic);
@@ -2932,7 +2932,7 @@ static struct pci_driver e100_driver = {
 
 static int __init e100_init_module(void)
 {
-	if(((1 << debug) - 1) & NETIF_MSG_DRV) {
+	if (((1 << debug) - 1) & NETIF_MSG_DRV) {
 		printk(KERN_INFO PFX "%s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
 		printk(KERN_INFO PFX "%s\n", DRV_COPYRIGHT);
 	}

