From: Johannes Berg <johannes@sipsolutions.net>
Subject: convert more to %pM
Date: Sat, 25 Oct 2008 02:35:06 +0200
Message-ID: <1224894906.3919.45.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Joe Perches <joe@perches.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:53947 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148AbYJYAfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 20:35:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A number of places still use %02x:...:%02x because it's
in debug statements or for no real reason. Make a few
of them use %pM.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
Gave up after a while, there are more.

 arch/sparc64/kernel/idprom.c            |    5 +----
 arch/um/drivers/net_kern.c              |    7 +------
 arch/xtensa/platforms/iss/network.c     |    5 +----
 drivers/media/dvb/b2c2/flexcop.c        |    2 +-
 drivers/media/dvb/bt8xx/dst.c           |    4 +---
 drivers/media/dvb/dm1105/dm1105.c       |    3 +--
 drivers/media/dvb/dvb-usb/dvb-usb-dvb.c |    5 +----
 drivers/media/dvb/pluto2/pluto2.c       |    3 +--
 drivers/message/fusion/mptlan.c         |   18 +++++++-----------
 drivers/net/bnx2x_main.c                |    7 ++-----
 drivers/net/de620.c                     |    5 +----
 drivers/net/e1000e/netdev.c             |   11 +++--------
 drivers/net/enic/enic_res.c             |    7 ++-----
 drivers/net/enic/vnic_dev.c             |   10 ++--------
 drivers/net/fs_enet/fs_enet-main.c      |    5 +----
 drivers/net/ibm_newemac/core.c          |   11 +++--------
 drivers/net/igb/igb_main.c              |    6 ++----
 drivers/net/ioc3-eth.c                  |    7 ++-----
 drivers/net/ixgbe/ixgbe_main.c          |    6 ++----
 drivers/net/jme.c                       |   12 ++----------
 drivers/net/ps3_gelic_wireless.c        |    6 +-----
 drivers/net/qlge/qlge_main.c            |   11 +++--------
 drivers/net/wireless/wavelan_cs.c       |    8 +-------
 drivers/s390/net/qeth_l2_main.c         |   18 ++++++------------
 drivers/usb/atm/cxacru.c                |    4 +---
 drivers/usb/atm/usbatm.c                |    5 +----
 26 files changed, 50 insertions(+), 141 deletions(-)

--- test-tree.orig/arch/sparc64/kernel/idprom.c	2008-10-24 12:58:45.000000000 +0200
+++ test-tree/arch/sparc64/kernel/idprom.c	2008-10-25 02:25:46.000000000 +0200
@@ -42,8 +42,5 @@ void __init idprom_init(void)
 			    idprom->id_cksum, calc_idprom_cksum(idprom));
 	}
 
-	printk("Ethernet address: %02x:%02x:%02x:%02x:%02x:%02x\n",
-	       idprom->id_ethaddr[0], idprom->id_ethaddr[1],
-	       idprom->id_ethaddr[2], idprom->id_ethaddr[3],
-	       idprom->id_ethaddr[4], idprom->id_ethaddr[5]);
+	printk("Ethernet address: %pM\n", idprom->id_ethaddr);
 }
