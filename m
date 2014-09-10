From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers/net: Convert remaining uses of pr_warning
 to pr_warn
Date: Tue, 09 Sep 2014 20:27:44 -0700
Message-ID: <1410319664.24028.6.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the much more common pr_warn instead of pr_warning.

Other miscellanea:

o Typo fixes submiting/submitting
o Coalesce formats
o Realign arguments
o Add missing terminating '\n' to formats

Signed-off-by: Joe Perches <joe@perches.com>
---

Most of these are old drivers so I'm not cc'ing everyone.
Let me know if you want these separated or simply dropped.

This does add a long line for a coalesced variable.
I think it reads better whole than in pieces.

 drivers/net/ethernet/3com/3c509.c                  |  6 ++---
 drivers/net/ethernet/3com/3c515.c                  | 25 +++++++++----------
 drivers/net/ethernet/3com/3c59x.c                  | 27 +++++++++++----------
 drivers/net/ethernet/broadcom/b44.c                |  2 +-
 drivers/net/ethernet/cisco/enic/vnic_dev.c         |  3 +--
 drivers/net/ethernet/marvell/skge.c                |  6 ++---
 drivers/net/ethernet/marvell/sky2.c                |  2 +-
 drivers/net/ethernet/packetengines/yellowfin.c     |  4 ++--
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |  5 ++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |  2 +-
 drivers/net/ethernet/sun/cassini.c                 |  2 +-
 drivers/net/ethernet/sun/niu.c                     |  4 ++--
 drivers/net/ethernet/sun/sunvnet.c                 |  2 +-
 drivers/net/ethernet/tile/tilepro.c                |  8 +++----
 drivers/net/wireless/mwifiex/usb.c                 |  2 +-
 drivers/net/wireless/orinoco/orinoco_usb.c         | 28 +++++++++++-----------
 drivers/net/wireless/ti/wlcore/debug.h             |  2 +-
 17 files changed, 62 insertions(+), 68 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index a968654..9f23b36 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -695,9 +695,9 @@ el3_tx_timeout (struct net_device *dev)
 	int ioaddr = dev->base_addr;
 
 	/* Transmitter timeout, serious problems. */
-	pr_warning("%s: transmit timed out, Tx_status %2.2x status %4.4x Tx FIFO room %d.\n",
-		   dev->name, inb(ioaddr + TX_STATUS), inw(ioaddr + EL3_STATUS),
-		   inw(ioaddr + TX_FREE));
+	pr_warn("%s: transmit timed out, Tx_status %2.2x status %4.4x Tx FIFO room %d\n",
+		dev->name, inb(ioaddr + TX_STATUS), inw(ioaddr + EL3_STATUS),
+		inw(ioaddr + TX_FREE));
 	dev->stats.tx_errors++;
 	dev->trans_start = jiffies; /* prevent tx timeout */
 	/* Issue TX_RESET and TX_START commands. */
diff --git a/drivers/net/ethernet/3com/3c515.c b/drivers/net/ethernet/3com/3c515.c
index 94c656f..942fb0d 100644
--- a/drivers/net/ethernet/3com/3c515.c
+++ b/drivers/net/ethernet/3com/3c515.c
@@ -515,7 +515,7 @@ static struct net_device *corkscrew_scan(int unit)
 			if (pnp_device_attach(idev) < 0)
 				continue;
 			if (pnp_activate_dev(idev) < 0) {
-				pr_warning("pnp activate failed (out of resources?)\n");
+				pr_warn("pnp activate failed (out of resources?)\n");
 				pnp_device_detach(idev);
 				continue;
 			}
