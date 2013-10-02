From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] net:drivers/net: Miscellaneous
 conversions to ETH_ALEN
Date: Tue, 01 Oct 2013 19:04:40 -0700
Message-ID: <1380679480.2081.24.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, e1000-devel@lists.sourceforge.net,
	brcm80211-dev-list@broadcom.com, linux-usb@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	ath10k@lists.infradead.org, wil6210@qca.qualcomm.com,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	b43-dev@lists.infradead.org, linuxppc-dev@lists.ozlabs.org
To: netdev <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Convert the memset/memcpy uses of 6 to ETH_ALEN
where appropriate.

Also convert some struct definitions and u8 array
declarations of [6] to ETH_ALEN.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/8390/ax88796.c                |  2 +-
 drivers/net/ethernet/amd/atarilance.c              |  4 +-
 drivers/net/ethernet/amd/au1000_eth.c              |  2 +-
 drivers/net/ethernet/amd/pcnet32.c                 |  2 +-
 drivers/net/ethernet/apple/bmac.c                  |  4 +-
 drivers/net/ethernet/broadcom/b44.c                |  2 +-
 drivers/net/ethernet/broadcom/bnx2.c               |  6 +-
 drivers/net/ethernet/broadcom/cnic.c               |  4 +-
 drivers/net/ethernet/broadcom/tg3.c                | 10 +--
 drivers/net/ethernet/chelsio/cxgb/pm3393.c         |  4 +-
 drivers/net/ethernet/davicom/dm9000.c              |  2 +-
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |  2 +-
 drivers/net/ethernet/freescale/ucc_geth.c          |  2 +-
 drivers/net/ethernet/i825xx/82596.c                |  4 +-
 drivers/net/ethernet/i825xx/lib82596.c             |  6 +-
 drivers/net/ethernet/ibm/emac/core.c               |  2 +-
 drivers/net/ethernet/ibm/ibmveth.c                 |  4 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |  2 +-
 drivers/net/ethernet/intel/igbvf/vf.c              |  4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |  9 +--
 drivers/net/ethernet/intel/ixgbevf/vf.c            |  4 +-
 drivers/net/ethernet/jme.c                         |  4 +-
 drivers/net/ethernet/korina.c                      |  2 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c         |  4 +-
 drivers/net/ethernet/micrel/ks8851_mll.c           |  4 +-
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   |  4 +-
 drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |  2 +-
 drivers/net/ethernet/renesas/sh_eth.c              |  2 +-
 drivers/net/ethernet/sgi/meth.c                    |  2 +-
 drivers/net/ethernet/smsc/smsc911x.c               |  2 +-
 drivers/net/ethernet/sun/cassini.c                 |  2 +-
 drivers/net/ethernet/sun/sungem.c                  |  2 +-
 drivers/net/ethernet/sun/sunhme.c                  | 10 +--
 drivers/net/ethernet/sun/sunqe.c                   |  2 +-
 drivers/net/ethernet/ti/davinci_emac.c             |  2 +-
 drivers/net/ethernet/tile/tilegx.c                 |  2 +-
 drivers/net/ethernet/xilinx/xilinx_emaclite.c      |  2 +-
 drivers/net/fddi/skfp/fplustm.c                    |  2 +-
 drivers/net/fddi/skfp/skfddi.c                     |  6 +-
 drivers/net/plip/plip.c                            |  2 +-
 drivers/net/usb/catc.c                             |  8 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |  2 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |  4 +-
 drivers/net/wireless/atmel.c                       | 92 +++++++++++-----------
 drivers/net/wireless/b43/xmit.c                    |  2 +-
 drivers/net/wireless/b43legacy/xmit.c              |  2 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |  6 +-
 drivers/net/wireless/hostap/hostap_info.c          |  2 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |  2 +-
 drivers/net/wireless/prism54/isl_ioctl.c           | 10 +--
 drivers/net/wireless/prism54/islpci_dev.c          |  2 +-
 drivers/net/wireless/prism54/oid_mgt.c             |  2 +-
 drivers/net/wireless/rtlwifi/core.c                | 10 +--
 net/bridge/br_multicast.c                          |  4 +-
 net/bridge/netfilter/ebt_among.c                   |  2 +-
 net/mac80211/trace.h                               |  4 +-
 57 files changed, 146 insertions(+), 149 deletions(-)

diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
index f92f001..36fa577 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -702,7 +702,7 @@ static int ax_init_dev(struct net_device *dev)
 			for (i = 0; i < 16; i++)
 				SA_prom[i] = SA_prom[i+i];
 
-		memcpy(dev->dev_addr, SA_prom, 6);
+		memcpy(dev->dev_addr, SA_prom, ETH_ALEN);
 	}
 
 #ifdef CONFIG_AX88796_93CX6
diff --git a/drivers/net/ethernet/amd/atarilance.c b/drivers/net/ethernet/amd/atarilance.c
index 10ceca5..e07ce5f 100644
--- a/drivers/net/ethernet/amd/atarilance.c
+++ b/drivers/net/ethernet/amd/atarilance.c
@@ -586,10 +586,10 @@ static unsigned long __init lance_probe1( struct net_device *dev,
 	switch( lp->cardtype ) {
 	  case OLD_RIEBL:
 		/* No ethernet address! (Set some default address) */
-		memcpy( dev->dev_addr, OldRieblDefHwaddr, 6 );
+		memcpy(dev->dev_addr, OldRieblDefHwaddr, ETH_ALEN);
 		break;
 	  case NEW_RIEBL:
-		lp->memcpy_f( dev->dev_addr, RIEBL_HWADDR_ADDR, 6 );
+		lp->memcpy_f(dev->dev_addr, RIEBL_HWADDR_ADDR, ETH_ALEN);
 		break;
 	  case PAM_CARD:
 		i = IO->eeprom;
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index 91d52b4..427c148 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -1138,7 +1138,7 @@ static int au1000_probe(struct platform_device *pdev)
 		aup->phy1_search_mac0 = 1;
 	} else {
 		if (is_valid_ether_addr(pd->mac)) {
-			memcpy(dev->dev_addr, pd->mac, 6);
+			memcpy(dev->dev_addr, pd->mac, ETH_ALEN);
 		} else {
 			/* Set a random MAC since no valid provided by platform_data. */
 			eth_hw_addr_random(dev);
diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index 2d8e288..bd4e640 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -1675,7 +1675,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 				pr_cont(" warning: CSR address invalid,\n");
 				pr_info("    using instead PROM address of");
 			}
-			memcpy(dev->dev_addr, promaddr, 6);
+			memcpy(dev->dev_addr, promaddr, ETH_ALEN);
 		}
 	}
 
diff --git a/drivers/net/ethernet/apple/bmac.c b/drivers/net/ethernet/apple/bmac.c
index a597b76..daae0e0 100644
--- a/drivers/net/ethernet/apple/bmac.c
+++ b/drivers/net/ethernet/apple/bmac.c
@@ -1220,8 +1220,8 @@ static void bmac_reset_and_enable(struct net_device *dev)
 	if (skb != NULL) {
 		data = skb_put(skb, ETHERMINPACKET);
 		memset(data, 0, ETHERMINPACKET);
-		memcpy(data, dev->dev_addr, 6);
-		memcpy(data+6, dev->dev_addr, 6);
+		memcpy(data, dev->dev_addr, ETH_ALEN);
+		memcpy(data + ETH_ALEN, dev->dev_addr, ETH_ALEN);
 		bmac_transmit_packet(skb, dev);
 	}
 	spin_unlock_irqrestore(&bp->lock, flags);
diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index c96930f..079a597 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -2111,7 +2111,7 @@ static int b44_get_invariants(struct b44 *bp)
 	 * valid PHY address. */
 	bp->phy_addr &= 0x1F;
 