--- test-tree.orig/arch/um/drivers/net_kern.c	2008-10-24 12:58:45.000000000 +0200
+++ test-tree/arch/um/drivers/net_kern.c	2008-10-25 02:25:46.000000000 +0200
@@ -418,12 +418,7 @@ static void eth_configure(int n, void *i
 
 	setup_etheraddr(mac, device->mac, dev->name);
 
-	printk(KERN_INFO "Netdevice %d ", n);
-	printk("(%02x:%02x:%02x:%02x:%02x:%02x) ",
-	       device->mac[0], device->mac[1],
-	       device->mac[2], device->mac[3],
-	       device->mac[4], device->mac[5]);
-	printk(": ");
+	printk(KERN_INFO "Netdevice %d (%pM) : ", n, device->mac);
 
 	lp = dev->priv;
 	/* This points to the transport private data. It's still clear, but we
--- test-tree.orig/arch/xtensa/platforms/iss/network.c	2008-10-25 01:57:16.000000000 +0200
+++ test-tree/arch/xtensa/platforms/iss/network.c	2008-10-25 02:25:46.000000000 +0200
@@ -660,10 +660,7 @@ static int iss_net_configure(int index, 
 
 	printk(KERN_INFO "Netdevice %d ", index);
 	if (lp->have_mac)
-		printk("(%02x:%02x:%02x:%02x:%02x:%02x) ",
-				lp->mac[0], lp->mac[1],
-				lp->mac[2], lp->mac[3],
-				lp->mac[4], lp->mac[5]);
+		printk("(%pM) ", lp->mac);
 	printk(": ");
 
 	/* sysfs register */
--- test-tree.orig/drivers/media/dvb/b2c2/flexcop.c	2008-10-24 12:58:45.000000000 +0200
+++ test-tree/drivers/media/dvb/b2c2/flexcop.c	2008-10-25 02:25:46.000000000 +0200
@@ -270,7 +270,7 @@ int flexcop_device_initialize(struct fle
 	/* do the MAC address reading after initializing the dvb_adapter */
 	if (fc->get_mac_addr(fc, 0) == 0) {
 		u8 *b = fc->dvb_adapter.proposed_mac;
-		info("MAC address = %02x:%02x:%02x:%02x:%02x:%02x", b[0],b[1],b[2],b[3],b[4],b[5]);
+		info("MAC address = %pM", b);
 		flexcop_set_mac_filter(fc,b);
 		flexcop_mac_filter_ctrl(fc,1);
 	} else
--- test-tree.orig/drivers/media/dvb/bt8xx/dst.c	2008-10-24 12:58:45.000000000 +0200
+++ test-tree/drivers/media/dvb/bt8xx/dst.c	2008-10-25 02:25:46.000000000 +0200
@@ -917,9 +917,7 @@ static int dst_get_mac(struct dst_state 
 	}
 	memset(&state->mac_address, '\0', 8);
 	memcpy(&state->mac_address, &state->rxbuffer, 6);
-	dprintk(verbose, DST_ERROR, 1, "MAC Address=[%02x:%02x:%02x:%02x:%02x:%02x]",
-		state->mac_address[0], state->mac_address[1], state->mac_address[2],
-		state->mac_address[4], state->mac_address[5], state->mac_address[6]);
+	dprintk(verbose, DST_ERROR, 1, "MAC Address=[%pM]", state->mac_address);
 
 	return 0;
 }
--- test-tree.orig/drivers/media/dvb/dm1105/dm1105.c	2008-10-24 12:58:45.000000000 +0200
+++ test-tree/drivers/media/dvb/dm1105/dm1105.c	2008-10-25 02:25:47.000000000 +0200
@@ -697,8 +697,7 @@ static void __devinit dm1105dvb_read_mac
 	};
 
 	dm1105_i2c_xfer(&dm1105dvb->i2c_adap, msg , 2);