@@ -659,7 +659,7 @@ static int corkscrew_setup(struct net_device *dev, int ioaddr,
 	pr_cont(", IRQ %d\n", dev->irq);
 	/* Tell them about an invalid IRQ. */
 	if (corkscrew_debug && (dev->irq <= 0 || dev->irq > 15))
-		pr_warning(" *** Warning: this IRQ is unlikely to work! ***\n");
+		pr_warn(" *** Warning: this IRQ is unlikely to work! ***\n");
 
 	{
 		static const char * const ram_split[] = {
@@ -967,13 +967,13 @@ static void corkscrew_timeout(struct net_device *dev)
 	struct corkscrew_private *vp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
-	pr_warning("%s: transmit timed out, tx_status %2.2x status %4.4x.\n",
-	       dev->name, inb(ioaddr + TxStatus),
-	       inw(ioaddr + EL3_STATUS));
+	pr_warn("%s: transmit timed out, tx_status %2.2x status %4.4x\n",
+		dev->name, inb(ioaddr + TxStatus),
+		inw(ioaddr + EL3_STATUS));
 	/* Slight code bloat to be user friendly. */
 	if ((inb(ioaddr + TxStatus) & 0x88) == 0x88)
-		pr_warning("%s: Transmitter encountered 16 collisions --"
-		       " network cable problem?\n", dev->name);
+		pr_warn("%s: Transmitter encountered 16 collisions -- network cable problem?\n",
+			dev->name);
 #ifndef final_version
 	pr_debug("  Flags; bus-master %d, full %d; dirty %d current %d.\n",
 	       vp->full_bus_master_tx, vp->tx_full, vp->dirty_tx,
@@ -1382,13 +1382,10 @@ static int boomerang_rx(struct net_device *dev)
 				temp = skb_put(skb, pkt_len);
 				/* Remove this checking code for final release. */
 				if (isa_bus_to_virt(vp->rx_ring[entry].addr) != temp)
-					pr_warning("%s: Warning -- the skbuff addresses do not match"
-					     " in boomerang_rx: %p vs. %p / %p.\n",
-					     dev->name,
-					     isa_bus_to_virt(vp->
-							 rx_ring[entry].
-							 addr), skb->head,
-					     temp);
+					pr_warn("%s: Warning -- the skbuff addresses do not match in boomerang_rx: %p vs. %p / %p\n",
+						dev->name,
+						isa_bus_to_virt(vp->rx_ring[entry].addr),
+						skb->head, temp);
 				rx_nocopy++;
 			}
 			skb->protocol = eth_type_trans(skb, dev);
diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 3fe45c7..2b92d712 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -1310,8 +1310,8 @@ static int vortex_probe1(struct device *gendev, void __iomem *ioaddr, int irq,
 		pr_cont(", IRQ %d\n", dev->irq);
 	/* Tell them about an invalid IRQ. */
 	if (dev->irq <= 0 || dev->irq >= nr_irqs)
-		pr_warning(" *** Warning: IRQ %d is unlikely to work! ***\n",
-			   dev->irq);
+		pr_warn(" *** Warning: IRQ %d is unlikely to work! ***\n",
+			dev->irq);
 
 	step = (window_read8(vp, 4, Wn4_NetDiag) & 0x1e) >> 1;
 	if (print_info) {
@@ -1425,7 +1425,7 @@ static int vortex_probe1(struct device *gendev, void __iomem *ioaddr, int irq,
 		}
 		mii_preamble_required--;
 		if (phy_idx == 0) {
-			pr_warning("  ***WARNING*** No MII transceivers found!\n");
+			pr_warn("  ***WARNING*** No MII transceivers found!\n");
 			vp->phys[0] = 24;
 		} else {
 			vp->advertising = mdio_read(dev, vp->phys[0], MII_ADVERTISE);
@@ -1566,8 +1566,7 @@ vortex_up(struct net_device *dev)
 			pci_restore_state(VORTEX_PCI(vp));
 		err = pci_enable_device(VORTEX_PCI(vp));
 		if (err) {
-			pr_warning("%s: Could not enable device\n",
-				dev->name);
+			pr_warn("%s: Could not enable device\n", dev->name);
 			goto err_out;
 		}
 	}
@@ -2007,8 +2006,8 @@ vortex_error(struct net_device *dev, int status)
 		/* This occurs when we have the wrong media type! */
 		if (DoneDidThat == 0  &&
 			ioread16(ioaddr + EL3_STATUS) & StatsFull) {
-			pr_warning("%s: Updating statistics failed, disabling "
-				   "stats as an interrupt source.\n", dev->name);
+			pr_warn("%s: Updating statistics failed, disabling stats as an interrupt source\n",
+				dev->name);
 			iowrite16(SetIntrEnb |
 				  (window_read16(vp, 5, 10) & ~StatsFull),
 				  ioaddr + EL3_CMD);
@@ -2147,8 +2146,8 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (vp->cur_tx - vp->dirty_tx >= TX_RING_SIZE) {
 		if (vortex_debug > 0)
-			pr_warning("%s: BUG! Tx Ring full, refusing to send buffer.\n",
-				   dev->name);
+			pr_warn("%s: BUG! Tx Ring full, refusing to send buffer\n",
+				dev->name);
 		netif_stop_queue(dev);
 		return NETDEV_TX_BUSY;
 	}
@@ -2311,7 +2310,7 @@ vortex_interrupt(int irq, void *dev_id)
 		}
 
 		if (--work_done < 0) {
-			pr_warning("%s: Too much work in interrupt, status %4.4x.\n",
+			pr_warn("%s: Too much work in interrupt, status %4.4x\n",
 				dev->name, status);
 			/* Disable all pending interrupts. */
 			do {
@@ -2444,7 +2443,7 @@ boomerang_interrupt(int irq, void *dev_id)
 			vortex_error(dev, status);
 
 		if (--work_done < 0) {
-			pr_warning("%s: Too much work in interrupt, status %4.4x.\n",
+			pr_warn("%s: Too much work in interrupt, status %4.4x\n",
 				dev->name, status);
 			/* Disable all pending interrupts. */
 			do {
@@ -2620,7 +2619,8 @@ boomerang_rx(struct net_device *dev)
 			if (skb == NULL) {
 				static unsigned long last_jif;
 				if (time_after(jiffies, last_jif + 10 * HZ)) {
-					pr_warning("%s: memory shortage\n", dev->name);
+					pr_warn("%s: memory shortage\n",
+						dev->name);
 					last_jif = jiffies;
 				}
 				if ((vp->cur_rx - vp->dirty_rx) == RX_RING_SIZE)
@@ -2719,7 +2719,8 @@ vortex_close(struct net_device *dev)
 	if (vp->rx_csumhits &&
 	    (vp->drv_flags & HAS_HWCKSM) == 0 &&
 	    (vp->card_idx >= MAX_UNITS || hw_checksums[vp->card_idx] == -1)) {
-		pr_warning("%s supports hardware checksums, and we're not using them!\n", dev->name);
+		pr_warn("%s supports hardware checksums, and we're not using them!\n",
+			dev->name);
 	}
 #endif
 
diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 4a7028d..56fadbd 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -427,7 +427,7 @@ static void b44_wap54g10_workaround(struct b44 *bp)
 	}
 	return;
 error:
-	pr_warning("PHY: cannot reset MII transceiver isolate bit\n");
+	pr_warn("PHY: cannot reset MII transceiver isolate bit\n");
 }
 #else
 static inline void b44_wap54g10_workaround(struct b44 *bp)
diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
index 37472ce..62f7b7b 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.c
@@ -847,8 +847,7 @@ int vnic_dev_intr_coal_timer_info(struct vnic_dev *vdev)
 	 */
 	if ((err == ERR_ECMDUNKNOWN) ||
 		(!err && !(vdev->args[0] && vdev->args[1] && vdev->args[2]))) {
-		pr_warning("Using default conversion factor for "
-			"interrupt coalesce timer\n");
+		pr_warn("Using default conversion factor for interrupt coalesce timer\n");
 		vnic_dev_intr_coal_timer_info_default(vdev);
 		return 0;
 	}
diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 24b2422..264eab7 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -1107,7 +1107,7 @@ static u16 xm_phy_read(struct skge_hw *hw, int port, u16 reg)
 {
 	u16 v = 0;
 	if (__xm_phy_read(hw, port, reg, &v))
-		pr_warning("%s: phy read timed out\n", hw->dev[port]->name);
+		pr_warn("%s: phy read timed out\n", hw->dev[port]->name);
 	return v;
 }
 
@@ -1903,7 +1903,7 @@ static int gm_phy_write(struct skge_hw *hw, int port, u16 reg, u16 val)
 			return 0;
 	}
 
-	pr_warning("%s: phy write timeout\n", hw->dev[port]->name);
+	pr_warn("%s: phy write timeout\n", hw->dev[port]->name);
 	return -EIO;
 }
 
@@ -1931,7 +1931,7 @@ static u16 gm_phy_read(struct skge_hw *hw, int port, u16 reg)
 {
 	u16 v = 0;
 	if (__gm_phy_read(hw, port, reg, &v))
-		pr_warning("%s: phy read timeout\n", hw->dev[port]->name);
+		pr_warn("%s: phy read timeout\n", hw->dev[port]->name);
 	return v;
 }
 
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index dba48a5c..bd33662 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -2814,7 +2814,7 @@ static int sky2_status_intr(struct sky2_hw *hw, int to_do, u16 idx)
 
 		default:
 			if (net_ratelimit())
-				pr_warning("unknown status opcode 0x%x\n", opcode);
+				pr_warn("unknown status opcode 0x%x\n", opcode);
 		}
 	} while (hw->st_idx != idx);
 
diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
index 2d6b148..fa2db41 100644
--- a/drivers/net/ethernet/packetengines/yellowfin.c
+++ b/drivers/net/ethernet/packetengines/yellowfin.c
@@ -693,11 +693,11 @@ static void yellowfin_tx_timeout(struct net_device *dev)
 	/* Note: these should be KERN_DEBUG. */
 	if (yellowfin_debug) {
 		int i;
-		pr_warning("  Rx ring %p: ", yp->rx_ring);
+		pr_warn("  Rx ring %p: ", yp->rx_ring);
 		for (i = 0; i < RX_RING_SIZE; i++)
 			pr_cont(" %08x", yp->rx_ring[i].result_status);
 		pr_cont("\n");
-		pr_warning("  Tx ring %p: ", yp->tx_ring);
+		pr_warn("  Tx ring %p: ", yp->tx_ring);
 		for (i = 0; i < TX_RING_SIZE; i++)
 			pr_cont(" %04x /%08x",
 			       yp->tx_status[i].tx_errs,
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 1159031..32456c7 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -1477,9 +1477,8 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	u32 val;
 
 	if (pdev->revision >= NX_P3_A0 && pdev->revision <= NX_P3_B1) {
-		pr_warning("%s: chip revisions between 0x%x-0x%x "
-				"will not be enabled.\n",
-				module_name(THIS_MODULE), NX_P3_A0, NX_P3_B1);
+		pr_warn("%s: chip revisions between 0x%x-0x%x will not be enabled\n",
+			module_name(THIS_MODULE), NX_P3_A0, NX_P3_B1);
 		return -ENODEV;
 	}
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index 8dd0408..b735fa2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -282,7 +282,7 @@ int stmmac_mdio_register(struct net_device *ndev)
 	}
 
 	if (!found) {
-		pr_warning("%s: No PHY found\n", ndev->name);
+		pr_warn("%s: No PHY found\n", ndev->name);
 		mdiobus_unregister(new_bus);
 		mdiobus_free(new_bus);
 		return -ENODEV;
diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index 37f87ff..02d370e 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -4962,7 +4962,7 @@ static int cas_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	pci_cmd |= PCI_COMMAND_PARITY;
 	pci_write_config_word(pdev, PCI_COMMAND, pci_cmd);
 	if (pci_try_set_mwi(pdev))
-		pr_warning("Could not enable MWI for %s\n", pci_name(pdev));
+		pr_warn("Could not enable MWI for %s\n", pci_name(pdev));
 
 	cas_program_bridge(pdev);
 
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 8216be4..904fd1a 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -8717,8 +8717,8 @@ static void niu_divide_channels(struct niu_parent *parent,
 			parent->txchan_per_port[i] = 1;
 	}
 	if (tot_rx < NIU_NUM_RXCHAN || tot_tx < NIU_NUM_TXCHAN) {
-		pr_warning("niu%d: Driver bug, wasted channels, RX[%d] TX[%d]\n",
-			   parent->index, tot_rx, tot_tx);
+		pr_warn("niu%d: Driver bug, wasted channels, RX[%d] TX[%d]\n",
+			parent->index, tot_rx, tot_tx);
 	}
 }
 
diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index f675396..78d313d 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -537,7 +537,7 @@ static void vnet_event(void *arg, int event)
 	}
 
 	if (unlikely(event != LDC_EVENT_DATA_READY)) {
-		pr_warning("Unexpected LDC event %d\n", event);
+		pr_warn("Unexpected LDC event %d\n", event);
 		spin_unlock_irqrestore(&vio->lock, flags);
 		return;
 	}
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 3faf03f..fb12d31 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -956,7 +956,7 @@ static int tile_net_open_aux(struct net_device *dev)
 	 */
 	if (hv_dev_pwrite(priv->hv_devhdl, 0, (HV_VirtAddr)&dummy,
 			  sizeof(dummy), NETIO_IPP_START_SHIM_OFF) < 0) {
-		pr_warning("Failed to start LIPP/LEPP.\n");
+		pr_warn("Failed to start LIPP/LEPP\n");
 		return -EIO;
 	}
 
@@ -2399,8 +2399,7 @@ static int __init network_cpus_setup(char *str)
 {
 	int rc = cpulist_parse_crop(str, &network_cpus_map);
 	if (rc != 0) {
-		pr_warning("network_cpus=%s: malformed cpu list\n",
-		       str);
+		pr_warn("network_cpus=%s: malformed cpu list\n", str);
 	} else {
 
 		/* Remove dedicated cpus. */
@@ -2409,8 +2408,7 @@ static int __init network_cpus_setup(char *str)
 
 
 		if (cpumask_empty(&network_cpus_map)) {
-			pr_warning("Ignoring network_cpus='%s'.\n",
-			       str);
+			pr_warn("Ignoring network_cpus='%s'\n", str);
 		} else {
 			char buf[1024];
 			cpulist_scnprintf(buf, sizeof(buf), &network_cpus_map);
diff --git a/drivers/net/wireless/mwifiex/usb.c b/drivers/net/wireless/mwifiex/usb.c
index 7118a18..4371e12 100644
--- a/drivers/net/wireless/mwifiex/usb.c
+++ b/drivers/net/wireless/mwifiex/usb.c
@@ -357,7 +357,7 @@ static int mwifiex_usb_probe(struct usb_interface *intf,
 		card->usb_boot_state = USB8XXX_FW_READY;
 		break;
 	default:
-		pr_warning("unknown id_product %#x\n", id_product);
+		pr_warn("unknown id_product %#x\n", id_product);
 		card->usb_boot_state = USB8XXX_FW_DNLD;
 		break;
 	}
diff --git a/drivers/net/wireless/orinoco/orinoco_usb.c b/drivers/net/wireless/orinoco/orinoco_usb.c
index f4b784f..9958464 100644
--- a/drivers/net/wireless/orinoco/orinoco_usb.c
+++ b/drivers/net/wireless/orinoco/orinoco_usb.c
@@ -534,7 +534,7 @@ static void ezusb_request_out_callback(struct urb *urb)
 
 	if (ctx->killed) {
 		spin_unlock_irqrestore(&upriv->req_lock, flags);
-		pr_warning("interrupt called with dead ctx");
+		pr_warn("interrupt called with dead ctx\n");
 		goto out;
 	}
 
@@ -671,8 +671,8 @@ static void ezusb_request_in_callback(struct ezusb_priv *upriv,
 	default:
 		spin_unlock_irqrestore(&upriv->req_lock, flags);
 
-		pr_warning("Matched IN URB, unexpected context state(0x%x)",
-		     state);
+		pr_warn("Matched IN URB, unexpected context state(0x%x)\n",
+			state);
 		/* Throw this CTX away and try submitting another */
 		del_timer(&ctx->timer);
 		ctx->outurb->transfer_flags |= URB_ASYNC_UNLINK;
@@ -1394,12 +1394,12 @@ static void ezusb_bulk_in_callback(struct urb *urb)
 		/* When a device gets unplugged we get this every time
 		 * we resubmit, flooding the logs.  Since we don't use
 		 * USB timeouts, it shouldn't happen any other time*/
-		pr_warning("%s: urb timed out, not resubmiting", __func__);
+		pr_warn("%s: urb timed out, not resubmitting\n", __func__);
 		return;
 	}
 	if (urb->status == -ECONNABORTED) {
-		pr_warning("%s: connection abort, resubmiting urb",
-		     __func__);
+		pr_warn("%s: connection abort, resubmitting urb\n",
+			__func__);
 		goto resubmit;
 	}
 	if ((urb->status == -EILSEQ)
@@ -1608,7 +1608,7 @@ static int ezusb_probe(struct usb_interface *interface,
 		if (usb_endpoint_is_bulk_in(ep)) {
 			/* we found a bulk in endpoint */
 			if (upriv->read_urb != NULL) {
-				pr_warning("Found a second bulk in ep, ignored");
+				pr_warn("Found a second bulk in ep, ignored\n");
 				continue;
 			}
 
@@ -1618,10 +1618,10 @@ static int ezusb_probe(struct usb_interface *interface,
 				goto error;
 			}
 			if (le16_to_cpu(ep->wMaxPacketSize) != 64)
-				pr_warning("bulk in: wMaxPacketSize!= 64");
+				pr_warn("bulk in: wMaxPacketSize!= 64\n");
 			if (ep->bEndpointAddress != (2 | USB_DIR_IN))
-				pr_warning("bulk in: bEndpointAddress: %d",
-				     ep->bEndpointAddress);
+				pr_warn("bulk in: bEndpointAddress: %d\n",
+					ep->bEndpointAddress);
 			upriv->read_pipe = usb_rcvbulkpipe(udev,
 							 ep->
 							 bEndpointAddress);
@@ -1636,15 +1636,15 @@ static int ezusb_probe(struct usb_interface *interface,
 		if (usb_endpoint_is_bulk_out(ep)) {
 			/* we found a bulk out endpoint */
 			if (upriv->bap_buf != NULL) {
-				pr_warning("Found a second bulk out ep, ignored");
+				pr_warn("Found a second bulk out ep, ignored\n");
 				continue;
 			}
 
 			if (le16_to_cpu(ep->wMaxPacketSize) != 64)
-				pr_warning("bulk out: wMaxPacketSize != 64");
+				pr_warn("bulk out: wMaxPacketSize != 64\n");
 			if (ep->bEndpointAddress != 2)
-				pr_warning("bulk out: bEndpointAddress: %d",
-				     ep->bEndpointAddress);
+				pr_warn("bulk out: bEndpointAddress: %d\n",
+					ep->bEndpointAddress);
 			upriv->write_pipe = usb_sndbulkpipe(udev,
 							  ep->
 							  bEndpointAddress);
diff --git a/drivers/net/wireless/ti/wlcore/debug.h b/drivers/net/wireless/ti/wlcore/debug.h
index 0420bd4..27bfb7c 100644
--- a/drivers/net/wireless/ti/wlcore/debug.h
+++ b/drivers/net/wireless/ti/wlcore/debug.h
@@ -65,7 +65,7 @@ extern u32 wl12xx_debug_level;
 	pr_err(DRIVER_PREFIX "ERROR " fmt "\n", ##arg)
 
 #define wl1271_warning(fmt, arg...) \
-	pr_warning(DRIVER_PREFIX "WARNING " fmt "\n", ##arg)
+	pr_warn(DRIVER_PREFIX "WARNING " fmt "\n", ##arg)
 
 #define wl1271_notice(fmt, arg...) \
 	pr_info(DRIVER_PREFIX fmt "\n", ##arg)
