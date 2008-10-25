From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] convert print_mac to %pM
Date: Sat, 25 Oct 2008 02:21:39 +0200
Message-ID: <1224894099.3919.43.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:55193 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757494AbYJYAVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 20:21:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This converts pretty much everything to print_mac. There were
a few things that had conflicts which I have just dropped for
now, no harm done.

I've built an allyesconfig with this and looked at the files
that weren't built very carefully, but it's a huge patch.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 arch/arm/mach-ixp4xx/fsg-setup.c              |    9 
 arch/arm/mach-ixp4xx/nas100d-setup.c          |    5 
 arch/arm/mach-ixp4xx/nslu2-setup.c            |    5 
 drivers/infiniband/hw/nes/nes.c               |    6 
 drivers/infiniband/hw/nes/nes_cm.c            |   10 -
 drivers/infiniband/hw/nes/nes_nic.c           |   10 -
 drivers/net/3c503.c                           |    3 
 drivers/net/3c505.c                           |    5 
 drivers/net/3c507.c                           |    3 
 drivers/net/3c509.c                           |    5 
 drivers/net/3c515.c                           |    3 
 drivers/net/3c523.c                           |   10 -
 drivers/net/3c527.c                           |    3 
 drivers/net/3c59x.c                           |    3 
 drivers/net/8139cp.c                          |    5 
 drivers/net/8139too.c                         |    5 
 drivers/net/82596.c                           |   13 -
 drivers/net/a2065.c                           |    4 
 drivers/net/ac3200.c                          |    5 
 drivers/net/acenic.c                          |    3 
 drivers/net/amd8111e.c                        |    5 
 drivers/net/apne.c                            |    3 
 drivers/net/ariadne.c                         |   20 --
 drivers/net/arm/am79c961a.c                   |    6 
 drivers/net/arm/at91_ether.c                  |   10 -
 drivers/net/arm/ether1.c                      |    5 
 drivers/net/arm/ether3.c                      |    5 
 drivers/net/arm/etherh.c                      |    5 
 drivers/net/at1700.c                          |    3 
 drivers/net/atarilance.c                      |   17 -
 drivers/net/atp.c                             |    5 
 drivers/net/ax88796.c                         |    9 
 drivers/net/b44.c                             |    5 
 drivers/net/bmac.c                            |    5 
 drivers/net/bnx2.c                            |    5 
 drivers/net/bnx2x_main.c                      |    3 
 drivers/net/bonding/bond_main.c               |   15 -
 drivers/net/bonding/bond_sysfs.c              |    4 
 drivers/net/cassini.c                         |    5 
 drivers/net/cpmac.c                           |    5 
 drivers/net/cris/eth_v10.c                    |    4 
 drivers/net/cs89x0.c                          |   12 -
 drivers/net/de600.c                           |    3 
 drivers/net/de620.c                           |    3 
 drivers/net/declance.c                        |    4 
 drivers/net/depca.c                           |    6 
 drivers/net/dl2k.c                            |    5 
 drivers/net/dm9000.c                          |    8 
 drivers/net/e100.c                            |    5 
 drivers/net/e1000/e1000_main.c                |    3 
 drivers/net/eepro.c                           |    3 
 drivers/net/eepro100.c                        |    5 
 drivers/net/enc28j60.c                        |   16 -
 drivers/net/epic100.c                         |    5 
 drivers/net/es3210.c                          |    9 
 drivers/net/ewrk3.c                           |    7 
 drivers/net/fealnx.c                          |    5 
 drivers/net/fec.c                             |    4 
 drivers/net/forcedeth.c                       |    9 
 drivers/net/gianfar.c                         |    4 
 drivers/net/hamachi.c                         |    5 
 drivers/net/hamradio/bpqether.c               |    7 
 drivers/net/hp-plus.c                         |    3 
 drivers/net/hp.c                              |    3 
 drivers/net/hp100.c                           |    5 
 drivers/net/hydra.c                           |    5 
 drivers/net/ibmlana.c                         |    5 
 drivers/net/ibmveth.c                         |    5 
 drivers/net/ioc3-eth.c                        |    5 
 drivers/net/isa-skeleton.c                    |    3 
 drivers/net/jazzsonic.c                       |    4 
 drivers/net/lance.c                           |    3 
 drivers/net/lib82596.c                        |   13 -
 drivers/net/lne390.c                          |    5 
 drivers/net/mac89x0.c                         |    4 
 drivers/net/macb.c                            |    7 
 drivers/net/mace.c                            |    5 
 drivers/net/macmace.c                         |    5 
 drivers/net/macsonic.c                        |    9 
 drivers/net/meth.c                            |    3 
 drivers/net/mv643xx_eth.c                     |    5 
 drivers/net/mvme147.c                         |    5 
 drivers/net/myri10ge/myri10ge.c               |    4 
 drivers/net/myri_sbus.c                       |   14 -
 drivers/net/natsemi.c                         |    5 
 drivers/net/ne-h8300.c                        |    3 
 drivers/net/ne.c                              |    3 
 drivers/net/ne2.c                             |    6 
 drivers/net/ne2k-pci.c                        |    5 
 drivers/net/ne3210.c                          |    5 
 drivers/net/netconsole.c                      |    9 
 drivers/net/netxen/netxen_nic_main.c          |    8 
 drivers/net/netxen/netxen_nic_niu.c           |    7 
 drivers/net/ni5010.c                          |    3 
 drivers/net/niu.c                             |    4 
 drivers/net/ns83820.c                         |    6 
 drivers/net/pasemi_mac.c                      |    5 
 drivers/net/pci-skeleton.c                    |    5 
 drivers/net/pcmcia/3c574_cs.c                 |    5 
 drivers/net/pcmcia/3c589_cs.c                 |    5 
 drivers/net/pcmcia/axnet_cs.c                 |    5 
 drivers/net/pcmcia/fmvj18x_cs.c               |    5 
 drivers/net/pcmcia/nmclan_cs.c                |    5 
 drivers/net/pcmcia/pcnet_cs.c                 |    3 
 drivers/net/pcmcia/smc91c92_cs.c              |    5 
 drivers/net/pcmcia/xirc2ps_cs.c               |    5 
 drivers/net/pcnet32.c                         |    3 
 drivers/net/pppoe.c                           |    5 
 drivers/net/ps3_gelic_net.c                   |    6 
 drivers/net/ps3_gelic_wireless.c              |   14 -
 drivers/net/qla3xxx.c                         |    5 
 drivers/net/r8169.c                           |    9 
 drivers/net/rionet.c                          |    5 
 drivers/net/rrunner.c                         |    3 
 drivers/net/s2io.c                            |    4 
 drivers/net/sb1250-mac.c                      |    5 
 drivers/net/seeq8005.c                        |    3 
 drivers/net/sfc/efx.c                         |   15 -
 drivers/net/sgiseeq.c                         |    4 
 drivers/net/sis190.c                          |    6 
 drivers/net/sis900.c                          |    5 
 drivers/net/skge.c                            |    5 
 drivers/net/sky2.c                            |    5 
 drivers/net/smc-mca.c                         |    5 
 drivers/net/smc-ultra.c                       |    5 
 drivers/net/smc-ultra32.c                     |    5 
 drivers/net/smc9194.c                         |    4 
 drivers/net/smc91x.c                          |    5 
 drivers/net/starfire.c                        |   13 -
 drivers/net/sun3lance.c                       |    9 
 drivers/net/sunbmac.c                         |    5 
 drivers/net/sundance.c                        |    5 
 drivers/net/sungem.c                          |    6 
 drivers/net/sunhme.c                          |    6 
 drivers/net/sunlance.c                        |    5 
 drivers/net/sunvnet.c                         |    5 
 drivers/net/tc35815.c                         |   17 -
 drivers/net/tg3.c                             |    5 
 drivers/net/tokenring/abyss.c                 |    4 
 drivers/net/tokenring/ibmtr.c                 |   10 -
 drivers/net/tokenring/lanstreamer.c           |   35 +--
 drivers/net/tokenring/madgemc.c               |   10 -
 drivers/net/tokenring/olympic.c               |   50 +----
 drivers/net/tokenring/proteon.c               |    5 
 drivers/net/tokenring/skisa.c                 |    5 
 drivers/net/tokenring/tmspci.c                |    5 
 drivers/net/tsi108_eth.c                      |    5 
 drivers/net/tulip/de2104x.c                   |    5 
 drivers/net/tulip/de4x5.c                     |   12 -
 drivers/net/tulip/dmfe.c                      |    6 
 drivers/net/tulip/tulip_core.c                |   11 -
 drivers/net/tulip/uli526x.c                   |    5 
 drivers/net/tulip/winbond-840.c               |   15 -
 drivers/net/tulip/xircom_cb.c                 |    3 
 drivers/net/tun.c                             |    5 
 drivers/net/typhoon.c                         |    5 
 drivers/net/usb/pegasus.c                     |    5 
 drivers/net/usb/smsc95xx.c                    |    4 
 drivers/net/usb/usbnet.c                      |    5 
 drivers/net/via-rhine.c                       |    5 
 drivers/net/virtio_net.c                      |    4 
 drivers/net/wd.c                              |    5 
 drivers/net/wireless/adm8211.c                |    5 
 drivers/net/wireless/airo.c                   |   17 -
 drivers/net/wireless/arlan-main.c             |   26 +-
 drivers/net/wireless/ath9k/hw.c               |    5 
 drivers/net/wireless/ath9k/main.c             |   19 --
 drivers/net/wireless/ath9k/rc.c               |    9 
 drivers/net/wireless/atmel.c                  |    5 
 drivers/net/wireless/b43/main.c               |    5 
 drivers/net/wireless/hostap/hostap_80211_rx.c |   59 ++----
 drivers/net/wireless/hostap/hostap_80211_tx.c |   15 -
 drivers/net/wireless/hostap/hostap_ap.c       |  241 ++++++++------------------
 drivers/net/wireless/hostap/hostap_hw.c       |   10 -
 drivers/net/wireless/hostap/hostap_info.c     |   16 -
 drivers/net/wireless/hostap/hostap_ioctl.c    |   16 -
 drivers/net/wireless/hostap/hostap_main.c     |   26 --
 drivers/net/wireless/hostap/hostap_proc.c     |   15 -
 drivers/net/wireless/ipw2100.c                |   31 ---
 drivers/net/wireless/ipw2200.c                |  217 ++++++++++-------------
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c    |    5 
 drivers/net/wireless/iwlwifi/iwl-3945.c       |    5 
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c     |   18 -
 drivers/net/wireless/iwlwifi/iwl-agn.c        |   47 +----
 drivers/net/wireless/iwlwifi/iwl-debugfs.c    |    2 
 drivers/net/wireless/iwlwifi/iwl-sta.c        |   38 +---
 drivers/net/wireless/iwlwifi/iwl-tx.c         |   17 -
 drivers/net/wireless/iwlwifi/iwl3945-base.c   |   54 +----
 drivers/net/wireless/libertas/assoc.c         |   32 +--
 drivers/net/wireless/libertas/cmd.c           |    5 
 drivers/net/wireless/libertas/debugfs.c       |    6 
 drivers/net/wireless/libertas/main.c          |    9 
 drivers/net/wireless/libertas/scan.c          |   11 -
 drivers/net/wireless/libertas/wext.c          |    3 
 drivers/net/wireless/libertas_tf/cmd.c        |    5 
 drivers/net/wireless/mac80211_hwsim.c         |   15 -
 drivers/net/wireless/netwave_cs.c             |    5 
 drivers/net/wireless/orinoco.c                |   10 -
 drivers/net/wireless/p54/p54common.c          |    5 
 drivers/net/wireless/prism54/isl_ioctl.c      |   24 +-
 drivers/net/wireless/ray_cs.c                 |    9 
 drivers/net/wireless/rndis_wlan.c             |    9 
 drivers/net/wireless/rt2x00/rt2400pci.c       |    4 
 drivers/net/wireless/rt2x00/rt2500pci.c       |    5 
 drivers/net/wireless/rt2x00/rt2500usb.c       |    4 
 drivers/net/wireless/rt2x00/rt61pci.c         |    4 
 drivers/net/wireless/rt2x00/rt73usb.c         |    4 
 drivers/net/wireless/rtl8180_dev.c            |    5 
 drivers/net/wireless/rtl8187_dev.c            |    5 
 drivers/net/wireless/wavelan.c                |   33 +--
 drivers/net/wireless/wavelan_cs.c             |   30 +--
 drivers/net/wireless/wl3501_cs.c              |   10 -
 drivers/net/wireless/zd1211rw/zd_chip.c       |    4 
 drivers/net/wireless/zd1211rw/zd_mac.c        |    6 
 drivers/net/yellowfin.c                       |   13 -
 drivers/net/znet.c                            |    5 
 drivers/net/zorro8390.c                       |    7 
 drivers/usb/gadget/u_ether.c                  |    6 
 net/802/tr.c                                  |   22 --
 net/appletalk/aarp.c                          |    3 
 net/atm/br2684.c                              |    5 
 net/atm/lec.c                                 |   26 --
 net/core/netpoll.c                            |    5 
 net/core/pktgen.c                             |    9 
 net/ieee80211/ieee80211_crypt_ccmp.c          |   13 -
 net/ieee80211/ieee80211_crypt_tkip.c          |   29 +--
 net/ieee80211/ieee80211_rx.c                  |   71 ++-----
 net/ieee80211/ieee80211_wx.c                  |    5 
 net/irda/irlan/irlan_client.c                 |    4 
 net/llc/llc_proc.c                            |    3 
 230 files changed, 891 insertions(+), 1565 deletions(-)

--- test-tree.orig/drivers/net/starfire.c	2008-10-25 02:15:05.000000000 +0200
+++ test-tree/drivers/net/starfire.c	2008-10-25 02:15:59.000000000 +0200
@@ -653,7 +653,6 @@ static int __devinit starfire_init_one(s
 	void __iomem *base;
 	int drv_flags, io_size;
 	int boguscnt;
-	DECLARE_MAC_BUF(mac);
 
 /* when built into the kernel, we only print version if device is found */
 #ifndef MODULE
@@ -823,9 +822,9 @@ static int __devinit starfire_init_one(s
 	if (register_netdev(dev))
 		goto err_out_cleardev;
 
-	printk(KERN_INFO "%s: %s at %p, %s, IRQ %d.\n",
+	printk(KERN_INFO "%s: %s at %p, %pM, IRQ %d.\n",
 	       dev->name, netdrv_tbl[chip_idx].name, base,
-	       print_mac(mac, dev->dev_addr), irq);
+	       dev->dev_addr, irq);
 
 	if (drv_flags & CanHaveMII) {
 		int phy, phy_idx = 0;
@@ -1452,12 +1451,8 @@ static int __netdev_rx(struct net_device
 #ifndef final_version			/* Remove after testing. */
 		/* You will want this info for the initial debug. */
 		if (debug > 5) {
-			printk(KERN_DEBUG "  Rx data " MAC_FMT " " MAC_FMT
-			       " %2.2x%2.2x.\n",
-			       skb->data[0], skb->data[1], skb->data[2],
-			       skb->data[3], skb->data[4], skb->data[5],
-			       skb->data[6], skb->data[7], skb->data[8],
-			       skb->data[9], skb->data[10], skb->data[11],
+			printk(KERN_DEBUG "  Rx data %pM %pM %2.2x%2.2x.\n",
+			       skb->data, skb->data + 6,
 			       skb->data[12], skb->data[13]);
 		}
 #endif
--- test-tree.orig/drivers/net/tokenring/olympic.c	2008-10-25 02:15:02.000000000 +0200
+++ test-tree/drivers/net/tokenring/olympic.c	2008-10-25 02:15:59.000000000 +0200
@@ -421,10 +421,7 @@ static int olympic_init(struct net_devic
 	memcpy_fromio(&dev->dev_addr[0], adapter_addr,6);
 
 #if OLYMPIC_DEBUG
- {
-	DECLARE_MAC_BUF(mac);
-	printk("adapter address: %s\n", print_mac(mac, dev->dev_addr));
- }
+	printk("adapter address: %pM\n", dev->dev_addr);
 #endif
 
 	olympic_priv->olympic_addr_table_addr = swab16(readw(init_srb + 12)); 
@@ -441,7 +438,6 @@ static int olympic_open(struct net_devic
 	unsigned long flags, t;
 	int i, open_finished = 1 ;
 	u8 resp, err;
-	DECLARE_MAC_BUF(mac);
 
 	DECLARE_WAITQUEUE(wait,current) ; 
 
@@ -569,8 +565,8 @@ static int olympic_open(struct net_devic
 			goto out;
 
 		case 0x32:
-			printk(KERN_WARNING "%s: Invalid LAA: %s\n",
-			       dev->name, print_mac(mac, olympic_priv->olympic_laa));
+			printk(KERN_WARNING "%s: Invalid LAA: %pM\n",
+			       dev->name, olympic_priv->olympic_laa);
 			goto out;
 
 		default:
@@ -704,13 +700,12 @@ static int olympic_open(struct net_devic
 		u8 __iomem *opt;
 		int i;
 		u8 addr[6];
-		DECLARE_MAC_BUF(mac);
 		oat = (olympic_priv->olympic_lap + olympic_priv->olympic_addr_table_addr);
 		opt = (olympic_priv->olympic_lap + olympic_priv->olympic_parms_addr);
 
 		for (i = 0; i < 6; i++)
 			addr[i] = readb(oat+offsetof(struct olympic_adapter_addr_table,node_addr)+i);
-		printk("%s: Node Address: %s\n",dev->name, print_mac(mac, addr));
+		printk("%s: Node Address: %pM\n", dev->name, addr);
 		printk("%s: Functional Address: %02x:%02x:%02x:%02x\n",dev->name, 
 			readb(oat+offsetof(struct olympic_adapter_addr_table,func_addr)), 
 			readb(oat+offsetof(struct olympic_adapter_addr_table,func_addr)+1),
@@ -719,7 +714,7 @@ static int olympic_open(struct net_devic
 
 		for (i = 0; i < 6; i++)
 			addr[i] = readb(opt+offsetof(struct olympic_parameters_table, up_node_addr)+i);
-		printk("%s: NAUN Address: %s\n",dev->name, print_mac(mac, addr));
+		printk("%s: NAUN Address: %pM\n", dev->name, addr);
 	}
 	
 	netif_start_queue(dev);
@@ -1440,16 +1435,10 @@ static void olympic_arb_cmd(struct net_d
 			struct trh_hdr *mac_hdr;
 			printk(KERN_WARNING "%s: Received MAC Frame, details: \n",dev->name);
 			mac_hdr = tr_hdr(mac_frame);
-			printk(KERN_WARNING "%s: MAC Frame Dest. Addr: "
-			       MAC_FMT " \n", dev->name,
-			       mac_hdr->daddr[0], mac_hdr->daddr[1],
-			       mac_hdr->daddr[2], mac_hdr->daddr[3],
-			       mac_hdr->daddr[4], mac_hdr->daddr[5]);
-			printk(KERN_WARNING "%s: MAC Frame Srce. Addr: "
-			       MAC_FMT " \n", dev->name,
-			       mac_hdr->saddr[0], mac_hdr->saddr[1],
-			       mac_hdr->saddr[2], mac_hdr->saddr[3],
-			       mac_hdr->saddr[4], mac_hdr->saddr[5]);
+			printk(KERN_WARNING "%s: MAC Frame Dest. Addr: %pM\n",
+			       dev->name, mac_hdr->daddr);
+			printk(KERN_WARNING "%s: MAC Frame Srce. Addr: %pM\n",
+			       dev->name, mac_hdr->saddr);
 		}
 		netif_rx(mac_frame);
 		dev->last_rx = jiffies;
@@ -1647,8 +1636,6 @@ static int olympic_proc_info(char *buffe
 	u8 addr[6];
 	u8 addr2[6];
 	int i;
-	DECLARE_MAC_BUF(mac);
-	DECLARE_MAC_BUF(mac2);
 
 	size = sprintf(buffer, 
 		"IBM Pit/Pit-Phy/Olympic Chipset Token Ring Adapter %s\n",dev->name);
@@ -1658,10 +1645,9 @@ static int olympic_proc_info(char *buffe
 	for (i = 0 ; i < 6 ; i++)
 		addr[i] = readb(oat+offsetof(struct olympic_adapter_addr_table,node_addr) + i);
 
-	size += sprintf(buffer+size, "%6s: %s : %s : %02x:%02x:%02x:%02x\n",
+	size += sprintf(buffer+size, "%6s: %pM : %pM : %02x:%02x:%02x:%02x\n",
 	   dev->name,
-	   print_mac(mac, dev->dev_addr),
-	   print_mac(mac2, addr),
+	   dev->dev_addr, addr,
 	   readb(oat+offsetof(struct olympic_adapter_addr_table,func_addr)), 
 	   readb(oat+offsetof(struct olympic_adapter_addr_table,func_addr)+1),
 	   readb(oat+offsetof(struct olympic_adapter_addr_table,func_addr)+2),
@@ -1677,14 +1663,13 @@ static int olympic_proc_info(char *buffe
 	for (i = 0 ; i < 6 ; i++)
 		addr2[i] =  readb(opt+offsetof(struct olympic_parameters_table, poll_addr) + i);
 
-	size += sprintf(buffer+size, "%6s: %02x:%02x:%02x:%02x   : %s : %s : %04x   : %04x     :  %04x    :\n",
+	size += sprintf(buffer+size, "%6s: %02x:%02x:%02x:%02x   : %pM : %pM : %04x   : %04x     :  %04x    :\n",
 	  dev->name,
 	  readb(opt+offsetof(struct olympic_parameters_table, phys_addr)),
 	  readb(opt+offsetof(struct olympic_parameters_table, phys_addr)+1),
 	  readb(opt+offsetof(struct olympic_parameters_table, phys_addr)+2),
 	  readb(opt+offsetof(struct olympic_parameters_table, phys_addr)+3),
-	  print_mac(mac, addr),
-	  print_mac(mac2, addr2),
+	  addr, addr2,
 	  swab16(readw(opt+offsetof(struct olympic_parameters_table, acc_priority))),
 	  swab16(readw(opt+offsetof(struct olympic_parameters_table, auth_source_class))),
 	  swab16(readw(opt+offsetof(struct olympic_parameters_table, att_code))));
@@ -1694,9 +1679,8 @@ static int olympic_proc_info(char *buffe
 	
 	for (i = 0 ; i < 6 ; i++)
 		addr[i] = readb(opt+offsetof(struct olympic_parameters_table, source_addr) + i);
-	size += sprintf(buffer+size, "%6s: %s : %04x  : %04x   : %04x   : %04x   : %04x    :     %04x     : \n",
-	  dev->name,
-	  print_mac(mac, addr),
+	size += sprintf(buffer+size, "%6s: %pM : %04x  : %04x   : %04x   : %04x   : %04x    :     %04x     : \n",
+	  dev->name, addr,
 	  swab16(readw(opt+offsetof(struct olympic_parameters_table, beacon_type))),
 	  swab16(readw(opt+offsetof(struct olympic_parameters_table, major_vector))),
 	  swab16(readw(opt+offsetof(struct olympic_parameters_table, lan_status))),
@@ -1709,11 +1693,11 @@ static int olympic_proc_info(char *buffe
 
 	for (i = 0 ; i < 6 ; i++)
 		addr[i] = readb(opt+offsetof(struct olympic_parameters_table, beacon_naun) + i);
-	size += sprintf(buffer+size, "%6s:                :  %02x  :  %02x  : %s : %02x:%02x:%02x:%02x    : \n",
+	size += sprintf(buffer+size, "%6s:                :  %02x  :  %02x  : %pM : %02x:%02x:%02x:%02x    : \n",
 	  dev->name,
 	  swab16(readw(opt+offsetof(struct olympic_parameters_table, beacon_transmit))),
 	  swab16(readw(opt+offsetof(struct olympic_parameters_table, beacon_receive))),
-	  print_mac(mac, addr),
+	  addr,
 	  readb(opt+offsetof(struct olympic_parameters_table, beacon_phys)),
 	  readb(opt+offsetof(struct olympic_parameters_table, beacon_phys)+1),
 	  readb(opt+offsetof(struct olympic_parameters_table, beacon_phys)+2),
--- test-tree.orig/drivers/net/virtio_net.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/virtio_net.c	2008-10-25 02:15:59.000000000 +0200
@@ -325,9 +325,7 @@ static int xmit_skb(struct virtnet_info 
 
 	sg_init_table(sg, 2+MAX_SKB_FRAGS);
 
-	pr_debug("%s: xmit %p " MAC_FMT "\n", vi->dev->name, skb,
-		 dest[0], dest[1], dest[2],
-		 dest[3], dest[4], dest[5]);
+	pr_debug("%s: xmit %p %pM\n", vi->dev->name, skb, dest);
 
 	/* Encode metadata header at front. */
 	hdr = skb_vnet_hdr(skb);
--- test-tree.orig/drivers/net/wireless/hostap/hostap_80211_rx.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/hostap/hostap_80211_rx.c	2008-10-25 02:15:59.000000000 +0200
@@ -19,7 +19,6 @@ void hostap_dump_rx_80211(const char *na
 {
 	struct ieee80211_hdr_4addr *hdr;
 	u16 fc;
-	DECLARE_MAC_BUF(mac);
 
 	hdr = (struct ieee80211_hdr_4addr *) skb->data;
 
@@ -45,11 +44,11 @@ void hostap_dump_rx_80211(const char *na
 	printk(" dur=0x%04x seq=0x%04x\n", le16_to_cpu(hdr->duration_id),
 	       le16_to_cpu(hdr->seq_ctl));
 
-	printk(KERN_DEBUG "   A1=%s", print_mac(mac, hdr->addr1));
-	printk(" A2=%s", print_mac(mac, hdr->addr2));
-	printk(" A3=%s", print_mac(mac, hdr->addr3));
+	printk(KERN_DEBUG "   A1=%pM", hdr->addr1);
+	printk(" A2=%pM", hdr->addr2);
+	printk(" A3=%pM", hdr->addr3);
 	if (skb->len >= 30)
-		printk(" A4=%s", print_mac(mac, hdr->addr4));
+		printk(" A4=%pM", hdr->addr4);
 	printk("\n");
 }
 
@@ -557,7 +556,6 @@ static int
 hostap_rx_frame_wds(local_info_t *local, struct ieee80211_hdr_4addr *hdr,
 		    u16 fc, struct net_device **wds)
 {
-	DECLARE_MAC_BUF(mac);
 	/* FIX: is this really supposed to accept WDS frames only in Master
 	 * mode? What about Repeater or Managed with WDS frames? */
 	if ((fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) !=
@@ -573,10 +571,10 @@ hostap_rx_frame_wds(local_info_t *local,
 	     hdr->addr1[4] != 0xff || hdr->addr1[5] != 0xff)) {
 		/* RA (or BSSID) is not ours - drop */
 		PDEBUG(DEBUG_EXTRA2, "%s: received WDS frame with "
-		       "not own or broadcast %s=%s\n",
+		       "not own or broadcast %s=%pM\n",
 		       local->dev->name,
 		       fc & IEEE80211_FCTL_FROMDS ? "RA" : "BSSID",
-		       print_mac(mac, hdr->addr1));
+		       hdr->addr1);
 		return -1;
 	}
 
@@ -589,8 +587,8 @@ hostap_rx_frame_wds(local_info_t *local,
 		/* require that WDS link has been registered with TA or the
 		 * frame is from current AP when using 'AP client mode' */
 		PDEBUG(DEBUG_EXTRA, "%s: received WDS[4 addr] frame "
-		       "from unknown TA=%s\n",
-		       local->dev->name, print_mac(mac, hdr->addr2));
+		       "from unknown TA=%pM\n",
+		       local->dev->name, hdr->addr2);
 		if (local->ap && local->ap->autom_ap_wds)
 			hostap_wds_link_oper(local, hdr->addr2, WDS_ADD);
 		return -1;
@@ -667,10 +665,8 @@ hostap_rx_frame_decrypt(local_info_t *lo
 	    strcmp(crypt->ops->name, "TKIP") == 0) {
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "%s: TKIP countermeasures: dropped "
-			       "received packet from " MAC_FMT "\n",
-			       local->dev->name,
-			       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
-			       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5]);
+			       "received packet from %pM\n",
+			       local->dev->name, hdr->addr2);
 		}
 		return -1;
 	}
@@ -679,12 +675,8 @@ hostap_rx_frame_decrypt(local_info_t *lo
 	res = crypt->ops->decrypt_mpdu(skb, hdrlen, crypt->priv);
 	atomic_dec(&crypt->refcnt);
 	if (res < 0) {
-		printk(KERN_DEBUG "%s: decryption failed (SA=" MAC_FMT
-		       ") res=%d\n",
-		       local->dev->name,
-		       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
-		       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5],
-		       res);
+		printk(KERN_DEBUG "%s: decryption failed (SA=%pM) res=%d\n",
+		       local->dev->name, hdr->addr2, res);
 		local->comm_tallies.rx_discards_wep_undecryptable++;
 		return -1;
 	}
@@ -700,7 +692,6 @@ hostap_rx_frame_decrypt_msdu(local_info_
 {
 	struct ieee80211_hdr_4addr *hdr;
 	int res, hdrlen;
-	DECLARE_MAC_BUF(mac);
 
 	if (crypt == NULL || crypt->ops->decrypt_msdu == NULL)
 		return 0;
@@ -713,8 +704,8 @@ hostap_rx_frame_decrypt_msdu(local_info_
 	atomic_dec(&crypt->refcnt);
 	if (res < 0) {
 		printk(KERN_DEBUG "%s: MSDU decryption/MIC verification failed"
-		       " (SA=%s keyidx=%d)\n",
-		       local->dev->name, print_mac(mac, hdr->addr2), keyidx);
+		       " (SA=%pM keyidx=%d)\n",
+		       local->dev->name, hdr->addr2, keyidx);
 		return -1;
 	}
 
@@ -822,10 +813,8 @@ void hostap_80211_rx(struct net_device *
 			 * frames silently instead of filling system log with
 			 * these reports. */
 			printk(KERN_DEBUG "%s: WEP decryption failed (not set)"
-			       " (SA=" MAC_FMT ")\n",
-			       local->dev->name,
-			       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
-			       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5]);
+			       " (SA=%pM)\n",
+			       local->dev->name, hdr->addr2);
 #endif
 			local->comm_tallies.rx_discards_wep_undecryptable++;
 			goto rx_dropped;
@@ -839,9 +828,7 @@ void hostap_80211_rx(struct net_device *
 		    (keyidx = hostap_rx_frame_decrypt(local, skb, crypt)) < 0)
 		{
 			printk(KERN_DEBUG "%s: failed to decrypt mgmt::auth "
-			       "from " MAC_FMT "\n", dev->name,
-			       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
-			       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5]);
+			       "from %pM\n", dev->name, hdr->addr2);
 			/* TODO: could inform hostapd about this so that it
 			 * could send auth failure report */
 			goto rx_dropped;
@@ -1009,10 +996,8 @@ void hostap_80211_rx(struct net_device *
 			       "unencrypted EAPOL frame\n", local->dev->name);
 		} else {
 			printk(KERN_DEBUG "%s: encryption configured, but RX "
-			       "frame not encrypted (SA=" MAC_FMT ")\n",
-			       local->dev->name,
-			       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
-			       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5]);
+			       "frame not encrypted (SA=%pM)\n",
+			       local->dev->name, hdr->addr2);
 			goto rx_dropped;
 		}
 	}
@@ -1021,10 +1006,8 @@ void hostap_80211_rx(struct net_device *
 	    !hostap_is_eapol_frame(local, skb)) {
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "%s: dropped unencrypted RX data "
-			       "frame from " MAC_FMT " (drop_unencrypted=1)\n",
-			       dev->name,
-			       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
-			       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5]);
+			       "frame from %pM (drop_unencrypted=1)\n",
+			       dev->name, hdr->addr2);
 		}
 		goto rx_dropped;
 	}
--- test-tree.orig/drivers/net/wireless/hostap/hostap_80211_tx.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/hostap/hostap_80211_tx.c	2008-10-25 02:15:59.000000000 +0200
@@ -17,7 +17,6 @@ void hostap_dump_tx_80211(const char *na
 {
 	struct ieee80211_hdr_4addr *hdr;
 	u16 fc;
-	DECLARE_MAC_BUF(mac);
 
 	hdr = (struct ieee80211_hdr_4addr *) skb->data;
 
@@ -41,11 +40,11 @@ void hostap_dump_tx_80211(const char *na
 	printk(" dur=0x%04x seq=0x%04x\n", le16_to_cpu(hdr->duration_id),
 	       le16_to_cpu(hdr->seq_ctl));
 
-	printk(KERN_DEBUG "   A1=%s", print_mac(mac, hdr->addr1));
-	printk(" A2=%s", print_mac(mac, hdr->addr2));
-	printk(" A3=%s", print_mac(mac, hdr->addr3));
+	printk(KERN_DEBUG "   A1=%pM", hdr->addr1);
+	printk(" A2=%pM", hdr->addr2);
+	printk(" A3=%pM", hdr->addr3);
 	if (skb->len >= 30)
-		printk(" A4=%s", print_mac(mac, hdr->addr4));
+		printk(" A4=%pM", hdr->addr4);
 	printk("\n");
 }
 
@@ -328,10 +327,8 @@ static struct sk_buff * hostap_tx_encryp
 		hdr = (struct ieee80211_hdr_4addr *) skb->data;
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "%s: TKIP countermeasures: dropped "
-			       "TX packet to " MAC_FMT "\n",
-			       local->dev->name,
-			       hdr->addr1[0], hdr->addr1[1], hdr->addr1[2],
-			       hdr->addr1[3], hdr->addr1[4], hdr->addr1[5]);
+			       "TX packet to %pM\n",
+			       local->dev->name, hdr->addr1);
 		}
 		kfree_skb(skb);
 		return NULL;
--- test-tree.orig/drivers/net/wireless/hostap/hostap_ap.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/hostap/hostap_ap.c	2008-10-25 02:15:59.000000000 +0200
@@ -94,7 +94,6 @@ static void ap_sta_hash_add(struct ap_da
 static void ap_sta_hash_del(struct ap_data *ap, struct sta_info *sta)
 {
 	struct sta_info *s;
-	DECLARE_MAC_BUF(mac);
 
 	s = ap->sta_hash[STA_HASH(sta->addr)];
 	if (s == NULL) return;
@@ -109,20 +108,18 @@ static void ap_sta_hash_del(struct ap_da
 	if (s->hnext != NULL)
 		s->hnext = s->hnext->hnext;
 	else
-		printk("AP: could not remove STA %s"
-		       " from hash table\n",
-		       print_mac(mac, sta->addr));
+		printk("AP: could not remove STA %pM from hash table\n",
+		       sta->addr);
 }
 
 static void ap_free_sta(struct ap_data *ap, struct sta_info *sta)
 {
-	DECLARE_MAC_BUF(mac);
 	if (sta->ap && sta->local)
 		hostap_event_expired_sta(sta->local->dev, sta);
 
 	if (ap->proc != NULL) {
 		char name[20];
-		sprintf(name, "%s", print_mac(mac, sta->addr));
+		sprintf(name, "%pM", sta->addr);
 		remove_proc_entry(name, ap->proc);
 	}
 
@@ -185,7 +182,6 @@ static void ap_handle_timer(unsigned lon
 	struct ap_data *ap;
 	unsigned long next_time = 0;
 	int was_assoc;
-	DECLARE_MAC_BUF(mac);
 
 	if (sta == NULL || sta->local == NULL || sta->local->ap == NULL) {
 		PDEBUG(DEBUG_AP, "ap_handle_timer() called with NULL data\n");
@@ -242,8 +238,8 @@ static void ap_handle_timer(unsigned lon
 	if (sta->ap) {
 		if (ap->autom_ap_wds) {
 			PDEBUG(DEBUG_AP, "%s: removing automatic WDS "
-			       "connection to AP %s\n",
-			       local->dev->name, print_mac(mac, sta->addr));
+			       "connection to AP %pM\n",
+			       local->dev->name, sta->addr);
 			hostap_wds_link_oper(local, sta->addr, WDS_DEL);
 		}
 	} else if (sta->timeout_next == STA_NULLFUNC) {
@@ -259,11 +255,11 @@ static void ap_handle_timer(unsigned lon
 	} else {
 		int deauth = sta->timeout_next == STA_DEAUTH;
 		__le16 resp;
-		PDEBUG(DEBUG_AP, "%s: sending %s info to STA %s"
+		PDEBUG(DEBUG_AP, "%s: sending %s info to STA %pM"
 		       "(last=%lu, jiffies=%lu)\n",
 		       local->dev->name,
 		       deauth ? "deauthentication" : "disassociation",
-		       print_mac(mac, sta->addr), sta->last_rx, jiffies);
+		       sta->addr, sta->last_rx, jiffies);
 
 		resp = cpu_to_le16(deauth ? WLAN_REASON_PREV_AUTH_NOT_VALID :
 				   WLAN_REASON_DISASSOC_DUE_TO_INACTIVITY);
@@ -275,10 +271,10 @@ static void ap_handle_timer(unsigned lon
 
 	if (sta->timeout_next == STA_DEAUTH) {
 		if (sta->flags & WLAN_STA_PERM) {
-			PDEBUG(DEBUG_AP, "%s: STA %s"
+			PDEBUG(DEBUG_AP, "%s: STA %pM"
 			       " would have been removed, "
 			       "but it has 'perm' flag\n",
-			       local->dev->name, print_mac(mac, sta->addr));
+			       local->dev->name, sta->addr);
 		} else
 			ap_free_sta(ap, sta);
 		return;
@@ -332,7 +328,6 @@ static int ap_control_proc_read(char *pa
 	struct ap_data *ap = (struct ap_data *) data;
 	char *policy_txt;
 	struct mac_entry *entry;
-	DECLARE_MAC_BUF(mac);
 
 	if (off != 0) {
 		*eof = 1;
@@ -363,7 +358,7 @@ static int ap_control_proc_read(char *pa
 			break;
 		}
 
-		p += sprintf(p, "%s\n", print_mac(mac, entry->addr));
+		p += sprintf(p, "%pM\n", entry->addr);
 	}
 	spin_unlock_bh(&ap->mac_restrictions.lock);
 
@@ -520,7 +515,6 @@ static int prism2_ap_proc_read(char *pag
 	struct ap_data *ap = (struct ap_data *) data;
 	struct sta_info *sta;
 	int i;
-	DECLARE_MAC_BUF(mac);
 
 	if (off > PROC_LIMIT) {
 		*eof = 1;
@@ -533,8 +527,8 @@ static int prism2_ap_proc_read(char *pag
 		if (!sta->ap)
 			continue;
 
-		p += sprintf(p, "%s %d %d %d %d '",
-			     print_mac(mac, sta->addr),
+		p += sprintf(p, "%pM %d %d %d %d '",
+			     sta->addr,
 			     sta->u.ap.channel, sta->last_rx_signal,
 			     sta->last_rx_silence, sta->last_rx_rate);
 		for (i = 0; i < sta->u.ap.ssid_len; i++)
@@ -683,11 +677,9 @@ static void hostap_ap_tx_cb_auth(struct 
 	if (sta)
 		atomic_dec(&sta->users);
 	if (txt) {
-		PDEBUG(DEBUG_AP, "%s: " MAC_FMT " auth_cb - alg=%d "
+		PDEBUG(DEBUG_AP, "%s: %pM auth_cb - alg=%d "
 		       "trans#=%d status=%d - %s\n",
-		       dev->name,
-		       hdr->addr1[0], hdr->addr1[1], hdr->addr1[2],
-		       hdr->addr1[3], hdr->addr1[4], hdr->addr1[5],
+		       dev->name, hdr->addr1,
 		       auth_alg, auth_transaction, status, txt);
 	}
 	dev_kfree_skb(skb);
@@ -754,11 +746,8 @@ static void hostap_ap_tx_cb_assoc(struct
 	if (sta)
 		atomic_dec(&sta->users);
 	if (txt) {
-		PDEBUG(DEBUG_AP, "%s: " MAC_FMT " assoc_cb - %s\n",
-		       dev->name,
-		       hdr->addr1[0], hdr->addr1[1], hdr->addr1[2],
-		       hdr->addr1[3], hdr->addr1[4], hdr->addr1[5],
-		       txt);
+		PDEBUG(DEBUG_AP, "%s: %pM assoc_cb - %s\n",
+		       dev->name, hdr->addr1, txt);
 	}
 	dev_kfree_skb(skb);
 }
@@ -781,11 +770,9 @@ static void hostap_ap_tx_cb_poll(struct 
 			sta->flags &= ~WLAN_STA_PENDING_POLL;
 		spin_unlock(&ap->sta_table_lock);
 	} else {
-		PDEBUG(DEBUG_AP, "%s: STA " MAC_FMT
-		       " did not ACK activity poll frame\n",
-		       ap->local->dev->name,
-		       hdr->addr1[0], hdr->addr1[1], hdr->addr1[2],
-		       hdr->addr1[3], hdr->addr1[4], hdr->addr1[5]);
+		PDEBUG(DEBUG_AP,
+		       "%s: STA %pM did not ACK activity poll frame\n",
+		       ap->local->dev->name, hdr->addr1);
 	}
 
  fail:
@@ -1002,7 +989,6 @@ static int prism2_sta_proc_read(char *pa
 	char *p = page;
 	struct sta_info *sta = (struct sta_info *) data;
 	int i;
-	DECLARE_MAC_BUF(mac);
 
 	/* FIX: possible race condition.. the STA data could have just expired,
 	 * but proc entry was still here so that the read could have started;
@@ -1013,11 +999,11 @@ static int prism2_sta_proc_read(char *pa
 		return 0;
 	}
 
-	p += sprintf(p, "%s=%s\nusers=%d\naid=%d\n"
+	p += sprintf(p, "%s=%pM\nusers=%d\naid=%d\n"
 		     "flags=0x%04x%s%s%s%s%s%s%s\n"
 		     "capability=0x%02x\nlisten_interval=%d\nsupported_rates=",
 		     sta->ap ? "AP" : "STA",
-		     print_mac(mac, sta->addr), atomic_read(&sta->users), sta->aid,
+		     sta->addr, atomic_read(&sta->users), sta->aid,
 		     sta->flags,
 		     sta->flags & WLAN_STA_AUTH ? " AUTH" : "",
 		     sta->flags & WLAN_STA_ASSOC ? " ASSOC" : "",
@@ -1078,7 +1064,6 @@ static void handle_add_proc_queue(struct
 	struct sta_info *sta;
 	char name[20];
 	struct add_sta_proc_data *entry, *prev;
-	DECLARE_MAC_BUF(mac);
 
 	entry = ap->add_sta_proc_entries;
 	ap->add_sta_proc_entries = NULL;
@@ -1091,7 +1076,7 @@ static void handle_add_proc_queue(struct
 		spin_unlock_bh(&ap->sta_table_lock);
 
 		if (sta) {
-			sprintf(name, "%s", print_mac(mac, sta->addr));
+			sprintf(name, "%pM", sta->addr);
 			sta->proc = create_proc_read_entry(
 				name, 0, ap->proc,
 				prism2_sta_proc_read, sta);
@@ -1318,9 +1303,7 @@ static void handle_authen(local_info_t *
 
 	if (len < 6) {
 		PDEBUG(DEBUG_AP, "%s: handle_authen - too short payload "
-		       "(len=%d) from " MAC_FMT "\n", dev->name, len,
-		       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
-		       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5]);
+		       "(len=%d) from %pM\n", dev->name, len, hdr->addr2);
 		return;
 	}
 
@@ -1385,10 +1368,8 @@ static void handle_authen(local_info_t *
 		if (time_after(jiffies, sta->u.ap.last_beacon +
 			       (10 * sta->listen_interval * HZ) / 1024)) {
 			PDEBUG(DEBUG_AP, "%s: no beacons received for a while,"
-			       " assuming AP " MAC_FMT " is now STA\n",
-			       dev->name,
-			       sta->addr[0], sta->addr[1], sta->addr[2],
-			       sta->addr[3], sta->addr[4], sta->addr[5]);
+			       " assuming AP %pM is now STA\n",
+			       dev->name, sta->addr);
 			sta->ap = 0;
 			sta->flags = 0;
 			sta->u.sta.challenge = NULL;
@@ -1503,11 +1484,9 @@ static void handle_authen(local_info_t *
 	}
 
 	if (resp) {
-		PDEBUG(DEBUG_AP, "%s: " MAC_FMT " auth (alg=%d "
+		PDEBUG(DEBUG_AP, "%s: %pM auth (alg=%d "
 		       "trans#=%d stat=%d len=%d fc=%04x) ==> %d (%s)\n",
-		       dev->name,
-		       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
-		       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5],
+		       dev->name, hdr->addr2,
 		       auth_alg, auth_transaction, status_code, len,
 		       fc, resp, txt);
 	}
@@ -1533,10 +1512,8 @@ static void handle_assoc(local_info_t *l
 
 	if (len < (reassoc ? 10 : 4)) {
 		PDEBUG(DEBUG_AP, "%s: handle_assoc - too short payload "
-		       "(len=%d, reassoc=%d) from " MAC_FMT "\n",
-		       dev->name, len, reassoc,
-		       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
-		       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5]);
+		       "(len=%d, reassoc=%d) from %pM\n",
+		       dev->name, len, reassoc, hdr->addr2);
 		return;
 	}
 
@@ -1613,12 +1590,9 @@ static void handle_assoc(local_info_t *l
 		}
 
 		if (left > 0) {
-			PDEBUG(DEBUG_AP, "%s: assoc from " MAC_FMT
+			PDEBUG(DEBUG_AP, "%s: assoc from %pM"
 			       " with extra data (%d bytes) [",
-			       dev->name,
-			       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
-			       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5],
-			       left);
+			       dev->name, hdr->addr2, left);
 			while (left > 0) {
 				PDEBUG2(DEBUG_AP, "<%02x>", *u);
 				u++; left--;
@@ -1717,14 +1691,12 @@ static void handle_assoc(local_info_t *l
 	}
 
 #if 0
-	PDEBUG(DEBUG_AP, "%s: " MAC_FMT" %sassoc (len=%d "
-	       "prev_ap=" MAC_FMT") => %d(%d) (%s)\n",
+	PDEBUG(DEBUG_AP, "%s: %pM %sassoc (len=%d "
+	       "prev_ap=%pM) => %d(%d) (%s)\n",
 	       dev->name,
-	       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
-	       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5],
+	       hdr->addr2,
 	       reassoc ? "re" : "", len,
-	       prev_ap[0], prev_ap[1], prev_ap[2],
-	       prev_ap[3], prev_ap[4], prev_ap[5],
+	       prev_ap,
 	       resp, send_deauth, txt);
 #endif
 }
@@ -1741,7 +1713,6 @@ static void handle_deauth(local_info_t *
 	u16 reason_code;
 	__le16 *pos;
 	struct sta_info *sta = NULL;
-	DECLARE_MAC_BUF(mac);
 
 	len = skb->len - IEEE80211_MGMT_HDR_LEN;
 
@@ -1753,10 +1724,8 @@ static void handle_deauth(local_info_t *
 	pos = (__le16 *) body;
 	reason_code = le16_to_cpu(*pos);
 
-	PDEBUG(DEBUG_AP, "%s: deauthentication: " MAC_FMT " len=%d, "
-	       "reason_code=%d\n", dev->name,
-	       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
-	       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5],
+	PDEBUG(DEBUG_AP, "%s: deauthentication: %pM len=%d, "
+	       "reason_code=%d\n", dev->name, hdr->addr2,
 	       len, reason_code);
 
 	spin_lock_bh(&local->ap->sta_table_lock);
@@ -1768,11 +1737,9 @@ static void handle_deauth(local_info_t *
 	}
 	spin_unlock_bh(&local->ap->sta_table_lock);
 	if (sta == NULL) {
-		printk("%s: deauthentication from " MAC_FMT ", "
+		printk("%s: deauthentication from %pM, "
 	       "reason_code=%d, but STA not authenticated\n", dev->name,
-		       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
-		       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5],
-		       reason_code);
+		       hdr->addr2, reason_code);
 	}
 }
 
@@ -1799,10 +1766,8 @@ static void handle_disassoc(local_info_t
 	pos = (__le16 *) body;
 	reason_code = le16_to_cpu(*pos);
 
-	PDEBUG(DEBUG_AP, "%s: disassociation: " MAC_FMT " len=%d, "
-	       "reason_code=%d\n", dev->name,
-	       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
-	       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5],
+	PDEBUG(DEBUG_AP, "%s: disassociation: %pM len=%d, "
+	       "reason_code=%d\n", dev->name, hdr->addr2,
 	       len, reason_code);
 
 	spin_lock_bh(&local->ap->sta_table_lock);
@@ -1814,12 +1779,9 @@ static void handle_disassoc(local_info_t
 	}
 	spin_unlock_bh(&local->ap->sta_table_lock);
 	if (sta == NULL) {
-		printk("%s: disassociation from " MAC_FMT ", "
+		printk("%s: disassociation from %pM, "
 		       "reason_code=%d, but STA not authenticated\n",
-		       dev->name,
-		       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
-		       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5],
-		       reason_code);
+		       dev->name, hdr->addr2, reason_code);
 	}
 }
 
@@ -1909,19 +1871,14 @@ static void handle_pspoll(local_info_t *
 	u16 aid;
 	struct sk_buff *skb;
 
-	PDEBUG(DEBUG_PS2, "handle_pspoll: BSSID=" MAC_FMT
-	       ", TA=" MAC_FMT " PWRMGT=%d\n",
-	       hdr->addr1[0], hdr->addr1[1], hdr->addr1[2],
-	       hdr->addr1[3], hdr->addr1[4], hdr->addr1[5],
-	       hdr->addr2[0], hdr->addr2[1], hdr->addr2[2],
-	       hdr->addr2[3], hdr->addr2[4], hdr->addr2[5],
+	PDEBUG(DEBUG_PS2, "handle_pspoll: BSSID=%pM, TA=%pM PWRMGT=%d\n",
+	       hdr->addr1, hdr->addr2,
 	       !!(le16_to_cpu(hdr->frame_ctl) & IEEE80211_FCTL_PM));
 
 	if (memcmp(hdr->addr1, dev->dev_addr, ETH_ALEN)) {
-		PDEBUG(DEBUG_AP, "handle_pspoll - addr1(BSSID)=" MAC_FMT
-		       " not own MAC\n",
-		       hdr->addr1[0], hdr->addr1[1], hdr->addr1[2],
-		       hdr->addr1[3], hdr->addr1[4], hdr->addr1[5]);
+		PDEBUG(DEBUG_AP,
+		       "handle_pspoll - addr1(BSSID)=%pM not own MAC\n",
+		       hdr->addr1);
 		return;
 	}
 
@@ -2007,11 +1964,10 @@ static void handle_wds_oper_queue(struct
 
 	while (entry) {
 		PDEBUG(DEBUG_AP, "%s: %s automatic WDS connection "
-		       "to AP " MAC_FMT "\n",
+		       "to AP %pM\n",
 		       local->dev->name,
 		       entry->type == WDS_ADD ? "adding" : "removing",
-		       entry->addr[0], entry->addr[1], entry->addr[2],
-		       entry->addr[3], entry->addr[4], entry->addr[5]);
+		       entry->addr);
 		if (entry->type == WDS_ADD)
 			prism2_wds_add(local, entry->addr, 0);
 		else if (entry->type == WDS_DEL)
@@ -2215,10 +2171,8 @@ static void handle_ap_item(local_info_t 
 		}
 
 		if (memcmp(hdr->addr1, dev->dev_addr, ETH_ALEN)) {
-			PDEBUG(DEBUG_AP, "handle_ap_item - addr1(BSSID)="
-			       MAC_FMT " not own MAC\n",
-			       hdr->addr1[0], hdr->addr1[1], hdr->addr1[2],
-			       hdr->addr1[3], hdr->addr1[4], hdr->addr1[5]);
+			PDEBUG(DEBUG_AP, "handle_ap_item - addr1(BSSID)=%pM"
+			       " not own MAC\n", hdr->addr1);
 			goto done;
 		}
 
@@ -2254,18 +2208,14 @@ static void handle_ap_item(local_info_t 
 	}
 
 	if (memcmp(hdr->addr1, dev->dev_addr, ETH_ALEN)) {
-		PDEBUG(DEBUG_AP, "handle_ap_item - addr1(DA)=" MAC_FMT
-		       " not own MAC\n",
-		       hdr->addr1[0], hdr->addr1[1], hdr->addr1[2],
-		       hdr->addr1[3], hdr->addr1[4], hdr->addr1[5]);
+		PDEBUG(DEBUG_AP, "handle_ap_item - addr1(DA)=%pM"
+		       " not own MAC\n", hdr->addr1);
 		goto done;
 	}
 
 	if (memcmp(hdr->addr3, dev->dev_addr, ETH_ALEN)) {
-		PDEBUG(DEBUG_AP, "handle_ap_item - addr3(BSSID)=" MAC_FMT
-		       " not own MAC\n",
-		       hdr->addr3[0], hdr->addr3[1], hdr->addr3[2],
-		       hdr->addr3[3], hdr->addr3[4], hdr->addr3[5]);
+		PDEBUG(DEBUG_AP, "handle_ap_item - addr3(BSSID)=%pM"
+		       " not own MAC\n", hdr->addr3);
 		goto done;
 	}
 
@@ -2366,10 +2316,9 @@ static void schedule_packet_send(local_i
 	memcpy(hdr->addr2, sta->addr, ETH_ALEN);
 	hdr->duration_id = cpu_to_le16(sta->aid | BIT(15) | BIT(14));
 
-	PDEBUG(DEBUG_PS2, "%s: Scheduling buffered packet delivery for STA "
-	       MAC_FMT "\n", local->dev->name,
-	       sta->addr[0], sta->addr[1], sta->addr[2],
-	       sta->addr[3], sta->addr[4], sta->addr[5]);
+	PDEBUG(DEBUG_PS2,
+	       "%s: Scheduling buffered packet delivery for STA %pM\n",
+	       local->dev->name, sta->addr);
 
 	skb->dev = local->dev;
 
@@ -2723,12 +2672,8 @@ static int ap_update_sta_tx_rate(struct 
 			case 3: sta->tx_rate = 110; break;
 			default: sta->tx_rate = 0; break;
 			}
-			PDEBUG(DEBUG_AP, "%s: STA " MAC_FMT
-			       " TX rate raised to %d\n",
-			       dev->name,
-			       sta->addr[0], sta->addr[1], sta->addr[2],
-			       sta->addr[3], sta->addr[4], sta->addr[5],
-			       sta->tx_rate);
+			PDEBUG(DEBUG_AP, "%s: STA %pM TX rate raised to %d\n",
+			       dev->name, sta->addr, sta->tx_rate);
 		}
 		sta->tx_since_last_failure = 0;
 	}
@@ -2781,9 +2726,7 @@ ap_tx_ret hostap_handle_sta_tx(local_inf
 		 * print out any errors here. */
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "AP: drop packet to non-associated "
-			       "STA " MAC_FMT "\n",
-			       hdr->addr1[0], hdr->addr1[1], hdr->addr1[2],
-			       hdr->addr1[3], hdr->addr1[4], hdr->addr1[5]);
+			       "STA %pM\n", hdr->addr1);
 		}
 #endif
 		local->ap->tx_drop_nonassoc++;
@@ -2821,11 +2764,9 @@ ap_tx_ret hostap_handle_sta_tx(local_inf
 	}
 
 	if (skb_queue_len(&sta->tx_buf) >= STA_MAX_TX_BUFFER) {
-		PDEBUG(DEBUG_PS, "%s: No more space in STA (" MAC_FMT
-		       ")'s PS mode buffer\n",
-		       local->dev->name,
-		       sta->addr[0], sta->addr[1], sta->addr[2],
-		       sta->addr[3], sta->addr[4], sta->addr[5]);
+		PDEBUG(DEBUG_PS, "%s: No more space in STA (%pM)'s"
+		       "PS mode buffer\n",
+		       local->dev->name, sta->addr);
 		/* Make sure that TIM is set for the station (it might not be
 		 * after AP wlan hw reset). */
 		/* FIX: should fix hw reset to restore bits based on STA
@@ -2897,12 +2838,9 @@ void hostap_handle_sta_tx_exc(local_info
 	sta = ap_get_sta(local->ap, hdr->addr1);
 	if (!sta) {
 		spin_unlock(&local->ap->sta_table_lock);
-		PDEBUG(DEBUG_AP, "%s: Could not find STA " MAC_FMT
+		PDEBUG(DEBUG_AP, "%s: Could not find STA %pM"
 		       " for this TX error (@%lu)\n",
-		       local->dev->name,
-		       hdr->addr1[0], hdr->addr1[1], hdr->addr1[2],
-		       hdr->addr1[3], hdr->addr1[4], hdr->addr1[5],
-		       jiffies);
+		       local->dev->name, hdr->addr1, jiffies);
 		return;
 	}
 
@@ -2929,12 +2867,9 @@ void hostap_handle_sta_tx_exc(local_info
 			case 3: sta->tx_rate = 110; break;
 			default: sta->tx_rate = 0; break;
 			}
-			PDEBUG(DEBUG_AP, "%s: STA " MAC_FMT
-			       " TX rate lowered to %d\n",
-			       local->dev->name,
-			       sta->addr[0], sta->addr[1], sta->addr[2],
-			       sta->addr[3], sta->addr[4], sta->addr[5],
-			       sta->tx_rate);
+			PDEBUG(DEBUG_AP,
+			       "%s: STA %pM TX rate lowered to %d\n",
+			       local->dev->name, sta->addr, sta->tx_rate);
 		}
 		sta->tx_consecutive_exc = 0;
 	}
@@ -2945,17 +2880,16 @@ void hostap_handle_sta_tx_exc(local_info
 static void hostap_update_sta_ps2(local_info_t *local, struct sta_info *sta,
 				  int pwrmgt, int type, int stype)
 {
-	DECLARE_MAC_BUF(mac);
 	if (pwrmgt && !(sta->flags & WLAN_STA_PS)) {
 		sta->flags |= WLAN_STA_PS;
-		PDEBUG(DEBUG_PS2, "STA %s changed to use PS "
+		PDEBUG(DEBUG_PS2, "STA %pM changed to use PS "
 		       "mode (type=0x%02X, stype=0x%02X)\n",
-		       print_mac(mac, sta->addr), type >> 2, stype >> 4);
+		       sta->addr, type >> 2, stype >> 4);
 	} else if (!pwrmgt && (sta->flags & WLAN_STA_PS)) {
 		sta->flags &= ~WLAN_STA_PS;
-		PDEBUG(DEBUG_PS2, "STA %s changed to not use "
+		PDEBUG(DEBUG_PS2, "STA %pM changed to not use "
 		       "PS mode (type=0x%02X, stype=0x%02X)\n",
-		       print_mac(mac, sta->addr), type >> 2, stype >> 4);
+		       sta->addr, type >> 2, stype >> 4);
 		if (type != IEEE80211_FTYPE_CTL ||
 		    stype != IEEE80211_STYPE_PSPOLL)
 			schedule_packet_send(local, sta);
@@ -3029,13 +2963,9 @@ ap_rx_ret hostap_handle_sta_rx(local_inf
 #ifndef PRISM2_NO_KERNEL_IEEE80211_MGMT
 			} else {
 				printk(KERN_DEBUG "%s: dropped received packet"
-				       " from non-associated STA "
-				       MAC_FMT
+				       " from non-associated STA %pM"
 				       " (type=0x%02x, subtype=0x%02x)\n",
-				       dev->name,
-				       hdr->addr2[0], hdr->addr2[1],
-				       hdr->addr2[2], hdr->addr2[3],
-				       hdr->addr2[4], hdr->addr2[5],
+				       dev->name, hdr->addr2,
 				       type >> 2, stype >> 4);
 				hostap_rx(dev, skb, rx_stats);
 #endif /* PRISM2_NO_KERNEL_IEEE80211_MGMT */
@@ -3068,13 +2998,9 @@ ap_rx_ret hostap_handle_sta_rx(local_inf
 			 * after being unavailable for some time. Speed up
 			 * re-association by informing the station about it not
 			 * being associated. */
-			printk(KERN_DEBUG "%s: rejected received nullfunc "
-			       "frame without ToDS from not associated STA "
-			       MAC_FMT "\n",
-			       dev->name,
-			       hdr->addr2[0], hdr->addr2[1],
-			       hdr->addr2[2], hdr->addr2[3],
-			       hdr->addr2[4], hdr->addr2[5]);
+			printk(KERN_DEBUG "%s: rejected received nullfunc frame"
+			       " without ToDS from not associated STA %pM\n",
+			       dev->name, hdr->addr2);
 			hostap_rx(dev, skb, rx_stats);
 #endif /* PRISM2_NO_KERNEL_IEEE80211_MGMT */
 		}
@@ -3090,13 +3016,10 @@ ap_rx_ret hostap_handle_sta_rx(local_inf
 		 * broadcast frame from an IBSS network. Drop it silently.
 		 * If BSSID is own, report the dropping of this frame. */
 		if (memcmp(hdr->addr3, dev->dev_addr, ETH_ALEN) == 0) {
-			printk(KERN_DEBUG "%s: dropped received packet from "
-			       MAC_FMT " with no ToDS flag "
+			printk(KERN_DEBUG "%s: dropped received packet from %pM"
+			       " with no ToDS flag "
 			       "(type=0x%02x, subtype=0x%02x)\n", dev->name,
-			       hdr->addr2[0], hdr->addr2[1],
-			       hdr->addr2[2], hdr->addr2[3],
-			       hdr->addr2[4], hdr->addr2[5],
-			       type >> 2, stype >> 4);
+			       hdr->addr2, type >> 2, stype >> 4);
 			hostap_dump_rx_80211(dev->name, skb, rx_stats);
 		}
 		ret = AP_RX_DROP;
--- test-tree.orig/drivers/net/wireless/ipw2200.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/ipw2200.c	2008-10-25 02:15:59.000000000 +0200
@@ -2265,8 +2265,8 @@ static int ipw_send_adapter_address(stru
 		return -1;
 	}
 
-	IPW_DEBUG_INFO("%s: Setting MAC to %s\n",
-		       priv->net_dev->name, print_mac(mac, mac));
+	IPW_DEBUG_INFO("%s: Setting MAC to %pM\n",
+		       priv->net_dev->name, mac);
 
 	return ipw_send_cmd_pdu(priv, IPW_CMD_ADAPTER_ADDRESS, ETH_ALEN, mac);
 }
@@ -3812,7 +3812,6 @@ static u8 ipw_add_station(struct ipw_pri
 {
 	struct ipw_station_entry entry;
 	int i;
-	DECLARE_MAC_BUF(mac);
 
 	for (i = 0; i < priv->num_stations; i++) {
 		if (!memcmp(priv->stations[i], bssid, ETH_ALEN)) {
@@ -3829,7 +3828,7 @@ static u8 ipw_add_station(struct ipw_pri
 	if (i == MAX_STATIONS)
 		return IPW_INVALID_STATION;
 
-	IPW_DEBUG_SCAN("Adding AdHoc station: %s\n", print_mac(mac, bssid));
+	IPW_DEBUG_SCAN("Adding AdHoc station: %pM\n", bssid);
 
 	entry.reserved = 0;
 	entry.support_mode = 0;
@@ -3856,7 +3855,6 @@ static u8 ipw_find_station(struct ipw_pr
 static void ipw_send_disassociate(struct ipw_priv *priv, int quiet)
 {
 	int err;
-	DECLARE_MAC_BUF(mac);
 
 	if (priv->status & STATUS_ASSOCIATING) {
 		IPW_DEBUG_ASSOC("Disassociating while associating.\n");
@@ -3869,9 +3867,9 @@ static void ipw_send_disassociate(struct
 		return;
 	}
 
-	IPW_DEBUG_ASSOC("Disassocation attempt from %s "
+	IPW_DEBUG_ASSOC("Disassocation attempt from %pM "
 			"on channel %d.\n",
-			print_mac(mac, priv->assoc_request.bssid),
+			priv->assoc_request.bssid,
 			priv->assoc_request.channel);
 
 	priv->status &= ~(STATUS_ASSOCIATING | STATUS_ASSOCIATED);
@@ -4397,7 +4395,6 @@ static void handle_scan_event(struct ipw
 static void ipw_rx_notification(struct ipw_priv *priv,
 				       struct ipw_rx_notification *notif)
 {
-	DECLARE_MAC_BUF(mac);
 	u16 size = le16_to_cpu(notif->size);
 	notif->size = le16_to_cpu(notif->size);
 
@@ -4411,11 +4408,10 @@ static void ipw_rx_notification(struct i
 			case CMAS_ASSOCIATED:{
 					IPW_DEBUG(IPW_DL_NOTIF | IPW_DL_STATE |
 						  IPW_DL_ASSOC,
-						  "associated: '%s' %s"
-						  " \n",
+						  "associated: '%s' %pM \n",
 						  escape_essid(priv->essid,
 							       priv->essid_len),
-						  print_mac(mac, priv->bssid));
+						  priv->bssid);
 
 					switch (priv->ieee->iw_mode) {
 					case IW_MODE_INFRA:
@@ -4492,13 +4488,13 @@ static void ipw_rx_notification(struct i
 							  IPW_DL_STATE |
 							  IPW_DL_ASSOC,
 							  "deauthenticated: '%s' "
-							  "%s"
+							  "%pM"
 							  ": (0x%04X) - %s \n",
 							  escape_essid(priv->
 								       essid,
 								       priv->
 								       essid_len),
-							  print_mac(mac, priv->bssid),
+							  priv->bssid,
 							  le16_to_cpu(auth->status),
 							  ipw_get_status_code
 							  (le16_to_cpu
@@ -4515,11 +4511,10 @@ static void ipw_rx_notification(struct i
 
 					IPW_DEBUG(IPW_DL_NOTIF | IPW_DL_STATE |
 						  IPW_DL_ASSOC,
-						  "authenticated: '%s' %s"
-						  "\n",
+						  "authenticated: '%s' %pM\n",
 						  escape_essid(priv->essid,
 							       priv->essid_len),
-						  print_mac(mac, priv->bssid));
+						  priv->bssid);
 					break;
 				}
 
@@ -4544,11 +4539,10 @@ static void ipw_rx_notification(struct i
 
 					IPW_DEBUG(IPW_DL_NOTIF | IPW_DL_STATE |
 						  IPW_DL_ASSOC,
-						  "disassociated: '%s' %s"
-						  " \n",
+						  "disassociated: '%s' %pM \n",
 						  escape_essid(priv->essid,
 							       priv->essid_len),
-						  print_mac(mac, priv->bssid));
+						  priv->bssid);
 
 					priv->status &=
 					    ~(STATUS_DISASSOCIATING |
@@ -4583,10 +4577,10 @@ static void ipw_rx_notification(struct i
 			switch (auth->state) {
 			case CMAS_AUTHENTICATED:
 				IPW_DEBUG(IPW_DL_NOTIF | IPW_DL_STATE,
-					  "authenticated: '%s' %s \n",
+					  "authenticated: '%s' %pM \n",
 					  escape_essid(priv->essid,
 						       priv->essid_len),
-					  print_mac(mac, priv->bssid));
+					  priv->bssid);
 				priv->status |= STATUS_AUTH;
 				break;
 
@@ -4602,10 +4596,10 @@ static void ipw_rx_notification(struct i
 				}
 				IPW_DEBUG(IPW_DL_NOTIF | IPW_DL_STATE |
 					  IPW_DL_ASSOC,
-					  "deauthenticated: '%s' %s\n",
+					  "deauthenticated: '%s' %pM\n",
 					  escape_essid(priv->essid,
 						       priv->essid_len),
-					  print_mac(mac, priv->bssid));
+					  priv->bssid);
 
 				priv->status &= ~(STATUS_ASSOCIATING |
 						  STATUS_AUTH |
@@ -5429,27 +5423,25 @@ static int ipw_find_adhoc_network(struct
 				  int roaming)
 {
 	struct ipw_supported_rates rates;
-	DECLARE_MAC_BUF(mac);
-	DECLARE_MAC_BUF(mac2);
 
 	/* Verify that this network's capability is compatible with the
 	 * current mode (AdHoc or Infrastructure) */
 	if ((priv->ieee->iw_mode == IW_MODE_ADHOC &&
 	     !(network->capability & WLAN_CAPABILITY_IBSS))) {
-		IPW_DEBUG_MERGE("Network '%s (%s)' excluded due to "
+		IPW_DEBUG_MERGE("Network '%s (%pM)' excluded due to "
 				"capability mismatch.\n",
 				escape_essid(network->ssid, network->ssid_len),
-				print_mac(mac, network->bssid));
+				network->bssid);
 		return 0;
 	}
 
 	/* If we do not have an ESSID for this AP, we can not associate with
 	 * it */
 	if (network->flags & NETWORK_EMPTY_ESSID) {
-		IPW_DEBUG_MERGE("Network '%s (%s)' excluded "
+		IPW_DEBUG_MERGE("Network '%s (%pM)' excluded "
 				"because of hidden ESSID.\n",
 				escape_essid(network->ssid, network->ssid_len),
-				print_mac(mac, network->bssid));
+				network->bssid);
 		return 0;
 	}
 
@@ -5459,11 +5451,11 @@ static int ipw_find_adhoc_network(struct
 		if ((network->ssid_len != match->network->ssid_len) ||
 		    memcmp(network->ssid, match->network->ssid,
 			   network->ssid_len)) {
-			IPW_DEBUG_MERGE("Network '%s (%s)' excluded "
+			IPW_DEBUG_MERGE("Network '%s (%pM)' excluded "
 					"because of non-network ESSID.\n",
 					escape_essid(network->ssid,
 						     network->ssid_len),
-					print_mac(mac, network->bssid));
+					network->bssid);
 			return 0;
 		}
 	} else {
@@ -5478,9 +5470,9 @@ static int ipw_find_adhoc_network(struct
 			strncpy(escaped,
 				escape_essid(network->ssid, network->ssid_len),
 				sizeof(escaped));
-			IPW_DEBUG_MERGE("Network '%s (%s)' excluded "
+			IPW_DEBUG_MERGE("Network '%s (%pM)' excluded "
 					"because of ESSID mismatch: '%s'.\n",
-					escaped, print_mac(mac, network->bssid),
+					escaped, network->bssid,
 					escape_essid(priv->essid,
 						     priv->essid_len));
 			return 0;
@@ -5507,10 +5499,10 @@ static int ipw_find_adhoc_network(struct
 	/* Now go through and see if the requested network is valid... */
 	if (priv->ieee->scan_age != 0 &&
 	    time_after(jiffies, network->last_scanned + priv->ieee->scan_age)) {
-		IPW_DEBUG_MERGE("Network '%s (%s)' excluded "
+		IPW_DEBUG_MERGE("Network '%s (%pM)' excluded "
 				"because of age: %ums.\n",
 				escape_essid(network->ssid, network->ssid_len),
-				print_mac(mac, network->bssid),
+				network->bssid,
 				jiffies_to_msecs(jiffies -
 						 network->last_scanned));
 		return 0;
@@ -5518,10 +5510,10 @@ static int ipw_find_adhoc_network(struct
 
 	if ((priv->config & CFG_STATIC_CHANNEL) &&
 	    (network->channel != priv->channel)) {
-		IPW_DEBUG_MERGE("Network '%s (%s)' excluded "
+		IPW_DEBUG_MERGE("Network '%s (%pM)' excluded "
 				"because of channel mismatch: %d != %d.\n",
 				escape_essid(network->ssid, network->ssid_len),
-				print_mac(mac, network->bssid),
+				network->bssid,
 				network->channel, priv->channel);
 		return 0;
 	}
@@ -5529,10 +5521,10 @@ static int ipw_find_adhoc_network(struct
 	/* Verify privacy compatability */
 	if (((priv->capability & CAP_PRIVACY_ON) ? 1 : 0) !=
 	    ((network->capability & WLAN_CAPABILITY_PRIVACY) ? 1 : 0)) {
-		IPW_DEBUG_MERGE("Network '%s (%s)' excluded "
+		IPW_DEBUG_MERGE("Network '%s (%pM)' excluded "
 				"because of privacy mismatch: %s != %s.\n",
 				escape_essid(network->ssid, network->ssid_len),
-				print_mac(mac, network->bssid),
+				network->bssid,
 				priv->
 				capability & CAP_PRIVACY_ON ? "on" : "off",
 				network->
@@ -5542,41 +5534,41 @@ static int ipw_find_adhoc_network(struct
 	}
 
 	if (!memcmp(network->bssid, priv->bssid, ETH_ALEN)) {
-		IPW_DEBUG_MERGE("Network '%s (%s)' excluded "
-				"because of the same BSSID match: %s"
+		IPW_DEBUG_MERGE("Network '%s (%pM)' excluded "
+				"because of the same BSSID match: %pM"
 				".\n", escape_essid(network->ssid,
 						    network->ssid_len),
-				print_mac(mac, network->bssid),
-				print_mac(mac2, priv->bssid));
+				network->bssid,
+				priv->bssid);
 		return 0;
 	}
 
 	/* Filter out any incompatible freq / mode combinations */
 	if (!ieee80211_is_valid_mode(priv->ieee, network->mode)) {
-		IPW_DEBUG_MERGE("Network '%s (%s)' excluded "
+		IPW_DEBUG_MERGE("Network '%s (%pM)' excluded "
 				"because of invalid frequency/mode "
 				"combination.\n",
 				escape_essid(network->ssid, network->ssid_len),
-				print_mac(mac, network->bssid));
+				network->bssid);
 		return 0;
 	}
 
 	/* Ensure that the rates supported by the driver are compatible with
 	 * this AP, including verification of basic rates (mandatory) */
 	if (!ipw_compatible_rates(priv, network, &rates)) {
-		IPW_DEBUG_MERGE("Network '%s (%s)' excluded "
+		IPW_DEBUG_MERGE("Network '%s (%pM)' excluded "
 				"because configured rate mask excludes "
 				"AP mandatory rate.\n",
 				escape_essid(network->ssid, network->ssid_len),
-				print_mac(mac, network->bssid));
+				network->bssid);
 		return 0;
 	}
 
 	if (rates.num_rates == 0) {
-		IPW_DEBUG_MERGE("Network '%s (%s)' excluded "
+		IPW_DEBUG_MERGE("Network '%s (%pM)' excluded "
 				"because of no compatible rates.\n",
 				escape_essid(network->ssid, network->ssid_len),
-				print_mac(mac, network->bssid));
+				network->bssid);
 		return 0;
 	}
 
@@ -5587,9 +5579,9 @@ static int ipw_find_adhoc_network(struct
 	/* Set up 'new' AP to this network */
 	ipw_copy_rates(&match->rates, &rates);
 	match->network = network;
-	IPW_DEBUG_MERGE("Network '%s (%s)' is a viable match.\n",
+	IPW_DEBUG_MERGE("Network '%s (%pM)' is a viable match.\n",
 			escape_essid(network->ssid, network->ssid_len),
-			print_mac(mac, network->bssid));
+			network->bssid);
 
 	return 1;
 }
@@ -5643,7 +5635,6 @@ static int ipw_best_network(struct ipw_p
 			    struct ieee80211_network *network, int roaming)
 {
 	struct ipw_supported_rates rates;
-	DECLARE_MAC_BUF(mac);
 
 	/* Verify that this network's capability is compatible with the
 	 * current mode (AdHoc or Infrastructure) */
@@ -5651,20 +5642,20 @@ static int ipw_best_network(struct ipw_p
 	     !(network->capability & WLAN_CAPABILITY_ESS)) ||
 	    (priv->ieee->iw_mode == IW_MODE_ADHOC &&
 	     !(network->capability & WLAN_CAPABILITY_IBSS))) {
-		IPW_DEBUG_ASSOC("Network '%s (%s)' excluded due to "
+		IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded due to "
 				"capability mismatch.\n",
 				escape_essid(network->ssid, network->ssid_len),
-				print_mac(mac, network->bssid));
+				network->bssid);
 		return 0;
 	}
 
 	/* If we do not have an ESSID for this AP, we can not associate with
 	 * it */
 	if (network->flags & NETWORK_EMPTY_ESSID) {
-		IPW_DEBUG_ASSOC("Network '%s (%s)' excluded "
+		IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded "
 				"because of hidden ESSID.\n",
 				escape_essid(network->ssid, network->ssid_len),
-				print_mac(mac, network->bssid));
+				network->bssid);
 		return 0;
 	}
 
@@ -5674,11 +5665,11 @@ static int ipw_best_network(struct ipw_p
 		if ((network->ssid_len != match->network->ssid_len) ||
 		    memcmp(network->ssid, match->network->ssid,
 			   network->ssid_len)) {
-			IPW_DEBUG_ASSOC("Network '%s (%s)' excluded "
+			IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded "
 					"because of non-network ESSID.\n",
 					escape_essid(network->ssid,
 						     network->ssid_len),
-					print_mac(mac, network->bssid));
+					network->bssid);
 			return 0;
 		}
 	} else {
@@ -5692,9 +5683,9 @@ static int ipw_best_network(struct ipw_p
 			strncpy(escaped,
 				escape_essid(network->ssid, network->ssid_len),
 				sizeof(escaped));
-			IPW_DEBUG_ASSOC("Network '%s (%s)' excluded "
+			IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded "
 					"because of ESSID mismatch: '%s'.\n",
-					escaped, print_mac(mac, network->bssid),
+					escaped, network->bssid,
 					escape_essid(priv->essid,
 						     priv->essid_len));
 			return 0;
@@ -5708,12 +5699,12 @@ static int ipw_best_network(struct ipw_p
 		strncpy(escaped,
 			escape_essid(network->ssid, network->ssid_len),
 			sizeof(escaped));
-		IPW_DEBUG_ASSOC("Network '%s (%s)' excluded because "
-				"'%s (%s)' has a stronger signal.\n",
-				escaped, print_mac(mac, network->bssid),
+		IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded because "
+				"'%s (%pM)' has a stronger signal.\n",
+				escaped, network->bssid,
 				escape_essid(match->network->ssid,
 					     match->network->ssid_len),
-				print_mac(mac, match->network->bssid));
+				match->network->bssid);
 		return 0;
 	}
 
@@ -5721,11 +5712,11 @@ static int ipw_best_network(struct ipw_p
 	 * last 3 seconds, do not try and associate again... */
 	if (network->last_associate &&
 	    time_after(network->last_associate + (HZ * 3UL), jiffies)) {
-		IPW_DEBUG_ASSOC("Network '%s (%s)' excluded "
+		IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded "
 				"because of storming (%ums since last "
 				"assoc attempt).\n",
 				escape_essid(network->ssid, network->ssid_len),
-				print_mac(mac, network->bssid),
+				network->bssid,
 				jiffies_to_msecs(jiffies -
 						 network->last_associate));
 		return 0;
@@ -5734,10 +5725,10 @@ static int ipw_best_network(struct ipw_p
 	/* Now go through and see if the requested network is valid... */
 	if (priv->ieee->scan_age != 0 &&
 	    time_after(jiffies, network->last_scanned + priv->ieee->scan_age)) {
-		IPW_DEBUG_ASSOC("Network '%s (%s)' excluded "
+		IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded "
 				"because of age: %ums.\n",
 				escape_essid(network->ssid, network->ssid_len),
-				print_mac(mac, network->bssid),
+				network->bssid,
 				jiffies_to_msecs(jiffies -
 						 network->last_scanned));
 		return 0;
@@ -5745,10 +5736,10 @@ static int ipw_best_network(struct ipw_p
 
 	if ((priv->config & CFG_STATIC_CHANNEL) &&
 	    (network->channel != priv->channel)) {
-		IPW_DEBUG_ASSOC("Network '%s (%s)' excluded "
+		IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded "
 				"because of channel mismatch: %d != %d.\n",
 				escape_essid(network->ssid, network->ssid_len),
-				print_mac(mac, network->bssid),
+				network->bssid,
 				network->channel, priv->channel);
 		return 0;
 	}
@@ -5756,10 +5747,10 @@ static int ipw_best_network(struct ipw_p
 	/* Verify privacy compatability */
 	if (((priv->capability & CAP_PRIVACY_ON) ? 1 : 0) !=
 	    ((network->capability & WLAN_CAPABILITY_PRIVACY) ? 1 : 0)) {
-		IPW_DEBUG_ASSOC("Network '%s (%s)' excluded "
+		IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded "
 				"because of privacy mismatch: %s != %s.\n",
 				escape_essid(network->ssid, network->ssid_len),
-				print_mac(mac, network->bssid),
+				network->bssid,
 				priv->capability & CAP_PRIVACY_ON ? "on" :
 				"off",
 				network->capability &
@@ -5769,48 +5760,48 @@ static int ipw_best_network(struct ipw_p
 
 	if ((priv->config & CFG_STATIC_BSSID) &&
 	    memcmp(network->bssid, priv->bssid, ETH_ALEN)) {
-		IPW_DEBUG_ASSOC("Network '%s (%s)' excluded "
-				"because of BSSID mismatch: %s.\n",
+		IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded "
+				"because of BSSID mismatch: %pM.\n",
 				escape_essid(network->ssid, network->ssid_len),
-				print_mac(mac, network->bssid), print_mac(mac, priv->bssid));
+				network->bssid, priv->bssid);
 		return 0;
 	}
 
 	/* Filter out any incompatible freq / mode combinations */
 	if (!ieee80211_is_valid_mode(priv->ieee, network->mode)) {
-		IPW_DEBUG_ASSOC("Network '%s (%s)' excluded "
+		IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded "
 				"because of invalid frequency/mode "
 				"combination.\n",
 				escape_essid(network->ssid, network->ssid_len),
-				print_mac(mac, network->bssid));
+				network->bssid);
 		return 0;
 	}
 
 	/* Filter out invalid channel in current GEO */
 	if (!ieee80211_is_valid_channel(priv->ieee, network->channel)) {
-		IPW_DEBUG_ASSOC("Network '%s (%s)' excluded "
+		IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded "
 				"because of invalid channel in current GEO\n",
 				escape_essid(network->ssid, network->ssid_len),
-				print_mac(mac, network->bssid));
+				network->bssid);
 		return 0;
 	}
 
 	/* Ensure that the rates supported by the driver are compatible with
 	 * this AP, including verification of basic rates (mandatory) */
 	if (!ipw_compatible_rates(priv, network, &rates)) {
-		IPW_DEBUG_ASSOC("Network '%s (%s)' excluded "
+		IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded "
 				"because configured rate mask excludes "
 				"AP mandatory rate.\n",
 				escape_essid(network->ssid, network->ssid_len),
-				print_mac(mac, network->bssid));
+				network->bssid);
 		return 0;
 	}
 
 	if (rates.num_rates == 0) {
-		IPW_DEBUG_ASSOC("Network '%s (%s)' excluded "
+		IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded "
 				"because of no compatible rates.\n",
 				escape_essid(network->ssid, network->ssid_len),
-				print_mac(mac, network->bssid));
+				network->bssid);
 		return 0;
 	}
 
@@ -5822,9 +5813,9 @@ static int ipw_best_network(struct ipw_p
 	ipw_copy_rates(&match->rates, &rates);
 	match->network = network;
 
-	IPW_DEBUG_ASSOC("Network '%s (%s)' is a viable match.\n",
+	IPW_DEBUG_ASSOC("Network '%s (%pM)' is a viable match.\n",
 			escape_essid(network->ssid, network->ssid_len),
-			print_mac(mac, network->bssid));
+			network->bssid);
 
 	return 1;
 }
@@ -6066,7 +6057,6 @@ static void ipw_bg_adhoc_check(struct wo
 
 static void ipw_debug_config(struct ipw_priv *priv)
 {
-	DECLARE_MAC_BUF(mac);
 	IPW_DEBUG_INFO("Scan completed, no valid APs matched "
 		       "[CFG 0x%08X]\n", priv->config);
 	if (priv->config & CFG_STATIC_CHANNEL)
@@ -6079,8 +6069,7 @@ static void ipw_debug_config(struct ipw_
 	else
 		IPW_DEBUG_INFO("ESSID unlocked.\n");
 	if (priv->config & CFG_STATIC_BSSID)
-		IPW_DEBUG_INFO("BSSID locked to %s\n",
-			       print_mac(mac, priv->bssid));
+		IPW_DEBUG_INFO("BSSID locked to %pM\n", priv->bssid);
 	else
 		IPW_DEBUG_INFO("BSSID unlocked.\n");
 	if (priv->capability & CAP_PRIVACY_ON)
@@ -7295,7 +7284,6 @@ static int ipw_associate_network(struct 
 				 struct ipw_supported_rates *rates, int roaming)
 {
 	int err;
-	DECLARE_MAC_BUF(mac);
 
 	if (priv->config & CFG_FIXED_RATE)
 		ipw_set_fixed_rate(priv, network->mode);
@@ -7463,9 +7451,9 @@ static int ipw_associate_network(struct 
 		return err;
 	}
 
-	IPW_DEBUG(IPW_DL_STATE, "associating: '%s' %s \n",
+	IPW_DEBUG(IPW_DL_STATE, "associating: '%s' %pM \n",
 		  escape_essid(priv->essid, priv->essid_len),
-		  print_mac(mac, priv->bssid));
+		  priv->bssid);
 
 	return 0;
 }
@@ -7604,7 +7592,6 @@ static int ipw_associate(void *data)
 		if (list_empty(&priv->ieee->network_free_list)) {
 			struct ieee80211_network *oldest = NULL;
 			struct ieee80211_network *target;
-			DECLARE_MAC_BUF(mac);
 
 			list_for_each_entry(target, &priv->ieee->network_list, list) {
 				if ((oldest == NULL) ||
@@ -7615,11 +7602,11 @@ static int ipw_associate(void *data)
 			/* If there are no more slots, expire the oldest */
 			list_del(&oldest->list);
 			target = oldest;
-			IPW_DEBUG_ASSOC("Expired '%s' (%s) from "
+			IPW_DEBUG_ASSOC("Expired '%s' (%pM) from "
 					"network list.\n",
 					escape_essid(target->ssid,
 						     target->ssid_len),
-					print_mac(mac, target->bssid));
+					target->bssid);
 			list_add_tail(&target->list,
 				      &priv->ieee->network_free_list);
 		}
@@ -8301,9 +8288,6 @@ static void ipw_rx(struct ipw_priv *priv
 	u32 r, w, i;
 	u8 network_packet;
 	u8 fill_rx = 0;
-	DECLARE_MAC_BUF(mac);
-	DECLARE_MAC_BUF(mac2);
-	DECLARE_MAC_BUF(mac3);
 
 	r = ipw_read32(priv, IPW_RX_READ_INDEX);
 	w = ipw_read32(priv, IPW_RX_WRITE_INDEX);
@@ -8433,18 +8417,12 @@ static void ipw_rx(struct ipw_priv *priv
 									 header)))
 					{
 						IPW_DEBUG_DROP("Dropping: "
-							       "%s, "
-							       "%s, "
-							       "%s\n",
-							       print_mac(mac,
-									 header->
-								       addr1),
-							       print_mac(mac2,
-									 header->
-								       addr2),
-							       print_mac(mac3,
-									 header->
-								       addr3));
+							       "%pM, "
+							       "%pM, "
+							       "%pM\n",
+							       header->addr1,
+							       header->addr2,
+							       header->addr3);
 						break;
 					}
 
@@ -8983,7 +8961,6 @@ static int ipw_wx_set_wap(struct net_dev
 			  union iwreq_data *wrqu, char *extra)
 {
 	struct ipw_priv *priv = ieee80211_priv(dev);
-	DECLARE_MAC_BUF(mac);
 
 	static const unsigned char any[] = {
 		0xff, 0xff, 0xff, 0xff, 0xff, 0xff
@@ -9014,8 +8991,8 @@ static int ipw_wx_set_wap(struct net_dev
 		return 0;
 	}
 
-	IPW_DEBUG_WX("Setting mandatory BSSID to %s\n",
-		     print_mac(mac, wrqu->ap_addr.sa_data));
+	IPW_DEBUG_WX("Setting mandatory BSSID to %pM\n",
+		     wrqu->ap_addr.sa_data);
 
 	memcpy(priv->bssid, wrqu->ap_addr.sa_data, ETH_ALEN);
 
@@ -9033,7 +9010,6 @@ static int ipw_wx_get_wap(struct net_dev
 			  union iwreq_data *wrqu, char *extra)
 {
 	struct ipw_priv *priv = ieee80211_priv(dev);
-	DECLARE_MAC_BUF(mac);
 
 	/* If we are associated, trying to associate, or have a statically
 	 * configured BSSID then return that; otherwise return ANY */
@@ -9045,8 +9021,8 @@ static int ipw_wx_get_wap(struct net_dev
 	} else
 		memset(wrqu->ap_addr.sa_data, 0, ETH_ALEN);
 
-	IPW_DEBUG_WX("Getting WAP BSSID: %s\n",
-		     print_mac(mac, wrqu->ap_addr.sa_data));
+	IPW_DEBUG_WX("Getting WAP BSSID: %pM\n",
+		     wrqu->ap_addr.sa_data);
 	mutex_unlock(&priv->mutex);
 	return 0;
 }
@@ -10199,10 +10175,8 @@ static int ipw_tx_skb(struct ipw_priv *p
 			id = ipw_add_station(priv, hdr->addr1);
 			if (id == IPW_INVALID_STATION) {
 				IPW_WARNING("Attempt to send data to "
-					    "invalid cell: " MAC_FMT "\n",
-					    hdr->addr1[0], hdr->addr1[1],
-					    hdr->addr1[2], hdr->addr1[3],
-					    hdr->addr1[4], hdr->addr1[5]);
+					    "invalid cell: %pM\n",
+					    hdr->addr1);
 				goto drop;
 			}
 		}
@@ -10505,15 +10479,14 @@ static int ipw_net_set_mac_address(struc
 {
 	struct ipw_priv *priv = ieee80211_priv(dev);
 	struct sockaddr *addr = p;
-	DECLARE_MAC_BUF(mac);
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 	mutex_lock(&priv->mutex);
 	priv->config |= CFG_CUSTOM_MAC;
 	memcpy(priv->mac_addr, addr->sa_data, ETH_ALEN);
-	printk(KERN_INFO "%s: Setting MAC to %s\n",
-	       priv->net_dev->name, print_mac(mac, priv->mac_addr));
+	printk(KERN_INFO "%s: Setting MAC to %pM\n",
+	       priv->net_dev->name, priv->mac_addr);
 	queue_work(priv->workqueue, &priv->adapter_restart);
 	mutex_unlock(&priv->mutex);
 	return 0;
--- test-tree.orig/net/atm/lec.c	2008-10-25 02:14:57.000000000 +0200
+++ test-tree/net/atm/lec.c	2008-10-25 02:15:59.000000000 +0200
@@ -373,19 +373,13 @@ static int lec_start_xmit(struct sk_buff
 		if (entry && (entry->tx_wait.qlen < LEC_UNRES_QUE_LEN)) {
 			pr_debug("%s:lec_start_xmit: queuing packet, ",
 				dev->name);
-			pr_debug("MAC address " MAC_FMT "\n",
-				 lec_h->h_dest[0], lec_h->h_dest[1],
-				 lec_h->h_dest[2], lec_h->h_dest[3],
-				 lec_h->h_dest[4], lec_h->h_dest[5]);
+			pr_debug("MAC address %pM\n", lec_h->h_dest);
 			skb_queue_tail(&entry->tx_wait, skb);
 		} else {
 			pr_debug
 			    ("%s:lec_start_xmit: tx queue full or no arp entry, dropping, ",
 			     dev->name);
-			pr_debug("MAC address " MAC_FMT "\n",
-				 lec_h->h_dest[0], lec_h->h_dest[1],
-				 lec_h->h_dest[2], lec_h->h_dest[3],
-				 lec_h->h_dest[4], lec_h->h_dest[5]);
+			pr_debug("MAC address %pM\n", lec_h->h_dest);
 			priv->stats.tx_dropped++;
 			dev_kfree_skb(skb);
 		}
@@ -397,10 +391,7 @@ static int lec_start_xmit(struct sk_buff
 
 	while (entry && (skb2 = skb_dequeue(&entry->tx_wait))) {
 		pr_debug("lec.c: emptying tx queue, ");
-		pr_debug("MAC address " MAC_FMT "\n",
-			 lec_h->h_dest[0], lec_h->h_dest[1],
-			 lec_h->h_dest[2], lec_h->h_dest[3],
-			 lec_h->h_dest[4], lec_h->h_dest[5]);
+		pr_debug("MAC address %pM\n", lec_h->h_dest);
 		lec_send(vcc, skb2, priv);
 	}
 
@@ -539,15 +530,8 @@ static int lec_atm_send(struct atm_vcc *
 		{
 			struct net_bridge_fdb_entry *f;
 
-			pr_debug
-			    ("%s: bridge zeppelin asks about " MAC_FMT "\n",
-			     dev->name,
-			     mesg->content.proxy.mac_addr[0],
-			     mesg->content.proxy.mac_addr[1],
-			     mesg->content.proxy.mac_addr[2],
-			     mesg->content.proxy.mac_addr[3],
-			     mesg->content.proxy.mac_addr[4],
-			     mesg->content.proxy.mac_addr[5]);
+			pr_debug("%s: bridge zeppelin asks about %pM\n",
+				 dev->name, mesg->content.proxy.mac_addr);
 
 			if (br_fdb_get_hook == NULL || dev->br_port == NULL)
 				break;
--- test-tree.orig/net/ieee80211/ieee80211_rx.c	2008-10-25 02:14:57.000000000 +0200
+++ test-tree/net/ieee80211/ieee80211_rx.c	2008-10-25 02:15:59.000000000 +0200
@@ -282,12 +282,8 @@ ieee80211_rx_frame_decrypt(struct ieee80
 	res = crypt->ops->decrypt_mpdu(skb, hdrlen, crypt->priv);
 	atomic_dec(&crypt->refcnt);
 	if (res < 0) {
-		IEEE80211_DEBUG_DROP("decryption failed (SA=" MAC_FMT
-				     ") res=%d\n",
-				     hdr->addr2[0], hdr->addr2[1],
-				     hdr->addr2[2], hdr->addr2[3],
-				     hdr->addr2[4], hdr->addr2[5],
-				     res);
+		IEEE80211_DEBUG_DROP("decryption failed (SA=%pM) res=%d\n",
+				     hdr->addr2, res);
 		if (res == -2)
 			IEEE80211_DEBUG_DROP("Decryption failed ICV "
 					     "mismatch (key %d)\n",
@@ -319,11 +315,7 @@ ieee80211_rx_frame_decrypt_msdu(struct i
 	atomic_dec(&crypt->refcnt);
 	if (res < 0) {
 		printk(KERN_DEBUG "%s: MSDU decryption/MIC verification failed"
-		       " (SA=" MAC_FMT " keyidx=%d)\n",
-		       ieee->dev->name,
-		       hdr->addr2[0], hdr->addr2[1],
-		       hdr->addr2[2], hdr->addr2[3],
-		       hdr->addr2[4], hdr->addr2[5],
+		       " (SA=%pM keyidx=%d)\n", ieee->dev->name, hdr->addr2,
 		       keyidx);
 		return -1;
 	}
@@ -358,7 +350,6 @@ int ieee80211_rx(struct ieee80211_device
 	struct ieee80211_crypt_data *crypt = NULL;
 	int keyidx = 0;
 	int can_be_decrypted = 0;
-	DECLARE_MAC_BUF(mac);
 
 	hdr = (struct ieee80211_hdr_4addr *)skb->data;
 	stats = &ieee->stats;
@@ -468,10 +459,7 @@ int ieee80211_rx(struct ieee80211_device
 			 * frames silently instead of filling system log with
 			 * these reports. */
 			IEEE80211_DEBUG_DROP("Decryption failed (not set)"
-					     " (SA=" MAC_FMT ")\n",
-					     hdr->addr2[0], hdr->addr2[1],
-					     hdr->addr2[2], hdr->addr2[3],
-					     hdr->addr2[4], hdr->addr2[5]);
+					     " (SA=%pM)\n", hdr->addr2);
 			ieee->ieee_stats.rx_discards_undecryptable++;
 			goto rx_dropped;
 		}
@@ -482,10 +470,7 @@ int ieee80211_rx(struct ieee80211_device
 		    fc & IEEE80211_FCTL_PROTECTED && ieee->host_decrypt &&
 		    (keyidx = hostap_rx_frame_decrypt(ieee, skb, crypt)) < 0) {
 			printk(KERN_DEBUG "%s: failed to decrypt mgmt::auth "
-			       "from " MAC_FMT "\n", dev->name,
-			       hdr->addr2[0], hdr->addr2[1],
-			       hdr->addr2[2], hdr->addr2[3],
-			       hdr->addr2[4], hdr->addr2[5]);
+			       "from %pM\n", dev->name, hdr->addr2);
 			/* TODO: could inform hostapd about this so that it
 			 * could send auth failure report */
 			goto rx_dropped;
@@ -663,11 +648,8 @@ int ieee80211_rx(struct ieee80211_device
 			 * configured */
 		} else {
 			IEEE80211_DEBUG_DROP("encryption configured, but RX "
-					     "frame not encrypted (SA="
-					     MAC_FMT ")\n",
-					     hdr->addr2[0], hdr->addr2[1],
-					     hdr->addr2[2], hdr->addr2[3],
-					     hdr->addr2[4], hdr->addr2[5]);
+					     "frame not encrypted (SA=%pM)\n",
+					     hdr->addr2);
 			goto rx_dropped;
 		}
 	}
@@ -675,11 +657,8 @@ int ieee80211_rx(struct ieee80211_device
 	if (crypt && !(fc & IEEE80211_FCTL_PROTECTED) && !ieee->open_wep &&
 	    !ieee80211_is_eapol_frame(ieee, skb)) {
 		IEEE80211_DEBUG_DROP("dropped unencrypted RX data "
-				     "frame from " MAC_FMT
-				     " (drop_unencrypted=1)\n",
-				     hdr->addr2[0], hdr->addr2[1],
-				     hdr->addr2[2], hdr->addr2[3],
-				     hdr->addr2[4], hdr->addr2[5]);
+				     "frame from %pM (drop_unencrypted=1)\n",
+				     hdr->addr2);
 		goto rx_dropped;
 	}
 
@@ -1429,8 +1408,6 @@ static int ieee80211_network_init(struct
 					 struct ieee80211_network *network,
 					 struct ieee80211_rx_stats *stats)
 {
-	DECLARE_MAC_BUF(mac);
-
 	network->qos_data.active = 0;
 	network->qos_data.supported = 0;
 	network->qos_data.param_count = 0;
@@ -1477,11 +1454,11 @@ static int ieee80211_network_init(struct
 	}
 
 	if (network->mode == 0) {
-		IEEE80211_DEBUG_SCAN("Filtered out '%s (%s)' "
+		IEEE80211_DEBUG_SCAN("Filtered out '%s (%pM)' "
 				     "network.\n",
 				     escape_essid(network->ssid,
 						  network->ssid_len),
-				     print_mac(mac, network->bssid));
+				     network->bssid);
 		return 1;
 	}
 
@@ -1510,7 +1487,6 @@ static void update_network(struct ieee80
 {
 	int qos_active;
 	u8 old_param;
-	DECLARE_MAC_BUF(mac);
 
 	ieee80211_network_reset(dst);
 	dst->ibss_dfs = src->ibss_dfs;
@@ -1524,8 +1500,8 @@ static void update_network(struct ieee80
 		memcpy(&dst->stats, &src->stats,
 		       sizeof(struct ieee80211_rx_stats));
 	else
-		IEEE80211_DEBUG_SCAN("Network %s info received "
-			"off channel (%d vs. %d)\n", print_mac(mac, src->bssid),
+		IEEE80211_DEBUG_SCAN("Network %pM info received "
+			"off channel (%d vs. %d)\n", src->bssid,
 			dst->channel, src->stats.received_channel);
 
 	dst->capability = src->capability;
@@ -1597,12 +1573,11 @@ static void ieee80211_process_probe_resp
 	struct ieee80211_info_element *info_element = beacon->info_element;
 #endif
 	unsigned long flags;
-	DECLARE_MAC_BUF(mac);
 
-	IEEE80211_DEBUG_SCAN("'%s' (%s"
+	IEEE80211_DEBUG_SCAN("'%s' (%pM"
 		     "): %c%c%c%c %c%c%c%c-%c%c%c%c %c%c%c%c\n",
 		     escape_essid(info_element->data, info_element->len),
-		     print_mac(mac, beacon->header.addr3),
+		     beacon->header.addr3,
 		     (beacon->capability & cpu_to_le16(1 << 0xf)) ? '1' : '0',
 		     (beacon->capability & cpu_to_le16(1 << 0xe)) ? '1' : '0',
 		     (beacon->capability & cpu_to_le16(1 << 0xd)) ? '1' : '0',
@@ -1621,10 +1596,10 @@ static void ieee80211_process_probe_resp
 		     (beacon->capability & cpu_to_le16(1 << 0x0)) ? '1' : '0');
 
 	if (ieee80211_network_init(ieee, beacon, &network, stats)) {
-		IEEE80211_DEBUG_SCAN("Dropped '%s' (%s) via %s.\n",
+		IEEE80211_DEBUG_SCAN("Dropped '%s' (%pM) via %s.\n",
 				     escape_essid(info_element->data,
 						  info_element->len),
-				     print_mac(mac, beacon->header.addr3),
+				     beacon->header.addr3,
 				     is_beacon(beacon->header.frame_ctl) ?
 				     "BEACON" : "PROBE RESPONSE");
 		return;
@@ -1658,11 +1633,11 @@ static void ieee80211_process_probe_resp
 			/* If there are no more slots, expire the oldest */
 			list_del(&oldest->list);
 			target = oldest;
-			IEEE80211_DEBUG_SCAN("Expired '%s' (%s) from "
+			IEEE80211_DEBUG_SCAN("Expired '%s' (%pM) from "
 					     "network list.\n",
 					     escape_essid(target->ssid,
 							  target->ssid_len),
-					     print_mac(mac, target->bssid));
+					     target->bssid);
 			ieee80211_network_reset(target);
 		} else {
 			/* Otherwise just pull from the free list */
@@ -1672,10 +1647,10 @@ static void ieee80211_process_probe_resp
 		}
 
 #ifdef CONFIG_IEEE80211_DEBUG
-		IEEE80211_DEBUG_SCAN("Adding '%s' (%s) via %s.\n",
+		IEEE80211_DEBUG_SCAN("Adding '%s' (%pM) via %s.\n",
 				     escape_essid(network.ssid,
 						  network.ssid_len),
-				     print_mac(mac, network.bssid),
+				     network.bssid,
 				     is_beacon(beacon->header.frame_ctl) ?
 				     "BEACON" : "PROBE RESPONSE");
 #endif
@@ -1683,10 +1658,10 @@ static void ieee80211_process_probe_resp
 		network.ibss_dfs = NULL;
 		list_add_tail(&target->list, &ieee->network_list);
 	} else {
-		IEEE80211_DEBUG_SCAN("Updating '%s' (%s) via %s.\n",
+		IEEE80211_DEBUG_SCAN("Updating '%s' (%pM) via %s.\n",
 				     escape_essid(target->ssid,
 						  target->ssid_len),
-				     print_mac(mac, target->bssid),
+				     target->bssid,
 				     is_beacon(beacon->header.frame_ctl) ?
 				     "BEACON" : "PROBE RESPONSE");
 		update_network(target, &network);
--- test-tree.orig/arch/arm/mach-ixp4xx/fsg-setup.c	2008-10-25 02:14:56.000000000 +0200
+++ test-tree/arch/arm/mach-ixp4xx/fsg-setup.c	2008-10-25 02:15:59.000000000 +0200
@@ -177,7 +177,6 @@ static irqreturn_t fsg_reset_handler(int
 
 static void __init fsg_init(void)
 {
-	DECLARE_MAC_BUF(mac_buf);
 	uint8_t __iomem *f;
 
 	ixp4xx_sys_init();
@@ -256,10 +255,10 @@ static void __init fsg_init(void)
 #endif
 		iounmap(f);
 	}
-	printk(KERN_INFO "FSG: Using MAC address %s for port 0\n",
-	       print_mac(mac_buf, fsg_plat_eth[0].hwaddr));
-	printk(KERN_INFO "FSG: Using MAC address %s for port 1\n",
-	       print_mac(mac_buf, fsg_plat_eth[1].hwaddr));
+	printk(KERN_INFO "FSG: Using MAC address %pM for port 0\n",
+	       fsg_plat_eth[0].hwaddr);
+	printk(KERN_INFO "FSG: Using MAC address %pM for port 1\n",
+	       fsg_plat_eth[1].hwaddr);
 
 }
 
--- test-tree.orig/arch/arm/mach-ixp4xx/nas100d-setup.c	2008-10-25 02:14:56.000000000 +0200
+++ test-tree/arch/arm/mach-ixp4xx/nas100d-setup.c	2008-10-25 02:15:59.000000000 +0200
@@ -231,7 +231,6 @@ static irqreturn_t nas100d_reset_handler
 
 static void __init nas100d_init(void)
 {
-	DECLARE_MAC_BUF(mac_buf);
 	uint8_t __iomem *f;
 	int i;
 
@@ -294,8 +293,8 @@ static void __init nas100d_init(void)
 #endif
 		iounmap(f);
 	}
-	printk(KERN_INFO "NAS100D: Using MAC address %s for port 0\n",
-	       print_mac(mac_buf, nas100d_plat_eth[0].hwaddr));
+	printk(KERN_INFO "NAS100D: Using MAC address %pM for port 0\n",
+	       nas100d_plat_eth[0].hwaddr);
 
 }
 
--- test-tree.orig/arch/arm/mach-ixp4xx/nslu2-setup.c	2008-10-25 02:14:56.000000000 +0200
+++ test-tree/arch/arm/mach-ixp4xx/nslu2-setup.c	2008-10-25 02:15:59.000000000 +0200
@@ -220,7 +220,6 @@ static struct sys_timer nslu2_timer = {
 
 static void __init nslu2_init(void)
 {
-	DECLARE_MAC_BUF(mac_buf);
 	uint8_t __iomem *f;
 	int i;
 
@@ -275,8 +274,8 @@ static void __init nslu2_init(void)
 #endif
 		iounmap(f);
 	}
-	printk(KERN_INFO "NSLU2: Using MAC address %s for port 0\n",
-	       print_mac(mac_buf, nslu2_plat_eth[0].hwaddr));
+	printk(KERN_INFO "NSLU2: Using MAC address %pM for port 0\n",
+	       nslu2_plat_eth[0].hwaddr);
 
 }
 
--- test-tree.orig/drivers/infiniband/hw/nes/nes.c	2008-10-25 02:14:57.000000000 +0200
+++ test-tree/drivers/infiniband/hw/nes/nes.c	2008-10-25 02:15:59.000000000 +0200
@@ -356,10 +356,8 @@ struct ib_qp *nes_get_qp(struct ib_devic
  */
 static void nes_print_macaddr(struct net_device *netdev)
 {
-	DECLARE_MAC_BUF(mac);
-
-	nes_debug(NES_DBG_INIT, "%s: %s, IRQ %u\n",
-		  netdev->name, print_mac(mac, netdev->dev_addr), netdev->irq);
+	nes_debug(NES_DBG_INIT, "%s: %pM, IRQ %u\n",
+		  netdev->name, netdev->dev_addr, netdev->irq);
 }
 
 /**
--- test-tree.orig/drivers/infiniband/hw/nes/nes_cm.c	2008-10-25 02:14:57.000000000 +0200
+++ test-tree/drivers/infiniband/hw/nes/nes_cm.c	2008-10-25 02:15:59.000000000 +0200
@@ -1027,7 +1027,6 @@ static int nes_addr_resolve_neigh(struct
 	struct flowi fl;
 	struct neighbour *neigh;
 	int rc = -1;
-	DECLARE_MAC_BUF(mac);
 
 	memset(&fl, 0, sizeof fl);
 	fl.nl_u.ip4_u.daddr = htonl(dst_ip);
@@ -1041,8 +1040,8 @@ static int nes_addr_resolve_neigh(struct
 	if (neigh) {
 		if (neigh->nud_state & NUD_VALID) {
 			nes_debug(NES_DBG_CM, "Neighbor MAC address for 0x%08X"
-				  " is %s, Gateway is 0x%08X \n", dst_ip,
-				  print_mac(mac, neigh->ha), ntohl(rt->rt_gateway));
+				  " is %pM, Gateway is 0x%08X \n", dst_ip,
+				  neigh->ha, ntohl(rt->rt_gateway));
 			nes_manage_arp_cache(nesvnic->netdev, neigh->ha,
 					     dst_ip, NES_ARP_ADD);
 			rc = nes_arp_table(nesvnic->nesdev, dst_ip, NULL,
@@ -1071,7 +1070,6 @@ static struct nes_cm_node *make_cm_node(
 	int arpindex = 0;
 	struct nes_device *nesdev;
 	struct nes_adapter *nesadapter;
-	DECLARE_MAC_BUF(mac);
 
 	/* create an hte and cm_node for this instance */
 	cm_node = kzalloc(sizeof(*cm_node), GFP_ATOMIC);
@@ -1137,8 +1135,8 @@ static struct nes_cm_node *make_cm_node(
 
 	/* copy the mac addr to node context */
 	memcpy(cm_node->rem_mac, nesadapter->arp_table[arpindex].mac_addr, ETH_ALEN);
-	nes_debug(NES_DBG_CM, "Remote mac addr from arp table: %s\n",
-		  print_mac(mac, cm_node->rem_mac));
+	nes_debug(NES_DBG_CM, "Remote mac addr from arp table: %pM\n",
+		  cm_node->rem_mac);
 
 	add_hte_node(cm_core, cm_node);
 	atomic_inc(&cm_nodes_created);
--- test-tree.orig/drivers/infiniband/hw/nes/nes_nic.c	2008-10-25 02:14:57.000000000 +0200
+++ test-tree/drivers/infiniband/hw/nes/nes_nic.c	2008-10-25 02:15:59.000000000 +0200
@@ -797,14 +797,13 @@ static int nes_netdev_set_mac_address(st
 	int i;
 	u32 macaddr_low;
 	u16 macaddr_high;
-	DECLARE_MAC_BUF(mac);
 
 	if (!is_valid_ether_addr(mac_addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memcpy(netdev->dev_addr, mac_addr->sa_data, netdev->addr_len);
-	printk(PFX "%s: Address length = %d, Address = %s\n",
-	       __func__, netdev->addr_len, print_mac(mac, mac_addr->sa_data));
+	printk(PFX "%s: Address length = %d, Address = %pM\n",
+	       __func__, netdev->addr_len, mac_addr->sa_data);
 	macaddr_high  = ((u16)netdev->dev_addr[0]) << 8;
 	macaddr_high += (u16)netdev->dev_addr[1];
 	macaddr_low   = ((u32)netdev->dev_addr[2]) << 24;
@@ -909,9 +908,8 @@ static void nes_netdev_set_multicast_lis
 			if (mc_index >= max_pft_entries_avaiable)
 				break;
 			if (multicast_addr) {
-				DECLARE_MAC_BUF(mac);
-				nes_debug(NES_DBG_NIC_RX, "Assigning MC Address %s to register 0x%04X nic_idx=%d\n",
-					  print_mac(mac, multicast_addr->dmi_addr),
+				nes_debug(NES_DBG_NIC_RX, "Assigning MC Address %pM to register 0x%04X nic_idx=%d\n",
+					  multicast_addr->dmi_addr,
 					  perfect_filter_register_address+(mc_index * 8),
 					  mc_nic_index);
 				macaddr_high  = ((u16)multicast_addr->dmi_addr[0]) << 8;
--- test-tree.orig/drivers/net/3c503.c	2008-10-25 02:15:00.000000000 +0200
+++ test-tree/drivers/net/3c503.c	2008-10-25 02:15:59.000000000 +0200
@@ -177,7 +177,6 @@ el2_probe1(struct net_device *dev, int i
     int i, iobase_reg, membase_reg, saved_406, wordlength, retval;
     static unsigned version_printed;
     unsigned long vendor_id;
-    DECLARE_MAC_BUF(mac);
 
     if (!request_region(ioaddr, EL2_IO_EXTENT, DRV_NAME))
 	return -EBUSY;
@@ -228,7 +227,7 @@ el2_probe1(struct net_device *dev, int i
     /* Retrieve and print the ethernet address. */
     for (i = 0; i < 6; i++)
 	dev->dev_addr[i] = inb(ioaddr + i);
-    printk("%s", print_mac(mac, dev->dev_addr));
+    printk("%pM", dev->dev_addr);
 
     /* Map the 8390 back into the window. */
     outb(ECNTRL_THIN, ioaddr + 0x406);
--- test-tree.orig/drivers/net/3c505.c	2008-10-25 02:15:01.000000000 +0200
+++ test-tree/drivers/net/3c505.c	2008-10-25 02:15:59.000000000 +0200
@@ -1385,7 +1385,6 @@ static int __init elplus_setup(struct ne
 	unsigned long timeout;
 	unsigned long cookie = 0;
 	int err = -ENODEV;
-	DECLARE_MAC_BUF(mac);
 
 	/*
 	 *  setup adapter structure
@@ -1522,9 +1521,9 @@ static int __init elplus_setup(struct ne
 	 * print remainder of startup message
 	 */
 	printk(KERN_INFO "%s: 3c505 at %#lx, irq %d, dma %d, "
-	       "addr %s, ",
+	       "addr %pM, ",
 	       dev->name, dev->base_addr, dev->irq, dev->dma,
-	       print_mac(mac, dev->dev_addr));
+	       dev->dev_addr);
 
 	/*
 	 * read more information from the adapter
--- test-tree.orig/drivers/net/3c507.c	2008-10-25 02:15:01.000000000 +0200
+++ test-tree/drivers/net/3c507.c	2008-10-25 02:15:59.000000000 +0200
@@ -357,7 +357,6 @@ static int __init el16_probe1(struct net
 	static unsigned char init_ID_done, version_printed;
 	int i, irq, irqval, retval;
 	struct net_local *lp;
-	DECLARE_MAC_BUF(mac);
 
 	if (init_ID_done == 0) {
 		ushort lrs_state = 0xff;
@@ -405,7 +404,7 @@ static int __init el16_probe1(struct net
 	outb(0x01, ioaddr + MISC_CTRL);
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = inb(ioaddr + i);
-	printk(" %s", print_mac(mac, dev->dev_addr));
+	printk(" %pM", dev->dev_addr);
 
 	if (mem_start)
 		net_debug = mem_start & 7;
--- test-tree.orig/drivers/net/3c509.c	2008-10-25 02:15:05.000000000 +0200
+++ test-tree/drivers/net/3c509.c	2008-10-25 02:15:59.000000000 +0200
@@ -541,7 +541,6 @@ static int __init el3_common_init(struct
 {
 	struct el3_private *lp = netdev_priv(dev);
 	int err;
-	DECLARE_MAC_BUF(mac);
 	const char *if_names[] = {"10baseT", "AUI", "undefined", "BNC"};
 
 	spin_lock_init(&lp->lock);
@@ -575,9 +574,9 @@ static int __init el3_common_init(struct
 	}
 
 	printk(KERN_INFO "%s: 3c5x9 found at %#3.3lx, %s port, "
-	       "address %s, IRQ %d.\n",
+	       "address %pM, IRQ %d.\n",
 	       dev->name, dev->base_addr, if_names[(dev->if_port & 0x03)],
-	       print_mac(mac, dev->dev_addr), dev->irq);
+	       dev->dev_addr, dev->irq);
 
 	if (el3_debug > 0)
 		printk(KERN_INFO "%s", version);
--- test-tree.orig/drivers/net/3c515.c	2008-10-25 02:15:00.000000000 +0200
+++ test-tree/drivers/net/3c515.c	2008-10-25 02:15:59.000000000 +0200
@@ -570,7 +570,6 @@ static int corkscrew_setup(struct net_de
 	unsigned int eeprom[0x40], checksum = 0;	/* EEPROM contents */
 	int i;
 	int irq;
-	DECLARE_MAC_BUF(mac);
 
 #ifdef __ISAPNP__
 	if (idev) {
@@ -636,7 +635,7 @@ static int corkscrew_setup(struct net_de
 	checksum = (checksum ^ (checksum >> 8)) & 0xff;
 	if (checksum != 0x00)
 		printk(" ***INVALID CHECKSUM %4.4x*** ", checksum);
-	printk(" %s", print_mac(mac, dev->dev_addr));
+	printk(" %pM", dev->dev_addr);
 	if (eeprom[16] == 0x11c7) {	/* Corkscrew */
 		if (request_dma(dev->dma, "3c515")) {
 			printk(", DMA %d allocation failed", dev->dma);
--- test-tree.orig/drivers/net/3c523.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/3c523.c	2008-10-25 02:15:59.000000000 +0200
@@ -383,7 +383,6 @@ static int elmc_getinfo(char *buf, int s
 {
 	int len = 0;
 	struct net_device *dev = d;
-	DECLARE_MAC_BUF(mac);
 
 	if (dev == NULL)
 		return len;
@@ -398,8 +397,8 @@ static int elmc_getinfo(char *buf, int s
 	len += sprintf(buf + len, "Transceiver: %s\n", dev->if_port ?
 		       "External" : "Internal");
 	len += sprintf(buf + len, "Device: %s\n", dev->name);
-	len += sprintf(buf + len, "Hardware Address: %s\n",
-		       print_mac(mac, dev->dev_addr));
+	len += sprintf(buf + len, "Hardware Address: %pM\n",
+		       dev->dev_addr);
 
 	return len;
 }				/* elmc_getinfo() */
@@ -417,7 +416,6 @@ static int __init do_elmc_probe(struct n
 	unsigned int size = 0;
 	int retval;
 	struct priv *pr = dev->priv;
-	DECLARE_MAC_BUF(mac);
 
 	if (MCA_bus == 0) {
 		return -ENODEV;
@@ -543,8 +541,8 @@ static int __init do_elmc_probe(struct n
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = inb(dev->base_addr + i);
 
-	printk(KERN_INFO "%s: hardware address %s\n",
-	       dev->name, print_mac(mac, dev->dev_addr));
+	printk(KERN_INFO "%s: hardware address %pM\n",
+	       dev->name, dev->dev_addr);
 
 	dev->open = &elmc_open;
 	dev->stop = &elmc_close;
--- test-tree.orig/drivers/net/3c527.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/3c527.c	2008-10-25 02:15:59.000000000 +0200
@@ -335,7 +335,6 @@ static int __init mc32_probe1(struct net
 		"82586 initialisation failure",
 		"Adapter list configuration error"
 	};
-	DECLARE_MAC_BUF(mac);
 
 	/* Time to play MCA games */
 
@@ -405,7 +404,7 @@ static int __init mc32_probe1(struct net
 		dev->dev_addr[i] = mca_read_pos(slot,3);
 	}
 
-	printk("%s: Address %s", dev->name, print_mac(mac, dev->dev_addr));
+	printk("%s: Address %pM", dev->name, dev->dev_addr);
 
 	mca_write_pos(slot, 6, 0);
 	mca_write_pos(slot, 7, 0);
--- test-tree.orig/drivers/net/3c59x.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/3c59x.c	2008-10-25 02:15:59.000000000 +0200
@@ -1013,7 +1013,6 @@ static int __devinit vortex_probe1(struc
 	const char *print_name = "3c59x";
 	struct pci_dev *pdev = NULL;
 	struct eisa_device *edev = NULL;
-	DECLARE_MAC_BUF(mac);
 
 	if (!printed_version) {
 		printk (version);
@@ -1206,7 +1205,7 @@ static int __devinit vortex_probe1(struc
 		((__be16 *)dev->dev_addr)[i] = htons(eeprom[i + 10]);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 	if (print_info)
-		printk(" %s", print_mac(mac, dev->dev_addr));
+		printk(" %pM", dev->dev_addr);
 	/* Unfortunately an all zero eeprom passes the checksum and this
 	   gets found in the wild in failure cases. Crypto is hard 8) */
 	if (!is_valid_ether_addr(dev->dev_addr)) {
--- test-tree.orig/drivers/net/8139cp.c	2008-10-25 02:15:01.000000000 +0200
+++ test-tree/drivers/net/8139cp.c	2008-10-25 02:15:59.000000000 +0200
@@ -1826,7 +1826,6 @@ static int cp_init_one (struct pci_dev *
 	void __iomem *regs;
 	resource_size_t pciaddr;
 	unsigned int addr_len, i, pci_using_dac;
-	DECLARE_MAC_BUF(mac);
 
 #ifndef MODULE
 	static int version_printed;
@@ -1967,10 +1966,10 @@ static int cp_init_one (struct pci_dev *
 		goto err_out_iomap;
 
 	printk (KERN_INFO "%s: RTL-8139C+ at 0x%lx, "
-		"%s, IRQ %d\n",
+		"%pM, IRQ %d\n",
 		dev->name,
 		dev->base_addr,
-		print_mac(mac, dev->dev_addr),
+		dev->dev_addr,
 		dev->irq);
 
 	pci_set_drvdata(pdev, dev);
--- test-tree.orig/drivers/net/8139too.c	2008-10-25 02:15:04.000000000 +0200
+++ test-tree/drivers/net/8139too.c	2008-10-25 02:15:59.000000000 +0200
@@ -925,7 +925,6 @@ static int __devinit rtl8139_init_one (s
 	int i, addr_len, option;
 	void __iomem *ioaddr;
 	static int board_idx = -1;
-	DECLARE_MAC_BUF(mac);
 
 	assert (pdev != NULL);
 	assert (ent != NULL);
@@ -1024,11 +1023,11 @@ static int __devinit rtl8139_init_one (s
 	pci_set_drvdata (pdev, dev);
 
 	printk (KERN_INFO "%s: %s at 0x%lx, "
-		"%s, IRQ %d\n",
+		"%pM, IRQ %d\n",
 		dev->name,
 		board_info[ent->driver_data].name,
 		dev->base_addr,
-		print_mac(mac, dev->dev_addr),
+		dev->dev_addr,
 		dev->irq);
 
 	printk (KERN_DEBUG "%s:  Identified 8139 chip type '%s'\n",
--- test-tree.orig/drivers/net/82596.c	2008-10-25 02:15:01.000000000 +0200
+++ test-tree/drivers/net/82596.c	2008-10-25 02:15:59.000000000 +0200
@@ -1116,12 +1116,8 @@ static int i596_start_xmit(struct sk_buf
 
 static void print_eth(unsigned char *add, char *str)
 {
-	DECLARE_MAC_BUF(mac);
-	DECLARE_MAC_BUF(mac2);
-
-	printk(KERN_DEBUG "i596 0x%p, %s --> %s %02X%02X, %s\n",
-	       add, print_mac(mac, add + 6), print_mac(mac2, add),
-	       add[12], add[13], str);
+	printk(KERN_DEBUG "i596 0x%p, %pM --> %pM %02X%02X, %s\n",
+	       add, add + 6, add, add[12], add[13], str);
 }
 
 static int io = 0x300;
@@ -1544,7 +1540,6 @@ static void set_multicast_list(struct ne
 		struct dev_mc_list *dmi;
 		unsigned char *cp;
 		struct mc_cmd *cmd;
-		DECLARE_MAC_BUF(mac);
 
 		if (wait_cfg(dev, &lp->mc_cmd.cmd, 1000, "multicast list change request timed out"))
 			return;
@@ -1555,8 +1550,8 @@ static void set_multicast_list(struct ne
 		for (dmi = dev->mc_list; cnt && dmi != NULL; dmi = dmi->next, cnt--, cp += 6) {
 			memcpy(cp, dmi->dmi_addr, 6);
 			if (i596_debug > 1)
-				DEB(DEB_MULTI,printk(KERN_INFO "%s: Adding address %s\n",
-						dev->name, print_mac(mac, cp)));
+				DEB(DEB_MULTI,printk(KERN_INFO "%s: Adding address %pM\n",
+						dev->name, cp));
 		}
 		i596_add_cmd(dev, &cmd->cmd);
 	}
--- test-tree.orig/drivers/net/a2065.c	2008-10-25 02:15:02.000000000 +0200
+++ test-tree/drivers/net/a2065.c	2008-10-25 02:15:59.000000000 +0200
@@ -710,7 +710,6 @@ static int __devinit a2065_init_one(stru
 	unsigned long board, base_addr, mem_start;
 	struct resource *r1, *r2;
 	int err;
-	DECLARE_MAC_BUF(mac);
 
 	board = z->resource.start;
 	base_addr = board+A2065_LANCE;
@@ -787,8 +786,7 @@ static int __devinit a2065_init_one(stru
 	zorro_set_drvdata(z, dev);
 
 	printk(KERN_INFO "%s: A2065 at 0x%08lx, Ethernet Address "
-	       "%s\n", dev->name, board,
-	       print_mac(mac, dev->dev_addr));
+	       "%pM\n", dev->name, board, dev->dev_addr);
 
 	return 0;
 }
--- test-tree.orig/drivers/net/ac3200.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/ac3200.c	2008-10-25 02:15:59.000000000 +0200
@@ -146,7 +146,6 @@ out:
 static int __init ac_probe1(int ioaddr, struct net_device *dev)
 {
 	int i, retval;
-	DECLARE_MAC_BUF(mac);
 
 	if (!request_region(ioaddr, AC_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
@@ -171,8 +170,8 @@ static int __init ac_probe1(int ioaddr, 
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = inb(ioaddr + AC_SA_PROM + i);
 
-	printk(KERN_DEBUG "AC3200 in EISA slot %d, node %s",
-	       ioaddr/0x1000, print_mac(mac, dev->dev_addr));
+	printk(KERN_DEBUG "AC3200 in EISA slot %d, node %pM",
+	       ioaddr/0x1000, dev->dev_addr);
 #if 0
 	/* Check the vendor ID/prefix. Redundant after checking the EISA ID */
 	if (inb(ioaddr + AC_SA_PROM + 0) != AC_ADDR0
--- test-tree.orig/drivers/net/acenic.c	2008-10-25 02:15:02.000000000 +0200
+++ test-tree/drivers/net/acenic.c	2008-10-25 02:15:59.000000000 +0200
@@ -892,7 +892,6 @@ static int __devinit ace_init(struct net
 	int board_idx, ecode = 0;
 	short i;
 	unsigned char cache_size;
-	DECLARE_MAC_BUF(mac);
 
 	ap = netdev_priv(dev);
 	regs = ap->regs;
@@ -1019,7 +1018,7 @@ static int __devinit ace_init(struct net
 	dev->dev_addr[4] = (mac2 >> 8) & 0xff;
 	dev->dev_addr[5] = mac2 & 0xff;
 
-	printk("MAC: %s\n", print_mac(mac, dev->dev_addr));
+	printk("MAC: %pM\n", dev->dev_addr);
 
 	/*
 	 * Looks like this is necessary to deal with on all architectures,
--- test-tree.orig/drivers/net/amd8111e.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/amd8111e.c	2008-10-25 02:15:59.000000000 +0200
@@ -1820,7 +1820,6 @@ static int __devinit amd8111e_probe_one(
 	unsigned long reg_addr,reg_len;
 	struct amd8111e_priv* lp;
 	struct net_device* dev;
-	DECLARE_MAC_BUF(mac);
 
 	err = pci_enable_device(pdev);
 	if(err){
@@ -1962,8 +1961,8 @@ static int __devinit amd8111e_probe_one(
     	chip_version = (readl(lp->mmio + CHIPID) & 0xf0000000)>>28;
 	printk(KERN_INFO "%s: AMD-8111e Driver Version: %s\n",
 	       dev->name,MODULE_VERS);
-	printk(KERN_INFO "%s: [ Rev %x ] PCI 10/100BaseT Ethernet %s\n",
-	       dev->name, chip_version, print_mac(mac, dev->dev_addr));
+	printk(KERN_INFO "%s: [ Rev %x ] PCI 10/100BaseT Ethernet %pM\n",
+	       dev->name, chip_version, dev->dev_addr);
 	if (lp->ext_phy_id)
 		printk(KERN_INFO "%s: Found MII PHY ID 0x%08x at address 0x%02x\n",
 		       dev->name, lp->ext_phy_id, lp->ext_phy_addr);
--- test-tree.orig/drivers/net/apne.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/apne.c	2008-10-25 02:15:59.000000000 +0200
@@ -207,7 +207,6 @@ static int __init apne_probe1(struct net
     int neX000, ctron;
 #endif
     static unsigned version_printed;
-    DECLARE_MAC_BUF(mac);
 
     if (ei_debug  &&  version_printed++ == 0)
 	printk(version);
@@ -323,7 +322,7 @@ static int __init apne_probe1(struct net
     for(i = 0; i < ETHER_ADDR_LEN; i++)
 	dev->dev_addr[i] = SA_prom[i];
 
-    printk(" %s\n", print_mac(mac, dev->dev_addr));
+    printk(" %pM\n", dev->dev_addr);
 
     printk("%s: %s found.\n", dev->name, name);
 
--- test-tree.orig/drivers/net/ariadne.c	2008-10-25 02:15:00.000000000 +0200
+++ test-tree/drivers/net/ariadne.c	2008-10-25 02:15:59.000000000 +0200
@@ -165,7 +165,6 @@ static int __devinit ariadne_init_one(st
     struct net_device *dev;
     struct ariadne_private *priv;
     int err;
-    DECLARE_MAC_BUF(mac);
 
     r1 = request_mem_region(base_addr, sizeof(struct Am79C960), "Am79C960");
     if (!r1)
@@ -215,9 +214,8 @@ static int __devinit ariadne_init_one(st
     }
     zorro_set_drvdata(z, dev);
 
-    printk(KERN_INFO "%s: Ariadne at 0x%08lx, Ethernet Address "
-	   "%s\n", dev->name, board,
-	   print_mac(mac, dev->dev_addr));
+    printk(KERN_INFO "%s: Ariadne at 0x%08lx, Ethernet Address %pM\n",
+           dev->name, board, dev->dev_addr);
 
     return 0;
 }
@@ -613,14 +611,10 @@ static int ariadne_start_xmit(struct sk_
 
 #if 0
 {
-    DECLARE_MAC_BUF(mac);
-    DECLARE_MAC_BUF(mac2);
-
-    printk(KERN_DEBUG "TX pkt type 0x%04x from %s to %s "
+    printk(KERN_DEBUG "TX pkt type 0x%04x from %pM to %pM "
 	   " data 0x%08x len %d\n",
 	   ((u_short *)skb->data)[6],
-	   print_mac(mac, ((const u8 *)skb->data)+6),
-	   print_mac(mac, (const u8 *)skb->data),
+	   skb->data + 6, skb->data,
 	   (int)skb->data, (int)skb->len);
 }
 #endif
@@ -743,18 +737,16 @@ static int ariadne_rx(struct net_device 
 	    skb->protocol=eth_type_trans(skb,dev);
 #if 0
 {
-	    DECLARE_MAC_BUF(mac);
-
 	    printk(KERN_DEBUG "RX pkt type 0x%04x from ",
 		   ((u_short *)skb->data)[6]);
 	    {
 		u_char *ptr = &((u_char *)skb->data)[6];
-		printk("%s", print_mac(mac, ptr));
+		printk("%pM", ptr);
 	    }
 	    printk(" to ");
 	    {
 		u_char *ptr = (u_char *)skb->data;
-		printk("%s", print_mac(mac, ptr));
+		printk("%pM", ptr);
 	    }
 	    printk(" data 0x%08x len %d\n", (int)skb->data, (int)skb->len);
 }
--- test-tree.orig/drivers/net/arm/am79c961a.c	2008-10-25 02:15:04.000000000 +0200
+++ test-tree/drivers/net/arm/am79c961a.c	2008-10-25 02:15:59.000000000 +0200
@@ -745,10 +745,8 @@ static int __init am79c961_probe(struct 
 
 	ret = register_netdev(dev);
 	if (ret == 0) {
-		DECLARE_MAC_BUF(mac);
-
-		printk(KERN_INFO "%s: ether address %s\n",
-		       dev->name, print_mac(mac, dev->dev_addr));
+		printk(KERN_INFO "%s: ether address %pM\n",
+		       dev->name, dev->dev_addr);
 		return 0;
 	}
 
--- test-tree.orig/drivers/net/arm/at91_ether.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/arm/at91_ether.c	2008-10-25 02:15:59.000000000 +0200
@@ -485,7 +485,6 @@ static void update_mac_address(struct ne
 static int set_mac_address(struct net_device *dev, void* addr)
 {
 	struct sockaddr *address = addr;
-	DECLARE_MAC_BUF(mac);
 
 	if (!is_valid_ether_addr(address->sa_data))
 		return -EADDRNOTAVAIL;
@@ -493,8 +492,8 @@ static int set_mac_address(struct net_de
 	memcpy(dev->dev_addr, address->sa_data, dev->addr_len);
 	update_mac_address(dev);
 
-	printk("%s: Setting MAC address to %s\n", dev->name,
-	       print_mac(mac, dev->dev_addr));
+	printk("%s: Setting MAC address to %pM\n", dev->name,
+	       dev->dev_addr);
 
 	return 0;
 }
@@ -978,7 +977,6 @@ static int __init at91ether_setup(unsign
 	struct at91_private *lp;
 	unsigned int val;
 	int res;
-	DECLARE_MAC_BUF(mac);
 
 	dev = alloc_etherdev(sizeof(struct at91_private));
 	if (!dev)
@@ -1083,11 +1081,11 @@ static int __init at91ether_setup(unsign
 	}
 
 	/* Display ethernet banner */
-	printk(KERN_INFO "%s: AT91 ethernet at 0x%08x int=%d %s%s (%s)\n",
+	printk(KERN_INFO "%s: AT91 ethernet at 0x%08x int=%d %s%s (%pM)\n",
 	       dev->name, (uint) dev->base_addr, dev->irq,
 	       at91_emac_read(AT91_EMAC_CFG) & AT91_EMAC_SPD ? "100-" : "10-",
 	       at91_emac_read(AT91_EMAC_CFG) & AT91_EMAC_FD ? "FullDuplex" : "HalfDuplex",
-	       print_mac(mac, dev->dev_addr));
+	       dev->dev_addr);
 	if ((phy_type == MII_DM9161_ID) || (lp->phy_type == MII_DM9161A_ID))
 		printk(KERN_INFO "%s: Davicom 9161 PHY %s\n", dev->name, (lp->phy_media == PORT_FIBRE) ? "(Fiber)" : "(Copper)");
 	else if (phy_type == MII_LXT971A_ID)
--- test-tree.orig/drivers/net/arm/ether1.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/arm/ether1.c	2008-10-25 02:15:59.000000000 +0200
@@ -996,7 +996,6 @@ ether1_probe(struct expansion_card *ec, 
 {
 	struct net_device *dev;
 	int i, ret = 0;
-	DECLARE_MAC_BUF(mac);
 
 	ether1_banner();
 
@@ -1044,8 +1043,8 @@ ether1_probe(struct expansion_card *ec, 
 	if (ret)
 		goto free;
 
-	printk(KERN_INFO "%s: ether1 in slot %d, %s\n",
-		dev->name, ec->slot_no, print_mac(mac, dev->dev_addr));
+	printk(KERN_INFO "%s: ether1 in slot %d, %pM\n",
+		dev->name, ec->slot_no, dev->dev_addr);
     
 	ecard_set_drvdata(ec, dev);
 	return 0;
--- test-tree.orig/drivers/net/arm/ether3.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/arm/ether3.c	2008-10-25 02:15:59.000000000 +0200
@@ -776,7 +776,6 @@ ether3_probe(struct expansion_card *ec, 
 	const struct ether3_data *data = id->data;
 	struct net_device *dev;
 	int bus_type, ret;
-	DECLARE_MAC_BUF(mac);
 
 	ether3_banner();
 
@@ -859,8 +858,8 @@ ether3_probe(struct expansion_card *ec, 
 	if (ret)
 		goto free;
 
-	printk("%s: %s in slot %d, %s\n",
-	       dev->name, data->name, ec->slot_no, print_mac(mac, dev->dev_addr));
+	printk("%s: %s in slot %d, %pM\n",
+	       dev->name, data->name, ec->slot_no, dev->dev_addr);
 
 	ecard_set_drvdata(ec, dev);
 	return 0;
--- test-tree.orig/drivers/net/arm/etherh.c	2008-10-25 02:15:04.000000000 +0200
+++ test-tree/drivers/net/arm/etherh.c	2008-10-25 02:15:59.000000000 +0200
@@ -648,7 +648,6 @@ etherh_probe(struct expansion_card *ec, 
 	struct net_device *dev;
 	struct etherh_priv *eh;
 	int ret;
-	DECLARE_MAC_BUF(mac);
 
 	etherh_banner();
 
@@ -746,8 +745,8 @@ etherh_probe(struct expansion_card *ec, 
 	if (ret)
 		goto free;
 
-	printk(KERN_INFO "%s: %s in slot %d, %s\n",
-		dev->name, data->name, ec->slot_no, print_mac(mac, dev->dev_addr));
+	printk(KERN_INFO "%s: %s in slot %d, %pM\n",
+		dev->name, data->name, ec->slot_no, dev->dev_addr);
 
 	ecard_set_drvdata(ec, dev);
 
--- test-tree.orig/drivers/net/at1700.c	2008-10-25 02:14:57.000000000 +0200
+++ test-tree/drivers/net/at1700.c	2008-10-25 02:15:59.000000000 +0200
@@ -265,7 +265,6 @@ static int __init at1700_probe1(struct n
 	unsigned int i, irq, is_fmv18x = 0, is_at1700 = 0;
 	int slot, ret = -ENODEV;
 	struct net_local *lp = netdev_priv(dev);
-	DECLARE_MAC_BUF(mac);
 
 	if (!request_region(ioaddr, AT1700_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
@@ -397,7 +396,7 @@ found:
 			dev->dev_addr[i] = val;
 		}
 	}
-	printk("%s", print_mac(mac, dev->dev_addr));
+	printk("%pM", dev->dev_addr);
 
 	/* The EEPROM word 12 bit 0x0400 means use regular 100 ohm 10baseT signals,
 	   rather than 150 ohm shielded twisted pair compensation.
--- test-tree.orig/drivers/net/atarilance.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/atarilance.c	2008-10-25 02:15:59.000000000 +0200
@@ -466,7 +466,6 @@ static unsigned long __init lance_probe1
 	int 					i;
 	static int 				did_version;
 	unsigned short			save1, save2;
-	DECLARE_MAC_BUF(mac);
 
 	PROBE_PRINT(( "Probing for Lance card at mem %#lx io %#lx\n",
 				  (long)memaddr, (long)ioaddr ));
@@ -595,7 +594,7 @@ static unsigned long __init lance_probe1
 		i = IO->mem;
 		break;
 	}
-	printk("%s\n", print_mac(mac, dev->dev_addr));
+	printk("%pM\n", dev->dev_addr);
 	if (lp->cardtype == OLD_RIEBL) {
 		printk( "%s: Warning: This is a default ethernet address!\n",
 				dev->name );
@@ -778,8 +777,6 @@ static int lance_start_xmit( struct sk_b
 	int entry, len;
 	struct lance_tx_head *head;
 	unsigned long flags;
-	DECLARE_MAC_BUF(mac);
-	DECLARE_MAC_BUF(mac2);
 
 	DPRINTK( 2, ( "%s: lance_start_xmit() called, csr0 %4.4x.\n",
 				  dev->name, DREG ));
@@ -802,12 +799,10 @@ static int lance_start_xmit( struct sk_b
 
 	/* Fill in a Tx ring entry */
 	if (lance_debug >= 3) {
-		printk( "%s: TX pkt type 0x%04x from "
-				"%s to %s"
+		printk( "%s: TX pkt type 0x%04x from %pM to %pM"
 				" data at 0x%08x len %d\n",
 				dev->name, ((u_short *)skb->data)[6],
-				print_mac(mac, &skb->data[6]),
-				print_mac(mac2, skb->data),
+				&skb->data[6], skb->data,
 				(int)skb->data, (int)skb->len );
 	}
 
@@ -1019,14 +1014,12 @@ static int lance_rx( struct net_device *
 
 				if (lance_debug >= 3) {
 					u_char *data = PKTBUF_ADDR(head);
-					DECLARE_MAC_BUF(mac);
-					DECLARE_MAC_BUF(mac2);
 
-					printk(KERN_DEBUG "%s: RX pkt type 0x%04x from %s to %s "
+					printk(KERN_DEBUG "%s: RX pkt type 0x%04x from %pM to %pM "
 						   "data %02x %02x %02x %02x %02x %02x %02x %02x "
 						   "len %d\n",
 						   dev->name, ((u_short *)data)[6],
-						   print_mac(mac, &data[6]), print_mac(mac2, data),
+						   &data[6], data,
 						   data[15], data[16], data[17], data[18],
 						   data[19], data[20], data[21], data[22],
 						   pkt_len);
--- test-tree.orig/drivers/net/atp.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/atp.c	2008-10-25 02:15:59.000000000 +0200
@@ -248,7 +248,6 @@ static int __init atp_probe1(long ioaddr
 	struct net_local *lp;
 	int saved_ctrl_reg, status, i;
 	int res;
-	DECLARE_MAC_BUF(mac);
 
 	outb(0xff, ioaddr + PAR_DATA);
 	/* Save the original value of the Control register, in case we guessed
@@ -324,8 +323,8 @@ static int __init atp_probe1(long ioaddr
 #endif
 
 	printk(KERN_NOTICE "%s: Pocket adapter found at %#3lx, IRQ %d, "
-	       "SAPROM %s.\n",
-	       dev->name, dev->base_addr, dev->irq, print_mac(mac, dev->dev_addr));
+	       "SAPROM %pM.\n",
+	       dev->name, dev->base_addr, dev->irq, dev->dev_addr);
 
 	/* Reset the ethernet hardware and activate the printer pass-through. */
 	write_reg_high(ioaddr, CMR1, CMR1h_RESET | CMR1h_MUX);
--- test-tree.orig/drivers/net/ax88796.c	2008-10-25 02:15:00.000000000 +0200
+++ test-tree/drivers/net/ax88796.c	2008-10-25 02:15:59.000000000 +0200
@@ -758,13 +758,10 @@ static int ax_init_dev(struct net_device
 #endif
 	ax_NS8390_init(dev, 0);
 
-	if (first_init) {
-		DECLARE_MAC_BUF(mac);
-
-		dev_info(&ax->dev->dev, "%dbit, irq %d, %lx, MAC: %s\n",
+	if (first_init)
+		dev_info(&ax->dev->dev, "%dbit, irq %d, %lx, MAC: %pM\n",
 			 ei_status.word16 ? 16:8, dev->irq, dev->base_addr,
-			 print_mac(mac, dev->dev_addr));
-	}
+			 dev->dev_addr);
 
 	ret = register_netdev(dev);
 	if (ret)
--- test-tree.orig/drivers/net/b44.c	2008-10-25 02:15:04.000000000 +0200
+++ test-tree/drivers/net/b44.c	2008-10-25 02:15:59.000000000 +0200
@@ -2117,7 +2117,6 @@ static int __devinit b44_init_one(struct
 	struct net_device *dev;
 	struct b44 *bp;
 	int err;
-	DECLARE_MAC_BUF(mac);
 
 	instance++;
 
@@ -2213,8 +2212,8 @@ static int __devinit b44_init_one(struct
 	 */
 	b44_chip_reset(bp, B44_CHIP_RESET_FULL);
 
-	printk(KERN_INFO "%s: Broadcom 44xx/47xx 10/100BaseT Ethernet %s\n",
-	       dev->name, print_mac(mac, dev->dev_addr));
+	printk(KERN_INFO "%s: Broadcom 44xx/47xx 10/100BaseT Ethernet %pM\n",
+	       dev->name, dev->dev_addr);
 
 	return 0;
 
--- test-tree.orig/drivers/net/bmac.c	2008-10-25 02:15:04.000000000 +0200
+++ test-tree/drivers/net/bmac.c	2008-10-25 02:15:59.000000000 +0200
@@ -1258,7 +1258,6 @@ static int __devinit bmac_probe(struct m
 	unsigned char addr[6];
 	struct net_device *dev;
 	int is_bmac_plus = ((int)match->data) != 0;
-	DECLARE_MAC_BUF(mac);
 
 	if (macio_resource_count(mdev) != 3 || macio_irq_count(mdev) != 3) {
 		printk(KERN_ERR "BMAC: can't use, need 3 addrs and 3 intrs\n");
@@ -1368,8 +1367,8 @@ static int __devinit bmac_probe(struct m
 		goto err_out_irq2;
 	}
 
-	printk(KERN_INFO "%s: BMAC%s at %s",
-	       dev->name, (is_bmac_plus ? "+" : ""), print_mac(mac, dev->dev_addr));
+	printk(KERN_INFO "%s: BMAC%s at %pM",
+	       dev->name, (is_bmac_plus ? "+" : ""), dev->dev_addr);
 	XXDEBUG((", base_addr=%#0lx", dev->base_addr));
 	printk("\n");
 
--- test-tree.orig/drivers/net/bnx2.c	2008-10-25 02:15:01.000000000 +0200
+++ test-tree/drivers/net/bnx2.c	2008-10-25 02:15:59.000000000 +0200
@@ -7700,7 +7700,6 @@ bnx2_init_one(struct pci_dev *pdev, cons
 	struct bnx2 *bp;
 	int rc;
 	char str[40];
-	DECLARE_MAC_BUF(mac);
 
 	if (version_printed++ == 0)
 		printk(KERN_INFO "%s", version);
@@ -7767,14 +7766,14 @@ bnx2_init_one(struct pci_dev *pdev, cons
 	}
 
 	printk(KERN_INFO "%s: %s (%c%d) %s found at mem %lx, "
-		"IRQ %d, node addr %s\n",
+		"IRQ %d, node addr %pM\n",
 		dev->name,
 		board_info[ent->driver_data].name,
 		((CHIP_ID(bp) & 0xf000) >> 12) + 'A',
 		((CHIP_ID(bp) & 0x0ff0) >> 4),
 		bnx2_bus_string(bp, str),
 		dev->base_addr,
-		bp->pdev->irq, print_mac(mac, dev->dev_addr));
+		bp->pdev->irq, dev->dev_addr);
 
 	return 0;
 }
--- test-tree.orig/drivers/net/bnx2x_main.c	2008-10-25 02:15:04.000000000 +0200
+++ test-tree/drivers/net/bnx2x_main.c	2008-10-25 02:15:59.000000000 +0200
@@ -10192,7 +10192,6 @@ static int __devinit bnx2x_init_one(stru
 	struct net_device *dev = NULL;
 	struct bnx2x *bp;
 	int rc;
-	DECLARE_MAC_BUF(mac);
 
 	if (version_printed++ == 0)
 		printk(KERN_INFO "%s", version);
@@ -10236,7 +10235,7 @@ static int __devinit bnx2x_init_one(stru
 	       bnx2x_get_pcie_width(bp),
 	       (bnx2x_get_pcie_speed(bp) == 2) ? "5GHz (Gen2)" : "2.5GHz",
 	       dev->base_addr, bp->pdev->irq);
-	printk(KERN_CONT "node addr %s\n", print_mac(mac, dev->dev_addr));
+	printk(KERN_CONT "node addr %pM\n", dev->dev_addr);
 	return 0;
 
 init_one_exit:
--- test-tree.orig/drivers/net/bonding/bond_main.c	2008-10-25 02:15:05.000000000 +0200
+++ test-tree/drivers/net/bonding/bond_main.c	2008-10-25 02:15:59.000000000 +0200
@@ -1791,7 +1791,6 @@ int bond_release(struct net_device *bond
 	struct slave *slave, *oldcurrent;
 	struct sockaddr addr;
 	int mac_addr_differ;
-	DECLARE_MAC_BUF(mac);
 
 	/* slave is not a slave or master is not master of this slave */
 	if (!(slave_dev->flags & IFF_SLAVE) ||
@@ -1820,11 +1819,11 @@ int bond_release(struct net_device *bond
 		if (!mac_addr_differ && (bond->slave_cnt > 1))
 			printk(KERN_WARNING DRV_NAME
 			       ": %s: Warning: the permanent HWaddr of %s - "
-			       "%s - is still in use by %s. "
+			       "%pM - is still in use by %s. "
 			       "Set the HWaddr of %s to a different address "
 			       "to avoid conflicts.\n",
 			       bond_dev->name, slave_dev->name,
-			       print_mac(mac, slave->perm_hwaddr),
+			       slave->perm_hwaddr,
 			       bond_dev->name, slave_dev->name);
 	}
 
@@ -3285,7 +3284,6 @@ static void bond_info_show_master(struct
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
-		DECLARE_MAC_BUF(mac);
 
 		seq_puts(seq, "\n802.3ad info\n");
 		seq_printf(seq, "LACP rate: %s\n",
@@ -3305,8 +3303,8 @@ static void bond_info_show_master(struct
 				   ad_info.actor_key);
 			seq_printf(seq, "\tPartner Key: %d\n",
 				   ad_info.partner_key);
-			seq_printf(seq, "\tPartner Mac Address: %s\n",
-				   print_mac(mac, ad_info.partner_system));
+			seq_printf(seq, "\tPartner Mac Address: %pM\n",
+				   ad_info.partner_system);
 		}
 	}
 }
@@ -3314,7 +3312,6 @@ static void bond_info_show_master(struct
 static void bond_info_show_slave(struct seq_file *seq, const struct slave *slave)
 {
 	struct bonding *bond = seq->private;
-	DECLARE_MAC_BUF(mac);
 
 	seq_printf(seq, "\nSlave Interface: %s\n", slave->dev->name);
 	seq_printf(seq, "MII Status: %s\n",
@@ -3322,9 +3319,7 @@ static void bond_info_show_slave(struct 
 	seq_printf(seq, "Link Failure Count: %u\n",
 		   slave->link_failure_count);
 
-	seq_printf(seq,
-		   "Permanent HW addr: %s\n",
-		   print_mac(mac, slave->perm_hwaddr));
+	seq_printf(seq, "Permanent HW addr: %pM\n", slave->perm_hwaddr);
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		const struct aggregator *agg
--- test-tree.orig/drivers/net/bonding/bond_sysfs.c	2008-10-25 02:15:05.000000000 +0200
+++ test-tree/drivers/net/bonding/bond_sysfs.c	2008-10-25 02:15:59.000000000 +0200
@@ -1391,13 +1391,11 @@ static ssize_t bonding_show_ad_partner_m
 {
 	int count = 0;
 	struct bonding *bond = to_bond(d);
-	DECLARE_MAC_BUF(mac);
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
 		if (!bond_3ad_get_active_agg_info(bond, &ad_info)) {
-			count = sprintf(buf,"%s\n",
-					print_mac(mac, ad_info.partner_system));
+			count = sprintf(buf, "%pM\n", ad_info.partner_system);
 		}
 	}
 
--- test-tree.orig/drivers/net/cassini.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/cassini.c	2008-10-25 02:15:59.000000000 +0200
@@ -4988,7 +4988,6 @@ static int __devinit cas_init_one(struct
 	int i, err, pci_using_dac;
 	u16 pci_cmd;
 	u8 orig_cacheline_size = 0, cas_cacheline_size = 0;
-	DECLARE_MAC_BUF(mac);
 
 	if (cas_version_printed++ == 0)
 		printk(KERN_INFO "%s", version);
@@ -5201,12 +5200,12 @@ static int __devinit cas_init_one(struct
 
 	i = readl(cp->regs + REG_BIM_CFG);
 	printk(KERN_INFO "%s: Sun Cassini%s (%sbit/%sMHz PCI/%s) "
-	       "Ethernet[%d] %s\n",  dev->name,
+	       "Ethernet[%d] %pM\n",  dev->name,
 	       (cp->cas_flags & CAS_FLAG_REG_PLUS) ? "+" : "",
 	       (i & BIM_CFG_32BIT) ? "32" : "64",
 	       (i & BIM_CFG_66MHZ) ? "66" : "33",
 	       (cp->phy_type == CAS_PHY_SERDES) ? "Fi" : "Cu", pdev->irq,
-	       print_mac(mac, dev->dev_addr));
+	       dev->dev_addr);
 
 	pci_set_drvdata(pdev, dev);
 	cp->hw_running = 1;
--- test-tree.orig/drivers/net/cpmac.c	2008-10-25 02:15:04.000000000 +0200
+++ test-tree/drivers/net/cpmac.c	2008-10-25 02:15:59.000000000 +0200
@@ -1103,7 +1103,6 @@ static int __devinit cpmac_probe(struct 
 	struct cpmac_priv *priv;
 	struct net_device *dev;
 	struct plat_cpmac_data *pdata;
-	DECLARE_MAC_BUF(mac);
 
 	pdata = pdev->dev.platform_data;
 
@@ -1180,8 +1179,8 @@ static int __devinit cpmac_probe(struct 
 	if (netif_msg_probe(priv)) {
 		printk(KERN_INFO
 		       "cpmac: device %s (regs: %p, irq: %d, phy: %s, "
-		       "mac: %s)\n", dev->name, (void *)mem->start, dev->irq,
-		       priv->phy_name, print_mac(mac, dev->dev_addr));
+		       "mac: %pM)\n", dev->name, (void *)mem->start, dev->irq,
+		       priv->phy_name, dev->dev_addr);
 	}
 	return 0;
 
--- test-tree.orig/drivers/net/cris/eth_v10.c	2008-10-25 02:15:00.000000000 +0200
+++ test-tree/drivers/net/cris/eth_v10.c	2008-10-25 02:15:59.000000000 +0200
@@ -419,7 +419,6 @@ e100_set_mac_address(struct net_device *
 {
 	struct net_local *np = netdev_priv(dev);
 	struct sockaddr *addr = p;
-	DECLARE_MAC_BUF(mac);
 
 	spin_lock(&np->lock); /* preemption protection */
 
@@ -440,8 +439,7 @@ e100_set_mac_address(struct net_device *
 
 	/* show it in the log as well */
 
-	printk(KERN_INFO "%s: changed MAC to %s\n",
-	       dev->name, print_mac(mac, dev->dev_addr));
+	printk(KERN_INFO "%s: changed MAC to %pM\n", dev->name, dev->dev_addr);
 
 	spin_unlock(&np->lock);
 
--- test-tree.orig/drivers/net/cs89x0.c	2008-10-25 02:14:57.000000000 +0200
+++ test-tree/drivers/net/cs89x0.c	2008-10-25 02:15:59.000000000 +0200
@@ -521,7 +521,6 @@ cs89x0_probe1(struct net_device *dev, in
 	unsigned rev_type = 0;
 	int eeprom_buff[CHKSUM_LEN];
 	int retval;
-	DECLARE_MAC_BUF(mac);
 
 	/* Initialize the device structure. */
 	if (!modular) {
@@ -846,7 +845,7 @@ cs89x0_probe1(struct net_device *dev, in
 	}
 
 	/* print the ethernet address. */
-	printk(", MAC %s", print_mac(mac, dev->dev_addr));
+	printk(", MAC %pM", dev->dev_addr);
 
 	dev->open		= net_open;
 	dev->stop		= net_close;
@@ -1817,11 +1816,10 @@ static int set_mac_address(struct net_de
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 
-	if (net_debug) {
-		DECLARE_MAC_BUF(mac);
-		printk("%s: Setting MAC address to %s.\n",
-		       dev->name, print_mac(mac, dev->dev_addr));
-	}
+	if (net_debug)
+		printk("%s: Setting MAC address to %pM.\n",
+		       dev->name, dev->dev_addr);
+
 	/* set the Ethernet address */
 	for (i=0; i < ETH_ALEN/2; i++)
 		writereg(dev, PP_IA+i*2, dev->dev_addr[i*2] | (dev->dev_addr[i*2+1] << 8));
--- test-tree.orig/drivers/net/de600.c	2008-10-25 02:14:57.000000000 +0200
+++ test-tree/drivers/net/de600.c	2008-10-25 02:15:59.000000000 +0200
@@ -384,7 +384,6 @@ static struct net_device * __init de600_
 	int	i;
 	struct net_device *dev;
 	int err;
-	DECLARE_MAC_BUF(mac);
 
 	dev = alloc_etherdev(0);
 	if (!dev)
@@ -439,7 +438,7 @@ static struct net_device * __init de600_
 		goto out1;
 	}
 
-	printk(", Ethernet Address: %s\n", print_mac(mac, dev->dev_addr));
+	printk(", Ethernet Address: %pM\n", dev->dev_addr);
 
 	dev->open = de600_open;
 	dev->stop = de600_close;
--- test-tree.orig/drivers/net/de620.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/de620.c	2008-10-25 02:15:59.000000000 +0200
@@ -800,7 +800,6 @@ struct net_device * __init de620_probe(i
 	struct net_device *dev;
 	int err = -ENOMEM;
 	int i;
-	DECLARE_MAC_BUF(mac);
 
 	dev = alloc_etherdev(0);
 	if (!dev)
@@ -853,7 +852,7 @@ struct net_device * __init de620_probe(i
 		dev->broadcast[i] = 0xff;
 	}
 
-	printk(", Ethernet Address: %s", print_mac(mac, dev->dev_addr));
+	printk(", Ethernet Address: %pM", dev->dev_addr);
 
 	printk(" (%dk RAM,",
 		(nic_data.RAM_Size) ? (nic_data.RAM_Size >> 2) : 64);
--- test-tree.orig/drivers/net/declance.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/declance.c	2008-10-25 02:15:59.000000000 +0200
@@ -1023,7 +1023,6 @@ static int __init dec_lance_probe(struct
 	int i, ret;
 	unsigned long esar_base;
 	unsigned char *esar;
-	DECLARE_MAC_BUF(mac);
 
 	if (dec_lance_debug && version_printed++ == 0)
 		printk(version);
@@ -1223,8 +1222,7 @@ static int __init dec_lance_probe(struct
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = esar[i * 4];
 
-	printk(", addr = %s, irq = %d\n",
-	       print_mac(mac, dev->dev_addr), dev->irq);
+	printk(", addr = %pM, irq = %d\n", dev->dev_addr, dev->irq);
 
 	dev->open = &lance_open;
 	dev->stop = &lance_close;
--- test-tree.orig/drivers/net/depca.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/depca.c	2008-10-25 02:15:59.000000000 +0200
@@ -573,7 +573,6 @@ static int __init depca_hw_init (struct 
 	s16 nicsr;
 	u_long ioaddr;
 	u_long mem_start;
-	DECLARE_MAC_BUF(mac);
 
 	/*
 	 * We are now supposed to enter this function with the
@@ -633,7 +632,7 @@ static int __init depca_hw_init (struct 
 
 	printk(", h/w address ");
 	status = get_hw_addr(dev);
-	printk("%s", print_mac(mac, dev->dev_addr));
+	printk("%pM", dev->dev_addr);
 	if (status != 0) {
 		printk("      which has an Ethernet PROM CRC error.\n");
 		return -ENXIO;
@@ -1841,7 +1840,6 @@ static void depca_dbg_open(struct net_de
 	u_long ioaddr = dev->base_addr;
 	struct depca_init *p = &lp->init_block;
 	int i;
-	DECLARE_MAC_BUF(mac);
 
 	if (depca_debug > 1) {
 		/* Do not copy the shadow init block into shared memory */
@@ -1880,7 +1878,7 @@ static void depca_dbg_open(struct net_de
 		printk("...0x%8.8x\n", readl(&lp->tx_ring[i].base));
 		printk("Initialisation block at 0x%8.8lx(Phys)\n", lp->mem_start);
 		printk("        mode: 0x%4.4x\n", p->mode);
-		printk("        physical address: %s\n", print_mac(mac, p->phys_addr));
+		printk("        physical address: %pM\n", p->phys_addr);
 		printk("        multicast hash table: ");
 		for (i = 0; i < (HASH_TABLE_LEN >> 3) - 1; i++) {
 			printk("%2.2x:", p->mcast_table[i]);
--- test-tree.orig/drivers/net/dl2k.c	2008-10-25 02:15:01.000000000 +0200
+++ test-tree/drivers/net/dl2k.c	2008-10-25 02:15:59.000000000 +0200
@@ -97,7 +97,6 @@ rio_probe1 (struct pci_dev *pdev, const 
 	static int version_printed;
 	void *ring_space;
 	dma_addr_t ring_dma;
-	DECLARE_MAC_BUF(mac);
 
 	if (!version_printed++)
 		printk ("%s", version);
@@ -257,8 +256,8 @@ rio_probe1 (struct pci_dev *pdev, const 
 
 	card_idx++;
 
-	printk (KERN_INFO "%s: %s, %s, IRQ %d\n",
-		dev->name, np->name, print_mac(mac, dev->dev_addr), irq);
+	printk (KERN_INFO "%s: %s, %pM, IRQ %d\n",
+		dev->name, np->name, dev->dev_addr, irq);
 	if (tx_coalesce > 1)
 		printk(KERN_INFO "tx_coalesce:\t%d packets\n",
 				tx_coalesce);
--- test-tree.orig/drivers/net/dm9000.c	2008-10-25 02:15:00.000000000 +0200
+++ test-tree/drivers/net/dm9000.c	2008-10-25 02:15:59.000000000 +0200
@@ -1385,13 +1385,11 @@ dm9000_probe(struct platform_device *pde
 	platform_set_drvdata(pdev, ndev);
 	ret = register_netdev(ndev);
 
-	if (ret == 0) {
-		DECLARE_MAC_BUF(mac);
-		printk(KERN_INFO "%s: dm9000%c at %p,%p IRQ %d MAC: %s (%s)\n",
+	if (ret == 0)
+		printk(KERN_INFO "%s: dm9000%c at %p,%p IRQ %d MAC: %pM (%s)\n",
 		       ndev->name, dm9000_type_to_char(db->type),
 		       db->io_addr, db->io_data, ndev->irq,
-		       print_mac(mac, ndev->dev_addr), mac_src);
-	}
+		       ndev->dev_addr, mac_src);
 	return 0;
 
 out:
--- test-tree.orig/drivers/net/e100.c	2008-10-25 02:15:05.000000000 +0200
+++ test-tree/drivers/net/e100.c	2008-10-25 02:15:59.000000000 +0200
@@ -2616,7 +2616,6 @@ static int __devinit e100_probe(struct p
 	struct net_device *netdev;
 	struct nic *nic;
 	int err;
-	DECLARE_MAC_BUF(mac);
 
 	if(!(netdev = alloc_etherdev(sizeof(struct nic)))) {
 		if(((1 << debug) - 1) & NETIF_MSG_PROBE)
@@ -2746,9 +2745,9 @@ static int __devinit e100_probe(struct p
 		goto err_out_free;
 	}
 
-	DPRINTK(PROBE, INFO, "addr 0x%llx, irq %d, MAC addr %s\n",
+	DPRINTK(PROBE, INFO, "addr 0x%llx, irq %d, MAC addr %pM\n",
 		(unsigned long long)pci_resource_start(pdev, use_io ? 1 : 0),
-		pdev->irq, print_mac(mac, netdev->dev_addr));
+		pdev->irq, netdev->dev_addr);
 
 	return 0;
 
--- test-tree.orig/drivers/net/e1000/e1000_main.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/e1000/e1000_main.c	2008-10-25 02:15:59.000000000 +0200
@@ -912,7 +912,6 @@ static int __devinit e1000_probe(struct 
 	u16 eeprom_data = 0;
 	u16 eeprom_apme_mask = E1000_EEPROM_APME;
 	int bars, need_ioport;
-	DECLARE_MAC_BUF(mac);
 
 	/* do not allocate ioport bars when not needed */
 	need_ioport = e1000_is_need_ioport(pdev);
@@ -1194,7 +1193,7 @@ static int __devinit e1000_probe(struct 
 		 (hw->bus_width == e1000_bus_width_pciex_1) ? "Width x1" :
 		 "32-bit"));
 
-	printk("%s\n", print_mac(mac, netdev->dev_addr));
+	printk("%pM\n", netdev->dev_addr);
 
 	if (hw->bus_type == e1000_bus_type_pci_express) {
 		DPRINTK(PROBE, WARNING, "This device (id %04x:%04x) will no "
--- test-tree.orig/drivers/net/eepro.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/eepro.c	2008-10-25 02:15:59.000000000 +0200
@@ -690,7 +690,6 @@ static void __init eepro_print_info (str
 	struct eepro_local *	lp = netdev_priv(dev);
 	int			i;
 	const char *		ifmap[] = {"AUI", "10Base2", "10BaseT"};
-	DECLARE_MAC_BUF(mac);
 
 	i = inb(dev->base_addr + ID_REG);
 	printk(KERN_DEBUG " id: %#x ",i);
@@ -715,7 +714,7 @@ static void __init eepro_print_info (str
 			break;
 	}
 
-	printk(" %s", print_mac(mac, dev->dev_addr));
+	printk(" %pM", dev->dev_addr);
 
 	if (net_debug > 3)
 		printk(KERN_DEBUG ", %dK RCV buffer",
--- test-tree.orig/drivers/net/eepro100.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/eepro100.c	2008-10-25 02:15:59.000000000 +0200
@@ -616,7 +616,6 @@ static int __devinit speedo_found1(struc
 	int size;
 	void *tx_ring_space;
 	dma_addr_t tx_ring_dma;
-	DECLARE_MAC_BUF(mac);
 
 	size = TX_RING_SIZE * sizeof(struct TxFD) + sizeof(struct speedo_stats);
 	tx_ring_space = pci_alloc_consistent(pdev, size, &tx_ring_dma);
@@ -700,8 +699,8 @@ static int __devinit speedo_found1(struc
 	else
 		product = pci_name(pdev);
 
-	printk(KERN_INFO "%s: %s, %s, IRQ %d.\n", dev->name, product,
-		   print_mac(mac, dev->dev_addr), pdev->irq);
+	printk(KERN_INFO "%s: %s, %pM, IRQ %d.\n", dev->name, product,
+		   dev->dev_addr, pdev->irq);
 
 	sp = netdev_priv(dev);
 
--- test-tree.orig/drivers/net/enc28j60.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/enc28j60.c	2008-10-25 02:15:59.000000000 +0200
@@ -477,12 +477,10 @@ static int enc28j60_set_hw_macaddr(struc
 
 	mutex_lock(&priv->lock);
 	if (!priv->hw_enable) {
-		if (netif_msg_drv(priv)) {
-			DECLARE_MAC_BUF(mac);
+		if (netif_msg_drv(priv))
 			printk(KERN_INFO DRV_NAME
-				": %s: Setting MAC address to %s\n",
-				ndev->name, print_mac(mac, ndev->dev_addr));
-		}
+				": %s: Setting MAC address to %pM\n",
+				ndev->name, ndev->dev_addr);
 		/* NOTE: MAC address in ENC28J60 is byte-backward */
 		nolock_regb_write(priv, MAADR5, ndev->dev_addr[0]);
 		nolock_regb_write(priv, MAADR4, ndev->dev_addr[1]);
@@ -1328,11 +1326,9 @@ static int enc28j60_net_open(struct net_
 		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __func__);
 
 	if (!is_valid_ether_addr(dev->dev_addr)) {
-		if (netif_msg_ifup(priv)) {
-			DECLARE_MAC_BUF(mac);
-			dev_err(&dev->dev, "invalid MAC address %s\n",
-				print_mac(mac, dev->dev_addr));
-		}
+		if (netif_msg_ifup(priv))
+			dev_err(&dev->dev, "invalid MAC address %pM\n",
+				dev->dev_addr);
 		return -EADDRNOTAVAIL;
 	}
 	/* Reset the hardware here (and take it out of low power mode) */
--- test-tree.orig/drivers/net/epic100.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/epic100.c	2008-10-25 02:15:59.000000000 +0200
@@ -322,7 +322,6 @@ static int __devinit epic_init_one (stru
 	int i, ret, option = 0, duplex = 0;
 	void *ring_space;
 	dma_addr_t ring_dma;
-	DECLARE_MAC_BUF(mac);
 
 /* when built into the kernel, we only print version if device is found */
 #ifndef MODULE
@@ -499,9 +498,9 @@ static int __devinit epic_init_one (stru
 	if (ret < 0)
 		goto err_out_unmap_rx;
 
-	printk(KERN_INFO "%s: %s at %#lx, IRQ %d, %s\n",
+	printk(KERN_INFO "%s: %s at %#lx, IRQ %d, %pM\n",
 	       dev->name, pci_id_tbl[chip_idx].name, ioaddr, dev->irq,
-	       print_mac(mac, dev->dev_addr));
+	       dev->dev_addr);
 
 out:
 	return ret;
--- test-tree.orig/drivers/net/es3210.c	2008-10-25 02:15:04.000000000 +0200
+++ test-tree/drivers/net/es3210.c	2008-10-25 02:15:59.000000000 +0200
@@ -179,7 +179,6 @@ static int __init es_probe1(struct net_d
 {
 	int i, retval;
 	unsigned long eisa_id;
-	DECLARE_MAC_BUF(mac);
 
 	if (!request_region(ioaddr + ES_SA_PROM, ES_IO_EXTENT, "es3210"))
 		return -ENODEV;
@@ -205,14 +204,14 @@ static int __init es_probe1(struct net_d
 	if (dev->dev_addr[0] != ES_ADDR0 ||
 	    dev->dev_addr[1] != ES_ADDR1 ||
 	    dev->dev_addr[2] != ES_ADDR2) {
-		printk("es3210.c: card not found %s (invalid_prefix).\n",
-		       print_mac(mac, dev->dev_addr));
+		printk("es3210.c: card not found %pM (invalid_prefix).\n",
+		       dev->dev_addr);
 		retval = -ENODEV;
 		goto out;
 	}
 
-	printk("es3210.c: ES3210 rev. %ld at %#x, node %s",
-	       eisa_id>>24, ioaddr, print_mac(mac, dev->dev_addr));
+	printk("es3210.c: ES3210 rev. %ld at %#x, node %pM",
+	       eisa_id>>24, ioaddr, dev->dev_addr);
 
 	/* Snarf the interrupt now. */
 	if (dev->irq == 0) {
--- test-tree.orig/drivers/net/ewrk3.c	2008-10-25 02:15:01.000000000 +0200
+++ test-tree/drivers/net/ewrk3.c	2008-10-25 02:15:59.000000000 +0200
@@ -396,7 +396,6 @@ ewrk3_hw_init(struct net_device *dev, u_
 	u_long mem_start, shmem_length;
 	u_char cr, cmr, icr, nicsr, lemac, hard_strapped = 0;
 	u_char eeprom_image[EEPROM_MAX], chksum, eisa_cr = 0;
-	DECLARE_MAC_BUF(mac);
 
 	/*
 	** Stop the EWRK3. Enable the DBR ROM. Disable interrupts and remote boot.
@@ -461,7 +460,7 @@ ewrk3_hw_init(struct net_device *dev, u_
 	if (lemac != LeMAC2)
 		DevicePresent(iobase);	/* need after EWRK3_INIT */
 	status = get_hw_addr(dev, eeprom_image, lemac);
-	printk("%s\n", print_mac(mac, dev->dev_addr));
+	printk("%pM\n", dev->dev_addr);
 
 	if (status) {
 		printk("      which has an EEPROM CRC error.\n");
@@ -646,10 +645,8 @@ static int ewrk3_open(struct net_device 
 			ewrk3_init(dev);
 
 			if (ewrk3_debug > 1) {
-				DECLARE_MAC_BUF(mac);
 				printk("%s: ewrk3 open with irq %d\n", dev->name, dev->irq);
-				printk("  physical address: %s\n",
-				       print_mac(mac, dev->dev_addr));
+				printk("  physical address: %pM\n", dev->dev_addr);
 				if (lp->shmem_length == 0) {
 					printk("  no shared memory, I/O only mode\n");
 				} else {
--- test-tree.orig/drivers/net/fealnx.c	2008-10-25 02:15:04.000000000 +0200
+++ test-tree/drivers/net/fealnx.c	2008-10-25 02:15:59.000000000 +0200
@@ -486,7 +486,6 @@ static int __devinit fealnx_init_one(str
 #else
 	int bar = 1;
 #endif
-	DECLARE_MAC_BUF(mac);
 
 /* when built into the kernel, we only print version if device is found */
 #ifndef MODULE
@@ -665,9 +664,9 @@ static int __devinit fealnx_init_one(str
 	if (err)
 		goto err_out_free_tx;
 
-	printk(KERN_INFO "%s: %s at %p, %s, IRQ %d.\n",
+	printk(KERN_INFO "%s: %s at %p, %pM, IRQ %d.\n",
 	       dev->name, skel_netdrv_tbl[chip_id].chip_name, ioaddr,
-	       print_mac(mac, dev->dev_addr), irq);
+	       dev->dev_addr, irq);
 
 	return 0;
 
--- test-tree.orig/drivers/net/fec.c	2008-10-25 02:15:04.000000000 +0200
+++ test-tree/drivers/net/fec.c	2008-10-25 02:15:59.000000000 +0200
@@ -2562,7 +2562,6 @@ static int __init fec_enet_module_init(v
 {
 	struct net_device *dev;
 	int i, err;
-	DECLARE_MAC_BUF(mac);
 
 	printk("FEC ENET Version 0.2\n");
 
@@ -2581,8 +2580,7 @@ static int __init fec_enet_module_init(v
 			return -EIO;
 		}
 
-		printk("%s: ethernet %s\n",
-		       dev->name, print_mac(mac, dev->dev_addr));
+		printk("%s: ethernet %pM\n", dev->name, dev->dev_addr);
 	}
 	return 0;
 }
--- test-tree.orig/drivers/net/forcedeth.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/forcedeth.c	2008-10-25 02:15:59.000000000 +0200
@@ -5420,7 +5420,6 @@ static int __devinit nv_probe(struct pci
 	u32 powerstate, txreg;
 	u32 phystate_orig = 0, phystate;
 	int phyinitialized = 0;
-	DECLARE_MAC_BUF(mac);
 	static int printed_version;
 
 	if (!printed_version++)
@@ -5653,8 +5652,8 @@ static int __devinit nv_probe(struct pci
 		 * to 01:23:45:67:89:ab
 		 */
 		dev_printk(KERN_ERR, &pci_dev->dev,
-			"Invalid Mac address detected: %s\n",
-		        print_mac(mac, dev->dev_addr));
+			"Invalid Mac address detected: %pM\n",
+		        dev->dev_addr);
 		dev_printk(KERN_ERR, &pci_dev->dev,
 			"Please complain to your hardware vendor. Switching to a random MAC.\n");
 		dev->dev_addr[0] = 0x00;
@@ -5663,8 +5662,8 @@ static int __devinit nv_probe(struct pci
 		get_random_bytes(&dev->dev_addr[3], 3);
 	}
 
-	dprintk(KERN_DEBUG "%s: MAC Address %s\n",
-		pci_name(pci_dev), print_mac(mac, dev->dev_addr));
+	dprintk(KERN_DEBUG "%s: MAC Address %pM\n",
+		pci_name(pci_dev), dev->dev_addr);
 
 	/* set mac address */
 	nv_copy_mac_to_hw(dev);
--- test-tree.orig/drivers/net/gianfar.c	2008-10-25 02:15:00.000000000 +0200
+++ test-tree/drivers/net/gianfar.c	2008-10-25 02:15:59.000000000 +0200
@@ -162,7 +162,6 @@ static int gfar_probe(struct platform_de
 	struct gianfar_platform_data *einfo;
 	struct resource *r;
 	int err = 0, irq;
-	DECLARE_MAC_BUF(mac);
 
 	einfo = (struct gianfar_platform_data *) pdev->dev.platform_data;
 
@@ -364,8 +363,7 @@ static int gfar_probe(struct platform_de
 	gfar_init_sysfs(dev);
 
 	/* Print out the device info */
-	printk(KERN_INFO DEVICE_NAME "%s\n",
-	       dev->name, print_mac(mac, dev->dev_addr));
+	printk(KERN_INFO DEVICE_NAME "%pM\n", dev->name, dev->dev_addr);
 
 	/* Even more device info helps when determining which kernel */
 	/* provided which set of benchmarks. */
--- test-tree.orig/drivers/net/hamachi.c	2008-10-25 02:15:01.000000000 +0200
+++ test-tree/drivers/net/hamachi.c	2008-10-25 02:15:59.000000000 +0200
@@ -582,7 +582,6 @@ static int __devinit hamachi_init_one (s
 	void *ring_space;
 	dma_addr_t ring_dma;
 	int ret = -ENOMEM;
-	DECLARE_MAC_BUF(mac);
 
 /* when built into the kernel, we only print version if device is found */
 #ifndef MODULE
@@ -744,9 +743,9 @@ static int __devinit hamachi_init_one (s
 		goto err_out_unmap_rx;
 	}
 
-	printk(KERN_INFO "%s: %s type %x at %p, %s, IRQ %d.\n",
+	printk(KERN_INFO "%s: %s type %x at %p, %pM, IRQ %d.\n",
 		   dev->name, chip_tbl[chip_id].name, readl(ioaddr + ChipRev),
-		   ioaddr, print_mac(mac, dev->dev_addr), irq);
+		   ioaddr, dev->dev_addr, irq);
 	i = readb(ioaddr + PCIClkMeas);
 	printk(KERN_INFO "%s:  %d-bit %d Mhz PCI bus (%d), Virtual Jumpers "
 		   "%2.2x, LPA %4.4x.\n",
--- test-tree.orig/drivers/net/hamradio/bpqether.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/hamradio/bpqether.c	2008-10-25 02:15:59.000000000 +0200
@@ -441,16 +441,15 @@ static int bpq_seq_show(struct seq_file 
 			 "dev   ether      destination        accept from\n");
 	else {
 		const struct bpqdev *bpqdev = v;
-		DECLARE_MAC_BUF(mac);
 
-		seq_printf(seq, "%-5s %-10s %s  ",
+		seq_printf(seq, "%-5s %-10s %pM  ",
 			bpqdev->axdev->name, bpqdev->ethdev->name,
-			print_mac(mac, bpqdev->dest_addr));
+			bpqdev->dest_addr);
 
 		if (is_multicast_ether_addr(bpqdev->acpt_addr))
 			seq_printf(seq, "*\n");
 		else
-			seq_printf(seq, "%s\n", print_mac(mac, bpqdev->acpt_addr));
+			seq_printf(seq, "%pM\n", bpqdev->acpt_addr);
 
 	}
 	return 0;
--- test-tree.orig/drivers/net/hp-plus.c	2008-10-25 02:15:01.000000000 +0200
+++ test-tree/drivers/net/hp-plus.c	2008-10-25 02:15:59.000000000 +0200
@@ -166,7 +166,6 @@ static int __init hpp_probe1(struct net_
 	const char name[] = "HP-PC-LAN+";
 	int mem_start;
 	static unsigned version_printed;
-	DECLARE_MAC_BUF(mac);
 
 	if (!request_region(ioaddr, HP_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
@@ -193,7 +192,7 @@ static int __init hpp_probe1(struct net_
 	}
 	checksum += inb(ioaddr + 14);
 
-	printk("%s", print_mac(mac, dev->dev_addr));
+	printk("%pM", dev->dev_addr);
 
 	if (checksum != 0xff) {
 		printk(" bad checksum %2.2x.\n", checksum);
--- test-tree.orig/drivers/net/hp.c	2008-10-25 02:15:02.000000000 +0200
+++ test-tree/drivers/net/hp.c	2008-10-25 02:15:59.000000000 +0200
@@ -127,7 +127,6 @@ static int __init hp_probe1(struct net_d
 	int i, retval, board_id, wordmode;
 	const char *name;
 	static unsigned version_printed;
-	DECLARE_MAC_BUF(mac);
 
 	if (!request_region(ioaddr, HP_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
@@ -161,7 +160,7 @@ static int __init hp_probe1(struct net_d
 	for(i = 0; i < ETHER_ADDR_LEN; i++)
 		dev->dev_addr[i] = inb(ioaddr + i);
 
-	printk(" %s", print_mac(mac, dev->dev_addr));
+	printk(" %pM", dev->dev_addr);
 
 	/* Snarf the interrupt now.  Someday this could be moved to open(). */
 	if (dev->irq < 2) {
--- test-tree.orig/drivers/net/hp100.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/hp100.c	2008-10-25 02:15:59.000000000 +0200
@@ -2093,9 +2093,8 @@ static void hp100_set_multicast_list(str
 				addrs = dmi->dmi_addr;
 				if ((*addrs & 0x01) == 0x01) {	/* multicast address? */
 #ifdef HP100_DEBUG
-					DECLARE_MAC_BUF(mac);
-					printk("hp100: %s: multicast = %s, ",
-						     dev->name, print_mac(mac, addrs));
+					printk("hp100: %s: multicast = %pM, ",
+						     dev->name, addrs);
 #endif
 					for (j = idx = 0; j < 6; j++) {
 						idx ^= *addrs++ & 0x3f;
--- test-tree.orig/drivers/net/hydra.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/hydra.c	2008-10-25 02:15:59.000000000 +0200
@@ -103,7 +103,6 @@ static int __devinit hydra_init(struct z
     int start_page, stop_page;
     int j;
     int err;
-    DECLARE_MAC_BUF(mac);
 
     static u32 hydra_offsets[16] = {
 	0x00, 0x02, 0x04, 0x06, 0x08, 0x0a, 0x0c, 0x0e,
@@ -163,8 +162,8 @@ static int __devinit hydra_init(struct z
     zorro_set_drvdata(z, dev);
 
     printk(KERN_INFO "%s: Hydra at 0x%08lx, address "
-	   "%s (hydra.c " HYDRA_VERSION ")\n",
-	   dev->name, z->resource.start, print_mac(mac, dev->dev_addr));
+	   "%pM (hydra.c " HYDRA_VERSION ")\n",
+	   dev->name, z->resource.start, dev->dev_addr);
 
     return 0;
 }
--- test-tree.orig/drivers/net/ibmlana.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/ibmlana.c	2008-10-25 02:15:59.000000000 +0200
@@ -914,7 +914,6 @@ static int __devinit ibmlana_init_one(st
 	int base = 0, irq = 0, iobase = 0, memlen = 0;
 	ibmlana_priv *priv;
 	ibmlana_medium medium;
-	DECLARE_MAC_BUF(mac);
 
 	dev = alloc_etherdev(sizeof(ibmlana_priv));
 	if (!dev)
@@ -990,10 +989,10 @@ static int __devinit ibmlana_init_one(st
 	/* print config */
 
 	printk(KERN_INFO "%s: IRQ %d, I/O %#lx, memory %#lx-%#lx, "
-	       "MAC address %s.\n",
+	       "MAC address %pM.\n",
 	       dev->name, priv->realirq, dev->base_addr,
 	       dev->mem_start, dev->mem_end - 1,
-	       print_mac(mac, dev->dev_addr));
+	       dev->dev_addr);
 	printk(KERN_INFO "%s: %s medium\n", dev->name, MediaNames[priv->medium]);
 
 	/* reset board */
--- test-tree.orig/drivers/net/ibmveth.c	2008-10-25 02:15:00.000000000 +0200
+++ test-tree/drivers/net/ibmveth.c	2008-10-25 02:15:59.000000000 +0200
@@ -1371,13 +1371,12 @@ static int ibmveth_show(struct seq_file 
 	struct ibmveth_adapter *adapter = seq->private;
 	char *current_mac = ((char*) &adapter->netdev->dev_addr);
 	char *firmware_mac = ((char*) &adapter->mac_addr) ;
-	DECLARE_MAC_BUF(mac);
 
 	seq_printf(seq, "%s %s\n\n", ibmveth_driver_string, ibmveth_driver_version);
 
 	seq_printf(seq, "Unit Address:    0x%x\n", adapter->vdev->unit_address);
-	seq_printf(seq, "Current MAC:     %s\n", print_mac(mac, current_mac));
-	seq_printf(seq, "Firmware MAC:    %s\n", print_mac(mac, firmware_mac));
+	seq_printf(seq, "Current MAC:     %pM\n", current_mac);
+	seq_printf(seq, "Firmware MAC:    %pM\n", firmware_mac);
 
 	seq_printf(seq, "\nAdapter Statistics:\n");
 	seq_printf(seq, "  TX:  vio_map_single failres:      %ld\n", adapter->tx_map_failed);
--- test-tree.orig/drivers/net/ioc3-eth.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/ioc3-eth.c	2008-10-25 02:15:59.000000000 +0200
@@ -443,12 +443,9 @@ static void ioc3_get_eaddr_nic(struct io
  */
 static void ioc3_get_eaddr(struct ioc3_private *ip)
 {
-	DECLARE_MAC_BUF(mac);
-
 	ioc3_get_eaddr_nic(ip);
 
-	printk("Ethernet address is %s.\n",
-	       print_mac(mac, priv_netdev(ip)->dev_addr));
+	printk("Ethernet address is %pM.\n", priv_netdev(ip)->dev_addr);
 }
 
 static void __ioc3_set_mac_address(struct net_device *dev)
--- test-tree.orig/drivers/net/isa-skeleton.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/isa-skeleton.c	2008-10-25 02:15:59.000000000 +0200
@@ -192,7 +192,6 @@ static int __init netcard_probe1(struct 
 	static unsigned version_printed;
 	int i;
 	int err = -ENODEV;
-	DECLARE_MAC_BUF(mac);
 
 	/* Grab the region so that no one else tries to probe our ioports. */
 	if (!request_region(ioaddr, NETCARD_IO_EXTENT, cardname))
@@ -220,7 +219,7 @@ static int __init netcard_probe1(struct 
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = inb(ioaddr + i);
 
-	printk("%s", print_mac(mac, dev->dev_addr));
+	printk("%pM", dev->dev_addr);
 
 	err = -EAGAIN;
 #ifdef jumpered_interrupts
--- test-tree.orig/drivers/net/jazzsonic.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/jazzsonic.c	2008-10-25 02:15:59.000000000 +0200
@@ -208,7 +208,6 @@ static int __init jazz_sonic_probe(struc
 	struct sonic_local *lp;
 	struct resource *res;
 	int err = 0;
-	DECLARE_MAC_BUF(mac);
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!res)
@@ -233,8 +232,7 @@ static int __init jazz_sonic_probe(struc
 	if (err)
 		goto out1;
 
-	printk("%s: MAC %s IRQ %d\n",
-	       dev->name, print_mac(mac, dev->dev_addr), dev->irq);
+	printk("%s: MAC %pM IRQ %d\n", dev->name, dev->dev_addr, dev->irq);
 
 	return 0;
 
--- test-tree.orig/drivers/net/lance.c	2008-10-25 02:15:01.000000000 +0200
+++ test-tree/drivers/net/lance.c	2008-10-25 02:15:59.000000000 +0200
@@ -466,7 +466,6 @@ static int __init lance_probe1(struct ne
 	unsigned long flags;
 	int err = -ENOMEM;
 	void __iomem *bios;
-	DECLARE_MAC_BUF(mac);
 
 	/* First we look for special cases.
 	   Check for HP's on-board ethernet by looking for 'HP' in the BIOS.
@@ -529,7 +528,7 @@ static int __init lance_probe1(struct ne
 	   The first six bytes are the station address. */
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = inb(ioaddr + i);
-	printk("%s", print_mac(mac, dev->dev_addr));
+	printk("%pM", dev->dev_addr);
 
 	dev->base_addr = ioaddr;
 	/* Make certain the data structures used by the LANCE are aligned and DMAble. */
--- test-tree.orig/drivers/net/lib82596.c	2008-10-25 02:15:01.000000000 +0200
+++ test-tree/drivers/net/lib82596.c	2008-10-25 02:15:59.000000000 +0200
@@ -1034,12 +1034,8 @@ static int i596_start_xmit(struct sk_buf
 
 static void print_eth(unsigned char *add, char *str)
 {
-	DECLARE_MAC_BUF(mac);
-	DECLARE_MAC_BUF(mac2);
-
-	printk(KERN_DEBUG "i596 0x%p, %s --> %s %02X%02X, %s\n",
-	       add, print_mac(mac, add + 6), print_mac(mac2, add),
-	       add[12], add[13], str);
+	printk(KERN_DEBUG "i596 0x%p, %pM --> %pM %02X%02X, %s\n",
+	       add, add + 6, add, add[12], add[13], str);
 }
 
 static int __devinit i82596_probe(struct net_device *dev)
@@ -1343,7 +1339,6 @@ static void set_multicast_list(struct ne
 	struct i596_private *lp = netdev_priv(dev);
 	struct i596_dma *dma = lp->dma;
 	int config = 0, cnt;
-	DECLARE_MAC_BUF(mac);
 
 	DEB(DEB_MULTI,
 	    printk(KERN_DEBUG
@@ -1407,8 +1402,8 @@ static void set_multicast_list(struct ne
 			if (i596_debug > 1)
 				DEB(DEB_MULTI,
 				    printk(KERN_DEBUG
-					   "%s: Adding address %s\n",
-					   dev->name, print_mac(mac, cp)));
+					   "%s: Adding address %pM\n",
+					   dev->name, cp));
 		}
 		DMA_WBACK_INV(dev, &dma->mc_cmd, sizeof(struct mc_cmd));
 		i596_add_cmd(dev, &cmd->cmd);
--- test-tree.orig/drivers/net/lne390.c	2008-10-25 02:15:01.000000000 +0200
+++ test-tree/drivers/net/lne390.c	2008-10-25 02:15:59.000000000 +0200
@@ -169,7 +169,6 @@ static int __init lne390_probe1(struct n
 {
 	int i, revision, ret;
 	unsigned long eisa_id;
-	DECLARE_MAC_BUF(mac);
 
 	if (inb_p(ioaddr + LNE390_ID_PORT) == 0xff) return -ENODEV;
 
@@ -203,8 +202,8 @@ static int __init lne390_probe1(struct n
 
 	for(i = 0; i < ETHER_ADDR_LEN; i++)
 		dev->dev_addr[i] = inb(ioaddr + LNE390_SA_PROM + i);
-	printk("lne390.c: LNE390%X in EISA slot %d, address %s.\n",
-	       0xa+revision, ioaddr/0x1000, print_mac(mac, dev->dev_addr));
+	printk("lne390.c: LNE390%X in EISA slot %d, address %pM.\n",
+	       0xa+revision, ioaddr/0x1000, dev->dev_addr);
 
 	printk("lne390.c: ");
 
--- test-tree.orig/drivers/net/mac89x0.c	2008-10-25 02:15:04.000000000 +0200
+++ test-tree/drivers/net/mac89x0.c	2008-10-25 02:15:59.000000000 +0200
@@ -181,7 +181,6 @@ struct net_device * __init mac89x0_probe
 	unsigned long ioaddr;
 	unsigned short sig;
 	int err = -ENODEV;
-	DECLARE_MAC_BUF(mac);
 
 	if (!MACH_IS_MAC)
 		return ERR_PTR(-ENODEV);
@@ -279,8 +278,7 @@ struct net_device * __init mac89x0_probe
 
 	/* print the IRQ and ethernet address. */
 
-	printk(" IRQ %d ADDR %s\n",
-	       dev->irq, print_mac(mac, dev->dev_addr));
+	printk(" IRQ %d ADDR %pM\n", dev->irq, dev->dev_addr);
 
 	dev->open		= net_open;
 	dev->stop		= net_close;
--- test-tree.orig/drivers/net/macb.c	2008-10-25 02:15:00.000000000 +0200
+++ test-tree/drivers/net/macb.c	2008-10-25 02:15:59.000000000 +0200
@@ -1104,7 +1104,6 @@ static int __init macb_probe(struct plat
 	unsigned long pclk_hz;
 	u32 config;
 	int err = -ENXIO;
-	DECLARE_MAC_BUF(mac);
 
 	regs = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!regs) {
@@ -1223,10 +1222,8 @@ static int __init macb_probe(struct plat
 
 	platform_set_drvdata(pdev, dev);
 
-	printk(KERN_INFO "%s: Atmel MACB at 0x%08lx irq %d "
-	       "(%s)\n",
-	       dev->name, dev->base_addr, dev->irq,
-	       print_mac(mac, dev->dev_addr));
+	printk(KERN_INFO "%s: Atmel MACB at 0x%08lx irq %d (%pM)\n",
+	       dev->name, dev->base_addr, dev->irq, dev->dev_addr);
 
 	phydev = bp->phy_dev;
 	printk(KERN_INFO "%s: attached PHY driver [%s] "
--- test-tree.orig/drivers/net/mace.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/mace.c	2008-10-25 02:15:59.000000000 +0200
@@ -101,7 +101,6 @@ static int __devinit mace_probe(struct m
 	struct mace_data *mp;
 	const unsigned char *addr;
 	int j, rev, rc = -EBUSY;
-	DECLARE_MAC_BUF(mac);
 
 	if (macio_resource_count(mdev) != 3 || macio_irq_count(mdev) != 3) {
 		printk(KERN_ERR "can't use MACE %s: need 3 addrs and 3 irqs\n",
@@ -241,8 +240,8 @@ static int __devinit mace_probe(struct m
 		goto err_free_rx_irq;
 	}
 
-	printk(KERN_INFO "%s: MACE at %s, chip revision %d.%d\n",
-	       dev->name, print_mac(mac, dev->dev_addr),
+	printk(KERN_INFO "%s: MACE at %pM, chip revision %d.%d\n",
+	       dev->name, dev->dev_addr,
 	       mp->chipid >> 8, mp->chipid & 0xff);
 
 	return 0;
--- test-tree.orig/drivers/net/macmace.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/macmace.c	2008-10-25 02:15:59.000000000 +0200
@@ -194,7 +194,6 @@ static int __devinit mace_probe(struct p
 	unsigned char checksum = 0;
 	static int found = 0;
 	int err;
-	DECLARE_MAC_BUF(mac);
 
 	if (found || macintosh_config->ether_type != MAC_ETHER_MACE)
 		return -ENODEV;
@@ -249,8 +248,8 @@ static int __devinit mace_probe(struct p
 	dev->set_multicast_list	= mace_set_multicast;
 	dev->set_mac_address	= mace_set_address;
 
-	printk(KERN_INFO "%s: 68K MACE, hardware address %s\n",
-	       dev->name, print_mac(mac, dev->dev_addr));
+	printk(KERN_INFO "%s: 68K MACE, hardware address %pM\n",
+	       dev->name, dev->dev_addr);
 
 	err = register_netdev(dev);
 	if (!err)
--- test-tree.orig/drivers/net/macsonic.c	2008-10-25 02:15:04.000000000 +0200
+++ test-tree/drivers/net/macsonic.c	2008-10-25 02:15:59.000000000 +0200
@@ -220,7 +220,6 @@ static int __init mac_onboard_sonic_ethe
 	struct sonic_local *lp = netdev_priv(dev);
 	const int prom_addr = ONBOARD_SONIC_PROM_BASE;
 	int i;
-	DECLARE_MAC_BUF(mac);
 
 	/* On NuBus boards we can sometimes look in the ROM resources.
 	   No such luck for comm-slot/onboard. */
@@ -264,8 +263,8 @@ static int __init mac_onboard_sonic_ethe
 		dev->dev_addr[1] = val >> 8;
 		dev->dev_addr[0] = val & 0xff;
 
-		printk(KERN_INFO "HW Address from CAM 15: %s\n",
-		       print_mac(mac, dev->dev_addr));
+		printk(KERN_INFO "HW Address from CAM 15: %pM\n",
+		       dev->dev_addr);
 	} else return 0;
 
 	if (memcmp(dev->dev_addr, "\x08\x00\x07", 3) &&
@@ -560,7 +559,6 @@ static int __init mac_sonic_probe(struct
 	struct net_device *dev;
 	struct sonic_local *lp;
 	int err;
-	DECLARE_MAC_BUF(mac);
 
 	dev = alloc_etherdev(sizeof(struct sonic_local));
 	if (!dev)
@@ -584,8 +582,7 @@ found:
 	if (err)
 		goto out;
 
-	printk("%s: MAC %s IRQ %d\n",
-	       dev->name, print_mac(mac, dev->dev_addr), dev->irq);
+	printk("%s: MAC %pM IRQ %d\n", dev->name, dev->dev_addr, dev->irq);
 
 	return 0;
 
--- test-tree.orig/drivers/net/meth.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/meth.c	2008-10-25 02:15:59.000000000 +0200
@@ -94,10 +94,9 @@ char o2meth_eaddr[8]={0,0,0,0,0,0,0,0};
 static inline void load_eaddr(struct net_device *dev)
 {
 	int i;
-	DECLARE_MAC_BUF(mac);
 	u64 macaddr;
 
-	DPRINTK("Loading MAC Address: %s\n", print_mac(mac, dev->dev_addr));
+	DPRINTK("Loading MAC Address: %pM\n", dev->dev_addr);
 	macaddr = 0;
 	for (i = 0; i < 6; i++)
 		macaddr |= (u64)dev->dev_addr[i] << ((5 - i) * 8);
--- test-tree.orig/drivers/net/mv643xx_eth.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/mv643xx_eth.c	2008-10-25 02:15:59.000000000 +0200
@@ -2589,7 +2589,6 @@ static int mv643xx_eth_probe(struct plat
 	struct mv643xx_eth_private *mp;
 	struct net_device *dev;
 	struct resource *res;
-	DECLARE_MAC_BUF(mac);
 	int err;
 
 	pd = pdev->dev.platform_data;
@@ -2683,8 +2682,8 @@ static int mv643xx_eth_probe(struct plat
 	if (err)
 		goto out;
 
-	dev_printk(KERN_NOTICE, &dev->dev, "port %d with MAC address %s\n",
-		   mp->port_num, print_mac(mac, dev->dev_addr));
+	dev_printk(KERN_NOTICE, &dev->dev, "port %d with MAC address %pM\n",
+		   mp->port_num, dev->dev_addr);
 
 	if (mp->tx_desc_sram_size > 0)
 		dev_printk(KERN_NOTICE, &dev->dev, "configured with sram\n");
--- test-tree.orig/drivers/net/mvme147.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/mvme147.c	2008-10-25 02:15:59.000000000 +0200
@@ -67,7 +67,6 @@ struct net_device * __init mvme147lance_
 	u_long *addr;
 	u_long address;
 	int err;
-	DECLARE_MAC_BUF(mac);
 
 	if (!MACH_IS_MVME147 || called)
 		return ERR_PTR(-ENODEV);
@@ -102,9 +101,9 @@ struct net_device * __init mvme147lance_
 	dev->dev_addr[3]=address&0xff;
 
 	printk("%s: MVME147 at 0x%08lx, irq %d, "
-	       "Hardware Address %s\n",
+	       "Hardware Address %pM\n",
 	       dev->name, dev->base_addr, MVME147_LANCE_IRQ,
-	       print_mac(mac, dev->dev_addr));
+	       dev->dev_addr);
 
 	lp = (struct m147lance_private *)dev->priv;
 	lp->ram = __get_dma_pages(GFP_ATOMIC, 3);	/* 16K */
--- test-tree.orig/drivers/net/myri10ge/myri10ge.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/myri10ge/myri10ge.c	2008-10-25 02:15:59.000000000 +0200
@@ -2981,7 +2981,6 @@ static void myri10ge_set_multicast_list(
 	struct dev_mc_list *mc_list;
 	__be32 data[2] = { 0, 0 };
 	int err;
-	DECLARE_MAC_BUF(mac);
 
 	/* can be called from atomic contexts,
 	 * pass 1 to force atomicity in myri10ge_send_cmd() */
@@ -3028,8 +3027,7 @@ static void myri10ge_set_multicast_list(
 			printk(KERN_ERR "myri10ge: %s: Failed "
 			       "MXGEFW_JOIN_MULTICAST_GROUP, error status:"
 			       "%d\t", dev->name, err);
-			printk(KERN_ERR "MAC %s\n",
-			       print_mac(mac, mc_list->dmi_addr));
+			printk(KERN_ERR "MAC %pM\n", mc_list->dmi_addr);
 			goto abort;
 		}
 	}
--- test-tree.orig/drivers/net/myri_sbus.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/myri_sbus.c	2008-10-25 02:15:59.000000000 +0200
@@ -318,13 +318,10 @@ static void myri_is_not_so_happy(struct 
 #ifdef DEBUG_HEADER
 static void dump_ehdr(struct ethhdr *ehdr)
 {
-	DECLARE_MAC_BUF(mac);
-	DECLARE_MAC_BUF(mac2);
-	printk("ehdr[h_dst(%s)"
-	       "h_source(%s)"
+	printk("ehdr[h_dst(%pM)"
+	       "h_source(%pM)"
 	       "h_proto(%04x)]\n",
-	       print_mac(mac, ehdr->h_dest), print_mac(mac2, ehdr->h_source),
-	       ehdr->h_proto);
+	       ehdr->h_dest, ehdr->h_source, ehdr->h_proto);
 }
 
 static void dump_ehdr_and_myripad(unsigned char *stuff)
@@ -905,7 +902,6 @@ static int __devinit myri_sbus_probe(str
 	struct device_node *dp = op->node;
 	static unsigned version_printed;
 	struct net_device *dev;
-	DECLARE_MAC_BUF(mac);
 	struct myri_eth *mp;
 	const void *prop;
 	static int num;
@@ -1088,8 +1084,8 @@ static int __devinit myri_sbus_probe(str
 
 	num++;
 
-	printk("%s: MyriCOM MyriNET Ethernet %s\n",
-	       dev->name, print_mac(mac, dev->dev_addr));
+	printk("%s: MyriCOM MyriNET Ethernet %pM\n",
+	       dev->name, dev->dev_addr);
 
 	return 0;
 
--- test-tree.orig/drivers/net/natsemi.c	2008-10-25 02:15:02.000000000 +0200
+++ test-tree/drivers/net/natsemi.c	2008-10-25 02:15:59.000000000 +0200
@@ -792,7 +792,6 @@ static int __devinit natsemi_probe1 (str
 	const int pcibar = 1; /* PCI base address register */
 	int prev_eedata;
 	u32 tmp;
-	DECLARE_MAC_BUF(mac);
 
 /* when built into the kernel, we only print version if device is found */
 #ifndef MODULE
@@ -948,10 +947,10 @@ static int __devinit natsemi_probe1 (str
 
 	if (netif_msg_drv(np)) {
 		printk(KERN_INFO "natsemi %s: %s at %#08llx "
-		       "(%s), %s, IRQ %d",
+		       "(%s), %pM, IRQ %d",
 		       dev->name, natsemi_pci_info[chip_idx].name,
 		       (unsigned long long)iostart, pci_name(np->pci_dev),
-		       print_mac(mac, dev->dev_addr), irq);
+		       dev->dev_addr, irq);
 		if (dev->if_port == PORT_TP)
 			printk(", port TP.\n");
 		else if (np->ignore_phy)
--- test-tree.orig/drivers/net/ne-h8300.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/ne-h8300.c	2008-10-25 02:15:59.000000000 +0200
@@ -204,7 +204,6 @@ static int __init ne_probe1(struct net_d
 	static unsigned version_printed;
 	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
 	unsigned char bus_width;
-	DECLARE_MAC_BUF(mac);
 
 	if (!request_region(ioaddr, NE_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
@@ -299,7 +298,7 @@ static int __init ne_probe1(struct net_d
 
 	for(i = 0; i < ETHER_ADDR_LEN; i++)
 		dev->dev_addr[i] = SA_prom[i];
-	printk(" %s\n", print_mac(mac, dev->dev_addr));
+	printk(" %pM\n", dev->dev_addr);
 
 	printk("%s: %s found at %#x, using IRQ %d.\n",
 		dev->name, name, ioaddr, dev->irq);
--- test-tree.orig/drivers/net/ne.c	2008-10-25 02:15:01.000000000 +0200
+++ test-tree/drivers/net/ne.c	2008-10-25 02:15:59.000000000 +0200
@@ -297,7 +297,6 @@ static int __init ne_probe1(struct net_d
 	int neX000, ctron, copam, bad_card;
 	int reg0, ret;
 	static unsigned version_printed;
-	DECLARE_MAC_BUF(mac);
 
 	if (!request_region(ioaddr, NE_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
@@ -517,7 +516,7 @@ static int __init ne_probe1(struct net_d
 	}
 #endif
 
-	printk("%s\n", print_mac(mac, dev->dev_addr));
+	printk("%pM\n", dev->dev_addr);
 
 	ei_status.name = name;
 	ei_status.tx_start_page = start_page;
--- test-tree.orig/drivers/net/ne2.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/ne2.c	2008-10-25 02:15:59.000000000 +0200
@@ -302,7 +302,6 @@ out:
 static int ne2_procinfo(char *buf, int slot, struct net_device *dev)
 {
 	int len=0;
-	DECLARE_MAC_BUF(mac);
 
 	len += sprintf(buf+len, "The NE/2 Ethernet Adapter\n" );
 	len += sprintf(buf+len, "Driver written by Wim Dumon ");
@@ -313,7 +312,7 @@ static int ne2_procinfo(char *buf, int s
 	len += sprintf(buf+len, "Based on the original NE2000 drivers\n" );
 	len += sprintf(buf+len, "Base IO: %#x\n", (unsigned int)dev->base_addr);
 	len += sprintf(buf+len, "IRQ    : %d\n", dev->irq);
-	len += sprintf(buf+len, "HW addr : %s\n", print_mac(mac, dev->dev_addr));
+	len += sprintf(buf+len, "HW addr : %pM\n", dev->dev_addr);
 
 	return len;
 }
@@ -326,7 +325,6 @@ static int __init ne2_probe1(struct net_
 	const char *name = "NE/2";
 	int start_page, stop_page;
 	static unsigned version_printed;
-	DECLARE_MAC_BUF(mac);
 
 	if (ei_debug && version_printed++ == 0)
 		printk(version);
@@ -469,7 +467,7 @@ static int __init ne2_probe1(struct net_
 	for(i = 0; i < ETHER_ADDR_LEN; i++)
 		dev->dev_addr[i] = SA_prom[i];
 
-	printk(" %s\n", print_mac(mac, dev->dev_addr));
+	printk(" %pM\n", dev->dev_addr);
 
 	printk("%s: %s found at %#x, using IRQ %d.\n",
 			dev->name, name, base_addr, dev->irq);
--- test-tree.orig/drivers/net/ne2k-pci.c	2008-10-25 02:15:02.000000000 +0200
+++ test-tree/drivers/net/ne2k-pci.c	2008-10-25 02:15:59.000000000 +0200
@@ -212,7 +212,6 @@ static int __devinit ne2k_pci_init_one (
 	static unsigned int fnd_cnt;
 	long ioaddr;
 	int flags = pci_clone_list[chip_idx].flags;
-	DECLARE_MAC_BUF(mac);
 
 /* when built into the kernel, we only print version if device is found */
 #ifndef MODULE
@@ -368,9 +367,9 @@ static int __devinit ne2k_pci_init_one (
 
 	for(i = 0; i < 6; i++)
 		dev->dev_addr[i] = SA_prom[i];
-	printk("%s: %s found at %#lx, IRQ %d, %s.\n",
+	printk("%s: %s found at %#lx, IRQ %d, %pM.\n",
 	       dev->name, pci_clone_list[chip_idx].name, ioaddr, dev->irq,
-	       print_mac(mac, dev->dev_addr));
+	       dev->dev_addr);
 
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
--- test-tree.orig/drivers/net/ne3210.c	2008-10-25 02:15:01.000000000 +0200
+++ test-tree/drivers/net/ne3210.c	2008-10-25 02:15:59.000000000 +0200
@@ -99,7 +99,6 @@ static int __init ne3210_eisa_probe (str
 	int i, retval, port_index;
 	struct eisa_device *edev = to_eisa_device (device);
 	struct net_device *dev;
-	DECLARE_MAC_BUF(mac);
 
 	/* Allocate dev->priv and fill in 8390 specific dev fields. */
 	if (!(dev = alloc_ei_netdev ())) {
@@ -131,8 +130,8 @@ static int __init ne3210_eisa_probe (str
 	port_index = inb(ioaddr + NE3210_CFG2) >> 6;
 	for(i = 0; i < ETHER_ADDR_LEN; i++)
 		dev->dev_addr[i] = inb(ioaddr + NE3210_SA_PROM + i);
-	printk("ne3210.c: NE3210 in EISA slot %d, media: %s, addr: %s.\n",
-		edev->slot, ifmap[port_index], print_mac(mac, dev->dev_addr));
+	printk("ne3210.c: NE3210 in EISA slot %d, media: %s, addr: %pM.\n",
+		edev->slot, ifmap[port_index], dev->dev_addr);
 
 	/* Snarf the interrupt now. CFG file has them all listed as `edge' with share=NO */
 	dev->irq = irq_map[(inb(ioaddr + NE3210_CFG2) >> 3) & 0x07];
--- test-tree.orig/drivers/net/netconsole.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/netconsole.c	2008-10-25 02:15:59.000000000 +0200
@@ -307,17 +307,14 @@ static ssize_t show_remote_ip(struct net
 static ssize_t show_local_mac(struct netconsole_target *nt, char *buf)
 {
 	struct net_device *dev = nt->np.dev;
+	static const u8 bcast[ETH_ALEN] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
 
-	DECLARE_MAC_BUF(mac);
-	return snprintf(buf, PAGE_SIZE, "%s\n", dev ?
-			print_mac(mac, dev->dev_addr) : "ff:ff:ff:ff:ff:ff");
+	return snprintf(buf, PAGE_SIZE, "%pM\n", dev ? dev->dev_addr : bcast);
 }
 
 static ssize_t show_remote_mac(struct netconsole_target *nt, char *buf)
 {
-	DECLARE_MAC_BUF(mac);
-	return snprintf(buf, PAGE_SIZE, "%s\n",
-			print_mac(mac, nt->np.remote_mac));
+	return snprintf(buf, PAGE_SIZE, "%pM\n", nt->np.remote_mac);
 }
 
 /*
--- test-tree.orig/drivers/net/netxen/netxen_nic_main.c	2008-10-25 02:15:00.000000000 +0200
+++ test-tree/drivers/net/netxen/netxen_nic_main.c	2008-10-25 02:15:59.000000000 +0200
@@ -439,7 +439,6 @@ netxen_read_mac_addr(struct netxen_adapt
 	int i;
 	unsigned char *p;
 	__le64 mac_addr;
-	DECLARE_MAC_BUF(mac);
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 
@@ -462,10 +461,9 @@ netxen_read_mac_addr(struct netxen_adapt
 
 	/* set station address */
 
-	if (!is_valid_ether_addr(netdev->perm_addr)) {
-		dev_warn(&pdev->dev, "Bad MAC address %s.\n",
-				print_mac(mac, netdev->dev_addr));
-	} else
+	if (!is_valid_ether_addr(netdev->perm_addr))
+		dev_warn(&pdev->dev, "Bad MAC address %pM.\n", netdev->dev_addr);
+	else
 		adapter->macaddr_set(adapter, netdev->dev_addr);
 
 	return 0;
--- test-tree.orig/drivers/net/netxen/netxen_nic_niu.c	2008-10-25 02:15:00.000000000 +0200
+++ test-tree/drivers/net/netxen/netxen_nic_niu.c	2008-10-25 02:15:59.000000000 +0200
@@ -608,7 +608,6 @@ int netxen_niu_macaddr_set(struct netxen
 	int phy = adapter->physical_port;
 	unsigned char mac_addr[6];
 	int i;
-	DECLARE_MAC_BUF(mac);
 
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
 		return 0;
@@ -636,10 +635,8 @@ int netxen_niu_macaddr_set(struct netxen
 	if (i == 10) {
 		printk(KERN_ERR "%s: cannot set Mac addr for %s\n",
 		       netxen_nic_driver_name, adapter->netdev->name);
-		printk(KERN_ERR "MAC address set: %s.\n",
-		       print_mac(mac, addr));
-		printk(KERN_ERR "MAC address get: %s.\n",
-		       print_mac(mac, mac_addr));
+		printk(KERN_ERR "MAC address set: %pM.\n", addr);
+		printk(KERN_ERR "MAC address get: %pM.\n", mac_addr);
 	}
 	return 0;
 }
--- test-tree.orig/drivers/net/ni5010.c	2008-10-25 02:15:02.000000000 +0200
+++ test-tree/drivers/net/ni5010.c	2008-10-25 02:15:59.000000000 +0200
@@ -203,7 +203,6 @@ static int __init ni5010_probe1(struct n
 	unsigned int data = 0;
 	int boguscount = 40;
 	int err = -ENODEV;
-	DECLARE_MAC_BUF(mac);
 
 	dev->base_addr = ioaddr;
 	dev->irq = irq;
@@ -271,7 +270,7 @@ static int __init ni5010_probe1(struct n
 		outw(i, IE_GP);
 		dev->dev_addr[i] = inb(IE_SAPROM);
 	}
-	printk("%s ", print_mac(mac, dev->dev_addr));
+	printk("%pM ", dev->dev_addr);
 
 	PRINTK2((KERN_DEBUG "%s: I/O #4 passed!\n", dev->name));
 
--- test-tree.orig/drivers/net/niu.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/niu.c	2008-10-25 02:15:59.000000000 +0200
@@ -8638,10 +8638,8 @@ static void __devinit niu_assign_netdev_
 static void __devinit niu_device_announce(struct niu *np)
 {
 	struct net_device *dev = np->dev;
-	DECLARE_MAC_BUF(mac);
 
-	pr_info("%s: NIU Ethernet %s\n",
-		dev->name, print_mac(mac, dev->dev_addr));
+	pr_info("%s: NIU Ethernet %pM\n", dev->name, dev->dev_addr);
 
 	if (np->parent->plat_type == PLAT_TYPE_ATCA_CP3220) {
 		pr_info("%s: Port type[%s] mode[%s:%s] XCVR[%s] phy[%s]\n",
--- test-tree.orig/drivers/net/ns83820.c	2008-10-25 02:15:02.000000000 +0200
+++ test-tree/drivers/net/ns83820.c	2008-10-25 02:15:59.000000000 +0200
@@ -1955,7 +1955,6 @@ static int __devinit ns83820_init_one(st
 	long addr;
 	int err;
 	int using_dac = 0;
-	DECLARE_MAC_BUF(mac);
 
 	/* See if we can set the dma mask early on; failure is fatal. */
 	if (sizeof(dma_addr_t) == 8 &&
@@ -2220,12 +2219,11 @@ static int __devinit ns83820_init_one(st
 		ndev->features |= NETIF_F_HIGHDMA;
 	}
 
-	printk(KERN_INFO "%s: ns83820 v" VERSION ": DP83820 v%u.%u: %s io=0x%08lx irq=%d f=%s\n",
+	printk(KERN_INFO "%s: ns83820 v" VERSION ": DP83820 v%u.%u: %pM io=0x%08lx irq=%d f=%s\n",
 		ndev->name,
 		(unsigned)readl(dev->base + SRR) >> 8,
 		(unsigned)readl(dev->base + SRR) & 0xff,
-		print_mac(mac, ndev->dev_addr),
-		addr, pci_dev->irq,
+		ndev->dev_addr, addr, pci_dev->irq,
 		(ndev->features & NETIF_F_HIGHDMA) ? "h,sg" : "sg"
 		);
 
--- test-tree.orig/drivers/net/pasemi_mac.c	2008-10-25 02:15:05.000000000 +0200
+++ test-tree/drivers/net/pasemi_mac.c	2008-10-25 02:15:59.000000000 +0200
@@ -1742,7 +1742,6 @@ pasemi_mac_probe(struct pci_dev *pdev, c
 	struct net_device *dev;
 	struct pasemi_mac *mac;
 	int err;
-	DECLARE_MAC_BUF(mac_buf);
 
 	err = pci_enable_device(pdev);
 	if (err)
@@ -1849,9 +1848,9 @@ pasemi_mac_probe(struct pci_dev *pdev, c
 			err);
 		goto out;
 	} else if netif_msg_probe(mac)
-		printk(KERN_INFO "%s: PA Semi %s: intf %d, hw addr %s\n",
+		printk(KERN_INFO "%s: PA Semi %s: intf %d, hw addr %pM\n",
 		       dev->name, mac->type == MAC_TYPE_GMAC ? "GMAC" : "XAUI",
-		       mac->dma_if, print_mac(mac_buf, dev->dev_addr));
+		       mac->dma_if, dev->dev_addr);
 
 	return err;
 
--- test-tree.orig/drivers/net/pci-skeleton.c	2008-10-25 02:15:01.000000000 +0200
+++ test-tree/drivers/net/pci-skeleton.c	2008-10-25 02:15:59.000000000 +0200
@@ -737,7 +737,6 @@ static int __devinit netdrv_init_one (st
 	int i, addr_len, option;
 	void *ioaddr = NULL;
 	static int board_idx = -1;
-	DECLARE_MAC_BUF(mac);
 
 /* when built into the kernel, we only print version if device is found */
 #ifndef MODULE
@@ -797,11 +796,11 @@ static int __devinit netdrv_init_one (st
 
 	tp->phys[0] = 32;
 
-	printk (KERN_INFO "%s: %s at 0x%lx, %sIRQ %d\n",
+	printk (KERN_INFO "%s: %s at 0x%lx, %pM IRQ %d\n",
 		dev->name,
 		board_info[ent->driver_data].name,
 		dev->base_addr,
-		print_mac(mac, dev->dev_addr),
+		dev->dev_addr,
 		dev->irq);
 
 	printk (KERN_DEBUG "%s:  Identified 8139 chip type '%s'\n",
--- test-tree.orig/drivers/net/pcmcia/3c574_cs.c	2008-10-25 02:15:04.000000000 +0200
+++ test-tree/drivers/net/pcmcia/3c574_cs.c	2008-10-25 02:15:59.000000000 +0200
@@ -345,7 +345,6 @@ static int tc574_config(struct pcmcia_de
 	__be16 *phys_addr;
 	char *cardname;
 	__u32 config;
-	DECLARE_MAC_BUF(mac);
 
 	phys_addr = (__be16 *)dev->dev_addr;
 
@@ -463,9 +462,9 @@ static int tc574_config(struct pcmcia_de
 	strcpy(lp->node.dev_name, dev->name);
 
 	printk(KERN_INFO "%s: %s at io %#3lx, irq %d, "
-	       "hw_addr %s.\n",
+	       "hw_addr %pM.\n",
 	       dev->name, cardname, dev->base_addr, dev->irq,
-	       print_mac(mac, dev->dev_addr));
+	       dev->dev_addr);
 	printk(" %dK FIFO split %s Rx:Tx, %sMII interface.\n",
 		   8 << config & Ram_size,
 		   ram_split[(config & Ram_split) >> Ram_split_shift],
--- test-tree.orig/drivers/net/pcmcia/3c589_cs.c	2008-10-25 02:15:04.000000000 +0200
+++ test-tree/drivers/net/pcmcia/3c589_cs.c	2008-10-25 02:15:59.000000000 +0200
@@ -255,7 +255,6 @@ static int tc589_config(struct pcmcia_de
     int last_fn, last_ret, i, j, multi = 0, fifo;
     unsigned int ioaddr;
     char *ram_split[] = {"5:3", "3:1", "1:1", "3:5"};
-    DECLARE_MAC_BUF(mac);
     
     DEBUG(0, "3c589_config(0x%p)\n", link);
 
@@ -333,9 +332,9 @@ static int tc589_config(struct pcmcia_de
     strcpy(lp->node.dev_name, dev->name);
 
     printk(KERN_INFO "%s: 3Com 3c%s, io %#3lx, irq %d, "
-	   "hw_addr %s\n",
+	   "hw_addr %pM\n",
 	   dev->name, (multi ? "562" : "589"), dev->base_addr, dev->irq,
-	   print_mac(mac, dev->dev_addr));
+	   dev->dev_addr);
     printk(KERN_INFO "  %dK FIFO split %s Rx:Tx, %s xcvr\n",
 	   (fifo & 7) ? 32 : 8, ram_split[(fifo >> 16) & 3],
 	   if_names[dev->if_port]);
--- test-tree.orig/drivers/net/pcmcia/axnet_cs.c	2008-10-25 02:15:04.000000000 +0200
+++ test-tree/drivers/net/pcmcia/axnet_cs.c	2008-10-25 02:15:59.000000000 +0200
@@ -321,7 +321,6 @@ static int axnet_config(struct pcmcia_de
     struct net_device *dev = link->priv;
     axnet_dev_t *info = PRIV(dev);
     int i, j, last_ret, last_fn;
-    DECLARE_MAC_BUF(mac);
 
     DEBUG(0, "axnet_config(0x%p)\n", link);
 
@@ -397,10 +396,10 @@ static int axnet_config(struct pcmcia_de
     strcpy(info->node.dev_name, dev->name);
 
     printk(KERN_INFO "%s: Asix AX88%d90: io %#3lx, irq %d, "
-	   "hw_addr %s\n",
+	   "hw_addr %pM\n",
 	   dev->name, ((info->flags & IS_AX88790) ? 7 : 1),
 	   dev->base_addr, dev->irq,
-	   print_mac(mac, dev->dev_addr));
+	   dev->dev_addr);
     if (info->phy_id != -1) {
 	DEBUG(0, "  MII transceiver at index %d, status %x.\n", info->phy_id, j);
     } else {
--- test-tree.orig/drivers/net/pcmcia/fmvj18x_cs.c	2008-10-25 02:15:04.000000000 +0200
+++ test-tree/drivers/net/pcmcia/fmvj18x_cs.c	2008-10-25 02:15:59.000000000 +0200
@@ -348,7 +348,6 @@ static int fmvj18x_config(struct pcmcia_
     cardtype_t cardtype;
     char *card_name = "unknown";
     u_char *node_id;
-    DECLARE_MAC_BUF(mac);
 
     DEBUG(0, "fmvj18x_config(0x%p)\n", link);
 
@@ -539,9 +538,9 @@ static int fmvj18x_config(struct pcmcia_
 
     /* print current configuration */
     printk(KERN_INFO "%s: %s, sram %s, port %#3lx, irq %d, "
-	   "hw_addr %s\n",
+	   "hw_addr %pM\n",
 	   dev->name, card_name, sram_config == 0 ? "4K TX*2" : "8K TX*2", 
-	   dev->base_addr, dev->irq, print_mac(mac, dev->dev_addr));
+	   dev->base_addr, dev->irq, dev->dev_addr);
 
     return 0;
     
--- test-tree.orig/drivers/net/pcmcia/nmclan_cs.c	2008-10-25 02:15:04.000000000 +0200
+++ test-tree/drivers/net/pcmcia/nmclan_cs.c	2008-10-25 02:15:59.000000000 +0200
@@ -659,7 +659,6 @@ static int nmclan_config(struct pcmcia_d
   u_char buf[64];
   int i, last_ret, last_fn;
   unsigned int ioaddr;
-  DECLARE_MAC_BUF(mac);
 
   DEBUG(0, "nmclan_config(0x%p)\n", link);
 
@@ -719,9 +718,9 @@ static int nmclan_config(struct pcmcia_d
   strcpy(lp->node.dev_name, dev->name);
 
   printk(KERN_INFO "%s: nmclan: port %#3lx, irq %d, %s port,"
-	 " hw_addr %s\n",
+	 " hw_addr %pM\n",
 	 dev->name, dev->base_addr, dev->irq, if_names[dev->if_port],
-	 print_mac(mac, dev->dev_addr));
+	 dev->dev_addr);
   return 0;
 
 cs_failed:
--- test-tree.orig/drivers/net/pcmcia/pcnet_cs.c	2008-10-25 02:15:04.000000000 +0200
+++ test-tree/drivers/net/pcmcia/pcnet_cs.c	2008-10-25 02:15:59.000000000 +0200
@@ -554,7 +554,6 @@ static int pcnet_config(struct pcmcia_de
     int last_ret, last_fn, start_pg, stop_pg, cm_offset;
     int has_shmem = 0;
     hw_info_t *local_hw_info;
-    DECLARE_MAC_BUF(mac);
 
     DEBUG(0, "pcnet_config(0x%p)\n", link);
 
@@ -675,7 +674,7 @@ static int pcnet_config(struct pcmcia_de
 	printk (" mem %#5lx,", dev->mem_start);
     if (info->flags & HAS_MISC_REG)
 	printk(" %s xcvr,", if_names[dev->if_port]);
-    printk(" hw_addr %s\n", print_mac(mac, dev->dev_addr));
+    printk(" hw_addr %pM\n", dev->dev_addr);
     return 0;
 
 cs_failed:
--- test-tree.orig/drivers/net/pcmcia/smc91c92_cs.c	2008-10-25 02:15:04.000000000 +0200
+++ test-tree/drivers/net/pcmcia/smc91c92_cs.c	2008-10-25 02:15:59.000000000 +0200
@@ -949,7 +949,6 @@ static int smc91c92_config(struct pcmcia
     int i, j, rev;
     unsigned int ioaddr;
     u_long mir;
-    DECLARE_MAC_BUF(mac);
 
     DEBUG(0, "smc91c92_config(0x%p)\n", link);
 
@@ -1062,9 +1061,9 @@ static int smc91c92_config(struct pcmcia
     strcpy(smc->node.dev_name, dev->name);
 
     printk(KERN_INFO "%s: smc91c%s rev %d: io %#3lx, irq %d, "
-	   "hw_addr %s\n",
+	   "hw_addr %pM\n",
 	   dev->name, name, (rev & 0x0f), dev->base_addr, dev->irq,
-	   print_mac(mac, dev->dev_addr));
+	   dev->dev_addr);
 
     if (rev > 0) {
 	if (mir & 0x3ff)
--- test-tree.orig/drivers/net/pcmcia/xirc2ps_cs.c	2008-10-25 02:15:04.000000000 +0200
+++ test-tree/drivers/net/pcmcia/xirc2ps_cs.c	2008-10-25 02:15:59.000000000 +0200
@@ -772,7 +772,6 @@ xirc2ps_config(struct pcmcia_device * li
     int err, i;
     u_char buf[64];
     cistpl_lan_node_id_t *node_id = (cistpl_lan_node_id_t*)parse.funce.data;
-    DECLARE_MAC_BUF(mac);
 
     local->dingo_ccr = NULL;
 
@@ -1051,9 +1050,9 @@ xirc2ps_config(struct pcmcia_device * li
     strcpy(local->node.dev_name, dev->name);
 
     /* give some infos about the hardware */
-    printk(KERN_INFO "%s: %s: port %#3lx, irq %d, hwaddr %s\n",
+    printk(KERN_INFO "%s: %s: port %#3lx, irq %d, hwaddr %pM\n",
 	   dev->name, local->manf_str,(u_long)dev->base_addr, (int)dev->irq,
-	   print_mac(mac, dev->dev_addr));
+	   dev->dev_addr);
 
     return 0;
 
--- test-tree.orig/drivers/net/pcnet32.c	2008-10-25 02:15:01.000000000 +0200
+++ test-tree/drivers/net/pcnet32.c	2008-10-25 02:15:59.000000000 +0200
@@ -1747,8 +1747,7 @@ pcnet32_probe1(unsigned long ioaddr, int
 		memset(dev->dev_addr, 0, sizeof(dev->dev_addr));
 
 	if (pcnet32_debug & NETIF_MSG_PROBE) {
-		DECLARE_MAC_BUF(mac);
-		printk(" %s", print_mac(mac, dev->dev_addr));
+		printk(" %pM", dev->dev_addr);
 
 		/* Version 0x2623 and 0x2624 */
 		if (((chip_version + 1) & 0xfffe) == 0x2624) {
--- test-tree.orig/drivers/net/pppoe.c	2008-10-25 02:15:01.000000000 +0200
+++ test-tree/drivers/net/pppoe.c	2008-10-25 02:15:59.000000000 +0200
@@ -958,7 +958,6 @@ static int pppoe_seq_show(struct seq_fil
 {
 	struct pppox_sock *po;
 	char *dev_name;
-	DECLARE_MAC_BUF(mac);
 
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq, "Id       Address              Device\n");
@@ -968,8 +967,8 @@ static int pppoe_seq_show(struct seq_fil
 	po = v;
 	dev_name = po->pppoe_pa.dev;
 
-	seq_printf(seq, "%08X %s %8s\n",
-		   po->pppoe_pa.sid, print_mac(mac, po->pppoe_pa.remote), dev_name);
+	seq_printf(seq, "%08X %pM %8s\n",
+		   po->pppoe_pa.sid, po->pppoe_pa.remote, dev_name);
 out:
 	return 0;
 }
--- test-tree.orig/drivers/net/ps3_gelic_net.c	2008-10-25 02:15:04.000000000 +0200
+++ test-tree/drivers/net/ps3_gelic_net.c	2008-10-25 02:15:59.000000000 +0200
@@ -1443,7 +1443,6 @@ int gelic_net_setup_netdev(struct net_de
 {
 	int status;
 	u64 v1, v2;
-	DECLARE_MAC_BUF(mac);
 
 	netdev->features = NETIF_F_IP_CSUM;
 
@@ -1474,9 +1473,8 @@ int gelic_net_setup_netdev(struct net_de
 			__func__, netdev->name, status);
 		return status;
 	}
-	dev_info(ctodev(card), "%s: MAC addr %s\n",
-		 netdev->name,
-		 print_mac(mac, netdev->dev_addr));
+	dev_info(ctodev(card), "%s: MAC addr %pM\n",
+		 netdev->name, netdev->dev_addr);
 
 	return 0;
 }
--- test-tree.orig/drivers/net/ps3_gelic_wireless.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/ps3_gelic_wireless.c	2008-10-25 02:15:59.000000000 +0200
@@ -763,7 +763,6 @@ static void scan_list_dump(struct gelic_
 {
 	struct gelic_wl_scan_info *scan_info;
 	int i;
-	DECLARE_MAC_BUF(mac);
 
 	i = 0;
 	list_for_each_entry(scan_info, &wl->network_list, list) {
@@ -775,8 +774,7 @@ static void scan_list_dump(struct gelic_
 			 scan_info->rate_len, scan_info->rate_ext_len,
 			 scan_info->essid_len);
 		/* -- */
-		pr_debug("bssid=%s\n",
-			 print_mac(mac, &scan_info->hwinfo->bssid[2]));
+		pr_debug("bssid=%pM\n", &scan_info->hwinfo->bssid[2]);
 		pr_debug("essid=%s\n", scan_info->hwinfo->essid);
 	}
 }
@@ -1632,7 +1630,6 @@ static void gelic_wl_scan_complete_event
 	unsigned long this_time = jiffies;
 	unsigned int data_len, i, found, r;
 	void *buf;
-	DECLARE_MAC_BUF(mac);
 
 	pr_debug("%s:start\n", __func__);
 	mutex_lock(&wl->scan_lock);
@@ -1684,9 +1681,9 @@ static void gelic_wl_scan_complete_event
 	     scan_info_size < data_len;
 	     i++, scan_info_size += be16_to_cpu(scan_info->size),
 	     scan_info = (void *)scan_info + be16_to_cpu(scan_info->size)) {
-		pr_debug("%s:size=%d bssid=%s scan_info=%p\n", __func__,
+		pr_debug("%s:size=%d bssid=%pM scan_info=%p\n", __func__,
 			 be16_to_cpu(scan_info->size),
-			 print_mac(mac, &scan_info->bssid[2]), scan_info);
+			 &scan_info->bssid[2], scan_info);
 
 		/*
 		 * The wireless firmware may return invalid channel 0 and/or
@@ -1787,7 +1784,6 @@ struct gelic_wl_scan_info *gelic_wl_find
 	struct gelic_wl_scan_info *best_bss;
 	int weight, best_weight;
 	u16 security;
-	DECLARE_MAC_BUF(mac);
 
 	pr_debug("%s: <-\n", __func__);
 
@@ -1857,8 +1853,8 @@ struct gelic_wl_scan_info *gelic_wl_find
 #ifdef DEBUG
 	pr_debug("%s: -> bss=%p\n", __func__, best_bss);
 	if (best_bss) {
-		pr_debug("%s:addr=%s\n", __func__,
-			 print_mac(mac, &best_bss->hwinfo->bssid[2]));
+		pr_debug("%s:addr=%pM\n", __func__,
+			 &best_bss->hwinfo->bssid[2]);
 	}
 #endif
 	return best_bss;
--- test-tree.orig/drivers/net/qla3xxx.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/qla3xxx.c	2008-10-25 02:15:59.000000000 +0200
@@ -3529,7 +3529,6 @@ static void ql_display_dev_info(struct n
 {
 	struct ql3_adapter *qdev = (struct ql3_adapter *)netdev_priv(ndev);
 	struct pci_dev *pdev = qdev->pdev;
-	DECLARE_MAC_BUF(mac);
 
 	printk(KERN_INFO PFX
 	       "\n%s Adapter %d RevisionID %d found %s on PCI slot %d.\n",
@@ -3555,8 +3554,8 @@ static void ql_display_dev_info(struct n
 
 	if (netif_msg_probe(qdev))
 		printk(KERN_INFO PFX
-		       "%s: MAC address %s\n",
-		       ndev->name, print_mac(mac, ndev->dev_addr));
+		       "%s: MAC address %pM\n",
+		       ndev->name, ndev->dev_addr);
 }
 
 static int ql_adapter_down(struct ql3_adapter *qdev, int do_reset)
--- test-tree.orig/drivers/net/rionet.c	2008-10-25 02:15:01.000000000 +0200
+++ test-tree/drivers/net/rionet.c	2008-10-25 02:15:59.000000000 +0200
@@ -435,7 +435,6 @@ static int rionet_setup_netdev(struct ri
 	struct net_device *ndev = NULL;
 	struct rionet_private *rnet;
 	u16 device_id;
-	DECLARE_MAC_BUF(mac);
 
 	/* Allocate our net_device structure */
 	ndev = alloc_etherdev(sizeof(struct rionet_private));
@@ -485,12 +484,12 @@ static int rionet_setup_netdev(struct ri
 	if (rc != 0)
 		goto out;
 
-	printk("%s: %s %s Version %s, MAC %s\n",
+	printk("%s: %s %s Version %s, MAC %pM\n",
 	       ndev->name,
 	       DRV_NAME,
 	       DRV_DESC,
 	       DRV_VERSION,
-	       print_mac(mac, ndev->dev_addr));
+	       ndev->dev_addr);
 
       out:
 	return rc;
--- test-tree.orig/drivers/net/rrunner.c	2008-10-25 02:15:02.000000000 +0200
+++ test-tree/drivers/net/rrunner.c	2008-10-25 02:15:59.000000000 +0200
@@ -511,7 +511,6 @@ static int __devinit rr_init(struct net_
 	struct rr_private *rrpriv;
 	struct rr_regs __iomem *regs;
 	u32 sram_size, rev;
-	DECLARE_MAC_BUF(mac);
 
 	rrpriv = netdev_priv(dev);
 	regs = rrpriv->regs;
@@ -549,7 +548,7 @@ static int __devinit rr_init(struct net_
 	*(__be32 *)(dev->dev_addr+2) =
 	  htonl(rr_read_eeprom_word(rrpriv, offsetof(struct eeprom, manf.BoardULA[4])));
 
-	printk("  MAC: %s\n", print_mac(mac, dev->dev_addr));
+	printk("  MAC: %pM\n", dev->dev_addr);
 
 	sram_size = rr_read_eeprom_word(rrpriv, 8);
 	printk("  SRAM size 0x%06x\n", sram_size);
--- test-tree.orig/drivers/net/s2io.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/s2io.c	2008-10-25 02:15:59.000000000 +0200
@@ -7748,7 +7748,6 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	int mode;
 	u8 dev_intr_type = intr_type;
 	u8 dev_multiq = 0;
-	DECLARE_MAC_BUF(mac);
 
 	ret = s2io_verify_parm(pdev, &dev_intr_type, &dev_multiq);
 	if (ret)
@@ -8125,8 +8124,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		  sp->product_name, pdev->revision);
 	DBG_PRINT(ERR_DBG, "%s: Driver version %s\n", dev->name,
 		  s2io_driver_version);
-	DBG_PRINT(ERR_DBG, "%s: MAC ADDR: %s\n",
-		  dev->name, print_mac(mac, dev->dev_addr));
+	DBG_PRINT(ERR_DBG, "%s: MAC ADDR: %pM\n", dev->name, dev->dev_addr);
 	DBG_PRINT(ERR_DBG, "SERIAL NUMBER: %s\n", sp->serial_num);
 	if (sp->device_type & XFRAME_II_DEVICE) {
 		mode = s2io_print_pci_mode(sp);
--- test-tree.orig/drivers/net/sb1250-mac.c	2008-10-25 02:15:00.000000000 +0200
+++ test-tree/drivers/net/sb1250-mac.c	2008-10-25 02:15:59.000000000 +0200
@@ -2292,7 +2292,6 @@ static int sbmac_init(struct platform_de
 	uint64_t ea_reg;
 	int i;
 	int err;
-	DECLARE_MAC_BUF(mac);
 
 	sc->sbm_dev = dev;
 	sc->sbe_idx = idx;
@@ -2373,8 +2372,8 @@ static int sbmac_init(struct platform_de
 	 * process so we need to finish off the config message that
 	 * was being displayed)
 	 */
-	pr_info("%s: SiByte Ethernet at 0x%08Lx, address: %s\n",
-	       dev->name, base, print_mac(mac, eaddr));
+	pr_info("%s: SiByte Ethernet at 0x%08Lx, address: %pM\n",
+	       dev->name, base, eaddr);
 
 	sc->mii_bus->name = sbmac_mdio_string;
 	snprintf(sc->mii_bus->id, MII_BUS_ID_SIZE, "%x", idx);
--- test-tree.orig/drivers/net/seeq8005.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/seeq8005.c	2008-10-25 02:15:59.000000000 +0200
@@ -158,7 +158,6 @@ static int __init seeq8005_probe1(struct
 	int old_dmaar;
 	int old_rear;
 	int retval;
-	DECLARE_MAC_BUF(mac);
 
 	if (!request_region(ioaddr, SEEQ8005_IO_EXTENT, "seeq8005"))
 		return -ENODEV;
@@ -303,7 +302,7 @@ static int __init seeq8005_probe1(struct
 	/* Retrieve and print the ethernet address. */
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = SA_prom[i+6];
-	printk("%s", print_mac(mac, dev->dev_addr));
+	printk("%pM", dev->dev_addr);
 
 	if (dev->irq == 0xff)
 		;			/* Do nothing: a user-level program will set it. */
--- test-tree.orig/drivers/net/sfc/efx.c	2008-10-25 02:15:02.000000000 +0200
+++ test-tree/drivers/net/sfc/efx.c	2008-10-25 02:15:59.000000000 +0200
@@ -612,17 +612,15 @@ static int efx_probe_port(struct efx_nic
 	if (is_valid_ether_addr(efx->mac_address)) {
 		memcpy(efx->net_dev->dev_addr, efx->mac_address, ETH_ALEN);
 	} else {
-		DECLARE_MAC_BUF(mac);
-
-		EFX_ERR(efx, "invalid MAC address %s\n",
-			print_mac(mac, efx->mac_address));
+		EFX_ERR(efx, "invalid MAC address %pM\n",
+			efx->mac_address);
 		if (!allow_bad_hwaddr) {
 			rc = -EINVAL;
 			goto err;
 		}
 		random_ether_addr(efx->net_dev->dev_addr);
-		EFX_INFO(efx, "using locally-generated MAC %s\n",
-			 print_mac(mac, efx->net_dev->dev_addr));
+		EFX_INFO(efx, "using locally-generated MAC %pM\n",
+			 efx->net_dev->dev_addr);
 	}
 
 	return 0;
@@ -1401,9 +1399,8 @@ static int efx_set_mac_address(struct ne
 	EFX_ASSERT_RESET_SERIALISED(efx);
 
 	if (!is_valid_ether_addr(new_addr)) {
-		DECLARE_MAC_BUF(mac);
-		EFX_ERR(efx, "invalid ethernet MAC address requested: %s\n",
-			print_mac(mac, new_addr));
+		EFX_ERR(efx, "invalid ethernet MAC address requested: %pM\n",
+			new_addr);
 		return -EINVAL;
 	}
 
--- test-tree.orig/drivers/net/sgiseeq.c	2008-10-25 02:15:01.000000000 +0200
+++ test-tree/drivers/net/sgiseeq.c	2008-10-25 02:15:59.000000000 +0200
@@ -719,7 +719,6 @@ static int __init sgiseeq_probe(struct p
 	struct sgiseeq_private *sp;
 	struct net_device *dev;
 	int err;
-	DECLARE_MAC_BUF(mac);
 
 	dev = alloc_etherdev(sizeof (struct sgiseeq_private));
 	if (!dev) {
@@ -793,8 +792,7 @@ static int __init sgiseeq_probe(struct p
 		goto err_out_free_page;
 	}
 
-	printk(KERN_INFO "%s: %s %s\n",
-	       dev->name, sgiseeqstr, print_mac(mac, dev->dev_addr));
+	printk(KERN_INFO "%s: %s %pM\n", dev->name, sgiseeqstr, dev->dev_addr);
 
 	return 0;
 
--- test-tree.orig/drivers/net/sis190.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/sis190.c	2008-10-25 02:15:59.000000000 +0200
@@ -1791,7 +1791,6 @@ static int __devinit sis190_init_one(str
 	struct net_device *dev;
 	void __iomem *ioaddr;
 	int rc;
-	DECLARE_MAC_BUF(mac);
 
 	if (!printed_version) {
 		net_drv(&debug, KERN_INFO SIS190_DRIVER_NAME " loaded.\n");
@@ -1841,10 +1840,9 @@ static int __devinit sis190_init_one(str
 	if (rc < 0)
 		goto err_remove_mii;
 
-	net_probe(tp, KERN_INFO "%s: %s at %p (IRQ: %d), "
-		  "%s\n",
+	net_probe(tp, KERN_INFO "%s: %s at %p (IRQ: %d), %pM\n",
 		  pci_name(pdev), sis_chip_info[ent->driver_data].name,
-		  ioaddr, dev->irq, print_mac(mac, dev->dev_addr));
+		  ioaddr, dev->irq, dev->dev_addr);
 
 	net_probe(tp, KERN_INFO "%s: %s mode.\n", dev->name,
 		  (tp->features & F_HAS_RGMII) ? "RGMII" : "GMII");
--- test-tree.orig/drivers/net/sis900.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/sis900.c	2008-10-25 02:15:59.000000000 +0200
@@ -404,7 +404,6 @@ static int __devinit sis900_probe(struct
 	int i, ret;
 	const char *card_name = card_names[pci_id->driver_data];
 	const char *dev_name = pci_name(pci_dev);
-	DECLARE_MAC_BUF(mac);
 
 /* when built into the kernel, we only print version if device is found */
 #ifndef MODULE
@@ -534,9 +533,9 @@ static int __devinit sis900_probe(struct
 		goto err_unmap_rx;
 
 	/* print some information about our NIC */
-	printk(KERN_INFO "%s: %s at %#lx, IRQ %d, %s\n",
+	printk(KERN_INFO "%s: %s at %#lx, IRQ %d, %pM\n",
 	       net_dev->name, card_name, ioaddr, net_dev->irq,
-	       print_mac(mac, net_dev->dev_addr));
+	       net_dev->dev_addr);
 
 	/* Detect Wake on Lan support */
 	ret = (inl(net_dev->base_addr + CFGPMC) & PMESP) >> 27;
--- test-tree.orig/drivers/net/skge.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/skge.c	2008-10-25 02:15:59.000000000 +0200
@@ -3885,11 +3885,10 @@ static struct net_device *skge_devinit(s
 static void __devinit skge_show_addr(struct net_device *dev)
 {
 	const struct skge_port *skge = netdev_priv(dev);
-	DECLARE_MAC_BUF(mac);
 
 	if (netif_msg_probe(skge))
-		printk(KERN_INFO PFX "%s: addr %s\n",
-		       dev->name, print_mac(mac, dev->dev_addr));
+		printk(KERN_INFO PFX "%s: addr %pM\n",
+		       dev->name, dev->dev_addr);
 }
 
 static int __devinit skge_probe(struct pci_dev *pdev,
--- test-tree.orig/drivers/net/sky2.c	2008-10-25 02:15:02.000000000 +0200
+++ test-tree/drivers/net/sky2.c	2008-10-25 02:15:59.000000000 +0200
@@ -4118,11 +4118,10 @@ static __devinit struct net_device *sky2
 static void __devinit sky2_show_addr(struct net_device *dev)
 {
 	const struct sky2_port *sky2 = netdev_priv(dev);
-	DECLARE_MAC_BUF(mac);
 
 	if (netif_msg_probe(sky2))
-		printk(KERN_INFO PFX "%s: addr %s\n",
-		       dev->name, print_mac(mac, dev->dev_addr));
+		printk(KERN_INFO PFX "%s: addr %pM\n",
+		       dev->name, dev->dev_addr);
 }
 
 /* Handle software interrupt used during MSI test */
--- test-tree.orig/drivers/net/smc-mca.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/smc-mca.c	2008-10-25 02:15:59.000000000 +0200
@@ -196,7 +196,6 @@ static int __init ultramca_probe(struct 
 	int tirq = 0;
 	int base_addr = ultra_io[ultra_found];
 	int irq = ultra_irq[ultra_found];
-	DECLARE_MAC_BUF(mac);
 
 	if (base_addr || irq) {
 		printk(KERN_INFO "Probing for SMC MCA adapter");
@@ -334,8 +333,8 @@ static int __init ultramca_probe(struct 
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = inb(ioaddr + 8 + i);
 
-	printk(KERN_INFO "smc_mca[%d]: Parameters: %#3x, %s",
-	       slot + 1, ioaddr, print_mac(mac, dev->dev_addr));
+	printk(KERN_INFO "smc_mca[%d]: Parameters: %#3x, %pM",
+	       slot + 1, ioaddr, dev->dev_addr);
 
 	/* Switch from the station address to the alternate register set
 	 * and read the useful registers there.
--- test-tree.orig/drivers/net/smc-ultra.c	2008-10-25 02:15:02.000000000 +0200
+++ test-tree/drivers/net/smc-ultra.c	2008-10-25 02:15:59.000000000 +0200
@@ -198,7 +198,6 @@ static int __init ultra_probe1(struct ne
 	unsigned char num_pages, irqreg, addr, piomode;
 	unsigned char idreg = inb(ioaddr + 7);
 	unsigned char reg4 = inb(ioaddr + 4) & 0x7f;
-	DECLARE_MAC_BUF(mac);
 
 	if (!request_region(ioaddr, ULTRA_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
@@ -228,8 +227,8 @@ static int __init ultra_probe1(struct ne
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = inb(ioaddr + 8 + i);
 
-	printk("%s: %s at %#3x, %s", dev->name, model_name,
-	       ioaddr, print_mac(mac, dev->dev_addr));
+	printk("%s: %s at %#3x, %pM", dev->name, model_name,
+	       ioaddr, dev->dev_addr);
 
 	/* Switch from the station address to the alternate register set and
 	   read the useful registers there. */
--- test-tree.orig/drivers/net/smc-ultra32.c	2008-10-25 02:15:05.000000000 +0200
+++ test-tree/drivers/net/smc-ultra32.c	2008-10-25 02:15:59.000000000 +0200
@@ -163,7 +163,6 @@ static int __init ultra32_probe1(struct 
 	unsigned char idreg;
 	unsigned char reg4;
 	const char *ifmap[] = {"UTP No Link", "", "UTP/AUI", "UTP/BNC"};
-	DECLARE_MAC_BUF(mac);
 
 	if (!request_region(ioaddr, ULTRA32_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
@@ -207,8 +206,8 @@ static int __init ultra32_probe1(struct 
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = inb(ioaddr + 8 + i);
 
-	printk("%s: %s at 0x%X, %s",
-	       dev->name, model_name, ioaddr, print_mac(mac, dev->dev_addr));
+	printk("%s: %s at 0x%X, %pM",
+	       dev->name, model_name, ioaddr, dev->dev_addr);
 
 	/* Switch from the station address to the alternate register set and
 	   read the useful registers there. */
--- test-tree.orig/drivers/net/smc9194.c	2008-10-25 02:15:02.000000000 +0200
+++ test-tree/drivers/net/smc9194.c	2008-10-25 02:15:59.000000000 +0200
@@ -876,8 +876,6 @@ static int __init smc_probe(struct net_d
 	word memory_info_register;
 	word memory_cfg_register;
 
-	DECLARE_MAC_BUF(mac);
-
 	/* Grab the region so that no one else tries to probe our ioports. */
 	if (!request_region(ioaddr, SMC_IO_EXTENT, DRV_NAME))
 		return -EBUSY;
@@ -1033,7 +1031,7 @@ static int __init smc_probe(struct net_d
 	/*
 	 . Print the Ethernet address
 	*/
-	printk("ADDR: %s\n", print_mac(mac, dev->dev_addr));
+	printk("ADDR: %pM\n", dev->dev_addr);
 
 	/* set the private data to zero by default */
 	memset(dev->priv, 0, sizeof(struct smc_local));
--- test-tree.orig/drivers/net/smc91x.c	2008-10-25 02:15:01.000000000 +0200
+++ test-tree/drivers/net/smc91x.c	2008-10-25 02:15:59.000000000 +0200
@@ -1778,7 +1778,6 @@ static int __init smc_probe(struct net_d
 	int retval;
 	unsigned int val, revision_register;
 	const char *version_string;
-	DECLARE_MAC_BUF(mac);
 
 	DBG(2, "%s: %s\n", CARDNAME, __func__);
 
@@ -1972,8 +1971,8 @@ static int __init smc_probe(struct net_d
 			       "set using ifconfig\n", dev->name);
 		} else {
 			/* Print the Ethernet address */
-			printk("%s: Ethernet addr: %s\n",
-			       dev->name, print_mac(mac, dev->dev_addr));
+			printk("%s: Ethernet addr: %pM\n",
+			       dev->name, dev->dev_addr);
 		}
 
 		if (lp->phy_type == 0) {
--- test-tree.orig/drivers/net/sun3lance.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/sun3lance.c	2008-10-25 02:15:59.000000000 +0200
@@ -303,7 +303,6 @@ static int __init lance_probe( struct ne
 	static int 		did_version;
 	volatile unsigned short *ioaddr_probe;
 	unsigned short tmp1, tmp2;
-	DECLARE_MAC_BUF(mac);
 
 #ifdef CONFIG_SUN3
 	ioaddr = (unsigned long)ioremap(LANCE_OBIO, PAGE_SIZE);
@@ -379,7 +378,7 @@ static int __init lance_probe( struct ne
 	MEM->init.hwaddr[4] = dev->dev_addr[5];
 	MEM->init.hwaddr[5] = dev->dev_addr[4];
 
-	printk("%s\n", print_mac(mac, dev->dev_addr));
+	printk("%pM\n", dev->dev_addr);
 
 	MEM->init.mode = 0x0000;
 	MEM->init.filter[0] = 0x00000000;
@@ -824,12 +823,10 @@ static int lance_rx( struct net_device *
 #if 0
 				if (lance_debug >= 3) {
 					u_char *data = PKTBUF_ADDR(head);
-					DECLARE_MAC_BUF(mac);
-					DECLARE_MAC_BUF(mac2)
 					printk("%s: RX pkt %d type 0x%04x"
-					       " from %s to %s",
+					       " from %pM to %pM",
 					       dev->name, lp->new_tx, ((u_short *)data)[6],
-					       print_mac(mac, &data[6]), print_mac(mac2, data));
+					       &data[6], data);
 
 					printk(" data %02x %02x %02x %02x %02x %02x %02x %02x "
 					       "len %d at %08x\n",
--- test-tree.orig/drivers/net/sunbmac.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/sunbmac.c	2008-10-25 02:15:59.000000000 +0200
@@ -1081,7 +1081,6 @@ static int __devinit bigmac_ether_init(s
 	static int version_printed;
 	struct net_device *dev;
 	u8 bsizes, bsizes_more;
-	DECLARE_MAC_BUF(mac);
 	struct bigmac *bp;
 	int i;
 
@@ -1212,8 +1211,8 @@ static int __devinit bigmac_ether_init(s
 
 	dev_set_drvdata(&bp->bigmac_op->dev, bp);
 
-	printk(KERN_INFO "%s: BigMAC 100baseT Ethernet %s\n",
-	       dev->name, print_mac(mac, dev->dev_addr));
+	printk(KERN_INFO "%s: BigMAC 100baseT Ethernet %pM\n",
+	       dev->name, dev->dev_addr);
 
 	return 0;
 
--- test-tree.orig/drivers/net/sundance.c	2008-10-25 02:15:01.000000000 +0200
+++ test-tree/drivers/net/sundance.c	2008-10-25 02:15:59.000000000 +0200
@@ -468,7 +468,6 @@ static int __devinit sundance_probe1 (st
 	int bar = 1;
 #endif
 	int phy, phy_end, phy_idx = 0;
-	DECLARE_MAC_BUF(mac);
 
 /* when built into the kernel, we only print version if device is found */
 #ifndef MODULE
@@ -547,9 +546,9 @@ static int __devinit sundance_probe1 (st
 	if (i)
 		goto err_out_unmap_rx;
 
-	printk(KERN_INFO "%s: %s at %p, %s, IRQ %d.\n",
+	printk(KERN_INFO "%s: %s at %p, %pM, IRQ %d.\n",
 	       dev->name, pci_id_tbl[chip_idx].name, ioaddr,
-	       print_mac(mac, dev->dev_addr), irq);
+	       dev->dev_addr, irq);
 
 	np->phys[0] = 1;		/* Default setting */
 	np->mii_preamble_required++;
--- test-tree.orig/drivers/net/sungem.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/sungem.c	2008-10-25 02:15:59.000000000 +0200
@@ -2966,7 +2966,6 @@ static int __devinit gem_init_one(struct
 	struct net_device *dev;
 	struct gem *gp;
 	int err, pci_using_dac;
-	DECLARE_MAC_BUF(mac);
 
 	if (gem_version_printed++ == 0)
 		printk(KERN_INFO "%s", version);
@@ -3150,9 +3149,8 @@ static int __devinit gem_init_one(struct
 		goto err_out_free_consistent;
 	}
 
-	printk(KERN_INFO "%s: Sun GEM (PCI) 10/100/1000BaseT Ethernet "
-	       "%s\n",
-	       dev->name, print_mac(mac, dev->dev_addr));
+	printk(KERN_INFO "%s: Sun GEM (PCI) 10/100/1000BaseT Ethernet %pM\n",
+	       dev->name, dev->dev_addr);
 
 	if (gp->phy_type == phy_mii_mdio0 ||
      	    gp->phy_type == phy_mii_mdio1)
--- test-tree.orig/drivers/net/sunhme.c	2008-10-25 02:15:02.000000000 +0200
+++ test-tree/drivers/net/sunhme.c	2008-10-25 02:15:59.000000000 +0200
@@ -2617,7 +2617,6 @@ static int __devinit happy_meal_sbus_pro
 	struct net_device *dev;
 	int i, qfe_slot = -1;
 	int err = -ENODEV;
-	DECLARE_MAC_BUF(mac);
 
 	if (is_qfe) {
 		qp = quattro_sbus_find(op);
@@ -2797,7 +2796,7 @@ static int __devinit happy_meal_sbus_pro
 		printk(KERN_INFO "%s: HAPPY MEAL (SBUS) 10/100baseT Ethernet ",
 		       dev->name);
 
-	printk("%s\n", print_mac(mac, dev->dev_addr));
+	printk("%pM\n", dev->dev_addr);
 
 	return 0;
 
@@ -2932,7 +2931,6 @@ static int __devinit happy_meal_pci_prob
 	int i, qfe_slot = -1;
 	char prom_name[64];
 	int err;
-	DECLARE_MAC_BUF(mac);
 
 	/* Now make sure pci_dev cookie is there. */
 #ifdef CONFIG_SPARC
@@ -3141,7 +3139,7 @@ static int __devinit happy_meal_pci_prob
 		printk(KERN_INFO "%s: HAPPY MEAL (PCI/CheerIO) 10/100BaseT Ethernet ",
 		       dev->name);
 
-	printk("%s\n", print_mac(mac, dev->dev_addr));
+	printk("%pM\n", dev->dev_addr);
 
 	return 0;
 
--- test-tree.orig/drivers/net/sunlance.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/sunlance.c	2008-10-25 02:15:59.000000000 +0200
@@ -1321,7 +1321,6 @@ static int __devinit sparc_lance_probe_o
 	static unsigned version_printed;
 	struct lance_private *lp;
 	struct net_device *dev;
-	DECLARE_MAC_BUF(mac);
 	int    i;
 
 	dev = alloc_etherdev(sizeof(struct lance_private) + 8);
@@ -1491,8 +1490,8 @@ no_link_test:
 
 	dev_set_drvdata(&op->dev, lp);
 
-	printk(KERN_INFO "%s: LANCE %s\n",
-	       dev->name, print_mac(mac, dev->dev_addr));
+	printk(KERN_INFO "%s: LANCE %pM\n",
+	       dev->name, dev->dev_addr);
 
 	return 0;
 
--- test-tree.orig/drivers/net/sunvnet.c	2008-10-25 02:15:00.000000000 +0200
+++ test-tree/drivers/net/sunvnet.c	2008-10-25 02:15:59.000000000 +0200
@@ -1149,7 +1149,6 @@ static int __devinit vnet_port_probe(str
 	struct vnet *vp;
 	const u64 *rmac;
 	int len, i, err, switch_port;
-	DECLARE_MAC_BUF(mac);
 
 	print_version();
 
@@ -1214,8 +1213,8 @@ static int __devinit vnet_port_probe(str
 
 	dev_set_drvdata(&vdev->dev, port);
 
-	printk(KERN_INFO "%s: PORT ( remote-mac %s%s )\n",
-	       vp->dev->name, print_mac(mac, port->raddr),
+	printk(KERN_INFO "%s: PORT ( remote-mac %pM%s )\n",
+	       vp->dev->name, port->raddr,
 	       switch_port ? " switch-port" : "");
 
 	vio_port_up(&port->vio);
--- test-tree.orig/drivers/net/tc35815.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/tc35815.c	2008-10-25 02:15:59.000000000 +0200
@@ -865,7 +865,6 @@ static int __devinit tc35815_init_one(st
 	struct net_device *dev;
 	struct tc35815_local *lp;
 	int rc;
-	DECLARE_MAC_BUF(mac);
 
 	static int printed_version;
 	if (!printed_version++) {
@@ -942,11 +941,11 @@ static int __devinit tc35815_init_one(st
 		goto err_out;
 
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
-	printk(KERN_INFO "%s: %s at 0x%lx, %s, IRQ %d\n",
+	printk(KERN_INFO "%s: %s at 0x%lx, %pM, IRQ %d\n",
 		dev->name,
 		chip_info[ent->driver_data].name,
 		dev->base_addr,
-		print_mac(mac, dev->dev_addr),
+		dev->dev_addr,
 		dev->irq);
 
 	rc = tc_mii_init(dev);
@@ -1288,12 +1287,9 @@ panic_queues(struct net_device *dev)
 
 static void print_eth(const u8 *add)
 {
-	DECLARE_MAC_BUF(mac);
-
 	printk(KERN_DEBUG "print_eth(%p)\n", add);
-	printk(KERN_DEBUG " %s =>", print_mac(mac, add + 6));
-	printk(KERN_CONT " %s : %02x%02x\n",
-		print_mac(mac, add), add[12], add[13]);
+	printk(KERN_DEBUG " %pM => %pM : %02x%02x\n",
+		add + 6, add, add[12], add[13]);
 }
 
 static int tc35815_tx_full(struct net_device *dev)
@@ -2153,13 +2149,12 @@ static void tc35815_set_cam_entry(struct
 	int cam_index = index * 6;
 	u32 cam_data;
 	u32 saved_addr;
-	DECLARE_MAC_BUF(mac);
 
 	saved_addr = tc_readl(&tr->CAM_Adr);
 
 	if (netif_msg_hw(lp))
-		printk(KERN_DEBUG "%s: CAM %d: %s\n",
-			dev->name, index, print_mac(mac, addr));
+		printk(KERN_DEBUG "%s: CAM %d: %pM\n",
+			dev->name, index, addr);
 	if (index & 1) {
 		/* read modify write */
 		tc_writel(cam_index - 2, &tr->CAM_Adr);
--- test-tree.orig/drivers/net/tg3.c	2008-10-25 02:15:05.000000000 +0200
+++ test-tree/drivers/net/tg3.c	2008-10-25 02:16:00.000000000 +0200
@@ -13252,7 +13252,6 @@ static int __devinit tg3_init_one(struct
 	int err, pm_cap;
 	char str[40];
 	u64 dma_mask, persist_dma_mask;
-	DECLARE_MAC_BUF(mac);
 
 	if (tg3_version_printed++ == 0)
 		printk(KERN_INFO "%s", version);
@@ -13536,7 +13535,7 @@ static int __devinit tg3_init_one(struct
 	}
 
 	printk(KERN_INFO "%s: Tigon3 [partno(%s) rev %04x PHY(%s)] "
-	       "(%s) %s Ethernet %s\n",
+	       "(%s) %s Ethernet %pM\n",
 	       dev->name,
 	       tp->board_part_number,
 	       tp->pci_chip_rev_id,
@@ -13545,7 +13544,7 @@ static int __devinit tg3_init_one(struct
 	       ((tp->tg3_flags & TG3_FLAG_10_100_ONLY) ? "10/100Base-TX" :
 		((tp->tg3_flags2 & TG3_FLG2_ANY_SERDES) ? "1000Base-SX" :
 		 "10/100/1000Base-T")),
-	       print_mac(mac, dev->dev_addr));
+	       dev->dev_addr);
 
 	printk(KERN_INFO "%s: RXcsums[%d] LinkChgREG[%d] "
 	       "MIirq[%d] ASF[%d] WireSpeed[%d] TSOcap[%d]\n",
--- test-tree.orig/drivers/net/tokenring/abyss.c	2008-10-25 02:15:02.000000000 +0200
+++ test-tree/drivers/net/tokenring/abyss.c	2008-10-25 02:16:00.000000000 +0200
@@ -99,7 +99,6 @@ static int __devinit abyss_attach(struct
 	struct net_local *tp;
 	int ret, pci_irq_line;
 	unsigned long pci_ioaddr;
-	DECLARE_MAC_BUF(mac);
 	
 	if (versionprinted++ == 0)
 		printk("%s", version);
@@ -147,8 +146,7 @@ static int __devinit abyss_attach(struct
 
 	abyss_read_eeprom(dev);
 
-	printk("%s:    Ring Station Address: %s\n",
-	       dev->name, print_mac(mac, dev->dev_addr));
+	printk("%s:    Ring Station Address: %pM\n", dev->name, dev->dev_addr);
 
 	tp = netdev_priv(dev);
 	tp->setnselout = abyss_setnselout_pins;
--- test-tree.orig/drivers/net/tokenring/ibmtr.c	2008-10-25 02:15:02.000000000 +0200
+++ test-tree/drivers/net/tokenring/ibmtr.c	2008-10-25 02:16:00.000000000 +0200
@@ -389,7 +389,6 @@ static int __devinit ibmtr_probe1(struct
         unsigned long timeout;
 	static int version_printed;
 #endif
-	DECLARE_MAC_BUF(mac);
 
 	/*    Query the adapter PIO base port which will return
 	 *    indication of where MMIO was placed. We also have a
@@ -703,8 +702,7 @@ static int __devinit ibmtr_probe1(struct
 		channel_def[cardpresent - 1], adapter_def(ti->adapter_type));
 	DPRINTK("using irq %d, PIOaddr %hx, %dK shared RAM.\n",
 			irq, PIOaddr, ti->mapped_ram_size / 2);
-	DPRINTK("Hardware address : %s\n",
-		print_mac(mac, dev->dev_addr));
+	DPRINTK("Hardware address : %pM\n", dev->dev_addr);
 	if (ti->page_mask)
 		DPRINTK("Shared RAM paging enabled. "
 			"Page size: %uK Shared Ram size %dK\n",
@@ -1741,8 +1739,6 @@ static void tr_rx(struct net_device *dev
 		void __iomem *trhhdr = rbuf + offsetof(struct rec_buf, data);
 		u8 saddr[6];
 		u8 daddr[6];
-		DECLARE_MAC_BUF(mac);
-		DECLARE_MAC_BUF(mac2);
 		int i;
 		for (i = 0 ; i < 6 ; i++)
 			saddr[i] = readb(trhhdr + SADDR_OFST + i);
@@ -1750,9 +1746,9 @@ static void tr_rx(struct net_device *dev
 			daddr[i] = readb(trhhdr + DADDR_OFST + i);
 		DPRINTK("Probably non-IP frame received.\n");
 		DPRINTK("ssap: %02X dsap: %02X "
-			"saddr: %s daddr: %$s\n",
+			"saddr: %pM daddr: %pM\n",
 			readb(llc + SSAP_OFST), readb(llc + DSAP_OFST),
-			print_mac(mac, saddr), print_mac(mac2, daddr));
+			saddr, daddr);
 	}
 #endif
 
--- test-tree.orig/drivers/net/tokenring/lanstreamer.c	2008-10-25 02:15:02.000000000 +0200
+++ test-tree/drivers/net/tokenring/lanstreamer.c	2008-10-25 02:16:00.000000000 +0200
@@ -446,9 +446,6 @@ static int streamer_reset(struct net_dev
 	unsigned int uaa_addr;
 	struct sk_buff *skb = NULL;
 	__u16 misr;
-#if STREAMER_DEBUG
-	DECLARE_MAC_BUF(mac);
-#endif
 
 	streamer_priv = netdev_priv(dev);
 	streamer_mmio = streamer_priv->streamer_mmio;
@@ -577,8 +574,7 @@ static int streamer_reset(struct net_dev
 			dev->dev_addr[i+1]= addr & 0xff;
 		}
 #if STREAMER_DEBUG
-		printk("Adapter address: %s\n",
-		       print_mac(mac, dev->dev_addr));
+		printk("Adapter address: %pM\n", dev->dev_addr);
 #endif
 	}
 	return 0;
@@ -1538,7 +1534,6 @@ static void streamer_arb_cmd(struct net_
 
 #if STREAMER_NETWORK_MONITOR
 	struct trh_hdr *mac_hdr;
-	DECLARE_MAC_BUF(mac);
 #endif
 
 	writew(streamer_priv->arb, streamer_mmio + LAPA);
@@ -1611,11 +1606,11 @@ static void streamer_arb_cmd(struct net_
 		       dev->name);
 		mac_hdr = tr_hdr(mac_frame);
 		printk(KERN_WARNING
-		       "%s: MAC Frame Dest. Addr: %s\n",
-		       dev->name, print_mac(mac, mac_hdr->daddr));
+		       "%s: MAC Frame Dest. Addr: %pM\n",
+		       dev->name, mac_hdr->daddr);
 		printk(KERN_WARNING
-		       "%s: MAC Frame Srce. Addr: %s\n",
-		       dev->name, DEV->ADDR6(mac_hdr->saddr));
+		       "%s: MAC Frame Srce. Addr: %pM\n",
+		       dev->name, mac_hdr->saddr);
 #endif
 		netif_rx(mac_frame);
 
@@ -1850,8 +1845,6 @@ static int sprintf_info(char *buffer, st
 	struct streamer_parameters_table spt;
 	int size = 0;
 	int i;
-	DECLARE_MAC_BUF(mac);
-	DECLARE_MAC_BUF(mac2);
 
 	writew(streamer_priv->streamer_addr_table_addr, streamer_mmio + LAPA);
 	for (i = 0; i < 14; i += 2) {
@@ -1873,9 +1866,8 @@ static int sprintf_info(char *buffer, st
 	size = sprintf(buffer, "\n%6s: Adapter Address   : Node Address      : Functional Addr\n", dev->name);
 
 	size += sprintf(buffer + size,
-			"%6s: %s : %s : %02x:%02x:%02x:%02x\n",
-			dev->name, print_mac(mac, dev->dev_addr),
-			print_mac(mac2, sat.node_addr),
+			"%6s: %pM : %pM : %02x:%02x:%02x:%02x\n",
+			dev->name, dev->dev_addr, sat.node_addr,
 			sat.func_addr[0], sat.func_addr[1],
 			sat.func_addr[2], sat.func_addr[3]);
 
@@ -1884,19 +1876,18 @@ static int sprintf_info(char *buffer, st
 	size += sprintf(buffer + size, "%6s: Physical Addr : Up Node Address   : Poll Address      : AccPri : Auth Src : Att Code :\n", dev->name);
 
 	size += sprintf(buffer + size,
-		    "%6s: %02x:%02x:%02x:%02x   : %s : %s : %04x   : %04x     :  %04x    :\n",
+		    "%6s: %02x:%02x:%02x:%02x   : %pM : %pM : %04x   : %04x     :  %04x    :\n",
 		    dev->name, spt.phys_addr[0], spt.phys_addr[1],
 		    spt.phys_addr[2], spt.phys_addr[3],
-		    print_mac(mac, spt.up_node_addr),
-		    print_mac(mac2, spt.poll_addr),
+		    spt.up_node_addr, spt.poll_addr,
 		    ntohs(spt.acc_priority), ntohs(spt.auth_source_class),
 		    ntohs(spt.att_code));
 
 	size += sprintf(buffer + size, "%6s: Source Address    : Bcn T : Maj. V : Lan St : Lcl Rg : Mon Err : Frame Correl : \n", dev->name);
 
 	size += sprintf(buffer + size,
-		    "%6s: %s : %04x  : %04x   : %04x   : %04x   : %04x    :     %04x     : \n",
-		    dev->name, print_mac(mac, spt.source_addr),
+		    "%6s: %pM : %04x  : %04x   : %04x   : %04x   : %04x    :     %04x     : \n",
+		    dev->name, spt.source_addr,
 		    ntohs(spt.beacon_type), ntohs(spt.major_vector),
 		    ntohs(spt.lan_status), ntohs(spt.local_ring),
 		    ntohs(spt.mon_error), ntohs(spt.frame_correl));
@@ -1905,10 +1896,10 @@ static int sprintf_info(char *buffer, st
 		    dev->name);
 
 	size += sprintf(buffer + size,
-		    "%6s:                :  %02x  :  %02x  : %s : %02x:%02x:%02x:%02x    : \n",
+		    "%6s:                :  %02x  :  %02x  : %pM : %02x:%02x:%02x:%02x    : \n",
 		    dev->name, ntohs(spt.beacon_transmit),
 		    ntohs(spt.beacon_receive),
-		    print_mac(mac, spt.beacon_naun),
+		    spt.beacon_naun,
 		    spt.beacon_phys[0], spt.beacon_phys[1],
 		    spt.beacon_phys[2], spt.beacon_phys[3]);
 	return size;
--- test-tree.orig/drivers/net/tokenring/madgemc.c	2008-10-25 02:15:02.000000000 +0200
+++ test-tree/drivers/net/tokenring/madgemc.c	2008-10-25 02:16:00.000000000 +0200
@@ -152,7 +152,6 @@ static int __devinit madgemc_probe(struc
 	struct card_info *card;
 	struct mca_device *mdev = to_mca_device(device);
 	int ret = 0;
-	DECLARE_MAC_BUF(mac);
 
 	if (versionprinted++ == 0)
 		printk("%s", version);
@@ -323,8 +322,8 @@ static int __devinit madgemc_probe(struc
 	mca_device_set_name(mdev, (card->cardtype == 0x08)?MADGEMC16_CARDNAME:MADGEMC32_CARDNAME);
 	mca_set_adapter_procfn(mdev->slot, madgemc_mcaproc, dev);
 
-	printk("%s:     Ring Station Address: %s\n",
-	       dev->name, print_mac(mac, dev->dev_addr));
+	printk("%s:     Ring Station Address: %pM\n",
+	       dev->name, dev->dev_addr);
 
 	if (tmsdev_init(dev, device)) {
 		printk("%s: unable to get memory for dev->priv.\n", 
@@ -690,7 +689,6 @@ static int madgemc_mcaproc(char *buf, in
 	struct net_local *tp = netdev_priv(dev);
 	struct card_info *curcard = tp->tmspriv;
 	int len = 0;
-	DECLARE_MAC_BUF(mac);
 	
 	len += sprintf(buf+len, "-------\n");
 	if (curcard) {
@@ -714,8 +712,8 @@ static int madgemc_mcaproc(char *buf, in
 		}
 		len += sprintf(buf+len, " (%s)\n", (curcard->fairness)?"Unfair":"Fair");
 		
-		len += sprintf(buf+len, "Ring Station Address: %s\n",
-			       print_mac(mac, dev->dev_addr));
+		len += sprintf(buf+len, "Ring Station Address: %pM\n",
+			       dev->dev_addr);
 	} else 
 		len += sprintf(buf+len, "Card not configured\n");
 
--- test-tree.orig/drivers/net/tokenring/proteon.c	2008-10-25 02:15:02.000000000 +0200
+++ test-tree/drivers/net/tokenring/proteon.c	2008-10-25 02:16:00.000000000 +0200
@@ -122,7 +122,6 @@ static int __init setup_card(struct net_
         static int versionprinted;
 	const unsigned *port;
 	int j,err = 0;
-	DECLARE_MAC_BUF(mac);
 
 	if (!dev)
 		return -ENOMEM;
@@ -153,8 +152,8 @@ static int __init setup_card(struct net_
 		
 	proteon_read_eeprom(dev);
 
-	printk(KERN_DEBUG "proteon.c:    Ring Station Address: %s\n",
-	       print_mac(mac, dev->dev_addr));
+	printk(KERN_DEBUG "proteon.c:    Ring Station Address: %pM\n",
+	       dev->dev_addr);
 		
 	tp = netdev_priv(dev);
 	tp->setnselout = proteon_setnselout_pins;
--- test-tree.orig/drivers/net/tokenring/skisa.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/tokenring/skisa.c	2008-10-25 02:16:00.000000000 +0200
@@ -139,7 +139,6 @@ static int __init setup_card(struct net_
         static int versionprinted;
 	const unsigned *port;
 	int j, err = 0;
-	DECLARE_MAC_BUF(mac);
 
 	if (!dev)
 		return -ENOMEM;
@@ -170,8 +169,8 @@ static int __init setup_card(struct net_
 		
 	sk_isa_read_eeprom(dev);
 
-	printk(KERN_DEBUG "skisa.c:    Ring Station Address: %s\n",
-	       print_mac(mac, dev->dev_addr));
+	printk(KERN_DEBUG "skisa.c:    Ring Station Address: %pM\n",
+	       dev->dev_addr);
 		
 	tp = netdev_priv(dev);
 	tp->setnselout = sk_isa_setnselout_pins;
--- test-tree.orig/drivers/net/tokenring/tmspci.c	2008-10-25 02:15:02.000000000 +0200
+++ test-tree/drivers/net/tokenring/tmspci.c	2008-10-25 02:16:00.000000000 +0200
@@ -100,7 +100,6 @@ static int __devinit tms_pci_attach(stru
 	unsigned int pci_irq_line;
 	unsigned long pci_ioaddr;
 	struct card_info *cardinfo = &card_info_table[ent->driver_data];
-	DECLARE_MAC_BUF(mac);
 
 	if (versionprinted++ == 0)
 		printk("%s", version);
@@ -137,8 +136,8 @@ static int __devinit tms_pci_attach(stru
 		
 	tms_pci_read_eeprom(dev);
 
-	printk("%s:    Ring Station Address: %s\n",
-	       dev->name, print_mac(mac, dev->dev_addr));
+	printk("%s:    Ring Station Address: %pM\n",
+	       dev->name, dev->dev_addr);
 		
 	ret = tmsdev_init(dev, &pdev->dev);
 	if (ret) {
--- test-tree.orig/drivers/net/tsi108_eth.c	2008-10-25 02:15:05.000000000 +0200
+++ test-tree/drivers/net/tsi108_eth.c	2008-10-25 02:16:00.000000000 +0200
@@ -1569,7 +1569,6 @@ tsi108_init_one(struct platform_device *
 	struct tsi108_prv_data *data = NULL;
 	hw_info *einfo;
 	int err = 0;
-	DECLARE_MAC_BUF(mac);
 
 	einfo = pdev->dev.platform_data;
 
@@ -1659,8 +1658,8 @@ tsi108_init_one(struct platform_device *
 	}
 
 	platform_set_drvdata(pdev, dev);
-	printk(KERN_INFO "%s: Tsi108 Gigabit Ethernet, MAC: %s\n",
-	       dev->name, print_mac(mac, dev->dev_addr));
+	printk(KERN_INFO "%s: Tsi108 Gigabit Ethernet, MAC: %pM\n",
+	       dev->name, dev->dev_addr);
 #ifdef DEBUG
 	data->msg_enable = DEBUG;
 	dump_eth_one(dev);
--- test-tree.orig/drivers/net/tulip/de2104x.c	2008-10-25 02:15:00.000000000 +0200
+++ test-tree/drivers/net/tulip/de2104x.c	2008-10-25 02:16:00.000000000 +0200
@@ -1932,7 +1932,6 @@ static int __devinit de_init_one (struct
 	void __iomem *regs;
 	unsigned long pciaddr;
 	static int board_idx = -1;
-	DECLARE_MAC_BUF(mac);
 
 	board_idx++;
 
@@ -2046,11 +2045,11 @@ static int __devinit de_init_one (struct
 		goto err_out_iomap;
 
 	/* print info about board and interface just registered */
-	printk (KERN_INFO "%s: %s at 0x%lx, %s, IRQ %d\n",
+	printk (KERN_INFO "%s: %s at 0x%lx, %pM, IRQ %d\n",
 		dev->name,
 		de->de21040 ? "21040" : "21041",
 		dev->base_addr,
-		print_mac(mac, dev->dev_addr),
+		dev->dev_addr,
 		dev->irq);
 
 	pci_set_drvdata(pdev, dev);
--- test-tree.orig/drivers/net/tulip/de4x5.c	2008-10-25 02:15:00.000000000 +0200
+++ test-tree/drivers/net/tulip/de4x5.c	2008-10-25 02:16:00.000000000 +0200
@@ -1085,7 +1085,6 @@ de4x5_hw_init(struct net_device *dev, u_
     struct de4x5_private *lp = netdev_priv(dev);
     struct pci_dev *pdev = NULL;
     int i, status=0;
-    DECLARE_MAC_BUF(mac);
 
     gendev->driver_data = dev;
 
@@ -1122,7 +1121,7 @@ de4x5_hw_init(struct net_device *dev, u_
     printk ("%s: %s at 0x%04lx", gendev->bus_id, name, iobase);
 
     status = get_hw_addr(dev);
-    printk(", h/w address %s\n", print_mac(mac, dev->dev_addr));
+    printk(", h/w address %pM\n", dev->dev_addr);
 
     if (status != 0) {
 	printk("      which has an Ethernet PROM CRC error.\n");
@@ -5401,7 +5400,6 @@ static void
 de4x5_dbg_srom(struct de4x5_srom *p)
 {
     int i;
-    DECLARE_MAC_BUF(mac);
 
     if (de4x5_debug & DEBUG_SROM) {
 	printk("Sub-system Vendor ID: %04x\n", *((u_short *)p->sub_vendor_id));
@@ -5410,7 +5408,7 @@ de4x5_dbg_srom(struct de4x5_srom *p)
 	printk("SROM version:         %02x\n", (u_char)(p->version));
 	printk("# controllers:        %02x\n", (u_char)(p->num_controllers));
 
-	printk("Hardware Address:     %s\n", print_mac(mac, p->ieee_addr));
+	printk("Hardware Address:     %pM\n", p->ieee_addr);
 	printk("CRC checksum:         %04x\n", (u_short)(p->chksum));
 	for (i=0; i<64; i++) {
 	    printk("%3d %04x\n", i<<1, (u_short)*((u_short *)p+i));
@@ -5424,12 +5422,10 @@ static void
 de4x5_dbg_rx(struct sk_buff *skb, int len)
 {
     int i, j;
-    DECLARE_MAC_BUF(mac);
-    DECLARE_MAC_BUF(mac2);
 
     if (de4x5_debug & DEBUG_RX) {
-	printk("R: %s <- %s len/SAP:%02x%02x [%d]\n",
-	       print_mac(mac, skb->data), print_mac(mac2, &skb->data[6]),
+	printk("R: %pM <- %pM len/SAP:%02x%02x [%d]\n",
+	       skb->data, &skb->data[6],
 	       (u_char)skb->data[12],
 	       (u_char)skb->data[13],
 	       len);
--- test-tree.orig/drivers/net/tulip/dmfe.c	2008-10-25 02:15:00.000000000 +0200
+++ test-tree/drivers/net/tulip/dmfe.c	2008-10-25 02:16:00.000000000 +0200
@@ -362,7 +362,6 @@ static int __devinit dmfe_init_one (stru
 	struct net_device *dev;
 	u32 pci_pmr;
 	int i, err;
-	DECLARE_MAC_BUF(mac);
 
 	DMFE_DBUG(0, "dmfe_init_one()", 0);
 
@@ -471,12 +470,11 @@ static int __devinit dmfe_init_one (stru
 	if (err)
 		goto err_out_res;
 
-	printk(KERN_INFO "%s: Davicom DM%04lx at pci%s, "
-	       "%s, irq %d.\n",
+	printk(KERN_INFO "%s: Davicom DM%04lx at pci%s, %pM, irq %d.\n",
 	       dev->name,
 	       ent->driver_data >> 16,
 	       pci_name(pdev),
-	       print_mac(mac, dev->dev_addr),
+	       dev->dev_addr,
 	       dev->irq);
 
 	pci_set_master(pdev);
--- test-tree.orig/drivers/net/tulip/tulip_core.c	2008-10-25 02:15:00.000000000 +0200
+++ test-tree/drivers/net/tulip/tulip_core.c	2008-10-25 02:16:00.000000000 +0200
@@ -1050,13 +1050,11 @@ static void set_rx_mode(struct net_devic
 					filterbit = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
 				filterbit &= 0x3f;
 				mc_filter[filterbit >> 5] |= 1 << (filterbit & 31);
-				if (tulip_debug > 2) {
-					DECLARE_MAC_BUF(mac);
-					printk(KERN_INFO "%s: Added filter for %s"
+				if (tulip_debug > 2)
+					printk(KERN_INFO "%s: Added filter for %pM"
 					       "  %8.8x bit %d.\n",
-					       dev->name, print_mac(mac, mclist->dmi_addr),
+					       dev->name, mclist->dmi_addr,
 					       ether_crc(ETH_ALEN, mclist->dmi_addr), filterbit);
-				}
 			}
 			if (mc_filter[0] == tp->mc_filter[0]  &&
 				mc_filter[1] == tp->mc_filter[1])
@@ -1250,7 +1248,6 @@ static int __devinit tulip_init_one (str
 	const char *chip_name = tulip_tbl[chip_idx].chip_name;
 	unsigned int eeprom_missing = 0;
 	unsigned int force_csr0 = 0;
-	DECLARE_MAC_BUF(mac);
 
 #ifndef MODULE
 	static int did_version;		/* Already printed version info. */
@@ -1635,7 +1632,7 @@ static int __devinit tulip_init_one (str
 
 	if (eeprom_missing)
 		printk(" EEPROM not present,");
-	printk(" %s", print_mac(mac, dev->dev_addr));
+	printk(" %pM", dev->dev_addr);
 	printk(", IRQ %d.\n", irq);
 
         if (tp->chip_id == PNIC2)
--- test-tree.orig/drivers/net/tulip/uli526x.c	2008-10-25 02:15:00.000000000 +0200
+++ test-tree/drivers/net/tulip/uli526x.c	2008-10-25 02:16:00.000000000 +0200
@@ -261,7 +261,6 @@ static int __devinit uli526x_init_one (s
 	struct uli526x_board_info *db;	/* board information structure */
 	struct net_device *dev;
 	int i, err;
-	DECLARE_MAC_BUF(mac);
 
 	ULI526X_DBUG(0, "uli526x_init_one()", 0);
 
@@ -379,9 +378,9 @@ static int __devinit uli526x_init_one (s
 	if (err)
 		goto err_out_res;
 
-	printk(KERN_INFO "%s: ULi M%04lx at pci%s, %s, irq %d.\n",
+	printk(KERN_INFO "%s: ULi M%04lx at pci%s, %pM, irq %d.\n",
 	       dev->name,ent->driver_data >> 16,pci_name(pdev),
-	       print_mac(mac, dev->dev_addr), dev->irq);
+	       dev->dev_addr, dev->irq);
 
 	pci_set_master(pdev);
 
--- test-tree.orig/drivers/net/tulip/winbond-840.c	2008-10-25 02:15:00.000000000 +0200
+++ test-tree/drivers/net/tulip/winbond-840.c	2008-10-25 02:16:00.000000000 +0200
@@ -355,7 +355,6 @@ static int __devinit w840_probe1 (struct
 	int irq;
 	int i, option = find_cnt < MAX_UNITS ? options[find_cnt] : 0;
 	void __iomem *ioaddr;
-	DECLARE_MAC_BUF(mac);
 
 	i = pci_enable_device(pdev);
 	if (i) return i;
@@ -435,9 +434,9 @@ static int __devinit w840_probe1 (struct
 	if (i)
 		goto err_out_cleardev;
 
-	printk(KERN_INFO "%s: %s at %p, %s, IRQ %d.\n",
+	printk(KERN_INFO "%s: %s at %p, %pM, IRQ %d.\n",
 	       dev->name, pci_id_tbl[chip_idx].name, ioaddr,
-	       print_mac(mac, dev->dev_addr), irq);
+	       dev->dev_addr, irq);
 
 	if (np->drv_flags & CanHaveMII) {
 		int phy, phy_idx = 0;
@@ -1245,16 +1244,12 @@ static int netdev_rx(struct net_device *
 			}
 #ifndef final_version				/* Remove after testing. */
 			/* You will want this info for the initial debug. */
-			if (debug > 5) {
-				DECLARE_MAC_BUF(mac);
-				DECLARE_MAC_BUF(mac2);
-
-				printk(KERN_DEBUG "  Rx data %s %s"
+			if (debug > 5)
+				printk(KERN_DEBUG "  Rx data %pM %pM"
 				       " %2.2x%2.2x %d.%d.%d.%d.\n",
-				       print_mac(mac, &skb->data[0]), print_mac(mac2, &skb->data[6]),
+				       &skb->data[0], &skb->data[6],
 				       skb->data[12], skb->data[13],
 				       skb->data[14], skb->data[15], skb->data[16], skb->data[17]);
-			}
 #endif
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
--- test-tree.orig/drivers/net/tulip/xircom_cb.c	2008-10-25 02:15:00.000000000 +0200
+++ test-tree/drivers/net/tulip/xircom_cb.c	2008-10-25 02:16:00.000000000 +0200
@@ -1072,7 +1072,6 @@ static void read_mac_address(struct xirc
 	unsigned char j, tuple, link, data_id, data_count;
 	unsigned long flags;
 	int i;
-	DECLARE_MAC_BUF(mac);
 
 	enter("read_mac_address");
 
@@ -1102,7 +1101,7 @@ static void read_mac_address(struct xirc
 		}
 	}
 	spin_unlock_irqrestore(&card->lock, flags);
-	pr_debug(" %s\n", print_mac(mac, card->dev->dev_addr));
+	pr_debug(" %pM\n", card->dev->dev_addr);
 	leave("read_mac_address");
 }
 
--- test-tree.orig/drivers/net/tun.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/tun.c	2008-10-25 02:16:00.000000000 +0200
@@ -883,7 +883,6 @@ static int tun_chr_ioctl(struct inode *i
 	void __user* argp = (void __user*)arg;
 	struct ifreq ifr;
 	int ret;
-	DECLARE_MAC_BUF(mac);
 
 	if (cmd == TUNSETIFF || _IOC_TYPE(cmd) == 0x89)
 		if (copy_from_user(&ifr, argp, sizeof ifr))
@@ -1011,8 +1010,8 @@ static int tun_chr_ioctl(struct inode *i
 
 	case SIOCSIFHWADDR:
 		/* Set hw address */
-		DBG(KERN_DEBUG "%s: set hw address: %s\n",
-			tun->dev->name, print_mac(mac, ifr.ifr_hwaddr.sa_data));
+		DBG(KERN_DEBUG "%s: set hw address: %pM\n",
+			tun->dev->name, ifr.ifr_hwaddr.sa_data);
 
 		rtnl_lock();
 		ret = dev_set_mac_address(tun->dev, &ifr.ifr_hwaddr);
--- test-tree.orig/drivers/net/typhoon.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/typhoon.c	2008-10-25 02:16:00.000000000 +0200
@@ -2311,7 +2311,6 @@ typhoon_init_one(struct pci_dev *pdev, c
 	struct cmd_desc xp_cmd;
 	struct resp_desc xp_resp[3];
 	int err = 0;
-	DECLARE_MAC_BUF(mac);
 
 	if(!did_version++)
 		printk(KERN_INFO "%s", version);
@@ -2526,11 +2525,11 @@ typhoon_init_one(struct pci_dev *pdev, c
 
 	pci_set_drvdata(pdev, dev);
 
-	printk(KERN_INFO "%s: %s at %s 0x%llx, %s\n",
+	printk(KERN_INFO "%s: %s at %s 0x%llx, %pM\n",
 	       dev->name, typhoon_card_info[card_id].name,
 	       use_mmio ? "MMIO" : "IO",
 	       (unsigned long long)pci_resource_start(pdev, use_mmio),
-	       print_mac(mac, dev->dev_addr));
+	       dev->dev_addr);
 
 	/* xp_resp still contains the response to the READ_VERSIONS command.
 	 * For debugging, let the user know what version he has.
--- test-tree.orig/drivers/net/usb/pegasus.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/usb/pegasus.c	2008-10-25 02:16:00.000000000 +0200
@@ -1309,7 +1309,6 @@ static int pegasus_probe(struct usb_inte
 	pegasus_t *pegasus;
 	int dev_index = id - pegasus_ids;
 	int res = -ENOMEM;
-	DECLARE_MAC_BUF(mac);
 
 	usb_get_dev(dev);
 
@@ -1386,10 +1385,10 @@ static int pegasus_probe(struct usb_inte
 	queue_delayed_work(pegasus_workqueue, &pegasus->carrier_check,
 				CARRIER_CHECK_DELAY);
 
-	dev_info(&intf->dev, "%s, %s, %s\n",
+	dev_info(&intf->dev, "%s, %s, %pM\n",
 		 net->name,
 		 usb_dev_id[dev_index].name,
-		 print_mac(mac, net->dev_addr));
+		 net->dev_addr);
 	return 0;
 
 out3:
--- test-tree.orig/drivers/net/usb/smsc95xx.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/usb/smsc95xx.c	2008-10-25 02:16:00.000000000 +0200
@@ -759,7 +759,6 @@ static int smsc95xx_reset(struct usbnet 
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	u32 read_buf, write_buf, burst_cap;
 	int ret = 0, timeout;
-	DECLARE_MAC_BUF(mac);
 
 	if (netif_msg_ifup(dev))
 		devdbg(dev, "entering smsc95xx_reset");
@@ -818,8 +817,7 @@ static int smsc95xx_reset(struct usbnet 
 		return ret;
 
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "MAC Address: %s",
-			print_mac(mac, dev->net->dev_addr));
+		devdbg(dev, "MAC Address: %pM", dev->net->dev_addr);
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
 	if (ret < 0) {
--- test-tree.orig/drivers/net/usb/usbnet.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/usb/usbnet.c	2008-10-25 02:16:00.000000000 +0200
@@ -1125,7 +1125,6 @@ usbnet_probe (struct usb_interface *udev
 	struct usb_device		*xdev;
 	int				status;
 	const char			*name;
-	DECLARE_MAC_BUF(mac);
 
 	name = udev->dev.driver->name;
 	info = (struct driver_info *) prod->driver_info;
@@ -1236,11 +1235,11 @@ usbnet_probe (struct usb_interface *udev
 	if (status)
 		goto out3;
 	if (netif_msg_probe (dev))
-		devinfo (dev, "register '%s' at usb-%s-%s, %s, %s",
+		devinfo (dev, "register '%s' at usb-%s-%s, %s, %pM",
 			udev->dev.driver->name,
 			xdev->bus->bus_name, xdev->devpath,
 			dev->driver_info->description,
-			print_mac(mac, net->dev_addr));
+			net->dev_addr);
 
 	// ok, it's ready to go.
 	usb_set_intfdata (udev, dev);
--- test-tree.orig/drivers/net/via-rhine.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/via-rhine.c	2008-10-25 02:16:00.000000000 +0200
@@ -631,7 +631,6 @@ static int __devinit rhine_init_one(stru
 #else
 	int bar = 0;
 #endif
-	DECLARE_MAC_BUF(mac);
 
 /* when built into the kernel, we only print version if device is found */
 #ifndef MODULE
@@ -787,14 +786,14 @@ static int __devinit rhine_init_one(stru
 	if (rc)
 		goto err_out_unmap;
 
-	printk(KERN_INFO "%s: VIA %s at 0x%lx, %s, IRQ %d.\n",
+	printk(KERN_INFO "%s: VIA %s at 0x%lx, %pM, IRQ %d.\n",
 	       dev->name, name,
 #ifdef USE_MMIO
 	       memaddr,
 #else
 	       (long)ioaddr,
 #endif
-	       print_mac(mac, dev->dev_addr), pdev->irq);
+	       dev->dev_addr, pdev->irq);
 
 	pci_set_drvdata(pdev, dev);
 
--- test-tree.orig/drivers/net/wd.c	2008-10-25 02:15:05.000000000 +0200
+++ test-tree/drivers/net/wd.c	2008-10-25 02:16:00.000000000 +0200
@@ -156,7 +156,6 @@ static int __init wd_probe1(struct net_d
 	int word16 = 0;				/* 0 = 8 bit, 1 = 16 bit */
 	const char *model_name;
 	static unsigned version_printed;
-	DECLARE_MAC_BUF(mac);
 
 	for (i = 0; i < 8; i++)
 		checksum += inb(ioaddr + 8 + i);
@@ -178,8 +177,8 @@ static int __init wd_probe1(struct net_d
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = inb(ioaddr + 8 + i);
 
-	printk("%s: WD80x3 at %#3x, %s",
-	       dev->name, ioaddr, print_mac(mac, dev->dev_addr));
+	printk("%s: WD80x3 at %#3x, %pM",
+	       dev->name, ioaddr, dev->dev_addr);
 
 	/* The following PureData probe code was contributed by
 	   Mike Jagdis <jaggy@purplet.demon.co.uk>. Puredata does software
--- test-tree.orig/drivers/net/wireless/adm8211.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/wireless/adm8211.c	2008-10-25 02:16:00.000000000 +0200
@@ -1791,7 +1791,6 @@ static int __devinit adm8211_probe(struc
 	int err;
 	u32 reg;
 	u8 perm_addr[ETH_ALEN];
-	DECLARE_MAC_BUF(mac);
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -1925,8 +1924,8 @@ static int __devinit adm8211_probe(struc
 		goto err_free_desc;
 	}
 
-	printk(KERN_INFO "%s: hwaddr %s, Rev 0x%02x\n",
-	       wiphy_name(dev->wiphy), print_mac(mac, dev->wiphy->perm_addr),
+	printk(KERN_INFO "%s: hwaddr %pM, Rev 0x%02x\n",
+	       wiphy_name(dev->wiphy), dev->wiphy->perm_addr,
 	       pdev->revision);
 
 	return 0;
--- test-tree.orig/drivers/net/wireless/airo.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/airo.c	2008-10-25 02:16:00.000000000 +0200
@@ -2757,7 +2757,6 @@ static struct net_device *_init_airo_car
 	struct net_device *dev;
 	struct airo_info *ai;
 	int i, rc;
-	DECLARE_MAC_BUF(mac);
 
 	/* Create the network device object. */
 	dev = alloc_netdev(sizeof(*ai), "", ether_setup);
@@ -2860,8 +2859,7 @@ static struct net_device *_init_airo_car
 		goto err_out_reg;
 
 	set_bit(FLAG_REGISTERED,&ai->flags);
-	airo_print_info(dev->name, "MAC enabled %s",
-			print_mac(mac, dev->dev_addr));
+	airo_print_info(dev->name, "MAC enabled %pM", dev->dev_addr);
 
 	/* Allocate the transmit buffers */
 	if (probe && !test_bit(FLAG_MPI,&ai->flags))
@@ -2918,7 +2916,6 @@ int reset_airo_card( struct net_device *
 {
 	int i;
 	struct airo_info *ai = dev->priv;
-	DECLARE_MAC_BUF(mac);
 
 	if (reset_card (dev, 1))
 		return -1;
@@ -2927,8 +2924,7 @@ int reset_airo_card( struct net_device *
 		airo_print_err(dev->name, "MAC could not be enabled");
 		return -1;
 	}
-	airo_print_info(dev->name, "MAC enabled %s",
-			print_mac(mac, dev->dev_addr));
+	airo_print_info(dev->name, "MAC enabled %pM", dev->dev_addr);
 	/* Allocate the transmit buffers if needed */
 	if (!test_bit(FLAG_MPI,&ai->flags))
 		for( i = 0; i < MAX_FIDS; i++ )
@@ -5330,7 +5326,6 @@ static int proc_APList_open( struct inod
 	int i;
 	char *ptr;
 	APListRid APList_rid;
-	DECLARE_MAC_BUF(mac);
 
 	if ((file->private_data = kzalloc(sizeof(struct proc_data ), GFP_KERNEL)) == NULL)
 		return -ENOMEM;
@@ -5354,8 +5349,7 @@ static int proc_APList_open( struct inod
 // We end when we find a zero MAC
 		if ( !*(int*)APList_rid.ap[i] &&
 		     !*(int*)&APList_rid.ap[i][2]) break;
-		ptr += sprintf(ptr, "%s\n",
-			       print_mac(mac, APList_rid.ap[i]));
+		ptr += sprintf(ptr, "%pM\n", APList_rid.ap[i]);
 	}
 	if (i==0) ptr += sprintf(ptr, "Not using specific APs\n");
 
@@ -5374,7 +5368,6 @@ static int proc_BSSList_open( struct ino
 	int rc;
 	/* If doLoseSync is not 1, we won't do a Lose Sync */
 	int doLoseSync = -1;
-	DECLARE_MAC_BUF(mac);
 
 	if ((file->private_data = kzalloc(sizeof(struct proc_data ), GFP_KERNEL)) == NULL)
 		return -ENOMEM;
@@ -5411,8 +5404,8 @@ static int proc_BSSList_open( struct ino
            we have to add a spin lock... */
 	rc = readBSSListRid(ai, doLoseSync, &BSSList_rid);
 	while(rc == 0 && BSSList_rid.index != cpu_to_le16(0xffff)) {
-		ptr += sprintf(ptr, "%s %*s rssi = %d",
-			       print_mac(mac, BSSList_rid.bssid),
+		ptr += sprintf(ptr, "%pM %*s rssi = %d",
+			       BSSList_rid.bssid,
 				(int)BSSList_rid.ssidLen,
 				BSSList_rid.ssid,
 				le16_to_cpu(BSSList_rid.dBm));
--- test-tree.orig/drivers/net/wireless/arlan-main.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/arlan-main.c	2008-10-25 02:16:00.000000000 +0200
@@ -1467,19 +1467,17 @@ static void arlan_rx_interrupt(struct ne
 						else if (hw_dst_addr[1] == 0x40)
 							printk(KERN_ERR "%s m/bcast 0x0140 \n", dev->name);
 					while (dmi)
-					{							if (dmi->dmi_addrlen == 6)
-						{
-							DECLARE_MAC_BUF(mac);
+					{
+						if (dmi->dmi_addrlen == 6) {
 							if (arlan_debug & ARLAN_DEBUG_HEADER_DUMP)
-								printk(KERN_ERR "%s mcl %s\n",
-								       dev->name, print_mac(mac, dmi->dmi_addr));
+								printk(KERN_ERR "%s mcl %pM\n",
+								       dev->name, dmi->dmi_addr);
 							for (i = 0; i < 6; i++)
 								if (dmi->dmi_addr[i] != hw_dst_addr[i])
 									break;
 							if (i == 6)
 								break;
-						}
-						else
+						} else
 							printk(KERN_ERR "%s: invalid multicast address length given.\n", dev->name);
 						dmi = dmi->next;
 					}
@@ -1512,18 +1510,14 @@ static void arlan_rx_interrupt(struct ne
 			{
 				char immedDestAddress[6];
 				char immedSrcAddress[6];
-				DECLARE_MAC_BUF(mac);
-				DECLARE_MAC_BUF(mac2);
-				DECLARE_MAC_BUF(mac3);
-				DECLARE_MAC_BUF(mac4);
 				memcpy_fromio(immedDestAddress, arlan->immedDestAddress, 6);
 				memcpy_fromio(immedSrcAddress, arlan->immedSrcAddress, 6);
 
-				printk(KERN_WARNING "%s t %s f %s imd %s ims %s\n",
-				       dev->name, print_mac(mac, skbtmp),
-				       print_mac(mac2, &skbtmp[6]),
-				       print_mac(mac3, immedDestAddress),
-				       print_mac(mac4, immedSrcAddress));
+				printk(KERN_WARNING "%s t %pM f %pM imd %pM ims %pM\n",
+				       dev->name, skbtmp,
+				       &skbtmp[6],
+				       immedDestAddress,
+				       immedSrcAddress);
 			}
 			skb->protocol = eth_type_trans(skb, dev);
 			IFDEBUG(ARLAN_DEBUG_HEADER_DUMP)
--- test-tree.orig/drivers/net/wireless/ath9k/hw.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/wireless/ath9k/hw.c	2008-10-25 02:16:00.000000000 +0200
@@ -1291,7 +1291,6 @@ static int ath9k_hw_init_macaddr(struct 
 	int i;
 	u16 eeval;
 	struct ath_hal_5416 *ahp = AH5416(ah);
-	DECLARE_MAC_BUF(mac);
 
 	sum = 0;
 	for (i = 0; i < 3; i++) {
@@ -1302,8 +1301,8 @@ static int ath9k_hw_init_macaddr(struct 
 	}
 	if (sum == 0 || sum == 0xffff * 3) {
 		DPRINTF(ah->ah_sc, ATH_DBG_EEPROM,
-			 "%s: mac address read failed: %s\n", __func__,
-			 print_mac(mac, ahp->ah_macaddr));
+			 "%s: mac address read failed: %pM\n", __func__,
+			 ahp->ah_macaddr);
 		return -EADDRNOTAVAIL;
 	}
 
--- test-tree.orig/drivers/net/wireless/ath9k/main.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/wireless/ath9k/main.c	2008-10-25 02:16:00.000000000 +0200
@@ -362,7 +362,6 @@ static void ath9k_bss_assoc_info(struct 
 	struct ieee80211_channel *curchan = hw->conf.channel;
 	struct ath_vap *avp;
 	int pos;
-	DECLARE_MAC_BUF(mac);
 
 	if (bss_conf->assoc) {
 		DPRINTF(sc, ATH_DBG_CONFIG, "%s: Bss Info ASSOC %d\n",
@@ -397,9 +396,9 @@ static void ath9k_bss_assoc_info(struct 
 		ath_update_chainmask(sc, bss_conf->assoc_ht);
 
 		DPRINTF(sc, ATH_DBG_CONFIG,
-			"%s: bssid %s aid 0x%x\n",
+			"%s: bssid %pM aid 0x%x\n",
 			__func__,
-			print_mac(mac, sc->sc_curbssid), sc->sc_curaid);
+			sc->sc_curbssid, sc->sc_curaid);
 
 		DPRINTF(sc, ATH_DBG_CONFIG, "%s: Set channel: %d MHz\n",
 			__func__,
@@ -1278,7 +1277,6 @@ static int ath9k_config_interface(struct
 	struct ath_vap *avp;
 	u32 rfilt = 0;
 	int error, i;
-	DECLARE_MAC_BUF(mac);
 
 	avp = sc->sc_vaps[0];
 	if (avp == NULL) {
@@ -1333,9 +1331,9 @@ static int ath9k_config_interface(struct
 			sc->sc_imask &= ~(ATH9K_INT_SWBA | ATH9K_INT_BMISS);
 
 			DPRINTF(sc, ATH_DBG_CONFIG,
-				"%s: RX filter 0x%x bssid %s aid 0x%x\n",
+				"%s: RX filter 0x%x bssid %pM aid 0x%x\n",
 				__func__, rfilt,
-				print_mac(mac, sc->sc_curbssid), sc->sc_curaid);
+				sc->sc_curbssid, sc->sc_curaid);
 
 			/* need to reconfigure the beacon */
 			sc->sc_flags &= ~SC_OP_BEACONS ;
@@ -1424,7 +1422,6 @@ static void ath9k_sta_notify(struct ieee
 	struct ath_softc *sc = hw->priv;
 	struct ath_node *an;
 	unsigned long flags;
-	DECLARE_MAC_BUF(mac);
 
 	spin_lock_irqsave(&sc->node_lock, flags);
 	an = ath_node_find(sc, sta->addr);
@@ -1435,8 +1432,8 @@ static void ath9k_sta_notify(struct ieee
 		spin_lock_irqsave(&sc->node_lock, flags);
 		if (!an) {
 			ath_node_attach(sc, sta->addr, 0);
-			DPRINTF(sc, ATH_DBG_CONFIG, "%s: Attach a node: %s\n",
-				__func__, print_mac(mac, sta->addr));
+			DPRINTF(sc, ATH_DBG_CONFIG, "%s: Attach a node: %pM\n",
+				__func__, sta->addr);
 		} else {
 			ath_node_get(sc, sta->addr);
 		}
@@ -1449,9 +1446,9 @@ static void ath9k_sta_notify(struct ieee
 				__func__);
 		else {
 			ath_node_put(sc, an, ATH9K_BH_STATUS_INTACT);
-			DPRINTF(sc, ATH_DBG_CONFIG, "%s: Put a node: %s\n",
+			DPRINTF(sc, ATH_DBG_CONFIG, "%s: Put a node: %pM\n",
 				__func__,
-				print_mac(mac, sta->addr));
+				sta->addr);
 		}
 		break;
 	default:
--- test-tree.orig/drivers/net/wireless/ath9k/rc.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/wireless/ath9k/rc.c	2008-10-25 02:16:00.000000000 +0200
@@ -1942,7 +1942,6 @@ static void ath_get_rate(void *priv, str
 	s8 lowest_idx;
 	__le16 fc = hdr->frame_control;
 	u8 *qc, tid;
-	DECLARE_MAC_BUF(mac);
 
 	DPRINTF(sc, ATH_DBG_RATE, "%s\n", __func__);
 
@@ -2003,14 +2002,14 @@ static void ath_get_rate(void *priv, str
 				if (ret)
 					DPRINTF(sc, ATH_DBG_AGGR,
 						"%s: Unable to start tx "
-						"aggr for: %s\n",
+						"aggr for: %pM\n",
 						__func__,
-						print_mac(mac, hdr->addr1));
+						hdr->addr1);
 				else
 					DPRINTF(sc, ATH_DBG_AGGR,
-						"%s: Started tx aggr for: %s\n",
+						"%s: Started tx aggr for: %pM\n",
 						__func__,
-						print_mac(mac, hdr->addr1));
+						hdr->addr1);
 			} else if (chk == AGGR_EXCHANGE_PROGRESS)
 				ath_tx_aggr_resp(sc, sband, sta, an, tid);
 		}
--- test-tree.orig/drivers/net/wireless/atmel.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/wireless/atmel.c	2008-10-25 02:16:00.000000000 +0200
@@ -1479,7 +1479,6 @@ struct net_device *init_atmel_card(unsig
 	struct net_device *dev;
 	struct atmel_private *priv;
 	int rc;
-	DECLARE_MAC_BUF(mac);
 
 	/* Create the network device object. */
         dev = alloc_etherdev(sizeof(*priv));
@@ -1591,8 +1590,8 @@ struct net_device *init_atmel_card(unsig
 	if (!ent)
 		printk(KERN_WARNING "atmel: unable to create /proc entry.\n");
 
-	printk(KERN_INFO "%s: Atmel at76c50x. Version %d.%d. MAC %s\n",
-	       dev->name, DRIVER_MAJOR, DRIVER_MINOR, print_mac(mac, dev->dev_addr));
+	printk(KERN_INFO "%s: Atmel at76c50x. Version %d.%d. MAC %pM\n",
+	       dev->name, DRIVER_MAJOR, DRIVER_MINOR, dev->dev_addr);
 
 	return dev;
 
--- test-tree.orig/drivers/net/wireless/b43/main.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/b43/main.c	2008-10-25 02:16:00.000000000 +0200
@@ -3445,7 +3445,6 @@ static int b43_op_set_key(struct ieee802
 	u8 algorithm;
 	u8 index;
 	int err;
-	DECLARE_MAC_BUF(mac);
 
 	if (modparam_nohwcrypt)
 		return -ENOSPC; /* User disabled HW-crypto */
@@ -3533,9 +3532,9 @@ out_unlock:
 	mutex_unlock(&wl->mutex);
 	if (!err) {
 		b43dbg(wl, "%s hardware based encryption for keyidx: %d, "
-		       "mac: %s\n",
+		       "mac: %pM\n",
 		       cmd == SET_KEY ? "Using" : "Disabling", key->keyidx,
-		       print_mac(mac, addr));
+		       addr);
 	}
 	return err;
 }
--- test-tree.orig/drivers/net/wireless/hostap/hostap_hw.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/hostap/hostap_hw.c	2008-10-25 02:16:00.000000000 +0200
@@ -2335,10 +2335,6 @@ static void prism2_txexc(local_info_t *l
 	int show_dump, res;
 	char *payload = NULL;
 	struct hfa384x_tx_frame txdesc;
-	DECLARE_MAC_BUF(mac);
-	DECLARE_MAC_BUF(mac2);
-	DECLARE_MAC_BUF(mac3);
-	DECLARE_MAC_BUF(mac4);
 
 	show_dump = local->frame_dump & PRISM2_DUMP_TXEXC_HDR;
 	local->stats.tx_errors++;
@@ -2404,9 +2400,9 @@ static void prism2_txexc(local_info_t *l
 	       WLAN_FC_GET_STYPE(fc) >> 4,
 	       fc & IEEE80211_FCTL_TODS ? " ToDS" : "",
 	       fc & IEEE80211_FCTL_FROMDS ? " FromDS" : "");
-	PDEBUG(DEBUG_EXTRA, "   A1=%s A2=%s A3=%s A4=%s\n",
-	       print_mac(mac, txdesc.addr1), print_mac(mac2, txdesc.addr2),
-	       print_mac(mac3, txdesc.addr3), print_mac(mac4, txdesc.addr4));
+	PDEBUG(DEBUG_EXTRA, "   A1=%pM A2=%pM A3=%pM A4=%pM\n",
+	       txdesc.addr1, txdesc.addr2,
+	       txdesc.addr3, txdesc.addr4);
 }
 
 
--- test-tree.orig/drivers/net/wireless/hostap/hostap_info.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/hostap/hostap_info.c	2008-10-25 02:16:00.000000000 +0200
@@ -166,7 +166,6 @@ static void prism2_host_roaming(local_in
 	struct hfa384x_hostscan_result *selected, *entry;
 	int i;
 	unsigned long flags;
-	DECLARE_MAC_BUF(mac);
 
 	if (local->last_join_time &&
 	    time_before(jiffies, local->last_join_time + 10 * HZ)) {
@@ -199,9 +198,8 @@ static void prism2_host_roaming(local_in
 	    local->preferred_ap[2] || local->preferred_ap[3] ||
 	    local->preferred_ap[4] || local->preferred_ap[5]) {
 		/* Try to find preferred AP */
-		PDEBUG(DEBUG_EXTRA, "%s: Preferred AP BSSID "
-		       "%s\n",
-		       dev->name, print_mac(mac, local->preferred_ap));
+		PDEBUG(DEBUG_EXTRA, "%s: Preferred AP BSSID %pM\n",
+		       dev->name, local->preferred_ap);
 		for (i = 0; i < local->last_scan_results_count; i++) {
 			entry = &local->last_scan_results[i];
 			if (memcmp(local->preferred_ap, entry->bssid, 6) == 0)
@@ -218,9 +216,9 @@ static void prism2_host_roaming(local_in
 	req.channel = selected->chid;
 	spin_unlock_irqrestore(&local->lock, flags);
 
-	PDEBUG(DEBUG_EXTRA, "%s: JoinRequest: BSSID=%s"
+	PDEBUG(DEBUG_EXTRA, "%s: JoinRequest: BSSID=%pM"
 	       " channel=%d\n",
-	       dev->name, print_mac(mac, req.bssid), le16_to_cpu(req.channel));
+	       dev->name, req.bssid, le16_to_cpu(req.channel));
 	if (local->func->set_rid(dev, HFA384X_RID_JOINREQUEST, &req,
 				 sizeof(req))) {
 		printk(KERN_DEBUG "%s: JoinRequest failed\n", dev->name);
@@ -413,7 +411,6 @@ static void handle_info_queue_linkstatus
 	int val = local->prev_link_status;
 	int connected;
 	union iwreq_data wrqu;
-	DECLARE_MAC_BUF(mac);
 
 	connected =
 		val == HFA384X_LINKSTATUS_CONNECTED ||
@@ -425,10 +422,9 @@ static void handle_info_queue_linkstatus
 		printk(KERN_DEBUG "%s: could not read CURRENTBSSID after "
 		       "LinkStatus event\n", local->dev->name);
 	} else {
-		PDEBUG(DEBUG_EXTRA, "%s: LinkStatus: BSSID="
-		       "%s\n",
+		PDEBUG(DEBUG_EXTRA, "%s: LinkStatus: BSSID=%pM\n",
 		       local->dev->name,
-		       print_mac(mac, (unsigned char *) local->bssid));
+		       (unsigned char *) local->bssid);
 		if (local->wds_type & HOSTAP_WDS_AP_CLIENT)
 			hostap_add_sta(local->ap, local->bssid);
 	}
--- test-tree.orig/drivers/net/wireless/hostap/hostap_ioctl.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/hostap/hostap_ioctl.c	2008-10-25 02:16:00.000000000 +0200
@@ -664,7 +664,6 @@ static int hostap_join_ap(struct net_dev
 	unsigned long flags;
 	int i;
 	struct hfa384x_hostscan_result *entry;
-	DECLARE_MAC_BUF(mac);
 
 	iface = netdev_priv(dev);
 	local = iface->local;
@@ -686,14 +685,13 @@ static int hostap_join_ap(struct net_dev
 
 	if (local->func->set_rid(dev, HFA384X_RID_JOINREQUEST, &req,
 				 sizeof(req))) {
-		printk(KERN_DEBUG "%s: JoinRequest %s"
-		       " failed\n",
-		       dev->name, print_mac(mac, local->preferred_ap));
+		printk(KERN_DEBUG "%s: JoinRequest %pM failed\n",
+		       dev->name, local->preferred_ap);
 		return -1;
 	}
 
-	printk(KERN_DEBUG "%s: Trying to join BSSID %s\n",
-	       dev->name, print_mac(mac, local->preferred_ap));
+	printk(KERN_DEBUG "%s: Trying to join BSSID %pM\n",
+	       dev->name, local->preferred_ap);
 
 	return 0;
 }
@@ -3701,10 +3699,8 @@ static int prism2_ioctl_set_assoc_ap_add
 					  struct prism2_hostapd_param *param,
 					  int param_len)
 {
-	DECLARE_MAC_BUF(mac);
-	printk(KERN_DEBUG "%ssta: associated as client with AP "
-	       "%s\n",
-	       local->dev->name, print_mac(mac, param->sta_addr));
+	printk(KERN_DEBUG "%ssta: associated as client with AP %pM\n",
+	       local->dev->name, param->sta_addr);
 	memcpy(local->assoc_ap_addr, param->sta_addr, ETH_ALEN);
 	return 0;
 }
--- test-tree.orig/drivers/net/wireless/hostap/hostap_main.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/hostap/hostap_main.c	2008-10-25 02:16:00.000000000 +0200
@@ -530,10 +530,6 @@ int hostap_set_auth_algs(local_info_t *l
 void hostap_dump_rx_header(const char *name, const struct hfa384x_rx_frame *rx)
 {
 	u16 status, fc;
-	DECLARE_MAC_BUF(mac);
-	DECLARE_MAC_BUF(mac2);
-	DECLARE_MAC_BUF(mac3);
-	DECLARE_MAC_BUF(mac4);
 
 	status = __le16_to_cpu(rx->status);
 
@@ -552,12 +548,11 @@ void hostap_dump_rx_header(const char *n
 	       fc & IEEE80211_FCTL_TODS ? " [ToDS]" : "",
 	       fc & IEEE80211_FCTL_FROMDS ? " [FromDS]" : "");
 
-	printk(KERN_DEBUG "   A1=%s A2=%s A3=%s A4=%s\n",
-	       print_mac(mac, rx->addr1), print_mac(mac2, rx->addr2),
-	       print_mac(mac3, rx->addr3), print_mac(mac4, rx->addr4));
+	printk(KERN_DEBUG "   A1=%pM A2=%pM A3=%pM A4=%pM\n",
+	       rx->addr1, rx->addr2, rx->addr3, rx->addr4);
 
-	printk(KERN_DEBUG "   dst=%s src=%s len=%d\n",
-	       print_mac(mac, rx->dst_addr), print_mac(mac2, rx->src_addr),
+	printk(KERN_DEBUG "   dst=%pM src=%pM len=%d\n",
+	       rx->dst_addr, rx->src_addr,
 	       __be16_to_cpu(rx->len));
 }
 
@@ -565,10 +560,6 @@ void hostap_dump_rx_header(const char *n
 void hostap_dump_tx_header(const char *name, const struct hfa384x_tx_frame *tx)
 {
 	u16 fc;
-	DECLARE_MAC_BUF(mac);
-	DECLARE_MAC_BUF(mac2);
-	DECLARE_MAC_BUF(mac3);
-	DECLARE_MAC_BUF(mac4);
 
 	printk(KERN_DEBUG "%s: TX status=0x%04x retry_count=%d tx_rate=%d "
 	       "tx_control=0x%04x; jiffies=%ld\n",
@@ -584,12 +575,11 @@ void hostap_dump_tx_header(const char *n
 	       fc & IEEE80211_FCTL_TODS ? " [ToDS]" : "",
 	       fc & IEEE80211_FCTL_FROMDS ? " [FromDS]" : "");
 
-	printk(KERN_DEBUG "   A1=%s A2=%s A3=%s A4=%s\n",
-	       print_mac(mac, tx->addr1), print_mac(mac2, tx->addr2),
-	       print_mac(mac3, tx->addr3), print_mac(mac4, tx->addr4));
+	printk(KERN_DEBUG "   A1=%pM A2=%pM A3=%pM A4=%pM\n",
+	       tx->addr1, tx->addr2, tx->addr3, tx->addr4);
 
-	printk(KERN_DEBUG "   dst=%s src=%s len=%d\n",
-	       print_mac(mac, tx->dst_addr), print_mac(mac2, tx->src_addr),
+	printk(KERN_DEBUG "   dst=%pM src=%pM len=%d\n",
+	       tx->dst_addr, tx->src_addr,
 	       __be16_to_cpu(tx->len));
 }
 
--- test-tree.orig/drivers/net/wireless/hostap/hostap_proc.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/hostap/hostap_proc.c	2008-10-25 02:16:00.000000000 +0200
@@ -106,7 +106,6 @@ static int prism2_wds_proc_read(char *pa
 	local_info_t *local = (local_info_t *) data;
 	struct list_head *ptr;
 	struct hostap_interface *iface;
-	DECLARE_MAC_BUF(mac);
 
 	if (off > PROC_LIMIT) {
 		*eof = 1;
@@ -118,9 +117,9 @@ static int prism2_wds_proc_read(char *pa
 		iface = list_entry(ptr, struct hostap_interface, list);
 		if (iface->type != HOSTAP_INTERFACE_WDS)
 			continue;
-		p += sprintf(p, "%s\t%s\n",
+		p += sprintf(p, "%s\t%pM\n",
 			     iface->dev->name,
-			     print_mac(mac, iface->u.wds.remote_addr));
+			     iface->u.wds.remote_addr);
 		if ((p - page) > PROC_LIMIT) {
 			printk(KERN_DEBUG "%s: wds proc did not fit\n",
 			       local->dev->name);
@@ -148,7 +147,6 @@ static int prism2_bss_list_proc_read(cha
 	struct list_head *ptr;
 	struct hostap_bss_info *bss;
 	int i;
-	DECLARE_MAC_BUF(mac);
 
 	if (off > PROC_LIMIT) {
 		*eof = 1;
@@ -160,8 +158,8 @@ static int prism2_bss_list_proc_read(cha
 	spin_lock_bh(&local->lock);
 	list_for_each(ptr, &local->bss_list) {
 		bss = list_entry(ptr, struct hostap_bss_info, list);
-		p += sprintf(p, "%s\t%lu\t%u\t0x%x\t",
-			     print_mac(mac, bss->bssid), bss->last_update,
+		p += sprintf(p, "%pM\t%lu\t%u\t0x%x\t",
+			     bss->bssid, bss->last_update,
 			     bss->count, bss->capab_info);
 		for (i = 0; i < bss->ssid_len; i++) {
 			p += sprintf(p, "%c",
@@ -314,7 +312,6 @@ static int prism2_scan_results_proc_read
 	int entry, i, len, total = 0;
 	struct hfa384x_hostscan_result *scanres;
 	u8 *pos;
-	DECLARE_MAC_BUF(mac);
 
 	p += sprintf(p, "CHID ANL SL BcnInt Capab Rate BSSID ATIM SupRates "
 		     "SSID\n");
@@ -332,14 +329,14 @@ static int prism2_scan_results_proc_read
 		if ((p - page) > (PAGE_SIZE - 200))
 			break;
 
-		p += sprintf(p, "%d %d %d %d 0x%02x %d %s %d ",
+		p += sprintf(p, "%d %d %d %d 0x%02x %d %pM %d ",
 			     le16_to_cpu(scanres->chid),
 			     (s16) le16_to_cpu(scanres->anl),
 			     (s16) le16_to_cpu(scanres->sl),
 			     le16_to_cpu(scanres->beacon_interval),
 			     le16_to_cpu(scanres->capability),
 			     le16_to_cpu(scanres->rate),
-			     print_mac(mac, scanres->bssid),
+			     scanres->bssid,
 			     le16_to_cpu(scanres->atim));
 
 		pos = scanres->sup_rates;
--- test-tree.orig/drivers/net/wireless/ipw2100.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/ipw2100.c	2008-10-25 02:16:00.000000000 +0200
@@ -1914,7 +1914,6 @@ static void isr_indicate_associated(stru
 	u32 chan;
 	char *txratename;
 	u8 bssid[ETH_ALEN];
-	DECLARE_MAC_BUF(mac);
 
 	/*
 	 * TBD: BSSID is usually 00:00:00:00:00:00 here and not
@@ -1975,10 +1974,9 @@ static void isr_indicate_associated(stru
 		break;
 	}
 
-	IPW_DEBUG_INFO("%s: Associated with '%s' at %s, channel %d (BSSID="
-		       "%s)\n",
+	IPW_DEBUG_INFO("%s: Associated with '%s' at %s, channel %d (BSSID=%pM)\n",
 		       priv->net_dev->name, escape_essid(essid, essid_len),
-		       txratename, chan, print_mac(mac, bssid));
+		       txratename, chan, bssid);
 
 	/* now we copy read ssid into dev */
 	if (!(priv->config & CFG_STATIC_ESSID)) {
@@ -2046,12 +2044,10 @@ static int ipw2100_set_essid(struct ipw2
 
 static void isr_indicate_association_lost(struct ipw2100_priv *priv, u32 status)
 {
-	DECLARE_MAC_BUF(mac);
-
 	IPW_DEBUG(IPW_DL_NOTIF | IPW_DL_STATE | IPW_DL_ASSOC,
-		  "disassociated: '%s' %s \n",
+		  "disassociated: '%s' %pM \n",
 		  escape_essid(priv->essid, priv->essid_len),
-		  print_mac(mac, priv->bssid));
+		  priv->bssid);
 
 	priv->status &= ~(STATUS_ASSOCIATED | STATUS_ASSOCIATING);
 
@@ -4058,7 +4054,6 @@ static ssize_t show_bssinfo(struct devic
 	char *out = buf;
 	int length;
 	int ret;
-	DECLARE_MAC_BUF(mac);
 
 	if (priv->status & STATUS_RF_KILL_MASK)
 		return 0;
@@ -4086,7 +4081,7 @@ static ssize_t show_bssinfo(struct devic
 			       __LINE__);
 
 	out += sprintf(out, "ESSID: %s\n", essid);
-	out += sprintf(out, "BSSID:   %s\n", print_mac(mac, bssid));
+	out += sprintf(out, "BSSID:   %pM\n", bssid);
 	out += sprintf(out, "Channel: %d\n", chan);
 
 	return out - buf;
@@ -4662,7 +4657,6 @@ static int ipw2100_read_mac_address(stru
 {
 	u32 length = ETH_ALEN;
 	u8 addr[ETH_ALEN];
-	DECLARE_MAC_BUF(mac);
 
 	int err;
 
@@ -4673,8 +4667,7 @@ static int ipw2100_read_mac_address(stru
 	}
 
 	memcpy(priv->net_dev->dev_addr, addr, ETH_ALEN);
-	IPW_DEBUG_INFO("card MAC is %s\n",
-		       print_mac(mac, priv->net_dev->dev_addr));
+	IPW_DEBUG_INFO("card MAC is %pM\n", priv->net_dev->dev_addr);
 
 	return 0;
 }
@@ -5053,10 +5046,8 @@ static int ipw2100_set_mandatory_bssid(s
 	int err;
 
 #ifdef CONFIG_IPW2100_DEBUG
-	DECLARE_MAC_BUF(mac);
 	if (bssid != NULL)
-		IPW_DEBUG_HC("MANDATORY_BSSID: %s\n",
-			     print_mac(mac, bssid));
+		IPW_DEBUG_HC("MANDATORY_BSSID: %pM\n", bssid);
 	else
 		IPW_DEBUG_HC("MANDATORY_BSSID: <clear>\n");
 #endif
@@ -6905,7 +6896,6 @@ static int ipw2100_wx_set_wap(struct net
 	static const unsigned char off[] = {
 		0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 	};
-	DECLARE_MAC_BUF(mac);
 
 	// sanity checks
 	if (wrqu->ap_addr.sa_family != ARPHRD_ETHER)
@@ -6931,8 +6921,7 @@ static int ipw2100_wx_set_wap(struct net
 
 	err = ipw2100_set_mandatory_bssid(priv, wrqu->ap_addr.sa_data, 0);
 
-	IPW_DEBUG_WX("SET BSSID -> %s\n",
-		     print_mac(mac, wrqu->ap_addr.sa_data));
+	IPW_DEBUG_WX("SET BSSID -> %pM\n", wrqu->ap_addr.sa_data);
 
       done:
 	mutex_unlock(&priv->action_mutex);
@@ -6948,7 +6937,6 @@ static int ipw2100_wx_get_wap(struct net
 	 */
 
 	struct ipw2100_priv *priv = ieee80211_priv(dev);
-	DECLARE_MAC_BUF(mac);
 
 	/* If we are associated, trying to associate, or have a statically
 	 * configured BSSID then return that; otherwise return ANY */
@@ -6958,8 +6946,7 @@ static int ipw2100_wx_get_wap(struct net
 	} else
 		memset(wrqu->ap_addr.sa_data, 0, ETH_ALEN);
 
-	IPW_DEBUG_WX("Getting WAP BSSID: %s\n",
-		     print_mac(mac, wrqu->ap_addr.sa_data));
+	IPW_DEBUG_WX("Getting WAP BSSID: %pM\n", wrqu->ap_addr.sa_data);
 	return 0;
 }
 
--- test-tree.orig/drivers/net/wireless/iwlwifi/iwl-3945-rs.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/iwlwifi/iwl-3945-rs.c	2008-10-25 02:16:00.000000000 +0200
@@ -649,7 +649,6 @@ static void rs_get_rate(void *priv_r, st
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
 	u16 fc, rate_mask;
 	struct iwl3945_priv *priv = (struct iwl3945_priv *)priv_r;
-	DECLARE_MAC_BUF(mac);
 
 	IWL_DEBUG_RATE("enter\n");
 
@@ -675,8 +674,8 @@ static void rs_get_rate(void *priv_r, st
 		u8 sta_id = iwl3945_hw_find_station(priv, hdr->addr1);
 
 		if (sta_id == IWL_INVALID_STATION) {
-			IWL_DEBUG_RATE("LQ: ADD station %s\n",
-				       print_mac(mac, hdr->addr1));
+			IWL_DEBUG_RATE("LQ: ADD station %pm\n",
+				       hdr->addr1);
 			sta_id = iwl3945_add_station(priv,
 				    hdr->addr1, 0, CMD_ASYNC);
 		}
--- test-tree.orig/drivers/net/wireless/iwlwifi/iwl-3945.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/iwlwifi/iwl-3945.c	2008-10-25 02:16:00.000000000 +0200
@@ -759,7 +759,6 @@ u8 iwl3945_hw_find_station(struct iwl394
 	int i;
 	int ret = IWL_INVALID_STATION;
 	unsigned long flags;
-	DECLARE_MAC_BUF(mac);
 
 	spin_lock_irqsave(&priv->sta_lock, flags);
 	for (i = IWL_STA_ID; i < priv->hw_setting.max_stations; i++)
@@ -770,8 +769,8 @@ u8 iwl3945_hw_find_station(struct iwl394
 			goto out;
 		}
 
-	IWL_DEBUG_INFO("can not find STA %s (total %d)\n",
-		       print_mac(mac, addr), priv->num_stations);
+	IWL_DEBUG_INFO("can not find STA %pM (total %d)\n",
+		       addr, priv->num_stations);
  out:
 	spin_unlock_irqrestore(&priv->sta_lock, flags);
 	return ret;
--- test-tree.orig/drivers/net/wireless/iwlwifi/iwl-agn-rs.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/iwlwifi/iwl-agn-rs.c	2008-10-25 02:16:00.000000000 +0200
@@ -357,11 +357,9 @@ static void rs_tl_turn_on_agg_for_tid(st
 				      struct iwl_lq_sta *lq_data, u8 tid,
 				      struct ieee80211_sta *sta)
 {
-	DECLARE_MAC_BUF(mac);
-
 	if (rs_tl_get_load(lq_data, tid) > IWL_AGG_LOAD_THRESHOLD) {
-		IWL_DEBUG_HT("Starting Tx agg: STA: %s tid: %d\n",
-				print_mac(mac, sta->addr), tid);
+		IWL_DEBUG_HT("Starting Tx agg: STA: %pM tid: %d\n",
+				sta->addr, tid);
 		ieee80211_start_tx_ba_session(priv->hw, sta->addr, tid);
 	}
 }
@@ -2132,11 +2130,10 @@ static void rs_get_rate(void *priv_r, st
 	if ((priv->iw_mode == NL80211_IFTYPE_ADHOC) &&
 	    !lq_sta->ibss_sta_added) {
 		u8 sta_id = iwl_find_station(priv, hdr->addr1);
-		DECLARE_MAC_BUF(mac);
 
 		if (sta_id == IWL_INVALID_STATION) {
-			IWL_DEBUG_RATE("LQ: ADD station %s\n",
-				       print_mac(mac, hdr->addr1));
+			IWL_DEBUG_RATE("LQ: ADD station %pM\n",
+				       hdr->addr1);
 			sta_id = iwl_add_station_flags(priv, hdr->addr1,
 							0, CMD_ASYNC, NULL);
 		}
@@ -2205,15 +2202,12 @@ static void rs_rate_init(void *priv_r, s
 	lq_sta->ibss_sta_added = 0;
 	if (priv->iw_mode == NL80211_IFTYPE_AP) {
 		u8 sta_id = iwl_find_station(priv, sta->addr);
-		DECLARE_MAC_BUF(mac);
 
 		/* for IBSS the call are from tasklet */
-		IWL_DEBUG_RATE("LQ: ADD station %s\n",
-			     print_mac(mac, sta->addr));
+		IWL_DEBUG_RATE("LQ: ADD station %pM\n", sta->addr);
 
 		if (sta_id == IWL_INVALID_STATION) {
-			IWL_DEBUG_RATE("LQ: ADD station %s\n",
-				       print_mac(mac, sta->addr));
+			IWL_DEBUG_RATE("LQ: ADD station %pM\n", sta->addr);
 			sta_id = iwl_add_station_flags(priv, sta->addr,
 							0, CMD_ASYNC, NULL);
 		}
--- test-tree.orig/drivers/net/wireless/iwlwifi/iwl-agn.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/iwlwifi/iwl-agn.c	2008-10-25 02:16:00.000000000 +0200
@@ -239,7 +239,6 @@ static int iwl4965_commit_rxon(struct iw
 {
 	/* cast away the const for active_rxon in this function */
 	struct iwl_rxon_cmd *active_rxon = (void *)&priv->active_rxon;
-	DECLARE_MAC_BUF(mac);
 	int ret;
 	bool new_assoc =
 		!!(priv->staging_rxon.filter_flags & RXON_FILTER_ASSOC_MSK);
@@ -300,10 +299,10 @@ static int iwl4965_commit_rxon(struct iw
 	IWL_DEBUG_INFO("Sending RXON\n"
 		       "* with%s RXON_FILTER_ASSOC_MSK\n"
 		       "* channel = %d\n"
-		       "* bssid = %s\n",
+		       "* bssid = %pM\n",
 		       (new_assoc ? "" : "out"),
 		       le16_to_cpu(priv->staging_rxon.channel),
-		       print_mac(mac, priv->staging_rxon.bssid_addr));
+		       priv->staging_rxon.bssid_addr);
 
 	iwl4965_set_rxon_hwcrypto(priv, !priv->hw_params.sw_crypto);
 
@@ -1464,7 +1463,6 @@ void iwl_rx_handle(struct iwl_priv *priv
 static void iwl4965_print_rx_config_cmd(struct iwl_priv *priv)
 {
 	struct iwl_rxon_cmd *rxon = &priv->staging_rxon;
-	DECLARE_MAC_BUF(mac);
 
 	IWL_DEBUG_RADIO("RX CONFIG:\n");
 	iwl_print_hex_dump(priv, IWL_DL_RADIO, (u8 *) rxon, sizeof(*rxon));
@@ -1476,10 +1474,8 @@ static void iwl4965_print_rx_config_cmd(
 	IWL_DEBUG_RADIO("u8 ofdm_basic_rates: 0x%02x\n",
 			rxon->ofdm_basic_rates);
 	IWL_DEBUG_RADIO("u8 cck_basic_rates: 0x%02x\n", rxon->cck_basic_rates);
-	IWL_DEBUG_RADIO("u8[6] node_addr: %s\n",
-			print_mac(mac, rxon->node_addr));
-	IWL_DEBUG_RADIO("u8[6] bssid_addr: %s\n",
-			print_mac(mac, rxon->bssid_addr));
+	IWL_DEBUG_RADIO("u8[6] node_addr: %pM\n", rxon->node_addr);
+	IWL_DEBUG_RADIO("u8[6] bssid_addr: %pM\n", rxon->bssid_addr);
 	IWL_DEBUG_RADIO("u16 assoc_id: 0x%x\n", le16_to_cpu(rxon->assoc_id));
 }
 #endif
@@ -2466,7 +2462,6 @@ static void iwl4965_post_associate(struc
 {
 	struct ieee80211_conf *conf = NULL;
 	int ret = 0;
-	DECLARE_MAC_BUF(mac);
 	unsigned long flags;
 
 	if (priv->iw_mode == NL80211_IFTYPE_AP) {
@@ -2474,9 +2469,8 @@ static void iwl4965_post_associate(struc
 		return;
 	}
 
-	IWL_DEBUG_ASSOC("Associated as %d to: %s\n",
-			priv->assoc_id,
-			print_mac(mac, priv->active_rxon.bssid_addr));
+	IWL_DEBUG_ASSOC("Associated as %d to: %pM\n",
+			priv->assoc_id, priv->active_rxon.bssid_addr);
 
 
 	if (test_bit(STATUS_EXIT_PENDING, &priv->status))
@@ -2722,7 +2716,6 @@ static int iwl4965_mac_add_interface(str
 {
 	struct iwl_priv *priv = hw->priv;
 	unsigned long flags;
-	DECLARE_MAC_BUF(mac);
 
 	IWL_DEBUG_MAC80211("enter: type %d\n", conf->type);
 
@@ -2739,7 +2732,7 @@ static int iwl4965_mac_add_interface(str
 	mutex_lock(&priv->mutex);
 
 	if (conf->mac_addr) {
-		IWL_DEBUG_MAC80211("Set %s\n", print_mac(mac, conf->mac_addr));
+		IWL_DEBUG_MAC80211("Set %pM\n", conf->mac_addr);
 		memcpy(priv->mac_addr, conf->mac_addr, ETH_ALEN);
 	}
 
@@ -2948,7 +2941,6 @@ static int iwl4965_mac_config_interface(
 				    struct ieee80211_if_conf *conf)
 {
 	struct iwl_priv *priv = hw->priv;
-	DECLARE_MAC_BUF(mac);
 	unsigned long flags;
 	int rc;
 
@@ -2983,8 +2975,7 @@ static int iwl4965_mac_config_interface(
 	mutex_lock(&priv->mutex);
 
 	if (conf->bssid)
-		IWL_DEBUG_MAC80211("bssid: %s\n",
-				   print_mac(mac, conf->bssid));
+		IWL_DEBUG_MAC80211("bssid: %pM\n", conf->bssid);
 
 /*
  * very dubious code was here; the probe filtering flag is never set:
@@ -2997,8 +2988,8 @@ static int iwl4965_mac_config_interface(
 		if (!conf->bssid) {
 			conf->bssid = priv->mac_addr;
 			memcpy(priv->bssid, priv->mac_addr, ETH_ALEN);
-			IWL_DEBUG_MAC80211("bssid was set to: %s\n",
-					   print_mac(mac, conf->bssid));
+			IWL_DEBUG_MAC80211("bssid was set to: %pM\n",
+					   conf->bssid);
 		}
 		if (priv->ibss_beacon)
 			dev_kfree_skb(priv->ibss_beacon);
@@ -3241,14 +3232,13 @@ static void iwl4965_mac_update_tkip_key(
 	unsigned long flags;
 	__le16 key_flags = 0;
 	int i;
-	DECLARE_MAC_BUF(mac);
 
 	IWL_DEBUG_MAC80211("enter\n");
 
 	sta_id = iwl_find_station(priv, addr);
 	if (sta_id == IWL_INVALID_STATION) {
-		IWL_DEBUG_MAC80211("leave - %s not in station map.\n",
-				   print_mac(mac, addr));
+		IWL_DEBUG_MAC80211("leave - %pM not in station map.\n",
+				   addr);
 		return;
 	}
 
@@ -3285,7 +3275,6 @@ static int iwl4965_mac_set_key(struct ie
 			   struct ieee80211_key_conf *key)
 {
 	struct iwl_priv *priv = hw->priv;
-	DECLARE_MAC_BUF(mac);
 	int ret = 0;
 	u8 sta_id = IWL_INVALID_STATION;
 	u8 is_default_wep_key = 0;
@@ -3303,8 +3292,8 @@ static int iwl4965_mac_set_key(struct ie
 
 	sta_id = iwl_find_station(priv, addr);
 	if (sta_id == IWL_INVALID_STATION) {
-		IWL_DEBUG_MAC80211("leave - %s not in station map.\n",
-				   print_mac(mac, addr));
+		IWL_DEBUG_MAC80211("leave - %pM not in station map.\n",
+				   addr);
 		return -EINVAL;
 
 	}
@@ -3405,10 +3394,9 @@ static int iwl4965_mac_ampdu_action(stru
 			     struct ieee80211_sta *sta, u16 tid, u16 *ssn)
 {
 	struct iwl_priv *priv = hw->priv;
-	DECLARE_MAC_BUF(mac);
 
-	IWL_DEBUG_HT("A-MPDU action on addr %s tid %d\n",
-		     print_mac(mac, sta->addr), tid);
+	IWL_DEBUG_HT("A-MPDU action on addr %pM tid %d\n",
+		     sta->addr, tid);
 
 	if (!(priv->cfg->sku & IWL_SKU_N))
 		return -EACCES;
@@ -4171,7 +4159,6 @@ static int iwl4965_pci_probe(struct pci_
 	struct ieee80211_hw *hw;
 	struct iwl_cfg *cfg = (struct iwl_cfg *)(ent->driver_data);
 	unsigned long flags;
-	DECLARE_MAC_BUF(mac);
 
 	/************************
 	 * 1. Allocating HW data
@@ -4280,7 +4267,7 @@ static int iwl4965_pci_probe(struct pci_
 
 	/* extract MAC Address */
 	iwl_eeprom_get_mac(priv, priv->mac_addr);
-	IWL_DEBUG_INFO("MAC address: %s\n", print_mac(mac, priv->mac_addr));
+	IWL_DEBUG_INFO("MAC address: %pM\n", priv->mac_addr);
 	SET_IEEE80211_PERM_ADDR(priv->hw, priv->mac_addr);
 
 	/************************
--- test-tree.orig/drivers/net/wireless/iwlwifi/iwl-debugfs.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/iwlwifi/iwl-debugfs.c	2008-10-25 02:16:00.000000000 +0200
@@ -228,7 +228,6 @@ static ssize_t iwl_dbgfs_stations_read(s
 	ssize_t ret;
 	/* Add 30 for initial string */
 	const size_t bufsz = 30 + sizeof(char) * 500 * (priv->num_stations);
-	DECLARE_MAC_BUF(mac);
 
 	buf = kmalloc(bufsz, GFP_KERNEL);
 	if (!buf)
@@ -242,7 +241,6 @@ static ssize_t iwl_dbgfs_stations_read(s
 		if (station->used) {
 			pos += scnprintf(buf + pos, bufsz - pos,
 					"station %d:\ngeneral data:\n", i+1);
-			print_mac(mac, station->sta.sta.addr);
 			pos += scnprintf(buf + pos, bufsz - pos, "id: %u\n",
 					station->sta.sta.sta_id);
 			pos += scnprintf(buf + pos, bufsz - pos, "mode: %u\n",
--- test-tree.orig/drivers/net/wireless/iwlwifi/iwl-sta.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/iwlwifi/iwl-sta.c	2008-10-25 02:16:00.000000000 +0200
@@ -45,7 +45,6 @@ u8 iwl_find_station(struct iwl_priv *pri
 	int start = 0;
 	int ret = IWL_INVALID_STATION;
 	unsigned long flags;
-	DECLARE_MAC_BUF(mac);
 
 	if ((priv->iw_mode == NL80211_IFTYPE_ADHOC) ||
 	    (priv->iw_mode == NL80211_IFTYPE_AP))
@@ -63,8 +62,8 @@ u8 iwl_find_station(struct iwl_priv *pri
 			goto out;
 		}
 
-	IWL_DEBUG_ASSOC_LIMIT("can not find STA %s total %d\n",
-			      print_mac(mac, addr), priv->num_stations);
+	IWL_DEBUG_ASSOC_LIMIT("can not find STA %pM total %d\n",
+			      addr, priv->num_stations);
 
  out:
 	spin_unlock_irqrestore(&priv->sta_lock, flags);
@@ -86,7 +85,6 @@ EXPORT_SYMBOL(iwl_get_ra_sta_id);
 static void iwl_sta_ucode_activate(struct iwl_priv *priv, u8 sta_id)
 {
 	unsigned long flags;
-	DECLARE_MAC_BUF(mac);
 
 	spin_lock_irqsave(&priv->sta_lock, flags);
 
@@ -94,8 +92,8 @@ static void iwl_sta_ucode_activate(struc
 		IWL_ERROR("ACTIVATE a non DRIVER active station %d\n", sta_id);
 
 	priv->stations[sta_id].used |= IWL_STA_UCODE_ACTIVE;
-	IWL_DEBUG_ASSOC("Added STA to Ucode: %s\n",
-			print_mac(mac, priv->stations[sta_id].sta.sta.addr));
+	IWL_DEBUG_ASSOC("Added STA to Ucode: %pM\n",
+			priv->stations[sta_id].sta.sta.addr);
 
 	spin_unlock_irqrestore(&priv->sta_lock, flags);
 }
@@ -237,7 +235,6 @@ u8 iwl_add_station_flags(struct iwl_priv
 	int sta_id = IWL_INVALID_STATION;
 	struct iwl_station_entry *station;
 	unsigned long flags_spin;
-	DECLARE_MAC_BUF(mac);
 
 	spin_lock_irqsave(&priv->sta_lock, flags_spin);
 	if (is_ap)
@@ -273,8 +270,8 @@ u8 iwl_add_station_flags(struct iwl_priv
 
 	station = &priv->stations[sta_id];
 	station->used = IWL_STA_DRIVER_ACTIVE;
-	IWL_DEBUG_ASSOC("Add STA to driver ID %d: %s\n",
-			sta_id, print_mac(mac, addr));
+	IWL_DEBUG_ASSOC("Add STA to driver ID %d: %pM\n",
+			sta_id, addr);
 	priv->num_stations++;
 
 	/* Set up the REPLY_ADD_STA command to send to device */
@@ -301,14 +298,11 @@ EXPORT_SYMBOL(iwl_add_station_flags);
 static void iwl_sta_ucode_deactivate(struct iwl_priv *priv, const char *addr)
 {
 	unsigned long flags;
-	DECLARE_MAC_BUF(mac);
-
 	u8 sta_id = iwl_find_station(priv, addr);
 
 	BUG_ON(sta_id == IWL_INVALID_STATION);
 
-	IWL_DEBUG_ASSOC("Removed STA from Ucode: %s\n",
-			print_mac(mac, addr));
+	IWL_DEBUG_ASSOC("Removed STA from Ucode: %pM\n", addr);
 
 	spin_lock_irqsave(&priv->sta_lock, flags);
 
@@ -415,7 +409,6 @@ int iwl_remove_station(struct iwl_priv *
 	int sta_id = IWL_INVALID_STATION;
 	int i, ret = -EINVAL;
 	unsigned long flags;
-	DECLARE_MAC_BUF(mac);
 
 	spin_lock_irqsave(&priv->sta_lock, flags);
 
@@ -435,18 +428,18 @@ int iwl_remove_station(struct iwl_priv *
 	if (unlikely(sta_id == IWL_INVALID_STATION))
 		goto out;
 
-	IWL_DEBUG_ASSOC("Removing STA from driver:%d  %s\n",
-		sta_id, print_mac(mac, addr));
+	IWL_DEBUG_ASSOC("Removing STA from driver:%d  %pM\n",
+		sta_id, addr);
 
 	if (!(priv->stations[sta_id].used & IWL_STA_DRIVER_ACTIVE)) {
-		IWL_ERROR("Removing %s but non DRIVER active\n",
-				print_mac(mac, addr));
+		IWL_ERROR("Removing %pM but non DRIVER active\n",
+				addr);
 		goto out;
 	}
 
 	if (!(priv->stations[sta_id].used & IWL_STA_UCODE_ACTIVE)) {
-		IWL_ERROR("Removing %s but non UCODE active\n",
-				print_mac(mac, addr));
+		IWL_ERROR("Removing %pM but non UCODE active\n",
+				addr);
 		goto out;
 	}
 
@@ -927,7 +920,6 @@ int iwl_get_sta_id(struct iwl_priv *priv
 {
 	int sta_id;
 	u16 fc = le16_to_cpu(hdr->frame_control);
-	DECLARE_MAC_BUF(mac);
 
 	/* If this frame is broadcast or management, use broadcast station id */
 	if (((fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA) ||
@@ -962,9 +954,9 @@ int iwl_get_sta_id(struct iwl_priv *priv
 		if (sta_id != IWL_INVALID_STATION)
 			return sta_id;
 
-		IWL_DEBUG_DROP("Station %s not in station map. "
+		IWL_DEBUG_DROP("Station %pM not in station map. "
 			       "Defaulting to broadcast...\n",
-			       print_mac(mac, hdr->addr1));
+			       hdr->addr1);
 		iwl_print_hex_dump(priv, IWL_DL_DROP, (u8 *) hdr, sizeof(*hdr));
 		return priv->hw_params.bcast_sta_id;
 
--- test-tree.orig/drivers/net/wireless/iwlwifi/iwl-tx.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/iwlwifi/iwl-tx.c	2008-10-25 02:16:00.000000000 +0200
@@ -830,10 +830,8 @@ int iwl_tx_skb(struct iwl_priv *priv, st
 	/* Find (or create) index into station table for destination station */
 	sta_id = iwl_get_sta_id(priv, hdr);
 	if (sta_id == IWL_INVALID_STATION) {
-		DECLARE_MAC_BUF(mac);
-
-		IWL_DEBUG_DROP("Dropping - INVALID STATION: %s\n",
-			       print_mac(mac, hdr->addr1));
+		IWL_DEBUG_DROP("Dropping - INVALID STATION: %pM\n",
+			       hdr->addr1);
 		goto drop;
 	}
 
@@ -1248,15 +1246,14 @@ int iwl_tx_agg_start(struct iwl_priv *pr
 	int ret;
 	unsigned long flags;
 	struct iwl_tid_data *tid_data;
-	DECLARE_MAC_BUF(mac);
 
 	if (likely(tid < ARRAY_SIZE(default_tid_to_tx_fifo)))
 		tx_fifo = default_tid_to_tx_fifo[tid];
 	else
 		return -EINVAL;
 
-	IWL_WARNING("%s on ra = %s tid = %d\n",
-			__func__, print_mac(mac, ra), tid);
+	IWL_WARNING("%s on ra = %pM tid = %d\n",
+			__func__, ra, tid);
 
 	sta_id = iwl_find_station(priv, ra);
 	if (sta_id == IWL_INVALID_STATION)
@@ -1301,7 +1298,6 @@ int iwl_tx_agg_stop(struct iwl_priv *pri
 	struct iwl_tid_data *tid_data;
 	int ret, write_ptr, read_ptr;
 	unsigned long flags;
-	DECLARE_MAC_BUF(mac);
 
 	if (!ra) {
 		IWL_ERROR("ra = NULL\n");
@@ -1467,7 +1463,6 @@ void iwl_rx_reply_compressed_ba(struct i
 	int index;
 	struct iwl_tx_queue *txq = NULL;
 	struct iwl_ht_agg *agg;
-	DECLARE_MAC_BUF(mac);
 
 	/* "flow" corresponds to Tx queue */
 	u16 scd_flow = le16_to_cpu(ba_resp->scd_flow);
@@ -1489,10 +1484,10 @@ void iwl_rx_reply_compressed_ba(struct i
 
 	/* TODO: Need to get this copy more safely - now good for debug */
 
-	IWL_DEBUG_TX_REPLY("REPLY_COMPRESSED_BA [%d]Received from %s, "
+	IWL_DEBUG_TX_REPLY("REPLY_COMPRESSED_BA [%d]Received from %pM, "
 			   "sta_id = %d\n",
 			   agg->wait_for_ba,
-			   print_mac(mac, (u8 *) &ba_resp->sta_addr_lo32),
+			   (u8 *) &ba_resp->sta_addr_lo32,
 			   ba_resp->sta_id);
 	IWL_DEBUG_TX_REPLY("TID = %d, SeqCtl = %d, bitmap = 0x%llx, scd_flow = "
 			   "%d, scd_ssn = %d\n",
--- test-tree.orig/drivers/net/wireless/iwlwifi/iwl3945-base.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/iwlwifi/iwl3945-base.c	2008-10-25 02:16:00.000000000 +0200
@@ -446,7 +446,6 @@ u8 iwl3945_add_station(struct iwl3945_pr
 	int index = IWL_INVALID_STATION;
 	struct iwl3945_station_entry *station;
 	unsigned long flags_spin;
-	DECLARE_MAC_BUF(mac);
 	u8 rate;
 
 	spin_lock_irqsave(&priv->sta_lock, flags_spin);
@@ -480,7 +479,7 @@ u8 iwl3945_add_station(struct iwl3945_pr
 		return index;
 	}
 
-	IWL_DEBUG_ASSOC("Add STA ID %d: %s\n", index, print_mac(mac, addr));
+	IWL_DEBUG_ASSOC("Add STA ID %d: %pM\n", index, addr);
 	station = &priv->stations[index];
 	station->used = 1;
 	priv->num_stations++;
@@ -1063,7 +1062,6 @@ static int iwl3945_commit_rxon(struct iw
 	/* cast away the const for active_rxon in this function */
 	struct iwl3945_rxon_cmd *active_rxon = (void *)&priv->active_rxon;
 	int rc = 0;
-	DECLARE_MAC_BUF(mac);
 
 	if (!iwl3945_is_alive(priv))
 		return -1;
@@ -1124,11 +1122,11 @@ static int iwl3945_commit_rxon(struct iw
 	IWL_DEBUG_INFO("Sending RXON\n"
 		       "* with%s RXON_FILTER_ASSOC_MSK\n"
 		       "* channel = %d\n"
-		       "* bssid = %s\n",
+		       "* bssid = %pM\n",
 		       ((priv->staging_rxon.filter_flags &
 			 RXON_FILTER_ASSOC_MSK) ? "" : "out"),
 		       le16_to_cpu(priv->staging_rxon.channel),
-		       print_mac(mac, priv->staging_rxon.bssid_addr));
+		       priv->staging_rxon.bssid_addr);
 
 	/* Apply the new configuration */
 	rc = iwl3945_send_cmd_pdu(priv, REPLY_RXON,
@@ -2482,8 +2480,6 @@ static int iwl3945_get_sta_id(struct iwl
 	/* If this frame is going out to an IBSS network, find the station,
 	 * or create a new station table entry */
 	case NL80211_IFTYPE_ADHOC: {
-		DECLARE_MAC_BUF(mac);
-
 		/* Create new station table entry */
 		sta_id = iwl3945_hw_find_station(priv, hdr->addr1);
 		if (sta_id != IWL_INVALID_STATION)
@@ -2494,9 +2490,9 @@ static int iwl3945_get_sta_id(struct iwl
 		if (sta_id != IWL_INVALID_STATION)
 			return sta_id;
 
-		IWL_DEBUG_DROP("Station %s not in station map. "
+		IWL_DEBUG_DROP("Station %pM not in station map. "
 			       "Defaulting to broadcast...\n",
-			       print_mac(mac, hdr->addr1));
+			       hdr->addr1);
 		iwl3945_print_hex_dump(IWL_DL_DROP, (u8 *) hdr, sizeof(*hdr));
 		return priv->hw_setting.bcast_sta_id;
 	}
@@ -2579,10 +2575,8 @@ static int iwl3945_tx_skb(struct iwl3945
 	/* Find (or create) index into station table for destination station */
 	sta_id = iwl3945_get_sta_id(priv, hdr);
 	if (sta_id == IWL_INVALID_STATION) {
-		DECLARE_MAC_BUF(mac);
-
-		IWL_DEBUG_DROP("Dropping - INVALID STATION: %s\n",
-			       print_mac(mac, hdr->addr1));
+		IWL_DEBUG_DROP("Dropping - INVALID STATION: %pM\n",
+			       hdr->addr1);
 		goto drop;
 	}
 
@@ -4019,8 +4013,6 @@ static int iwl3945_tx_queue_update_write
 #ifdef CONFIG_IWL3945_DEBUG
 static void iwl3945_print_rx_config_cmd(struct iwl3945_rxon_cmd *rxon)
 {
-	DECLARE_MAC_BUF(mac);
-
 	IWL_DEBUG_RADIO("RX CONFIG:\n");
 	iwl3945_print_hex_dump(IWL_DL_RADIO, (u8 *) rxon, sizeof(*rxon));
 	IWL_DEBUG_RADIO("u16 channel: 0x%x\n", le16_to_cpu(rxon->channel));
@@ -4031,10 +4023,8 @@ static void iwl3945_print_rx_config_cmd(
 	IWL_DEBUG_RADIO("u8 ofdm_basic_rates: 0x%02x\n",
 			rxon->ofdm_basic_rates);
 	IWL_DEBUG_RADIO("u8 cck_basic_rates: 0x%02x\n", rxon->cck_basic_rates);
-	IWL_DEBUG_RADIO("u8[6] node_addr: %s\n",
-			print_mac(mac, rxon->node_addr));
-	IWL_DEBUG_RADIO("u8[6] bssid_addr: %s\n",
-			print_mac(mac, rxon->bssid_addr));
+	IWL_DEBUG_RADIO("u8[6] node_addr: %pM\n", rxon->node_addr);
+	IWL_DEBUG_RADIO("u8[6] bssid_addr: %pM\n", rxon->bssid_addr);
 	IWL_DEBUG_RADIO("u16 assoc_id: 0x%x\n", le16_to_cpu(rxon->assoc_id));
 }
 #endif
@@ -6321,7 +6311,6 @@ static void iwl3945_post_associate(struc
 {
 	int rc = 0;
 	struct ieee80211_conf *conf = NULL;
-	DECLARE_MAC_BUF(mac);
 
 	if (priv->iw_mode == NL80211_IFTYPE_AP) {
 		IWL_ERROR("%s Should not be called in AP mode\n", __func__);
@@ -6329,9 +6318,8 @@ static void iwl3945_post_associate(struc
 	}
 
 
-	IWL_DEBUG_ASSOC("Associated as %d to: %s\n",
-			priv->assoc_id,
-			print_mac(mac, priv->active_rxon.bssid_addr));
+	IWL_DEBUG_ASSOC("Associated as %d to: %pM\n",
+			priv->assoc_id, priv->active_rxon.bssid_addr);
 
 	if (test_bit(STATUS_EXIT_PENDING, &priv->status))
 		return;
@@ -6592,7 +6580,6 @@ static int iwl3945_mac_add_interface(str
 {
 	struct iwl3945_priv *priv = hw->priv;
 	unsigned long flags;
-	DECLARE_MAC_BUF(mac);
 
 	IWL_DEBUG_MAC80211("enter: type %d\n", conf->type);
 
@@ -6609,7 +6596,7 @@ static int iwl3945_mac_add_interface(str
 	mutex_lock(&priv->mutex);
 
 	if (conf->mac_addr) {
-		IWL_DEBUG_MAC80211("Set: %s\n", print_mac(mac, conf->mac_addr));
+		IWL_DEBUG_MAC80211("Set: %pM\n", conf->mac_addr);
 		memcpy(priv->mac_addr, conf->mac_addr, ETH_ALEN);
 	}
 
@@ -6778,7 +6765,6 @@ static int iwl3945_mac_config_interface(
 				    struct ieee80211_if_conf *conf)
 {
 	struct iwl3945_priv *priv = hw->priv;
-	DECLARE_MAC_BUF(mac);
 	unsigned long flags;
 	int rc;
 
@@ -6816,8 +6802,7 @@ static int iwl3945_mac_config_interface(
 	mutex_lock(&priv->mutex);
 
 	if (conf->bssid)
-		IWL_DEBUG_MAC80211("bssid: %s\n",
-				   print_mac(mac, conf->bssid));
+		IWL_DEBUG_MAC80211("bssid: %pM\n", conf->bssid);
 
 /*
  * very dubious code was here; the probe filtering flag is never set:
@@ -6830,8 +6815,8 @@ static int iwl3945_mac_config_interface(
 		if (!conf->bssid) {
 			conf->bssid = priv->mac_addr;
 			memcpy(priv->bssid, priv->mac_addr, ETH_ALEN);
-			IWL_DEBUG_MAC80211("bssid was set to: %s\n",
-					   print_mac(mac, conf->bssid));
+			IWL_DEBUG_MAC80211("bssid was set to: %pM\n",
+					   conf->bssid);
 		}
 		if (priv->ibss_beacon)
 			dev_kfree_skb(priv->ibss_beacon);
@@ -7072,10 +7057,8 @@ static int iwl3945_mac_set_key(struct ie
 
 	sta_id = iwl3945_hw_find_station(priv, addr);
 	if (sta_id == IWL_INVALID_STATION) {
-		DECLARE_MAC_BUF(mac);
-
-		IWL_DEBUG_MAC80211("leave - %s not in station map.\n",
-				   print_mac(mac, addr));
+		IWL_DEBUG_MAC80211("leave - %pM not in station map.\n",
+				   addr);
 		return -EINVAL;
 	}
 
@@ -7870,7 +7853,6 @@ static int iwl3945_pci_probe(struct pci_
 	struct ieee80211_hw *hw;
 	struct iwl_3945_cfg *cfg = (struct iwl_3945_cfg *)(ent->driver_data);
 	unsigned long flags;
-	DECLARE_MAC_BUF(mac);
 
 	/* Disabling hardware scan means that mac80211 will perform scans
 	 * "the hard way", rather than using device's scan. */
@@ -8045,7 +8027,7 @@ static int iwl3945_pci_probe(struct pci_
 	}
 	/* MAC Address location in EEPROM same for 3945/4965 */
 	get_eeprom_mac(priv, priv->mac_addr);
-	IWL_DEBUG_INFO("MAC address: %s\n", print_mac(mac, priv->mac_addr));
+	IWL_DEBUG_INFO("MAC address: %pM\n", priv->mac_addr);
 	SET_IEEE80211_PERM_ADDR(priv->hw, priv->mac_addr);
 
 	err = iwl3945_init_channel_map(priv);
--- test-tree.orig/drivers/net/wireless/libertas/assoc.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/libertas/assoc.c	2008-10-25 02:16:00.000000000 +0200
@@ -151,7 +151,6 @@ static int lbs_adhoc_join(struct lbs_pri
 	struct cmd_ds_802_11_ad_hoc_join cmd;
 	struct bss_descriptor *bss = &assoc_req->bss;
 	u8 preamble = RADIO_PREAMBLE_LONG;
-	DECLARE_MAC_BUF(mac);
 	u16 ratesize = 0;
 	int ret = 0;
 
@@ -226,8 +225,8 @@ static int lbs_adhoc_join(struct lbs_pri
 	       bss->capability, CAPINFO_MASK);
 
 	/* information on BSSID descriptor passed to FW */
-	lbs_deb_join("ADHOC_J_CMD: BSSID = %s, SSID = '%s'\n",
-			print_mac(mac, cmd.bss.bssid), cmd.bss.ssid);
+	lbs_deb_join("ADHOC_J_CMD: BSSID = %pM, SSID = '%s'\n",
+			cmd.bss.bssid, cmd.bss.ssid);
 
 	/* Only v8 and below support setting these */
 	if (priv->fwrelease < 0x09000000) {
@@ -752,17 +751,15 @@ static int assoc_helper_bssid(struct lbs
 {
 	int ret = 0;
 	struct bss_descriptor * bss;
-	DECLARE_MAC_BUF(mac);
 
-	lbs_deb_enter_args(LBS_DEB_ASSOC, "BSSID %s",
-		print_mac(mac, assoc_req->bssid));
+	lbs_deb_enter_args(LBS_DEB_ASSOC, "BSSID %pM", assoc_req->bssid);
 
 	/* Search for index position in list for requested MAC */
 	bss = lbs_find_bssid_in_list(priv, assoc_req->bssid,
 			    assoc_req->mode);
 	if (bss == NULL) {
-		lbs_deb_assoc("ASSOC: WAP: BSSID %s not found, "
-			"cannot associate.\n", print_mac(mac, assoc_req->bssid));
+		lbs_deb_assoc("ASSOC: WAP: BSSID %pM not found, "
+			"cannot associate.\n", assoc_req->bssid);
 		goto out;
 	}
 
@@ -1208,7 +1205,6 @@ void lbs_association_worker(struct work_
 	struct assoc_request * assoc_req = NULL;
 	int ret = 0;
 	int find_any_ssid = 0;
-	DECLARE_MAC_BUF(mac);
 
 	lbs_deb_enter(LBS_DEB_ASSOC);
 
@@ -1228,13 +1224,13 @@ void lbs_association_worker(struct work_
 		"    chann:     %d\n"
 		"    band:      %d\n"
 		"    mode:      %d\n"
-		"    BSSID:     %s\n"
+		"    BSSID:     %pM\n"
 		"    secinfo:  %s%s%s\n"
 		"    auth_mode: %d\n",
 		assoc_req->flags,
 		escape_essid(assoc_req->ssid, assoc_req->ssid_len),
 		assoc_req->channel, assoc_req->band, assoc_req->mode,
-		print_mac(mac, assoc_req->bssid),
+		assoc_req->bssid,
 		assoc_req->secinfo.WPAenabled ? " WPA" : "",
 		assoc_req->secinfo.WPA2enabled ? " WPA2" : "",
 		assoc_req->secinfo.wep_enabled ? " WEP" : "",
@@ -1357,8 +1353,8 @@ void lbs_association_worker(struct work_
 		}
 
 		if (success) {
-			lbs_deb_assoc("associated to %s\n",
-				print_mac(mac, priv->curbssparams.bssid));
+			lbs_deb_assoc("associated to %pM\n",
+				priv->curbssparams.bssid);
 			lbs_prepare_and_send_command(priv,
 				CMD_802_11_RSSI,
 				0, CMD_OPTION_WAITFORRSP, 0, NULL);
@@ -1478,7 +1474,6 @@ int lbs_cmd_80211_authenticate(struct lb
 	struct cmd_ds_802_11_authenticate *pauthenticate = &cmd->params.auth;
 	int ret = -1;
 	u8 *bssid = pdata_buf;
-	DECLARE_MAC_BUF(mac);
 
 	lbs_deb_enter(LBS_DEB_JOIN);
 
@@ -1505,8 +1500,8 @@ int lbs_cmd_80211_authenticate(struct lb
 
 	memcpy(pauthenticate->macaddr, bssid, ETH_ALEN);
 
-	lbs_deb_join("AUTH_CMD: BSSID %s, auth 0x%x\n",
-		print_mac(mac, bssid), pauthenticate->authtype);
+	lbs_deb_join("AUTH_CMD: BSSID %pM, auth 0x%x\n",
+		bssid, pauthenticate->authtype);
 	ret = 0;
 
 out:
@@ -1770,7 +1765,6 @@ static int lbs_adhoc_post(struct lbs_pri
 	struct cmd_ds_802_11_ad_hoc_result *adhoc_resp;
 	union iwreq_data wrqu;
 	struct bss_descriptor *bss;
-	DECLARE_MAC_BUF(mac);
 
 	lbs_deb_enter(LBS_DEB_JOIN);
 
@@ -1819,9 +1813,9 @@ static int lbs_adhoc_post(struct lbs_pri
 	wrqu.ap_addr.sa_family = ARPHRD_ETHER;
 	wireless_send_event(priv->dev, SIOCGIWAP, &wrqu, NULL);
 
-	lbs_deb_join("ADHOC_RESP: Joined/started '%s', BSSID %s, channel %d\n",
+	lbs_deb_join("ADHOC_RESP: Joined/started '%s', BSSID %pM, channel %d\n",
 		     escape_essid(bss->ssid, bss->ssid_len),
-		     print_mac(mac, priv->curbssparams.bssid),
+		     priv->curbssparams.bssid,
 		     priv->curbssparams.channel);
 
 done:
--- test-tree.orig/drivers/net/wireless/libertas/cmd.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/libertas/cmd.c	2008-10-25 02:16:00.000000000 +0200
@@ -87,7 +87,6 @@ int lbs_update_hw_spec(struct lbs_privat
 	struct cmd_ds_get_hw_spec cmd;
 	int ret = -1;
 	u32 i;
-	DECLARE_MAC_BUF(mac);
 
 	lbs_deb_enter(LBS_DEB_CMD);
 
@@ -110,8 +109,8 @@ int lbs_update_hw_spec(struct lbs_privat
 	 * CF card    firmware 5.0.16p0:   cap 0x00000303
 	 * USB dongle firmware 5.110.17p2: cap 0x00000303
 	 */
-	lbs_pr_info("%s, fw %u.%u.%up%u, cap 0x%08x\n",
-		print_mac(mac, cmd.permanentaddr),
+	lbs_pr_info("%pM, fw %u.%u.%up%u, cap 0x%08x\n",
+		cmd.permanentaddr,
 		priv->fwrelease >> 24 & 0xff,
 		priv->fwrelease >> 16 & 0xff,
 		priv->fwrelease >>  8 & 0xff,
--- test-tree.orig/drivers/net/wireless/libertas/debugfs.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/libertas/debugfs.c	2008-10-25 02:16:00.000000000 +0200
@@ -65,7 +65,6 @@ static ssize_t lbs_getscantable(struct f
 	int numscansdone = 0, res;
 	unsigned long addr = get_zeroed_page(GFP_KERNEL);
 	char *buf = (char *)addr;
-	DECLARE_MAC_BUF(mac);
 	struct bss_descriptor * iter_bss;
 
 	pos += snprintf(buf+pos, len-pos,
@@ -77,10 +76,9 @@ static ssize_t lbs_getscantable(struct f
 		u16 privacy = (iter_bss->capability & WLAN_CAPABILITY_PRIVACY);
 		u16 spectrum_mgmt = (iter_bss->capability & WLAN_CAPABILITY_SPECTRUM_MGMT);
 
-		pos += snprintf(buf+pos, len-pos,
-			"%02u| %03d | %04d | %s |",
+		pos += snprintf(buf+pos, len-pos, "%02u| %03d | %04d | %pM |",
 			numscansdone, iter_bss->channel, iter_bss->rssi,
-			print_mac(mac, iter_bss->bssid));
+			iter_bss->bssid);
 		pos += snprintf(buf+pos, len-pos, " %04x-", iter_bss->capability);
 		pos += snprintf(buf+pos, len-pos, "%c%c%c |",
 				ibss ? 'A' : 'I', privacy ? 'P' : ' ',
--- test-tree.orig/drivers/net/wireless/libertas/main.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/libertas/main.c	2008-10-25 02:16:00.000000000 +0200
@@ -588,7 +588,6 @@ static int lbs_add_mcast_addrs(struct cm
 {
 	int i = nr_addrs;
 	struct dev_mc_list *mc_list;
-	DECLARE_MAC_BUF(mac);
 
 	if ((dev->flags & (IFF_UP|IFF_MULTICAST)) != (IFF_UP|IFF_MULTICAST))
 		return nr_addrs;
@@ -596,16 +595,16 @@ static int lbs_add_mcast_addrs(struct cm
 	netif_addr_lock_bh(dev);
 	for (mc_list = dev->mc_list; mc_list; mc_list = mc_list->next) {
 		if (mac_in_list(cmd->maclist, nr_addrs, mc_list->dmi_addr)) {
-			lbs_deb_net("mcast address %s:%s skipped\n", dev->name,
-				    print_mac(mac, mc_list->dmi_addr));
+			lbs_deb_net("mcast address %s:%pM skipped\n", dev->name,
+				    mc_list->dmi_addr);
 			continue;
 		}
 
 		if (i == MRVDRV_MAX_MULTICAST_LIST_SIZE)
 			break;
 		memcpy(&cmd->maclist[6*i], mc_list->dmi_addr, ETH_ALEN);
-		lbs_deb_net("mcast address %s:%s added to filter\n", dev->name,
-			    print_mac(mac, mc_list->dmi_addr));
+		lbs_deb_net("mcast address %s:%pM added to filter\n", dev->name,
+			    mc_list->dmi_addr);
 		i++;
 	}
 	netif_addr_unlock_bh(dev);
--- test-tree.orig/drivers/net/wireless/libertas/scan.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/libertas/scan.c	2008-10-25 02:16:00.000000000 +0200
@@ -359,7 +359,6 @@ int lbs_scan_networks(struct lbs_private
 #ifdef CONFIG_LIBERTAS_DEBUG
 	struct bss_descriptor *iter;
 	int i = 0;
-	DECLARE_MAC_BUF(mac);
 #endif
 
 	lbs_deb_enter_args(LBS_DEB_SCAN, "full_scan %d", full_scan);
@@ -451,8 +450,8 @@ int lbs_scan_networks(struct lbs_private
 	mutex_lock(&priv->lock);
 	lbs_deb_scan("scan table:\n");
 	list_for_each_entry(iter, &priv->network_list, list)
-		lbs_deb_scan("%02d: BSSID %s, RSSI %d, SSID '%s'\n",
-			     i++, print_mac(mac, iter->bssid), iter->rssi,
+		lbs_deb_scan("%02d: BSSID %pM, RSSI %d, SSID '%s'\n",
+			     i++, iter->bssid, iter->rssi,
 			     escape_essid(iter->ssid, iter->ssid_len));
 	mutex_unlock(&priv->lock);
 #endif
@@ -512,7 +511,6 @@ static int lbs_process_bss(struct bss_de
 	struct ieeetypes_dsparamset *pDS;
 	struct ieeetypes_cfparamset *pCF;
 	struct ieeetypes_ibssparamset *pibss;
-	DECLARE_MAC_BUF(mac);
 	struct ieeetypes_countryinfoset *pcountryinfo;
 	uint8_t *pos, *end, *p;
 	uint8_t n_ex_rates = 0, got_basic_rates = 0, n_basic_rates = 0;
@@ -544,7 +542,7 @@ static int lbs_process_bss(struct bss_de
 	*bytesleft -= beaconsize;
 
 	memcpy(bss->bssid, pos, ETH_ALEN);
-	lbs_deb_scan("process_bss: BSSID %s\n", print_mac(mac, bss->bssid));
+	lbs_deb_scan("process_bss: BSSID %pM\n", bss->bssid);
 	pos += ETH_ALEN;
 
 	if ((end - pos) < 12) {
@@ -1151,7 +1149,6 @@ static int lbs_ret_80211_scan(struct lbs
 		struct bss_descriptor new;
 		struct bss_descriptor *found = NULL;
 		struct bss_descriptor *oldest = NULL;
-		DECLARE_MAC_BUF(mac);
 
 		/* Process the data fields and IEs returned for this BSS */
 		memset(&new, 0, sizeof (struct bss_descriptor));
@@ -1190,7 +1187,7 @@ static int lbs_ret_80211_scan(struct lbs
 			continue;
 		}
 
-		lbs_deb_scan("SCAN_RESP: BSSID %s\n", print_mac(mac, new.bssid));
+		lbs_deb_scan("SCAN_RESP: BSSID %pM\n", new.bssid);
 
 		/* Copy the locally created newbssentry to the scan table */
 		memcpy(found, &new, offsetof(struct bss_descriptor, list));
--- test-tree.orig/drivers/net/wireless/libertas/wext.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/libertas/wext.c	2008-10-25 02:16:00.000000000 +0200
@@ -2104,7 +2104,6 @@ static int lbs_set_wap(struct net_device
 	struct lbs_private *priv = dev->priv;
 	struct assoc_request * assoc_req;
 	int ret = 0;
-	DECLARE_MAC_BUF(mac);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -2114,7 +2113,7 @@ static int lbs_set_wap(struct net_device
 	if (awrq->sa_family != ARPHRD_ETHER)
 		return -EINVAL;
 
-	lbs_deb_wext("ASSOC: WAP: sa_data %s\n", print_mac(mac, awrq->sa_data));
+	lbs_deb_wext("ASSOC: WAP: sa_data %pM\n", awrq->sa_data);
 
 	mutex_lock(&priv->lock);
 
--- test-tree.orig/drivers/net/wireless/libertas_tf/cmd.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/wireless/libertas_tf/cmd.c	2008-10-25 02:16:00.000000000 +0200
@@ -79,7 +79,6 @@ int lbtf_update_hw_spec(struct lbtf_priv
 	struct cmd_ds_get_hw_spec cmd;
 	int ret = -1;
 	u32 i;
-	DECLARE_MAC_BUF(mac);
 
 	memset(&cmd, 0, sizeof(cmd));
 	cmd.hdr.size = cpu_to_le16(sizeof(cmd));
@@ -96,8 +95,8 @@ int lbtf_update_hw_spec(struct lbtf_priv
 	priv->fwrelease = (priv->fwrelease << 8) |
 		(priv->fwrelease >> 24 & 0xff);
 
-	printk(KERN_INFO "libertastf: %s, fw %u.%u.%up%u, cap 0x%08x\n",
-		print_mac(mac, cmd.permanentaddr),
+	printk(KERN_INFO "libertastf: %pM, fw %u.%u.%up%u, cap 0x%08x\n",
+		cmd.permanentaddr,
 		priv->fwrelease >> 24 & 0xff,
 		priv->fwrelease >> 16 & 0xff,
 		priv->fwrelease >>  8 & 0xff,
--- test-tree.orig/drivers/net/wireless/mac80211_hwsim.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/wireless/mac80211_hwsim.c	2008-10-25 02:16:00.000000000 +0200
@@ -301,10 +301,9 @@ static void mac80211_hwsim_stop(struct i
 static int mac80211_hwsim_add_interface(struct ieee80211_hw *hw,
 					struct ieee80211_if_init_conf *conf)
 {
-	DECLARE_MAC_BUF(mac);
-	printk(KERN_DEBUG "%s:%s (type=%d mac_addr=%s)\n",
+	printk(KERN_DEBUG "%s:%s (type=%d mac_addr=%pM)\n",
 	       wiphy_name(hw->wiphy), __func__, conf->type,
-	       print_mac(mac, conf->mac_addr));
+	       conf->mac_addr);
 	hwsim_set_magic(conf->vif);
 	return 0;
 }
@@ -313,10 +312,9 @@ static int mac80211_hwsim_add_interface(
 static void mac80211_hwsim_remove_interface(
 	struct ieee80211_hw *hw, struct ieee80211_if_init_conf *conf)
 {
-	DECLARE_MAC_BUF(mac);
-	printk(KERN_DEBUG "%s:%s (type=%d mac_addr=%s)\n",
+	printk(KERN_DEBUG "%s:%s (type=%d mac_addr=%pM)\n",
 	       wiphy_name(hw->wiphy), __func__, conf->type,
-	       print_mac(mac, conf->mac_addr));
+	       conf->mac_addr);
 	hwsim_check_magic(conf->vif);
 	hwsim_clear_magic(conf->vif);
 }
@@ -505,7 +503,6 @@ static int __init init_mac80211_hwsim(vo
 	u8 addr[ETH_ALEN];
 	struct mac80211_hwsim_data *data;
 	struct ieee80211_hw *hw;
-	DECLARE_MAC_BUF(mac);
 
 	if (radios < 1 || radios > 100)
 		return -EINVAL;
@@ -588,9 +585,9 @@ static int __init init_mac80211_hwsim(vo
 			goto failed_hw;
 		}
 
-		printk(KERN_DEBUG "%s: hwaddr %s registered\n",
+		printk(KERN_DEBUG "%s: hwaddr %pM registered\n",
 		       wiphy_name(hw->wiphy),
-		       print_mac(mac, hw->wiphy->perm_addr));
+		       hw->wiphy->perm_addr);
 
 		setup_timer(&data->beacon_timer, mac80211_hwsim_beacon,
 			    (unsigned long) hw);
--- test-tree.orig/drivers/net/wireless/netwave_cs.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/netwave_cs.c	2008-10-25 02:16:00.000000000 +0200
@@ -737,7 +737,6 @@ static int netwave_pcmcia_config(struct 
     win_req_t req;
     memreq_t mem;
     u_char __iomem *ramBase = NULL;
-    DECLARE_MAC_BUF(mac);
 
     DEBUG(0, "netwave_pcmcia_config(0x%p)\n", link);
 
@@ -808,12 +807,12 @@ static int netwave_pcmcia_config(struct 
 	dev->dev_addr[i] = readb(ramBase + NETWAVE_EREG_PA + i);
 
     printk(KERN_INFO "%s: Netwave: port %#3lx, irq %d, mem %lx, "
-	   "id %c%c, hw_addr %s\n",
+	   "id %c%c, hw_addr %pM\n",
 	   dev->name, dev->base_addr, dev->irq,
 	   (u_long) ramBase,
 	   (int) readb(ramBase+NETWAVE_EREG_NI),
 	   (int) readb(ramBase+NETWAVE_EREG_NI+1),
-	   print_mac(mac, dev->dev_addr));
+	   dev->dev_addr);
 
     /* get revision words */
     printk(KERN_DEBUG "Netwave_reset: revision %04x %04x\n", 
--- test-tree.orig/drivers/net/wireless/orinoco.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/orinoco.c	2008-10-25 02:16:00.000000000 +0200
@@ -1477,12 +1477,11 @@ static void orinoco_rx(struct net_device
 			   MICHAEL_MIC_LEN)) {
 			union iwreq_data wrqu;
 			struct iw_michaelmicfailure wxmic;
-			DECLARE_MAC_BUF(mac);
 
 			printk(KERN_WARNING "%s: "
-			       "Invalid Michael MIC in data frame from %s, "
+			       "Invalid Michael MIC in data frame from %pM, "
 			       "using key %i\n",
-			       dev->name, print_mac(mac, src), key_id);
+			       dev->name, src, key_id);
 
 			/* TODO: update stats */
 
@@ -3277,7 +3276,6 @@ static int orinoco_init(struct net_devic
 	struct hermes_idstring nickbuf;
 	u16 reclen;
 	int len;
-	DECLARE_MAC_BUF(mac);
 
 	/* No need to lock, the hw_unavailable flag is already set in
 	 * alloc_orinocodev() */
@@ -3348,8 +3346,8 @@ static int orinoco_init(struct net_devic
 		goto out;
 	}
 
-	printk(KERN_DEBUG "%s: MAC address %s\n",
-	       dev->name, print_mac(mac, dev->dev_addr));
+	printk(KERN_DEBUG "%s: MAC address %pM\n",
+	       dev->name, dev->dev_addr);
 
 	/* Get the station name */
 	err = hermes_read_ltv(hw, USER_BAP, HERMES_RID_CNFOWNNAME,
--- test-tree.orig/drivers/net/wireless/p54/p54common.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/p54/p54common.c	2008-10-25 02:16:00.000000000 +0200
@@ -320,7 +320,6 @@ static int p54_parse_eeprom(struct ieee8
 	int err;
 	u8 *end = (u8 *)eeprom + len;
 	u16 synth;
-	DECLARE_MAC_BUF(mac);
 
 	wrap = (struct eeprom_pda_wrap *) eeprom;
 	entry = (void *)wrap->data + le16_to_cpu(wrap->len);
@@ -445,9 +444,9 @@ static int p54_parse_eeprom(struct ieee8
 		SET_IEEE80211_PERM_ADDR(dev, perm_addr);
 	}
 
-	printk(KERN_INFO "%s: hwaddr %s, MAC:isl38%02x RF:%s\n",
+	printk(KERN_INFO "%s: hwaddr %pM, MAC:isl38%02x RF:%s\n",
 		wiphy_name(dev->wiphy),
-		print_mac(mac, dev->wiphy->perm_addr),
+		dev->wiphy->perm_addr,
 		priv->version, p54_rf_chips[priv->rxhw]);
 
 	return 0;
--- test-tree.orig/drivers/net/wireless/prism54/isl_ioctl.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/prism54/isl_ioctl.c	2008-10-25 02:16:00.000000000 +0200
@@ -2028,12 +2028,11 @@ static void
 format_event(islpci_private *priv, char *dest, const char *str,
 	     const struct obj_mlme *mlme, u16 *length, int error)
 {
-	DECLARE_MAC_BUF(mac);
 	int n = snprintf(dest, IW_CUSTOM_MAX,
-			 "%s %s %s %s (%2.2X)",
+			 "%s %s %pM %s (%2.2X)",
 			 str,
 			 ((priv->iw_mode == IW_MODE_MASTER) ? "from" : "to"),
-			 print_mac(mac, mlme->address),
+			 mlme->address,
 			 (error ? (mlme->code ? " : REJECTED " : " : ACCEPTED ")
 			  : ""), mlme->code);
 	BUG_ON(n > IW_CUSTOM_MAX);
@@ -2113,7 +2112,6 @@ prism54_wpa_bss_ie_add(islpci_private *p
 {
 	struct list_head *ptr;
 	struct islpci_bss_wpa_ie *bss = NULL;
-	DECLARE_MAC_BUF(mac);
 
 	if (wpa_ie_len > MAX_WPA_IE_LEN)
 		wpa_ie_len = MAX_WPA_IE_LEN;
@@ -2154,7 +2152,7 @@ prism54_wpa_bss_ie_add(islpci_private *p
 		bss->last_update = jiffies;
 	} else {
 		printk(KERN_DEBUG "Failed to add BSS WPA entry for "
-		       "%s\n", print_mac(mac, bssid));
+		       "%pM\n", bssid);
 	}
 
 	/* expire old entries from WPA list */
@@ -2219,7 +2217,6 @@ prism54_process_bss_data(islpci_private 
 {
 	struct ieee80211_beacon_phdr *hdr;
 	u8 *pos, *end;
-	DECLARE_MAC_BUF(mac);
 
 	if (!priv->wpa)
 		return;
@@ -2230,7 +2227,7 @@ prism54_process_bss_data(islpci_private 
 	while (pos < end) {
 		if (pos + 2 + pos[1] > end) {
 			printk(KERN_DEBUG "Parsing Beacon/ProbeResp failed "
-			       "for %s\n", print_mac(mac, addr));
+			       "for %pM\n", addr);
 			return;
 		}
 		if (pos[0] == WLAN_EID_GENERIC && pos[1] >= 4 &&
@@ -2269,7 +2266,6 @@ prism54_process_trap_helper(islpci_priva
 	size_t len = 0; /* u16, better? */
 	u8 *payload = NULL, *pos = NULL;
 	int ret;
-	DECLARE_MAC_BUF(mac);
 
 	/* I think all trapable objects are listed here.
 	 * Some oids have a EX version. The difference is that they are emitted
@@ -2358,8 +2354,8 @@ prism54_process_trap_helper(islpci_priva
 			break;
 
 		memcpy(&confirm->address, mlmeex->address, ETH_ALEN);
-		printk(KERN_DEBUG "Authenticate from: address:\t%s\n",
-		       print_mac(mac, mlmeex->address));
+		printk(KERN_DEBUG "Authenticate from: address:\t%pM\n",
+		       mlmeex->address);
 		confirm->id = -1; /* or mlmeex->id ? */
 		confirm->state = 0; /* not used */
 		confirm->code = 0;
@@ -2404,8 +2400,8 @@ prism54_process_trap_helper(islpci_priva
 		wpa_ie_len = prism54_wpa_bss_ie_get(priv, mlmeex->address, wpa_ie);
 
 		if (!wpa_ie_len) {
-			printk(KERN_DEBUG "No WPA IE found from address:\t%s\n",
-			       print_mac(mac, mlmeex->address));
+			printk(KERN_DEBUG "No WPA IE found from address:\t%pM\n",
+			       mlmeex->address);
 			kfree(confirm);
 			break;
 		}
@@ -2441,8 +2437,8 @@ prism54_process_trap_helper(islpci_priva
 		wpa_ie_len = prism54_wpa_bss_ie_get(priv, mlmeex->address, wpa_ie);
 
 		if (!wpa_ie_len) {
-			printk(KERN_DEBUG "No WPA IE found from address:\t%s\n",
-			       print_mac(mac, mlmeex->address));
+			printk(KERN_DEBUG "No WPA IE found from address:\t%pM\n",
+			       mlmeex->address);
 			kfree(confirm);
 			break;
 		}
--- test-tree.orig/drivers/net/wireless/ray_cs.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/ray_cs.c	2008-10-25 02:16:00.000000000 +0200
@@ -414,7 +414,6 @@ static int ray_config(struct pcmcia_devi
     memreq_t mem;
     struct net_device *dev = (struct net_device *)link->priv;
     ray_dev_t *local = netdev_priv(dev);
-    DECLARE_MAC_BUF(mac);
 
     DEBUG(1, "ray_config(0x%p)\n", link);
 
@@ -485,8 +484,8 @@ static int ray_config(struct pcmcia_devi
     strcpy(local->node.dev_name, dev->name);
     link->dev_node = &local->node;
 
-    printk(KERN_INFO "%s: RayLink, irq %d, hw_addr %s\n",
-       dev->name, dev->irq, print_mac(mac, dev->dev_addr));
+    printk(KERN_INFO "%s: RayLink, irq %d, hw_addr %pM\n",
+       dev->name, dev->irq, dev->dev_addr);
 
     return 0;
 
@@ -2595,7 +2594,6 @@ static int ray_cs_proc_show(struct seq_f
     UCHAR *p;
     struct freq_hop_element *pfh;
     UCHAR c[33];
-    DECLARE_MAC_BUF(mac);
 
     link = this_device;
     if (!link)
@@ -2623,8 +2621,7 @@ static int ray_cs_proc_show(struct seq_f
                    nettype[local->sparm.b5.a_network_type], c);
 
     p = local->bss_id;
-    seq_printf(m, "BSSID                = %s\n",
-                   print_mac(mac, p));
+    seq_printf(m, "BSSID                = %pM\n", p);
 
     seq_printf(m, "Country code         = %d\n",
                    local->sparm.b5.a_curr_country_code);
--- test-tree.orig/drivers/net/wireless/rndis_wlan.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/rndis_wlan.c	2008-10-25 02:16:00.000000000 +0200
@@ -1276,12 +1276,11 @@ static int rndis_iw_get_bssid(struct net
 	struct usbnet *usbdev = dev->priv;
 	unsigned char bssid[ETH_ALEN];
 	int ret;
-	DECLARE_MAC_BUF(mac);
 
 	ret = get_bssid(usbdev, bssid);
 
 	if (ret == 0)
-		devdbg(usbdev, "SIOCGIWAP: %s", print_mac(mac, bssid));
+		devdbg(usbdev, "SIOCGIWAP: %pM", bssid);
 	else
 		devdbg(usbdev, "SIOCGIWAP: <not associated>");
 
@@ -1297,10 +1296,9 @@ static int rndis_iw_set_bssid(struct net
 {
 	struct usbnet *usbdev = dev->priv;
 	u8 *bssid = (u8 *)wrqu->ap_addr.sa_data;
-	DECLARE_MAC_BUF(mac);
 	int ret;
 
-	devdbg(usbdev, "SIOCSIWAP: %s", print_mac(mac, bssid));
+	devdbg(usbdev, "SIOCSIWAP: %pM", bssid);
 
 	ret = rndis_set_oid(usbdev, OID_802_11_BSSID, bssid, ETH_ALEN);
 
@@ -1660,11 +1658,10 @@ static char *rndis_translate_scan(struct
 	u32 beacon, atim;
 	struct iw_event iwe;
 	unsigned char sbuf[32];
-	DECLARE_MAC_BUF(mac);
 
 	bssid_len = le32_to_cpu(bssid->length);
 
-	devdbg(usbdev, "BSSID %s", print_mac(mac, bssid->mac));
+	devdbg(usbdev, "BSSID %pM", bssid->mac);
 	iwe.cmd = SIOCGIWAP;
 	iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 	memcpy(iwe.u.ap_addr.sa_data, bssid->mac, ETH_ALEN);
--- test-tree.orig/drivers/net/wireless/rt2x00/rt2400pci.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/rt2x00/rt2400pci.c	2008-10-25 02:16:00.000000000 +0200
@@ -1313,10 +1313,8 @@ static int rt2400pci_validate_eeprom(str
 	 */
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
 	if (!is_valid_ether_addr(mac)) {
-		DECLARE_MAC_BUF(macbuf);
-
 		random_ether_addr(mac);
-		EEPROM(rt2x00dev, "MAC: %s\n", print_mac(macbuf, mac));
+		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_ANTENNA, &word);
--- test-tree.orig/drivers/net/wireless/rt2x00/rt2500pci.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/rt2x00/rt2500pci.c	2008-10-25 02:16:00.000000000 +0200
@@ -1451,11 +1451,8 @@ static int rt2500pci_validate_eeprom(str
 	 */
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
 	if (!is_valid_ether_addr(mac)) {
-		DECLARE_MAC_BUF(macbuf);
-
 		random_ether_addr(mac);
-		EEPROM(rt2x00dev, "MAC: %s\n",
-		       print_mac(macbuf, mac));
+		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_ANTENNA, &word);
--- test-tree.orig/drivers/net/wireless/rt2x00/rt2500usb.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/rt2x00/rt2500usb.c	2008-10-25 02:16:00.000000000 +0200
@@ -1319,10 +1319,8 @@ static int rt2500usb_validate_eeprom(str
 	 */
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
 	if (!is_valid_ether_addr(mac)) {
-		DECLARE_MAC_BUF(macbuf);
-
 		random_ether_addr(mac);
-		EEPROM(rt2x00dev, "MAC: %s\n", print_mac(macbuf, mac));
+		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_ANTENNA, &word);
--- test-tree.orig/drivers/net/wireless/rt2x00/rt61pci.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/rt2x00/rt61pci.c	2008-10-25 02:16:00.000000000 +0200
@@ -2175,10 +2175,8 @@ static int rt61pci_validate_eeprom(struc
 	 */
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
 	if (!is_valid_ether_addr(mac)) {
-		DECLARE_MAC_BUF(macbuf);
-
 		random_ether_addr(mac);
-		EEPROM(rt2x00dev, "MAC: %s\n", print_mac(macbuf, mac));
+		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_ANTENNA, &word);
--- test-tree.orig/drivers/net/wireless/rt2x00/rt73usb.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/rt2x00/rt73usb.c	2008-10-25 02:16:00.000000000 +0200
@@ -1781,10 +1781,8 @@ static int rt73usb_validate_eeprom(struc
 	 */
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
 	if (!is_valid_ether_addr(mac)) {
-		DECLARE_MAC_BUF(macbuf);
-
 		random_ether_addr(mac);
-		EEPROM(rt2x00dev, "MAC: %s\n", print_mac(macbuf, mac));
+		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
 	}
 
 	rt2x00_eeprom_read(rt2x00dev, EEPROM_ANTENNA, &word);
--- test-tree.orig/drivers/net/wireless/rtl8180_dev.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/rtl8180_dev.c	2008-10-25 02:16:00.000000000 +0200
@@ -806,7 +806,6 @@ static int __devinit rtl8180_probe(struc
 	const char *chip_name, *rf_name = NULL;
 	u32 reg;
 	u16 eeprom_val;
-	DECLARE_MAC_BUF(mac);
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -1002,8 +1001,8 @@ static int __devinit rtl8180_probe(struc
 		goto err_iounmap;
 	}
 
-	printk(KERN_INFO "%s: hwaddr %s, %s + %s\n",
-	       wiphy_name(dev->wiphy), print_mac(mac, dev->wiphy->perm_addr),
+	printk(KERN_INFO "%s: hwaddr %pM, %s + %s\n",
+	       wiphy_name(dev->wiphy), dev->wiphy->perm_addr,
 	       chip_name, priv->rf->name);
 
 	return 0;
--- test-tree.orig/drivers/net/wireless/rtl8187_dev.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/rtl8187_dev.c	2008-10-25 02:16:00.000000000 +0200
@@ -1026,7 +1026,6 @@ static int __devinit rtl8187_probe(struc
 	const char *chip_name;
 	u16 txpwr, reg;
 	int err, i;
-	DECLARE_MAC_BUF(mac);
 
 	dev = ieee80211_alloc_hw(sizeof(*priv), &rtl8187_ops);
 	if (!dev) {
@@ -1209,8 +1208,8 @@ static int __devinit rtl8187_probe(struc
 	}
 	mutex_init(&priv->conf_mutex);
 
-	printk(KERN_INFO "%s: hwaddr %s, %s V%d + %s\n",
-	       wiphy_name(dev->wiphy), print_mac(mac, dev->wiphy->perm_addr),
+	printk(KERN_INFO "%s: hwaddr %pM, %s V%d + %s\n",
+	       wiphy_name(dev->wiphy), dev->wiphy->perm_addr,
 	       chip_name, priv->asic_rev, priv->rf->name);
 
 	return 0;
--- test-tree.orig/drivers/net/wireless/wavelan.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/wavelan.c	2008-10-25 02:16:00.000000000 +0200
@@ -859,8 +859,6 @@ static void wv_82586_reconfig(struct net
  */
 static void wv_psa_show(psa_t * p)
 {
-	DECLARE_MAC_BUF(mac);
-
 	printk(KERN_DEBUG "##### WaveLAN PSA contents: #####\n");
 	printk(KERN_DEBUG "psa_io_base_addr_1: 0x%02X %02X %02X %02X\n",
 	       p->psa_io_base_addr_1,
@@ -872,13 +870,10 @@ static void wv_psa_show(psa_t * p)
 	printk(KERN_DEBUG "psa_holi_params: 0x%02x, ", p->psa_holi_params);
 	printk("psa_int_req_no: %d\n", p->psa_int_req_no);
 #ifdef DEBUG_SHOW_UNUSED
-	printk(KERN_DEBUG "psa_unused0[]: %s\n",
-	       print_mac(mac, p->psa_unused0));
+	printk(KERN_DEBUG "psa_unused0[]: %pM\n", p->psa_unused0);
 #endif				/* DEBUG_SHOW_UNUSED */
-	printk(KERN_DEBUG "psa_univ_mac_addr[]: %s\n",
-	       print_mac(mac, p->psa_univ_mac_addr));
-	printk(KERN_DEBUG "psa_local_mac_addr[]: %s\n",
-	       print_mac(mac, p->psa_local_mac_addr));
+	printk(KERN_DEBUG "psa_univ_mac_addr[]: %pM\n", p->psa_univ_mac_addr);
+	printk(KERN_DEBUG "psa_local_mac_addr[]: %pM\n", p->psa_local_mac_addr);
 	printk(KERN_DEBUG "psa_univ_local_sel: %d, ",
 	       p->psa_univ_local_sel);
 	printk("psa_comp_number: %d, ", p->psa_comp_number);
@@ -1220,14 +1215,13 @@ static inline void wv_packet_info(u8 * p
 {				/* Name of the function */
 	int i;
 	int maxi;
-	DECLARE_MAC_BUF(mac);
 
 	printk(KERN_DEBUG
-	       "%s: %s(): dest %s, length %d\n",
-	       msg1, msg2, print_mac(mac, p), length);
+	       "%s: %s(): dest %pM, length %d\n",
+	       msg1, msg2, p, length);
 	printk(KERN_DEBUG
-	       "%s: %s(): src %s, type 0x%02X%02X\n",
-	       msg1, msg2, print_mac(mac, &p[6]), p[12], p[13]);
+	       "%s: %s(): src %pM, type 0x%02X%02X\n",
+	       msg1, msg2, &p[6], p[12], p[13]);
 
 #ifdef DEBUG_PACKET_DUMP
 
@@ -1258,9 +1252,6 @@ static void wv_init_info(struct net_devi
 	short ioaddr = dev->base_addr;
 	net_local *lp = (net_local *) dev->priv;
 	psa_t psa;
-#ifdef DEBUG_BASIC_SHOW
-	DECLARE_MAC_BUF(mac);
-#endif
 
 	/* Read the parameter storage area */
 	psa_read(ioaddr, lp->hacr, 0, (unsigned char *) &psa, sizeof(psa));
@@ -1277,8 +1268,8 @@ static void wv_init_info(struct net_devi
 
 #ifdef DEBUG_BASIC_SHOW
 	/* Now, let's go for the basic stuff. */
-	printk(KERN_NOTICE "%s: WaveLAN at %#x, %s, IRQ %d",
-	       dev->name, ioaddr, print_mac(mac, dev->dev_addr), dev->irq);
+	printk(KERN_NOTICE "%s: WaveLAN at %#x, %pM, IRQ %d",
+	       dev->name, ioaddr, dev->dev_addr, dev->irq);
 
 	/* Print current network ID. */
 	if (psa.psa_nwid_select)
@@ -3565,15 +3556,11 @@ static void wv_82586_config(struct net_d
 			      WAVELAN_ADDR_SIZE >> 1);
 
 #ifdef DEBUG_CONFIG_INFO
- {
-		DECLARE_MAC_BUF(mac);
 		printk(KERN_DEBUG
 		       "%s: wv_82586_config(): set %d multicast addresses:\n",
 		       dev->name, lp->mc_count);
 		for (dmi = dev->mc_list; dmi; dmi = dmi->next)
-			printk(KERN_DEBUG " %s\n",
-			       print_mac(mac, dmi->dmi_addr));
- }
+			printk(KERN_DEBUG " %pM\n", dmi->dmi_addr);
 #endif
 	}
 
--- test-tree.orig/drivers/net/wireless/wavelan_cs.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/wavelan_cs.c	2008-10-25 02:16:00.000000000 +0200
@@ -1020,7 +1020,6 @@ wv_82593_reconfig(struct net_device *	de
 static void
 wv_psa_show(psa_t *	p)
 {
-  DECLARE_MAC_BUF(mac);
   printk(KERN_DEBUG "##### wavelan psa contents: #####\n");
   printk(KERN_DEBUG "psa_io_base_addr_1: 0x%02X %02X %02X %02X\n",
 	 p->psa_io_base_addr_1,
@@ -1034,13 +1033,10 @@ wv_psa_show(psa_t *	p)
   printk(KERN_DEBUG "psa_holi_params: 0x%02x, ", p->psa_holi_params);
   printk("psa_int_req_no: %d\n", p->psa_int_req_no);
 #ifdef DEBUG_SHOW_UNUSED
-  printk(KERN_DEBUG "psa_unused0[]: %s\n",
-	 print_mac(mac, p->psa_unused0));
+  printk(KERN_DEBUG "psa_unused0[]: %pM\n", p->psa_unused0);
 #endif	/* DEBUG_SHOW_UNUSED */
-  printk(KERN_DEBUG "psa_univ_mac_addr[]: %s\n",
-	 print_mac(mac, p->psa_univ_mac_addr));
-  printk(KERN_DEBUG "psa_local_mac_addr[]: %s\n",
-	 print_mac(mac, p->psa_local_mac_addr));
+  printk(KERN_DEBUG "psa_univ_mac_addr[]: %pM\n", p->psa_univ_mac_addr);
+  printk(KERN_DEBUG "psa_local_mac_addr[]: %pM\n", p->psa_local_mac_addr);
   printk(KERN_DEBUG "psa_univ_local_sel: %d, ", p->psa_univ_local_sel);
   printk("psa_comp_number: %d, ", p->psa_comp_number);
   printk("psa_thr_pre_set: 0x%02x\n", p->psa_thr_pre_set);
@@ -1238,12 +1234,11 @@ wv_packet_info(u_char *		p,		/* Packet t
 {
   int		i;
   int		maxi;
-  DECLARE_MAC_BUF(mac);
 
-  printk(KERN_DEBUG "%s: %s(): dest %s, length %d\n",
-	 msg1, msg2, print_mac(mac, p), length);
-  printk(KERN_DEBUG "%s: %s(): src %s, type 0x%02X%02X\n",
-	 msg1, msg2, print_mac(mac, &p[6]), p[12], p[13]);
+  printk(KERN_DEBUG "%s: %s(): dest %pM, length %d\n",
+	 msg1, msg2, p, length);
+  printk(KERN_DEBUG "%s: %s(): src %pM, type 0x%02X%02X\n",
+	 msg1, msg2, &p[6], p[12], p[13]);
 
 #ifdef DEBUG_PACKET_DUMP
 
@@ -1274,7 +1269,6 @@ wv_init_info(struct net_device *	dev)
 {
   unsigned int	base = dev->base_addr;
   psa_t		psa;
-  DECLARE_MAC_BUF(mac);
 
   /* Read the parameter storage area */
   psa_read(dev, 0, (unsigned char *) &psa, sizeof(psa));
@@ -1291,10 +1285,8 @@ wv_init_info(struct net_device *	dev)
 
 #ifdef DEBUG_BASIC_SHOW
   /* Now, let's go for the basic stuff */
-  printk(KERN_NOTICE "%s: WaveLAN: port %#x, irq %d, "
-	 "hw_addr %s",
-	 dev->name, base, dev->irq,
-	 print_mac(mac, dev->dev_addr));
+  printk(KERN_NOTICE "%s: WaveLAN: port %#x, irq %d, hw_addr %pM",
+	 dev->name, base, dev->irq, dev->dev_addr);
 
   /* Print current network id */
   if(psa.psa_nwid_select)
@@ -3647,12 +3639,10 @@ wv_82593_config(struct net_device *	dev)
       int			addrs_len = WAVELAN_ADDR_SIZE * lp->mc_count;
 
 #ifdef DEBUG_CONFIG_INFO
-      DECLARE_MAC_BUF(mac);
       printk(KERN_DEBUG "%s: wv_hw_config(): set %d multicast addresses:\n",
 	     dev->name, lp->mc_count);
       for(dmi=dev->mc_list; dmi; dmi=dmi->next)
-	printk(KERN_DEBUG " %s\n",
-	       print_mac(mac, dmi->dmi_addr));
+	printk(KERN_DEBUG " %pM\n", dmi->dmi_addr);
 #endif
 
       /* Initialize adapter's ethernet multicast addresses */
--- test-tree.orig/drivers/net/wireless/wl3501_cs.c	2008-10-25 02:14:59.000000000 +0200
+++ test-tree/drivers/net/wireless/wl3501_cs.c	2008-10-25 02:16:00.000000000 +0200
@@ -860,10 +860,9 @@ static int wl3501_esbq_confirm(struct wl
 static void wl3501_online(struct net_device *dev)
 {
 	struct wl3501_card *this = netdev_priv(dev);
-	DECLARE_MAC_BUF(mac);
 
-	printk(KERN_INFO "%s: Wireless LAN online. BSSID: %s\n",
-	       dev->name, print_mac(mac, this->bssid));
+	printk(KERN_INFO "%s: Wireless LAN online. BSSID: %pM\n",
+	       dev->name, this->bssid);
 	netif_wake_queue(dev);
 }
 
@@ -1965,7 +1964,6 @@ static int wl3501_config(struct pcmcia_d
 	struct net_device *dev = link->priv;
 	int i = 0, j, last_fn, last_ret;
 	struct wl3501_card *this;
-	DECLARE_MAC_BUF(mac);
 
 	/* Try allocating IO ports.  This tries a few fixed addresses.  If you
 	 * want, you can also read the card's config table to pick addresses --
@@ -2024,9 +2022,9 @@ static int wl3501_config(struct pcmcia_d
 
 	/* print probe information */
 	printk(KERN_INFO "%s: wl3501 @ 0x%3.3x, IRQ %d, "
-	       "MAC addr in flash ROM:%s\n",
+	       "MAC addr in flash ROM:%pM\n",
 	       dev->name, this->base_addr, (int)dev->irq,
-	       print_mac(mac, dev->dev_addr));
+	       dev->dev_addr);
 	/*
 	 * Initialize card parameters - added by jss
 	 */
--- test-tree.orig/drivers/net/wireless/zd1211rw/zd_chip.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/zd1211rw/zd_chip.c	2008-10-25 02:16:00.000000000 +0200
@@ -378,7 +378,6 @@ int zd_write_mac_addr(struct zd_chip *ch
 		[0] = { .addr = CR_MAC_ADDR_P1 },
 		[1] = { .addr = CR_MAC_ADDR_P2 },
 	};
-	DECLARE_MAC_BUF(mac);
 
 	if (mac_addr) {
 		reqs[0].value = (mac_addr[3] << 24)
@@ -387,8 +386,7 @@ int zd_write_mac_addr(struct zd_chip *ch
 			      |  mac_addr[0];
 		reqs[1].value = (mac_addr[5] <<  8)
 			      |  mac_addr[4];
-		dev_dbg_f(zd_chip_dev(chip),
-			"mac addr %s\n", print_mac(mac, mac_addr));
+		dev_dbg_f(zd_chip_dev(chip), "mac addr %pM\n", mac_addr);
 	} else {
 		dev_dbg_f(zd_chip_dev(chip), "set NULL mac\n");
 	}
--- test-tree.orig/drivers/net/wireless/zd1211rw/zd_mac.c	2008-10-25 02:14:58.000000000 +0200
+++ test-tree/drivers/net/wireless/zd1211rw/zd_mac.c	2008-10-25 02:16:00.000000000 +0200
@@ -852,14 +852,12 @@ static void zd_op_configure_filter(struc
 	if (*new_flags & (FIF_PROMISC_IN_BSS | FIF_ALLMULTI)) {
 		zd_mc_add_all(&hash);
 	} else {
-		DECLARE_MAC_BUF(macbuf);
-
 		zd_mc_clear(&hash);
 		for (i = 0; i < mc_count; i++) {
 			if (!mclist)
 				break;
-			dev_dbg_f(zd_mac_dev(mac), "mc addr %s\n",
-				  print_mac(macbuf, mclist->dmi_addr));
+			dev_dbg_f(zd_mac_dev(mac), "mc addr %pM\n",
+				  mclist->dmi_addr);
 			zd_mc_add_addr(&hash, mclist->dmi_addr);
 			mclist = mclist->next;
 		}
--- test-tree.orig/drivers/net/yellowfin.c	2008-10-25 02:15:03.000000000 +0200
+++ test-tree/drivers/net/yellowfin.c	2008-10-25 02:16:00.000000000 +0200
@@ -374,7 +374,6 @@ static int __devinit yellowfin_init_one(
 #else
 	int bar = 1;
 #endif
-	DECLARE_MAC_BUF(mac);
 
 /* when built into the kernel, we only print version if device is found */
 #ifndef MODULE
@@ -481,10 +480,10 @@ static int __devinit yellowfin_init_one(
 	if (i)
 		goto err_out_unmap_status;
 
-	printk(KERN_INFO "%s: %s type %8x at %p, %s, IRQ %d.\n",
+	printk(KERN_INFO "%s: %s type %8x at %p, %pM, IRQ %d.\n",
 		   dev->name, pci_id_tbl[chip_idx].name,
 		   ioread32(ioaddr + ChipRev), ioaddr,
-		   print_mac(mac, dev->dev_addr), irq);
+		   dev->dev_addr, irq);
 
 	if (np->drv_flags & HasMII) {
 		int phy, phy_idx = 0;
@@ -1100,11 +1099,9 @@ static int yellowfin_rx(struct net_devic
 			memcmp(le32_to_cpu(yp->rx_ring_dma +
 				entry*sizeof(struct yellowfin_desc)),
 				"\377\377\377\377\377\377", 6) != 0) {
-			if (bogus_rx++ == 0) {
-				DECLARE_MAC_BUF(mac);
-				printk(KERN_WARNING "%s: Bad frame to %s\n",
-					   dev->name, print_mac(mac, buf_addr));
-			}
+			if (bogus_rx++ == 0)
+				printk(KERN_WARNING "%s: Bad frame to %pM\n",
+					   dev->name, buf_addr);
 #endif
 		} else {
 			struct sk_buff *skb;
--- test-tree.orig/drivers/net/znet.c	2008-10-25 02:15:04.000000000 +0200
+++ test-tree/drivers/net/znet.c	2008-10-25 02:16:00.000000000 +0200
@@ -370,7 +370,6 @@ static int __init znet_probe (void)
 	struct net_device *dev;
 	char *p;
 	int err = -ENOMEM;
-	DECLARE_MAC_BUF(mac);
 
 	/* This code scans the region 0xf0000 to 0xfffff for a "NETIDBLK". */
 	for(p = (char *)phys_to_virt(0xf0000); p < (char *)phys_to_virt(0x100000); p++)
@@ -397,9 +396,9 @@ static int __init znet_probe (void)
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = netinfo->netid[i];
 
-	printk(KERN_INFO "%s: ZNET at %#3lx, %s"
+	printk(KERN_INFO "%s: ZNET at %#3lx, %pM"
 	       ", using IRQ %d DMA %d and %d.\n",
-	       dev->name, dev->base_addr, print_mac(mac, dev->dev_addr),
+	       dev->name, dev->base_addr, dev->dev_addr,
 	       dev->irq, netinfo->dma1, netinfo->dma2);
 
 	if (znet_debug > 1) {
--- test-tree.orig/drivers/net/zorro8390.c	2008-10-25 02:15:00.000000000 +0200
+++ test-tree/drivers/net/zorro8390.c	2008-10-25 02:16:00.000000000 +0200
@@ -151,7 +151,6 @@ static int __devinit zorro8390_init(stru
 	0x00, 0x02, 0x04, 0x06, 0x08, 0x0a, 0x0c, 0x0e,
 	0x10, 0x12, 0x14, 0x16, 0x18, 0x1a, 0x1c, 0x1e,
     };
-    DECLARE_MAC_BUF(mac);
 
     /* Reset card. Who knows what dain-bramaged state it was left in. */
     {
@@ -216,7 +215,7 @@ static int __devinit zorro8390_init(stru
 	dev->dev_addr[i] = SA_prom[i];
 
 #ifdef DEBUG
-    printk("%s", print_mac(mac, dev->dev_addr));
+    printk("%pM", dev->dev_addr);
 #endif
 
     ei_status.name = name;
@@ -244,8 +243,8 @@ static int __devinit zorro8390_init(stru
 	return err;
     }
 
-    printk(KERN_INFO "%s: %s at 0x%08lx, Ethernet Address %s\n",
-	   dev->name, name, board, print_mac(mac, dev->dev_addr));
+    printk(KERN_INFO "%s: %s at 0x%08lx, Ethernet Address %pM\n",
+	   dev->name, name, board, dev->dev_addr);
 
     return 0;
 }
--- test-tree.orig/drivers/usb/gadget/u_ether.c	2008-10-25 02:14:57.000000000 +0200
+++ test-tree/drivers/usb/gadget/u_ether.c	2008-10-25 02:16:00.000000000 +0200
@@ -787,10 +787,8 @@ int __init gether_setup(struct usb_gadge
 		dev_dbg(&g->dev, "register_netdev failed, %d\n", status);
 		free_netdev(net);
 	} else {
-		DECLARE_MAC_BUF(tmp);
-
-		INFO(dev, "MAC %s\n", print_mac(tmp, net->dev_addr));
-		INFO(dev, "HOST MAC %s\n", print_mac(tmp, dev->host_mac));
+		INFO(dev, "MAC %pM\n", net->dev_addr);
+		INFO(dev, "HOST MAC %pM\n", dev->host_mac);
 
 		the_dev = dev;
 	}
--- test-tree.orig/net/802/tr.c	2008-10-25 02:14:57.000000000 +0200
+++ test-tree/net/802/tr.c	2008-10-25 02:16:00.000000000 +0200
@@ -285,10 +285,7 @@ void tr_source_route(struct sk_buff *skb
 		if(entry)
 		{
 #if TR_SR_DEBUG
-{
-DECLARE_MAC_BUF(mac);
-printk("source routing for %s\n",print_mac(mac, trh->daddr));
-}
+printk("source routing for %pM\n", trh->daddr);
 #endif
 			if(!entry->local_ring && (ntohs(entry->rcf) & TR_RCF_LEN_MASK) >> 8)
 			{
@@ -370,9 +367,8 @@ static void tr_add_rif_info(struct trh_h
 	if(entry==NULL)
 	{
 #if TR_SR_DEBUG
-		DECLARE_MAC_BUF(mac);
-		printk("adding rif_entry: addr:%s rcf:%04X\n",
-		       print_mac(mac, trh->saddr), ntohs(trh->rcf));
+		printk("adding rif_entry: addr:%pM rcf:%04X\n",
+		       trh->saddr, ntohs(trh->rcf));
 #endif
 		/*
 		 *	Allocate our new entry. A failure to allocate loses
@@ -417,11 +413,8 @@ static void tr_add_rif_info(struct trh_h
 			 !(trh->rcf & htons(TR_RCF_BROADCAST_MASK)))
 		    {
 #if TR_SR_DEBUG
-{
-DECLARE_MAC_BUF(mac);
-printk("updating rif_entry: addr:%s rcf:%04X\n",
-		print_mac(mac, trh->saddr), ntohs(trh->rcf));
-}
+printk("updating rif_entry: addr:%pM rcf:%04X\n",
+		trh->saddr, ntohs(trh->rcf));
 #endif
 			    entry->rcf = trh->rcf & htons((unsigned short)~TR_RCF_BROADCAST_MASK);
 			    memcpy(&(entry->rseg[0]),&(trh->rseg[0]),8*sizeof(unsigned short));
@@ -532,7 +525,6 @@ static int rif_seq_show(struct seq_file 
 {
 	int j, rcf_len, segment, brdgnmb;
 	struct rif_cache *entry = v;
-	DECLARE_MAC_BUF(mac);
 
 	if (v == SEQ_START_TOKEN)
 		seq_puts(seq,
@@ -542,9 +534,9 @@ static int rif_seq_show(struct seq_file 
 		long ttl = (long) (entry->last_used + sysctl_tr_rif_timeout)
 				- (long) jiffies;
 
-		seq_printf(seq, "%s %s %7li ",
+		seq_printf(seq, "%s %pM %7li ",
 			   dev?dev->name:"?",
-			   print_mac(mac, entry->addr),
+			   entry->addr,
 			   ttl/HZ);
 
 			if (entry->local_ring)
--- test-tree.orig/net/appletalk/aarp.c	2008-10-25 02:14:57.000000000 +0200
+++ test-tree/net/appletalk/aarp.c	2008-10-25 02:16:00.000000000 +0200
@@ -995,7 +995,6 @@ static int aarp_seq_show(struct seq_file
 	struct aarp_iter_state *iter = seq->private;
 	struct aarp_entry *entry = v;
 	unsigned long now = jiffies;
-	DECLARE_MAC_BUF(mac);
 
 	if (v == SEQ_START_TOKEN)
 		seq_puts(seq,
@@ -1006,7 +1005,7 @@ static int aarp_seq_show(struct seq_file
 			   ntohs(entry->target_addr.s_net),
 			   (unsigned int) entry->target_addr.s_node,
 			   entry->dev ? entry->dev->name : "????");
-		seq_printf(seq, "%s", print_mac(mac, entry->hwaddr));
+		seq_printf(seq, "%pM", entry->hwaddr);
 		seq_printf(seq, " %8s",
 			   dt2str((long)entry->expires_at - (long)now));
 		if (iter->table == unresolved)
--- test-tree.orig/net/atm/br2684.c	2008-10-25 02:14:57.000000000 +0200
+++ test-tree/net/atm/br2684.c	2008-10-25 02:16:00.000000000 +0200
@@ -698,12 +698,11 @@ static int br2684_seq_show(struct seq_fi
 						    br2684_devs);
 	const struct net_device *net_dev = brdev->net_dev;
 	const struct br2684_vcc *brvcc;
-	DECLARE_MAC_BUF(mac);
 
-	seq_printf(seq, "dev %.16s: num=%d, mac=%s (%s)\n",
+	seq_printf(seq, "dev %.16s: num=%d, mac=%pM (%s)\n",
 		   net_dev->name,
 		   brdev->number,
-		   print_mac(mac, net_dev->dev_addr),
+		   net_dev->dev_addr,
 		   brdev->mac_was_set ? "set" : "auto");
 
 	list_for_each_entry(brvcc, &brdev->brvccs, brvccs) {
--- test-tree.orig/net/core/netpoll.c	2008-10-25 02:14:57.000000000 +0200
+++ test-tree/net/core/netpoll.c	2008-10-25 02:16:00.000000000 +0200
@@ -553,7 +553,6 @@ out:
 
 void netpoll_print_options(struct netpoll *np)
 {
-	DECLARE_MAC_BUF(mac);
 	printk(KERN_INFO "%s: local port %d\n",
 			 np->name, np->local_port);
 	printk(KERN_INFO "%s: local IP %d.%d.%d.%d\n",
@@ -564,8 +563,8 @@ void netpoll_print_options(struct netpol
 			 np->name, np->remote_port);
 	printk(KERN_INFO "%s: remote IP %d.%d.%d.%d\n",
 			 np->name, HIPQUAD(np->remote_ip));
-	printk(KERN_INFO "%s: remote ethernet address %s\n",
-	                 np->name, print_mac(mac, np->remote_mac));
+	printk(KERN_INFO "%s: remote ethernet address %pM\n",
+	                 np->name, np->remote_mac);
 }
 
 int netpoll_parse_options(struct netpoll *np, char *opt)
--- test-tree.orig/net/core/pktgen.c	2008-10-25 02:14:57.000000000 +0200
+++ test-tree/net/core/pktgen.c	2008-10-25 02:16:00.000000000 +0200
@@ -509,7 +509,6 @@ static int pktgen_if_show(struct seq_fil
 	__u64 sa;
 	__u64 stopped;
 	__u64 now = getCurUs();
-	DECLARE_MAC_BUF(mac);
 
 	seq_printf(seq,
 		   "Params: count %llu  min_pkt_size: %u  max_pkt_size: %u\n",
@@ -554,12 +553,12 @@ static int pktgen_if_show(struct seq_fil
 
 	seq_puts(seq, "     src_mac: ");
 
-	seq_printf(seq, "%s ",
-		   print_mac(mac, is_zero_ether_addr(pkt_dev->src_mac) ?
-			     pkt_dev->odev->dev_addr : pkt_dev->src_mac));
+	seq_printf(seq, "%pM ",
+		   is_zero_ether_addr(pkt_dev->src_mac) ?
+			     pkt_dev->odev->dev_addr : pkt_dev->src_mac);
 
 	seq_printf(seq, "dst_mac: ");
-	seq_printf(seq, "%s\n", print_mac(mac, pkt_dev->dst_mac));
+	seq_printf(seq, "%pM\n", pkt_dev->dst_mac);
 
 	seq_printf(seq,
 		   "     udp_src_min: %d  udp_src_max: %d  udp_dst_min: %d  udp_dst_max: %d\n",
--- test-tree.orig/net/ieee80211/ieee80211_crypt_ccmp.c	2008-10-25 02:14:57.000000000 +0200
+++ test-tree/net/ieee80211/ieee80211_crypt_ccmp.c	2008-10-25 02:16:00.000000000 +0200
@@ -296,7 +296,6 @@ static int ieee80211_ccmp_decrypt(struct
 	int i, blocks, last, len;
 	size_t data_len = skb->len - hdr_len - CCMP_HDR_LEN - CCMP_MIC_LEN;
 	u8 *mic = skb->data + skb->len - CCMP_MIC_LEN;
-	DECLARE_MAC_BUF(mac);
 
 	if (skb->len < hdr_len + CCMP_HDR_LEN + CCMP_MIC_LEN) {
 		key->dot11RSNAStatsCCMPFormatErrors++;
@@ -309,7 +308,7 @@ static int ieee80211_ccmp_decrypt(struct
 	if (!(keyidx & (1 << 5))) {
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "CCMP: received packet without ExtIV"
-			       " flag from %s\n", print_mac(mac, hdr->addr2));
+			       " flag from %pM\n", hdr->addr2);
 		}
 		key->dot11RSNAStatsCCMPFormatErrors++;
 		return -2;
@@ -322,9 +321,9 @@ static int ieee80211_ccmp_decrypt(struct
 	}
 	if (!key->key_set) {
 		if (net_ratelimit()) {
-			printk(KERN_DEBUG "CCMP: received packet from %s"
+			printk(KERN_DEBUG "CCMP: received packet from %pM"
 			       " with keyid=%d that does not have a configured"
-			       " key\n", print_mac(mac, hdr->addr2), keyidx);
+			       " key\n", hdr->addr2, keyidx);
 		}
 		return -3;
 	}
@@ -339,10 +338,10 @@ static int ieee80211_ccmp_decrypt(struct
 
 	if (ccmp_replay_check(pn, key->rx_pn)) {
 		if (ieee80211_ratelimit_debug(IEEE80211_DL_DROP)) {
-			IEEE80211_DEBUG_DROP("CCMP: replay detected: STA=%s "
+			IEEE80211_DEBUG_DROP("CCMP: replay detected: STA=%pM "
 				 "previous PN %02x%02x%02x%02x%02x%02x "
 				 "received PN %02x%02x%02x%02x%02x%02x\n",
-				 print_mac(mac, hdr->addr2),
+				 hdr->addr2,
 				 key->rx_pn[0], key->rx_pn[1], key->rx_pn[2],
 				 key->rx_pn[3], key->rx_pn[4], key->rx_pn[5],
 				 pn[0], pn[1], pn[2], pn[3], pn[4], pn[5]);
@@ -373,7 +372,7 @@ static int ieee80211_ccmp_decrypt(struct
 	if (memcmp(mic, a, CCMP_MIC_LEN) != 0) {
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "CCMP: decrypt failed: STA="
-			       "%s\n", print_mac(mac, hdr->addr2));
+			       "%pM\n", hdr->addr2);
 		}
 		key->dot11RSNAStatsCCMPDecryptErrors++;
 		return -5;
--- test-tree.orig/net/ieee80211/ieee80211_crypt_tkip.c	2008-10-25 02:14:57.000000000 +0200
+++ test-tree/net/ieee80211/ieee80211_crypt_tkip.c	2008-10-25 02:16:00.000000000 +0200
@@ -359,15 +359,13 @@ static int ieee80211_tkip_encrypt(struct
 	u8 rc4key[16], *pos, *icv;
 	u32 crc;
 	struct scatterlist sg;
-	DECLARE_MAC_BUF(mac);
 
 	if (tkey->flags & IEEE80211_CRYPTO_TKIP_COUNTERMEASURES) {
 		if (net_ratelimit()) {
 			struct ieee80211_hdr_4addr *hdr =
 			    (struct ieee80211_hdr_4addr *)skb->data;
 			printk(KERN_DEBUG ": TKIP countermeasures: dropped "
-			       "TX packet to %s\n",
-			       print_mac(mac, hdr->addr1));
+			       "TX packet to %pM\n", hdr->addr1);
 		}
 		return -1;
 	}
@@ -420,15 +418,13 @@ static int ieee80211_tkip_decrypt(struct
 	u32 crc;
 	struct scatterlist sg;
 	int plen;
-	DECLARE_MAC_BUF(mac);
 
 	hdr = (struct ieee80211_hdr_4addr *)skb->data;
 
 	if (tkey->flags & IEEE80211_CRYPTO_TKIP_COUNTERMEASURES) {
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG ": TKIP countermeasures: dropped "
-			       "received packet from %s\n",
-			       print_mac(mac, hdr->addr2));
+			       "received packet from %pM\n", hdr->addr2);
 		}
 		return -1;
 	}
@@ -441,7 +437,7 @@ static int ieee80211_tkip_decrypt(struct
 	if (!(keyidx & (1 << 5))) {
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "TKIP: received packet without ExtIV"
-			       " flag from %s\n", print_mac(mac, hdr->addr2));
+			       " flag from %pM\n", hdr->addr2);
 		}
 		return -2;
 	}
@@ -453,9 +449,9 @@ static int ieee80211_tkip_decrypt(struct
 	}
 	if (!tkey->key_set) {
 		if (net_ratelimit()) {
-			printk(KERN_DEBUG "TKIP: received packet from %s"
+			printk(KERN_DEBUG "TKIP: received packet from %pM"
 			       " with keyid=%d that does not have a configured"
-			       " key\n", print_mac(mac, hdr->addr2), keyidx);
+			       " key\n", hdr->addr2, keyidx);
 		}
 		return -3;
 	}
@@ -465,9 +461,9 @@ static int ieee80211_tkip_decrypt(struct
 
 	if (tkip_replay_check(iv32, iv16, tkey->rx_iv32, tkey->rx_iv16)) {
 		if (ieee80211_ratelimit_debug(IEEE80211_DL_DROP)) {
-			IEEE80211_DEBUG_DROP("TKIP: replay detected: STA=%s"
+			IEEE80211_DEBUG_DROP("TKIP: replay detected: STA=%pM"
 			       " previous TSC %08x%04x received TSC "
-			       "%08x%04x\n", print_mac(mac, hdr->addr2),
+			       "%08x%04x\n", hdr->addr2,
 			       tkey->rx_iv32, tkey->rx_iv16, iv32, iv16);
 		}
 		tkey->dot11RSNAStatsTKIPReplays++;
@@ -487,8 +483,8 @@ static int ieee80211_tkip_decrypt(struct
 	if (crypto_blkcipher_decrypt(&desc, &sg, &sg, plen + 4)) {
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG ": TKIP: failed to decrypt "
-			       "received packet from %s\n",
-			       print_mac(mac, hdr->addr2));
+			       "received packet from %pM\n",
+			       hdr->addr2);
 		}
 		return -7;
 	}
@@ -506,7 +502,7 @@ static int ieee80211_tkip_decrypt(struct
 		}
 		if (ieee80211_ratelimit_debug(IEEE80211_DL_DROP)) {
 			IEEE80211_DEBUG_DROP("TKIP: ICV error detected: STA="
-			       "%s\n", print_mac(mac, hdr->addr2));
+			       "%pM\n", hdr->addr2);
 		}
 		tkey->dot11RSNAStatsTKIPICVErrors++;
 		return -5;
@@ -633,7 +629,6 @@ static int ieee80211_michael_mic_verify(
 {
 	struct ieee80211_tkip_data *tkey = priv;
 	u8 mic[8];
-	DECLARE_MAC_BUF(mac);
 
 	if (!tkey->key_set)
 		return -1;
@@ -646,8 +641,8 @@ static int ieee80211_michael_mic_verify(
 		struct ieee80211_hdr_4addr *hdr;
 		hdr = (struct ieee80211_hdr_4addr *)skb->data;
 		printk(KERN_DEBUG "%s: Michael MIC verification failed for "
-		       "MSDU from %s keyidx=%d\n",
-		       skb->dev ? skb->dev->name : "N/A", print_mac(mac, hdr->addr2),
+		       "MSDU from %pM keyidx=%d\n",
+		       skb->dev ? skb->dev->name : "N/A", hdr->addr2,
 		       keyidx);
 		if (skb->dev)
 			ieee80211_michael_mic_failure(skb->dev, hdr, keyidx);
--- test-tree.orig/net/ieee80211/ieee80211_wx.c	2008-10-25 02:14:56.000000000 +0200
+++ test-tree/net/ieee80211/ieee80211_wx.c	2008-10-25 02:16:00.000000000 +0200
@@ -264,7 +264,6 @@ int ieee80211_wx_get_scan(struct ieee802
 	char *ev = extra;
 	char *stop = ev + wrqu->data.length;
 	int i = 0;
-	DECLARE_MAC_BUF(mac);
 
 	IEEE80211_DEBUG_WX("Getting scan\n");
 
@@ -283,10 +282,10 @@ int ieee80211_wx_get_scan(struct ieee802
 						      info);
 		else
 			IEEE80211_DEBUG_SCAN("Not showing network '%s ("
-					     "%s)' due to age (%dms).\n",
+					     "%pM)' due to age (%dms).\n",
 					     escape_essid(network->ssid,
 							  network->ssid_len),
-					     print_mac(mac, network->bssid),
+					     network->bssid,
 					     jiffies_to_msecs(jiffies -
 							      network->
 							      last_scanned));
--- test-tree.orig/net/irda/irlan/irlan_client.c	2008-10-25 02:14:57.000000000 +0200
+++ test-tree/net/irda/irlan/irlan_client.c	2008-10-25 02:16:00.000000000 +0200
@@ -436,7 +436,6 @@ static void irlan_check_response_param(s
 	__u16 tmp_cpu; /* Temporary value in host order */
 	__u8 *bytes;
 	int i;
-	DECLARE_MAC_BUF(mac);
 
 	IRDA_DEBUG(4, "%s(), parm=%s\n", __func__ , param);
 
@@ -521,8 +520,7 @@ static void irlan_check_response_param(s
 	/* FILTER_ENTRY, have we got an ethernet address? */
 	if (strcmp(param, "FILTER_ENTRY") == 0) {
 		bytes = value;
-		IRDA_DEBUG(4, "Ethernet address = %s\n",
-			   print_mac(mac, bytes));
+		IRDA_DEBUG(4, "Ethernet address = %pM\n", bytes);
 		for (i = 0; i < 6; i++)
 			self->dev->dev_addr[i] = bytes[i];
 	}
--- test-tree.orig/net/llc/llc_proc.c	2008-10-25 02:14:57.000000000 +0200
+++ test-tree/net/llc/llc_proc.c	2008-10-25 02:19:53.000000000 +0200
@@ -27,8 +27,7 @@
 
 static void llc_ui_format_mac(struct seq_file *seq, u8 *addr)
 {
-	DECLARE_MAC_BUF(mac);
-	seq_printf(seq, "%s", print_mac(mac, addr));
+	seq_printf(seq, "%pM", addr);
 }
 
 static struct sock *llc_get_sk_idx(loff_t pos)
--- test-tree.orig/drivers/net/r8169.c	2008-10-25 02:15:05.000000000 +0200
+++ test-tree/drivers/net/r8169.c	2008-10-25 02:16:00.000000000 +0200
@@ -1990,12 +1990,9 @@ static void rtl_init_mac_address(struct 
 		return;
 	}
 
-	if (netif_msg_probe(tp)) {
-		DECLARE_MAC_BUF(buf);
-
-		dev_info(&pdev->dev, "MAC address found in EEPROM: %s\n",
-			 print_mac(buf, mac));
-	}
+	if (netif_msg_probe(tp))
+		dev_info(&pdev->dev, "MAC address found in EEPROM: %pM\n",
+			 mac);
 
 	if (is_valid_ether_addr(mac))
 		rtl_rar_set(tp, mac);