-	dev_info(&dm1105dvb->pdev->dev, "MAC %02x:%02x:%02x:%02x:%02x:%02x\n",
-			mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
+	dev_info(&dm1105dvb->pdev->dev, "MAC %pM\n", mac);
 }
 
 static int __devinit dm1105_probe(struct pci_dev *pdev,
--- test-tree.orig/drivers/media/dvb/dvb-usb/dvb-usb-dvb.c	2008-10-24 12:58:45.000000000 +0200
+++ test-tree/drivers/media/dvb/dvb-usb/dvb-usb-dvb.c	2008-10-25 02:25:47.000000000 +0200
@@ -91,10 +91,7 @@ int dvb_usb_adapter_dvb_init(struct dvb_
 
 	if (adap->dev->props.read_mac_address) {
 		if (adap->dev->props.read_mac_address(adap->dev,adap->dvb_adap.proposed_mac) == 0)
-			info("MAC address: %02x:%02x:%02x:%02x:%02x:%02x",adap->dvb_adap.proposed_mac[0],
-					adap->dvb_adap.proposed_mac[1], adap->dvb_adap.proposed_mac[2],
-					adap->dvb_adap.proposed_mac[3], adap->dvb_adap.proposed_mac[4],
-					adap->dvb_adap.proposed_mac[5]);
+			info("MAC address: %pM",adap->dvb_adap.proposed_mac);
 		else
 			err("MAC address reading failed.");
 	}
--- test-tree.orig/drivers/media/dvb/pluto2/pluto2.c	2008-10-24 12:58:45.000000000 +0200
+++ test-tree/drivers/media/dvb/pluto2/pluto2.c	2008-10-25 02:25:47.000000000 +0200
@@ -560,8 +560,7 @@ static void __devinit pluto_read_mac(str
 	mac[4] = (val >> 8) & 0xff;
 	mac[5] = (val >> 0) & 0xff;
 
-	dev_info(&pluto->pdev->dev, "MAC %02x:%02x:%02x:%02x:%02x:%02x\n",
-			mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
+	dev_info(&pluto->pdev->dev, "MAC %pM\n", mac);
 }
 
 static int __devinit pluto_read_serial(struct pluto *pluto)
--- test-tree.orig/drivers/message/fusion/mptlan.c	2008-10-24 12:58:46.000000000 +0200
+++ test-tree/drivers/message/fusion/mptlan.c	2008-10-25 02:29:37.000000000 +0200
@@ -1462,11 +1462,9 @@ mptlan_probe(struct pci_dev *pdev, const
 		printk(KERN_INFO MYNAM ": %s: Fusion MPT LAN device "
 		       "registered as '%s'\n", ioc->name, dev->name);
 		printk(KERN_INFO MYNAM ": %s/%s: "
-		       "LanAddr = %02X:%02X:%02X:%02X:%02X:%02X\n",
+		       "LanAddr = %pM\n",
 		       IOC_AND_NETDEV_NAMES_s_s(dev),
-		       dev->dev_addr[0], dev->dev_addr[1],
-		       dev->dev_addr[2], dev->dev_addr[3],
-		       dev->dev_addr[4], dev->dev_addr[5]);
+		       dev->dev_addr);
 	
 		ioc->netdev = dev;
 
@@ -1551,9 +1549,8 @@ mpt_lan_type_trans(struct sk_buff *skb, 
 
 		printk (KERN_WARNING MYNAM ": %s: WARNING - Broadcast swap F/W bug detected!\n",
 				NETDEV_PTR_TO_IOC_NAME_s(dev));
-		printk (KERN_WARNING MYNAM ": Please update sender @ MAC_addr = %02x:%02x:%02x:%02x:%02x:%02x\n",
-				fch->saddr[0], fch->saddr[1], fch->saddr[2],
-				fch->saddr[3], fch->saddr[4], fch->saddr[5]);
+		printk (KERN_WARNING MYNAM ": Please update sender @ MAC_addr = %pM\n",
+				fch->saddr);
 	}
 
 	if (*fch->daddr & 1) {
@@ -1628,10 +1625,9 @@ mpt_lan_type_trans(struct sk_buff *skb, 
 				nh->NAA = source_naa; /* Set the S_NAA value. */
 				for (i = 0; i < FC_ALEN; i++)
 					nh->ieee[i] = fch->saddr[i];
-				dlprintk ((KERN_INFO "Got ARP from %02x:%02x:%02x:%02x:"
-					  "%02x:%02x with non-compliant S_NAA value.\n",
-					  fch->saddr[0], fch->saddr[1], fch->saddr[2],
-					  fch->saddr[3], fch->saddr[4],fch->saddr[5]));
+				dlprintk ((KERN_INFO "Got ARP from %pM with"
+					  " non-compliant S_NAA value.\n",
+					  fch->saddr));
 			} else {
 				printk (KERN_ERR "mptlan/type_trans: Unable to"
 					" kmalloc a NAA_Hosed struct.\n");
--- test-tree.orig/drivers/net/bnx2x_main.c	2008-10-25 02:15:59.000000000 +0200
+++ test-tree/drivers/net/bnx2x_main.c	2008-10-25 02:25:47.000000000 +0200
@@ -9851,11 +9851,8 @@ static void bnx2x_set_rx_mode(struct net
 			     mclist && (i < dev->mc_count);
 			     i++, mclist = mclist->next) {
 
-				DP(NETIF_MSG_IFUP, "Adding mcast MAC: "
-				   "%02x:%02x:%02x:%02x:%02x:%02x\n",
-				   mclist->dmi_addr[0], mclist->dmi_addr[1],
-				   mclist->dmi_addr[2], mclist->dmi_addr[3],
-				   mclist->dmi_addr[4], mclist->dmi_addr[5]);
+				DP(NETIF_MSG_IFUP, "Adding mcast MAC: %pM\n",
+				   mclist->dmi_addr);
 
 				crc = crc32c_le(0, mclist->dmi_addr, ETH_ALEN);
 				bit = (crc >> 24) & 0xff;
--- test-tree.orig/drivers/net/de620.c	2008-10-25 02:15:59.000000000 +0200
+++ test-tree/drivers/net/de620.c	2008-10-25 02:25:47.000000000 +0200
@@ -875,10 +875,7 @@ struct net_device * __init de620_probe(i
 	if (de620_debug) {
 		printk("\nEEPROM contents:\n");
 		printk("RAM_Size = 0x%02X\n", nic_data.RAM_Size);
-		printk("NodeID = %02X:%02X:%02X:%02X:%02X:%02X\n",
-			nic_data.NodeID[0], nic_data.NodeID[1],
-			nic_data.NodeID[2], nic_data.NodeID[3],
-			nic_data.NodeID[4], nic_data.NodeID[5]);
+		printk("NodeID = %pM\n", nic_data.NodeID);
 		printk("Model = %d\n", nic_data.Model);
 		printk("Media = %d\n", nic_data.Media);
 		printk("SCR = 0x%02x\n", nic_data.SCR);
--- test-tree.orig/drivers/net/e1000e/netdev.c	2008-10-24 12:58:46.000000000 +0200
+++ test-tree/drivers/net/e1000e/netdev.c	2008-10-25 02:25:47.000000000 +0200
@@ -4652,14 +4652,12 @@ static void e1000_print_device_info(stru
 	u32 pba_num;
 
 	/* print bus type/speed/width info */
-	e_info("(PCI Express:2.5GB/s:%s) %02x:%02x:%02x:%02x:%02x:%02x\n",
+	e_info("(PCI Express:2.5GB/s:%s) %pM\n",
 	       /* bus width */
 	       ((hw->bus.width == e1000_bus_width_pcie_x4) ? "Width x4" :
 	        "Width x1"),
 	       /* MAC address */
-	       netdev->dev_addr[0], netdev->dev_addr[1],
-	       netdev->dev_addr[2], netdev->dev_addr[3],
-	       netdev->dev_addr[4], netdev->dev_addr[5]);
+	       netdev->dev_addr);
 	e_info("Intel(R) PRO/%s Network Connection\n",
 	       (hw->phy.type == e1000_phy_ife) ? "10/100" : "1000");
 	e1000e_read_pba_num(hw, &pba_num);
@@ -4906,10 +4904,7 @@ static int __devinit e1000_probe(struct 
 	memcpy(netdev->perm_addr, adapter->hw.mac.addr, netdev->addr_len);
 
 	if (!is_valid_ether_addr(netdev->perm_addr)) {
-		e_err("Invalid MAC Address: %02x:%02x:%02x:%02x:%02x:%02x\n",
-		      netdev->perm_addr[0], netdev->perm_addr[1],
-		      netdev->perm_addr[2], netdev->perm_addr[3],
-		      netdev->perm_addr[4], netdev->perm_addr[5]);
+		e_err("Invalid MAC Address: %pM\n", netdev->perm_addr);
 		err = -EIO;
 		goto err_eeprom;
 	}
--- test-tree.orig/drivers/net/enic/enic_res.c	2008-10-24 12:58:46.000000000 +0200
+++ test-tree/drivers/net/enic/enic_res.c	2008-10-25 02:25:47.000000000 +0200
@@ -90,11 +90,8 @@ int enic_get_vnic_config(struct enic *en
 
 	c->intr_timer = min_t(u16, VNIC_INTR_TIMER_MAX, c->intr_timer);
 
-	printk(KERN_INFO PFX "vNIC MAC addr %02x:%02x:%02x:%02x:%02x:%02x "
-		"wq/rq %d/%d\n",
-		enic->mac_addr[0], enic->mac_addr[1], enic->mac_addr[2],
-		enic->mac_addr[3], enic->mac_addr[4], enic->mac_addr[5],
-		c->wq_desc_count, c->rq_desc_count);
+	printk(KERN_INFO PFX "vNIC MAC addr %pM wq/rq %d/%d\n",
+		enic->mac_addr, c->wq_desc_count, c->rq_desc_count);
 	printk(KERN_INFO PFX "vNIC mtu %d csum tx/rx %d/%d tso/lro %d/%d "
 		"intr timer %d\n",
 		c->mtu, ENIC_SETTING(enic, TXCSUM),
--- test-tree.orig/drivers/net/enic/vnic_dev.c	2008-10-24 12:58:46.000000000 +0200
+++ test-tree/drivers/net/enic/vnic_dev.c	2008-10-25 02:25:47.000000000 +0200
@@ -489,10 +489,7 @@ void vnic_dev_add_addr(struct vnic_dev *
 
 	err = vnic_dev_cmd(vdev, CMD_ADDR_ADD, &a0, &a1, wait);
 	if (err)
-		printk(KERN_ERR
-			"Can't add addr [%02x:%02x:%02x:%02x:%02x:%02x], %d\n",
-			addr[0], addr[1], addr[2], addr[3], addr[4], addr[5],
-			err);
+		printk(KERN_ERR "Can't add addr [%pM], %d\n", addr, err);
 }
 
 void vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr)
@@ -507,10 +504,7 @@ void vnic_dev_del_addr(struct vnic_dev *
 
 	err = vnic_dev_cmd(vdev, CMD_ADDR_DEL, &a0, &a1, wait);
 	if (err)
-		printk(KERN_ERR
-			"Can't del addr [%02x:%02x:%02x:%02x:%02x:%02x], %d\n",
-			addr[0], addr[1], addr[2], addr[3], addr[4], addr[5],
-			err);
+		printk(KERN_ERR "Can't del addr [%pM], %d\n", addr, err);
 }
 
 int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr)
--- test-tree.orig/drivers/net/fs_enet/fs_enet-main.c	2008-10-24 12:58:46.000000000 +0200
+++ test-tree/drivers/net/fs_enet/fs_enet-main.c	2008-10-25 02:31:25.000000000 +0200
@@ -1115,10 +1115,7 @@ static int __devinit fs_enet_probe(struc
 	if (ret)
 		goto out_free_bd;
 
-	printk(KERN_INFO "%s: fs_enet: %02x:%02x:%02x:%02x:%02x:%02x\n",
-	       ndev->name,
-	       ndev->dev_addr[0], ndev->dev_addr[1], ndev->dev_addr[2],
-	       ndev->dev_addr[3], ndev->dev_addr[4], ndev->dev_addr[5]);
+	printk(KERN_INFO "%s: fs_enet: %pM\n", ndev->name, ndev->dev_addr);
 
 	return 0;
 
--- test-tree.orig/drivers/net/ibm_newemac/core.c	2008-10-25 01:57:17.000000000 +0200
+++ test-tree/drivers/net/ibm_newemac/core.c	2008-10-25 02:25:47.000000000 +0200
@@ -396,9 +396,7 @@ static void emac_hash_mc(struct emac_ins
 
 	for (dmi = dev->ndev->mc_list; dmi; dmi = dmi->next) {
 		int slot, reg, mask;
-		DBG2(dev, "mc %02x:%02x:%02x:%02x:%02x:%02x" NL,
-		     dmi->dmi_addr[0], dmi->dmi_addr[1], dmi->dmi_addr[2],
-		     dmi->dmi_addr[3], dmi->dmi_addr[4], dmi->dmi_addr[5]);
+		DBG2(dev, "mc %pM" NL, dmi->dmi_addr);
 
 		slot = EMAC_XAHT_CRC_TO_SLOT(dev, ether_crc(ETH_ALEN, dmi->dmi_addr));
 		reg = EMAC_XAHT_SLOT_TO_REG(dev, slot);
@@ -2857,11 +2855,8 @@ static int __devinit emac_probe(struct o
 	wake_up_all(&emac_probe_wait);
 
 
-	printk(KERN_INFO
-	       "%s: EMAC-%d %s, MAC %02x:%02x:%02x:%02x:%02x:%02x\n",
-	       ndev->name, dev->cell_index, np->full_name,
-	       ndev->dev_addr[0], ndev->dev_addr[1], ndev->dev_addr[2],
-	       ndev->dev_addr[3], ndev->dev_addr[4], ndev->dev_addr[5]);
+	printk(KERN_INFO "%s: EMAC-%d %s, MAC %pM\n",
+	       ndev->name, dev->cell_index, np->full_name, ndev->dev_addr);
 
 	if (dev->phy_mode == PHY_MODE_SGMII)
 		printk(KERN_NOTICE "%s: in SGMII mode\n", ndev->name);
--- test-tree.orig/drivers/net/igb/igb_main.c	2008-10-24 12:58:46.000000000 +0200
+++ test-tree/drivers/net/igb/igb_main.c	2008-10-25 02:25:47.000000000 +0200
@@ -1275,16 +1275,14 @@ static int __devinit igb_probe(struct pc
 
 	dev_info(&pdev->dev, "Intel(R) Gigabit Ethernet Network Connection\n");
 	/* print bus type/speed/width info */
-	dev_info(&pdev->dev,
-		 "%s: (PCIe:%s:%s) %02x:%02x:%02x:%02x:%02x:%02x\n",
+	dev_info(&pdev->dev, "%s: (PCIe:%s:%s) %pM\n",
 		 netdev->name,
 		 ((hw->bus.speed == e1000_bus_speed_2500)
 		  ? "2.5Gb/s" : "unknown"),
 		 ((hw->bus.width == e1000_bus_width_pcie_x4)
 		  ? "Width x4" : (hw->bus.width == e1000_bus_width_pcie_x1)
 		  ? "Width x1" : "unknown"),
-		 netdev->dev_addr[0], netdev->dev_addr[1], netdev->dev_addr[2],
-		 netdev->dev_addr[3], netdev->dev_addr[4], netdev->dev_addr[5]);
+		 netdev->dev_addr);
 
 	igb_read_part_num(hw, &part_num);
 	dev_info(&pdev->dev, "%s: PBA No: %06x-%03x\n", netdev->name,
--- test-tree.orig/drivers/net/ioc3-eth.c	2008-10-25 02:15:59.000000000 +0200
+++ test-tree/drivers/net/ioc3-eth.c	2008-10-25 02:25:47.000000000 +0200
@@ -390,11 +390,8 @@ static int nic_init(struct ioc3 *ioc3)
 	}
 
 	printk("Found %s NIC", type);
-	if (type != unknown) {
-		printk (" registration number %02x:%02x:%02x:%02x:%02x:%02x,"
-			" CRC %02x", serial[0], serial[1], serial[2],
-			serial[3], serial[4], serial[5], crc);
-	}
+	if (type != unknown)
+		printk (" registration number %pM, CRC %02x", serial, crc);
 	printk(".\n");
 
 	return 0;
--- test-tree.orig/drivers/net/ixgbe/ixgbe_main.c	2008-10-24 12:58:46.000000000 +0200
+++ test-tree/drivers/net/ixgbe/ixgbe_main.c	2008-10-25 02:25:47.000000000 +0200
@@ -3877,8 +3877,7 @@ static int __devinit ixgbe_probe(struct 
 	pci_read_config_word(pdev, IXGBE_PCI_LINK_STATUS, &link_status);
 	link_speed = link_status & IXGBE_PCI_LINK_SPEED;
 	link_width = link_status & IXGBE_PCI_LINK_WIDTH;
-	dev_info(&pdev->dev, "(PCI Express:%s:%s) "
-	         "%02x:%02x:%02x:%02x:%02x:%02x\n",
+	dev_info(&pdev->dev, "(PCI Express:%s:%s) %pM\n",
 	        ((link_speed == IXGBE_PCI_LINK_SPEED_5000) ? "5.0Gb/s" :
 	         (link_speed == IXGBE_PCI_LINK_SPEED_2500) ? "2.5Gb/s" :
 	         "Unknown"),
@@ -3887,8 +3886,7 @@ static int __devinit ixgbe_probe(struct 
 	         (link_width == IXGBE_PCI_LINK_WIDTH_2) ? "Width x2" :
 	         (link_width == IXGBE_PCI_LINK_WIDTH_1) ? "Width x1" :
 	         "Unknown"),
-	        netdev->dev_addr[0], netdev->dev_addr[1], netdev->dev_addr[2],
-	        netdev->dev_addr[3], netdev->dev_addr[4], netdev->dev_addr[5]);
+	        netdev->dev_addr);
 	ixgbe_read_pba_num_generic(hw, &part_num);
 	dev_info(&pdev->dev, "MAC: %d, PHY: %d, PBA No: %06x-%03x\n",
 	         hw->mac.type, hw->phy.type,
--- test-tree.orig/drivers/net/jme.c	2008-10-24 12:58:46.000000000 +0200
+++ test-tree/drivers/net/jme.c	2008-10-25 02:25:47.000000000 +0200
@@ -2862,18 +2862,10 @@ jme_init_one(struct pci_dev *pdev,
 		goto err_out_free_shadow;
 	}
 
-	msg_probe(jme,
-		"JMC250 gigabit%s ver:%x rev:%x "
-		"macaddr:%02x:%02x:%02x:%02x:%02x:%02x\n",
+	msg_probe(jme, "JMC250 gigabit%s ver:%x rev:%x macaddr:%pM\n",
 		(jme->fpgaver != 0) ? " (FPGA)" : "",
 		(jme->fpgaver != 0) ? jme->fpgaver : jme->chiprev,
-		jme->rev,
-		netdev->dev_addr[0],
-		netdev->dev_addr[1],
-		netdev->dev_addr[2],
-		netdev->dev_addr[3],
-		netdev->dev_addr[4],
-		netdev->dev_addr[5]);
+		jme->rev, netdev->dev_addr);
 
 	return 0;
 
--- test-tree.orig/drivers/net/ps3_gelic_wireless.c	2008-10-25 02:15:59.000000000 +0200
+++ test-tree/drivers/net/ps3_gelic_wireless.c	2008-10-25 02:25:47.000000000 +0200
@@ -1165,11 +1165,7 @@ static int gelic_wl_set_ap(struct net_de
 		       ETH_ALEN);
 		set_bit(GELIC_WL_STAT_BSSID_SET, &wl->stat);
 		set_bit(GELIC_WL_STAT_CONFIGURED, &wl->stat);
-		pr_debug("%s: bss=%02x:%02x:%02x:%02x:%02x:%02x\n",
-			 __func__,
-			 wl->bssid[0], wl->bssid[1],
-			 wl->bssid[2], wl->bssid[3],
-			 wl->bssid[4], wl->bssid[5]);
+		pr_debug("%s: bss=%pM\n", __func__, wl->bssid);
 	} else {
 		pr_debug("%s: clear bssid\n", __func__);
 		clear_bit(GELIC_WL_STAT_BSSID_SET, &wl->stat);
--- test-tree.orig/drivers/net/qlge/qlge_main.c	2008-10-24 12:58:46.000000000 +0200
+++ test-tree/drivers/net/qlge/qlge_main.c	2008-10-25 02:25:47.000000000 +0200
@@ -336,12 +336,11 @@ static int ql_set_mac_addr_reg(struct ql
 			    (addr[5]);
 
 			QPRINTK(qdev, IFUP, INFO,
-				"Adding %s address %02x:%02x:%02x:%02x:%02x:%02x"
+				"Adding %s address %pM"
 				" at index %d in the CAM.\n",
 				((type ==
 				  MAC_ADDR_TYPE_MULTI_MAC) ? "MULTICAST" :
-				 "UNICAST"), addr[0], addr[1], addr[2], addr[3],
-				addr[4], addr[5], index);
+				 "UNICAST"), addr, index);
 
 			status =
 			    ql_wait_reg_rdy(qdev,
@@ -3127,11 +3126,7 @@ static void ql_display_dev_info(struct n
 		qdev->chip_rev_id >> 4 & 0x0000000f,
 		qdev->chip_rev_id >> 8 & 0x0000000f,
 		qdev->chip_rev_id >> 12 & 0x0000000f);
-	QPRINTK(qdev, PROBE, INFO,
-		"MAC address %02x:%02x:%02x:%02x:%02x:%02x\n",
-		ndev->dev_addr[0], ndev->dev_addr[1],
-		ndev->dev_addr[2], ndev->dev_addr[3], ndev->dev_addr[4],
-		ndev->dev_addr[5]);
+	QPRINTK(qdev, PROBE, INFO, "MAC address %pM\n", ndev->dev_addr);
 }
 
 static int ql_adapter_down(struct ql_adapter *qdev)
--- test-tree.orig/drivers/net/wireless/wavelan_cs.c	2008-10-25 02:16:00.000000000 +0200
+++ test-tree/drivers/net/wireless/wavelan_cs.c	2008-10-25 02:25:47.000000000 +0200
@@ -2235,13 +2235,7 @@ static int wavelan_set_wap(struct net_de
 			   char *extra)
 {
 #ifdef DEBUG_IOCTL_INFO
-	printk(KERN_DEBUG "Set AP to : %02X:%02X:%02X:%02X:%02X:%02X\n",
-	       wrqu->ap_addr.sa_data[0],
-	       wrqu->ap_addr.sa_data[1],
-	       wrqu->ap_addr.sa_data[2],
-	       wrqu->ap_addr.sa_data[3],
-	       wrqu->ap_addr.sa_data[4],
-	       wrqu->ap_addr.sa_data[5]);
+	printk(KERN_DEBUG "Set AP to : %pM\n", wrqu->ap_addr.sa_data);
 #endif	/* DEBUG_IOCTL_INFO */
 
 	return -EOPNOTSUPP;
--- test-tree.orig/drivers/s390/net/qeth_l2_main.c	2008-10-24 12:58:45.000000000 +0200
+++ test-tree/drivers/s390/net/qeth_l2_main.c	2008-10-25 02:25:47.000000000 +0200
@@ -131,17 +131,13 @@ static int qeth_l2_send_setgroupmac_cb(s
 	mac = &cmd->data.setdelmac.mac[0];
 	/* MAC already registered, needed in couple/uncouple case */
 	if (cmd->hdr.return_code == 0x2005) {
-		QETH_DBF_MESSAGE(2, "Group MAC %02x:%02x:%02x:%02x:%02x:%02x "
-			  "already existing on %s \n",
-			  mac[0], mac[1], mac[2], mac[3], mac[4], mac[5],
-			  QETH_CARD_IFNAME(card));
+		QETH_DBF_MESSAGE(2, "Group MAC %pM already existing on %s \n",
+			  mac, QETH_CARD_IFNAME(card));
 		cmd->hdr.return_code = 0;
 	}
 	if (cmd->hdr.return_code)
-		QETH_DBF_MESSAGE(2, "Could not set group MAC "
-			  "%02x:%02x:%02x:%02x:%02x:%02x on %s: %x\n",
-			  mac[0], mac[1], mac[2], mac[3], mac[4], mac[5],
-			  QETH_CARD_IFNAME(card), cmd->hdr.return_code);
+		QETH_DBF_MESSAGE(2, "Could not set group MAC %pM on %s: %x\n",
+			  mac, QETH_CARD_IFNAME(card), cmd->hdr.return_code);
 	return 0;
 }
 
@@ -163,10 +159,8 @@ static int qeth_l2_send_delgroupmac_cb(s
 	cmd = (struct qeth_ipa_cmd *) data;
 	mac = &cmd->data.setdelmac.mac[0];
 	if (cmd->hdr.return_code)
-		QETH_DBF_MESSAGE(2, "Could not delete group MAC "
-			  "%02x:%02x:%02x:%02x:%02x:%02x on %s: %x\n",
-			  mac[0], mac[1], mac[2], mac[3], mac[4], mac[5],
-			  QETH_CARD_IFNAME(card), cmd->hdr.return_code);
+		QETH_DBF_MESSAGE(2, "Could not delete group MAC %pM on %s: %x\n",
+			  mac, QETH_CARD_IFNAME(card), cmd->hdr.return_code);
 	return 0;
 }
 
--- test-tree.orig/drivers/usb/atm/cxacru.c	2008-10-24 12:58:45.000000000 +0200
+++ test-tree/drivers/usb/atm/cxacru.c	2008-10-25 02:25:47.000000000 +0200
@@ -286,9 +286,7 @@ static ssize_t cxacru_sysfs_show_mac_add
 	struct usbatm_data *usbatm_instance = usb_get_intfdata(intf);
 	struct atm_dev *atm_dev = usbatm_instance->atm_dev;
 
-	return snprintf(buf, PAGE_SIZE, "%02x:%02x:%02x:%02x:%02x:%02x\n",
-			atm_dev->esi[0], atm_dev->esi[1], atm_dev->esi[2],
-			atm_dev->esi[3], atm_dev->esi[4], atm_dev->esi[5]);
+	return snprintf(buf, PAGE_SIZE, "%pM\n", atm_dev->esi);
 }
 
 static ssize_t cxacru_sysfs_show_adsl_state(struct device *dev,
--- test-tree.orig/drivers/usb/atm/usbatm.c	2008-10-24 12:58:45.000000000 +0200
+++ test-tree/drivers/usb/atm/usbatm.c	2008-10-25 02:25:47.000000000 +0200
@@ -770,10 +770,7 @@ static int usbatm_atm_proc_read(struct a
 		return sprintf(page, "%s\n", instance->description);
 
 	if (!left--)
-		return sprintf(page, "MAC: %02x:%02x:%02x:%02x:%02x:%02x\n",
-			       atm_dev->esi[0], atm_dev->esi[1],
-			       atm_dev->esi[2], atm_dev->esi[3],
-			       atm_dev->esi[4], atm_dev->esi[5]);
+		return sprintf(page, "MAC: %pM\n", atm_dev->esi);
 
 	if (!left--)
 		return sprintf(page,