-	memcpy(bp->dev->dev_addr, addr, 6);
+	memcpy(bp->dev->dev_addr, addr, ETH_ALEN);
 
 	if (!is_valid_ether_addr(&bp->dev->dev_addr[0])){
 		pr_err("Invalid MAC address found in EEPROM\n");
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index e838a3f..6111870 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -5761,8 +5761,8 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 	if (!skb)
 		return -ENOMEM;
 	packet = skb_put(skb, pkt_size);
-	memcpy(packet, bp->dev->dev_addr, 6);
-	memset(packet + 6, 0x0, 8);
+	memcpy(packet, bp->dev->dev_addr, ETH_ALEN);
+	memset(packet + ETH_ALEN, 0x0, 8);
 	for (i = 14; i < pkt_size; i++)
 		packet[i] = (unsigned char) (i & 0xff);
 
@@ -8514,7 +8514,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_drvdata(pdev, dev);
 
-	memcpy(dev->dev_addr, bp->mac_addr, 6);
+	memcpy(dev->dev_addr, bp->mac_addr, ETH_ALEN);
 
 	dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG |
 		NETIF_F_TSO | NETIF_F_TSO_ECN |
diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 99394bd..f58a8b8 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -393,7 +393,7 @@ static int cnic_iscsi_nl_msg_recv(struct cnic_dev *dev, u32 msg_type,
 
 			csk->vlan_id = path_resp->vlan_id;
 
-			memcpy(csk->ha, path_resp->mac_addr, 6);
+			memcpy(csk->ha, path_resp->mac_addr, ETH_ALEN);
 			if (test_bit(SK_F_IPV6, &csk->flags))
 				memcpy(&csk->src_ip[0], &path_resp->src.v6_addr,
 				       sizeof(struct in6_addr));
@@ -5572,7 +5572,7 @@ static struct cnic_dev *init_bnx2x_cnic(struct net_device *dev)
 	if (cdev->max_fcoe_conn > BNX2X_FCOE_NUM_CONNECTIONS)
 		cdev->max_fcoe_conn = BNX2X_FCOE_NUM_CONNECTIONS;
 
-	memcpy(cdev->mac_addr, ethdev->iscsi_mac, 6);
+	memcpy(cdev->mac_addr, ethdev->iscsi_mac, ETH_ALEN);
 
 	cp->cnic_ops = &cnic_bnx2x_ops;
 	cp->start_hw = cnic_start_bnx2x_hw;
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 221a181..d9ed140 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -13207,8 +13207,8 @@ static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, bool tso_loopback)
 		return -ENOMEM;
 
 	tx_data = skb_put(skb, tx_len);
-	memcpy(tx_data, tp->dev->dev_addr, 6);
-	memset(tx_data + 6, 0x0, 8);
+	memcpy(tx_data, tp->dev->dev_addr, ETH_ALEN);
+	memset(tx_data + ETH_ALEN, 0x0, 8);
 
 	tw32(MAC_RX_MTU_SIZE, tx_len + ETH_FCS_LEN);
 
@@ -16654,8 +16654,8 @@ static int tg3_get_macaddr_sparc(struct tg3 *tp)
 	int len;
 
 	addr = of_get_property(dp, "local-mac-address", &len);
-	if (addr && len == 6) {
-		memcpy(dev->dev_addr, addr, 6);
+	if (addr && len == ETH_ALEN) {
+		memcpy(dev->dev_addr, addr, ETH_ALEN);
 		return 0;
 	}
 	return -ENODEV;
@@ -16665,7 +16665,7 @@ static int tg3_get_default_macaddr_sparc(struct tg3 *tp)
 {
 	struct net_device *dev = tp->dev;
 
-	memcpy(dev->dev_addr, idprom->id_ethaddr, 6);
+	memcpy(dev->dev_addr, idprom->id_ethaddr, ETH_ALEN);
 	return 0;
 }
 #endif
diff --git a/drivers/net/ethernet/chelsio/cxgb/pm3393.c b/drivers/net/ethernet/chelsio/cxgb/pm3393.c
index 40c7b93..eb33a31 100644
--- a/drivers/net/ethernet/chelsio/cxgb/pm3393.c
+++ b/drivers/net/ethernet/chelsio/cxgb/pm3393.c
@@ -499,7 +499,7 @@ static const struct cmac_statistics *pm3393_update_statistics(struct cmac *mac,
 
 static int pm3393_macaddress_get(struct cmac *cmac, u8 mac_addr[6])
 {
-	memcpy(mac_addr, cmac->instance->mac_addr, 6);
+	memcpy(mac_addr, cmac->instance->mac_addr, ETH_ALEN);
 	return 0;
 }
 
@@ -526,7 +526,7 @@ static int pm3393_macaddress_set(struct cmac *cmac, u8 ma[6])
 	 */
 
 	/* Store local copy */
-	memcpy(cmac->instance->mac_addr, ma, 6);
+	memcpy(cmac->instance->mac_addr, ma, ETH_ALEN);
 
 	lo  = ((u32) ma[1] << 8) | (u32) ma[0];
 	mid = ((u32) ma[3] << 8) | (u32) ma[2];
diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 5f5896e..be8efee 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1603,7 +1603,7 @@ dm9000_probe(struct platform_device *pdev)
 
 	if (!is_valid_ether_addr(ndev->dev_addr) && pdata != NULL) {
 		mac_src = "platform data";
-		memcpy(ndev->dev_addr, pdata->dev_addr, 6);
+		memcpy(ndev->dev_addr, pdata->dev_addr, ETH_ALEN);
 	}
 
 	if (!is_valid_ether_addr(ndev->dev_addr)) {
diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 6b60582..56f2f60 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -1083,7 +1083,7 @@ static int fs_enet_probe(struct platform_device *ofdev)
 
 	mac_addr = of_get_mac_address(ofdev->dev.of_node);
 	if (mac_addr)
-		memcpy(ndev->dev_addr, mac_addr, 6);
+		memcpy(ndev->dev_addr, mac_addr, ETH_ALEN);
 
 	ret = fep->ops->allocate_bd(ndev);
 	if (ret)
diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 5930c39..d58a3df 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3899,7 +3899,7 @@ static int ucc_geth_probe(struct platform_device* ofdev)
 
 	mac_addr = of_get_mac_address(np);
 	if (mac_addr)
-		memcpy(dev->dev_addr, mac_addr, 6);
+		memcpy(dev->dev_addr, mac_addr, ETH_ALEN);
 
 	ugeth->ug_info = ug_info;
 	ugeth->dev = device;
diff --git a/drivers/net/ethernet/i825xx/82596.c b/drivers/net/ethernet/i825xx/82596.c
index e388161..a15877a 100644
--- a/drivers/net/ethernet/i825xx/82596.c
+++ b/drivers/net/ethernet/i825xx/82596.c
@@ -711,7 +711,7 @@ static int init_i596_mem(struct net_device *dev)
 	i596_add_cmd(dev, &lp->cf_cmd.cmd);
 
 	DEB(DEB_INIT,printk(KERN_DEBUG "%s: queuing CmdSASetup\n", dev->name));
-	memcpy(lp->sa_cmd.eth_addr, dev->dev_addr, 6);
+	memcpy(lp->sa_cmd.eth_addr, dev->dev_addr, ETH_ALEN);
 	lp->sa_cmd.cmd.command = CmdSASetup;
 	i596_add_cmd(dev, &lp->sa_cmd.cmd);
 
@@ -1155,7 +1155,7 @@ struct net_device * __init i82596_probe(int unit)
 			err = -ENODEV;
 			goto out;
 		}
-		memcpy(eth_addr, (void *) 0xfffc1f2c, 6);	/* YUCK! Get addr from NOVRAM */
+		memcpy(eth_addr, (void *) 0xfffc1f2c, ETH_ALEN);	/* YUCK! Get addr from NOVRAM */
 		dev->base_addr = MVME_I596_BASE;
 		dev->irq = (unsigned) MVME16x_IRQ_I596;
 		goto found;
diff --git a/drivers/net/ethernet/i825xx/lib82596.c b/drivers/net/ethernet/i825xx/lib82596.c
index d653bac..861fa15 100644
--- a/drivers/net/ethernet/i825xx/lib82596.c
+++ b/drivers/net/ethernet/i825xx/lib82596.c
@@ -607,7 +607,7 @@ static int init_i596_mem(struct net_device *dev)
 	i596_add_cmd(dev, &dma->cf_cmd.cmd);
 
 	DEB(DEB_INIT, printk(KERN_DEBUG "%s: queuing CmdSASetup\n", dev->name));
-	memcpy(dma->sa_cmd.eth_addr, dev->dev_addr, 6);
+	memcpy(dma->sa_cmd.eth_addr, dev->dev_addr, ETH_ALEN);
 	dma->sa_cmd.cmd.command = SWAP16(CmdSASetup);
 	DMA_WBACK(dev, &(dma->sa_cmd), sizeof(struct sa_cmd));
 	i596_add_cmd(dev, &dma->sa_cmd.cmd);
@@ -1396,13 +1396,13 @@ static void set_multicast_list(struct net_device *dev)
 		netdev_for_each_mc_addr(ha, dev) {
 			if (!cnt--)
 				break;
-			memcpy(cp, ha->addr, 6);
+			memcpy(cp, ha->addr, ETH_ALEN);
 			if (i596_debug > 1)
 				DEB(DEB_MULTI,
 				    printk(KERN_DEBUG
 					   "%s: Adding address %pM\n",
 					   dev->name, cp));
-			cp += 6;
+			cp += ETH_ALEN;
 		}
 		DMA_WBACK_INV(dev, &dma->mc_cmd, sizeof(struct mc_cmd));
 		i596_add_cmd(dev, &cmd->cmd);
diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 6b5c722..ef21a2e 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -2676,7 +2676,7 @@ static int emac_init_config(struct emac_instance *dev)
 		       np->full_name);
 		return -ENXIO;
 	}
-	memcpy(dev->ndev->dev_addr, p, 6);
+	memcpy(dev->ndev->dev_addr, p, ETH_ALEN);
 
 	/* IAHT and GAHT filter parameterization */
 	if (emac_has_feature(dev, EMAC_FTR_EMAC4SYNC)) {
diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 5d41aee..952d795 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1185,7 +1185,7 @@ static void ibmveth_set_multicast_list(struct net_device *netdev)
 		netdev_for_each_mc_addr(ha, netdev) {
 			/* add the multicast address to the filter table */
 			unsigned long mcast_addr = 0;
-			memcpy(((char *)&mcast_addr)+2, ha->addr, 6);
+			memcpy(((char *)&mcast_addr)+2, ha->addr, ETH_ALEN);
 			lpar_rc = h_multicast_ctrl(adapter->vdev->unit_address,
 						   IbmVethMcastAddFilter,
 						   mcast_addr);
@@ -1370,7 +1370,7 @@ static int ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
 	netif_napi_add(netdev, &adapter->napi, ibmveth_poll, 16);
 
 	adapter->mac_addr = 0;
-	memcpy(&adapter->mac_addr, mac_addr_p, 6);
+	memcpy(&adapter->mac_addr, mac_addr_p, ETH_ALEN);
 
 	netdev->irq = dev->irq;
 	netdev->netdev_ops = &ibmveth_netdev_ops;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index a56266e..a505d3b 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5708,7 +5708,7 @@ static void igb_vf_reset_msg(struct igb_adapter *adapter, u32 vf)
 
 	/* reply to reset with ack and vf mac address */
 	msgbuf[0] = E1000_VF_RESET | E1000_VT_MSGTYPE_ACK;
-	memcpy(addr, vf_mac, 6);
+	memcpy(addr, vf_mac, ETH_ALEN);
 	igb_write_mbx(hw, msgbuf, 3, vf);
 }
 
diff --git a/drivers/net/ethernet/intel/igbvf/vf.c b/drivers/net/ethernet/intel/igbvf/vf.c
index eea0e10..955ad8c 100644
--- a/drivers/net/ethernet/intel/igbvf/vf.c
+++ b/drivers/net/ethernet/intel/igbvf/vf.c
@@ -154,7 +154,7 @@ static s32 e1000_reset_hw_vf(struct e1000_hw *hw)
 		ret_val = mbx->ops.read_posted(hw, msgbuf, 3);
 		if (!ret_val) {
 			if (msgbuf[0] == (E1000_VF_RESET | E1000_VT_MSGTYPE_ACK))
-				memcpy(hw->mac.perm_addr, addr, 6);
+				memcpy(hw->mac.perm_addr, addr, ETH_ALEN);
 			else
 				ret_val = -E1000_ERR_MAC_INIT;
 		}
@@ -314,7 +314,7 @@ static void e1000_rar_set_vf(struct e1000_hw *hw, u8 * addr, u32 index)
 
 	memset(msgbuf, 0, 12);
 	msgbuf[0] = E1000_VF_SET_MAC_ADDR;
-	memcpy(msg_addr, addr, 6);
+	memcpy(msg_addr, addr, ETH_ALEN);
 	ret_val = mbx->ops.write_posted(hw, msgbuf, 3);
 
 	if (!ret_val)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 276d7b1..1fe7cb0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -558,7 +558,7 @@ static int ixgbe_set_vf_mac(struct ixgbe_adapter *adapter,
 	struct ixgbe_hw *hw = &adapter->hw;
 	int rar_entry = hw->mac.num_rar_entries - (vf + 1);
 
-	memcpy(adapter->vfinfo[vf].vf_mac_addresses, mac_addr, 6);
+	memcpy(adapter->vfinfo[vf].vf_mac_addresses, mac_addr, ETH_ALEN);
 	hw->mac.ops.set_rar(hw, rar_entry, mac_addr, vf, IXGBE_RAH_AV);
 
 	return 0;
@@ -621,16 +621,13 @@ static int ixgbe_set_vf_macvlan(struct ixgbe_adapter *adapter,
 
 int ixgbe_vf_configuration(struct pci_dev *pdev, unsigned int event_mask)
 {
-	unsigned char vf_mac_addr[6];
 	struct ixgbe_adapter *adapter = pci_get_drvdata(pdev);
 	unsigned int vfn = (event_mask & 0x3f);
 
 	bool enable = ((event_mask & 0x10000000U) != 0);
 
-	if (enable) {
-		eth_zero_addr(vf_mac_addr);
-		memcpy(adapter->vfinfo[vfn].vf_mac_addresses, vf_mac_addr, 6);
-	}
+	if (enable)
+		eth_zero_addr(adapter->vfinfo[vfn].vf_mac_addresses);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 387b526..4d44d64 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -242,7 +242,7 @@ static s32 ixgbevf_set_uc_addr_vf(struct ixgbe_hw *hw, u32 index, u8 *addr)
 	msgbuf[0] |= index << IXGBE_VT_MSGINFO_SHIFT;
 	msgbuf[0] |= IXGBE_VF_SET_MACVLAN;
 	if (addr)
-		memcpy(msg_addr, addr, 6);
+		memcpy(msg_addr, addr, ETH_ALEN);
 	ret_val = mbx->ops.write_posted(hw, msgbuf, 3);
 
 	if (!ret_val)
@@ -275,7 +275,7 @@ static s32 ixgbevf_set_rar_vf(struct ixgbe_hw *hw, u32 index, u8 *addr,
 
 	memset(msgbuf, 0, sizeof(msgbuf));
 	msgbuf[0] = IXGBE_VF_SET_MAC_ADDR;
-	memcpy(msg_addr, addr, 6);
+	memcpy(msg_addr, addr, ETH_ALEN);
 	ret_val = mbx->ops.write_posted(hw, msgbuf, 3);
 
 	if (!ret_val)
diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 23de82a..b56d2a2 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -309,7 +309,7 @@ static void
 jme_load_macaddr(struct net_device *netdev)
 {
 	struct jme_adapter *jme = netdev_priv(netdev);
-	unsigned char macaddr[6];
+	unsigned char macaddr[ETH_ALEN];
 	u32 val;
 
 	spin_lock_bh(&jme->macaddr_lock);
@@ -321,7 +321,7 @@ jme_load_macaddr(struct net_device *netdev)
 	val = jread32(jme, JME_RXUMA_HI);
 	macaddr[4] = (val >>  0) & 0xFF;
 	macaddr[5] = (val >>  8) & 0xFF;
-	memcpy(netdev->dev_addr, macaddr, 6);
+	memcpy(netdev->dev_addr, macaddr, ETH_ALEN);
 	spin_unlock_bh(&jme->macaddr_lock);
 }
 
diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index a36fa80..4a5e3b0 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -1110,7 +1110,7 @@ static int korina_probe(struct platform_device *pdev)
 	lp = netdev_priv(dev);
 
 	bif->dev = dev;
-	memcpy(dev->dev_addr, bif->mac, 6);
+	memcpy(dev->dev_addr, bif->mac, ETH_ALEN);
 
 	lp->rx_irq = platform_get_irq_byname(pdev, "korina_rx");
 	lp->tx_irq = platform_get_irq_byname(pdev, "korina_tx");
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 7fb5677..99f16cb 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2514,7 +2514,7 @@ static int mv643xx_eth_shared_of_add_port(struct platform_device *pdev,
 
 	mac_addr = of_get_mac_address(pnp);
 	if (mac_addr)
-		memcpy(ppd.mac_addr, mac_addr, 6);
+		memcpy(ppd.mac_addr, mac_addr, ETH_ALEN);
 
 	mv643xx_eth_property(pnp, "tx-queue-size", ppd.tx_queue_size);
 	mv643xx_eth_property(pnp, "tx-sram-addr", ppd.tx_sram_addr);
@@ -2696,7 +2696,7 @@ static void set_params(struct mv643xx_eth_private *mp,
 	struct net_device *dev = mp->dev;
 
 	if (is_valid_ether_addr(pd->mac_addr))
-		memcpy(dev->dev_addr, pd->mac_addr, 6);
+		memcpy(dev->dev_addr, pd->mac_addr, ETH_ALEN);
 	else
 		uc_addr_get(mp, dev->dev_addr);
 
diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index 075f4e2..c83d16d 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -1248,7 +1248,7 @@ static void ks_set_mac(struct ks_net *ks, u8 *data)
 	w = ((u & 0xFF) << 8) | ((u >> 8) & 0xFF);
 	ks_wrreg16(ks, KS_MARL, w);
 
-	memcpy(ks->mac_addr, data, 6);
+	memcpy(ks->mac_addr, data, ETH_ALEN);
 
 	if (ks->enabled)
 		ks_start_rx(ks);
@@ -1651,7 +1651,7 @@ static int ks8851_probe(struct platform_device *pdev)
 	}
 	netdev_info(netdev, "Mac address is: %pM\n", ks->mac_addr);
 
-	memcpy(netdev->dev_addr, ks->mac_addr, 6);
+	memcpy(netdev->dev_addr, ks->mac_addr, ETH_ALEN);
 
 	ks_set_mac(ks, netdev->dev_addr);
 
diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 149355b..6ddaf7b 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -3164,7 +3164,7 @@ static void myri10ge_set_multicast_list(struct net_device *dev)
 
 	/* Walk the multicast list, and add each address */
 	netdev_for_each_mc_addr(ha, dev) {
-		memcpy(data, &ha->addr, 6);
+		memcpy(data, &ha->addr, ETH_ALEN);
 		cmd.data0 = ntohl(data[0]);
 		cmd.data1 = ntohl(data[1]);
 		err = myri10ge_send_cmd(mgp, MXGEFW_JOIN_MULTICAST_GROUP,
@@ -3207,7 +3207,7 @@ static int myri10ge_set_mac_address(struct net_device *dev, void *addr)
 	}
 
 	/* change the dev structure */
-	memcpy(dev->dev_addr, sa->sa_data, 6);
+	memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
index 8375cbd..67efe75 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
@@ -648,7 +648,7 @@ nx_p3_sre_macaddr_change(struct netxen_adapter *adapter, u8 *addr, unsigned op)
 
 	mac_req = (nx_mac_req_t *)&req.words[0];
 	mac_req->op = op;
-	memcpy(mac_req->mac_addr, addr, 6);
+	memcpy(mac_req->mac_addr, addr, ETH_ALEN);
 
 	return netxen_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index f8adc7b..73e72eb 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -445,7 +445,7 @@ int qlcnic_82xx_sre_macaddr_change(struct qlcnic_adapter *adapter, u8 *addr,
 
 	mac_req = (struct qlcnic_mac_req *)&req.words[0];
 	mac_req->op = op;
-	memcpy(mac_req->mac_addr, addr, 6);
+	memcpy(mac_req->mac_addr, addr, ETH_ALEN);
 
 	vlan_req = (struct qlcnic_vlan_req *)&req.words[1];
 	vlan_req->vlan_id = cpu_to_le16(vlan_id);
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 5cd831e..c8df52b 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -868,7 +868,7 @@ static void update_mac_address(struct net_device *ndev)
 static void read_mac_address(struct net_device *ndev, unsigned char *mac)
 {
 	if (mac[0] || mac[1] || mac[2] || mac[3] || mac[4] || mac[5]) {
-		memcpy(ndev->dev_addr, mac, 6);
+		memcpy(ndev->dev_addr, mac, ETH_ALEN);
 	} else {
 		ndev->dev_addr[0] = (sh_eth_read(ndev, MAHR) >> 24);
 		ndev->dev_addr[1] = (sh_eth_read(ndev, MAHR) >> 16) & 0xFF;
diff --git a/drivers/net/ethernet/sgi/meth.c b/drivers/net/ethernet/sgi/meth.c
index 770036b..513ed8b 100644
--- a/drivers/net/ethernet/sgi/meth.c
+++ b/drivers/net/ethernet/sgi/meth.c
@@ -839,7 +839,7 @@ static int meth_probe(struct platform_device *pdev)
 	dev->watchdog_timeo	= timeout;
 	dev->irq		= MACE_ETHERNET_IRQ;
 	dev->base_addr		= (unsigned long)&mace->eth;
-	memcpy(dev->dev_addr, o2meth_eaddr, 6);
+	memcpy(dev->dev_addr, o2meth_eaddr, ETH_ALEN);
 
 	priv = netdev_priv(dev);
 	spin_lock_init(&priv->meth_lock);
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 5fdbc26..01f8459 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2502,7 +2502,7 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
 		SMSC_TRACE(pdata, probe,
 			   "MAC Address is specified by configuration");
 	} else if (is_valid_ether_addr(pdata->config.mac)) {
-		memcpy(dev->dev_addr, pdata->config.mac, 6);
+		memcpy(dev->dev_addr, pdata->config.mac, ETH_ALEN);
 		SMSC_TRACE(pdata, probe,
 			   "MAC Address specified by platform data");
 	} else {
diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index 759441b..a72ecc4 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -3354,7 +3354,7 @@ use_random_mac_addr:
 #if defined(CONFIG_SPARC)
 	addr = of_get_property(cp->of_node, "local-mac-address", NULL);
 	if (addr != NULL) {
-		memcpy(dev_addr, addr, 6);
+		memcpy(dev_addr, addr, ETH_ALEN);
 		goto done;
 	}
 #endif
diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index e62df2b..a235bd9 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -2779,7 +2779,7 @@ static int gem_get_device_address(struct gem *gp)
 		return -1;
 #endif
 	}
-	memcpy(dev->dev_addr, addr, 6);
+	memcpy(dev->dev_addr, addr, ETH_ALEN);
 #else
 	get_gem_mac_nonobp(gp->pdev, gp->dev->dev_addr);
 #endif
diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index e37b587..99043b7 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -2675,10 +2675,10 @@ static int happy_meal_sbus_probe_one(struct platform_device *op, int is_qfe)
 
 		addr = of_get_property(dp, "local-mac-address", &len);
 
-		if (qfe_slot != -1 && addr && len == 6)
-			memcpy(dev->dev_addr, addr, 6);
+		if (qfe_slot != -1 && addr && len == ETH_ALEN)
+			memcpy(dev->dev_addr, addr, ETH_ALEN);
 		else
-			memcpy(dev->dev_addr, idprom->id_ethaddr, 6);
+			memcpy(dev->dev_addr, idprom->id_ethaddr, ETH_ALEN);
 	}
 
 	hp = netdev_priv(dev);
@@ -3024,9 +3024,9 @@ static int happy_meal_pci_probe(struct pci_dev *pdev,
 		    (addr = of_get_property(dp, "local-mac-address", &len))
 			!= NULL &&
 		    len == 6) {
-			memcpy(dev->dev_addr, addr, 6);
+			memcpy(dev->dev_addr, addr, ETH_ALEN);
 		} else {
-			memcpy(dev->dev_addr, idprom->id_ethaddr, 6);
+			memcpy(dev->dev_addr, idprom->id_ethaddr, ETH_ALEN);
 		}
 #else
 		get_hme_mac_nonsparc(pdev, &dev->dev_addr[0]);
diff --git a/drivers/net/ethernet/sun/sunqe.c b/drivers/net/ethernet/sun/sunqe.c
index b072f4d..5695ae2 100644
--- a/drivers/net/ethernet/sun/sunqe.c
+++ b/drivers/net/ethernet/sun/sunqe.c
@@ -843,7 +843,7 @@ static int qec_ether_init(struct platform_device *op)
 	if (!dev)
 		return -ENOMEM;
 
-	memcpy(dev->dev_addr, idprom->id_ethaddr, 6);
+	memcpy(dev->dev_addr, idprom->id_ethaddr, ETH_ALEN);
 
 	qe = netdev_priv(dev);
 
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 67df09e..fba1c48 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1853,7 +1853,7 @@ static int davinci_emac_probe(struct platform_device *pdev)
 	}
 
 	/* MAC addr and PHY mask , RMII enable info from platform_data */
-	memcpy(priv->mac_addr, pdata->mac_addr, 6);
+	memcpy(priv->mac_addr, pdata->mac_addr, ETH_ALEN);
 	priv->phy_id = pdata->phy_id;
 	priv->rmii_en = pdata->rmii_en;
 	priv->version = pdata->version;
diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 13e6fff..628b736 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -2230,7 +2230,7 @@ static void tile_net_dev_init(const char *name, const uint8_t *mac)
 		nz_addr |= mac[i];
 
 	if (nz_addr) {
-		memcpy(dev->dev_addr, mac, 6);
+		memcpy(dev->dev_addr, mac, ETH_ALEN);
 		dev->addr_len = 6;
 	} else {
 		eth_hw_addr_random(dev);
diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 80dd404..74234a5 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -1172,7 +1172,7 @@ static int xemaclite_of_probe(struct platform_device *ofdev)
 
 	if (mac_address)
 		/* Set the MAC address. */
-		memcpy(ndev->dev_addr, mac_address, 6);
+		memcpy(ndev->dev_addr, mac_address, ETH_ALEN);
 	else
 		dev_warn(dev, "No MAC address found\n");
 
diff --git a/drivers/net/fddi/skfp/fplustm.c b/drivers/net/fddi/skfp/fplustm.c
index a20ed1a..f839935 100644
--- a/drivers/net/fddi/skfp/fplustm.c
+++ b/drivers/net/fddi/skfp/fplustm.c
@@ -453,7 +453,7 @@ static void directed_beacon(struct s_smc *smc)
 	 */
 	* (char *) a = (char) ((long)DBEACON_INFO<<24L) ;
 	a[1] = 0 ;
-	memcpy((char *)a+1,(char *) &smc->mib.m[MAC0].fddiMACUpstreamNbr,6) ;
+	memcpy((char *)a+1, (char *) &smc->mib.m[MAC0].fddiMACUpstreamNbr, ETH_ALEN);
 
 	CHECK_NPP() ;
 	 /* set memory address reg for writes */
diff --git a/drivers/net/fddi/skfp/skfddi.c b/drivers/net/fddi/skfp/skfddi.c
index f5d7305..713d303 100644
--- a/drivers/net/fddi/skfp/skfddi.c
+++ b/drivers/net/fddi/skfp/skfddi.c
@@ -436,7 +436,7 @@ static  int skfp_driver_init(struct net_device *dev)
 	}
 	read_address(smc, NULL);
 	pr_debug("HW-Addr: %pMF\n", smc->hw.fddi_canon_addr.a);
-	memcpy(dev->dev_addr, smc->hw.fddi_canon_addr.a, 6);
+	memcpy(dev->dev_addr, smc->hw.fddi_canon_addr.a, ETH_ALEN);
 
 	smt_reset_defaults(smc, 0);
 
@@ -503,7 +503,7 @@ static int skfp_open(struct net_device *dev)
 	 *               address.
 	 */
 	read_address(smc, NULL);
-	memcpy(dev->dev_addr, smc->hw.fddi_canon_addr.a, 6);
+	memcpy(dev->dev_addr, smc->hw.fddi_canon_addr.a, ETH_ALEN);
 
 	init_smt(smc, NULL);
 	smt_online(smc, 1);
@@ -1213,7 +1213,7 @@ static void CheckSourceAddress(unsigned char *frame, unsigned char *hw_addr)
 	if ((unsigned short) frame[1 + 10] != 0)
 		return;
 	SRBit = frame[1 + 6] & 0x01;
-	memcpy(&frame[1 + 6], hw_addr, 6);
+	memcpy(&frame[1 + 6], hw_addr, ETH_ALEN);
 	frame[8] |= SRBit;
 }				// CheckSourceAddress
 
diff --git a/drivers/net/plip/plip.c b/drivers/net/plip/plip.c
index 1f7bef9..7b4ff35 100644
--- a/drivers/net/plip/plip.c
+++ b/drivers/net/plip/plip.c
@@ -1002,7 +1002,7 @@ plip_rewrite_address(const struct net_device *dev, struct ethhdr *eth)
 		/* Any address will do - we take the first */
 		const struct in_ifaddr *ifa = in_dev->ifa_list;
 		if (ifa) {
-			memcpy(eth->h_source, dev->dev_addr, 6);
+			memcpy(eth->h_source, dev->dev_addr, ETH_ALEN);
 			memset(eth->h_dest, 0xfc, 2);
 			memcpy(eth->h_dest+2, &ifa->ifa_address, 4);
 		}
diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index 8d5cac2..df507e6 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -640,10 +640,10 @@ static void catc_set_multicast_list(struct net_device *netdev)
 {
 	struct catc *catc = netdev_priv(netdev);
 	struct netdev_hw_addr *ha;
-	u8 broadcast[6];
+	u8 broadcast[ETH_ALEN];
 	u8 rx = RxEnable | RxPolarity | RxMultiCast;
 
-	memset(broadcast, 0xff, 6);
+	memset(broadcast, 0xff, ETH_ALEN);
 	memset(catc->multicast, 0, 64);
 
 	catc_multicast(broadcast, catc->multicast);
@@ -778,7 +778,7 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
 	struct usb_device *usbdev = interface_to_usbdev(intf);
 	struct net_device *netdev;
 	struct catc *catc;
-	u8 broadcast[6];
+	u8 broadcast[ETH_ALEN];
 	int i, pktsz;
 
 	if (usb_set_interface(usbdev,
@@ -882,7 +882,7 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
 		
 		dev_dbg(dev, "Filling the multicast list.\n");
 	  
-		memset(broadcast, 0xff, 6);
+		memset(broadcast, 0xff, ETH_ALEN);
 		catc_multicast(broadcast, catc->multicast);
 		catc_multicast(netdev->dev_addr, catc->multicast);
 		catc_write_mem(catc, 0xfa80, catc->multicast, 64);
diff --git a/drivers/net/wireless/ath/ath10k/wmi.c b/drivers/net/wireless/ath/ath10k/wmi.c
index 55f90c7..bee88e8 100644
--- a/drivers/net/wireless/ath/ath10k/wmi.c
+++ b/drivers/net/wireless/ath/ath10k/wmi.c
@@ -1918,7 +1918,7 @@ int ath10k_wmi_peer_set_param(struct ath10k *ar, u32 vdev_id,
 	cmd->vdev_id     = __cpu_to_le32(vdev_id);
 	cmd->param_id    = __cpu_to_le32(param_id);
 	cmd->param_value = __cpu_to_le32(param_value);
-	memcpy(&cmd->peer_macaddr.addr, peer_addr, 6);
+	memcpy(&cmd->peer_macaddr.addr, peer_addr, ETH_ALEN);
 
 	ath10k_dbg(ATH10K_DBG_WMI,
 		   "wmi vdev %d peer 0x%pM set param %d value %d\n",
diff --git a/drivers/net/wireless/ath/wil6210/cfg80211.c b/drivers/net/wireless/ath/wil6210/cfg80211.c
index 61c302a..5b34076 100644
--- a/drivers/net/wireless/ath/wil6210/cfg80211.c
+++ b/drivers/net/wireless/ath/wil6210/cfg80211.c
@@ -316,8 +316,8 @@ static int wil_cfg80211_connect(struct wiphy *wiphy,
 	}
 	conn.channel = ch - 1;
 
-	memcpy(conn.bssid, bss->bssid, 6);
-	memcpy(conn.dst_mac, bss->bssid, 6);
+	memcpy(conn.bssid, bss->bssid, ETH_ALEN);
+	memcpy(conn.dst_mac, bss->bssid, ETH_ALEN);
 	/*
 	 * FW don't support scan after connection attempt
 	 */
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index b827d51..a55ae64 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -844,18 +844,18 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 	if (priv->wep_is_on)
 		frame_ctl |= IEEE80211_FCTL_PROTECTED;
 	if (priv->operating_mode == IW_MODE_ADHOC) {
-		skb_copy_from_linear_data(skb, &header.addr1, 6);
-		memcpy(&header.addr2, dev->dev_addr, 6);
-		memcpy(&header.addr3, priv->BSSID, 6);
+		skb_copy_from_linear_data(skb, &header.addr1, ETH_ALEN);
+		memcpy(&header.addr2, dev->dev_addr, ETH_ALEN);
+		memcpy(&header.addr3, priv->BSSID, ETH_ALEN);
 	} else {
 		frame_ctl |= IEEE80211_FCTL_TODS;
-		memcpy(&header.addr1, priv->CurrentBSSID, 6);
-		memcpy(&header.addr2, dev->dev_addr, 6);
-		skb_copy_from_linear_data(skb, &header.addr3, 6);
+		memcpy(&header.addr1, priv->CurrentBSSID, ETH_ALEN);
+		memcpy(&header.addr2, dev->dev_addr, ETH_ALEN);
+		skb_copy_from_linear_data(skb, &header.addr3, ETH_ALEN);
 	}
 
 	if (priv->use_wpa)
-		memcpy(&header.addr4, SNAP_RFC1024, 6);
+		memcpy(&header.addr4, SNAP_RFC1024, ETH_ALEN);
 
 	header.frame_control = cpu_to_le16(frame_ctl);
 	/* Copy the wireless header into the card */
@@ -929,11 +929,11 @@ static void fast_rx_path(struct atmel_private *priv,
 		}
 	}
 
-	memcpy(skbp, header->addr1, 6); /* destination address */
+	memcpy(skbp, header->addr1, ETH_ALEN); /* destination address */
 	if (le16_to_cpu(header->frame_control) & IEEE80211_FCTL_FROMDS)
-		memcpy(&skbp[6], header->addr3, 6);
+		memcpy(&skbp[ETH_ALEN], header->addr3, ETH_ALEN);
 	else
-		memcpy(&skbp[6], header->addr2, 6); /* source address */
+		memcpy(&skbp[ETH_ALEN], header->addr2, ETH_ALEN); /* source address */
 
 	skb->protocol = eth_type_trans(skb, priv->dev);
 	skb->ip_summed = CHECKSUM_NONE;
@@ -969,14 +969,14 @@ static void frag_rx_path(struct atmel_private *priv,
 			 u16 msdu_size, u16 rx_packet_loc, u32 crc, u16 seq_no,
 			 u8 frag_no, int more_frags)
 {
-	u8 mac4[6];
-	u8 source[6];
+	u8 mac4[ETH_ALEN];
+	u8 source[ETH_ALEN];
 	struct sk_buff *skb;
 
 	if (le16_to_cpu(header->frame_control) & IEEE80211_FCTL_FROMDS)
-		memcpy(source, header->addr3, 6);
+		memcpy(source, header->addr3, ETH_ALEN);
 	else
-		memcpy(source, header->addr2, 6);
+		memcpy(source, header->addr2, ETH_ALEN);
 
 	rx_packet_loc += 24; /* skip header */
 
@@ -984,9 +984,9 @@ static void frag_rx_path(struct atmel_private *priv,
 		msdu_size -= 4;
 
 	if (frag_no == 0) { /* first fragment */
-		atmel_copy_to_host(priv->dev, mac4, rx_packet_loc, 6);
-		msdu_size -= 6;
-		rx_packet_loc += 6;
+		atmel_copy_to_host(priv->dev, mac4, rx_packet_loc, ETH_ALEN);
+		msdu_size -= ETH_ALEN;
+		rx_packet_loc += ETH_ALEN;
 
 		if (priv->do_rx_crc)
 			crc = crc32_le(crc, mac4, 6);
@@ -994,9 +994,9 @@ static void frag_rx_path(struct atmel_private *priv,
 		priv->frag_seq = seq_no;
 		priv->frag_no = 1;
 		priv->frag_len = msdu_size;
-		memcpy(priv->frag_source, source, 6);
-		memcpy(&priv->rx_buf[6], source, 6);
-		memcpy(priv->rx_buf, header->addr1, 6);
+		memcpy(priv->frag_source, source, ETH_ALEN);
+		memcpy(&priv->rx_buf[ETH_ALEN], source, ETH_ALEN);
+		memcpy(priv->rx_buf, header->addr1, ETH_ALEN);
 
 		atmel_copy_to_host(priv->dev, &priv->rx_buf[12], rx_packet_loc, msdu_size);
 
@@ -1006,13 +1006,13 @@ static void frag_rx_path(struct atmel_private *priv,
 			atmel_copy_to_host(priv->dev, (void *)&netcrc, rx_packet_loc + msdu_size, 4);
 			if ((crc ^ 0xffffffff) != netcrc) {
 				priv->dev->stats.rx_crc_errors++;
-				memset(priv->frag_source, 0xff, 6);
+				memset(priv->frag_source, 0xff, ETH_ALEN);
 			}
 		}
 
 	} else if (priv->frag_no == frag_no &&
 		   priv->frag_seq == seq_no &&
-		   memcmp(priv->frag_source, source, 6) == 0) {
+		   memcmp(priv->frag_source, source, ETH_ALEN) == 0) {
 
 		atmel_copy_to_host(priv->dev, &priv->rx_buf[12 + priv->frag_len],
 				   rx_packet_loc, msdu_size);
@@ -1024,7 +1024,7 @@ static void frag_rx_path(struct atmel_private *priv,
 			atmel_copy_to_host(priv->dev, (void *)&netcrc, rx_packet_loc + msdu_size, 4);
 			if ((crc ^ 0xffffffff) != netcrc) {
 				priv->dev->stats.rx_crc_errors++;
-				memset(priv->frag_source, 0xff, 6);
+				memset(priv->frag_source, 0xff, ETH_ALEN);
 				more_frags = 1; /* don't send broken assembly */
 			}
 		}
@@ -1033,7 +1033,7 @@ static void frag_rx_path(struct atmel_private *priv,
 		priv->frag_no++;
 
 		if (!more_frags) { /* last one */
-			memset(priv->frag_source, 0xff, 6);
+			memset(priv->frag_source, 0xff, ETH_ALEN);
 			if (!(skb = dev_alloc_skb(priv->frag_len + 14))) {
 				priv->dev->stats.rx_dropped++;
 			} else {
@@ -1129,7 +1129,7 @@ static void rx_done_irq(struct atmel_private *priv)
 			atmel_copy_to_host(priv->dev, (unsigned char *)&priv->rx_buf, rx_packet_loc + 24, msdu_size);
 
 			/* we use the same buffer for frag reassembly and control packets */
-			memset(priv->frag_source, 0xff, 6);
+			memset(priv->frag_source, 0xff, ETH_ALEN);
 
 			if (priv->do_rx_crc) {
 				/* last 4 octets is crc */
@@ -1557,7 +1557,7 @@ struct net_device *init_atmel_card(unsigned short irq, unsigned long port,
 	priv->last_qual = jiffies;
 	priv->last_beacon_timestamp = 0;
 	memset(priv->frag_source, 0xff, sizeof(priv->frag_source));
-	memset(priv->BSSID, 0, 6);
+	memset(priv->BSSID, 0, ETH_ALEN);
 	priv->CurrentBSSID[0] = 0xFF; /* Initialize to something invalid.... */
 	priv->station_was_associated = 0;
 
@@ -1718,7 +1718,7 @@ static int atmel_get_wap(struct net_device *dev,
 			 char *extra)
 {
 	struct atmel_private *priv = netdev_priv(dev);
-	memcpy(awrq->sa_data, priv->CurrentBSSID, 6);
+	memcpy(awrq->sa_data, priv->CurrentBSSID, ETH_ALEN);
 	awrq->sa_family = ARPHRD_ETHER;
 
 	return 0;
@@ -2356,7 +2356,7 @@ static int atmel_get_scan(struct net_device *dev,
 	for (i = 0; i < priv->BSS_list_entries; i++) {
 		iwe.cmd = SIOCGIWAP;
 		iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
-		memcpy(iwe.u.ap_addr.sa_data, priv->BSSinfo[i].BSSID, 6);
+		memcpy(iwe.u.ap_addr.sa_data, priv->BSSinfo[i].BSSID, ETH_ALEN);
 		current_ev = iwe_stream_add_event(info, current_ev,
 						  extra + IW_SCAN_MAX_DATA,
 						  &iwe, IW_EV_ADDR_LEN);
@@ -2760,7 +2760,7 @@ static void atmel_enter_state(struct atmel_private *priv, int new_state)
 static void atmel_scan(struct atmel_private *priv, int specific_ssid)
 {
 	struct {
-		u8 BSSID[6];
+		u8 BSSID[ETH_ALEN];
 		u8 SSID[MAX_SSID_LENGTH];
 		u8 scan_type;
 		u8 channel;
@@ -2771,7 +2771,7 @@ static void atmel_scan(struct atmel_private *priv, int specific_ssid)
 		u8 SSID_size;
 	} cmd;
 
-	memset(cmd.BSSID, 0xff, 6);
+	memset(cmd.BSSID, 0xff, ETH_ALEN);
 
 	if (priv->fast_scan) {
 		cmd.SSID_size = priv->SSID_size;
@@ -2816,7 +2816,7 @@ static void join(struct atmel_private *priv, int type)
 
 	cmd.SSID_size = priv->SSID_size;
 	memcpy(cmd.SSID, priv->SSID, priv->SSID_size);
-	memcpy(cmd.BSSID, priv->CurrentBSSID, 6);
+	memcpy(cmd.BSSID, priv->CurrentBSSID, ETH_ALEN);
 	cmd.channel = (priv->channel & 0x7f);
 	cmd.BSS_type = type;
 	cmd.timeout = cpu_to_le16(2000);
@@ -2837,7 +2837,7 @@ static void start(struct atmel_private *priv, int type)
 
 	cmd.SSID_size = priv->SSID_size;
 	memcpy(cmd.SSID, priv->SSID, priv->SSID_size);
-	memcpy(cmd.BSSID, priv->BSSID, 6);
+	memcpy(cmd.BSSID, priv->BSSID, ETH_ALEN);
 	cmd.BSS_type = type;
 	cmd.channel = (priv->channel & 0x7f);
 
@@ -2883,9 +2883,9 @@ static void send_authentication_request(struct atmel_private *priv, u16 system,
 	header.frame_control = cpu_to_le16(IEEE80211_FTYPE_MGMT | IEEE80211_STYPE_AUTH);
 	header.duration_id = cpu_to_le16(0x8000);
 	header.seq_ctrl = 0;
-	memcpy(header.addr1, priv->CurrentBSSID, 6);
-	memcpy(header.addr2, priv->dev->dev_addr, 6);
-	memcpy(header.addr3, priv->CurrentBSSID, 6);
+	memcpy(header.addr1, priv->CurrentBSSID, ETH_ALEN);
+	memcpy(header.addr2, priv->dev->dev_addr, ETH_ALEN);
+	memcpy(header.addr3, priv->CurrentBSSID, ETH_ALEN);
 
 	if (priv->wep_is_on && priv->CurrentAuthentTransactionSeqNum != 1)
 		/* no WEP for authentication frames with TrSeqNo 1 */
@@ -2916,7 +2916,7 @@ static void send_association_request(struct atmel_private *priv, int is_reassoc)
 	struct ass_req_format {
 		__le16 capability;
 		__le16 listen_interval;
-		u8 ap[6]; /* nothing after here directly accessible */
+		u8 ap[ETH_ALEN]; /* nothing after here directly accessible */
 		u8 ssid_el_id;
 		u8 ssid_len;
 		u8 ssid[MAX_SSID_LENGTH];
@@ -2930,9 +2930,9 @@ static void send_association_request(struct atmel_private *priv, int is_reassoc)
 	header.duration_id = cpu_to_le16(0x8000);
 	header.seq_ctrl = 0;
 
-	memcpy(header.addr1, priv->CurrentBSSID, 6);
-	memcpy(header.addr2, priv->dev->dev_addr, 6);
-	memcpy(header.addr3, priv->CurrentBSSID, 6);
+	memcpy(header.addr1, priv->CurrentBSSID, ETH_ALEN);
+	memcpy(header.addr2, priv->dev->dev_addr, ETH_ALEN);
+	memcpy(header.addr3, priv->CurrentBSSID, ETH_ALEN);
 
 	body.capability = cpu_to_le16(WLAN_CAPABILITY_ESS);
 	if (priv->wep_is_on)
@@ -2944,7 +2944,7 @@ static void send_association_request(struct atmel_private *priv, int is_reassoc)
 
 	/* current AP address - only in reassoc frame */
 	if (is_reassoc) {
-		memcpy(body.ap, priv->CurrentBSSID, 6);
+		memcpy(body.ap, priv->CurrentBSSID, ETH_ALEN);
 		ssid_el_p = &body.ssid_el_id;
 		bodysize = 18 + priv->SSID_size;
 	} else {
@@ -3021,7 +3021,7 @@ static void store_bss_info(struct atmel_private *priv,
 	int i, index;
 
 	for (index = -1, i = 0; i < priv->BSS_list_entries; i++)
-		if (memcmp(bss, priv->BSSinfo[i].BSSID, 6) == 0)
+		if (memcmp(bss, priv->BSSinfo[i].BSSID, ETH_ALEN) == 0)
 			index = i;
 
 	/* If we process a probe and an entry from this BSS exists
@@ -3032,7 +3032,7 @@ static void store_bss_info(struct atmel_private *priv,
 		if (priv->BSS_list_entries == MAX_BSS_ENTRIES)
 			return;
 		index = priv->BSS_list_entries++;
-		memcpy(priv->BSSinfo[index].BSSID, bss, 6);
+		memcpy(priv->BSSinfo[index].BSSID, bss, ETH_ALEN);
 		priv->BSSinfo[index].RSSI = rssi;
 	} else {
 		if (rssi > priv->BSSinfo[index].RSSI)
@@ -3235,7 +3235,7 @@ static void atmel_join_bss(struct atmel_private *priv, int bss_index)
 {
 	struct bss_info *bss =  &priv->BSSinfo[bss_index];
 
-	memcpy(priv->CurrentBSSID, bss->BSSID, 6);
+	memcpy(priv->CurrentBSSID, bss->BSSID, ETH_ALEN);
 	memcpy(priv->SSID, bss->SSID, priv->SSID_size = bss->SSIDsize);
 
 	/* The WPA stuff cares about the current AP address */
@@ -3767,7 +3767,7 @@ static int probe_atmel_card(struct net_device *dev)
 				0x00, 0x04, 0x25, 0x00, 0x00, 0x00
 			};
 			printk(KERN_ALERT "%s: *** Invalid MAC address. UPGRADE Firmware ****\n", dev->name);
-			memcpy(dev->dev_addr, default_mac, 6);
+			memcpy(dev->dev_addr, default_mac, ETH_ALEN);
 		}
 	}
 
@@ -3819,7 +3819,7 @@ static void build_wpa_mib(struct atmel_private *priv)
 
 	struct { /* NB this is matched to the hardware, don't change. */
 		u8 cipher_default_key_value[MAX_ENCRYPTION_KEYS][MAX_ENCRYPTION_KEY_SIZE];
-		u8 receiver_address[6];
+		u8 receiver_address[ETH_ALEN];
 		u8 wep_is_on;
 		u8 default_key; /* 0..3 */
 		u8 group_key;
@@ -3837,7 +3837,7 @@ static void build_wpa_mib(struct atmel_private *priv)
 
 	mib.wep_is_on = priv->wep_is_on;
 	mib.exclude_unencrypted = priv->exclude_unencrypted;
-	memcpy(mib.receiver_address, priv->CurrentBSSID, 6);
+	memcpy(mib.receiver_address, priv->CurrentBSSID, ETH_ALEN);
 
 	/* zero all the keys before adding in valid ones. */
 	memset(mib.cipher_default_key_value, 0, sizeof(mib.cipher_default_key_value));
diff --git a/drivers/net/wireless/b43/xmit.c b/drivers/net/wireless/b43/xmit.c
index 8cb206a..4ae63f4 100644
--- a/drivers/net/wireless/b43/xmit.c
+++ b/drivers/net/wireless/b43/xmit.c
@@ -278,7 +278,7 @@ int b43_generate_txhdr(struct b43_wldev *dev,
 	else
 		txhdr->phy_rate = b43_plcp_get_ratecode_cck(rate);
 	txhdr->mac_frame_ctl = wlhdr->frame_control;
-	memcpy(txhdr->tx_receiver, wlhdr->addr1, 6);
+	memcpy(txhdr->tx_receiver, wlhdr->addr1, ETH_ALEN);
 
 	/* Calculate duration for fallback rate */
 	if ((rate_fb == rate) ||
diff --git a/drivers/net/wireless/b43legacy/xmit.c b/drivers/net/wireless/b43legacy/xmit.c
index 849a28c..86588c9 100644
--- a/drivers/net/wireless/b43legacy/xmit.c
+++ b/drivers/net/wireless/b43legacy/xmit.c
@@ -215,7 +215,7 @@ static int generate_txhdr_fw3(struct b43legacy_wldev *dev,
 	rate_fb_ofdm = b43legacy_is_ofdm_rate(rate_fb->hw_value);
 
 	txhdr->mac_frame_ctl = wlhdr->frame_control;
-	memcpy(txhdr->tx_receiver, wlhdr->addr1, 6);
+	memcpy(txhdr->tx_receiver, wlhdr->addr1, ETH_ALEN);
 
 	/* Calculate duration for fallback rate */
 	if ((rate_fb->hw_value == rate) ||
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/wireless/brcm80211/brcmsmac/main.c
index 4608e0e..69b14dc 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -1906,14 +1906,14 @@ static void brcms_c_get_macaddr(struct brcms_hardware *wlc_hw, u8 etheraddr[ETH_
 
 	/* If macaddr exists, use it (Sromrev4, CIS, ...). */
 	if (!is_zero_ether_addr(sprom->il0mac)) {
-		memcpy(etheraddr, sprom->il0mac, 6);
+		memcpy(etheraddr, sprom->il0mac, ETH_ALEN);
 		return;
 	}
 
 	if (wlc_hw->_nbands > 1)
-		memcpy(etheraddr, sprom->et1mac, 6);
+		memcpy(etheraddr, sprom->et1mac, ETH_ALEN);
 	else
-		memcpy(etheraddr, sprom->il0mac, 6);
+		memcpy(etheraddr, sprom->il0mac, ETH_ALEN);
 }
 
 /* power both the pll and external oscillator on/off */
diff --git a/drivers/net/wireless/hostap/hostap_info.c b/drivers/net/wireless/hostap/hostap_info.c
index 970a48b..de7c4ff 100644
--- a/drivers/net/wireless/hostap/hostap_info.c
+++ b/drivers/net/wireless/hostap/hostap_info.c
@@ -217,7 +217,7 @@ static void prism2_host_roaming(local_info_t *local)
 		}
 	}
 
-	memcpy(req.bssid, selected->bssid, 6);
+	memcpy(req.bssid, selected->bssid, ETH_ALEN);
 	req.channel = selected->chid;
 	spin_unlock_irqrestore(&local->lock, flags);
 
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 6b823a1..8711a51 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -2698,7 +2698,7 @@ static u16 eeprom_read_u16(struct ipw_priv *priv, u8 addr)
 /* data's copy of the eeprom data                                 */
 static void eeprom_parse_mac(struct ipw_priv *priv, u8 * mac)
 {
-	memcpy(mac, &priv->eeprom[EEPROM_MAC_ADDRESS], 6);
+	memcpy(mac, &priv->eeprom[EEPROM_MAC_ADDRESS], ETH_ALEN);
 }
 
 static void ipw_read_eeprom(struct ipw_priv *priv)
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index 1c22b81..8863a6c 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -183,7 +183,7 @@ prism54_update_stats(struct work_struct *work)
 	data = r.ptr;
 
 	/* copy this MAC to the bss */
-	memcpy(bss.address, data, 6);
+	memcpy(bss.address, data, ETH_ALEN);
 	kfree(data);
 
 	/* now ask for the corresponding bss */
@@ -531,7 +531,7 @@ prism54_set_wap(struct net_device *ndev, struct iw_request_info *info,
 		return -EINVAL;
 
 	/* prepare the structure for the set object */
-	memcpy(&bssid[0], awrq->sa_data, 6);
+	memcpy(&bssid[0], awrq->sa_data, ETH_ALEN);
 
 	/* set the bssid -- does this make sense when in AP mode? */
 	rvalue = mgt_set_request(priv, DOT11_OID_BSSID, 0, &bssid);
@@ -550,7 +550,7 @@ prism54_get_wap(struct net_device *ndev, struct iw_request_info *info,
 	int rvalue;
 
 	rvalue = mgt_get_request(priv, DOT11_OID_BSSID, 0, NULL, &r);
-	memcpy(awrq->sa_data, r.ptr, 6);
+	memcpy(awrq->sa_data, r.ptr, ETH_ALEN);
 	awrq->sa_family = ARPHRD_ETHER;
 	kfree(r.ptr);
 
@@ -582,7 +582,7 @@ prism54_translate_bss(struct net_device *ndev, struct iw_request_info *info,
 	size_t wpa_ie_len;
 
 	/* The first entry must be the MAC address */
-	memcpy(iwe.u.ap_addr.sa_data, bss->address, 6);
+	memcpy(iwe.u.ap_addr.sa_data, bss->address, ETH_ALEN);
 	iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 	iwe.cmd = SIOCGIWAP;
 	current_ev = iwe_stream_add_event(info, current_ev, end_buf,
@@ -2489,7 +2489,7 @@ prism54_set_mac_address(struct net_device *ndev, void *addr)
 			      &((struct sockaddr *) addr)->sa_data);
 	if (!ret)
 		memcpy(priv->ndev->dev_addr,
-		       &((struct sockaddr *) addr)->sa_data, 6);
+		       &((struct sockaddr *) addr)->sa_data, ETH_ALEN);
 
 	return ret;
 }
diff --git a/drivers/net/wireless/prism54/islpci_dev.c b/drivers/net/wireless/prism54/islpci_dev.c
index 5970ff6..41a16d3 100644
--- a/drivers/net/wireless/prism54/islpci_dev.c
+++ b/drivers/net/wireless/prism54/islpci_dev.c
@@ -837,7 +837,7 @@ islpci_setup(struct pci_dev *pdev)
 	/* ndev->set_multicast_list = &islpci_set_multicast_list; */
 	ndev->addr_len = ETH_ALEN;
 	/* Get a non-zero dummy MAC address for nameif. Jean II */
-	memcpy(ndev->dev_addr, dummy_mac, 6);
+	memcpy(ndev->dev_addr, dummy_mac, ETH_ALEN);
 
 	ndev->watchdog_timeo = ISLPCI_TX_TIMEOUT;
 
diff --git a/drivers/net/wireless/prism54/oid_mgt.c b/drivers/net/wireless/prism54/oid_mgt.c
index a01606b..056af38 100644
--- a/drivers/net/wireless/prism54/oid_mgt.c
+++ b/drivers/net/wireless/prism54/oid_mgt.c
@@ -682,7 +682,7 @@ mgt_update_addr(islpci_private *priv)
 				     isl_oid[GEN_OID_MACADDRESS].size, &res);
 
 	if ((ret == 0) && res && (res->header->operation != PIMFOR_OP_ERROR))
-		memcpy(priv->ndev->dev_addr, res->data, 6);
+		memcpy(priv->ndev->dev_addr, res->data, ETH_ALEN);
 	else
 		ret = -EIO;
 	if (res)
diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
index 733b7ce..210ce7c 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -115,7 +115,7 @@ static void rtl_op_stop(struct ieee80211_hw *hw)
 	mutex_lock(&rtlpriv->locks.conf_mutex);
 
 	mac->link_state = MAC80211_NOLINK;
-	memset(mac->bssid, 0, 6);
+	memset(mac->bssid, 0, ETH_ALEN);
 	mac->vendor = PEER_UNKNOWN;
 
 	/*reset sec info */
@@ -280,7 +280,7 @@ static void rtl_op_remove_interface(struct ieee80211_hw *hw,
 	mac->p2p = 0;
 	mac->vif = NULL;
 	mac->link_state = MAC80211_NOLINK;
-	memset(mac->bssid, 0, 6);
+	memset(mac->bssid, 0, ETH_ALEN);
 	mac->vendor = PEER_UNKNOWN;
 	mac->opmode = NL80211_IFTYPE_UNSPECIFIED;
 	rtlpriv->cfg->ops->set_network_type(hw, mac->opmode);
@@ -721,7 +721,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 			mac->link_state = MAC80211_LINKED;
 			mac->cnt_after_linked = 0;
 			mac->assoc_id = bss_conf->aid;
-			memcpy(mac->bssid, bss_conf->bssid, 6);
+			memcpy(mac->bssid, bss_conf->bssid, ETH_ALEN);
 
 			if (rtlpriv->cfg->ops->linked_set_reg)
 				rtlpriv->cfg->ops->linked_set_reg(hw);
@@ -750,7 +750,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 			if (ppsc->p2p_ps_info.p2p_ps_mode > P2P_PS_NONE)
 				rtl_p2p_ps_cmd(hw, P2P_PS_DISABLE);
 			mac->link_state = MAC80211_NOLINK;
-			memset(mac->bssid, 0, 6);
+			memset(mac->bssid, 0, ETH_ALEN);
 			mac->vendor = PEER_UNKNOWN;
 
 			if (rtlpriv->dm.supp_phymode_switch) {
@@ -826,7 +826,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 			 bss_conf->bssid);
 
 		mac->vendor = PEER_UNKNOWN;
-		memcpy(mac->bssid, bss_conf->bssid, 6);
+		memcpy(mac->bssid, bss_conf->bssid, ETH_ALEN);
 		rtlpriv->cfg->ops->set_network_type(hw, vif->type);
 
 		rcu_read_lock();
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index d1c5786..005d876 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -363,7 +363,7 @@ static struct sk_buff *br_ip4_multicast_alloc_query(struct net_bridge *br,
 	skb_reset_mac_header(skb);
 	eth = eth_hdr(skb);
 
-	memcpy(eth->h_source, br->dev->dev_addr, 6);
+	memcpy(eth->h_source, br->dev->dev_addr, ETH_ALEN);
 	eth->h_dest[0] = 1;
 	eth->h_dest[1] = 0;
 	eth->h_dest[2] = 0x5e;
@@ -433,7 +433,7 @@ static struct sk_buff *br_ip6_multicast_alloc_query(struct net_bridge *br,
 	skb_reset_mac_header(skb);
 	eth = eth_hdr(skb);
 
-	memcpy(eth->h_source, br->dev->dev_addr, 6);
+	memcpy(eth->h_source, br->dev->dev_addr, ETH_ALEN);
 	eth->h_proto = htons(ETH_P_IPV6);
 	skb_put(skb, sizeof(*eth));
 
diff --git a/net/bridge/netfilter/ebt_among.c b/net/bridge/netfilter/ebt_among.c
index 8b84c58..3fb3c84 100644
--- a/net/bridge/netfilter/ebt_among.c
+++ b/net/bridge/netfilter/ebt_among.c
@@ -28,7 +28,7 @@ static bool ebt_mac_wormhash_contains(const struct ebt_mac_wormhash *wh,
 	uint32_t cmp[2] = { 0, 0 };
 	int key = ((const unsigned char *)mac)[5];
 
-	memcpy(((char *) cmp) + 2, mac, 6);
+	memcpy(((char *) cmp) + 2, mac, ETH_ALEN);
 	start = wh->table[key];
 	limit = wh->table[key + 1];
 	if (ip) {
diff --git a/net/mac80211/trace.h b/net/mac80211/trace.h
index 1aba645..3fb9dd6 100644
--- a/net/mac80211/trace.h
+++ b/net/mac80211/trace.h
@@ -77,13 +77,13 @@ DECLARE_EVENT_CLASS(local_sdata_addr_evt,
 	TP_STRUCT__entry(
 		LOCAL_ENTRY
 		VIF_ENTRY
-		__array(char, addr, 6)
+		__array(char, addr, ETH_ALEN)
 	),
 
 	TP_fast_assign(
 		LOCAL_ASSIGN;
 		VIF_ASSIGN;
-		memcpy(__entry->addr, sdata->vif.addr, 6);
+		memcpy(__entry->addr, sdata->vif.addr, ETH_ALEN);
 	),
 
 	TP_printk(



------------------------------------------------------------------------------
October Webinars: Code for Performance
Free Intel webinars can help you accelerate application performance.
Explore tips for MPI, OpenMP, advanced profiling, and more. Get the most from 
the latest Intel processors and coprocessors. See abstracts and register >
http://pubads.g.doubleclick.net/gampad/clk?id=60134791&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
