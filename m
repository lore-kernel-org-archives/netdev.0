From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH 2/2] net: convert multicast list to list_head
Date: Fri, 2 Apr 2010 09:22:57 +0200
Message-ID: <20100402072253.GC3100@psychotron.redhat.com>
References: <20100402072126.GA3100@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39401 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759294Ab0DBHXC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Apr 2010 03:23:02 -0400
Content-Disposition: inline
In-Reply-To: <20100402072126.GA3100@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converts the list and the core manipulating with it to be the same as uc_list.

+uses two functions for adding/removing mc address (normal and "global"
 variant) instead of a function parameter.
+removes dev_mcast.c completely.
+exposes netdev_hw_addr_list_* macros along with __hw_addr_* functions for
 manipulation with lists on a sandbox (used in bonding and 80211 drivers)

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/infiniband/hw/nes/nes_nic.c            |    7 +-
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |    9 +-
 drivers/media/dvb/dvb-core/dvb_net.c           |   10 +-
 drivers/net/3c505.c                            |    7 +-
 drivers/net/3c523.c                            |    7 +-
 drivers/net/3c527.c                            |    6 +-
 drivers/net/7990.c                             |    6 +-
 drivers/net/8139cp.c                           |    6 +-
 drivers/net/8139too.c                          |    6 +-
 drivers/net/82596.c                            |    6 +-
 drivers/net/a2065.c                            |    6 +-
 drivers/net/amd8111e.c                         |    6 +-
 drivers/net/arm/am79c961a.c                    |    6 +-
 drivers/net/arm/at91_ether.c                   |    6 +-
 drivers/net/arm/ixp4xx_eth.c                   |    8 +-
 drivers/net/arm/ks8695net.c                    |   10 +-
 drivers/net/at1700.c                           |    6 +-
 drivers/net/atl1c/atl1c_main.c                 |    6 +-
 drivers/net/atl1e/atl1e_main.c                 |    6 +-
 drivers/net/atlx/atl2.c                        |    6 +-
 drivers/net/atlx/atlx.c                        |    6 +-
 drivers/net/atp.c                              |    6 +-
 drivers/net/au1000_eth.c                       |    6 +-
 drivers/net/b44.c                              |    6 +-
 drivers/net/bcm63xx_enet.c                     |    6 +-
 drivers/net/benet/be_cmds.c                    |    6 +-
 drivers/net/bfin_mac.c                         |    6 +-
 drivers/net/bmac.c                             |   12 +-
 drivers/net/bnx2.c                             |    5 +-
 drivers/net/bnx2x_main.c                       |   18 +-
 drivers/net/bonding/bond_main.c                |  157 ++++--------
 drivers/net/bonding/bonding.h                  |    2 +-
 drivers/net/cassini.c                          |   12 +-
 drivers/net/chelsio/pm3393.c                   |    7 +-
 drivers/net/cpmac.c                            |   16 +-
 drivers/net/cris/eth_v10.c                     |    6 +-
 drivers/net/cxgb3/xgmac.c                      |    8 +-
 drivers/net/davinci_emac.c                     |    7 +-
 drivers/net/declance.c                         |    6 +-
 drivers/net/defxx.c                            |    6 +-
 drivers/net/depca.c                            |    6 +-
 drivers/net/dl2k.c                             |    6 +-
 drivers/net/dm9000.c                           |    6 +-
 drivers/net/e100.c                             |    6 +-
 drivers/net/e1000/e1000_main.c                 |    7 +-
 drivers/net/e1000e/netdev.c                    |    7 +-
 drivers/net/eepro.c                            |    6 +-
 drivers/net/eexpress.c                         |    6 +-
 drivers/net/ehea/ehea_main.c                   |    6 +-
 drivers/net/enic/enic_main.c                   |    6 +-
 drivers/net/epic100.c                          |    6 +-
 drivers/net/ethoc.c                            |    6 +-
 drivers/net/ewrk3.c                            |    6 +-
 drivers/net/fealnx.c                           |    6 +-
 drivers/net/fec.c                              |   10 +-
 drivers/net/fec_mpc52xx.c                      |    6 +-
 drivers/net/forcedeth.c                        |   10 +-
 drivers/net/fs_enet/mac-fcc.c                  |    6 +-
 drivers/net/fs_enet/mac-fec.c                  |    6 +-
 drivers/net/fs_enet/mac-scc.c                  |    6 +-
 drivers/net/gianfar.c                          |    9 +-
 drivers/net/greth.c                            |    6 +-
 drivers/net/hamachi.c                          |    8 +-
 drivers/net/hp100.c                            |    6 +-
 drivers/net/ibm_newemac/core.c                 |   11 +-
 drivers/net/ibmlana.c                          |    8 +-
 drivers/net/ibmveth.c                          |    6 +-
 drivers/net/igb/igb_main.c                     |    6 +-
 drivers/net/igbvf/netdev.c                     |    6 +-
 drivers/net/ioc3-eth.c                         |    6 +-
 drivers/net/ipg.c                              |    6 +-
 drivers/net/iseries_veth.c                     |    6 +-
 drivers/net/ixgb/ixgb_main.c                   |    6 +-
 drivers/net/ixgbe/ixgbe_common.c               |    6 +-
 drivers/net/ixgbevf/vf.c                       |    6 +-
 drivers/net/jme.c                              |    6 +-
 drivers/net/korina.c                           |    6 +-
 drivers/net/ks8851.c                           |    6 +-
 drivers/net/ks8851_mll.c                       |   12 +-
 drivers/net/ksz884x.c                          |   11 +-
 drivers/net/lib82596.c                         |    6 +-
 drivers/net/lib8390.c                          |    6 +-
 drivers/net/ll_temac_main.c                    |   16 +-
 drivers/net/lp486e.c                           |    6 +-
 drivers/net/macb.c                             |    6 +-
 drivers/net/mace.c                             |    6 +-
 drivers/net/macmace.c                          |    6 +-
 drivers/net/mlx4/en_netdev.c                   |    6 +-
 drivers/net/mv643xx_eth.c                      |    6 +-
 drivers/net/myri10ge/myri10ge.c                |    8 +-
 drivers/net/natsemi.c                          |    6 +-
 drivers/net/netxen/netxen_nic_hw.c             |   12 +-
 drivers/net/ni52.c                             |    6 +-
 drivers/net/niu.c                              |    5 +-
 drivers/net/octeon/octeon_mgmt.c               |    6 +-
 drivers/net/pci-skeleton.c                     |    6 +-
 drivers/net/pcmcia/axnet_cs.c                  |    6 +-
 drivers/net/pcmcia/fmvj18x_cs.c                |    6 +-
 drivers/net/pcmcia/nmclan_cs.c                 |    6 +-
 drivers/net/pcmcia/smc91c92_cs.c               |    8 +-
 drivers/net/pcmcia/xirc2ps_cs.c                |    6 +-
 drivers/net/pcnet32.c                          |    6 +-
 drivers/net/ps3_gelic_net.c                    |    6 +-
 drivers/net/qlcnic/qlcnic_hw.c                 |    6 +-
 drivers/net/qlge/qlge_main.c                   |    6 +-
 drivers/net/r6040.c                            |   10 +-
 drivers/net/r8169.c                            |    6 +-
 drivers/net/s2io.c                             |    8 +-
 drivers/net/sb1250-mac.c                       |    6 +-
 drivers/net/sc92031.c                          |    6 +-
 drivers/net/sfc/efx.c                          |    6 +-
 drivers/net/sis190.c                           |    6 +-
 drivers/net/sis900.c                           |   10 +-
 drivers/net/skfp/skfddi.c                      |   12 +-
 drivers/net/skge.c                             |   12 +-
 drivers/net/sky2.c                             |    6 +-
 drivers/net/smc911x.c                          |   13 +-
 drivers/net/smc9194.c                          |   13 +-
 drivers/net/smc91x.c                           |    8 +-
 drivers/net/smsc911x.c                         |    6 +-
 drivers/net/smsc9420.c                         |    6 +-
 drivers/net/sonic.c                            |    6 +-
 drivers/net/spider_net.c                       |    6 +-
 drivers/net/starfire.c                         |   10 +-
 drivers/net/stmmac/dwmac100.c                  |    6 +-
 drivers/net/stmmac/dwmac1000_core.c            |    6 +-
 drivers/net/sun3_82586.c                       |    6 +-
 drivers/net/sunbmac.c                          |    6 +-
 drivers/net/sundance.c                         |    6 +-
 drivers/net/sungem.c                           |    6 +-
 drivers/net/sunhme.c                           |   12 +-
 drivers/net/sunlance.c                         |    6 +-
 drivers/net/sunqe.c                            |    6 +-
 drivers/net/sunvnet.c                          |    8 +-
 drivers/net/tc35815.c                          |    6 +-
 drivers/net/tehuti.c                           |    6 +-
 drivers/net/tg3.c                              |    6 +-
 drivers/net/tlan.c                             |    8 +-
 drivers/net/tokenring/3c359.c                  |   12 +-
 drivers/net/tokenring/ibmtr.c                  |   12 +-
 drivers/net/tokenring/lanstreamer.c            |   12 +-
 drivers/net/tokenring/olympic.c                |   12 +-
 drivers/net/tokenring/tms380tr.c               |   12 +-
 drivers/net/tsi108_eth.c                       |    6 +-
 drivers/net/tulip/de2104x.c                    |   12 +-
 drivers/net/tulip/de4x5.c                      |   10 +-
 drivers/net/tulip/dmfe.c                       |   12 +-
 drivers/net/tulip/tulip_core.c                 |   27 ++-
 drivers/net/tulip/uli526x.c                    |    6 +-
 drivers/net/tulip/winbond-840.c                |   12 +-
 drivers/net/typhoon.c                          |    6 +-
 drivers/net/ucc_geth.c                         |    8 +-
 drivers/net/usb/asix.c                         |   16 +-
 drivers/net/usb/catc.c                         |    6 +-
 drivers/net/usb/dm9601.c                       |    6 +-
 drivers/net/usb/mcs7830.c                      |    6 +-
 drivers/net/usb/smsc75xx.c                     |    6 +-
 drivers/net/usb/smsc95xx.c                     |    6 +-
 drivers/net/via-rhine.c                        |    6 +-
 drivers/net/via-velocity.c                     |    6 +-
 drivers/net/virtio_net.c                       |    5 +-
 drivers/net/vmxnet3/vmxnet3_drv.c              |    6 +-
 drivers/net/vxge/vxge-main.c                   |    6 +-
 drivers/net/wireless/adm8211.c                 |   12 +-
 drivers/net/wireless/ath/ar9170/main.c         |   14 +-
 drivers/net/wireless/ath/ath5k/base.c          |   17 +-
 drivers/net/wireless/libertas/main.c           |   12 +-
 drivers/net/wireless/libertas_tf/main.c        |   14 +-
 drivers/net/wireless/mwl8k.c                   |   24 +-
 drivers/net/wireless/orinoco/hw.c              |    6 +-
 drivers/net/wireless/orinoco/hw.h              |    1 -
 drivers/net/wireless/ray_cs.c                  |   12 +-
 drivers/net/wireless/rndis_wlan.c              |    6 +-
 drivers/net/wireless/rtl818x/rtl8180_dev.c     |    6 +-
 drivers/net/wireless/rtl818x/rtl8187_dev.c     |    4 +-
 drivers/net/wireless/wl12xx/wl1271_main.c      |   25 +--
 drivers/net/wireless/zd1201.c                  |    6 +-
 drivers/net/wireless/zd1211rw/zd_mac.c         |   13 +-
 drivers/net/yellowfin.c                        |   12 +-
 drivers/s390/net/qeth_l2_main.c                |    5 +-
 drivers/scsi/fcoe/fcoe.c                       |    4 +-
 drivers/staging/arlan/arlan-main.c             |    9 +-
 drivers/staging/et131x/et131x_netdev.c         |    6 +-
 drivers/staging/slicoss/slicoss.c              |    6 +-
 drivers/staging/vt6655/device_main.c           |    6 +-
 drivers/staging/vt6656/main_usb.c              |    6 +-
 drivers/staging/wavelan/wavelan.c              |   10 +-
 drivers/staging/wavelan/wavelan_cs.c           |   12 +-
 drivers/staging/winbond/wbusb.c                |    6 +-
 drivers/staging/wlags49_h2/wl_netdev.c         |   12 +-
 include/linux/netdevice.h                      |   82 ++++---
 include/net/mac80211.h                         |    2 +-
 net/802/garp.c                                 |    4 +-
 net/appletalk/ddp.c                            |    2 +-
 net/bluetooth/bnep/netdev.c                    |    8 +-
 net/core/Makefile                              |    5 +-
 net/core/dev.c                                 |  145 +-----------
 net/core/dev_addr_lists.c                      |  305 ++++++++++++++++++++++--
 net/core/dev_mcast.c                           |  232 ------------------
 net/decnet/dn_dev.c                            |   12 +-
 net/ipv4/igmp.c                                |    4 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c             |    4 +-
 net/ipv6/mcast.c                               |    4 +-
 net/mac80211/driver-ops.h                      |    8 +-
 net/mac80211/ieee80211_i.h                     |    3 +-
 net/mac80211/iface.c                           |    6 +-
 net/mac80211/main.c                            |    2 +-
 net/packet/af_packet.c                         |    4 +-
 208 files changed, 1137 insertions(+), 1327 deletions(-)
 delete mode 100644 net/core/dev_mcast.c

diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 91fdde3..ce9ef6b 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -876,7 +876,7 @@ static void nes_netdev_set_multicast_list(struct net_device *netdev)
 	if (!mc_all_on) {
 		char *addrs;
 		int i;
-		struct dev_mc_list *mcaddr;
+		struct netdev_hw_addr *ha;
 
 		addrs = kmalloc(ETH_ALEN * mc_count, GFP_ATOMIC);
 		if (!addrs) {
@@ -884,9 +884,8 @@ static void nes_netdev_set_multicast_list(struct net_device *netdev)
 			goto unlock;
 		}
 		i = 0;
-		netdev_for_each_mc_addr(mcaddr, netdev)
-			memcpy(get_addr(addrs, i++),
-			       mcaddr->dmi_addr, ETH_ALEN);
+		netdev_for_each_mc_addr(ha, netdev)
+			memcpy(get_addr(addrs, i++), ha->addr, ETH_ALEN);
 
 		perfect_filter_register_address = NES_IDX_PERFECT_FILTER_LOW +
 						pft_entries_preallocated * 0x8;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index 19eba3c..c8a0f7d 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -783,7 +783,7 @@ void ipoib_mcast_restart_task(struct work_struct *work)
 	struct ipoib_dev_priv *priv =
 		container_of(work, struct ipoib_dev_priv, restart_task);
 	struct net_device *dev = priv->dev;
-	struct dev_mc_list *mclist;
+	struct netdev_hw_addr *ha;
 	struct ipoib_mcast *mcast, *tmcast;
 	LIST_HEAD(remove_list);
 	unsigned long flags;
@@ -808,14 +808,13 @@ void ipoib_mcast_restart_task(struct work_struct *work)
 		clear_bit(IPOIB_MCAST_FLAG_FOUND, &mcast->flags);
 
 	/* Mark all of the entries that are found or don't exist */
-	netdev_for_each_mc_addr(mclist, dev) {
+	netdev_for_each_mc_addr(ha, dev) {
 		union ib_gid mgid;
 
-		if (!ipoib_mcast_addr_is_valid(mclist->dmi_addr,
-					       dev->broadcast))
+		if (!ipoib_mcast_addr_is_valid(ha->addr, dev->broadcast))
 			continue;
 
-		memcpy(mgid.raw, mclist->dmi_addr + 4, sizeof mgid);
+		memcpy(mgid.raw, ha->addr + 4, sizeof mgid);
 
 		mcast = __ipoib_mcast_find(dev, &mgid);
 		if (!mcast || test_bit(IPOIB_MCAST_FLAG_SENDONLY, &mcast->flags)) {
diff --git a/drivers/media/dvb/dvb-core/dvb_net.c b/drivers/media/dvb/dvb-core/dvb_net.c
index dba1c84..cccea41 100644
--- a/drivers/media/dvb/dvb-core/dvb_net.c
+++ b/drivers/media/dvb/dvb-core/dvb_net.c
@@ -1109,14 +1109,14 @@ static int dvb_net_feed_stop(struct net_device *dev)
 }
 
 
-static int dvb_set_mc_filter (struct net_device *dev, struct dev_mc_list *mc)
+static int dvb_set_mc_filter(struct net_device *dev, unsigned char *addr)
 {
 	struct dvb_net_priv *priv = netdev_priv(dev);
 
 	if (priv->multi_num == DVB_NET_MULTICAST_MAX)
 		return -ENOMEM;
 
-	memcpy(priv->multi_macs[priv->multi_num], mc->dmi_addr, 6);
+	memcpy(priv->multi_macs[priv->multi_num], addr, ETH_ALEN);
 
 	priv->multi_num++;
 	return 0;
@@ -1140,7 +1140,7 @@ static void wq_set_multicast_list (struct work_struct *work)
 		dprintk("%s: allmulti mode\n", dev->name);
 		priv->rx_mode = RX_MODE_ALL_MULTI;
 	} else if (!netdev_mc_empty(dev)) {
-		struct dev_mc_list *mc;
+		struct netdev_hw_addr *ha;
 
 		dprintk("%s: set_mc_list, %d entries\n",
 			dev->name, netdev_mc_count(dev));
@@ -1148,8 +1148,8 @@ static void wq_set_multicast_list (struct work_struct *work)
 		priv->rx_mode = RX_MODE_MULTI;
 		priv->multi_num = 0;
 
-		netdev_for_each_mc_addr(mc, dev)
-			dvb_set_mc_filter(dev, mc);
+		netdev_for_each_mc_addr(ha, dev)
+			dvb_set_mc_filter(dev, ha->addr);
 	}
 
 	netif_addr_unlock_bh(dev);
diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
index 04b5bba..81c8b31 100644
--- a/drivers/net/3c505.c
+++ b/drivers/net/3c505.c
@@ -1216,7 +1216,7 @@ static int elp_close(struct net_device *dev)
 static void elp_set_mc_list(struct net_device *dev)
 {
 	elp_device *adapter = netdev_priv(dev);
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	int i;
 	unsigned long flags;
 
@@ -1231,8 +1231,9 @@ static void elp_set_mc_list(struct net_device *dev)
 		adapter->tx_pcb.command = CMD_LOAD_MULTICAST_LIST;
 		adapter->tx_pcb.length = 6 * netdev_mc_count(dev);
 		i = 0;
-		netdev_for_each_mc_addr(dmi, dev)
-			memcpy(adapter->tx_pcb.data.multicast[i++], dmi->dmi_addr, 6);
+		netdev_for_each_mc_addr(ha, dev)
+			memcpy(adapter->tx_pcb.data.multicast[i++],
+			       ha->addr, 6);
 		adapter->got[CMD_LOAD_MULTICAST_LIST] = 0;
 		if (!send_pcb(dev, &adapter->tx_pcb))
 			pr_err("%s: couldn't send set_multicast command\n", dev->name);
diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index beed4fa..966cb12 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -625,7 +625,7 @@ static int init586(struct net_device *dev)
 	volatile struct iasetup_cmd_struct *ias_cmd;
 	volatile struct tdr_cmd_struct *tdr_cmd;
 	volatile struct mcsetup_cmd_struct *mc_cmd;
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	int num_addrs = netdev_mc_count(dev);
 
 	ptr = (void *) ((char *) p->scb + sizeof(struct scb_struct));
@@ -788,8 +788,9 @@ static int init586(struct net_device *dev)
 			mc_cmd->cmd_link = 0xffff;
 			mc_cmd->mc_cnt = num_addrs * 6;
 			i = 0;
-			netdev_for_each_mc_addr(dmi, dev)
-				memcpy((char *) mc_cmd->mc_list[i++], dmi->dmi_addr, 6);
+			netdev_for_each_mc_addr(ha, dev)
+				memcpy((char *) mc_cmd->mc_list[i++],
+				       ha->addr, 6);
 			p->scb->cbl_offset = make16(mc_cmd);
 			p->scb->cmd = CUC_START;
 			elmc_id_attn586();
diff --git a/drivers/net/3c527.c b/drivers/net/3c527.c
index 5c07b14..38395df 100644
--- a/drivers/net/3c527.c
+++ b/drivers/net/3c527.c
@@ -1533,7 +1533,7 @@ static void do_mc32_set_multicast_list(struct net_device *dev, int retry)
 	{
 		unsigned char block[62];
 		unsigned char *bp;
-		struct dev_mc_list *dmc;
+		struct netdev_hw_addr *ha;
 
 		if(retry==0)
 			lp->mc_list_valid = 0;
@@ -1543,8 +1543,8 @@ static void do_mc32_set_multicast_list(struct net_device *dev, int retry)
 			block[0]=netdev_mc_count(dev);
 			bp=block+2;
 
-			netdev_for_each_mc_addr(dmc, dev) {
-				memcpy(bp, dmc->dmi_addr, 6);
+			netdev_for_each_mc_addr(ha, dev) {
+				memcpy(bp, ha->addr, 6);
 				bp+=6;
 			}
 			if(mc32_command_nowait(dev, 2, block,
diff --git a/drivers/net/7990.c b/drivers/net/7990.c
index 4e9a5a2..818837d 100644
--- a/drivers/net/7990.c
+++ b/drivers/net/7990.c
@@ -595,7 +595,7 @@ static void lance_load_multicast (struct net_device *dev)
         struct lance_private *lp = netdev_priv(dev);
         volatile struct lance_init_block *ib = lp->init_block;
         volatile u16 *mcast_table = (u16 *)&ib->filter;
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
         char *addrs;
         u32 crc;
 
@@ -610,8 +610,8 @@ static void lance_load_multicast (struct net_device *dev)
         ib->filter [1] = 0;
 
         /* Add addresses */
-	netdev_for_each_mc_addr(dmi, dev) {
-                addrs = dmi->dmi_addr;
+	netdev_for_each_mc_addr(ha, dev) {
+		addrs = ha->addr;
 
                 /* multicast address? */
                 if (!(*addrs & 1))
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 3d4406b..e4e2aef 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -909,11 +909,11 @@ static void __cp_set_rx_mode (struct net_device *dev)
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
 	} else {
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 		rx_mode = AcceptBroadcast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0;
-		netdev_for_each_mc_addr(mclist, dev) {
-			int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
+		netdev_for_each_mc_addr(ha, dev) {
+			int bit_nr = ether_crc(ETH_ALEN, ha->addr) >> 26;
 
 			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
 			rx_mode |= AcceptMulticast;
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index b4efc91..f61784c 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -2502,11 +2502,11 @@ static void __set_rx_mode (struct net_device *dev)
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
 	} else {
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 		rx_mode = AcceptBroadcast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0;
-		netdev_for_each_mc_addr(mclist, dev) {
-			int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
+		netdev_for_each_mc_addr(ha, dev) {
+			int bit_nr = ether_crc(ETH_ALEN, ha->addr) >> 26;
 
 			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
 			rx_mode |= AcceptMulticast;
diff --git a/drivers/net/82596.c b/drivers/net/82596.c
index f94d17d..3a28b1f 100644
--- a/drivers/net/82596.c
+++ b/drivers/net/82596.c
@@ -1542,7 +1542,7 @@ static void set_multicast_list(struct net_device *dev)
 	}
 
 	if (!netdev_mc_empty(dev)) {
-		struct dev_mc_list *dmi;
+		struct netdev_hw_addr *ha;
 		unsigned char *cp;
 		struct mc_cmd *cmd;
 
@@ -1552,10 +1552,10 @@ static void set_multicast_list(struct net_device *dev)
 		cmd->cmd.command = CmdMulticastList;
 		cmd->mc_cnt = cnt * ETH_ALEN;
 		cp = cmd->mc_addrs;
-		netdev_for_each_mc_addr(dmi, dev) {
+		netdev_for_each_mc_addr(ha, dev) {
 			if (!cnt--)
 				break;
-			memcpy(cp, dmi->dmi_addr, ETH_ALEN);
+			memcpy(cp, ha->addr, ETH_ALEN);
 			if (i596_debug > 1)
 				DEB(DEB_MULTI,printk(KERN_INFO "%s: Adding address %pM\n",
 						dev->name, cp));
diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
index bd4d829..7cce643 100644
--- a/drivers/net/a2065.c
+++ b/drivers/net/a2065.c
@@ -603,7 +603,7 @@ static void lance_load_multicast (struct net_device *dev)
 	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
 	volatile u16 *mcast_table = (u16 *)&ib->filter;
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	char *addrs;
 	u32 crc;
 
@@ -618,8 +618,8 @@ static void lance_load_multicast (struct net_device *dev)
 	ib->filter [1] = 0;
 
 	/* Add addresses */
-	netdev_for_each_mc_addr(dmi, dev) {
-		addrs = dmi->dmi_addr;
+	netdev_for_each_mc_addr(ha, dev) {
+		addrs = ha->addr;
 
 		/* multicast address? */
 		if (!(*addrs & 1))
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index b8a59d2..d002c76 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -1377,7 +1377,7 @@ list to the device.
 */
 static void amd8111e_set_multicast_list(struct net_device *dev)
 {
-	struct dev_mc_list *mc_ptr;
+	struct netdev_hw_addr *ha;
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	u32 mc_filter[2] ;
 	int bit_num;
@@ -1408,8 +1408,8 @@ static void amd8111e_set_multicast_list(struct net_device *dev)
 	/* load all the multicast addresses in the logic filter */
 	lp->options |= OPTION_MULTICAST_ENABLE;
 	mc_filter[1] = mc_filter[0] = 0;
-	netdev_for_each_mc_addr(mc_ptr, dev) {
-		bit_num = (ether_crc_le(ETH_ALEN, mc_ptr->dmi_addr) >> 26) & 0x3f;
+	netdev_for_each_mc_addr(ha, dev) {
+		bit_num = (ether_crc_le(ETH_ALEN, ha->addr) >> 26) & 0x3f;
 		mc_filter[bit_num >> 5] |= 1 << (bit_num & 31);
 	}
 	amd8111e_writeq(*(u64*)mc_filter,lp->mmio+ LADRF);
diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/arm/am79c961a.c
index f1f58c5..a4b5b08 100644
--- a/drivers/net/arm/am79c961a.c
+++ b/drivers/net/arm/am79c961a.c
@@ -383,12 +383,12 @@ static void am79c961_setmulticastlist (struct net_device *dev)
 	} else if (dev->flags & IFF_ALLMULTI) {
 		memset(multi_hash, 0xff, sizeof(multi_hash));
 	} else {
-		struct dev_mc_list *dmi;
+		struct netdev_hw_addr *ha;
 
 		memset(multi_hash, 0x00, sizeof(multi_hash));
 
-		netdev_for_each_mc_addr(dmi, dev)
-			am79c961_mc_hash(dmi->dmi_addr, multi_hash);
+		netdev_for_each_mc_addr(ha, dev)
+			am79c961_mc_hash(ha->addr, multi_hash);
 	}
 
 	spin_lock_irqsave(&priv->chip_lock, flags);
diff --git a/drivers/net/arm/at91_ether.c b/drivers/net/arm/at91_ether.c
index 8b23d5a..f31e8b6 100644
--- a/drivers/net/arm/at91_ether.c
+++ b/drivers/net/arm/at91_ether.c
@@ -556,14 +556,14 @@ static int hash_get_index(__u8 *addr)
  */
 static void at91ether_sethashtable(struct net_device *dev)
 {
-	struct dev_mc_list *curr;
+	struct netdev_hw_addr *ha;
 	unsigned long mc_filter[2];
 	unsigned int bitnr;
 
 	mc_filter[0] = mc_filter[1] = 0;
 
-	netdev_for_each_mc_addr(curr, dev) {
-		bitnr = hash_get_index(curr->dmi_addr);
+	netdev_for_each_mc_addr(ha, dev) {
+		bitnr = hash_get_index(ha->addr);
 		mc_filter[bitnr >> 5] |= 1 << (bitnr & 31);
 	}
 
diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
index 6e2ae1d..f9d1687 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -735,7 +735,7 @@ static int eth_xmit(struct sk_buff *skb, struct net_device *dev)
 static void eth_set_mcast_list(struct net_device *dev)
 {
 	struct port *port = netdev_priv(dev);
-	struct dev_mc_list *mclist;
+	struct netdev_hw_addr *ha;
 	u8 diffs[ETH_ALEN], *addr;
 	int i;
 
@@ -748,11 +748,11 @@ static void eth_set_mcast_list(struct net_device *dev)
 	memset(diffs, 0, ETH_ALEN);
 
 	addr = NULL;
-	netdev_for_each_mc_addr(mclist, dev) {
+	netdev_for_each_mc_addr(ha, dev) {
 		if (!addr)
-			addr = mclist->dmi_addr; /* first MAC address */
+			addr = ha->addr; /* first MAC address */
 		for (i = 0; i < ETH_ALEN; i++)
-			diffs[i] |= addr[i] ^ mclist->dmi_addr[i];
+			diffs[i] |= addr[i] ^ ha->addr[i];
 	}
 
 	for (i = 0; i < ETH_ALEN; i++) {
diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
index e7810b7..6ec245c 100644
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -331,16 +331,16 @@ ks8695_init_partial_multicast(struct ks8695_priv *ksp,
 {
 	u32 low, high;
 	int i;
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 
 	i = 0;
-	netdev_for_each_mc_addr(dmi, ndev) {
+	netdev_for_each_mc_addr(ha, ndev) {
 		/* Ran out of space in chip? */
 		BUG_ON(i == KS8695_NR_ADDRESSES);
 
-		low = (dmi->dmi_addr[2] << 24) | (dmi->dmi_addr[3] << 16) |
-		      (dmi->dmi_addr[4] << 8) | (dmi->dmi_addr[5]);
-		high = (dmi->dmi_addr[0] << 8) | (dmi->dmi_addr[1]);
+		low = (ha->addr[2] << 24) | (ha->addr[3] << 16) |
+		      (ha->addr[4] << 8) | (ha->addr[5]);
+		high = (ha->addr[0] << 8) | (ha->addr[1]);
 
 		ks8695_writereg(ksp, KS8695_AAL_(i), low);
 		ks8695_writereg(ksp, KS8695_AAH_(i), AAH_E | high);
diff --git a/drivers/net/at1700.c b/drivers/net/at1700.c
index 309843a..e2a549a 100644
--- a/drivers/net/at1700.c
+++ b/drivers/net/at1700.c
@@ -848,12 +848,12 @@ set_rx_mode(struct net_device *dev)
 		memset(mc_filter, 0x00, sizeof(mc_filter));
 		outb(1, ioaddr + RX_MODE);	/* Ignore almost all multicasts. */
 	} else {
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		netdev_for_each_mc_addr(mclist, dev) {
+		netdev_for_each_mc_addr(ha, dev) {
 			unsigned int bit =
-				ether_crc_le(ETH_ALEN, mclist->dmi_addr) >> 26;
+				ether_crc_le(ETH_ALEN, ha->addr) >> 26;
 			mc_filter[bit >> 3] |= (1 << bit);
 		}
 		outb(0x02, ioaddr + RX_MODE);	/* Use normal mode. */
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index a5508e1..3d70511 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -354,7 +354,7 @@ static void atl1c_set_multi(struct net_device *netdev)
 {
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
 	struct atl1c_hw *hw = &adapter->hw;
-	struct dev_mc_list *mc_ptr;
+	struct netdev_hw_addr *ha;
 	u32 mac_ctrl_data;
 	u32 hash_value;
 
@@ -377,8 +377,8 @@ static void atl1c_set_multi(struct net_device *netdev)
 	AT_WRITE_REG_ARRAY(hw, REG_RX_HASH_TABLE, 1, 0);
 
 	/* comoute mc addresses' hash value ,and put it into hash table */
-	netdev_for_each_mc_addr(mc_ptr, netdev) {
-		hash_value = atl1c_hash_mc_addr(hw, mc_ptr->dmi_addr);
+	netdev_for_each_mc_addr(ha, netdev) {
+		hash_value = atl1c_hash_mc_addr(hw, ha->addr);
 		atl1c_hash_set(hw, hash_value);
 	}
 }
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 7231b57..b6605d4 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -284,7 +284,7 @@ static void atl1e_set_multi(struct net_device *netdev)
 {
 	struct atl1e_adapter *adapter = netdev_priv(netdev);
 	struct atl1e_hw *hw = &adapter->hw;
-	struct dev_mc_list *mc_ptr;
+	struct netdev_hw_addr *ha;
 	u32 mac_ctrl_data = 0;
 	u32 hash_value;
 
@@ -307,8 +307,8 @@ static void atl1e_set_multi(struct net_device *netdev)
 	AT_WRITE_REG_ARRAY(hw, REG_RX_HASH_TABLE, 1, 0);
 
 	/* comoute mc addresses' hash value ,and put it into hash table */
-	netdev_for_each_mc_addr(mc_ptr, netdev) {
-		hash_value = atl1e_hash_mc_addr(hw, mc_ptr->dmi_addr);
+	netdev_for_each_mc_addr(ha, netdev) {
+		hash_value = atl1e_hash_mc_addr(hw, ha->addr);
 		atl1e_hash_set(hw, hash_value);
 	}
 }
diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index 199f2c9..078d9d1 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -135,7 +135,7 @@ static void atl2_set_multi(struct net_device *netdev)
 {
 	struct atl2_adapter *adapter = netdev_priv(netdev);
 	struct atl2_hw *hw = &adapter->hw;
-	struct dev_mc_list *mc_ptr;
+	struct netdev_hw_addr *ha;
 	u32 rctl;
 	u32 hash_value;
 
@@ -157,8 +157,8 @@ static void atl2_set_multi(struct net_device *netdev)
 	ATL2_WRITE_REG_ARRAY(hw, REG_RX_HASH_TABLE, 1, 0);
 
 	/* comoute mc addresses' hash value ,and put it into hash table */
-	netdev_for_each_mc_addr(mc_ptr, netdev) {
-		hash_value = atl2_hash_mc_addr(hw, mc_ptr->dmi_addr);
+	netdev_for_each_mc_addr(ha, netdev) {
+		hash_value = atl2_hash_mc_addr(hw, ha->addr);
 		atl2_hash_set(hw, hash_value);
 	}
 }
diff --git a/drivers/net/atlx/atlx.c b/drivers/net/atlx/atlx.c
index 72f3306..f979ea2 100644
--- a/drivers/net/atlx/atlx.c
+++ b/drivers/net/atlx/atlx.c
@@ -123,7 +123,7 @@ static void atlx_set_multi(struct net_device *netdev)
 {
 	struct atlx_adapter *adapter = netdev_priv(netdev);
 	struct atlx_hw *hw = &adapter->hw;
-	struct dev_mc_list *mc_ptr;
+	struct netdev_hw_addr *ha;
 	u32 rctl;
 	u32 hash_value;
 
@@ -144,8 +144,8 @@ static void atlx_set_multi(struct net_device *netdev)
 	iowrite32(0, (hw->hw_addr + REG_RX_HASH_TABLE) + (1 << 2));
 
 	/* compute mc addresses' hash value ,and put it into hash table */
-	netdev_for_each_mc_addr(mc_ptr, netdev) {
-		hash_value = atlx_hash_mc_addr(hw, mc_ptr->dmi_addr);
+	netdev_for_each_mc_addr(ha, netdev) {
+		hash_value = atlx_hash_mc_addr(hw, ha->addr);
 		atlx_hash_set(hw, hash_value);
 	}
 }
diff --git a/drivers/net/atp.c b/drivers/net/atp.c
index 6ad1620..0d730c8 100644
--- a/drivers/net/atp.c
+++ b/drivers/net/atp.c
@@ -883,11 +883,11 @@ static void set_rx_mode_8012(struct net_device *dev)
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		new_mode = CMR2h_Normal;
 	} else {
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		netdev_for_each_mc_addr(mclist, dev) {
-			int filterbit = ether_crc_le(ETH_ALEN, mclist->dmi_addr) & 0x3f;
+		netdev_for_each_mc_addr(ha, dev) {
+			int filterbit = ether_crc_le(ETH_ALEN, ha->addr) & 0x3f;
 			mc_filter[filterbit >> 5] |= 1 << (filterbit & 31);
 		}
 		new_mode = CMR2h_Normal;
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 4da191b..2963159 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -957,12 +957,12 @@ static void au1000_multicast_list(struct net_device *dev)
 		aup->mac->control &= ~MAC_PROMISCUOUS;
 		printk(KERN_INFO "%s: Pass all multicast\n", dev->name);
 	} else {
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 		u32 mc_filter[2];	/* Multicast hash filter */
 
 		mc_filter[1] = mc_filter[0] = 0;
-		netdev_for_each_mc_addr(mclist, dev)
-			set_bit(ether_crc(ETH_ALEN, mclist->dmi_addr)>>26,
+		netdev_for_each_mc_addr(ha, dev)
+			set_bit(ether_crc(ETH_ALEN, ha->addr)>>26,
 					(long *)mc_filter);
 		aup->mac->multi_hash_high = mc_filter[1];
 		aup->mac->multi_hash_low = mc_filter[0];
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 332c603..b2c5fd7 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1680,15 +1680,15 @@ static struct net_device_stats *b44_get_stats(struct net_device *dev)
 
 static int __b44_load_mcast(struct b44 *bp, struct net_device *dev)
 {
-	struct dev_mc_list *mclist;
+	struct netdev_hw_addr *ha;
 	int i, num_ents;
 
 	num_ents = min_t(int, netdev_mc_count(dev), B44_MCAST_TABLE_SIZE);
 	i = 0;
-	netdev_for_each_mc_addr(mclist, dev) {
+	netdev_for_each_mc_addr(ha, dev) {
 		if (i == num_ents)
 			break;
-		__b44_cam_write(bp, mclist->dmi_addr, i++ + 1);
+		__b44_cam_write(bp, ha->addr, i++ + 1);
 	}
 	return i+1;
 }
diff --git a/drivers/net/bcm63xx_enet.c b/drivers/net/bcm63xx_enet.c
index 37eb802..5173340 100644
--- a/drivers/net/bcm63xx_enet.c
+++ b/drivers/net/bcm63xx_enet.c
@@ -603,7 +603,7 @@ static int bcm_enet_set_mac_address(struct net_device *dev, void *p)
 static void bcm_enet_set_multicast_list(struct net_device *dev)
 {
 	struct bcm_enet_priv *priv;
-	struct dev_mc_list *mc_list;
+	struct netdev_hw_addr *ha;
 	u32 val;
 	int i;
 
@@ -631,14 +631,14 @@ static void bcm_enet_set_multicast_list(struct net_device *dev)
 	}
 
 	i = 0;
-	netdev_for_each_mc_addr(mc_list, dev) {
+	netdev_for_each_mc_addr(ha, dev) {
 		u8 *dmi_addr;
 		u32 tmp;
 
 		if (i == 3)
 			break;
 		/* update perfect match registers */
-		dmi_addr = mc_list->dmi_addr;
+		dmi_addr = ha->addr;
 		tmp = (dmi_addr[2] << 24) | (dmi_addr[3] << 16) |
 			(dmi_addr[4] << 8) | dmi_addr[5];
 		enet_writel(priv, tmp, ENET_PML_REG(i + 1));
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 9f53d9e..61a9afd 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1159,13 +1159,13 @@ int be_cmd_multicast_set(struct be_adapter *adapter, u32 if_id,
 	req->interface_id = if_id;
 	if (netdev) {
 		int i;
-		struct dev_mc_list *mc;
+		struct netdev_hw_addr *ha;
 
 		req->num_mac = cpu_to_le16(netdev_mc_count(netdev));
 
 		i = 0;
-		netdev_for_each_mc_addr(mc, netdev)
-			memcpy(req->mac[i].byte, mc->dmi_addr, ETH_ALEN);
+		netdev_for_each_mc_addr(ha, netdev)
+			memcpy(req->mac[i].byte, ha->addr, ETH_ALEN);
 	} else {
 		req->promiscuous = 1;
 	}
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 587f93c..c488cea 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -812,14 +812,14 @@ static void bfin_mac_timeout(struct net_device *dev)
 static void bfin_mac_multicast_hash(struct net_device *dev)
 {
 	u32 emac_hashhi, emac_hashlo;
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	char *addrs;
 	u32 crc;
 
 	emac_hashhi = emac_hashlo = 0;
 
-	netdev_for_each_mc_addr(dmi, dev) {
-		addrs = dmi->dmi_addr;
+	netdev_for_each_mc_addr(ha, dev) {
+		addrs = ha->addr;
 
 		/* skip non-multicast addresses */
 		if (!(*addrs & 1))
diff --git a/drivers/net/bmac.c b/drivers/net/bmac.c
index 119468e..1245e98 100644
--- a/drivers/net/bmac.c
+++ b/drivers/net/bmac.c
@@ -971,7 +971,7 @@ bmac_remove_multi(struct net_device *dev,
  */
 static void bmac_set_multicast(struct net_device *dev)
 {
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	struct bmac_data *bp = netdev_priv(dev);
 	int num_addrs = netdev_mc_count(dev);
 	unsigned short rx_cfg;
@@ -1000,8 +1000,8 @@ static void bmac_set_multicast(struct net_device *dev)
 			rx_cfg = bmac_rx_on(dev, 0, 0);
 			XXDEBUG(("bmac: multi disabled, rx_cfg=%#08x\n", rx_cfg));
 		} else {
-			netdev_for_each_mc_addr(dmi, dev)
-				bmac_addhash(bp, dmi->dmi_addr);
+			netdev_for_each_mc_addr(ha, dev)
+				bmac_addhash(bp, ha->addr);
 			bmac_update_hash_table_mask(dev, bp);
 			rx_cfg = bmac_rx_on(dev, 1, 0);
 			XXDEBUG(("bmac: multi enabled, rx_cfg=%#08x\n", rx_cfg));
@@ -1015,7 +1015,7 @@ static void bmac_set_multicast(struct net_device *dev)
 
 static void bmac_set_multicast(struct net_device *dev)
 {
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	char *addrs;
 	int i;
 	unsigned short rx_cfg;
@@ -1039,8 +1039,8 @@ static void bmac_set_multicast(struct net_device *dev)
 
 		for(i = 0; i < 4; i++) hash_table[i] = 0;
 
-		netdev_for_each_mc_addr(dmi, dev) {
-			addrs = dmi->dmi_addr;
+		netdev_for_each_mc_addr(ha, dev) {
+			addrs = ha->addr;
 
 			if(!(*addrs & 1))
 				continue;
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 381887b..0b69ffb 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3544,7 +3544,6 @@ bnx2_set_rx_mode(struct net_device *dev)
 	}
 	else {
 		/* Accept one or more multicast(s). */
-		struct dev_mc_list *mclist;
 		u32 mc_filter[NUM_MC_HASH_REGISTERS];
 		u32 regidx;
 		u32 bit;
@@ -3552,8 +3551,8 @@ bnx2_set_rx_mode(struct net_device *dev)
 
 		memset(mc_filter, 0, 4 * NUM_MC_HASH_REGISTERS);
 
-		netdev_for_each_mc_addr(mclist, dev) {
-			crc = ether_crc_le(ETH_ALEN, mclist->dmi_addr);
+		netdev_for_each_mc_addr(ha, dev) {
+			crc = ether_crc_le(ETH_ALEN, ha->addr);
 			bit = crc & 0xff;
 			regidx = (bit & 0xe0) >> 5;
 			bit &= 0x1f;
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index f4ea99d..fa9275c 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -11496,21 +11496,21 @@ static void bnx2x_set_rx_mode(struct net_device *dev)
 	else { /* some multicasts */
 		if (CHIP_IS_E1(bp)) {
 			int i, old, offset;
-			struct dev_mc_list *mclist;
+			struct netdev_hw_addr *ha;
 			struct mac_configuration_cmd *config =
 						bnx2x_sp(bp, mcast_config);
 
 			i = 0;
-			netdev_for_each_mc_addr(mclist, dev) {
+			netdev_for_each_mc_addr(ha, dev) {
 				config->config_table[i].
 					cam_entry.msb_mac_addr =
-					swab16(*(u16 *)&mclist->dmi_addr[0]);
+					swab16(*(u16 *)&ha->addr[0]);
 				config->config_table[i].
 					cam_entry.middle_mac_addr =
-					swab16(*(u16 *)&mclist->dmi_addr[2]);
+					swab16(*(u16 *)&ha->addr[2]);
 				config->config_table[i].
 					cam_entry.lsb_mac_addr =
-					swab16(*(u16 *)&mclist->dmi_addr[4]);
+					swab16(*(u16 *)&ha->addr[4]);
 				config->config_table[i].cam_entry.flags =
 							cpu_to_le16(port);
 				config->config_table[i].
@@ -11564,18 +11564,18 @@ static void bnx2x_set_rx_mode(struct net_device *dev)
 				      0);
 		} else { /* E1H */
 			/* Accept one or more multicasts */
-			struct dev_mc_list *mclist;
+			struct netdev_hw_addr *ha;
 			u32 mc_filter[MC_HASH_SIZE];
 			u32 crc, bit, regidx;
 			int i;
 
 			memset(mc_filter, 0, 4 * MC_HASH_SIZE);
 
-			netdev_for_each_mc_addr(mclist, dev) {
+			netdev_for_each_mc_addr(ha, dev) {
 				DP(NETIF_MSG_IFUP, "Adding mcast MAC: %pM\n",
-				   mclist->dmi_addr);
+				   ha->addr);
 
-				crc = crc32c_le(0, mclist->dmi_addr, ETH_ALEN);
+				crc = crc32c_le(0, ha->addr, ETH_ALEN);
 				bit = (crc >> 24) & 0xff;
 				regidx = bit >> 5;
 				bit &= 0x1f;
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d6ae63b..22682f1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -762,32 +762,6 @@ static int bond_check_dev_link(struct bonding *bond,
 /*----------------------------- Multicast list ------------------------------*/
 
 /*
- * Returns 0 if dmi1 and dmi2 are the same, non-0 otherwise
- */
-static inline int bond_is_dmi_same(const struct dev_mc_list *dmi1,
-				   const struct dev_mc_list *dmi2)
-{
-	return memcmp(dmi1->dmi_addr, dmi2->dmi_addr, dmi1->dmi_addrlen) == 0 &&
-			dmi1->dmi_addrlen == dmi2->dmi_addrlen;
-}
-
-/*
- * returns dmi entry if found, NULL otherwise
- */
-static struct dev_mc_list *bond_mc_list_find_dmi(struct dev_mc_list *dmi,
-						 struct dev_mc_list *mc_list)
-{
-	struct dev_mc_list *idmi;
-
-	for (idmi = mc_list; idmi; idmi = idmi->next) {
-		if (bond_is_dmi_same(dmi, idmi))
-			return idmi;
-	}
-
-	return NULL;
-}
-
-/*
  * Push the promiscuity flag down to appropriate slaves
  */
 static int bond_set_promiscuity(struct bonding *bond, int inc)
@@ -839,18 +813,18 @@ static int bond_set_allmulti(struct bonding *bond, int inc)
  * Add a Multicast address to slaves
  * according to mode
  */
-static void bond_mc_add(struct bonding *bond, void *addr, int alen)
+static void bond_mc_add(struct bonding *bond, void *addr)
 {
 	if (USES_PRIMARY(bond->params.mode)) {
 		/* write lock already acquired */
 		if (bond->curr_active_slave)
-			dev_mc_add(bond->curr_active_slave->dev, addr, alen, 0);
+			dev_mc_add(bond->curr_active_slave->dev, addr);
 	} else {
 		struct slave *slave;
 		int i;
 
 		bond_for_each_slave(bond, slave, i)
-			dev_mc_add(slave->dev, addr, alen, 0);
+			dev_mc_add(slave->dev, addr);
 	}
 }
 
@@ -858,18 +832,17 @@ static void bond_mc_add(struct bonding *bond, void *addr, int alen)
  * Remove a multicast address from slave
  * according to mode
  */
-static void bond_mc_delete(struct bonding *bond, void *addr, int alen)
+static void bond_mc_del(struct bonding *bond, void *addr)
 {
 	if (USES_PRIMARY(bond->params.mode)) {
 		/* write lock already acquired */
 		if (bond->curr_active_slave)
-			dev_mc_delete(bond->curr_active_slave->dev, addr,
-				      alen, 0);
+			dev_mc_del(bond->curr_active_slave->dev, addr);
 	} else {
 		struct slave *slave;
 		int i;
 		bond_for_each_slave(bond, slave, i) {
-			dev_mc_delete(slave->dev, addr, alen, 0);
+			dev_mc_del(slave->dev, addr);
 		}
 	}
 }
@@ -896,66 +869,22 @@ static void bond_resend_igmp_join_requests(struct bonding *bond)
 }
 
 /*
- * Totally destroys the mc_list in bond
- */
-static void bond_mc_list_destroy(struct bonding *bond)
-{
-	struct dev_mc_list *dmi;
-
-	dmi = bond->mc_list;
-	while (dmi) {
-		bond->mc_list = dmi->next;
-		kfree(dmi);
-		dmi = bond->mc_list;
-	}
-
-	bond->mc_list = NULL;
-}
-
-/*
- * Copy all the Multicast addresses from src to the bonding device dst
- */
-static int bond_mc_list_copy(struct dev_mc_list *mc_list, struct bonding *bond,
-			     gfp_t gfp_flag)
-{
-	struct dev_mc_list *dmi, *new_dmi;
-
-	for (dmi = mc_list; dmi; dmi = dmi->next) {
-		new_dmi = kmalloc(sizeof(struct dev_mc_list), gfp_flag);
-
-		if (!new_dmi) {
-			/* FIXME: Potential memory leak !!! */
-			return -ENOMEM;
-		}
-
-		new_dmi->next = bond->mc_list;
-		bond->mc_list = new_dmi;
-		new_dmi->dmi_addrlen = dmi->dmi_addrlen;
-		memcpy(new_dmi->dmi_addr, dmi->dmi_addr, dmi->dmi_addrlen);
-		new_dmi->dmi_users = dmi->dmi_users;
-		new_dmi->dmi_gusers = dmi->dmi_gusers;
-	}
-
-	return 0;
-}
-
-/*
  * flush all members of flush->mc_list from device dev->mc_list
  */
 static void bond_mc_list_flush(struct net_device *bond_dev,
 			       struct net_device *slave_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 
-	for (dmi = bond_dev->mc_list; dmi; dmi = dmi->next)
-		dev_mc_delete(slave_dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
+	netdev_for_each_mc_addr(ha, bond_dev)
+		dev_mc_del(slave_dev, ha->addr);
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		/* del lacpdu mc addr from mc list */
 		u8 lacpdu_multicast[ETH_ALEN] = MULTICAST_LACPDU_ADDR;
 
-		dev_mc_delete(slave_dev, lacpdu_multicast, ETH_ALEN, 0);
+		dev_mc_del(slave_dev, lacpdu_multicast);
 	}
 }
 
@@ -969,7 +898,7 @@ static void bond_mc_list_flush(struct net_device *bond_dev,
 static void bond_mc_swap(struct bonding *bond, struct slave *new_active,
 			 struct slave *old_active)
 {
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 
 	if (!USES_PRIMARY(bond->params.mode))
 		/* nothing to do -  mc list is already up-to-date on
@@ -984,9 +913,8 @@ static void bond_mc_swap(struct bonding *bond, struct slave *new_active,
 		if (bond->dev->flags & IFF_ALLMULTI)
 			dev_set_allmulti(old_active->dev, -1);
 
-		for (dmi = bond->dev->mc_list; dmi; dmi = dmi->next)
-			dev_mc_delete(old_active->dev, dmi->dmi_addr,
-				      dmi->dmi_addrlen, 0);
+		netdev_for_each_mc_addr(ha, bond->dev)
+			dev_mc_del(old_active->dev, ha->addr);
 	}
 
 	if (new_active) {
@@ -997,9 +925,8 @@ static void bond_mc_swap(struct bonding *bond, struct slave *new_active,
 		if (bond->dev->flags & IFF_ALLMULTI)
 			dev_set_allmulti(new_active->dev, 1);
 
-		for (dmi = bond->dev->mc_list; dmi; dmi = dmi->next)
-			dev_mc_add(new_active->dev, dmi->dmi_addr,
-				   dmi->dmi_addrlen, 0);
+		netdev_for_each_mc_addr(ha, bond->dev)
+			dev_mc_add(new_active->dev, ha->addr);
 		bond_resend_igmp_join_requests(bond);
 	}
 }
@@ -1406,7 +1333,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	struct bonding *bond = netdev_priv(bond_dev);
 	const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
 	struct slave *new_slave = NULL;
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	struct sockaddr addr;
 	int link_reporting;
 	int old_features = bond_dev->features;
@@ -1492,7 +1419,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 			/* Flush unicast and multicast addresses */
 			dev_uc_flush(bond_dev);
-			dev_addr_discard(bond_dev);
+			dev_mc_flush(bond_dev);
 
 			if (slave_dev->type != ARPHRD_ETHER)
 				bond_setup_by_slave(bond_dev, slave_dev);
@@ -1601,9 +1528,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 		netif_addr_lock_bh(bond_dev);
 		/* upload master's mc_list to new slave */
-		for (dmi = bond_dev->mc_list; dmi; dmi = dmi->next)
-			dev_mc_add(slave_dev, dmi->dmi_addr,
-				   dmi->dmi_addrlen, 0);
+		netdev_for_each_mc_addr(ha, bond_dev)
+			dev_mc_add(slave_dev, ha->addr);
 		netif_addr_unlock_bh(bond_dev);
 	}
 
@@ -1611,7 +1537,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		/* add lacpdu mc addr to mc list */
 		u8 lacpdu_multicast[ETH_ALEN] = MULTICAST_LACPDU_ADDR;
 
-		dev_mc_add(slave_dev, lacpdu_multicast, ETH_ALEN, 0);
+		dev_mc_add(slave_dev, lacpdu_multicast);
 	}
 
 	bond_add_vlans_on_slave(bond, slave_dev);
@@ -3913,10 +3839,24 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 	return res;
 }
 
+static bool bond_addr_in_mc_list(unsigned char *addr,
+				 struct netdev_hw_addr_list *list,
+				 int addrlen)
+{
+	struct netdev_hw_addr *ha;
+
+	netdev_hw_addr_list_for_each(ha, list)
+		if (!memcmp(ha->addr, addr, addrlen))
+			return true;
+
+	return false;
+}
+
 static void bond_set_multicast_list(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
+	bool found;
 
 	/*
 	 * Do promisc before checking multicast_mode
@@ -3951,20 +3891,25 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
 	bond->flags = bond_dev->flags;
 
 	/* looking for addresses to add to slaves' mc list */
-	for (dmi = bond_dev->mc_list; dmi; dmi = dmi->next) {
-		if (!bond_mc_list_find_dmi(dmi, bond->mc_list))
-			bond_mc_add(bond, dmi->dmi_addr, dmi->dmi_addrlen);
+	netdev_for_each_mc_addr(ha, bond_dev) {
+		found = bond_addr_in_mc_list(ha->addr, &bond->mc_list,
+					     bond_dev->addr_len);
+		if (!found)
+			bond_mc_add(bond, ha->addr);
 	}
 
 	/* looking for addresses to delete from slaves' list */
-	for (dmi = bond->mc_list; dmi; dmi = dmi->next) {
-		if (!bond_mc_list_find_dmi(dmi, bond_dev->mc_list))
-			bond_mc_delete(bond, dmi->dmi_addr, dmi->dmi_addrlen);
+	netdev_hw_addr_list_for_each(ha, &bond->mc_list) {
+		found = bond_addr_in_mc_list(ha->addr, &bond_dev->mc,
+					     bond_dev->addr_len);
+		if (!found)
+			bond_mc_del(bond, ha->addr);
 	}
 
 	/* save master's multicast list */
-	bond_mc_list_destroy(bond);
-	bond_mc_list_copy(bond_dev->mc_list, bond, GFP_ATOMIC);
+	__hw_addr_flush(&bond->mc_list);
+	__hw_addr_add_multiple(&bond->mc_list, &bond_dev->mc,
+			       bond_dev->addr_len, NETDEV_HW_ADDR_T_MULTICAST);
 
 	read_unlock(&bond->lock);
 }
@@ -4534,9 +4479,7 @@ static void bond_uninit(struct net_device *bond_dev)
 	if (bond->wq)
 		destroy_workqueue(bond->wq);
 
-	netif_addr_lock_bh(bond_dev);
-	bond_mc_list_destroy(bond);
-	netif_addr_unlock_bh(bond_dev);
+	__hw_addr_flush(&bond->mc_list);
 }
 
 /*------------------------- Module initialization ---------------------------*/
@@ -4908,6 +4851,8 @@ static int bond_init(struct net_device *bond_dev)
 	list_add_tail(&bond->bond_list, &bn->dev_list);
 
 	bond_prepare_sysfs_group(bond);
+
+	__hw_addr_init(&bond->mc_list);
 	return 0;
 }
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 257a7a4..2aa3367 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -202,7 +202,7 @@ struct bonding {
 	char     proc_file_name[IFNAMSIZ];
 #endif /* CONFIG_PROC_FS */
 	struct   list_head bond_list;
-	struct   dev_mc_list *mc_list;
+	struct   netdev_hw_addr_list mc_list;
 	int      (*xmit_hash_policy)(struct sk_buff *, int);
 	__be32   master_ip;
 	u16      flags;
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 9bd155e..bd857a2 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2957,20 +2957,20 @@ static void cas_process_mc_list(struct cas *cp)
 {
 	u16 hash_table[16];
 	u32 crc;
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	int i = 1;
 
 	memset(hash_table, 0, sizeof(hash_table));
-	netdev_for_each_mc_addr(dmi, cp->dev) {
+	netdev_for_each_mc_addr(ha, cp->dev) {
 		if (i <= CAS_MC_EXACT_MATCH_SIZE) {
 			/* use the alternate mac address registers for the
 			 * first 15 multicast addresses
 			 */
-			writel((dmi->dmi_addr[4] << 8) | dmi->dmi_addr[5],
+			writel((ha->addr[4] << 8) | ha->addr[5],
 			       cp->regs + REG_MAC_ADDRN(i*3 + 0));
-			writel((dmi->dmi_addr[2] << 8) | dmi->dmi_addr[3],
+			writel((ha->addr[2] << 8) | ha->addr[3],
 			       cp->regs + REG_MAC_ADDRN(i*3 + 1));
-			writel((dmi->dmi_addr[0] << 8) | dmi->dmi_addr[1],
+			writel((ha->addr[0] << 8) | ha->addr[1],
 			       cp->regs + REG_MAC_ADDRN(i*3 + 2));
 			i++;
 		}
@@ -2978,7 +2978,7 @@ static void cas_process_mc_list(struct cas *cp)
 			/* use hw hash table for the next series of
 			 * multicast addresses
 			 */
-			crc = ether_crc_le(ETH_ALEN, dmi->dmi_addr);
+			crc = ether_crc_le(ETH_ALEN, ha->addr);
 			crc >>= 24;
 			hash_table[crc >> 4] |= 1 << (15 - (crc & 0xf));
 		}
diff --git a/drivers/net/chelsio/pm3393.c b/drivers/net/chelsio/pm3393.c
index a6eb30a..13fd962 100644
--- a/drivers/net/chelsio/pm3393.c
+++ b/drivers/net/chelsio/pm3393.c
@@ -376,12 +376,13 @@ static int pm3393_set_rx_mode(struct cmac *cmac, struct t1_rx_mode *rm)
 		rx_mode |= SUNI1x10GEXP_BITMSK_RXXG_MHASH_EN;
 	} else if (t1_rx_mode_mc_cnt(rm)) {
 		/* Accept one or more multicast(s). */
-		struct dev_mc_list *dmi;
+		struct netdev_hw_addr *ha;
 		int bit;
 		u16 mc_filter[4] = { 0, };
 
-		netdev_for_each_mc_addr(dmi, t1_get_netdev(rm)) {
-			bit = (ether_crc(ETH_ALEN, dmi->dmi_addr) >> 23) & 0x3f; /* bit[23:28] */
+		netdev_for_each_mc_addr(ha, t1_get_netdev(rm)) {
+			/* bit[23:28] */
+			bit = (ether_crc(ETH_ALEN, ha->addr) >> 23) & 0x3f;
 			mc_filter[bit >> 4] |= 1 << (bit & 0xf);
 		}
 		pmwrite(cmac, SUNI1x10GEXP_REG_RXXG_MULTICAST_HASH_LOW, mc_filter[0]);
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 60777fd..bdfff78 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -328,7 +328,7 @@ static int cpmac_config(struct net_device *dev, struct ifmap *map)
 
 static void cpmac_set_multicast_list(struct net_device *dev)
 {
-	struct dev_mc_list *iter;
+	struct netdev_hw_addr *ha;
 	u8 tmp;
 	u32 mbp, bit, hash[2] = { 0, };
 	struct cpmac_priv *priv = netdev_priv(dev);
@@ -348,19 +348,19 @@ static void cpmac_set_multicast_list(struct net_device *dev)
 			 * cpmac uses some strange mac address hashing
 			 * (not crc32)
 			 */
-			netdev_for_each_mc_addr(iter, dev) {
+			netdev_for_each_mc_addr(ha, dev) {
 				bit = 0;
-				tmp = iter->dmi_addr[0];
+				tmp = ha->addr[0];
 				bit  ^= (tmp >> 2) ^ (tmp << 4);
-				tmp = iter->dmi_addr[1];
+				tmp = ha->addr[1];
 				bit  ^= (tmp >> 4) ^ (tmp << 2);
-				tmp = iter->dmi_addr[2];
+				tmp = ha->addr[2];
 				bit  ^= (tmp >> 6) ^ tmp;
-				tmp = iter->dmi_addr[3];
+				tmp = ha->addr[3];
 				bit  ^= (tmp >> 2) ^ (tmp << 4);
-				tmp = iter->dmi_addr[4];
+				tmp = ha->addr[4];
 				bit  ^= (tmp >> 4) ^ (tmp << 2);
-				tmp = iter->dmi_addr[5];
+				tmp = ha->addr[5];
 				bit  ^= (tmp >> 6) ^ tmp;
 				bit &= 0x3f;
 				hash[bit / 32] |= 1 << (bit % 32);
diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index dd24aad..59110bc 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -1596,16 +1596,16 @@ set_multicast_list(struct net_device *dev)
 	} else {
 		/* MC mode, receive normal and MC packets */
 		char hash_ix;
-		struct dev_mc_list *dmi;
+		struct netdev_hw_addr *ha;
 		char *baddr;
 
 		lo_bits = 0x00000000ul;
 		hi_bits = 0x00000000ul;
-		netdev_for_each_mc_addr(dmi, dev) {
+		netdev_for_each_mc_addr(ha, dev) {
 			/* Calculate the hash index for the GA registers */
 
 			hash_ix = 0;
-			baddr = dmi->dmi_addr;
+			baddr = ha->addr;
 			hash_ix ^= (*baddr) & 0x3f;
 			hash_ix ^= ((*baddr) >> 6) & 0x03;
 			++baddr;
diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/cxgb3/xgmac.c
index c142a21..3af19a5 100644
--- a/drivers/net/cxgb3/xgmac.c
+++ b/drivers/net/cxgb3/xgmac.c
@@ -311,16 +311,16 @@ int t3_mac_set_rx_mode(struct cmac *mac, struct net_device *dev)
 	if (dev->flags & IFF_ALLMULTI)
 		hash_lo = hash_hi = 0xffffffff;
 	else {
-		struct dev_mc_list *dmi;
+		struct netdev_hw_addr *ha;
 		int exact_addr_idx = mac->nucast;
 
 		hash_lo = hash_hi = 0;
-		netdev_for_each_mc_addr(dmi, dev)
+		netdev_for_each_mc_addr(ha, dev)
 			if (exact_addr_idx < EXACT_ADDR_FILTERS)
 				set_addr_filter(mac, exact_addr_idx++,
-						dmi->dmi_addr);
+						ha->addr);
 			else {
-				int hash = hash_hw_addr(dmi->dmi_addr);
+				int hash = hash_hw_addr(ha->addr);
 
 				if (hash < 32)
 					hash_lo |= (1 << hash);
diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 2b8edd2..1f9df5c 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -952,13 +952,14 @@ static void emac_dev_mcast_set(struct net_device *ndev)
 			emac_add_mcast(priv, EMAC_ALL_MULTI_SET, NULL);
 		}
 		if (!netdev_mc_empty(ndev)) {
-			struct dev_mc_list *mc_ptr;
+			struct netdev_hw_addr *ha;
+
 			mbp_enable = (mbp_enable | EMAC_MBP_RXMCAST);
 			emac_add_mcast(priv, EMAC_ALL_MULTI_CLR, NULL);
 			/* program multicast address list into EMAC hardware */
-			netdev_for_each_mc_addr(mc_ptr, ndev) {
+			netdev_for_each_mc_addr(ha, ndev) {
 				emac_add_mcast(priv, EMAC_MULTICAST_ADD,
-					       (u8 *) mc_ptr->dmi_addr);
+					       (u8 *) ha->addr);
 			}
 		} else {
 			mbp_enable = (mbp_enable & ~EMAC_MBP_RXMCAST);
diff --git a/drivers/net/declance.c b/drivers/net/declance.c
index 8cf3cc6..fb3f098 100644
--- a/drivers/net/declance.c
+++ b/drivers/net/declance.c
@@ -940,7 +940,7 @@ static void lance_load_multicast(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
 	volatile u16 *ib = (volatile u16 *)dev->mem_start;
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	char *addrs;
 	u32 crc;
 
@@ -959,8 +959,8 @@ static void lance_load_multicast(struct net_device *dev)
 	*lib_ptr(ib, filter[3], lp->type) = 0;
 
 	/* Add addresses */
-	netdev_for_each_mc_addr(dmi, dev) {
-		addrs = dmi->dmi_addr;
+	netdev_for_each_mc_addr(ha, dev) {
+		addrs = ha->addr;
 
 		/* multicast address? */
 		if (!(*addrs & 1))
diff --git a/drivers/net/defxx.c b/drivers/net/defxx.c
index ed53a8d..e5667c5 100644
--- a/drivers/net/defxx.c
+++ b/drivers/net/defxx.c
@@ -2195,7 +2195,7 @@ static void dfx_ctl_set_multicast_list(struct net_device *dev)
 {
 	DFX_board_t *bp = netdev_priv(dev);
 	int					i;			/* used as index in for loop */
-	struct dev_mc_list	*dmi;		/* ptr to multicast addr entry */
+	struct netdev_hw_addr *ha;
 
 	/* Enable LLC frame promiscuous mode, if necessary */
 
@@ -2241,9 +2241,9 @@ static void dfx_ctl_set_multicast_list(struct net_device *dev)
 		/* Copy addresses to multicast address table, then update adapter CAM */
 
 		i = 0;
-		netdev_for_each_mc_addr(dmi, dev)
+		netdev_for_each_mc_addr(ha, dev)
 			memcpy(&bp->mc_table[i++ * FDDI_K_ALEN],
-			       dmi->dmi_addr, FDDI_K_ALEN);
+			       ha->addr, FDDI_K_ALEN);
 
 		if (dfx_ctl_update_cam(bp) != DFX_K_SUCCESS)
 			{
diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index 744c192..a88300a 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -1272,7 +1272,7 @@ static void set_multicast_list(struct net_device *dev)
 static void SetMulticastFilter(struct net_device *dev)
 {
 	struct depca_private *lp = netdev_priv(dev);
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	char *addrs;
 	int i, j, bit, byte;
 	u16 hashcode;
@@ -1287,8 +1287,8 @@ static void SetMulticastFilter(struct net_device *dev)
 			lp->init_block.mcast_table[i] = 0;
 		}
 		/* Add multicast addresses */
-		netdev_for_each_mc_addr(dmi, dev) {
-			addrs = dmi->dmi_addr;
+		netdev_for_each_mc_addr(ha, dev) {
+			addrs = ha->addr;
 			if ((*addrs & 0x01) == 1) {	/* multicast address? */
 				crc = ether_crc(ETH_ALEN, addrs);
 				hashcode = (crc & 1);	/* hashcode is 6 LSb of CRC ... */
diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index b05bad8..6579225 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -1132,14 +1132,14 @@ set_multicast (struct net_device *dev)
 		/* Receive broadcast and multicast frames */
 		rx_mode = ReceiveBroadcast | ReceiveMulticast | ReceiveUnicast;
 	} else if (!netdev_mc_empty(dev)) {
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 		/* Receive broadcast frames and multicast frames filtering
 		   by Hashtable */
 		rx_mode =
 		    ReceiveBroadcast | ReceiveMulticastHash | ReceiveUnicast;
-		netdev_for_each_mc_addr(mclist, dev) {
+		netdev_for_each_mc_addr(ha, dev) {
 			int bit, index = 0;
-			int crc = ether_crc_le (ETH_ALEN, mclist->dmi_addr);
+			int crc = ether_crc_le(ETH_ALEN, ha->addr);
 			/* The inverted high significant 6 bits of CRC are
 			   used as an index to hashtable */
 			for (bit = 0; bit < 6; bit++)
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 1c67f11..989f2be 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -724,7 +724,7 @@ static void
 dm9000_hash_table(struct net_device *dev)
 {
 	board_info_t *db = netdev_priv(dev);
-	struct dev_mc_list *mcptr;
+	struct netdev_hw_addr *ha;
 	int i, oft;
 	u32 hash_val;
 	u16 hash_table[4];
@@ -752,8 +752,8 @@ dm9000_hash_table(struct net_device *dev)
 		rcr |= RCR_ALL;
 
 	/* the multicast address in Hash Table : 64 bits */
-	netdev_for_each_mc_addr(mcptr, dev) {
-		hash_val = ether_crc_le(6, mcptr->dmi_addr) & 0x3f;
+	netdev_for_each_mc_addr(ha, dev) {
+		hash_val = ether_crc_le(6, ha->addr) & 0x3f;
 		hash_table[hash_val / 16] |= (u16) 1 << (hash_val % 16);
 	}
 
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index c0cd576..3e8d000 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1545,16 +1545,16 @@ static int e100_hw_init(struct nic *nic)
 static void e100_multi(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 {
 	struct net_device *netdev = nic->netdev;
-	struct dev_mc_list *list;
+	struct netdev_hw_addr *ha;
 	u16 i, count = min(netdev_mc_count(netdev), E100_MAX_MULTICAST_ADDRS);
 
 	cb->command = cpu_to_le16(cb_multi);
 	cb->u.multi.count = cpu_to_le16(count * ETH_ALEN);
 	i = 0;
-	netdev_for_each_mc_addr(list, netdev) {
+	netdev_for_each_mc_addr(ha, netdev) {
 		if (i == count)
 			break;
-		memcpy(&cb->u.multi.addr[i++ * ETH_ALEN], &list->dmi_addr,
+		memcpy(&cb->u.multi.addr[i++ * ETH_ALEN], &ha->addr,
 			ETH_ALEN);
 	}
 }
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 8be6fae..4133034 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2101,7 +2101,6 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 	struct e1000_hw *hw = &adapter->hw;
 	struct netdev_hw_addr *ha;
 	bool use_uc = false;
-	struct dev_addr_list *mc_ptr;
 	u32 rctl;
 	u32 hash_value;
 	int i, rar_entries = E1000_RAR_ENTRIES;
@@ -2161,17 +2160,17 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 
 	WARN_ON(i == rar_entries);
 
-	netdev_for_each_mc_addr(mc_ptr, netdev) {
+	netdev_for_each_mc_addr(ha, netdev) {
 		if (i == rar_entries) {
 			/* load any remaining addresses into the hash table */
 			u32 hash_reg, hash_bit, mta;
-			hash_value = e1000_hash_mc_addr(hw, mc_ptr->da_addr);
+			hash_value = e1000_hash_mc_addr(hw, ha->addr);
 			hash_reg = (hash_value >> 5) & 0x7F;
 			hash_bit = hash_value & 0x1F;
 			mta = (1 << hash_bit);
 			mcarray[hash_reg] |= mta;
 		} else {
-			e1000_rar_set(hw, mc_ptr->da_addr, i++);
+			e1000_rar_set(hw, ha->addr, i++);
 		}
 	}
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 5304959..02f7d20 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2567,7 +2567,7 @@ static void e1000_set_multi(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	struct dev_mc_list *mc_ptr;
+	struct netdev_hw_addr *ha;
 	u8  *mta_list;
 	u32 rctl;
 	int i;
@@ -2599,9 +2599,8 @@ static void e1000_set_multi(struct net_device *netdev)
 
 		/* prepare a packed array of only addresses. */
 		i = 0;
-		netdev_for_each_mc_addr(mc_ptr, netdev)
-			memcpy(mta_list + (i++ * ETH_ALEN),
-			       mc_ptr->dmi_addr, ETH_ALEN);
+		netdev_for_each_mc_addr(ha, netdev)
+			memcpy(mta_list + (i++ * ETH_ALEN), ha->addr, ETH_ALEN);
 
 		e1000_update_mc_addr_list(hw, mta_list, i);
 		kfree(mta_list);
diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index 15d6266..b01e699 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -1287,7 +1287,7 @@ set_multicast_list(struct net_device *dev)
 	struct eepro_local *lp = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 	unsigned short mode;
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	int mc_count = netdev_mc_count(dev);
 
 	if (dev->flags&(IFF_ALLMULTI|IFF_PROMISC) || mc_count > 63)
@@ -1332,8 +1332,8 @@ set_multicast_list(struct net_device *dev)
 		outw(0, ioaddr + IO_PORT);
 		outw(6 * (mc_count + 1), ioaddr + IO_PORT);
 
-		netdev_for_each_mc_addr(dmi, dev) {
-			eaddrs = (unsigned short *) dmi->dmi_addr;
+		netdev_for_each_mc_addr(ha, dev) {
+			eaddrs = (unsigned short *) ha->addr;
 			outw(*eaddrs++, ioaddr + IO_PORT);
 			outw(*eaddrs++, ioaddr + IO_PORT);
 			outw(*eaddrs++, ioaddr + IO_PORT);
diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
index 7013dc8..b3882fd 100644
--- a/drivers/net/eexpress.c
+++ b/drivers/net/eexpress.c
@@ -1576,7 +1576,7 @@ static void eexp_hw_init586(struct net_device *dev)
 
 static void eexp_setup_filter(struct net_device *dev)
 {
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	unsigned short ioaddr = dev->base_addr;
 	int count = netdev_mc_count(dev);
 	int i;
@@ -1589,8 +1589,8 @@ static void eexp_setup_filter(struct net_device *dev)
 	outw(CONF_NR_MULTICAST & ~31, ioaddr+SM_PTR);
 	outw(6*count, ioaddr+SHADOW(CONF_NR_MULTICAST));
 	i = 0;
-	netdev_for_each_mc_addr(dmi, dev) {
-		unsigned short *data = (unsigned short *) dmi->dmi_addr;
+	netdev_for_each_mc_addr(ha, dev) {
+		unsigned short *data = (unsigned short *) ha->addr;
 
 		if (i == count)
 			break;
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index b004eab..b97411a 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -1966,7 +1966,7 @@ static void ehea_add_multicast_entry(struct ehea_port *port, u8 *mc_mac_addr)
 static void ehea_set_multicast_list(struct net_device *dev)
 {
 	struct ehea_port *port = netdev_priv(dev);
-	struct dev_mc_list *k_mcl_entry;
+	struct netdev_hw_addr *ha;
 	int ret;
 
 	if (dev->flags & IFF_PROMISC) {
@@ -1997,8 +1997,8 @@ static void ehea_set_multicast_list(struct net_device *dev)
 			goto out;
 		}
 
-		netdev_for_each_mc_addr(k_mcl_entry, dev)
-			ehea_add_multicast_entry(port, k_mcl_entry->dmi_addr);
+		netdev_for_each_mc_addr(ha, dev)
+			ehea_add_multicast_entry(port, ha->addr);
 
 	}
 out:
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 6d70c34..1232887 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -822,7 +822,7 @@ static int enic_set_mac_addr(struct net_device *netdev, char *addr)
 static void enic_set_multicast_list(struct net_device *netdev)
 {
 	struct enic *enic = netdev_priv(netdev);
-	struct dev_mc_list *list;
+	struct netdev_hw_addr *ha;
 	int directed = 1;
 	int multicast = (netdev->flags & IFF_MULTICAST) ? 1 : 0;
 	int broadcast = (netdev->flags & IFF_BROADCAST) ? 1 : 0;
@@ -852,10 +852,10 @@ static void enic_set_multicast_list(struct net_device *netdev)
 	 */
 
 	i = 0;
-	netdev_for_each_mc_addr(list, netdev) {
+	netdev_for_each_mc_addr(ha, netdev) {
 		if (i == mc_count)
 			break;
-		memcpy(mc_addr[i++], list->dmi_addr, ETH_ALEN);
+		memcpy(mc_addr[i++], ha->addr, ETH_ALEN);
 	}
 
 	for (i = 0; i < enic->mc_count; i++) {
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 39c271b..f6584a1 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -1400,12 +1400,12 @@ static void set_rx_mode(struct net_device *dev)
 		outl(0x0004, ioaddr + RxCtrl);
 		return;
 	} else {					/* Never executed, for now. */
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		netdev_for_each_mc_addr(mclist, dev) {
+		netdev_for_each_mc_addr(ha, dev) {
 			unsigned int bit_nr =
-				ether_crc_le(ETH_ALEN, mclist->dmi_addr) & 0x3f;
+				ether_crc_le(ETH_ALEN, ha->addr) & 0x3f;
 			mc_filter[bit_nr >> 3] |= (1 << bit_nr);
 		}
 	}
diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 2097423..f6be5ae 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -755,7 +755,7 @@ static void ethoc_set_multicast_list(struct net_device *dev)
 {
 	struct ethoc *priv = netdev_priv(dev);
 	u32 mode = ethoc_read(priv, MODER);
-	struct dev_mc_list *mc;
+	struct netdev_hw_addr *ha;
 	u32 hash[2] = { 0, 0 };
 
 	/* set loopback mode if requested */
@@ -783,8 +783,8 @@ static void ethoc_set_multicast_list(struct net_device *dev)
 		hash[0] = 0xffffffff;
 		hash[1] = 0xffffffff;
 	} else {
-		netdev_for_each_mc_addr(mc, dev) {
-			u32 crc = ether_crc(ETH_ALEN, mc->dmi_addr);
+		netdev_for_each_mc_addr(ha, dev) {
+			u32 crc = ether_crc(ETH_ALEN, ha->addr);
 			int bit = (crc >> 26) & 0x3f;
 			hash[bit >> 5] |= 1 << (bit & 0x1f);
 		}
diff --git a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
index a2bade5..11ba70f 100644
--- a/drivers/net/ewrk3.c
+++ b/drivers/net/ewrk3.c
@@ -1169,7 +1169,7 @@ static void set_multicast_list(struct net_device *dev)
 static void SetMulticastFilter(struct net_device *dev)
 {
 	struct ewrk3_private *lp = netdev_priv(dev);
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	u_long iobase = dev->base_addr;
 	int i;
 	char *addrs, bit, byte;
@@ -1213,8 +1213,8 @@ static void SetMulticastFilter(struct net_device *dev)
 		}
 
 		/* Update table */
-		netdev_for_each_mc_addr(dmi, dev) {
-			addrs = dmi->dmi_addr;
+		netdev_for_each_mc_addr(ha, dev) {
+			addrs = ha->addr;
 			if ((*addrs & 0x01) == 1) {	/* multicast address? */
 				crc = ether_crc_le(ETH_ALEN, addrs);
 				hashcode = crc & ((1 << 9) - 1);	/* hashcode is 9 LSb of CRC */
diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index 9d5ad08..e8a2705 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -1792,12 +1792,12 @@ static void __set_rx_mode(struct net_device *dev)
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = CR_W_AB | CR_W_AM;
 	} else {
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		netdev_for_each_mc_addr(mclist, dev) {
+		netdev_for_each_mc_addr(ha, dev) {
 			unsigned int bit;
-			bit = (ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26) ^ 0x3F;
+			bit = (ether_crc(ETH_ALEN, ha->addr) >> 26) ^ 0x3F;
 			mc_filter[bit >> 5] |= (1 << bit);
 		}
 		rx_mode = CR_W_AB | CR_W_AM;
diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 848eb19..2b1651a 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -954,7 +954,7 @@ fec_enet_close(struct net_device *dev)
 static void set_multicast_list(struct net_device *dev)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	unsigned int i, bit, data, crc, tmp;
 	unsigned char hash;
 
@@ -984,16 +984,16 @@ static void set_multicast_list(struct net_device *dev)
 	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
 	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
 
-	netdev_for_each_mc_addr(dmi, dev) {
+	netdev_for_each_mc_addr(ha, dev) {
 		/* Only support group multicast for now */
-		if (!(dmi->dmi_addr[0] & 1))
+		if (!(ha->addr[0] & 1))
 			continue;
 
 		/* calculate crc32 value of mac address */
 		crc = 0xffffffff;
 
-		for (i = 0; i < dmi->dmi_addrlen; i++) {
-			data = dmi->dmi_addr[i];
+		for (i = 0; i < dev->addr_len; i++) {
+			data = ha->addr[i];
 			for (bit = 0; bit < 8; bit++, data >>= 1) {
 				crc = (crc >> 1) ^
 				(((crc ^ data) & 1) ? CRC32_POLY : 0);
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index 704155e..667ba13 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -574,12 +574,12 @@ static void mpc52xx_fec_set_multicast_list(struct net_device *dev)
 			out_be32(&fec->gaddr2, 0xffffffff);
 		} else {
 			u32 crc;
-			struct dev_mc_list *dmi;
+			struct netdev_hw_addr *ha;
 			u32 gaddr1 = 0x00000000;
 			u32 gaddr2 = 0x00000000;
 
-			netdev_for_each_mc_addr(dmi, dev) {
-				crc = ether_crc_le(6, dmi->dmi_addr) >> 26;
+			netdev_for_each_mc_addr(ha, dev) {
+				crc = ether_crc_le(6, ha->addr) >> 26;
 				if (crc >= 32)
 					gaddr1 |= 1 << (crc-32);
 				else
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index ca05e56..6a2b64f 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -3103,12 +3103,14 @@ static void nv_set_multicast(struct net_device *dev)
 			if (dev->flags & IFF_ALLMULTI) {
 				alwaysOn[0] = alwaysOn[1] = alwaysOff[0] = alwaysOff[1] = 0;
 			} else {
-				struct dev_mc_list *walk;
+				struct netdev_hw_addr *ha;
 
-				netdev_for_each_mc_addr(walk, dev) {
+				netdev_for_each_mc_addr(ha, dev) {
+					unsigned char *addr = ha->addr;
 					u32 a, b;
-					a = le32_to_cpu(*(__le32 *) walk->dmi_addr);
-					b = le16_to_cpu(*(__le16 *) (&walk->dmi_addr[4]));
+
+					a = le32_to_cpu(*(__le32 *) addr);
+					b = le16_to_cpu(*(__le16 *) (&addr[4]));
 					alwaysOn[0] &= a;
 					alwaysOff[0] &= ~a;
 					alwaysOn[1] &= b;
diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
index cf4f674..b3bad7c 100644
--- a/drivers/net/fs_enet/mac-fcc.c
+++ b/drivers/net/fs_enet/mac-fcc.c
@@ -231,12 +231,12 @@ static void set_multicast_finish(struct net_device *dev)
 
 static void set_multicast_list(struct net_device *dev)
 {
-	struct dev_mc_list *pmc;
+	struct netdev_hw_addr *ha;
 
 	if ((dev->flags & IFF_PROMISC) == 0) {
 		set_multicast_start(dev);
-		netdev_for_each_mc_addr(pmc, dev)
-			set_multicast_one(dev, pmc->dmi_addr);
+		netdev_for_each_mc_addr(ha, dev)
+			set_multicast_one(dev, ha->addr);
 		set_multicast_finish(dev);
 	} else
 		set_promiscuous_mode(dev);
diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
index cd2c6cc..75974c6 100644
--- a/drivers/net/fs_enet/mac-fec.c
+++ b/drivers/net/fs_enet/mac-fec.c
@@ -232,12 +232,12 @@ static void set_multicast_finish(struct net_device *dev)
 
 static void set_multicast_list(struct net_device *dev)
 {
-	struct dev_mc_list *pmc;
+	struct netdev_hw_addr *ha;
 
 	if ((dev->flags & IFF_PROMISC) == 0) {
 		set_multicast_start(dev);
-		netdev_for_each_mc_addr(pmc, dev)
-			set_multicast_one(dev, pmc->dmi_addr);
+		netdev_for_each_mc_addr(ha, dev)
+			set_multicast_one(dev, ha->addr);
 		set_multicast_finish(dev);
 	} else
 		set_promiscuous_mode(dev);
diff --git a/drivers/net/fs_enet/mac-scc.c b/drivers/net/fs_enet/mac-scc.c
index c490a46..0ab6a34 100644
--- a/drivers/net/fs_enet/mac-scc.c
+++ b/drivers/net/fs_enet/mac-scc.c
@@ -224,12 +224,12 @@ static void set_multicast_finish(struct net_device *dev)
 
 static void set_multicast_list(struct net_device *dev)
 {
-	struct dev_mc_list *pmc;
+	struct netdev_hw_addr *ha;
 
 	if ((dev->flags & IFF_PROMISC) == 0) {
 		set_multicast_start(dev);
-		netdev_for_each_mc_addr(pmc, dev)
-			set_multicast_one(dev, pmc->dmi_addr);
+		netdev_for_each_mc_addr(ha, dev)
+			set_multicast_one(dev, ha->addr);
 		set_multicast_finish(dev);
 	} else
 		set_promiscuous_mode(dev);
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index b671555..fdd26c2 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2797,7 +2797,7 @@ static void adjust_link(struct net_device *dev)
  * whenever dev->flags is changed */
 static void gfar_set_multi(struct net_device *dev)
 {
-	struct dev_mc_list *mc_ptr;
+	struct netdev_hw_addr *ha;
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
 	u32 tempval;
@@ -2870,13 +2870,12 @@ static void gfar_set_multi(struct net_device *dev)
 			return;
 
 		/* Parse the list, and set the appropriate bits */
-		netdev_for_each_mc_addr(mc_ptr, dev) {
+		netdev_for_each_mc_addr(ha, dev) {
 			if (idx < em_num) {
-				gfar_set_mac_for_addr(dev, idx,
-						mc_ptr->dmi_addr);
+				gfar_set_mac_for_addr(dev, idx, ha->addr);
 				idx++;
 			} else
-				gfar_set_hash_for_addr(dev, mc_ptr->dmi_addr);
+				gfar_set_hash_for_addr(dev, ha->addr);
 		}
 	}
 
diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index c5e0d28..fbe6ab6 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -988,7 +988,7 @@ static u32 greth_hash_get_index(__u8 *addr)
 
 static void greth_set_hash_filter(struct net_device *dev)
 {
-	struct dev_mc_list *curr;
+	struct netdev_hw_addr *ha;
 	struct greth_private *greth = netdev_priv(dev);
 	struct greth_regs *regs = (struct greth_regs *) greth->regs;
 	u32 mc_filter[2];
@@ -996,8 +996,8 @@ static void greth_set_hash_filter(struct net_device *dev)
 
 	mc_filter[0] = mc_filter[1] = 0;
 
-	netdev_for_each_mc_addr(curr, dev) {
-		bitnr = greth_hash_get_index(curr->dmi_addr);
+	netdev_for_each_mc_addr(ha, dev) {
+		bitnr = greth_hash_get_index(ha->addr);
 		mc_filter[bitnr >> 5] |= 1 << (bitnr & 31);
 	}
 
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index 373546d..2bfcca6 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -1858,12 +1858,12 @@ static void set_rx_mode(struct net_device *dev)
 		/* Too many to match, or accept all multicasts. */
 		writew(0x000B, ioaddr + AddrMode);
 	} else if (!netdev_mc_empty(dev)) { /* Must use the CAM filter. */
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 		int i = 0;
 
-		netdev_for_each_mc_addr(mclist, dev) {
-			writel(*(u32*)(mclist->dmi_addr), ioaddr + 0x100 + i*8);
-			writel(0x20000 | (*(u16*)&mclist->dmi_addr[4]),
+		netdev_for_each_mc_addr(ha, dev) {
+			writel(*(u32 *)(ha->addr), ioaddr + 0x100 + i*8);
+			writel(0x20000 | (*(u16 *)&ha->addr[4]),
 				   ioaddr + 0x104 + i*8);
 			i++;
 		}
diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
index b766a69..86b2b43 100644
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -2100,15 +2100,15 @@ static void hp100_set_multicast_list(struct net_device *dev)
 		} else {
 			int i, idx;
 			u_char *addrs;
-			struct dev_mc_list *dmi;
+			struct netdev_hw_addr *ha;
 
 			memset(&lp->hash_bytes, 0x00, 8);
 #ifdef HP100_DEBUG
 			printk("hp100: %s: computing hash filter - mc_count = %i\n",
 			       dev->name, netdev_mc_count(dev));
 #endif
-			netdev_for_each_mc_addr(dmi, dev) {
-				addrs = dmi->dmi_addr;
+			netdev_for_each_mc_addr(ha, dev) {
+				addrs = ha->addr;
 				if ((*addrs & 0x01) == 0x01) {	/* multicast address? */
 #ifdef HP100_DEBUG
 					printk("hp100: %s: multicast = %pM, ",
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index d8533a4..40c7850 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -388,18 +388,19 @@ static void emac_hash_mc(struct emac_instance *dev)
 	const int regs = EMAC_XAHT_REGS(dev);
 	u32 *gaht_base = emac_gaht_base(dev);
 	u32 gaht_temp[regs];
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	int i;
 
 	DBG(dev, "hash_mc %d" NL, netdev_mc_count(dev->ndev));
 
 	memset(gaht_temp, 0, sizeof (gaht_temp));
 
-	netdev_for_each_mc_addr(dmi, dev->ndev) {
+	netdev_for_each_mc_addr(ha, dev->ndev) {
 		int slot, reg, mask;
-		DBG2(dev, "mc %pM" NL, dmi->dmi_addr);
+		DBG2(dev, "mc %pM" NL, ha->addr);
 
-		slot = EMAC_XAHT_CRC_TO_SLOT(dev, ether_crc(ETH_ALEN, dmi->dmi_addr));
+		slot = EMAC_XAHT_CRC_TO_SLOT(dev,
+					     ether_crc(ETH_ALEN, ha->addr));
 		reg = EMAC_XAHT_SLOT_TO_REG(dev, slot);
 		mask = EMAC_XAHT_SLOT_TO_MASK(dev, slot);
 
@@ -1176,7 +1177,7 @@ static int emac_open(struct net_device *ndev)
 		netif_carrier_on(dev->ndev);
 
 	/* Required for Pause packet support in EMAC */
-	dev_mc_add(ndev, default_mcast_addr, sizeof(default_mcast_addr), 1);
+	dev_mc_add_global(ndev, default_mcast_addr);
 
 	emac_configure(dev);
 	mal_poll_add(dev->mal, &dev->commac);
diff --git a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
index b5d0f4e..76949e0 100644
--- a/drivers/net/ibmlana.c
+++ b/drivers/net/ibmlana.c
@@ -385,7 +385,7 @@ static void InitBoard(struct net_device *dev)
 	int camcnt;
 	camentry_t cams[16];
 	u32 cammask;
-	struct dev_mc_list *mcptr;
+	struct netdev_hw_addr *ha;
 	u16 rcrval;
 
 	/* reset the SONIC */
@@ -420,8 +420,8 @@ static void InitBoard(struct net_device *dev)
 	/* start putting the multicast addresses into the CAM list.  Stop if
 	   it is full. */
 
-	netdev_for_each_mc_addr(mcptr, dev) {
-		putcam(cams, &camcnt, mcptr->dmi_addr);
+	netdev_for_each_mc_addr(ha, dev) {
+		putcam(cams, &camcnt, ha->addr);
 		if (camcnt == 16)
 			break;
 	}
@@ -479,7 +479,7 @@ static void InitBoard(struct net_device *dev)
 	/* if still multicast addresses left or ALLMULTI is set, set the multicast
 	   enable bit */
 
-	if ((dev->flags & IFF_ALLMULTI) || (mcptr != NULL))
+	if ((dev->flags & IFF_ALLMULTI) || netdev_mc_count(dev) > camcnt)
 		rcrval |= RCREG_AMC;
 
 	/* promiscous mode ? */
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 0bc777b..f468590 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -1072,7 +1072,7 @@ static void ibmveth_set_multicast_list(struct net_device *netdev)
 			ibmveth_error_printk("h_multicast_ctrl rc=%ld when entering promisc mode\n", lpar_rc);
 		}
 	} else {
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 		/* clear the filter table & disable filtering */
 		lpar_rc = h_multicast_ctrl(adapter->vdev->unit_address,
 					   IbmVethMcastEnableRecv |
@@ -1083,10 +1083,10 @@ static void ibmveth_set_multicast_list(struct net_device *netdev)
 			ibmveth_error_printk("h_multicast_ctrl rc=%ld when attempting to clear filter table\n", lpar_rc);
 		}
 		/* add the addresses to the filter table */
-		netdev_for_each_mc_addr(mclist, netdev) {
+		netdev_for_each_mc_addr(ha, netdev) {
 			// add the multicast address to the filter table
 			unsigned long mcast_addr = 0;
-			memcpy(((char *)&mcast_addr)+2, mclist->dmi_addr, 6);
+			memcpy(((char *)&mcast_addr)+2, ha->addr, 6);
 			lpar_rc = h_multicast_ctrl(adapter->vdev->unit_address,
 						   IbmVethMcastAddFilter,
 						   mcast_addr);
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index ea87570..78cc742 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2864,7 +2864,7 @@ static int igb_write_mc_addr_list(struct net_device *netdev)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	struct dev_mc_list *mc_ptr;
+	struct netdev_hw_addr *ha;
 	u8  *mta_list;
 	int i;
 
@@ -2881,8 +2881,8 @@ static int igb_write_mc_addr_list(struct net_device *netdev)
 
 	/* The shared function expects a packed array of only addresses. */
 	i = 0;
-	netdev_for_each_mc_addr(mc_ptr, netdev)
-		memcpy(mta_list + (i++ * ETH_ALEN), mc_ptr->dmi_addr, ETH_ALEN);
+	netdev_for_each_mc_addr(ha, netdev)
+		memcpy(mta_list + (i++ * ETH_ALEN), ha->addr, ETH_ALEN);
 
 	igb_update_mc_addr_list(hw, mta_list, i);
 	kfree(mta_list);
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index a77afd8..ea8abf5 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -1399,7 +1399,7 @@ static void igbvf_set_multi(struct net_device *netdev)
 {
 	struct igbvf_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	struct dev_mc_list *mc_ptr;
+	struct netdev_hw_addr *ha;
 	u8  *mta_list = NULL;
 	int i;
 
@@ -1414,8 +1414,8 @@ static void igbvf_set_multi(struct net_device *netdev)
 
 	/* prepare a packed array of only addresses. */
 	i = 0;
-	netdev_for_each_mc_addr(mc_ptr, netdev)
-		memcpy(mta_list + (i++ * ETH_ALEN), mc_ptr->dmi_addr, ETH_ALEN);
+	netdev_for_each_mc_addr(ha, netdev)
+		memcpy(mta_list + (i++ * ETH_ALEN), ha->addr, ETH_ALEN);
 
 	hw->mac.ops.update_mc_addr_list(hw, mta_list, i, 0, 0);
 	kfree(mta_list);
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index 70871b9..57d873d 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -1664,7 +1664,7 @@ static int ioc3_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 static void ioc3_set_multicast_list(struct net_device *dev)
 {
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	struct ioc3_private *ip = netdev_priv(dev);
 	struct ioc3 *ioc3 = ip->regs;
 	u64 ehar = 0;
@@ -1688,8 +1688,8 @@ static void ioc3_set_multicast_list(struct net_device *dev)
 			ip->ehar_h = 0xffffffff;
 			ip->ehar_l = 0xffffffff;
 		} else {
-			netdev_for_each_mc_addr(dmi, dev) {
-				char *addr = dmi->dmi_addr;
+			netdev_for_each_mc_addr(ha, dev) {
+				char *addr = ha->addr;
 
 				if (!(*addr & 1))
 					continue;
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index 0d7ad3f..67cfc7d 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -569,7 +569,7 @@ static int ipg_config_autoneg(struct net_device *dev)
 static void ipg_nic_set_multicast_list(struct net_device *dev)
 {
 	void __iomem *ioaddr = ipg_ioaddr(dev);
-	struct dev_mc_list *mc_list_ptr;
+	struct netdev_hw_addr *ha;
 	unsigned int hashindex;
 	u32 hashtable[2];
 	u8 receivemode;
@@ -608,9 +608,9 @@ static void ipg_nic_set_multicast_list(struct net_device *dev)
 	hashtable[1] = 0x00000000;
 
 	/* Cycle through all multicast addresses to filter. */
-	netdev_for_each_mc_addr(mc_list_ptr, dev) {
+	netdev_for_each_mc_addr(ha, dev) {
 		/* Calculate CRC result for each multicast address. */
-		hashindex = crc32_le(0xffffffff, mc_list_ptr->dmi_addr,
+		hashindex = crc32_le(0xffffffff, ha->addr,
 				     ETH_ALEN);
 
 		/* Use only the least significant 6 bits. */
diff --git a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
index e6e972d..cd65b86 100644
--- a/drivers/net/iseries_veth.c
+++ b/drivers/net/iseries_veth.c
@@ -961,15 +961,15 @@ static void veth_set_multicast_list(struct net_device *dev)
 			(netdev_mc_count(dev) > VETH_MAX_MCAST)) {
 		port->promiscuous = 1;
 	} else {
-		struct dev_mc_list *dmi;
+		struct netdev_hw_addr *ha;
 
 		port->promiscuous = 0;
 
 		/* Update table */
 		port->num_mcast = 0;
 
-		netdev_for_each_mc_addr(dmi, dev) {
-			u8 *addr = dmi->dmi_addr;
+		netdev_for_each_mc_addr(ha, dev) {
+			u8 *addr = ha->addr;
 			u64 xaddr = 0;
 
 			if (addr[0] & 0x01) {/* multicast address? */
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index c9fef65..912dd1d 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1058,7 +1058,7 @@ ixgb_set_multi(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_hw *hw = &adapter->hw;
-	struct dev_mc_list *mc_ptr;
+	struct netdev_hw_addr *ha;
 	u32 rctl;
 	int i;
 
@@ -1089,9 +1089,9 @@ ixgb_set_multi(struct net_device *netdev)
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 
 		i = 0;
-		netdev_for_each_mc_addr(mc_ptr, netdev)
+		netdev_for_each_mc_addr(ha, netdev)
 			memcpy(&mta[i++ * IXGB_ETH_LENGTH_OF_ADDRESS],
-			       mc_ptr->dmi_addr, IXGB_ETH_LENGTH_OF_ADDRESS);
+			       ha->addr, IXGB_ETH_LENGTH_OF_ADDRESS);
 
 		ixgb_mc_addr_list_update(hw, mta, netdev_mc_count(netdev), 0);
 	}
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 4d1c3a4..6eb5814 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1494,7 +1494,7 @@ static void ixgbe_set_mta(struct ixgbe_hw *hw, u8 *mc_addr)
 s32 ixgbe_update_mc_addr_list_generic(struct ixgbe_hw *hw,
 				      struct net_device *netdev)
 {
-	struct dev_addr_list *dmi;
+	struct netdev_hw_addr *ha;
 	u32 i;
 
 	/*
@@ -1510,9 +1510,9 @@ s32 ixgbe_update_mc_addr_list_generic(struct ixgbe_hw *hw,
 		IXGBE_WRITE_REG(hw, IXGBE_MTA(i), 0);
 
 	/* Add the new addresses */
-	netdev_for_each_mc_addr(dmi, netdev) {
+	netdev_for_each_mc_addr(ha, netdev) {
 		hw_dbg(hw, " Adding the multicast addresses:\n");
-		ixgbe_set_mta(hw, dmi->dmi_addr);
+		ixgbe_set_mta(hw, ha->addr);
 	}
 
 	/* Enable mta */
diff --git a/drivers/net/ixgbevf/vf.c b/drivers/net/ixgbevf/vf.c
index f457c52..852e9c4 100644
--- a/drivers/net/ixgbevf/vf.c
+++ b/drivers/net/ixgbevf/vf.c
@@ -259,7 +259,7 @@ static s32 ixgbevf_set_rar_vf(struct ixgbe_hw *hw, u32 index, u8 *addr,
 static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw,
 					  struct net_device *netdev)
 {
-	struct dev_addr_list *dmi;
+	struct netdev_hw_addr *ha;
 	struct ixgbe_mbx_info *mbx = &hw->mbx;
 	u32 msgbuf[IXGBE_VFMAILBOX_SIZE];
 	u16 *vector_list = (u16 *)&msgbuf[1];
@@ -281,10 +281,10 @@ static s32 ixgbevf_update_mc_addr_list_vf(struct ixgbe_hw *hw,
 	msgbuf[0] |= cnt << IXGBE_VT_MSGINFO_SHIFT;
 
 	i = 0;
-	netdev_for_each_mc_addr(dmi, netdev) {
+	netdev_for_each_mc_addr(ha, netdev) {
 		if (i == cnt)
 			break;
-		vector_list[i++] = ixgbevf_mta_vector(hw, dmi->dmi_addr);
+		vector_list[i++] = ixgbevf_mta_vector(hw, ha->addr);
 	}
 
 	mbx->ops.write_posted(hw, msgbuf, IXGBE_VFMAILBOX_SIZE);
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index c0b59a5..10e816d 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -2009,12 +2009,12 @@ jme_set_multi(struct net_device *netdev)
 	} else if (netdev->flags & IFF_ALLMULTI) {
 		jme->reg_rxmcs |= RXMCS_ALLMULFRAME;
 	} else if (netdev->flags & IFF_MULTICAST) {
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 		int bit_nr;
 
 		jme->reg_rxmcs |= RXMCS_MULFRAME | RXMCS_MULFILTERED;
-		netdev_for_each_mc_addr(mclist, netdev) {
-			bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) & 0x3F;
+		netdev_for_each_mc_addr(ha, netdev) {
+			bit_nr = ether_crc(ETH_ALEN, ha->addr) & 0x3F;
 			mc_hash[bit_nr >> 5] |= 1 << (bit_nr & 0x1F);
 		}
 
diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index edaedc7..26bf1b7 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -482,7 +482,7 @@ static void korina_multicast_list(struct net_device *dev)
 {
 	struct korina_private *lp = netdev_priv(dev);
 	unsigned long flags;
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	u32 recognise = ETH_ARC_AB;	/* always accept broadcasts */
 	int i;
 
@@ -502,8 +502,8 @@ static void korina_multicast_list(struct net_device *dev)
 		for (i = 0; i < 4; i++)
 			hash_table[i] = 0;
 
-		netdev_for_each_mc_addr(dmi, dev) {
-			char *addrs = dmi->dmi_addr;
+		netdev_for_each_mc_addr(ha, dev) {
+			char *addrs = ha->addr;
 
 			if (!(*addrs & 1))
 				continue;
diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
index 66be4e4..4dcd61f 100644
--- a/drivers/net/ks8851.c
+++ b/drivers/net/ks8851.c
@@ -956,13 +956,13 @@ static void ks8851_set_rx_mode(struct net_device *dev)
 		rxctrl.rxcr1 = (RXCR1_RXME | RXCR1_RXAE |
 				RXCR1_RXPAFMA | RXCR1_RXMAFMA);
 	} else if (dev->flags & IFF_MULTICAST && !netdev_mc_empty(dev)) {
-		struct dev_mc_list *mcptr;
+		struct netdev_hw_addr *ha;
 		u32 crc;
 
 		/* accept some multicast */
 
-		netdev_for_each_mc_addr(mcptr, dev) {
-			crc = ether_crc(ETH_ALEN, mcptr->dmi_addr);
+		netdev_for_each_mc_addr(ha, dev) {
+			crc = ether_crc(ETH_ALEN, ha->addr);
 			crc >>= (32 - 6);  /* get top six bits */
 
 			rxctrl.mchash[crc >> 4] |= (1 << (crc & 0xf));
diff --git a/drivers/net/ks8851_mll.c b/drivers/net/ks8851_mll.c
index ee3fe30..70a3d98 100644
--- a/drivers/net/ks8851_mll.c
+++ b/drivers/net/ks8851_mll.c
@@ -362,7 +362,6 @@ static u8 KS_DEFAULT_MAC_ADDRESS[] = { 0x00, 0x10, 0xA1, 0x86, 0x95, 0x11 };
 
 #define MAX_MCAST_LST			32
 #define HW_MCAST_SIZE			8
-#define MAC_ADDR_LEN			6
 
 /**
  * union ks_tx_hdr - tx header data
@@ -450,7 +449,7 @@ struct ks_net {
 	u16			promiscuous;
 	u16			all_mcast;
 	u16			mcast_lst_size;
-	u8			mcast_lst[MAX_MCAST_LST][MAC_ADDR_LEN];
+	u8			mcast_lst[MAX_MCAST_LST][ETH_ALEN];
 	u8			mcast_bits[HW_MCAST_SIZE];
 	u8			mac_addr[6];
 	u8                      fid;
@@ -1170,7 +1169,7 @@ static void ks_set_mcast(struct ks_net *ks, u16 mcast)
 static void ks_set_rx_mode(struct net_device *netdev)
 {
 	struct ks_net *ks = netdev_priv(netdev);
-	struct dev_mc_list *ptr;
+	struct netdev_hw_addr *ha;
 
 	/* Turn on/off promiscuous mode. */
 	if ((netdev->flags & IFF_PROMISC) == IFF_PROMISC)
@@ -1187,13 +1186,12 @@ static void ks_set_rx_mode(struct net_device *netdev)
 		if (netdev_mc_count(netdev) <= MAX_MCAST_LST) {
 			int i = 0;
 
-			netdev_for_each_mc_addr(ptr, netdev) {
-				if (!(*ptr->dmi_addr & 1))
+			netdev_for_each_mc_addr(ha, netdev) {
+				if (!(*ha->addr & 1))
 					continue;
 				if (i >= MAX_MCAST_LST)
 					break;
-				memcpy(ks->mcast_lst[i++], ptr->dmi_addr,
-				MAC_ADDR_LEN);
+				memcpy(ks->mcast_lst[i++], ha->addr, ETH_ALEN);
 			}
 			ks->mcast_lst_size = (u8)i;
 			ks_set_grpaddr(ks);
diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index b843bf7..3487695 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -5763,7 +5763,7 @@ static void netdev_set_rx_mode(struct net_device *dev)
 	struct dev_priv *priv = netdev_priv(dev);
 	struct dev_info *hw_priv = priv->adapter;
 	struct ksz_hw *hw = &hw_priv->hw;
-	struct dev_mc_list *mc_ptr;
+	struct netdev_hw_addr *ha;
 	int multicast = (dev->flags & IFF_ALLMULTI);
 
 	dev_set_promiscuous(dev, priv, hw, (dev->flags & IFF_PROMISC));
@@ -5780,7 +5780,7 @@ static void netdev_set_rx_mode(struct net_device *dev)
 		int i = 0;
 
 		/* List too big to support so turn on all multicast mode. */
-		if (dev->mc_count > MAX_MULTICAST_LIST) {
+		if (netdev_mc_count(dev) > MAX_MULTICAST_LIST) {
 			if (MAX_MULTICAST_LIST != hw->multi_list_size) {
 				hw->multi_list_size = MAX_MULTICAST_LIST;
 				++hw->all_multi;
@@ -5789,13 +5789,12 @@ static void netdev_set_rx_mode(struct net_device *dev)
 			return;
 		}
 
-		netdev_for_each_mc_addr(mc_ptr, dev) {
-			if (!(*mc_ptr->dmi_addr & 1))
+		netdev_for_each_mc_addr(ha, dev) {
+			if (!(*ha->addr & 1))
 				continue;
 			if (i >= MAX_MULTICAST_LIST)
 				break;
-			memcpy(hw->multi_list[i++], mc_ptr->dmi_addr,
-				MAC_ADDR_LEN);
+			memcpy(hw->multi_list[i++], ha->addr, MAC_ADDR_LEN);
 		}
 		hw->multi_list_size = (u8) i;
 		hw_set_grp_addr(hw);
diff --git a/drivers/net/lib82596.c b/drivers/net/lib82596.c
index 443c39a..fddaf92 100644
--- a/drivers/net/lib82596.c
+++ b/drivers/net/lib82596.c
@@ -1388,7 +1388,7 @@ static void set_multicast_list(struct net_device *dev)
 	}
 
 	if (!netdev_mc_empty(dev)) {
-		struct dev_mc_list *dmi;
+		struct netdev_hw_addr *ha;
 		unsigned char *cp;
 		struct mc_cmd *cmd;
 
@@ -1396,10 +1396,10 @@ static void set_multicast_list(struct net_device *dev)
 		cmd->cmd.command = SWAP16(CmdMulticastList);
 		cmd->mc_cnt = SWAP16(netdev_mc_count(dev) * 6);
 		cp = cmd->mc_addrs;
-		netdev_for_each_mc_addr(dmi, dev) {
+		netdev_for_each_mc_addr(ha, dev) {
 			if (!cnt--)
 				break;
-			memcpy(cp, dmi->dmi_addr, 6);
+			memcpy(cp, ha->addr, 6);
 			if (i596_debug > 1)
 				DEB(DEB_MULTI,
 				    printk(KERN_DEBUG
diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index 56f66f4..526dc9c 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -905,10 +905,10 @@ static struct net_device_stats *__ei_get_stats(struct net_device *dev)
 
 static inline void make_mc_bits(u8 *bits, struct net_device *dev)
 {
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 
-	netdev_for_each_mc_addr(dmi, dev) {
-		u32 crc = ether_crc(ETH_ALEN, dmi->dmi_addr);
+	netdev_for_each_mc_addr(ha, dev) {
+		u32 crc = ether_crc(ETH_ALEN, ha->addr);
 		/*
 		 * The 8390 uses the 6 most significant bits of the
 		 * CRC to index the multicast table.
diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index a18e348..30474d6 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -250,20 +250,20 @@ static void temac_set_multicast_list(struct net_device *ndev)
 		temac_indirect_out32(lp, XTE_AFM_OFFSET, XTE_AFM_EPPRM_MASK);
 		dev_info(&ndev->dev, "Promiscuous mode enabled.\n");
 	} else if (!netdev_mc_empty(ndev)) {
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 
 		i = 0;
-		netdev_for_each_mc_addr(mclist, ndev) {
+		netdev_for_each_mc_addr(ha, ndev) {
 			if (i >= MULTICAST_CAM_TABLE_NUM)
 				break;
-			multi_addr_msw = ((mclist->dmi_addr[3] << 24) |
-					  (mclist->dmi_addr[2] << 16) |
-					  (mclist->dmi_addr[1] << 8) |
-					  (mclist->dmi_addr[0]));
+			multi_addr_msw = ((ha->addr[3] << 24) |
+					  (ha->addr[2] << 16) |
+					  (ha->addr[1] << 8) |
+					  (ha->addr[0]));
 			temac_indirect_out32(lp, XTE_MAW0_OFFSET,
 					     multi_addr_msw);
-			multi_addr_lsw = ((mclist->dmi_addr[5] << 8) |
-					  (mclist->dmi_addr[4]) | (i << 16));
+			multi_addr_lsw = ((ha->addr[5] << 8) |
+					  (ha->addr[4]) | (i << 16));
 			temac_indirect_out32(lp, XTE_MAW1_OFFSET,
 					     multi_addr_lsw);
 			i++;
diff --git a/drivers/net/lp486e.c b/drivers/net/lp486e.c
index 3e3cc04..72379c5 100644
--- a/drivers/net/lp486e.c
+++ b/drivers/net/lp486e.c
@@ -1256,7 +1256,7 @@ static void set_multicast_list(struct net_device *dev) {
 			dev->name, netdev_mc_count(dev));
 
 	if (!netdev_mc_empty(dev)) {
-		struct dev_mc_list *dmi;
+		struct netdev_hw_addr *ha;
 		char *cp;
 		cmd = kmalloc(sizeof(struct i596_cmd) + 2 +
 			      netdev_mc_count(dev) * 6, GFP_ATOMIC);
@@ -1267,8 +1267,8 @@ static void set_multicast_list(struct net_device *dev) {
 		cmd->command = CmdMulticastList;
 		*((unsigned short *) (cmd + 1)) = netdev_mc_count(dev) * 6;
 		cp = ((char *)(cmd + 1))+2;
-		netdev_for_each_mc_addr(dmi, dev) {
-			memcpy(cp, dmi->dmi_addr, 6);
+		netdev_for_each_mc_addr(ha, dev) {
+			memcpy(cp, ha->addr, 6);
 			cp += 6;
 		}
 		if (i596_debug & LOG_SRCDST)
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index c8a18a6..eab1219 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -882,15 +882,15 @@ static int hash_get_index(__u8 *addr)
  */
 static void macb_sethashtable(struct net_device *dev)
 {
-	struct dev_mc_list *curr;
+	struct netdev_hw_addr *ha;
 	unsigned long mc_filter[2];
 	unsigned int bitnr;
 	struct macb *bp = netdev_priv(dev);
 
 	mc_filter[0] = mc_filter[1] = 0;
 
-	netdev_for_each_mc_addr(curr, dev) {
-		bitnr = hash_get_index(curr->dmi_addr);
+	netdev_for_each_mc_addr(ha, dev) {
+		bitnr = hash_get_index(ha->addr);
 		mc_filter[bitnr >> 5] |= 1 << (bitnr & 31);
 	}
 
diff --git a/drivers/net/mace.c b/drivers/net/mace.c
index ab5f0bf..2328a73 100644
--- a/drivers/net/mace.c
+++ b/drivers/net/mace.c
@@ -598,7 +598,7 @@ static void mace_set_multicast(struct net_device *dev)
 	mp->maccc |= PROM;
     } else {
 	unsigned char multicast_filter[8];
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 
 	if (dev->flags & IFF_ALLMULTI) {
 	    for (i = 0; i < 8; i++)
@@ -606,8 +606,8 @@ static void mace_set_multicast(struct net_device *dev)
 	} else {
 	    for (i = 0; i < 8; i++)
 		multicast_filter[i] = 0;
-	    netdev_for_each_mc_addr(dmi, dev) {
-	        crc = ether_crc_le(6, dmi->dmi_addr);
+	    netdev_for_each_mc_addr(ha, dev) {
+	        crc = ether_crc_le(6, ha->addr);
 		i = crc >> 26;	/* bit number in multicast_filter */
 		multicast_filter[i >> 3] |= 1 << (i & 7);
 	    }
diff --git a/drivers/net/macmace.c b/drivers/net/macmace.c
index 13ba8f4..8a50c67 100644
--- a/drivers/net/macmace.c
+++ b/drivers/net/macmace.c
@@ -508,7 +508,7 @@ static void mace_set_multicast(struct net_device *dev)
 		mb->maccc |= PROM;
 	} else {
 		unsigned char multicast_filter[8];
-		struct dev_mc_list *dmi;
+		struct netdev_hw_addr *ha;
 
 		if (dev->flags & IFF_ALLMULTI) {
 			for (i = 0; i < 8; i++) {
@@ -517,8 +517,8 @@ static void mace_set_multicast(struct net_device *dev)
 		} else {
 			for (i = 0; i < 8; i++)
 				multicast_filter[i] = 0;
-			netdev_for_each_mc_addr(dmi, dev) {
-				crc = ether_crc_le(6, dmi->dmi_addr);
+			netdev_for_each_mc_addr(ha, dev) {
+				crc = ether_crc_le(6, ha->addr);
 				/* bit number in multicast_filter */
 				i = crc >> 26;
 				multicast_filter[i >> 3] |= 1 << (i & 7);
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 5eb96fe..4554642 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -168,7 +168,7 @@ static void mlx4_en_clear_list(struct net_device *dev)
 static void mlx4_en_cache_mclist(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	struct dev_mc_list *mclist;
+	struct netdev_hw_addr *ha;
 	char *mc_addrs;
 	int mc_addrs_cnt = netdev_mc_count(dev);
 	int i;
@@ -179,8 +179,8 @@ static void mlx4_en_cache_mclist(struct net_device *dev)
 		return;
 	}
 	i = 0;
-	netdev_for_each_mc_addr(mclist, dev)
-		memcpy(mc_addrs + i++ * ETH_ALEN, mclist->dmi_addr, ETH_ALEN);
+	netdev_for_each_mc_addr(ha, dev)
+		memcpy(mc_addrs + i++ * ETH_ALEN, ha->addr, ETH_ALEN);
 	priv->mc_addrs = mc_addrs;
 	priv->mc_addrs_cnt = mc_addrs_cnt;
 }
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index c97b6e4..d5ebe43 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1769,7 +1769,7 @@ static void mv643xx_eth_program_multicast_filter(struct net_device *dev)
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	u32 *mc_spec;
 	u32 *mc_other;
-	struct dev_addr_list *addr;
+	struct netdev_hw_addr *ha;
 	int i;
 
 	if (dev->flags & (IFF_PROMISC | IFF_ALLMULTI)) {
@@ -1794,8 +1794,8 @@ oom:
 	memset(mc_spec, 0, 0x100);
 	memset(mc_other, 0, 0x100);
 
-	netdev_for_each_mc_addr(addr, dev) {
-		u8 *a = addr->da_addr;
+	netdev_for_each_mc_addr(ha, dev) {
+		u8 *a = ha->addr;
 		u32 *table;
 		int entry;
 
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index e84dd3e..6d33adf 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -3001,7 +3001,7 @@ static void myri10ge_set_multicast_list(struct net_device *dev)
 {
 	struct myri10ge_priv *mgp = netdev_priv(dev);
 	struct myri10ge_cmd cmd;
-	struct dev_mc_list *mc_list;
+	struct netdev_hw_addr *ha;
 	__be32 data[2] = { 0, 0 };
 	int err;
 
@@ -3038,8 +3038,8 @@ static void myri10ge_set_multicast_list(struct net_device *dev)
 	}
 
 	/* Walk the multicast list, and add each address */
-	netdev_for_each_mc_addr(mc_list, dev) {
-		memcpy(data, &mc_list->dmi_addr, 6);
+	netdev_for_each_mc_addr(ha, dev) {
+		memcpy(data, &ha->addr, 6);
 		cmd.data0 = ntohl(data[0]);
 		cmd.data1 = ntohl(data[1]);
 		err = myri10ge_send_cmd(mgp, MXGEFW_JOIN_MULTICAST_GROUP,
@@ -3047,7 +3047,7 @@ static void myri10ge_set_multicast_list(struct net_device *dev)
 
 		if (err != 0) {
 			netdev_err(dev, "Failed MXGEFW_JOIN_MULTICAST_GROUP, error status:%d %pM\n",
-				   err, mc_list->dmi_addr);
+				   err, ha->addr);
 			goto abort;
 		}
 	}
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index e520387..9250bf6 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -2493,12 +2493,12 @@ static void __set_rx_mode(struct net_device *dev)
 		rx_mode = RxFilterEnable | AcceptBroadcast
 			| AcceptAllMulticast | AcceptMyPhys;
 	} else {
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 		int i;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		netdev_for_each_mc_addr(mclist, dev) {
-			int b = (ether_crc(ETH_ALEN, mclist->dmi_addr) >> 23) & 0x1ff;
+		netdev_for_each_mc_addr(ha, dev) {
+			int b = (ether_crc(ETH_ALEN, ha->addr) >> 23) & 0x1ff;
 			mc_filter[b/8] |= (1 << (b & 0x07));
 		}
 		rx_mode = RxFilterEnable | AcceptBroadcast
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index a945591..781ca89 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -537,7 +537,7 @@ netxen_nic_set_mcast_addr(struct netxen_adapter *adapter,
 void netxen_p2_nic_set_multi(struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
-	struct dev_mc_list *mc_ptr;
+	struct netdev_hw_addr *ha;
 	u8 null_addr[6];
 	int i;
 
@@ -571,8 +571,8 @@ void netxen_p2_nic_set_multi(struct net_device *netdev)
 	netxen_nic_enable_mcast_filter(adapter);
 
 	i = 0;
-	netdev_for_each_mc_addr(mc_ptr, netdev)
-		netxen_nic_set_mcast_addr(adapter, i++, mc_ptr->dmi_addr);
+	netdev_for_each_mc_addr(ha, netdev)
+		netxen_nic_set_mcast_addr(adapter, i++, ha->addr);
 
 	/* Clear out remaining addresses */
 	while (i < adapter->max_mc_count)
@@ -680,7 +680,7 @@ static int nx_p3_nic_add_mac(struct netxen_adapter *adapter,
 void netxen_p3_nic_set_multi(struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
-	struct dev_mc_list *mc_ptr;
+	struct netdev_hw_addr *ha;
 	u8 bcast_addr[ETH_ALEN] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
 	u32 mode = VPORT_MISS_MODE_DROP;
 	LIST_HEAD(del_list);
@@ -707,8 +707,8 @@ void netxen_p3_nic_set_multi(struct net_device *netdev)
 	}
 
 	if (!netdev_mc_empty(netdev)) {
-		netdev_for_each_mc_addr(mc_ptr, netdev)
-			nx_p3_nic_add_mac(adapter, mc_ptr->dmi_addr, &del_list);
+		netdev_for_each_mc_addr(ha, netdev)
+			nx_p3_nic_add_mac(adapter, ha->addr, &del_list);
 	}
 
 send_fw_cmd:
diff --git a/drivers/net/ni52.c b/drivers/net/ni52.c
index 05c29c2..a76fabe 100644
--- a/drivers/net/ni52.c
+++ b/drivers/net/ni52.c
@@ -596,7 +596,7 @@ static int init586(struct net_device *dev)
 	struct iasetup_cmd_struct __iomem *ias_cmd;
 	struct tdr_cmd_struct __iomem *tdr_cmd;
 	struct mcsetup_cmd_struct __iomem *mc_cmd;
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	int num_addrs = netdev_mc_count(dev);
 
 	ptr = p->scb + 1;
@@ -725,8 +725,8 @@ static int init586(struct net_device *dev)
 		writew(num_addrs * 6, &mc_cmd->mc_cnt);
 
 		i = 0;
-		netdev_for_each_mc_addr(dmi, dev)
-			memcpy_toio(mc_cmd->mc_list[i++], dmi->dmi_addr, 6);
+		netdev_for_each_mc_addr(ha, dev)
+			memcpy_toio(mc_cmd->mc_list[i++], ha->addr, 6);
 
 		writew(make16(mc_cmd), &p->scb->cbl_offset);
 		writeb(CUC_START, &p->scb->cmd_cuc);
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 0678f31..7b52c46 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6313,7 +6313,6 @@ static void niu_set_rx_mode(struct net_device *dev)
 {
 	struct niu *np = netdev_priv(dev);
 	int i, alt_cnt, err;
-	struct dev_addr_list *addr;
 	struct netdev_hw_addr *ha;
 	unsigned long flags;
 	u16 hash[16] = { 0, };
@@ -6365,8 +6364,8 @@ static void niu_set_rx_mode(struct net_device *dev)
 		for (i = 0; i < 16; i++)
 			hash[i] = 0xffff;
 	} else if (!netdev_mc_empty(dev)) {
-		netdev_for_each_mc_addr(addr, dev) {
-			u32 crc = ether_crc_le(ETH_ALEN, addr->da_addr);
+		netdev_for_each_mc_addr(ha, dev) {
+			u32 crc = ether_crc_le(ETH_ALEN, ha->addr);
 
 			crc >>= 24;
 			hash[crc >> 4] |= (1 << (15 - (crc & 0xf)));
diff --git a/drivers/net/octeon/octeon_mgmt.c b/drivers/net/octeon/octeon_mgmt.c
index be368e5..ee894ed 100644
--- a/drivers/net/octeon/octeon_mgmt.c
+++ b/drivers/net/octeon/octeon_mgmt.c
@@ -474,7 +474,7 @@ static void octeon_mgmt_set_rx_filtering(struct net_device *netdev)
 	unsigned int cam_mode = 1; /* 1 - Accept on CAM match */
 	unsigned int multicast_mode = 1; /* 1 - Reject all multicast.  */
 	struct octeon_mgmt_cam_state cam_state;
-	struct dev_addr_list *list;
+	struct netdev_hw_addr *ha;
 	struct list_head *pos;
 	int available_cam_entries;
 
@@ -510,8 +510,8 @@ static void octeon_mgmt_set_rx_filtering(struct net_device *netdev)
 		}
 	}
 	if (multicast_mode == 0) {
-		netdev_for_each_mc_addr(list, netdev)
-			octeon_mgmt_cam_state_add(&cam_state, list->da_addr);
+		netdev_for_each_mc_addr(ha, netdev)
+			octeon_mgmt_cam_state_add(&cam_state, ha->addr);
 	}
 
 
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index 3678585..dc3b4c7 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -1813,12 +1813,12 @@ static void netdrv_set_rx_mode(struct net_device *dev)
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
 	} else {
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0;
-		netdev_for_each_mc_addr(mclist, dev) {
-			int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
+		netdev_for_each_mc_addr(ha, dev) {
+			int bit_nr = ether_crc(ETH_ALEN, ha->addr) >> 26;
 
 			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
 		}
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 09291e6..333cb33 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -1623,11 +1623,11 @@ static struct net_device_stats *get_stats(struct net_device *dev)
  
 static inline void make_mc_bits(u8 *bits, struct net_device *dev)
 {
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	u32 crc;
 
-	netdev_for_each_mc_addr(dmi, dev) {
-		crc = ether_crc(ETH_ALEN, dmi->dmi_addr);
+	netdev_for_each_mc_addr(ha, dev) {
+		crc = ether_crc(ETH_ALEN, ha->addr);
 		/* 
 		 * The 8390 uses the 6 most significant bits of the
 		 * CRC to index the multicast table.
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index b9dc80b..6734f7d 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -1196,11 +1196,11 @@ static void set_rx_mode(struct net_device *dev)
 	memset(mc_filter, 0x00, sizeof(mc_filter));
 	outb(1, ioaddr + RX_MODE);	/* Ignore almost all multicasts. */
     } else {
-	struct dev_mc_list *mclist;
+	struct netdev_hw_addr *ha;
 
 	memset(mc_filter, 0, sizeof(mc_filter));
-	netdev_for_each_mc_addr(mclist, dev) {
-	    unsigned int bit = ether_crc_le(ETH_ALEN, mclist->dmi_addr) >> 26;
+	netdev_for_each_mc_addr(ha, dev) {
+	    unsigned int bit = ether_crc_le(ETH_ALEN, ha->addr) >> 26;
 	    mc_filter[bit >> 3] |= (1 << (bit & 7));
 	}
 	outb(2, ioaddr + RX_MODE);	/* Use normal mode. */
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index c717b14..c516c19 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -1475,7 +1475,7 @@ static void set_multicast_list(struct net_device *dev)
 {
   mace_private *lp = netdev_priv(dev);
   int adr[ETHER_ADDR_LEN] = {0}; /* Ethernet address */
-  struct dev_mc_list *dmi;
+  struct netdev_hw_addr *ha;
 
 #ifdef PCMCIA_DEBUG
   {
@@ -1495,8 +1495,8 @@ static void set_multicast_list(struct net_device *dev)
   if (num_addrs > 0) {
     /* Calculate multicast logical address filter */
     memset(lp->multicast_ladrf, 0, MACE_LADRF_LEN);
-    netdev_for_each_mc_addr(dmi, dev) {
-      memcpy(adr, dmi->dmi_addr, ETHER_ADDR_LEN);
+    netdev_for_each_mc_addr(ha, dev) {
+      memcpy(adr, ha->addr, ETHER_ADDR_LEN);
       BuildLAF(lp->multicast_ladrf, adr);
     }
   }
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 5adc662..f45c626 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -1616,12 +1616,12 @@ static void set_rx_mode(struct net_device *dev)
 	rx_cfg_setting = RxStripCRC | RxEnable | RxAllMulti;
     else {
 	if (!netdev_mc_empty(dev)) {
-	    struct dev_mc_list *mc_addr;
+	    struct netdev_hw_addr *ha;
 
-	    netdev_for_each_mc_addr(mc_addr, dev) {
-		u_int position = ether_crc(6, mc_addr->dmi_addr);
+	    netdev_for_each_mc_addr(ha, dev) {
+		u_int position = ether_crc(6, ha->addr);
 #ifndef final_version		/* Verify multicast address. */
-		if ((mc_addr->dmi_addr[0] & 1) == 0)
+		if ((ha->addr[0] & 1) == 0)
 		    continue;
 #endif
 		multicast_table[position >> 29] |= 1 << ((position >> 26) & 7);
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 4d1802e..656be93 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -1398,7 +1398,7 @@ static void set_addresses(struct net_device *dev)
 {
 	unsigned int ioaddr = dev->base_addr;
 	local_info_t *lp = netdev_priv(dev);
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	struct set_address_info sa_info;
 	int i;
 
@@ -1413,10 +1413,10 @@ static void set_addresses(struct net_device *dev)
 
 	set_address(&sa_info, dev->dev_addr);
 	i = 0;
-	netdev_for_each_mc_addr(dmi, dev) {
+	netdev_for_each_mc_addr(ha, dev) {
 		if (i++ == 9)
 			break;
-		set_address(&sa_info, dmi->dmi_addr);
+		set_address(&sa_info, ha->addr);
 	}
 	while (i++ < 9)
 		set_address(&sa_info, dev->dev_addr);
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 084d78d..a2254f7 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -2590,7 +2590,7 @@ static void pcnet32_load_multicast(struct net_device *dev)
 	struct pcnet32_private *lp = netdev_priv(dev);
 	volatile struct pcnet32_init_block *ib = lp->init_block;
 	volatile __le16 *mcast_table = (__le16 *)ib->filter;
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	unsigned long ioaddr = dev->base_addr;
 	char *addrs;
 	int i;
@@ -2611,8 +2611,8 @@ static void pcnet32_load_multicast(struct net_device *dev)
 	ib->filter[1] = 0;
 
 	/* Add addresses */
-	netdev_for_each_mc_addr(dmi, dev) {
-		addrs = dmi->dmi_addr;
+	netdev_for_each_mc_addr(ha, dev) {
+		addrs = ha->addr;
 
 		/* multicast address? */
 		if (!(*addrs & 1))
diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index a602da6..fed5df9 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -546,7 +546,7 @@ out:
 void gelic_net_set_multi(struct net_device *netdev)
 {
 	struct gelic_card *card = netdev_card(netdev);
-	struct dev_mc_list *mc;
+	struct netdev_hw_addr *ha;
 	unsigned int i;
 	uint8_t *p;
 	u64 addr;
@@ -580,9 +580,9 @@ void gelic_net_set_multi(struct net_device *netdev)
 	}
 
 	/* set multicast addresses */
-	netdev_for_each_mc_addr(mc, netdev) {
+	netdev_for_each_mc_addr(ha, netdev) {
 		addr = 0;
-		p = mc->dmi_addr;
+		p = ha->addr;
 		for (i = 0; i < ETH_ALEN; i++) {
 			addr <<= 8;
 			addr |= *p++;
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index da00e16..f0f6d98 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -426,7 +426,7 @@ static int qlcnic_nic_add_mac(struct qlcnic_adapter *adapter, u8 *addr)
 void qlcnic_set_multi(struct net_device *netdev)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
-	struct dev_mc_list *mc_ptr;
+	struct netdev_hw_addr *ha;
 	u8 bcast_addr[ETH_ALEN] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
 	u32 mode = VPORT_MISS_MODE_DROP;
 
@@ -445,8 +445,8 @@ void qlcnic_set_multi(struct net_device *netdev)
 	}
 
 	if (!netdev_mc_empty(netdev)) {
-		netdev_for_each_mc_addr(mc_ptr, netdev) {
-			qlcnic_nic_add_mac(adapter, mc_ptr->dmi_addr);
+		netdev_for_each_mc_addr(ha, netdev) {
+			qlcnic_nic_add_mac(adapter, ha->addr);
 		}
 	}
 
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index fd34f26..76df968 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -4207,7 +4207,7 @@ static struct net_device_stats *qlge_get_stats(struct net_device
 static void qlge_set_multicast_list(struct net_device *ndev)
 {
 	struct ql_adapter *qdev = (struct ql_adapter *)netdev_priv(ndev);
-	struct dev_mc_list *mc_ptr;
+	struct netdev_hw_addr *ha;
 	int i, status;
 
 	status = ql_sem_spinlock(qdev, SEM_RT_IDX_MASK);
@@ -4271,8 +4271,8 @@ static void qlge_set_multicast_list(struct net_device *ndev)
 		if (status)
 			goto exit;
 		i = 0;
-		netdev_for_each_mc_addr(mc_ptr, ndev) {
-			if (ql_set_mac_addr_reg(qdev, (u8 *) mc_ptr->dmi_addr,
+		netdev_for_each_mc_addr(ha, ndev) {
+			if (ql_set_mac_addr_reg(qdev, (u8 *) ha->addr,
 						MAC_ADDR_TYPE_MULTI_MAC, i)) {
 				netif_err(qdev, hw, qdev->ndev,
 					  "Failed to loadmulticast address.\n");
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 15d5373..f5a0e96 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -938,7 +938,7 @@ static void r6040_multicast_list(struct net_device *dev)
 	u16 *adrp;
 	u16 reg;
 	unsigned long flags;
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	int i;
 
 	/* MAC Address */
@@ -973,8 +973,8 @@ static void r6040_multicast_list(struct net_device *dev)
 		for (i = 0; i < 4; i++)
 			hash_table[i] = 0;
 
-		netdev_for_each_mc_addr(dmi, dev) {
-			char *addrs = dmi->dmi_addr;
+		netdev_for_each_mc_addr(ha, dev) {
+			char *addrs = ha->addr;
 
 			if (!(*addrs & 1))
 				continue;
@@ -994,9 +994,9 @@ static void r6040_multicast_list(struct net_device *dev)
 	}
 	/* Multicast Address 1~4 case */
 	i = 0;
-	netdev_for_each_mc_addr(dmi, dev) {
+	netdev_for_each_mc_addr(ha, dev) {
 		if (i < MCAST_MAX) {
-			adrp = (u16 *) dmi->dmi_addr;
+			adrp = (u16 *) ha->addr;
 			iowrite16(adrp[0], ioaddr + MID_1L + 8 * i);
 			iowrite16(adrp[1], ioaddr + MID_1M + 8 * i);
 			iowrite16(adrp[2], ioaddr + MID_1H + 8 * i);
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index f7ffa5d..64cd250 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4785,12 +4785,12 @@ static void rtl_set_rx_mode(struct net_device *dev)
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
 	} else {
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 
 		rx_mode = AcceptBroadcast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0;
-		netdev_for_each_mc_addr(mclist, dev) {
-			int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
+		netdev_for_each_mc_addr(ha, dev) {
+			int bit_nr = ether_crc(ETH_ALEN, ha->addr) >> 26;
 			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
 			rx_mode |= AcceptMulticast;
 		}
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 2eb7f8a..ad5a6a8 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -4964,7 +4964,7 @@ static struct net_device_stats *s2io_get_stats(struct net_device *dev)
 static void s2io_set_multicast(struct net_device *dev)
 {
 	int i, j, prev_cnt;
-	struct dev_mc_list *mclist;
+	struct netdev_hw_addr *ha;
 	struct s2io_nic *sp = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 	u64 val64 = 0, multi_mac = 0x010203040506ULL, mask =
@@ -5093,12 +5093,12 @@ static void s2io_set_multicast(struct net_device *dev)
 
 		/* Create the new Rx filter list and update the same in H/W. */
 		i = 0;
-		netdev_for_each_mc_addr(mclist, dev) {
-			memcpy(sp->usr_addrs[i].addr, mclist->dmi_addr,
+		netdev_for_each_mc_addr(ha, dev) {
+			memcpy(sp->usr_addrs[i].addr, ha->addr,
 			       ETH_ALEN);
 			mac_addr = 0;
 			for (j = 0; j < ETH_ALEN; j++) {
-				mac_addr |= mclist->dmi_addr[j];
+				mac_addr |= ha->addr[j];
 				mac_addr <<= 8;
 			}
 			mac_addr >>= 8;
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 9944e5d..f7de960 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2112,7 +2112,7 @@ static void sbmac_setmulti(struct sbmac_softc *sc)
 	uint64_t reg;
 	void __iomem *port;
 	int idx;
-	struct dev_mc_list *mclist;
+	struct netdev_hw_addr *ha;
 	struct net_device *dev = sc->sbm_dev;
 
 	/*
@@ -2161,10 +2161,10 @@ static void sbmac_setmulti(struct sbmac_softc *sc)
 	 * XXX if the table overflows */
 
 	idx = 1;		/* skip station address */
-	netdev_for_each_mc_addr(mclist, dev) {
+	netdev_for_each_mc_addr(ha, dev) {
 		if (idx == MAC_ADDR_COUNT)
 			break;
-		reg = sbmac_addr2reg(mclist->dmi_addr);
+		reg = sbmac_addr2reg(ha->addr);
 		port = sc->sbm_base + R_MAC_ADDR_BASE+(idx * sizeof(uint64_t));
 		__raw_writeq(reg, port);
 		idx++;
diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index d87c478..1b32605 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -433,13 +433,13 @@ static void _sc92031_set_mar(struct net_device *dev)
 	    (dev->flags & IFF_ALLMULTI))
 		mar0 = mar1 = 0xffffffff;
 	else if (dev->flags & IFF_MULTICAST) {
-		struct dev_mc_list *mc_list;
+		struct netdev_hw_addr *ha;
 
-		netdev_for_each_mc_addr(mc_list, dev) {
+		netdev_for_each_mc_addr(ha, dev) {
 			u32 crc;
 			unsigned bit = 0;
 
-			crc = ~ether_crc(ETH_ALEN, mc_list->dmi_addr);
+			crc = ~ether_crc(ETH_ALEN, ha->addr);
 			crc >>= 24;
 
 			if (crc & 0x01)	bit |= 0x02;
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 88f2fb1..e07b82b 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1602,7 +1602,7 @@ static int efx_set_mac_address(struct net_device *net_dev, void *data)
 static void efx_set_multicast_list(struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
-	struct dev_mc_list *mc_list;
+	struct netdev_hw_addr *ha;
 	union efx_multicast_hash *mc_hash = &efx->multicast_hash;
 	u32 crc;
 	int bit;
@@ -1614,8 +1614,8 @@ static void efx_set_multicast_list(struct net_device *net_dev)
 		memset(mc_hash, 0xff, sizeof(*mc_hash));
 	} else {
 		memset(mc_hash, 0x00, sizeof(*mc_hash));
-		netdev_for_each_mc_addr(mc_list, net_dev) {
-			crc = ether_crc_le(ETH_ALEN, mc_list->dmi_addr);
+		netdev_for_each_mc_addr(ha, net_dev) {
+			crc = ether_crc_le(ETH_ALEN, ha->addr);
 			bit = crc & (EFX_MCAST_HASH_ENTRIES - 1);
 			set_bit_le(bit, mc_hash->byte);
 		}
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 760d9e8..6a05b93 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -848,13 +848,13 @@ static void sis190_set_rx_mode(struct net_device *dev)
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
 	} else {
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 
 		rx_mode = AcceptBroadcast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0;
-		netdev_for_each_mc_addr(mclist, dev) {
+		netdev_for_each_mc_addr(ha, dev) {
 			int bit_nr =
-				ether_crc(ETH_ALEN, mclist->dmi_addr) & 0x3f;
+				ether_crc(ETH_ALEN, ha->addr) & 0x3f;
 			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
 			rx_mode |= AcceptMulticast;
 		}
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index bc7ff41..6293592 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -2298,12 +2298,14 @@ static void set_rx_mode(struct net_device *net_dev)
 		/* Accept Broadcast packet, destination address matchs our
 		 * MAC address, use Receive Filter to reject unwanted MCAST
 		 * packets */
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 		rx_mode = RFAAB;
 
-		netdev_for_each_mc_addr(mclist, net_dev) {
-			unsigned int bit_nr =
-				sis900_mcast_bitnr(mclist->dmi_addr, sis_priv->chipset_rev);
+		netdev_for_each_mc_addr(ha, net_dev) {
+			unsigned int bit_nr;
+
+			bit_nr = sis900_mcast_bitnr(ha->addr,
+						    sis_priv->chipset_rev);
 			mc_filter[bit_nr >> 4] |= (1 << (bit_nr & 0xf));
 		}
 	}
diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index 1921a54..7e5b9f3 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -852,7 +852,7 @@ static void skfp_ctl_set_multicast_list(struct net_device *dev)
 static void skfp_ctl_set_multicast_list_wo_lock(struct net_device *dev)
 {
 	struct s_smc *smc = netdev_priv(dev);
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 
 	/* Enable promiscuous mode, if necessary */
 	if (dev->flags & IFF_PROMISC) {
@@ -876,13 +876,13 @@ static void skfp_ctl_set_multicast_list_wo_lock(struct net_device *dev)
 				/* use exact filtering */
 
 				// point to first multicast addr
-				netdev_for_each_mc_addr(dmi, dev) {
-					mac_add_multicast(smc, 
-							  (struct fddi_addr *)dmi->dmi_addr, 
-							  1);
+				netdev_for_each_mc_addr(ha, dev) {
+					mac_add_multicast(smc,
+						(struct fddi_addr *)ha->addr,
+						1);
 
 					pr_debug(KERN_INFO "ENABLE MC ADDRESS: %pMF\n",
-						dmi->dmi_addr);
+						ha->addr);
 				}
 
 			} else {	// more MC addresses than HW supports
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index bd8c5e8..de5ef38 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2917,7 +2917,7 @@ static void genesis_set_multicast(struct net_device *dev)
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
-	struct dev_mc_list *list;
+	struct netdev_hw_addr *ha;
 	u32 mode;
 	u8 filter[8];
 
@@ -2937,8 +2937,8 @@ static void genesis_set_multicast(struct net_device *dev)
 		    skge->flow_status == FLOW_STAT_SYMMETRIC)
 			genesis_add_filter(filter, pause_mc_addr);
 
-		netdev_for_each_mc_addr(list, dev)
-			genesis_add_filter(filter, list->dmi_addr);
+		netdev_for_each_mc_addr(ha, dev)
+			genesis_add_filter(filter, ha->addr);
 	}
 
 	xm_write32(hw, port, XM_MODE, mode);
@@ -2956,7 +2956,7 @@ static void yukon_set_multicast(struct net_device *dev)
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
-	struct dev_mc_list *list;
+	struct netdev_hw_addr *ha;
 	int rx_pause = (skge->flow_status == FLOW_STAT_REM_SEND ||
 			skge->flow_status == FLOW_STAT_SYMMETRIC);
 	u16 reg;
@@ -2979,8 +2979,8 @@ static void yukon_set_multicast(struct net_device *dev)
 		if (rx_pause)
 			yukon_add_filter(filter, pause_mc_addr);
 
-		netdev_for_each_mc_addr(list, dev)
-			yukon_add_filter(filter, list->dmi_addr);
+		netdev_for_each_mc_addr(ha, dev)
+			yukon_add_filter(filter, ha->addr);
 	}
 
 
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index f1c0ec3..5b97edb 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3627,7 +3627,7 @@ static void sky2_set_multicast(struct net_device *dev)
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
-	struct dev_mc_list *list;
+	struct netdev_hw_addr *ha;
 	u16 reg;
 	u8 filter[8];
 	int rx_pause;
@@ -3651,8 +3651,8 @@ static void sky2_set_multicast(struct net_device *dev)
 		if (rx_pause)
 			sky2_add_filter(filter, pause_mc_addr);
 
-		netdev_for_each_mc_addr(list, dev)
-			sky2_add_filter(filter, list->dmi_addr);
+		netdev_for_each_mc_addr(ha, dev)
+			sky2_add_filter(filter, ha->addr);
 	}
 
 	gma_write16(hw, port, GM_MC_ADDR_H1,
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 0f97b5a..6278734 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -1341,7 +1341,7 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 	 * within that register.
 	 */
 	else if (!netdev_mc_empty(dev)) {
-		struct dev_mc_list *cur_addr;
+		struct netdev_hw_addr *ha;
 
 		/* Set the Hash perfec mode */
 		mcr |= MAC_CR_HPFILT_;
@@ -1349,19 +1349,16 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 		/* start with a table of all zeros: reject all */
 		memset(multicast_table, 0, sizeof(multicast_table));
 
-		netdev_for_each_mc_addr(cur_addr, dev) {
+		netdev_for_each_mc_addr(ha, dev) {
 			u32 position;
 
-			/* do we have a pointer here? */
-			if (!cur_addr)
-				break;
 			/* make sure this is a multicast address -
 				shouldn't this be a given if we have it here ? */
-			if (!(*cur_addr->dmi_addr & 1))
-				 continue;
+			if (!(*ha->addr & 1))
+				continue;
 
 			/* upper 6 bits are used as hash index */
-			position = ether_crc(ETH_ALEN, cur_addr->dmi_addr)>>26;
+			position = ether_crc(ETH_ALEN, ha->addr)>>26;
 
 			multicast_table[position>>5] |= 1 << (position&0x1f);
 		}
diff --git a/drivers/net/smc9194.c b/drivers/net/smc9194.c
index ee14877..9e5e9e7 100644
--- a/drivers/net/smc9194.c
+++ b/drivers/net/smc9194.c
@@ -417,7 +417,7 @@ static void smc_shutdown( int ioaddr )
 
 
 /*
- . Function: smc_setmulticast( int ioaddr, int count, dev_mc_list * adds )
+ . Function: smc_setmulticast( int ioaddr, struct net_device *dev )
  . Purpose:
  .    This sets the internal hardware table to filter out unwanted multicast
  .    packets before they take up memory.
@@ -438,26 +438,23 @@ static void smc_setmulticast(int ioaddr, struct net_device *dev)
 {
 	int			i;
 	unsigned char		multicast_table[ 8 ];
-	struct dev_mc_list *cur_addr;
+	struct netdev_hw_addr *ha;
 	/* table for flipping the order of 3 bits */
 	unsigned char invert3[] = { 0, 4, 2, 6, 1, 5, 3, 7 };
 
 	/* start with a table of all zeros: reject all */
 	memset( multicast_table, 0, sizeof( multicast_table ) );
 
-	netdev_for_each_mc_addr(cur_addr, dev) {
+	netdev_for_each_mc_addr(ha, dev) {
 		int position;
 
-		/* do we have a pointer here? */
-		if ( !cur_addr )
-			break;
 		/* make sure this is a multicast address - shouldn't this
 		   be a given if we have it here ? */
-		if ( !( *cur_addr->dmi_addr & 1 ) )
+		if (!(*ha->addr & 1))
 			continue;
 
 		/* only use the low order bits */
-		position = ether_crc_le(6, cur_addr->dmi_addr) & 0x3f;
+		position = ether_crc_le(6, ha->addr) & 0x3f;
 
 		/* do some messy swapping to put the bit in the right spot */
 		multicast_table[invert3[position&7]] |=
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 2e81338..20c7565 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -1413,7 +1413,7 @@ static void smc_set_multicast_list(struct net_device *dev)
 	 * within that register.
 	 */
 	else if (!netdev_mc_empty(dev)) {
-		struct dev_mc_list *cur_addr;
+		struct netdev_hw_addr *ha;
 
 		/* table for flipping the order of 3 bits */
 		static const unsigned char invert3[] = {0, 4, 2, 6, 1, 5, 3, 7};
@@ -1421,16 +1421,16 @@ static void smc_set_multicast_list(struct net_device *dev)
 		/* start with a table of all zeros: reject all */
 		memset(multicast_table, 0, sizeof(multicast_table));
 
-		netdev_for_each_mc_addr(cur_addr, dev) {
+		netdev_for_each_mc_addr(ha, dev) {
 			int position;
 
 			/* make sure this is a multicast address -
 		   	   shouldn't this be a given if we have it here ? */
-			if (!(*cur_addr->dmi_addr & 1))
+			if (!(*ha->addr & 1))
 				continue;
 
 			/* only use the low order bits */
-			position = crc32_le(~0, cur_addr->dmi_addr, 6) & 0x3f;
+			position = crc32_le(~0, ha->addr, 6) & 0x3f;
 
 			/* do some messy swapping to put the bit in the right spot */
 			multicast_table[invert3[position&7]] |=
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 4fd1d8b..d6e3a12 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1383,13 +1383,13 @@ static void smsc911x_set_multicast_list(struct net_device *dev)
 		/* Enabling specific multicast addresses */
 		unsigned int hash_high = 0;
 		unsigned int hash_low = 0;
-		struct dev_mc_list *mc_list;
+		struct netdev_hw_addr *ha;
 
 		pdata->set_bits_mask = MAC_CR_HPFILT_;
 		pdata->clear_bits_mask = (MAC_CR_PRMS_ | MAC_CR_MCPAS_);
 
-		netdev_for_each_mc_addr(mc_list, dev) {
-			unsigned int bitnum = smsc911x_hash(mc_list->dmi_addr);
+		netdev_for_each_mc_addr(ha, dev) {
+			unsigned int bitnum = smsc911x_hash(ha->addr);
 			unsigned int mask = 0x01 << (bitnum & 0x1F);
 
 			if (bitnum & 0x20)
diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index 34fa10d..5409ec1 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -1063,12 +1063,12 @@ static void smsc9420_set_multicast_list(struct net_device *dev)
 		mac_cr |= MAC_CR_MCPAS_;
 		mac_cr &= (~MAC_CR_HPFILT_);
 	} else if (!netdev_mc_empty(dev)) {
-		struct dev_mc_list *mc_list;
+		struct netdev_hw_addr *ha;
 		u32 hash_lo = 0, hash_hi = 0;
 
 		smsc_dbg(HW, "Multicast filter enabled");
-		netdev_for_each_mc_addr(mc_list, dev) {
-			u32 bit_num = smsc9420_hash(mc_list->dmi_addr);
+		netdev_for_each_mc_addr(ha, dev) {
+			u32 bit_num = smsc9420_hash(ha->addr);
 			u32 mask = 1 << (bit_num & 0x1F);
 
 			if (bit_num & 0x20)
diff --git a/drivers/net/sonic.c b/drivers/net/sonic.c
index 287c251..e5d6732 100644
--- a/drivers/net/sonic.c
+++ b/drivers/net/sonic.c
@@ -531,7 +531,7 @@ static void sonic_multicast_list(struct net_device *dev)
 {
 	struct sonic_local *lp = netdev_priv(dev);
 	unsigned int rcr;
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	unsigned char *addr;
 	int i;
 
@@ -550,8 +550,8 @@ static void sonic_multicast_list(struct net_device *dev)
 				       netdev_mc_count(dev));
 			sonic_set_cam_enable(dev, 1);  /* always enable our own address */
 			i = 1;
-			netdev_for_each_mc_addr(dmi, dev) {
-				addr = dmi->dmi_addr;
+			netdev_for_each_mc_addr(ha, dev) {
+				addr = ha->addr;
 				sonic_cda_put(dev, i, SONIC_CD_CAP0, addr[1] << 8 | addr[0]);
 				sonic_cda_put(dev, i, SONIC_CD_CAP1, addr[3] << 8 | addr[2]);
 				sonic_cda_put(dev, i, SONIC_CD_CAP2, addr[5] << 8 | addr[4]);
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 5ba9d98..c04c8f9 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -625,7 +625,7 @@ spider_net_get_multicast_hash(struct net_device *netdev, __u8 *addr)
 static void
 spider_net_set_multi(struct net_device *netdev)
 {
-	struct dev_mc_list *mc;
+	struct netdev_hw_addr *ha;
 	u8 hash;
 	int i;
 	u32 reg;
@@ -646,8 +646,8 @@ spider_net_set_multi(struct net_device *netdev)
 	hash = spider_net_get_multicast_hash(netdev, netdev->broadcast); */
 	set_bit(0xfd, bitmask);
 
-	netdev_for_each_mc_addr(mc, netdev) {
-		hash = spider_net_get_multicast_hash(netdev, mc->dmi_addr);
+	netdev_for_each_mc_addr(ha, netdev) {
+		hash = spider_net_get_multicast_hash(netdev, ha->addr);
 		set_bit(hash, bitmask);
 	}
 
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 6dfa698..8a6d27c 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1766,7 +1766,7 @@ static void set_rx_mode(struct net_device *dev)
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->base;
 	u32 rx_mode = MinVLANPrio;
-	struct dev_mc_list *mclist;
+	struct netdev_hw_addr *ha;
 	int i;
 #ifdef VLAN_SUPPORT
 
@@ -1804,8 +1804,8 @@ static void set_rx_mode(struct net_device *dev)
 		/* Use the 16 element perfect filter, skip first two entries. */
 		void __iomem *filter_addr = ioaddr + PerfFilterTable + 2 * 16;
 		__be16 *eaddrs;
-		netdev_for_each_mc_addr(mclist, dev) {
-			eaddrs = (__be16 *)mclist->dmi_addr;
+		netdev_for_each_mc_addr(ha, dev) {
+			eaddrs = (__be16 *) ha->addr;
 			writew(be16_to_cpu(eaddrs[2]), filter_addr); filter_addr += 4;
 			writew(be16_to_cpu(eaddrs[1]), filter_addr); filter_addr += 4;
 			writew(be16_to_cpu(eaddrs[0]), filter_addr); filter_addr += 8;
@@ -1825,10 +1825,10 @@ static void set_rx_mode(struct net_device *dev)
 		__le16 mc_filter[32] __attribute__ ((aligned(sizeof(long))));	/* Multicast hash filter */
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		netdev_for_each_mc_addr(mclist, dev) {
+		netdev_for_each_mc_addr(ha, dev) {
 			/* The chip uses the upper 9 CRC bits
 			   as index into the hash table */
-			int bit_nr = ether_crc_le(ETH_ALEN, mclist->dmi_addr) >> 23;
+			int bit_nr = ether_crc_le(ETH_ALEN, ha->addr) >> 23;
 			__le32 *fptr = (__le32 *) &mc_filter[(bit_nr >> 4) & ~1];
 
 			*fptr |= cpu_to_le32(1 << (bit_nr & 31));
diff --git a/drivers/net/stmmac/dwmac100.c b/drivers/net/stmmac/dwmac100.c
index a183de2..c0a1c9d 100644
--- a/drivers/net/stmmac/dwmac100.c
+++ b/drivers/net/stmmac/dwmac100.c
@@ -316,7 +316,7 @@ static void dwmac100_set_filter(struct net_device *dev)
 			   MAC_CONTROL_HO | MAC_CONTROL_HP);
 	} else {
 		u32 mc_filter[2];
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 
 		/* Perfect filter mode for physical address and Hash
 		   filter for multicast */
@@ -325,11 +325,11 @@ static void dwmac100_set_filter(struct net_device *dev)
 			   MAC_CONTROL_IF | MAC_CONTROL_HO);
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		netdev_for_each_mc_addr(mclist, dev) {
+		netdev_for_each_mc_addr(ha, dev) {
 			/* The upper 6 bits of the calculated CRC are used to
 			 * index the contens of the hash table */
 			int bit_nr =
-			    ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
+			    ether_crc(ETH_ALEN, ha->addr) >> 26;
 			/* The most significant bit determines the register to
 			 * use (H/L) while the other 5 bits determine the bit
 			 * within the register. */
diff --git a/drivers/net/stmmac/dwmac1000_core.c b/drivers/net/stmmac/dwmac1000_core.c
index a6538ae..bf73fda 100644
--- a/drivers/net/stmmac/dwmac1000_core.c
+++ b/drivers/net/stmmac/dwmac1000_core.c
@@ -94,17 +94,17 @@ static void dwmac1000_set_filter(struct net_device *dev)
 		writel(0xffffffff, ioaddr + GMAC_HASH_LOW);
 	} else if (!netdev_mc_empty(dev)) {
 		u32 mc_filter[2];
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 
 		/* Hash filter for multicast */
 		value = GMAC_FRAME_FILTER_HMC;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		netdev_for_each_mc_addr(mclist, dev) {
+		netdev_for_each_mc_addr(ha, dev) {
 			/* The upper 6 bits of the calculated CRC are used to
 			   index the contens of the hash table */
 			int bit_nr =
-			    bitrev32(~crc32_le(~0, mclist->dmi_addr, 6)) >> 26;
+			    bitrev32(~crc32_le(~0, ha->addr, 6)) >> 26;
 			/* The most significant bit determines the register to
 			 * use (H/L) while the other 5 bits determine the bit
 			 * within the register. */
diff --git a/drivers/net/sun3_82586.c b/drivers/net/sun3_82586.c
index 2f6a760..2cfa065 100644
--- a/drivers/net/sun3_82586.c
+++ b/drivers/net/sun3_82586.c
@@ -413,7 +413,7 @@ static int init586(struct net_device *dev)
 	volatile struct iasetup_cmd_struct *ias_cmd;
 	volatile struct tdr_cmd_struct *tdr_cmd;
 	volatile struct mcsetup_cmd_struct *mc_cmd;
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	int num_addrs=netdev_mc_count(dev);
 
 	ptr = (void *) ((char *)p->scb + sizeof(struct scb_struct));
@@ -537,9 +537,9 @@ static int init586(struct net_device *dev)
 		mc_cmd->mc_cnt = swab16(num_addrs * 6);
 
 		i = 0;
-		netdev_for_each_mc_addr(dmi, dev)
+		netdev_for_each_mc_addr(ha, dev)
 			memcpy((char *) mc_cmd->mc_list[i++],
-			       dmi->dmi_addr, ETH_ALEN);
+			       ha->addr, ETH_ALEN);
 
 		p->scb->cbl_offset = make16(mc_cmd);
 		p->scb->cmd_cuc = CUC_START;
diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index a0bd361..4dd159b 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -999,7 +999,7 @@ static void bigmac_set_multicast(struct net_device *dev)
 {
 	struct bigmac *bp = netdev_priv(dev);
 	void __iomem *bregs = bp->bregs;
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	char *addrs;
 	int i;
 	u32 tmp, crc;
@@ -1028,8 +1028,8 @@ static void bigmac_set_multicast(struct net_device *dev)
 		for (i = 0; i < 4; i++)
 			hash_table[i] = 0;
 
-		netdev_for_each_mc_addr(dmi, dev) {
-			addrs = dmi->dmi_addr;
+		netdev_for_each_mc_addr(ha, dev) {
+			addrs = ha->addr;
 
 			if (!(*addrs & 1))
 				continue;
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index a855934..47e8cce 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -1523,13 +1523,13 @@ static void set_rx_mode(struct net_device *dev)
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 	} else if (!netdev_mc_empty(dev)) {
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 		int bit;
 		int index;
 		int crc;
 		memset (mc_filter, 0, sizeof (mc_filter));
-		netdev_for_each_mc_addr(mclist, dev) {
-			crc = ether_crc_le (ETH_ALEN, mclist->dmi_addr);
+		netdev_for_each_mc_addr(ha, dev) {
+			crc = ether_crc_le(ETH_ALEN, ha->addr);
 			for (index=0, bit=0; bit < 6; bit++, crc <<= 1)
 				if (crc & 0x80000000) index |= 1 << bit;
 			mc_filter[index/16] |= (1 << (index % 16));
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 70196bc..58a2754 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -1846,12 +1846,12 @@ static u32 gem_setup_multicast(struct gem *gp)
 	} else {
 		u16 hash_table[16];
 		u32 crc;
-		struct dev_mc_list *dmi;
+		struct netdev_hw_addr *ha;
 		int i;
 
 		memset(hash_table, 0, sizeof(hash_table));
-		netdev_for_each_mc_addr(dmi, gp->dev) {
-			char *addrs = dmi->dmi_addr;
+		netdev_for_each_mc_addr(ha, gp->dev) {
+			char *addrs = ha->addr;
 
 			if (!(*addrs & 1))
 				continue;
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index b17dbb1..20deb14 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -1523,13 +1523,13 @@ static int happy_meal_init(struct happy_meal *hp)
 		hme_write32(hp, bregs + BMAC_HTABLE3, 0xffff);
 	} else if ((hp->dev->flags & IFF_PROMISC) == 0) {
 		u16 hash_table[4];
-		struct dev_mc_list *dmi;
+		struct netdev_hw_addr *ha;
 		char *addrs;
 		u32 crc;
 
 		memset(hash_table, 0, sizeof(hash_table));
-		netdev_for_each_mc_addr(dmi, hp->dev) {
-			addrs = dmi->dmi_addr;
+		netdev_for_each_mc_addr(ha, hp->dev) {
+			addrs = ha->addr;
 
 			if (!(*addrs & 1))
 				continue;
@@ -2362,7 +2362,7 @@ static void happy_meal_set_multicast(struct net_device *dev)
 {
 	struct happy_meal *hp = netdev_priv(dev);
 	void __iomem *bregs = hp->bigmacregs;
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	char *addrs;
 	u32 crc;
 
@@ -2380,8 +2380,8 @@ static void happy_meal_set_multicast(struct net_device *dev)
 		u16 hash_table[4];
 
 		memset(hash_table, 0, sizeof(hash_table));
-		netdev_for_each_mc_addr(dmi, dev) {
-			addrs = dmi->dmi_addr;
+		netdev_for_each_mc_addr(ha, dev) {
+			addrs = ha->addr;
 
 			if (!(*addrs & 1))
 				continue;
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index d7c73f4..6745705 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -1170,7 +1170,7 @@ static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 static void lance_load_multicast(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	char *addrs;
 	u32 crc;
 	u32 val;
@@ -1195,8 +1195,8 @@ static void lance_load_multicast(struct net_device *dev)
 		return;
 
 	/* Add addresses */
-	netdev_for_each_mc_addr(dmi, dev) {
-		addrs = dmi->dmi_addr;
+	netdev_for_each_mc_addr(ha, dev) {
+		addrs = ha->addr;
 
 		/* multicast address? */
 		if (!(*addrs & 1))
diff --git a/drivers/net/sunqe.c b/drivers/net/sunqe.c
index be637dc..239f097 100644
--- a/drivers/net/sunqe.c
+++ b/drivers/net/sunqe.c
@@ -627,7 +627,7 @@ static int qe_start_xmit(struct sk_buff *skb, struct net_device *dev)
 static void qe_set_multicast(struct net_device *dev)
 {
 	struct sunqe *qep = netdev_priv(dev);
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	u8 new_mconfig = qep->mconfig;
 	char *addrs;
 	int i;
@@ -651,8 +651,8 @@ static void qe_set_multicast(struct net_device *dev)
 		u8 *hbytes = (unsigned char *) &hash_table[0];
 
 		memset(hash_table, 0, sizeof(hash_table));
-		netdev_for_each_mc_addr(dmi, dev) {
-			addrs = dmi->dmi_addr;
+		netdev_for_each_mc_addr(ha, dev) {
+			addrs = ha->addr;
 
 			if (!(*addrs & 1))
 				continue;
diff --git a/drivers/net/sunvnet.c b/drivers/net/sunvnet.c
index 6b1b7ce..6cf8b06 100644
--- a/drivers/net/sunvnet.c
+++ b/drivers/net/sunvnet.c
@@ -763,12 +763,12 @@ static struct vnet_mcast_entry *__vnet_mc_find(struct vnet *vp, u8 *addr)
 
 static void __update_mc_list(struct vnet *vp, struct net_device *dev)
 {
-	struct dev_addr_list *p;
+	struct netdev_hw_addr *ha;
 
-	netdev_for_each_mc_addr(p, dev) {
+	netdev_for_each_mc_addr(ha, dev) {
 		struct vnet_mcast_entry *m;
 
-		m = __vnet_mc_find(vp, p->dmi_addr);
+		m = __vnet_mc_find(vp, ha->addr);
 		if (m) {
 			m->hit = 1;
 			continue;
@@ -778,7 +778,7 @@ static void __update_mc_list(struct vnet *vp, struct net_device *dev)
 			m = kzalloc(sizeof(*m), GFP_ATOMIC);
 			if (!m)
 				continue;
-			memcpy(m->addr, p->dmi_addr, ETH_ALEN);
+			memcpy(m->addr, ha->addr, ETH_ALEN);
 			m->hit = 1;
 
 			m->next = vp->mcast_list;
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 49bd84c..36149dd 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1954,16 +1954,16 @@ tc35815_set_multicast_list(struct net_device *dev)
 		/* Disable promiscuous mode, use normal mode. */
 		tc_writel(CAM_CompEn | CAM_BroadAcc | CAM_GroupAcc, &tr->CAM_Ctl);
 	} else if (!netdev_mc_empty(dev)) {
-		struct dev_mc_list *cur_addr;
+		struct netdev_hw_addr *ha;
 		int i;
 		int ena_bits = CAM_Ena_Bit(CAM_ENTRY_SOURCE);
 
 		tc_writel(0, &tr->CAM_Ctl);
 		/* Walk the address list, and load the filter */
 		i = 0;
-		netdev_for_each_mc_addr(cur_addr, dev) {
+		netdev_for_each_mc_addr(ha, dev) {
 			/* entry 0,1 is reserved. */
-			tc35815_set_cam_entry(dev, i + 2, cur_addr->dmi_addr);
+			tc35815_set_cam_entry(dev, i + 2, ha->addr);
 			ena_bits |= CAM_Ena_Bit(i + 2);
 			i++;
 		}
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 068a471..a38aede 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -808,7 +808,7 @@ static void bdx_setmulti(struct net_device *ndev)
 			WRITE_REG(priv, regRX_MCST_HASH0 + i * 4, ~0);
 	} else if (!netdev_mc_empty(ndev)) {
 		u8 hash;
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 		u32 reg, val;
 
 		/* set IMF to deny all multicast frames */
@@ -825,10 +825,10 @@ static void bdx_setmulti(struct net_device *ndev)
 		 * into RX_MAC_MCST regs. we skip this phase now and accept ALL
 		 * multicast frames throu IMF */
 		/* accept the rest of addresses throu IMF */
-		netdev_for_each_mc_addr(mclist, ndev) {
+		netdev_for_each_mc_addr(ha, ndev) {
 			hash = 0;
 			for (i = 0; i < ETH_ALEN; i++)
-				hash ^= mclist->dmi_addr[i];
+				hash ^= ha->addr[i];
 			reg = regRX_MCST_HASH0 + ((hash >> 5) << 2);
 			val = READ_REG(priv, reg);
 			val |= (1 << (hash % 32));
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 22cf1c4..aff11f8 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9457,14 +9457,14 @@ static void __tg3_set_rx_mode(struct net_device *dev)
 		tg3_set_multi (tp, 0);
 	} else {
 		/* Accept one or more multicast(s). */
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 		u32 mc_filter[4] = { 0, };
 		u32 regidx;
 		u32 bit;
 		u32 crc;
 
-		netdev_for_each_mc_addr(mclist, dev) {
-			crc = calc_crc (mclist->dmi_addr, ETH_ALEN);
+		netdev_for_each_mc_addr(ha, dev) {
+			crc = calc_crc(ha->addr, ETH_ALEN);
 			bit = ~crc & 0x7f;
 			regidx = (bit & 0x60) >> 5;
 			bit &= 0x1f;
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 05ea30a..8ffec22 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -1314,7 +1314,7 @@ static struct net_device_stats *TLan_GetStats( struct net_device *dev )
 
 static void TLan_SetMulticastList( struct net_device *dev )
 {
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	u32			hash1 = 0;
 	u32			hash2 = 0;
 	int			i;
@@ -1336,12 +1336,12 @@ static void TLan_SetMulticastList( struct net_device *dev )
 			TLan_DioWrite32( dev->base_addr, TLAN_HASH_2, 0xFFFFFFFF );
 		} else {
 			i = 0;
-			netdev_for_each_mc_addr(dmi, dev) {
+			netdev_for_each_mc_addr(ha, dev) {
 				if ( i < 3 ) {
 					TLan_SetMac( dev, i + 1,
-						     (char *) &dmi->dmi_addr );
+						     (char *) &ha->addr);
 				} else {
-					offset = TLan_HashFunc( (u8 *) &dmi->dmi_addr );
+					offset = TLan_HashFunc((u8 *)&ha->addr);
 					if ( offset < 32 )
 						hash1 |= ( 1 << offset );
 					else
diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index 8c54d89..4673e38 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -1390,7 +1390,7 @@ static int xl_close(struct net_device *dev)
 static void xl_set_rx_mode(struct net_device *dev) 
 {
 	struct xl_private *xl_priv = netdev_priv(dev);
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	unsigned char dev_mc_address[4] ; 
 	u16 options ; 
 
@@ -1407,11 +1407,11 @@ static void xl_set_rx_mode(struct net_device *dev)
 
 	dev_mc_address[0] = dev_mc_address[1] = dev_mc_address[2] = dev_mc_address[3] = 0 ;
 
-	netdev_for_each_mc_addr(dmi, dev) {
-                dev_mc_address[0] |= dmi->dmi_addr[2] ;
-                dev_mc_address[1] |= dmi->dmi_addr[3] ;
-                dev_mc_address[2] |= dmi->dmi_addr[4] ;
-                dev_mc_address[3] |= dmi->dmi_addr[5] ;
+	netdev_for_each_mc_addr(ha, dev) {
+		dev_mc_address[0] |= ha->addr[2];
+		dev_mc_address[1] |= ha->addr[3];
+		dev_mc_address[2] |= ha->addr[4];
+		dev_mc_address[3] |= ha->addr[5];
         }
 
 	if (memcmp(xl_priv->xl_functional_addr,dev_mc_address,4) != 0) { /* Options have changed, run the command */
diff --git a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
index 1a09672..eebdaae 100644
--- a/drivers/net/tokenring/ibmtr.c
+++ b/drivers/net/tokenring/ibmtr.c
@@ -986,7 +986,7 @@ static void open_sap(unsigned char type, struct net_device *dev)
 static void tok_set_multicast_list(struct net_device *dev)
 {
 	struct tok_info *ti = netdev_priv(dev);
-	struct dev_mc_list *mclist;
+	struct netdev_hw_addr *ha;
 	unsigned char address[4];
 
 	int i;
@@ -995,11 +995,11 @@ static void tok_set_multicast_list(struct net_device *dev)
 	/*BMS ifconfig tr down or hot unplug a PCMCIA card ??hownowbrowncow*/
 	if (/*BMSHELPdev->start == 0 ||*/ ti->open_status != OPEN) return;
 	address[0] = address[1] = address[2] = address[3] = 0;
-	netdev_for_each_mc_addr(mclist, dev) {
-		address[0] |= mclist->dmi_addr[2];
-		address[1] |= mclist->dmi_addr[3];
-		address[2] |= mclist->dmi_addr[4];
-		address[3] |= mclist->dmi_addr[5];
+	netdev_for_each_mc_addr(ha, dev) {
+		address[0] |= ha->addr[2];
+		address[1] |= ha->addr[3];
+		address[2] |= ha->addr[4];
+		address[3] |= ha->addr[5];
 	}
 	SET_PAGE(ti->srb_page);
 	for (i = 0; i < sizeof(struct srb_set_funct_addr); i++)
diff --git a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/lanstreamer.c
index 01c780f..88c8931 100644
--- a/drivers/net/tokenring/lanstreamer.c
+++ b/drivers/net/tokenring/lanstreamer.c
@@ -1266,7 +1266,7 @@ static void streamer_set_rx_mode(struct net_device *dev)
 	    netdev_priv(dev);
 	__u8 __iomem *streamer_mmio = streamer_priv->streamer_mmio;
 	__u8 options = 0;
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	unsigned char dev_mc_address[5];
 
 	writel(streamer_priv->srb, streamer_mmio + LAPA);
@@ -1302,11 +1302,11 @@ static void streamer_set_rx_mode(struct net_device *dev)
 	writel(streamer_priv->srb,streamer_mmio+LAPA);
 	dev_mc_address[0] = dev_mc_address[1] = dev_mc_address[2] = dev_mc_address[3] = 0 ; 
   
-	netdev_for_each_mc_addr(dmi, dev) {
-   	        dev_mc_address[0] |= dmi->dmi_addr[2] ; 
-		dev_mc_address[1] |= dmi->dmi_addr[3] ; 
-		dev_mc_address[2] |= dmi->dmi_addr[4] ; 
-		dev_mc_address[3] |= dmi->dmi_addr[5] ; 
+	netdev_for_each_mc_addr(ha, dev) {
+		dev_mc_address[0] |= ha->addr[2];
+		dev_mc_address[1] |= ha->addr[3];
+		dev_mc_address[2] |= ha->addr[4];
+		dev_mc_address[3] |= ha->addr[5];
 	}
   
 	writew(htons(SRB_SET_FUNC_ADDRESS << 8),streamer_mmio+LAPDINC);
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
index 3decaf4..3d2fbe6 100644
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -1139,7 +1139,7 @@ static void olympic_set_rx_mode(struct net_device *dev)
    	u8 __iomem *olympic_mmio = olympic_priv->olympic_mmio ; 
 	u8 options = 0; 
 	u8 __iomem *srb;
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	unsigned char dev_mc_address[4] ; 
 
 	writel(olympic_priv->srb,olympic_mmio+LAPA);
@@ -1177,11 +1177,11 @@ static void olympic_set_rx_mode(struct net_device *dev)
 
 	dev_mc_address[0] = dev_mc_address[1] = dev_mc_address[2] = dev_mc_address[3] = 0 ; 
 
-	netdev_for_each_mc_addr(dmi, dev) {
-		dev_mc_address[0] |= dmi->dmi_addr[2] ; 
-		dev_mc_address[1] |= dmi->dmi_addr[3] ; 
-		dev_mc_address[2] |= dmi->dmi_addr[4] ; 
-		dev_mc_address[3] |= dmi->dmi_addr[5] ; 
+	netdev_for_each_mc_addr(ha, dev) {
+		dev_mc_address[0] |= ha->addr[2];
+		dev_mc_address[1] |= ha->addr[3];
+		dev_mc_address[2] |= ha->addr[4];
+		dev_mc_address[3] |= ha->addr[5];
 	}
 
 	writeb(SRB_SET_FUNC_ADDRESS,srb+0);
diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index b545e20..9fa2c36 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -1212,17 +1212,17 @@ static void tms380tr_set_multicast_list(struct net_device *dev)
 		}
 		else
 		{
-			struct dev_mc_list *mclist;
+			struct netdev_hw_addr *ha;
 
-			netdev_for_each_mc_addr(mclist, dev) {
+			netdev_for_each_mc_addr(ha, dev) {
 				((char *)(&tp->ocpl.FunctAddr))[0] |=
-					mclist->dmi_addr[2];
+					ha->addr[2];
 				((char *)(&tp->ocpl.FunctAddr))[1] |=
-					mclist->dmi_addr[3];
+					ha->addr[3];
 				((char *)(&tp->ocpl.FunctAddr))[2] |=
-					mclist->dmi_addr[4];
+					ha->addr[4];
 				((char *)(&tp->ocpl.FunctAddr))[3] |=
-					mclist->dmi_addr[5];
+					ha->addr[5];
 			}
 		}
 		tms380tr_exec_cmd(dev, OC_SET_FUNCT_ADDR);
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index 80333a4..1366541 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -1186,15 +1186,15 @@ static void tsi108_set_rx_mode(struct net_device *dev)
 
 	if (dev->flags & IFF_ALLMULTI || !netdev_mc_empty(dev)) {
 		int i;
-		struct dev_mc_list *mc;
+		struct netdev_hw_addr *ha;
 		rxcfg |= TSI108_EC_RXCFG_MFE | TSI108_EC_RXCFG_MC_HASH;
 
 		memset(data->mc_hash, 0, sizeof(data->mc_hash));
 
-		netdev_for_each_mc_addr(mc, dev) {
+		netdev_for_each_mc_addr(ha, dev) {
 			u32 hash, crc;
 
-			crc = ether_crc(6, mc->dmi_addr);
+			crc = ether_crc(6, ha->addr);
 			hash = crc >> 23;
 			__set_bit(hash, &data->mc_hash[0]);
 		}
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index cb42972..a68b917 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -670,15 +670,15 @@ static void build_setup_frame_hash(u16 *setup_frm, struct net_device *dev)
 {
 	struct de_private *de = netdev_priv(dev);
 	u16 hash_table[32];
-	struct dev_mc_list *mclist;
+	struct netdev_hw_addr *ha;
 	int i;
 	u16 *eaddrs;
 
 	memset(hash_table, 0, sizeof(hash_table));
 	set_bit_le(255, hash_table); 			/* Broadcast entry */
 	/* This should work on big-endian machines as well. */
-	netdev_for_each_mc_addr(mclist, dev) {
-		int index = ether_crc_le(ETH_ALEN, mclist->dmi_addr) & 0x1ff;
+	netdev_for_each_mc_addr(ha, dev) {
+		int index = ether_crc_le(ETH_ALEN, ha->addr) & 0x1ff;
 
 		set_bit_le(index, hash_table);
 	}
@@ -699,13 +699,13 @@ static void build_setup_frame_hash(u16 *setup_frm, struct net_device *dev)
 static void build_setup_frame_perfect(u16 *setup_frm, struct net_device *dev)
 {
 	struct de_private *de = netdev_priv(dev);
-	struct dev_mc_list *mclist;
+	struct netdev_hw_addr *ha;
 	u16 *eaddrs;
 
 	/* We have <= 14 addresses so we can use the wonderful
 	   16 address perfect filtering of the Tulip. */
-	netdev_for_each_mc_addr(mclist, dev) {
-		eaddrs = (u16 *)mclist->dmi_addr;
+	netdev_for_each_mc_addr(ha, dev) {
+		eaddrs = (u16 *) ha->addr;
 		*setup_frm++ = *eaddrs; *setup_frm++ = *eaddrs++;
 		*setup_frm++ = *eaddrs; *setup_frm++ = *eaddrs++;
 		*setup_frm++ = *eaddrs; *setup_frm++ = *eaddrs++;
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index 55ade89..cac4bcc 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -1951,7 +1951,7 @@ static void
 SetMulticastFilter(struct net_device *dev)
 {
     struct de4x5_private *lp = netdev_priv(dev);
-    struct dev_mc_list *dmi;
+    struct netdev_hw_addr *ha;
     u_long iobase = dev->base_addr;
     int i, bit, byte;
     u16 hashcode;
@@ -1966,8 +1966,8 @@ SetMulticastFilter(struct net_device *dev)
     if ((dev->flags & IFF_ALLMULTI) || (netdev_mc_count(dev) > 14)) {
 	omr |= OMR_PM;                       /* Pass all multicasts */
     } else if (lp->setup_f == HASH_PERF) {   /* Hash Filtering */
-	netdev_for_each_mc_addr(dmi, dev) {
-	    addrs = dmi->dmi_addr;
+	netdev_for_each_mc_addr(ha, dev) {
+	    addrs = ha->addr;
 	    if ((*addrs & 0x01) == 1) {      /* multicast address? */
 		crc = ether_crc_le(ETH_ALEN, addrs);
 		hashcode = crc & HASH_BITS;  /* hashcode is 9 LSb of CRC */
@@ -1983,8 +1983,8 @@ SetMulticastFilter(struct net_device *dev)
 	    }
 	}
     } else {                                 /* Perfect filtering */
-	netdev_for_each_mc_addr(dmi, dev) {
-	    addrs = dmi->dmi_addr;
+	netdev_for_each_mc_addr(ha, dev) {
+	    addrs = ha->addr;
 	    for (i=0; i<ETH_ALEN; i++) {
 		*(pa + (i&1)) = *addrs++;
 		if (i & 0x01) pa += 4;
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 95b38d8..a039c8a 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -1454,7 +1454,7 @@ static void update_cr6(u32 cr6_data, unsigned long ioaddr)
 
 static void dm9132_id_table(struct DEVICE *dev)
 {
-	struct dev_mc_list *mcptr;
+	struct netdev_hw_addr *ha;
 	u16 * addrptr;
 	unsigned long ioaddr = dev->base_addr+0xc0;		/* ID Table */
 	u32 hash_val;
@@ -1478,8 +1478,8 @@ static void dm9132_id_table(struct DEVICE *dev)
 	hash_table[3] = 0x8000;
 
 	/* the multicast address in Hash Table : 64 bits */
-	netdev_for_each_mc_addr(mcptr, dev) {
-		hash_val = cal_CRC((char *) mcptr->dmi_addr, 6, 0) & 0x3f;
+	netdev_for_each_mc_addr(ha, dev) {
+		hash_val = cal_CRC((char *) ha->addr, 6, 0) & 0x3f;
 		hash_table[hash_val / 16] |= (u16) 1 << (hash_val % 16);
 	}
 
@@ -1497,7 +1497,7 @@ static void dm9132_id_table(struct DEVICE *dev)
 static void send_filter_frame(struct DEVICE *dev)
 {
 	struct dmfe_board_info *db = netdev_priv(dev);
-	struct dev_mc_list *mcptr;
+	struct netdev_hw_addr *ha;
 	struct tx_desc *txptr;
 	u16 * addrptr;
 	u32 * suptr;
@@ -1520,8 +1520,8 @@ static void send_filter_frame(struct DEVICE *dev)
 	*suptr++ = 0xffff;
 
 	/* fit the multicast address */
-	netdev_for_each_mc_addr(mcptr, dev) {
-		addrptr = (u16 *) mcptr->dmi_addr;
+	netdev_for_each_mc_addr(ha, dev) {
+		addrptr = (u16 *) ha->addr;
 		*suptr++ = addrptr[0];
 		*suptr++ = addrptr[1];
 		*suptr++ = addrptr[2];
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 7f544ef..c4b7cd7 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -990,15 +990,15 @@ static void build_setup_frame_hash(u16 *setup_frm, struct net_device *dev)
 {
 	struct tulip_private *tp = netdev_priv(dev);
 	u16 hash_table[32];
-	struct dev_mc_list *mclist;
+	struct netdev_hw_addr *ha;
 	int i;
 	u16 *eaddrs;
 
 	memset(hash_table, 0, sizeof(hash_table));
 	set_bit_le(255, hash_table); 			/* Broadcast entry */
 	/* This should work on big-endian machines as well. */
-	netdev_for_each_mc_addr(mclist, dev) {
-		int index = ether_crc_le(ETH_ALEN, mclist->dmi_addr) & 0x1ff;
+	netdev_for_each_mc_addr(ha, dev) {
+		int index = ether_crc_le(ETH_ALEN, ha->addr) & 0x1ff;
 
 		set_bit_le(index, hash_table);
 	}
@@ -1018,13 +1018,13 @@ static void build_setup_frame_hash(u16 *setup_frm, struct net_device *dev)
 static void build_setup_frame_perfect(u16 *setup_frm, struct net_device *dev)
 {
 	struct tulip_private *tp = netdev_priv(dev);
-	struct dev_mc_list *mclist;
+	struct netdev_hw_addr *ha;
 	u16 *eaddrs;
 
 	/* We have <= 14 addresses so we can use the wonderful
 	   16 address perfect filtering of the Tulip. */
-	netdev_for_each_mc_addr(mclist, dev) {
-		eaddrs = (u16 *)mclist->dmi_addr;
+	netdev_for_each_mc_addr(ha, dev) {
+		eaddrs = (u16 *) ha->addr;
 		*setup_frm++ = *eaddrs; *setup_frm++ = *eaddrs++;
 		*setup_frm++ = *eaddrs; *setup_frm++ = *eaddrs++;
 		*setup_frm++ = *eaddrs; *setup_frm++ = *eaddrs++;
@@ -1061,7 +1061,7 @@ static void set_rx_mode(struct net_device *dev)
 	} else	if (tp->flags & MC_HASH_ONLY) {
 		/* Some work-alikes have only a 64-entry hash filter table. */
 		/* Should verify correctness on big-endian/__powerpc__ */
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 		if (netdev_mc_count(dev) > 64) {
 			/* Arbitrary non-effective limit. */
 			tp->csr6 |= AcceptAllMulticast;
@@ -1069,18 +1069,21 @@ static void set_rx_mode(struct net_device *dev)
 		} else {
 			u32 mc_filter[2] = {0, 0};		 /* Multicast hash filter */
 			int filterbit;
-			netdev_for_each_mc_addr(mclist, dev) {
+			netdev_for_each_mc_addr(ha, dev) {
 				if (tp->flags & COMET_MAC_ADDR)
-					filterbit = ether_crc_le(ETH_ALEN, mclist->dmi_addr);
+					filterbit = ether_crc_le(ETH_ALEN,
+								 ha->addr);
 				else
-					filterbit = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
+					filterbit = ether_crc(ETH_ALEN,
+							      ha->addr) >> 26;
 				filterbit &= 0x3f;
 				mc_filter[filterbit >> 5] |= 1 << (filterbit & 31);
 				if (tulip_debug > 2)
 					dev_info(&dev->dev,
 						 "Added filter for %pM  %08x bit %d\n",
-						 mclist->dmi_addr,
-						 ether_crc(ETH_ALEN, mclist->dmi_addr), filterbit);
+						 ha->addr,
+						 ether_crc(ETH_ALEN, ha->addr),
+						 filterbit);
 			}
 			if (mc_filter[0] == tp->mc_filter[0]  &&
 				mc_filter[1] == tp->mc_filter[1])
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index 0ab05af..b79d908 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -1392,7 +1392,7 @@ static void update_cr6(u32 cr6_data, unsigned long ioaddr)
 static void send_filter_frame(struct net_device *dev, int mc_cnt)
 {
 	struct uli526x_board_info *db = netdev_priv(dev);
-	struct dev_mc_list *mcptr;
+	struct netdev_hw_addr *ha;
 	struct tx_desc *txptr;
 	u16 * addrptr;
 	u32 * suptr;
@@ -1415,8 +1415,8 @@ static void send_filter_frame(struct net_device *dev, int mc_cnt)
 	*suptr++ = 0xffff << FLT_SHIFT;
 
 	/* fit the multicast address */
-	netdev_for_each_mc_addr(mcptr, dev) {
-		addrptr = (u16 *) mcptr->dmi_addr;
+	netdev_for_each_mc_addr(ha, dev) {
+		addrptr = (u16 *) ha->addr;
 		*suptr++ = addrptr[0] << FLT_SHIFT;
 		*suptr++ = addrptr[1] << FLT_SHIFT;
 		*suptr++ = addrptr[2] << FLT_SHIFT;
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 304f438..3e3822c 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -1367,13 +1367,15 @@ static u32 __set_rx_mode(struct net_device *dev)
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = RxAcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 	} else {
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		netdev_for_each_mc_addr(mclist, dev) {
-			int filterbit = (ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26) ^ 0x3F;
-			filterbit &= 0x3f;
-			mc_filter[filterbit >> 5] |= 1 << (filterbit & 31);
+		netdev_for_each_mc_addr(ha, dev) {
+			int filbit;
+
+			filbit = (ether_crc(ETH_ALEN, ha->addr) >> 26) ^ 0x3F;
+			filbit &= 0x3f;
+			mc_filter[filbit >> 5] |= 1 << (filbit & 31);
 		}
 		rx_mode = RxAcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 	}
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index cd24e5f..3053f85 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -921,11 +921,11 @@ typhoon_set_rx_mode(struct net_device *dev)
 		/* Too many to match, or accept all multicasts. */
 		filter |= TYPHOON_RX_FILTER_ALL_MCAST;
 	} else if (!netdev_mc_empty(dev)) {
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		netdev_for_each_mc_addr(mclist, dev) {
-			int bit = ether_crc(ETH_ALEN, mclist->dmi_addr) & 0x3f;
+		netdev_for_each_mc_addr(ha, dev) {
+			int bit = ether_crc(ETH_ALEN, ha->addr) & 0x3f;
 			mc_filter[bit >> 5] |= 1 << (bit & 0x1f);
 		}
 
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 75743a7..081f76b 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1999,7 +1999,7 @@ static void ucc_geth_memclean(struct ucc_geth_private *ugeth)
 static void ucc_geth_set_multi(struct net_device *dev)
 {
 	struct ucc_geth_private *ugeth;
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 	struct ucc_fast __iomem *uf_regs;
 	struct ucc_geth_82xx_address_filtering_pram __iomem *p_82xx_addr_filt;
 
@@ -2028,16 +2028,16 @@ static void ucc_geth_set_multi(struct net_device *dev)
 			out_be32(&p_82xx_addr_filt->gaddr_h, 0x0);
 			out_be32(&p_82xx_addr_filt->gaddr_l, 0x0);
 
-			netdev_for_each_mc_addr(dmi, dev) {
+			netdev_for_each_mc_addr(ha, dev) {
 				/* Only support group multicast for now.
 				 */
-				if (!(dmi->dmi_addr[0] & 1))
+				if (!(ha->addr[0] & 1))
 					continue;
 
 				/* Ask CPM to run CRC and set bit in
 				 * filter mask.
 				 */
-				hw_add_addr_in_hash(ugeth, dmi->dmi_addr);
+				hw_add_addr_in_hash(ugeth, ha->addr);
 			}
 		}
 	}
diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index 9e05639..763364f 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -557,16 +557,14 @@ static void asix_set_multicast(struct net_device *net)
 		 * for our 8 byte filter buffer
 		 * to avoid allocating memory that
 		 * is tricky to free later */
-		struct dev_mc_list *mc_list;
+		struct netdev_hw_addr *ha;
 		u32 crc_bits;
 
 		memset(data->multi_filter, 0, AX_MCAST_FILTER_SIZE);
 
 		/* Build the multicast hash filter. */
-		netdev_for_each_mc_addr(mc_list, net) {
-			crc_bits =
-			    ether_crc(ETH_ALEN,
-				      mc_list->dmi_addr) >> 26;
+		netdev_for_each_mc_addr(ha, net) {
+			crc_bits = ether_crc(ETH_ALEN, ha->addr) >> 26;
 			data->multi_filter[crc_bits >> 3] |=
 			    1 << (crc_bits & 7);
 		}
@@ -793,16 +791,14 @@ static void ax88172_set_multicast(struct net_device *net)
 		 * for our 8 byte filter buffer
 		 * to avoid allocating memory that
 		 * is tricky to free later */
-		struct dev_mc_list *mc_list;
+		struct netdev_hw_addr *ha;
 		u32 crc_bits;
 
 		memset(data->multi_filter, 0, AX_MCAST_FILTER_SIZE);
 
 		/* Build the multicast hash filter. */
-		netdev_for_each_mc_addr(mc_list, net) {
-			crc_bits =
-			    ether_crc(ETH_ALEN,
-				      mc_list->dmi_addr) >> 26;
+		netdev_for_each_mc_addr(ha, net) {
+			crc_bits = ether_crc(ETH_ALEN, ha->addr) >> 26;
 			data->multi_filter[crc_bits >> 3] |=
 			    1 << (crc_bits & 7);
 		}
diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index 96f1ebe..0c48ff9 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -629,7 +629,7 @@ static void catc_multicast(unsigned char *addr, u8 *multicast)
 static void catc_set_multicast_list(struct net_device *netdev)
 {
 	struct catc *catc = netdev_priv(netdev);
-	struct dev_mc_list *mc;
+	struct netdev_hw_addr *ha;
 	u8 broadcast[6];
 	u8 rx = RxEnable | RxPolarity | RxMultiCast;
 
@@ -647,8 +647,8 @@ static void catc_set_multicast_list(struct net_device *netdev)
 	if (netdev->flags & IFF_ALLMULTI) {
 		memset(catc->multicast, 0xff, 64);
 	} else {
-		netdev_for_each_mc_addr(mc, netdev) {
-			u32 crc = ether_crc_le(6, mc->dmi_addr);
+		netdev_for_each_mc_addr(ha, netdev) {
+			u32 crc = ether_crc_le(6, ha->addr);
 			if (!catc->is_f5u011) {
 				catc->multicast[(crc >> 3) & 0x3f] |= 1 << (crc & 7);
 			} else {
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 2693397..4eb1fb3 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -386,10 +386,10 @@ static void dm9601_set_multicast(struct net_device *net)
 		   netdev_mc_count(net) > DM_MAX_MCAST) {
 		rx_ctl |= 0x04;
 	} else if (!netdev_mc_empty(net)) {
-		struct dev_mc_list *mc_list;
+		struct netdev_hw_addr *ha;
 
-		netdev_for_each_mc_addr(mc_list, net) {
-			u32 crc = ether_crc(ETH_ALEN, mc_list->dmi_addr) >> 26;
+		netdev_for_each_mc_addr(ha, net) {
+			u32 crc = ether_crc(ETH_ALEN, ha->addr) >> 26;
 			hashes[crc >> 3] |= 1 << (crc & 0x7);
 		}
 	}
diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index 7097821..0dc92c8 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -452,12 +452,12 @@ static void mcs7830_data_set_multicast(struct net_device *net)
 		 * for our 8 byte filter buffer
 		 * to avoid allocating memory that
 		 * is tricky to free later */
-		struct dev_mc_list *mc_list;
+		struct netdev_hw_addr *ha;
 		u32 crc_bits;
 
 		/* Build the multicast hash filter. */
-		netdev_for_each_mc_addr(mc_list, net) {
-			crc_bits = ether_crc(ETH_ALEN, mc_list->dmi_addr) >> 26;
+		netdev_for_each_mc_addr(ha, net) {
+			crc_bits = ether_crc(ETH_ALEN, ha->addr) >> 26;
 			data->multi_filter[crc_bits >> 3] |= 1 << (crc_bits & 7);
 		}
 	}
diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 300e3e7..b8b00d0 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -444,14 +444,14 @@ static void smsc75xx_set_multicast(struct net_device *netdev)
 		netif_dbg(dev, drv, dev->net, "receive all multicast enabled");
 		pdata->rfe_ctl |= RFE_CTL_AM | RFE_CTL_DPF;
 	} else if (!netdev_mc_empty(dev->net)) {
-		struct dev_mc_list *mc_list;
+		struct netdev_hw_addr *ha;
 
 		netif_dbg(dev, drv, dev->net, "receive multicast hash filter");
 
 		pdata->rfe_ctl |= RFE_CTL_MHF | RFE_CTL_DPF;
 
-		netdev_for_each_mc_addr(mc_list, netdev) {
-			u32 bitnum = smsc75xx_hash(mc_list->dmi_addr);
+		netdev_for_each_mc_addr(ha, netdev) {
+			u32 bitnum = smsc75xx_hash(ha->addr);
 			pdata->multicast_hash_table[bitnum / 32] |=
 				(1 << (bitnum % 32));
 		}
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 73f9a31..ccd55ca 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -384,13 +384,13 @@ static void smsc95xx_set_multicast(struct net_device *netdev)
 		pdata->mac_cr |= MAC_CR_MCPAS_;
 		pdata->mac_cr &= ~(MAC_CR_PRMS_ | MAC_CR_HPFILT_);
 	} else if (!netdev_mc_empty(dev->net)) {
-		struct dev_mc_list *mc_list;
+		struct netdev_hw_addr *ha;
 
 		pdata->mac_cr |= MAC_CR_HPFILT_;
 		pdata->mac_cr &= ~(MAC_CR_PRMS_ | MAC_CR_MCPAS_);
 
-		netdev_for_each_mc_addr(mc_list, netdev) {
-			u32 bitnum = smsc95xx_hash(mc_list->dmi_addr);
+		netdev_for_each_mc_addr(ha, netdev) {
+			u32 bitnum = smsc95xx_hash(ha->addr);
 			u32 mask = 0x01 << (bitnum & 0x1F);
 			if (bitnum & 0x20)
 				hash_hi |= mask;
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 50f881a..d9133c6 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -1704,11 +1704,11 @@ static void rhine_set_rx_mode(struct net_device *dev)
 		iowrite32(0xffffffff, ioaddr + MulticastFilter1);
 		rx_mode = 0x0C;
 	} else {
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		netdev_for_each_mc_addr(mclist, dev) {
-			int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
+		netdev_for_each_mc_addr(ha, dev) {
+			int bit_nr = ether_crc(ETH_ALEN, ha->addr) >> 26;
 
 			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
 		}
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 3a486f3..91f3b84 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1126,7 +1126,7 @@ static void velocity_set_multi(struct net_device *dev)
 	struct mac_regs __iomem *regs = vptr->mac_regs;
 	u8 rx_mode;
 	int i;
-	struct dev_mc_list *mclist;
+	struct netdev_hw_addr *ha;
 
 	if (dev->flags & IFF_PROMISC) {	/* Set promiscuous. */
 		writel(0xffffffff, &regs->MARCAM[0]);
@@ -1142,8 +1142,8 @@ static void velocity_set_multi(struct net_device *dev)
 		mac_get_cam_mask(regs, vptr->mCAMmask);
 
 		i = 0;
-		netdev_for_each_mc_addr(mclist, dev) {
-			mac_set_cam(regs, i + offset, mclist->dmi_addr);
+		netdev_for_each_mc_addr(ha, dev) {
+			mac_set_cam(regs, i + offset, ha->addr);
 			vptr->mCAMmask[(offset + i) / 8] |= 1 << ((offset + i) & 7);
 			i++;
 		}
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 3f5be35..ecec9a8 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -721,7 +721,6 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	struct scatterlist sg[2];
 	u8 promisc, allmulti;
 	struct virtio_net_ctrl_mac *mac_data;
-	struct dev_addr_list *addr;
 	struct netdev_hw_addr *ha;
 	int uc_count;
 	int mc_count;
@@ -778,8 +777,8 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 
 	mac_data->entries = mc_count;
 	i = 0;
-	netdev_for_each_mc_addr(addr, dev)
-		memcpy(&mac_data->macs[i++][0], addr->da_addr, ETH_ALEN);
+	netdev_for_each_mc_addr(ha, dev)
+		memcpy(&mac_data->macs[i++][0], ha->addr, ETH_ALEN);
 
 	sg_set_buf(&sg[1], mac_data,
 		   sizeof(mac_data->entries) + (mc_count * ETH_ALEN));
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index cff3485..58dfa36 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1675,11 +1675,11 @@ vmxnet3_copy_mc(struct net_device *netdev)
 		/* We may be called with BH disabled */
 		buf = kmalloc(sz, GFP_ATOMIC);
 		if (buf) {
-			struct dev_mc_list *mc;
+			struct netdev_hw_addr *ha;
 			int i = 0;
 
-			netdev_for_each_mc_addr(mc, netdev)
-				memcpy(buf + i++ * ETH_ALEN, mc->dmi_addr,
+			netdev_for_each_mc_addr(ha, netdev)
+				memcpy(buf + i++ * ETH_ALEN, ha->addr,
 				       ETH_ALEN);
 		}
 	}
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index e5f2d3e..37836a1 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -1117,7 +1117,7 @@ vxge_tx_term(void *dtrh, enum vxge_hw_txdl_state state, void *userdata)
  */
 static void vxge_set_multicast(struct net_device *dev)
 {
-	struct dev_mc_list *mclist;
+	struct netdev_hw_addr *ha;
 	struct vxgedev *vdev;
 	int i, mcast_cnt = 0;
 	struct __vxge_hw_device  *hldev;
@@ -1217,8 +1217,8 @@ static void vxge_set_multicast(struct net_device *dev)
 		}
 
 		/* Add new ones */
-		netdev_for_each_mc_addr(mclist, dev) {
-			memcpy(mac_info.macaddr, mclist->dmi_addr, ETH_ALEN);
+		netdev_for_each_mc_addr(ha, dev) {
+			memcpy(mac_info.macaddr, ha->addr, ETH_ALEN);
 			for (vpath_idx = 0; vpath_idx < vdev->no_of_vpath;
 					vpath_idx++) {
 				mac_info.vpath_no = vpath_idx;
diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index 547912e..2277998 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -1317,21 +1317,19 @@ static void adm8211_bss_info_changed(struct ieee80211_hw *dev,
 }
 
 static u64 adm8211_prepare_multicast(struct ieee80211_hw *hw,
-				     int mc_count, struct dev_addr_list *mclist)
+				     struct netdev_hw_addr_list *mc_list)
 {
-	unsigned int bit_nr, i;
+	unsigned int bit_nr;
 	u32 mc_filter[2];
+	struct netdev_hw_addr *ha;
 
 	mc_filter[1] = mc_filter[0] = 0;
 
-	for (i = 0; i < mc_count; i++) {
-		if (!mclist)
-			break;
-		bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
+	netdev_hw_addr_list_for_each(ha, mc_list) {
+		bit_nr = ether_crc(ETH_ALEN, ha->addr) >> 26;
 
 		bit_nr &= 0x3F;
 		mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
-		mclist = mclist->next;
 	}
 
 	return mc_filter[0] | ((u64)(mc_filter[1]) << 32);
diff --git a/drivers/net/wireless/ath/ar9170/main.c b/drivers/net/wireless/ath/ar9170/main.c
index 257c734..b43d4b0 100644
--- a/drivers/net/wireless/ath/ar9170/main.c
+++ b/drivers/net/wireless/ath/ar9170/main.c
@@ -2045,21 +2045,17 @@ out:
 	return err;
 }
 
-static u64 ar9170_op_prepare_multicast(struct ieee80211_hw *hw, int mc_count,
-				       struct dev_addr_list *mclist)
+static u64 ar9170_op_prepare_multicast(struct ieee80211_hw *hw,
+				       struct netdev_hw_addr_list *mc_list)
 {
 	u64 mchash;
-	int i;
+	struct netdev_hw_addr *ha;
 
 	/* always get broadcast frames */
 	mchash = 1ULL << (0xff >> 2);
 
-	for (i = 0; i < mc_count; i++) {
-		if (WARN_ON(!mclist))
-			break;
-		mchash |= 1ULL << (mclist->dmi_addr[5] >> 2);
-		mclist = mclist->next;
-	}
+	netdev_hw_addr_list_for_each(ha, mc_list)
+		mchash |= 1ULL << (ha->addr[5] >> 2);
 
 	return mchash;
 }
diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index b142a78..53a2340 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -230,7 +230,7 @@ static void ath5k_remove_interface(struct ieee80211_hw *hw,
 		struct ieee80211_vif *vif);
 static int ath5k_config(struct ieee80211_hw *hw, u32 changed);
 static u64 ath5k_prepare_multicast(struct ieee80211_hw *hw,
-				   int mc_count, struct dev_addr_list *mc_list);
+				   struct netdev_hw_addr_list *mc_list);
 static void ath5k_configure_filter(struct ieee80211_hw *hw,
 		unsigned int changed_flags,
 		unsigned int *new_flags,
@@ -2999,22 +2999,20 @@ unlock:
 }
 
 static u64 ath5k_prepare_multicast(struct ieee80211_hw *hw,
-				   int mc_count, struct dev_addr_list *mclist)
+				   struct netdev_hw_addr_list *mc_list)
 {
 	u32 mfilt[2], val;
-	int i;
 	u8 pos;
+	struct netdev_hw_addr *ha;
 
 	mfilt[0] = 0;
 	mfilt[1] = 1;
 
-	for (i = 0; i < mc_count; i++) {
-		if (!mclist)
-			break;
+	netdev_hw_addr_list_for_each(ha, mc_list) {
 		/* calculate XOR of eight 6-bit values */
-		val = get_unaligned_le32(mclist->dmi_addr + 0);
+		val = get_unaligned_le32(ha->addr + 0);
 		pos = (val >> 18) ^ (val >> 12) ^ (val >> 6) ^ val;
-		val = get_unaligned_le32(mclist->dmi_addr + 3);
+		val = get_unaligned_le32(ha->addr + 3);
 		pos ^= (val >> 18) ^ (val >> 12) ^ (val >> 6) ^ val;
 		pos &= 0x3f;
 		mfilt[pos / 32] |= (1 << (pos % 32));
@@ -3022,8 +3020,7 @@ static u64 ath5k_prepare_multicast(struct ieee80211_hw *hw,
 		* but not sure, needs testing, if we do use this we'd
 		* neet to inform below to not reset the mcast */
 		/* ath5k_hw_set_mcast_filterindex(ah,
-		 *      mclist->dmi_addr[5]); */
-		mclist = mclist->next;
+		 *      ha->addr[5]); */
 	}
 
 	return ((u64)(mfilt[1]) << 32) | mfilt[0];
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 3c889f4..ff7b0d0 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -318,7 +318,7 @@ static int lbs_add_mcast_addrs(struct cmd_ds_mac_multicast_adr *cmd,
 			       struct net_device *dev, int nr_addrs)
 {
 	int i = nr_addrs;
-	struct dev_mc_list *mc_list;
+	struct netdev_hw_addr *ha;
 	int cnt;
 
 	if ((dev->flags & (IFF_UP|IFF_MULTICAST)) != (IFF_UP|IFF_MULTICAST))
@@ -326,19 +326,19 @@ static int lbs_add_mcast_addrs(struct cmd_ds_mac_multicast_adr *cmd,
 
 	netif_addr_lock_bh(dev);
 	cnt = netdev_mc_count(dev);
-	netdev_for_each_mc_addr(mc_list, dev) {
-		if (mac_in_list(cmd->maclist, nr_addrs, mc_list->dmi_addr)) {
+	netdev_for_each_mc_addr(ha, dev) {
+		if (mac_in_list(cmd->maclist, nr_addrs, ha->addr)) {
 			lbs_deb_net("mcast address %s:%pM skipped\n", dev->name,
-				    mc_list->dmi_addr);
+				    ha->addr);
 			cnt--;
 			continue;
 		}
 
 		if (i == MRVDRV_MAX_MULTICAST_LIST_SIZE)
 			break;
-		memcpy(&cmd->maclist[6*i], mc_list->dmi_addr, ETH_ALEN);
+		memcpy(&cmd->maclist[6*i], ha->addr, ETH_ALEN);
 		lbs_deb_net("mcast address %s:%pM added to filter\n", dev->name,
-			    mc_list->dmi_addr);
+			    ha->addr);
 		i++;
 		cnt--;
 	}
diff --git a/drivers/net/wireless/libertas_tf/main.c b/drivers/net/wireless/libertas_tf/main.c
index 6ab3003..c20eef6 100644
--- a/drivers/net/wireless/libertas_tf/main.c
+++ b/drivers/net/wireless/libertas_tf/main.c
@@ -367,22 +367,20 @@ static int lbtf_op_config(struct ieee80211_hw *hw, u32 changed)
 }
 
 static u64 lbtf_op_prepare_multicast(struct ieee80211_hw *hw,
-				     int mc_count, struct dev_addr_list *mclist)
+				     struct netdev_hw_addr_list *mc_list)
 {
 	struct lbtf_private *priv = hw->priv;
 	int i;
+	struct netdev_hw_addr *ha;
+	int mc_count = netdev_hw_addr_list_count(mc_list);
 
 	if (!mc_count || mc_count > MRVDRV_MAX_MULTICAST_LIST_SIZE)
 		return mc_count;
 
 	priv->nr_of_multicastmacaddr = mc_count;
-	for (i = 0; i < mc_count; i++) {
-		if (!mclist)
-			break;
-		memcpy(&priv->multicastlist[i], mclist->da_addr,
-				ETH_ALEN);
-		mclist = mclist->next;
-	}
+	i = 0;
+	netdev_hw_addr_list_for_each(ha, mc_list)
+		memcpy(&priv->multicastlist[i++], ha->addr, ETH_ALEN);
 
 	return mc_count;
 }
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index ac65e13..6599fd1 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -1938,11 +1938,15 @@ struct mwl8k_cmd_mac_multicast_adr {
 
 static struct mwl8k_cmd_pkt *
 __mwl8k_cmd_mac_multicast_adr(struct ieee80211_hw *hw, int allmulti,
-			      int mc_count, struct dev_addr_list *mclist)
+			      struct netdev_hw_addr_list *mc_list)
 {
 	struct mwl8k_priv *priv = hw->priv;
 	struct mwl8k_cmd_mac_multicast_adr *cmd;
 	int size;
+	int mc_count = 0;
+
+	if (mc_list)
+		mc_count = netdev_hw_addr_list_count(mc_list);
 
 	if (allmulti || mc_count > priv->num_mcaddrs) {
 		allmulti = 1;
@@ -1963,17 +1967,13 @@ __mwl8k_cmd_mac_multicast_adr(struct ieee80211_hw *hw, int allmulti,
 	if (allmulti) {
 		cmd->action |= cpu_to_le16(MWL8K_ENABLE_RX_ALL_MULTICAST);
 	} else if (mc_count) {
-		int i;
+		struct netdev_hw_addr *ha;
+		int i = 0;
 
 		cmd->action |= cpu_to_le16(MWL8K_ENABLE_RX_MULTICAST);
 		cmd->numaddr = cpu_to_le16(mc_count);
-		for (i = 0; i < mc_count && mclist; i++) {
-			if (mclist->da_addrlen != ETH_ALEN) {
-				kfree(cmd);
-				return NULL;
-			}
-			memcpy(cmd->addr[i], mclist->da_addr, ETH_ALEN);
-			mclist = mclist->next;
+		netdev_hw_addr_list_for_each(ha, mc_list) {
+			memcpy(cmd->addr[i], ha->addr, ETH_ALEN);
 		}
 	}
 
@@ -3552,7 +3552,7 @@ mwl8k_bss_info_changed(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 }
 
 static u64 mwl8k_prepare_multicast(struct ieee80211_hw *hw,
-				   int mc_count, struct dev_addr_list *mclist)
+				   struct netdev_hw_addr_list *mc_list)
 {
 	struct mwl8k_cmd_pkt *cmd;
 
@@ -3563,7 +3563,7 @@ static u64 mwl8k_prepare_multicast(struct ieee80211_hw *hw,
 	 * we'll end up throwing this packet away and creating a new
 	 * one in mwl8k_configure_filter().
 	 */
-	cmd = __mwl8k_cmd_mac_multicast_adr(hw, 0, mc_count, mclist);
+	cmd = __mwl8k_cmd_mac_multicast_adr(hw, 0, mc_list);
 
 	return (unsigned long)cmd;
 }
@@ -3686,7 +3686,7 @@ static void mwl8k_configure_filter(struct ieee80211_hw *hw,
 	 */
 	if (*total_flags & FIF_ALLMULTI) {
 		kfree(cmd);
-		cmd = __mwl8k_cmd_mac_multicast_adr(hw, 1, 0, NULL);
+		cmd = __mwl8k_cmd_mac_multicast_adr(hw, 1, NULL);
 	}
 
 	if (cmd != NULL) {
diff --git a/drivers/net/wireless/orinoco/hw.c b/drivers/net/wireless/orinoco/hw.c
index 883b8f8..9f657af 100644
--- a/drivers/net/wireless/orinoco/hw.c
+++ b/drivers/net/wireless/orinoco/hw.c
@@ -1056,14 +1056,14 @@ int __orinoco_hw_set_multicast_list(struct orinoco_private *priv,
 	 * group address if either we want to multicast, or if we were
 	 * multicasting and want to stop */
 	if (!promisc && (mc_count || priv->mc_count)) {
-		struct dev_mc_list *p;
+		struct netdev_hw_addr *ha;
 		struct hermes_multicast mclist;
 		int i = 0;
 
-		netdev_for_each_mc_addr(p, dev) {
+		netdev_for_each_mc_addr(ha, dev) {
 			if (i == mc_count)
 				break;
-			memcpy(mclist.addr[i++], p->dmi_addr, ETH_ALEN);
+			memcpy(mclist.addr[i++], ha->addr, ETH_ALEN);
 		}
 
 		err = hermes_write_ltv(hw, USER_BAP,
diff --git a/drivers/net/wireless/orinoco/hw.h b/drivers/net/wireless/orinoco/hw.h
index 9799a1d..97af71e 100644
--- a/drivers/net/wireless/orinoco/hw.h
+++ b/drivers/net/wireless/orinoco/hw.h
@@ -22,7 +22,6 @@
 
 /* Forward declarations */
 struct orinoco_private;
-struct dev_addr_list;
 
 int determine_fw_capabilities(struct orinoco_private *priv, char *fw_name,
 			      size_t fw_name_len, u32 *hw_ver);
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 4f5bdb5..54680a3 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -1875,17 +1875,17 @@ static void ray_update_multi_list(struct net_device *dev, int all)
 		writeb(0xff, &pccs->var);
 		local->num_multi = 0xff;
 	} else {
-		struct dev_mc_list *dmi;
+		struct netdev_hw_addr *ha;
 		int i = 0;
 
 		/* Copy the kernel's list of MC addresses to card */
-		netdev_for_each_mc_addr(dmi, dev) {
-			memcpy_toio(p, dmi->dmi_addr, ETH_ALEN);
+		netdev_for_each_mc_addr(ha, dev) {
+			memcpy_toio(p, ha->addr, ETH_ALEN);
 			dev_dbg(&link->dev,
 			      "ray_update_multi add addr %02x%02x%02x%02x%02x%02x\n",
-			      dmi->dmi_addr[0], dmi->dmi_addr[1],
-			      dmi->dmi_addr[2], dmi->dmi_addr[3],
-			      dmi->dmi_addr[4], dmi->dmi_addr[5]);
+			      ha->addr[0], ha->addr[1],
+			      ha->addr[2], ha->addr[3],
+			      ha->addr[4], ha->addr[5]);
 			p += ETH_ALEN;
 			i++;
 		}
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index aceb95e..8ab9f09 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -1545,7 +1545,7 @@ static int remove_key(struct usbnet *usbdev, int index, const u8 *bssid)
 static void set_multicast_list(struct usbnet *usbdev)
 {
 	struct rndis_wlan_private *priv = get_rndis_wlan_priv(usbdev);
-	struct dev_mc_list *mclist;
+	struct netdev_hw_addr *ha;
 	__le32 filter, basefilter;
 	int ret;
 	char *mc_addrs = NULL;
@@ -1584,9 +1584,9 @@ static void set_multicast_list(struct usbnet *usbdev)
 			return;
 		}
 
-		netdev_for_each_mc_addr(mclist, usbdev->net)
+		netdev_for_each_mc_addr(ha, usbdev->net)
 			memcpy(mc_addrs + i++ * ETH_ALEN,
-			       mclist->dmi_addr, ETH_ALEN);
+			       ha->addr, ETH_ALEN);
 	}
 	netif_addr_unlock_bh(usbdev->net);
 
diff --git a/drivers/net/wireless/rtl818x/rtl8180_dev.c b/drivers/net/wireless/rtl818x/rtl8180_dev.c
index 2b928ec..fb8a62f 100644
--- a/drivers/net/wireless/rtl818x/rtl8180_dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8180_dev.c
@@ -723,10 +723,10 @@ static void rtl8180_bss_info_changed(struct ieee80211_hw *dev,
 	        priv->rf->conf_erp(dev, info);
 }
 
-static u64 rtl8180_prepare_multicast(struct ieee80211_hw *dev, int mc_count,
-				     struct dev_addr_list *mc_list)
+static u64 rtl8180_prepare_multicast(struct ieee80211_hw *dev,
+				     struct netdev_hw_addr_list *mc_list)
 {
-	return mc_count;
+	return netdev_hw_addr_list_count(mc_list);
 }
 
 static void rtl8180_configure_filter(struct ieee80211_hw *dev,
diff --git a/drivers/net/wireless/rtl818x/rtl8187_dev.c b/drivers/net/wireless/rtl818x/rtl8187_dev.c
index 0fb850e..441d817 100644
--- a/drivers/net/wireless/rtl818x/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8187_dev.c
@@ -1193,9 +1193,9 @@ static void rtl8187_bss_info_changed(struct ieee80211_hw *dev,
 }
 
 static u64 rtl8187_prepare_multicast(struct ieee80211_hw *dev,
-				     int mc_count, struct dev_addr_list *mc_list)
+				     struct netdev_hw_addr_list *mc_list)
 {
-	return mc_count;
+	return netdev_hw_addr_list_count(mc_list);
 }
 
 static void rtl8187_configure_filter(struct ieee80211_hw *dev,
diff --git a/drivers/net/wireless/wl12xx/wl1271_main.c b/drivers/net/wireless/wl12xx/wl1271_main.c
index 3daba6c..6036d02 100644
--- a/drivers/net/wireless/wl12xx/wl1271_main.c
+++ b/drivers/net/wireless/wl12xx/wl1271_main.c
@@ -1266,11 +1266,11 @@ struct wl1271_filter_params {
 	u8 mc_list[ACX_MC_ADDRESS_GROUP_MAX][ETH_ALEN];
 };
 
-static u64 wl1271_op_prepare_multicast(struct ieee80211_hw *hw, int mc_count,
-				       struct dev_addr_list *mc_list)
+static u64 wl1271_op_prepare_multicast(struct ieee80211_hw *hw,
+				       struct netdev_hw_addr_list *mc_list)
 {
 	struct wl1271_filter_params *fp;
-	int i;
+	struct netdev_hw_addr *ha;
 
 	fp = kzalloc(sizeof(*fp), GFP_ATOMIC);
 	if (!fp) {
@@ -1279,21 +1279,16 @@ static u64 wl1271_op_prepare_multicast(struct ieee80211_hw *hw, int mc_count,
 	}
 
 	/* update multicast filtering parameters */
-	fp->enabled = true;
-	if (mc_count > ACX_MC_ADDRESS_GROUP_MAX) {
-		mc_count = 0;
-		fp->enabled = false;
-	}
-
 	fp->mc_list_length = 0;
-	for (i = 0; i < mc_count; i++) {
-		if (mc_list->da_addrlen == ETH_ALEN) {
+	if (netdev_hw_addr_list_count(mc_list) > ACX_MC_ADDRESS_GROUP_MAX) {
+		fp->enabled = false;
+	} else {
+		fp->enabled = true;
+		netdev_hw_addr_list_for_each(ha, mc_list) {
 			memcpy(fp->mc_list[fp->mc_list_length],
-			       mc_list->da_addr, ETH_ALEN);
+					ha->addr, ETH_ALEN);
 			fp->mc_list_length++;
-		} else
-			wl1271_warning("Unknown mc address length.");
-		mc_list = mc_list->next;
+		}
 	}
 
 	return (u64)(unsigned long)fp;
diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index 6917286..74530b2 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -875,7 +875,7 @@ static struct iw_statistics *zd1201_get_wireless_stats(struct net_device *dev)
 static void zd1201_set_multicast(struct net_device *dev)
 {
 	struct zd1201 *zd = netdev_priv(dev);
-	struct dev_mc_list *mc;
+	struct netdev_hw_addr *ha;
 	unsigned char reqbuf[ETH_ALEN*ZD1201_MAXMULTI];
 	int i;
 
@@ -883,8 +883,8 @@ static void zd1201_set_multicast(struct net_device *dev)
 		return;
 
 	i = 0;
-	netdev_for_each_mc_addr(mc, dev)
-		memcpy(reqbuf + i++ * ETH_ALEN, mc->dmi_addr, ETH_ALEN);
+	netdev_for_each_mc_addr(ha, dev)
+		memcpy(reqbuf + i++ * ETH_ALEN, ha->addr, ETH_ALEN);
 	zd1201_setconfig(zd, ZD1201_RID_CNFGROUPADDRESS, reqbuf,
 			 netdev_mc_count(dev) * ETH_ALEN, 0);
 }
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index 00e09e2..6d95e4d 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -947,20 +947,17 @@ static void set_rx_filter_handler(struct work_struct *work)
 }
 
 static u64 zd_op_prepare_multicast(struct ieee80211_hw *hw,
-				   int mc_count, struct dev_addr_list *mclist)
+				   struct netdev_hw_addr_list *mc_list)
 {
 	struct zd_mac *mac = zd_hw_mac(hw);
 	struct zd_mc_hash hash;
-	int i;
+	struct netdev_hw_addr *ha;
 
 	zd_mc_clear(&hash);
 
-	for (i = 0; i < mc_count; i++) {
-		if (!mclist)
-			break;
-		dev_dbg_f(zd_mac_dev(mac), "mc addr %pM\n", mclist->dmi_addr);
-		zd_mc_add_addr(&hash, mclist->dmi_addr);
-		mclist = mclist->next;
+	netdev_hw_addr_list_for_each(ha, mc_list) {
+		dev_dbg_f(zd_mac_dev(mac), "mc addr %pM\n", ha->addr);
+		zd_mc_add_addr(&hash, ha->addr);
 	}
 
 	return hash.low | ((u64)hash.high << 32);
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index 7d4107f..34c91cf 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -1300,25 +1300,25 @@ static void set_rx_mode(struct net_device *dev)
 		/* Too many to filter well, or accept all multicasts. */
 		iowrite16(0x000B, ioaddr + AddrMode);
 	} else if (!netdev_mc_empty(dev)) { /* Must use the multicast hash table. */
-		struct dev_mc_list *mclist;
+		struct netdev_hw_addr *ha;
 		u16 hash_table[4];
 		int i;
 
 		memset(hash_table, 0, sizeof(hash_table));
-		netdev_for_each_mc_addr(mclist, dev) {
+		netdev_for_each_mc_addr(ha, dev) {
 			unsigned int bit;
 
 			/* Due to a bug in the early chip versions, multiple filter
 			   slots must be set for each address. */
 			if (yp->drv_flags & HasMulticastBug) {
-				bit = (ether_crc_le(3, mclist->dmi_addr) >> 3) & 0x3f;
+				bit = (ether_crc_le(3, ha->addr) >> 3) & 0x3f;
 				hash_table[bit >> 4] |= (1 << bit);
-				bit = (ether_crc_le(4, mclist->dmi_addr) >> 3) & 0x3f;
+				bit = (ether_crc_le(4, ha->addr) >> 3) & 0x3f;
 				hash_table[bit >> 4] |= (1 << bit);
-				bit = (ether_crc_le(5, mclist->dmi_addr) >> 3) & 0x3f;
+				bit = (ether_crc_le(5, ha->addr) >> 3) & 0x3f;
 				hash_table[bit >> 4] |= (1 << bit);
 			}
-			bit = (ether_crc_le(6, mclist->dmi_addr) >> 3) & 0x3f;
+			bit = (ether_crc_le(6, ha->addr) >> 3) & 0x3f;
 			hash_table[bit >> 4] |= (1 << bit);
 		}
 		/* Copy the hash table to the chip. */
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 7576ad5..945f3e0 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -607,7 +607,6 @@ static int qeth_l2_set_mac_address(struct net_device *dev, void *p)
 static void qeth_l2_set_multicast_list(struct net_device *dev)
 {
 	struct qeth_card *card = dev->ml_priv;
-	struct dev_addr_list *dm;
 	struct netdev_hw_addr *ha;
 
 	if (card->info.type == QETH_CARD_TYPE_OSN)
@@ -619,8 +618,8 @@ static void qeth_l2_set_multicast_list(struct net_device *dev)
 		return;
 	qeth_l2_del_all_mc(card);
 	spin_lock_bh(&card->mclock);
-	netdev_for_each_mc_addr(dm, dev)
-		qeth_l2_add_mc(card, dm->da_addr, 0);
+	netdev_for_each_mc_addr(ha, dev)
+		qeth_l2_add_mc(card, ha->addr, 0);
 
 	netdev_for_each_uc_addr(ha, dev)
 		qeth_l2_add_mc(card, ha->addr, 1);
diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index de33e38..37de40e 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -311,7 +311,7 @@ static int fcoe_interface_setup(struct fcoe_interface *fcoe,
 	dev_uc_add(netdev, flogi_maddr);
 	if (fip->spma)
 		dev_uc_add(netdev, fip->ctl_src_addr);
-	dev_mc_add(netdev, FIP_ALL_ENODE_MACS, ETH_ALEN, 0);
+	dev_mc_add(netdev, FIP_ALL_ENODE_MACS);
 
 	/*
 	 * setup the receive function from ethernet driver
@@ -397,7 +397,7 @@ void fcoe_interface_cleanup(struct fcoe_interface *fcoe)
 	dev_uc_del(netdev, flogi_maddr);
 	if (fip->spma)
 		dev_uc_del(netdev, fip->ctl_src_addr);
-	dev_mc_delete(netdev, FIP_ALL_ENODE_MACS, ETH_ALEN, 0);
+	dev_mc_del(netdev, FIP_ALL_ENODE_MACS);
 
 	/* Tell the LLD we are done w/ FCoE */
 	ops = netdev->netdev_ops;
diff --git a/drivers/staging/arlan/arlan-main.c b/drivers/staging/arlan/arlan-main.c
index 88fdd53..8028452 100644
--- a/drivers/staging/arlan/arlan-main.c
+++ b/drivers/staging/arlan/arlan-main.c
@@ -1458,7 +1458,7 @@ static void arlan_rx_interrupt(struct net_device *dev, u_char rxStatus, u_short
 				!netdev_mc_empty(dev))
 			{
 				char hw_dst_addr[6];
-				struct dev_mc_list *dmi;
+				struct netdev_hw_addr *ha;
 				int i;
 
 				memcpy_fromio(hw_dst_addr, arlan->ultimateDestAddress, 6);
@@ -1469,12 +1469,13 @@ static void arlan_rx_interrupt(struct net_device *dev, u_char rxStatus, u_short
 							printk(KERN_ERR "%s mcast 0x0100 \n", dev->name);
 						else if (hw_dst_addr[1] == 0x40)
 							printk(KERN_ERR "%s m/bcast 0x0140 \n", dev->name);
-					netdev_for_each_mc_entry(dmi, dev) {
+					netdev_for_each_mc_entry(ha, dev) {
 						if (arlan_debug & ARLAN_DEBUG_HEADER_DUMP)
 							printk(KERN_ERR "%s mcl %pM\n",
-							       dev->name, dmi->dmi_addr);
+							       dev->name,
+							       ha->addr);
 						for (i = 0; i < 6; i++)
-							if (dmi->dmi_addr[i] != hw_dst_addr[i])
+							if (ha->addr[i] != hw_dst_addr[i])
 								break;
 						if (i == 6)
 							break;
diff --git a/drivers/staging/et131x/et131x_netdev.c b/drivers/staging/et131x/et131x_netdev.c
index 40f8954..2fb89cd 100644
--- a/drivers/staging/et131x/et131x_netdev.c
+++ b/drivers/staging/et131x/et131x_netdev.c
@@ -405,7 +405,7 @@ void et131x_multicast(struct net_device *netdev)
 	struct et131x_adapter *adapter = netdev_priv(netdev);
 	uint32_t PacketFilter = 0;
 	unsigned long flags;
-	struct dev_mc_list *mclist;
+	struct netdev_hw_addr *ha;
 	int i;
 
 	spin_lock_irqsave(&adapter->Lock, flags);
@@ -450,10 +450,10 @@ void et131x_multicast(struct net_device *netdev)
 
 	/* Set values in the private adapter struct */
 	i = 0;
-	netdev_for_each_mc_addr(mclist, netdev) {
+	netdev_for_each_mc_addr(ha, netdev) {
 		if (i == NIC_MAX_MCAST_LIST)
 			break;
-		memcpy(adapter->MCList[i++], mclist->dmi_addr, ETH_ALEN);
+		memcpy(adapter->MCList[i++], ha->addr, ETH_ALEN);
 	}
 	adapter->MCAddressCount = i;
 
diff --git a/drivers/staging/slicoss/slicoss.c b/drivers/staging/slicoss/slicoss.c
index 7daeced..bebf0fd 100644
--- a/drivers/staging/slicoss/slicoss.c
+++ b/drivers/staging/slicoss/slicoss.c
@@ -1367,12 +1367,12 @@ static void slic_mcast_set_list(struct net_device *dev)
 	struct adapter *adapter = netdev_priv(dev);
 	int status = STATUS_SUCCESS;
 	char *addresses;
-	struct dev_mc_list *mc_list;
+	struct netdev_hw_addr *ha;
 
 	ASSERT(adapter);
 
-	netdev_for_each_mc_addr(mc_list, dev) {
-		addresses = (char *) &mc_list->dmi_addr;
+	netdev_for_each_mc_addr(ha, dev) {
+		addresses = (char *) &ha->addr;
 		status = slic_mcast_add_list(adapter, addresses);
 		if (status != STATUS_SUCCESS)
 			break;
diff --git a/drivers/staging/vt6655/device_main.c b/drivers/staging/vt6655/device_main.c
index 1d64365..b698de4 100644
--- a/drivers/staging/vt6655/device_main.c
+++ b/drivers/staging/vt6655/device_main.c
@@ -3079,7 +3079,7 @@ static void device_set_multi(struct net_device *dev) {
 
     PSMgmtObject     pMgmt = pDevice->pMgmt;
     u32              mc_filter[2];
-    struct dev_mc_list *mclist;
+    struct netdev_hw_addr *ha;
 
 
     VNSvInPortB(pDevice->PortOffset + MAC_REG_RCR, &(pDevice->byRxMode));
@@ -3099,8 +3099,8 @@ static void device_set_multi(struct net_device *dev) {
     }
     else {
         memset(mc_filter, 0, sizeof(mc_filter));
-	netdev_for_each_mc_addr(mclist, dev) {
-            int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
+	netdev_for_each_mc_addr(ha, dev) {
+            int bit_nr = ether_crc(ETH_ALEN, ha->addr) >> 26;
             mc_filter[bit_nr >> 5] |= cpu_to_le32(1 << (bit_nr & 31));
         }
         MACvSelectPage1(pDevice->PortOffset);
diff --git a/drivers/staging/vt6656/main_usb.c b/drivers/staging/vt6656/main_usb.c
index a8e1adb..49270db 100644
--- a/drivers/staging/vt6656/main_usb.c
+++ b/drivers/staging/vt6656/main_usb.c
@@ -1596,7 +1596,7 @@ static void device_set_multi(struct net_device *dev) {
     PSMgmtObject     pMgmt = &(pDevice->sMgmtObj);
     u32              mc_filter[2];
     int              ii;
-    struct dev_mc_list *mclist;
+    struct netdev_hw_addr *ha;
     BYTE             pbyData[8] = {0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff};
     BYTE             byTmpMode = 0;
     int              rc;
@@ -1632,8 +1632,8 @@ static void device_set_multi(struct net_device *dev) {
     }
     else {
         memset(mc_filter, 0, sizeof(mc_filter));
-	netdev_for_each_mc_addr(mclist, dev) {
-            int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
+	netdev_for_each_mc_addr(ha, dev) {
+            int bit_nr = ether_crc(ETH_ALEN, ha->addr) >> 26;
             mc_filter[bit_nr >> 5] |= cpu_to_le32(1 << (bit_nr & 31));
         }
         for (ii = 0; ii < 4; ii++) {
diff --git a/drivers/staging/wavelan/wavelan.c b/drivers/staging/wavelan/wavelan.c
index 54ca631..f44ef35 100644
--- a/drivers/staging/wavelan/wavelan.c
+++ b/drivers/staging/wavelan/wavelan.c
@@ -3419,7 +3419,7 @@ static void wv_82586_config(struct net_device * dev)
 	ac_cfg_t cfg;		/* Configure action */
 	ac_ias_t ias;		/* IA-setup action */
 	ac_mcs_t mcs;		/* Multicast setup */
-	struct dev_mc_list *dmi;
+	struct netdev_hw_addr *ha;
 
 #ifdef DEBUG_CONFIG_TRACE
 	printk(KERN_DEBUG "%s: ->wv_82586_config()\n", dev->name);
@@ -3531,16 +3531,16 @@ static void wv_82586_config(struct net_device * dev)
 
 	/* Any address to set? */
 	if (lp->mc_count) {
-		netdev_for_each_mc_addr(dmi, dev)
-			outsw(PIOP1(ioaddr), (u16 *) dmi->dmi_addr,
+		netdev_for_each_mc_addr(ha, dev)
+			outsw(PIOP1(ioaddr), (u16 *) ha->addr,
 			      WAVELAN_ADDR_SIZE >> 1);
 
 #ifdef DEBUG_CONFIG_INFO
 		printk(KERN_DEBUG
 		       "%s: wv_82586_config(): set %d multicast addresses:\n",
 		       dev->name, lp->mc_count);
-		netdev_for_each_mc_addr(dmi, dev)
-			printk(KERN_DEBUG " %pM\n", dmi->dmi_addr);
+		netdev_for_each_mc_addr(ha, dev)
+			printk(KERN_DEBUG " %pM\n", ha->addr);
 #endif
 	}
 
diff --git a/drivers/staging/wavelan/wavelan_cs.c b/drivers/staging/wavelan/wavelan_cs.c
index 04f691d..a90132a 100644
--- a/drivers/staging/wavelan/wavelan_cs.c
+++ b/drivers/staging/wavelan/wavelan_cs.c
@@ -3591,20 +3591,20 @@ wv_82593_config(struct net_device *	dev)
     /* If roaming is enabled, join the "Beacon Request" multicast group... */
     /* But only if it's not in there already! */
   if(do_roaming)
-    dev_mc_add(dev,WAVELAN_BEACON_ADDRESS, WAVELAN_ADDR_SIZE, 1);
+    dev_mc_add(dev, WAVELAN_BEACON_ADDRESS);
 #endif	/* WAVELAN_ROAMING */
 
   /* If any multicast address to set */
   if(lp->mc_count)
     {
-      struct dev_mc_list *dmi;
+      struct netdev_hw_addr *ha;
       int			addrs_len = WAVELAN_ADDR_SIZE * lp->mc_count;
 
 #ifdef DEBUG_CONFIG_INFO
       printk(KERN_DEBUG "%s: wv_hw_config(): set %d multicast addresses:\n",
 	     dev->name, lp->mc_count);
-      netdev_for_each_mc_addr(dmi, dev)
-	printk(KERN_DEBUG " %pM\n", dmi->dmi_addr);
+      netdev_for_each_mc_addr(ha, dev)
+	printk(KERN_DEBUG " %pM\n", ha->addr);
 #endif
 
       /* Initialize adapter's ethernet multicast addresses */
@@ -3612,8 +3612,8 @@ wv_82593_config(struct net_device *	dev)
       outb(((TX_BASE >> 8) & PIORH_MASK) | PIORH_SEL_TX, PIORH(base));
       outb(addrs_len & 0xff, PIOP(base));	/* byte count lsb */
       outb((addrs_len >> 8), PIOP(base));	/* byte count msb */
-      netdev_for_each_mc_addr(dmi, dev)
-	outsb(PIOP(base), dmi->dmi_addr, dmi->dmi_addrlen);
+      netdev_for_each_mc_addr(ha, dev)
+	outsb(PIOP(base), ha->addr, dev->addr_len);
 
       /* reset transmit DMA pointer */
       hacr_write_slow(base, HACR_PWR_STAT | HACR_TX_DMA_RESET);
diff --git a/drivers/staging/winbond/wbusb.c b/drivers/staging/winbond/wbusb.c
index 3482eec..5d9499b 100644
--- a/drivers/staging/winbond/wbusb.c
+++ b/drivers/staging/winbond/wbusb.c
@@ -92,10 +92,10 @@ static int wbsoft_get_stats(struct ieee80211_hw *hw,
 	return 0;
 }
 
-static u64 wbsoft_prepare_multicast(struct ieee80211_hw *hw, int mc_count,
-				    struct dev_addr_list *mc_list)
+static u64 wbsoft_prepare_multicast(struct ieee80211_hw *hw,
+				    struct netdev_hw_addr_list *mc_list)
 {
-	return mc_count;
+	return netdev_hw_addr_list_count(mc_list);
 }
 
 static void wbsoft_configure_filter(struct ieee80211_hw *dev,
diff --git a/drivers/staging/wlags49_h2/wl_netdev.c b/drivers/staging/wlags49_h2/wl_netdev.c
index fa082d9..d7532e8 100644
--- a/drivers/staging/wlags49_h2/wl_netdev.c
+++ b/drivers/staging/wlags49_h2/wl_netdev.c
@@ -1049,7 +1049,7 @@ void wl_multicast( struct net_device *dev )
 //;?seems reasonable that even an AP-only driver could afford this small additional footprint
 
     int                 x;
-    struct dev_mc_list *mclist;
+    struct netdev_hw_addr *ha;
     struct wl_private   *lp = wl_priv(dev);
     unsigned long       flags;
     /*------------------------------------------------------------------------*/
@@ -1072,9 +1072,9 @@ void wl_multicast( struct net_device *dev )
 
         DBG_PRINT( "  mc_count: %d\n", netdev_mc_count(dev));
 
-	netdev_for_each_mc_addr(mclist, dev)
-            DBG_PRINT( "    %s (%d)\n", DbgHwAddr(mclist->dmi_addr),
-                       mclist->dmi_addrlen );
+	netdev_for_each_mc_addr(ha, dev)
+            DBG_PRINT("    %s (%d)\n", DbgHwAddr(ha->addr),
+		      dev->addr_len);
     }
 #endif /* DBG */
 
@@ -1119,9 +1119,9 @@ void wl_multicast( struct net_device *dev )
                 lp->ltvRecord.typ = CFG_GROUP_ADDR;
 
 		x = 0;
-		netdev_for_each_mc_addr(mclist, dev)
+		netdev_for_each_mc_addr(ha, dev)
                     memcpy(&(lp->ltvRecord.u.u8[x++ * ETH_ALEN]),
-                           mclist->dmi_addr, ETH_ALEN);
+			   ha->addr, ETH_ALEN);
                 DBG_PRINT( "Setting multicast list\n" );
                 hcf_put_info( &( lp->hcfCtx ), (LTVP)&( lp->ltvRecord ));
             } else {
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 60f0c83..a343a21 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -228,25 +228,6 @@ struct netif_rx_stats {
 
 DECLARE_PER_CPU(struct netif_rx_stats, netdev_rx_stat);
 
-struct dev_addr_list {
-	struct dev_addr_list	*next;
-	u8			da_addr[MAX_ADDR_LEN];
-	u8			da_addrlen;
-	u8			da_synced;
-	int			da_users;
-	int			da_gusers;
-};
-
-/*
- *	We tag multicasts with these structures.
- */
-
-#define dev_mc_list	dev_addr_list
-#define dmi_addr	da_addr
-#define dmi_addrlen	da_addrlen
-#define dmi_users	da_users
-#define dmi_gusers	da_gusers
-
 struct netdev_hw_addr {
 	struct list_head	list;
 	unsigned char		addr[MAX_ADDR_LEN];
@@ -255,8 +236,10 @@ struct netdev_hw_addr {
 #define NETDEV_HW_ADDR_T_SAN		2
 #define NETDEV_HW_ADDR_T_SLAVE		3
 #define NETDEV_HW_ADDR_T_UNICAST	4
+#define NETDEV_HW_ADDR_T_MULTICAST	5
 	int			refcount;
 	bool			synced;
+	bool			global_use;
 	struct rcu_head		rcu_head;
 };
 
@@ -265,16 +248,20 @@ struct netdev_hw_addr_list {
 	int			count;
 };
 
-#define netdev_uc_count(dev) ((dev)->uc.count)
-#define netdev_uc_empty(dev) ((dev)->uc.count == 0)
-#define netdev_for_each_uc_addr(ha, dev) \
-	list_for_each_entry(ha, &dev->uc.list, list)
+#define netdev_hw_addr_list_count(l) ((l)->count)
+#define netdev_hw_addr_list_empty(l) (netdev_hw_addr_list_count(l) == 0)
+#define netdev_hw_addr_list_for_each(ha, l) \
+	list_for_each_entry(ha, &(l)->list, list)
 
-#define netdev_mc_count(dev) ((dev)->mc_count)
-#define netdev_mc_empty(dev) (netdev_mc_count(dev) == 0)
+#define netdev_uc_count(dev) netdev_hw_addr_list_count(&(dev)->uc)
+#define netdev_uc_empty(dev) netdev_hw_addr_list_empty(&(dev)->uc)
+#define netdev_for_each_uc_addr(ha, dev) \
+	netdev_hw_addr_list_for_each(ha, &(dev)->uc)
 
+#define netdev_mc_count(dev) netdev_hw_addr_list_count(&(dev)->mc)
+#define netdev_mc_empty(dev) netdev_hw_addr_list_empty(&(dev)->mc)
 #define netdev_for_each_mc_addr(mclist, dev) \
-	for (mclist = dev->mc_list; mclist; mclist = mclist->next)
+	netdev_hw_addr_list_for_each(ha, &(dev)->mc)
 
 struct hh_cache {
 	struct hh_cache *hh_next;	/* Next entry			     */
@@ -862,12 +849,10 @@ struct net_device {
 	unsigned char		addr_len;	/* hardware address length	*/
 	unsigned short          dev_id;		/* for shared network cards */
 
-	struct netdev_hw_addr_list	uc;	/* Secondary unicast
-						   mac addresses */
-	int			uc_promisc;
 	spinlock_t		addr_list_lock;
-	struct dev_addr_list	*mc_list;	/* Multicast mac addresses	*/
-	int			mc_count;	/* Number of installed mcasts	*/
+	struct netdev_hw_addr_list	uc;	/* Unicast mac addresses */
+	struct netdev_hw_addr_list	mc;	/* Multicast mac addresses */
+	int			uc_promisc;
 	unsigned int		promiscuity;
 	unsigned int		allmulti;
 
@@ -1980,6 +1965,22 @@ extern struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 extern int		register_netdev(struct net_device *dev);
 extern void		unregister_netdev(struct net_device *dev);
 
+/* General hardware address lists handling functions */
+extern int __hw_addr_add_multiple(struct netdev_hw_addr_list *to_list,
+				  struct netdev_hw_addr_list *from_list,
+				  int addr_len, unsigned char addr_type);
+extern void __hw_addr_del_multiple(struct netdev_hw_addr_list *to_list,
+				   struct netdev_hw_addr_list *from_list,
+				   int addr_len, unsigned char addr_type);
+extern int __hw_addr_sync(struct netdev_hw_addr_list *to_list,
+			  struct netdev_hw_addr_list *from_list,
+			  int addr_len);
+extern void __hw_addr_unsync(struct netdev_hw_addr_list *to_list,
+			     struct netdev_hw_addr_list *from_list,
+			     int addr_len);
+extern void __hw_addr_flush(struct netdev_hw_addr_list *list);
+extern void __hw_addr_init(struct netdev_hw_addr_list *list);
+
 /* Functions used for device addresses handling */
 extern int dev_addr_add(struct net_device *dev, unsigned char *addr,
 			unsigned char addr_type);
@@ -2002,18 +2003,19 @@ extern void dev_uc_unsync(struct net_device *to, struct net_device *from);
 extern void dev_uc_flush(struct net_device *dev);
 extern void dev_uc_init(struct net_device *dev);
 
+/* Functions used for multicast addresses handling */
+extern int dev_mc_add(struct net_device *dev, unsigned char *addr);
+extern int dev_mc_add_global(struct net_device *dev, unsigned char *addr);
+extern int dev_mc_del(struct net_device *dev, unsigned char *addr);
+extern int dev_mc_del_global(struct net_device *dev, unsigned char *addr);
+extern int dev_mc_sync(struct net_device *to, struct net_device *from);
+extern void dev_mc_unsync(struct net_device *to, struct net_device *from);
+extern void dev_mc_flush(struct net_device *dev);
+extern void dev_mc_init(struct net_device *dev);
+
 /* Functions used for secondary unicast and multicast support */
 extern void		dev_set_rx_mode(struct net_device *dev);
 extern void		__dev_set_rx_mode(struct net_device *dev);
-extern int 		dev_mc_delete(struct net_device *dev, void *addr, int alen, int all);
-extern int		dev_mc_add(struct net_device *dev, void *addr, int alen, int newonly);
-extern int		dev_mc_sync(struct net_device *to, struct net_device *from);
-extern void		dev_mc_unsync(struct net_device *to, struct net_device *from);
-extern void		dev_addr_discard(struct net_device *dev);
-extern int 		__dev_addr_delete(struct dev_addr_list **list, int *count, void *addr, int alen, int all);
-extern int		__dev_addr_add(struct dev_addr_list **list, int *count, void *addr, int alen, int newonly);
-extern int		__dev_addr_sync(struct dev_addr_list **to, int *to_count, struct dev_addr_list **from, int *from_count);
-extern void		__dev_addr_unsync(struct dev_addr_list **to, int *to_count, struct dev_addr_list **from, int *from_count);
 extern int		dev_set_promiscuity(struct net_device *dev, int inc);
 extern int		dev_set_allmulti(struct net_device *dev, int inc);
 extern void		netdev_state_change(struct net_device *dev);
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 1a8f50a..20823d0 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -1626,7 +1626,7 @@ struct ieee80211_ops {
 				 struct ieee80211_bss_conf *info,
 				 u32 changed);
 	u64 (*prepare_multicast)(struct ieee80211_hw *hw,
-				 int mc_count, struct dev_addr_list *mc_list);
+				 struct netdev_hw_addr_list *mc_list);
 	void (*configure_filter)(struct ieee80211_hw *hw,
 				 unsigned int changed_flags,
 				 unsigned int *total_flags,
diff --git a/net/802/garp.c b/net/802/garp.c
index 1dcb066..78cff9e 100644
--- a/net/802/garp.c
+++ b/net/802/garp.c
@@ -575,7 +575,7 @@ int garp_init_applicant(struct net_device *dev, struct garp_application *appl)
 	if (!app)
 		goto err2;
 
-	err = dev_mc_add(dev, appl->proto.group_address, ETH_ALEN, 0);
+	err = dev_mc_add(dev, appl->proto.group_address);
 	if (err < 0)
 		goto err3;
 
@@ -615,7 +615,7 @@ void garp_uninit_applicant(struct net_device *dev, struct garp_application *appl
 	garp_pdu_queue(app);
 	garp_queue_xmit(app);
 
-	dev_mc_delete(dev, appl->proto.group_address, ETH_ALEN, 0);
+	dev_mc_del(dev, appl->proto.group_address);
 	kfree(app);
 	garp_release_port(dev);
 }
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 9fc4da5..1d15a60 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -781,7 +781,7 @@ static int atif_ioctl(int cmd, void __user *arg)
 						atrtr_create(&rtdef, dev);
 					}
 			}
-			dev_mc_add(dev, aarp_mcast, 6, 1);
+			dev_mc_add_global(dev, aarp_mcast);
 			return 0;
 
 		case SIOCGIFADDR:
diff --git a/net/bluetooth/bnep/netdev.c b/net/bluetooth/bnep/netdev.c
index 326ab45..260a950 100644
--- a/net/bluetooth/bnep/netdev.c
+++ b/net/bluetooth/bnep/netdev.c
@@ -87,7 +87,7 @@ static void bnep_net_set_mc_list(struct net_device *dev)
 		memcpy(__skb_put(skb, ETH_ALEN), dev->broadcast, ETH_ALEN);
 		r->len = htons(ETH_ALEN * 2);
 	} else {
-		struct dev_mc_list *dmi;
+		struct netdev_hw_addr *ha;
 		int i, len = skb->len;
 
 		if (dev->flags & IFF_BROADCAST) {
@@ -98,11 +98,11 @@ static void bnep_net_set_mc_list(struct net_device *dev)
 		/* FIXME: We should group addresses here. */
 
 		i = 0;
-		netdev_for_each_mc_addr(dmi, dev) {
+		netdev_for_each_mc_addr(ha, dev) {
 			if (i == BNEP_MAX_MULTICAST_FILTERS)
 				break;
-			memcpy(__skb_put(skb, ETH_ALEN), dmi->dmi_addr, ETH_ALEN);
-			memcpy(__skb_put(skb, ETH_ALEN), dmi->dmi_addr, ETH_ALEN);
+			memcpy(__skb_put(skb, ETH_ALEN), ha->addr, ETH_ALEN);
+			memcpy(__skb_put(skb, ETH_ALEN), ha->addr, ETH_ALEN);
 		}
 		r->len = htons(skb->len - len);
 	}
diff --git a/net/core/Makefile b/net/core/Makefile
index 0a899f1..51c3eec 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -7,9 +7,8 @@ obj-y := sock.o request_sock.o skbuff.o iovec.o datagram.o stream.o scm.o \
 
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
-obj-y		     += dev.o ethtool.o dev_mcast.o dst.o netevent.o \
-			neighbour.o rtnetlink.o utils.o link_watch.o filter.o \
-			dev_addr_lists.o
+obj-y		     += dev.o ethtool.o dev_addr_lists.o dst.o netevent.o \
+			neighbour.o rtnetlink.o utils.o link_watch.o filter.o
 
 obj-$(CONFIG_XFRM) += flow.o
 obj-y += net-sysfs.o
diff --git a/net/core/dev.c b/net/core/dev.c
index d80cc20..4e77a55 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3966,140 +3966,6 @@ void dev_set_rx_mode(struct net_device *dev)
 	netif_addr_unlock_bh(dev);
 }
 
-/* multicast addresses handling functions */
-
-int __dev_addr_delete(struct dev_addr_list **list, int *count,
-		      void *addr, int alen, int glbl)
-{
-	struct dev_addr_list *da;
-
-	for (; (da = *list) != NULL; list = &da->next) {
-		if (memcmp(da->da_addr, addr, da->da_addrlen) == 0 &&
-		    alen == da->da_addrlen) {
-			if (glbl) {
-				int old_glbl = da->da_gusers;
-				da->da_gusers = 0;
-				if (old_glbl == 0)
-					break;
-			}
-			if (--da->da_users)
-				return 0;
-
-			*list = da->next;
-			kfree(da);
-			(*count)--;
-			return 0;
-		}
-	}
-	return -ENOENT;
-}
-
-int __dev_addr_add(struct dev_addr_list **list, int *count,
-		   void *addr, int alen, int glbl)
-{
-	struct dev_addr_list *da;
-
-	for (da = *list; da != NULL; da = da->next) {
-		if (memcmp(da->da_addr, addr, da->da_addrlen) == 0 &&
-		    da->da_addrlen == alen) {
-			if (glbl) {
-				int old_glbl = da->da_gusers;
-				da->da_gusers = 1;
-				if (old_glbl)
-					return 0;
-			}
-			da->da_users++;
-			return 0;
-		}
-	}
-
-	da = kzalloc(sizeof(*da), GFP_ATOMIC);
-	if (da == NULL)
-		return -ENOMEM;
-	memcpy(da->da_addr, addr, alen);
-	da->da_addrlen = alen;
-	da->da_users = 1;
-	da->da_gusers = glbl ? 1 : 0;
-	da->next = *list;
-	*list = da;
-	(*count)++;
-	return 0;
-}
-
-
-int __dev_addr_sync(struct dev_addr_list **to, int *to_count,
-		    struct dev_addr_list **from, int *from_count)
-{
-	struct dev_addr_list *da, *next;
-	int err = 0;
-
-	da = *from;
-	while (da != NULL) {
-		next = da->next;
-		if (!da->da_synced) {
-			err = __dev_addr_add(to, to_count,
-					     da->da_addr, da->da_addrlen, 0);
-			if (err < 0)
-				break;
-			da->da_synced = 1;
-			da->da_users++;
-		} else if (da->da_users == 1) {
-			__dev_addr_delete(to, to_count,
-					  da->da_addr, da->da_addrlen, 0);
-			__dev_addr_delete(from, from_count,
-					  da->da_addr, da->da_addrlen, 0);
-		}
-		da = next;
-	}
-	return err;
-}
-EXPORT_SYMBOL_GPL(__dev_addr_sync);
-
-void __dev_addr_unsync(struct dev_addr_list **to, int *to_count,
-		       struct dev_addr_list **from, int *from_count)
-{
-	struct dev_addr_list *da, *next;
-
-	da = *from;
-	while (da != NULL) {
-		next = da->next;
-		if (da->da_synced) {
-			__dev_addr_delete(to, to_count,
-					  da->da_addr, da->da_addrlen, 0);
-			da->da_synced = 0;
-			__dev_addr_delete(from, from_count,
-					  da->da_addr, da->da_addrlen, 0);
-		}
-		da = next;
-	}
-}
-EXPORT_SYMBOL_GPL(__dev_addr_unsync);
-
-static void __dev_addr_discard(struct dev_addr_list **list)
-{
-	struct dev_addr_list *tmp;
-
-	while (*list != NULL) {
-		tmp = *list;
-		*list = tmp->next;
-		if (tmp->da_users > tmp->da_gusers)
-			printk("__dev_addr_discard: address leakage! "
-			       "da_users=%d\n", tmp->da_users);
-		kfree(tmp);
-	}
-}
-
-void dev_addr_discard(struct net_device *dev)
-{
-	netif_addr_lock_bh(dev);
-
-	__dev_addr_discard(&dev->mc_list);
-	netdev_mc_count(dev) = 0;
-
-	netif_addr_unlock_bh(dev);
-}
-EXPORT_SYMBOL(dev_addr_discard);
-
 /**
  *	dev_get_flags - get flags reported to userspace
  *	@dev: device
@@ -4410,8 +4276,7 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 			return -EINVAL;
 		if (!netif_device_present(dev))
 			return -ENODEV;
-		return dev_mc_add(dev, ifr->ifr_hwaddr.sa_data,
-				  dev->addr_len, 1);
+		return dev_mc_add_global(dev, ifr->ifr_hwaddr.sa_data);
 
 	case SIOCDELMULTI:
 		if ((!ops->ndo_set_multicast_list && !ops->ndo_set_rx_mode) ||
@@ -4419,8 +4284,7 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 			return -EINVAL;
 		if (!netif_device_present(dev))
 			return -ENODEV;
-		return dev_mc_delete(dev, ifr->ifr_hwaddr.sa_data,
-				     dev->addr_len, 1);
+		return dev_mc_del_global(dev, ifr->ifr_hwaddr.sa_data);
 
 	case SIOCSIFTXQLEN:
 		if (ifr->ifr_qlen < 0)
@@ -4728,7 +4592,7 @@ static void rollback_registered_many(struct list_head *head)
 		 *	Flush the unicast and multicast chains
 		 */
 		dev_uc_flush(dev);
-		dev_addr_discard(dev);
+		dev_mc_flush(dev);
 
 		if (dev->netdev_ops->ndo_uninit)
 			dev->netdev_ops->ndo_uninit(dev);
@@ -5308,6 +5172,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	if (dev_addr_init(dev))
 		goto free_rx;
 
+	dev_mc_init(dev);
 	dev_uc_init(dev);
 
 	dev_net_set(dev, &init_net);
@@ -5543,7 +5408,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	 *	Flush the unicast and multicast chains
 	 */
 	dev_uc_flush(dev);
-	dev_addr_discard(dev);
+	dev_mc_flush(dev);
 
 	netdev_unregister_kobject(dev);
 
diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index 7e52b6d..37d5975 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -19,8 +19,9 @@
  * General list handling functions
  */
 
-static int __hw_addr_add(struct netdev_hw_addr_list *list, unsigned char *addr,
-			 int addr_len, unsigned char addr_type)
+static int __hw_addr_add_ex(struct netdev_hw_addr_list *list,
+			    unsigned char *addr, int addr_len,
+			    unsigned char addr_type, bool global)
 {
 	struct netdev_hw_addr *ha;
 	int alloc_size;
@@ -31,6 +32,13 @@ static int __hw_addr_add(struct netdev_hw_addr_list *list, unsigned char *addr,
 	list_for_each_entry(ha, &list->list, list) {
 		if (!memcmp(ha->addr, addr, addr_len) &&
 		    ha->type == addr_type) {
+			if (global) {
+				/* check if addr is already used as global */
+				if (ha->global_use)
+					return 0;
+				else
+					ha->global_use = true;
+			}
 			ha->refcount++;
 			return 0;
 		}
@@ -46,12 +54,19 @@ static int __hw_addr_add(struct netdev_hw_addr_list *list, unsigned char *addr,
 	memcpy(ha->addr, addr, addr_len);
 	ha->type = addr_type;
 	ha->refcount = 1;
+	ha->global_use = global;
 	ha->synced = false;
 	list_add_tail_rcu(&ha->list, &list->list);
 	list->count++;
 	return 0;
 }
 
+static int __hw_addr_add(struct netdev_hw_addr_list *list, unsigned char *addr,
+			 int addr_len, unsigned char addr_type)
+{
+	return __hw_addr_add_ex(list, addr, addr_len, addr_type, false);
+}
+
 static void ha_rcu_free(struct rcu_head *head)
 {
 	struct netdev_hw_addr *ha;
@@ -60,14 +75,21 @@ static void ha_rcu_free(struct rcu_head *head)
 	kfree(ha);
 }
 
-static int __hw_addr_del(struct netdev_hw_addr_list *list, unsigned char *addr,
-			 int addr_len, unsigned char addr_type)
+static int __hw_addr_del_ex(struct netdev_hw_addr_list *list,
+			    unsigned char *addr, int addr_len,
+			    unsigned char addr_type, bool global)
 {
 	struct netdev_hw_addr *ha;
 
 	list_for_each_entry(ha, &list->list, list) {
 		if (!memcmp(ha->addr, addr, addr_len) &&
 		    (ha->type == addr_type || !addr_type)) {
+			if (global) {
+				if (!ha->global_use)
+					break;
+				else
+					ha->global_use = false;
+			}
 			if (--ha->refcount)
 				return 0;
 			list_del_rcu(&ha->list);
@@ -79,10 +101,15 @@ static int __hw_addr_del(struct netdev_hw_addr_list *list, unsigned char *addr,
 	return -ENOENT;
 }
 
-static int __hw_addr_add_multiple(struct netdev_hw_addr_list *to_list,
-				  struct netdev_hw_addr_list *from_list,
-				  int addr_len,
-				  unsigned char addr_type)
+static int __hw_addr_del(struct netdev_hw_addr_list *list, unsigned char *addr,
+			 int addr_len, unsigned char addr_type)
+{
+	return __hw_addr_del_ex(list, addr, addr_len, addr_type, false);
+}
+
+int __hw_addr_add_multiple(struct netdev_hw_addr_list *to_list,
+			   struct netdev_hw_addr_list *from_list,
+			   int addr_len, unsigned char addr_type)
 {
 	int err;
 	struct netdev_hw_addr *ha, *ha2;
@@ -105,11 +132,11 @@ unroll:
 	}
 	return err;
 }
+EXPORT_SYMBOL(__hw_addr_add_multiple);
 
-static void __hw_addr_del_multiple(struct netdev_hw_addr_list *to_list,
-				   struct netdev_hw_addr_list *from_list,
-				   int addr_len,
-				   unsigned char addr_type)
+void __hw_addr_del_multiple(struct netdev_hw_addr_list *to_list,
+			    struct netdev_hw_addr_list *from_list,
+			    int addr_len, unsigned char addr_type)
 {
 	struct netdev_hw_addr *ha;
 	unsigned char type;
@@ -119,10 +146,11 @@ static void __hw_addr_del_multiple(struct netdev_hw_addr_list *to_list,
 		__hw_addr_del(to_list, ha->addr, addr_len, addr_type);
 	}
 }
+EXPORT_SYMBOL(__hw_addr_del_multiple);
 
-static int __hw_addr_sync(struct netdev_hw_addr_list *to_list,
-			  struct netdev_hw_addr_list *from_list,
-			  int addr_len)
+int __hw_addr_sync(struct netdev_hw_addr_list *to_list,
+		   struct netdev_hw_addr_list *from_list,
+		   int addr_len)
 {
 	int err = 0;
 	struct netdev_hw_addr *ha, *tmp;
@@ -142,10 +170,11 @@ static int __hw_addr_sync(struct netdev_hw_addr_list *to_list,
 	}
 	return err;
 }
+EXPORT_SYMBOL(__hw_addr_sync);
 
-static void __hw_addr_unsync(struct netdev_hw_addr_list *to_list,
-			     struct netdev_hw_addr_list *from_list,
-			     int addr_len)
+void __hw_addr_unsync(struct netdev_hw_addr_list *to_list,
+		      struct netdev_hw_addr_list *from_list,
+		      int addr_len)
 {
 	struct netdev_hw_addr *ha, *tmp;
 
@@ -159,8 +188,9 @@ static void __hw_addr_unsync(struct netdev_hw_addr_list *to_list,
 		}
 	}
 }
+EXPORT_SYMBOL(__hw_addr_unsync);
 
-static void __hw_addr_flush(struct netdev_hw_addr_list *list)
+void __hw_addr_flush(struct netdev_hw_addr_list *list)
 {
 	struct netdev_hw_addr *ha, *tmp;
 
@@ -170,12 +200,14 @@ static void __hw_addr_flush(struct netdev_hw_addr_list *list)
 	}
 	list->count = 0;
 }
+EXPORT_SYMBOL(__hw_addr_flush);
 
-static void __hw_addr_init(struct netdev_hw_addr_list *list)
+void __hw_addr_init(struct netdev_hw_addr_list *list)
 {
 	INIT_LIST_HEAD(&list->list);
 	list->count = 0;
 }
+EXPORT_SYMBOL(__hw_addr_init);
 
 /*
  * Device addresses handling functions
@@ -475,4 +507,235 @@ EXPORT_SYMBOL(dev_uc_init);
  * Multicast list handling functions
  */
 
-/* To be filled here */
+static int __dev_mc_add(struct net_device *dev, unsigned char *addr,
+			bool global)
+{
+	int err;
+
+	netif_addr_lock_bh(dev);
+	err = __hw_addr_add_ex(&dev->mc, addr, dev->addr_len,
+			       NETDEV_HW_ADDR_T_MULTICAST, global);
+	if (!err)
+		__dev_set_rx_mode(dev);
+	netif_addr_unlock_bh(dev);
+	return err;
+}
+/**
+ *	dev_mc_add - Add a multicast address
+ *	@dev: device
+ *	@addr: address to add
+ *
+ *	Add a multicast address to the device or increase
+ *	the reference count if it already exists.
+ */
+int dev_mc_add(struct net_device *dev, unsigned char *addr)
+{
+	return __dev_mc_add(dev, addr, false);
+}
+EXPORT_SYMBOL(dev_mc_add);
+
+/**
+ *	dev_mc_add_global - Add a global multicast address
+ *	@dev: device
+ *	@addr: address to add
+ *
+ *	Add a global multicast address to the device.
+ */
+int dev_mc_add_global(struct net_device *dev, unsigned char *addr)
+{
+	return __dev_mc_add(dev, addr, true);
+}
+EXPORT_SYMBOL(dev_mc_add_global);
+
+static int __dev_mc_del(struct net_device *dev, unsigned char *addr,
+			bool global)
+{
+	int err;
+
+	netif_addr_lock_bh(dev);
+	err = __hw_addr_del_ex(&dev->mc, addr, dev->addr_len,
+			       NETDEV_HW_ADDR_T_MULTICAST, global);
+	if (!err)
+		__dev_set_rx_mode(dev);
+	netif_addr_unlock_bh(dev);
+	return err;
+}
+
+/**
+ *	dev_mc_del - Delete a multicast address.
+ *	@dev: device
+ *	@addr: address to delete
+ *
+ *	Release reference to a multicast address and remove it
+ *	from the device if the reference count drops to zero.
+ */
+int dev_mc_del(struct net_device *dev, unsigned char *addr)
+{
+	return __dev_mc_del(dev, addr, false);
+}
+EXPORT_SYMBOL(dev_mc_del);
+
+/**
+ *	dev_mc_del_global - Delete a global multicast address.
+ *	@dev: device
+ *	@addr: address to delete
+ *
+ *	Release reference to a multicast address and remove it
+ *	from the device if the reference count drops to zero.
+ */
+int dev_mc_del_global(struct net_device *dev, unsigned char *addr)
+{
+	return __dev_mc_del(dev, addr, true);
+}
+EXPORT_SYMBOL(dev_mc_del_global);
+
+/**
+ *	dev_mc_sync - Synchronize device's unicast list to another device
+ *	@to: destination device
+ *	@from: source device
+ *
+ *	Add newly added addresses to the destination device and release
+ *	addresses that have no users left. The source device must be
+ *	locked by netif_tx_lock_bh.
+ *
+ *	This function is intended to be called from the dev->set_multicast_list
+ *	or dev->set_rx_mode function of layered software devices.
+ */
+int dev_mc_sync(struct net_device *to, struct net_device *from)
+{
+	int err = 0;
+
+	if (to->addr_len != from->addr_len)
+		return -EINVAL;
+
+	netif_addr_lock_bh(to);
+	err = __hw_addr_sync(&to->mc, &from->mc, to->addr_len);
+	if (!err)
+		__dev_set_rx_mode(to);
+	netif_addr_unlock_bh(to);
+	return err;
+}
+EXPORT_SYMBOL(dev_mc_sync);
+
+/**
+ *	dev_mc_unsync - Remove synchronized addresses from the destination device
+ *	@to: destination device
+ *	@from: source device
+ *
+ *	Remove all addresses that were added to the destination device by
+ *	dev_mc_sync(). This function is intended to be called from the
+ *	dev->stop function of layered software devices.
+ */
+void dev_mc_unsync(struct net_device *to, struct net_device *from)
+{
+	if (to->addr_len != from->addr_len)
+		return;
+
+	netif_addr_lock_bh(from);
+	netif_addr_lock(to);
+	__hw_addr_unsync(&to->mc, &from->mc, to->addr_len);
+	__dev_set_rx_mode(to);
+	netif_addr_unlock(to);
+	netif_addr_unlock_bh(from);
+}
+EXPORT_SYMBOL(dev_mc_unsync);
+
+/**
+ *	dev_mc_flush - Flush multicast addresses
+ *	@dev: device
+ *
+ *	Flush multicast addresses.
+ */
+void dev_mc_flush(struct net_device *dev)
+{
+	netif_addr_lock_bh(dev);
+	__hw_addr_flush(&dev->mc);
+	netif_addr_unlock_bh(dev);
+}
+EXPORT_SYMBOL(dev_mc_flush);
+
+/**
+ *	dev_mc_flush - Init multicast address list
+ *	@dev: device
+ *
+ *	Init multicast address list.
+ */
+void dev_mc_init(struct net_device *dev)
+{
+	__hw_addr_init(&dev->mc);
+}
+EXPORT_SYMBOL(dev_mc_init);
+
+#ifdef CONFIG_PROC_FS
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+
+static int dev_mc_seq_show(struct seq_file *seq, void *v)
+{
+	struct netdev_hw_addr *ha;
+	struct net_device *dev = v;
+
+	if (v == SEQ_START_TOKEN)
+		return 0;
+
+	netif_addr_lock_bh(dev);
+	netdev_for_each_mc_addr(ha, dev) {
+		int i;
+
+		seq_printf(seq, "%-4d %-15s %-5d %-5d ", dev->ifindex,
+			   dev->name, ha->refcount, ha->global_use);
+
+		for (i = 0; i < dev->addr_len; i++)
+			seq_printf(seq, "%02x", ha->addr[i]);
+
+		seq_putc(seq, '\n');
+	}
+	netif_addr_unlock_bh(dev);
+	return 0;
+}
+
+static const struct seq_operations dev_mc_seq_ops = {
+	.start = dev_seq_start,
+	.next  = dev_seq_next,
+	.stop  = dev_seq_stop,
+	.show  = dev_mc_seq_show,
+};
+
+static int dev_mc_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open_net(inode, file, &dev_mc_seq_ops,
+			    sizeof(struct seq_net_private));
+}
+
+static const struct file_operations dev_mc_seq_fops = {
+	.owner	 = THIS_MODULE,
+	.open    = dev_mc_seq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release_net,
+};
+
+#endif
+
+static int __net_init dev_mc_net_init(struct net *net)
+{
+	if (!proc_net_fops_create(net, "dev_mcast", 0, &dev_mc_seq_fops))
+		return -ENOMEM;
+	return 0;
+}
+
+static void __net_exit dev_mc_net_exit(struct net *net)
+{
+	proc_net_remove(net, "dev_mcast");
+}
+
+static struct pernet_operations __net_initdata dev_mc_net_ops = {
+	.init = dev_mc_net_init,
+	.exit = dev_mc_net_exit,
+};
+
+void __init dev_mcast_init(void)
+{
+	register_pernet_subsys(&dev_mc_net_ops);
+}
+
diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
deleted file mode 100644
index 3dc295b..0000000
--- a/net/core/dev_mcast.c
+++ /dev/null
@@ -1,232 +0,0 @@
-/*
- *	Linux NET3:	Multicast List maintenance.
- *
- *	Authors:
- *		Tim Kordas <tjk@nostromo.eeap.cwru.edu>
- *		Richard Underwood <richard@wuzz.demon.co.uk>
- *
- *	Stir fried together from the IP multicast and CAP patches above
- *		Alan Cox <alan@lxorguk.ukuu.org.uk>
- *
- *	Fixes:
- *		Alan Cox	:	Update the device on a real delete
- *					rather than any time but...
- *		Alan Cox	:	IFF_ALLMULTI support.
- *		Alan Cox	: 	New format set_multicast_list() calls.
- *		Gleb Natapov    :       Remove dev_mc_lock.
- *
- *	This program is free software; you can redistribute it and/or
- *	modify it under the terms of the GNU General Public License
- *	as published by the Free Software Foundation; either version
- *	2 of the License, or (at your option) any later version.
- */
-
-#include <linux/module.h>
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <linux/bitops.h>
-#include <linux/types.h>
-#include <linux/kernel.h>
-#include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
-#include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/if_ether.h>
-#include <linux/inet.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/proc_fs.h>
-#include <linux/seq_file.h>
-#include <linux/init.h>
-#include <net/net_namespace.h>
-#include <net/ip.h>
-#include <net/route.h>
-#include <linux/skbuff.h>
-#include <net/sock.h>
-#include <net/arp.h>
-
-
-/*
- *	Device multicast list maintenance.
- *
- *	This is used both by IP and by the user level maintenance functions.
- *	Unlike BSD we maintain a usage count on a given multicast address so
- *	that a casual user application can add/delete multicasts used by
- *	protocols without doing damage to the protocols when it deletes the
- *	entries. It also helps IP as it tracks overlapping maps.
- *
- *	Device mc lists are changed by bh at least if IPv6 is enabled,
- *	so that it must be bh protected.
- *
- *	We block accesses to device mc filters with netif_tx_lock.
- */
-
-/*
- *	Delete a device level multicast
- */
-
-int dev_mc_delete(struct net_device *dev, void *addr, int alen, int glbl)
-{
-	int err;
-
-	netif_addr_lock_bh(dev);
-	err = __dev_addr_delete(&dev->mc_list, &dev->mc_count,
-				addr, alen, glbl);
-	if (!err) {
-		/*
-		 *	We have altered the list, so the card
-		 *	loaded filter is now wrong. Fix it
-		 */
-
-		__dev_set_rx_mode(dev);
-	}
-	netif_addr_unlock_bh(dev);
-	return err;
-}
-
-/*
- *	Add a device level multicast
- */
-
-int dev_mc_add(struct net_device *dev, void *addr, int alen, int glbl)
-{
-	int err;
-
-	netif_addr_lock_bh(dev);
-	if (alen != dev->addr_len)
-		err = -EINVAL;
-	else
-		err = __dev_addr_add(&dev->mc_list, &dev->mc_count, addr, alen, glbl);
-	if (!err)
-		__dev_set_rx_mode(dev);
-	netif_addr_unlock_bh(dev);
-	return err;
-}
-
-/**
- *	dev_mc_sync	- Synchronize device's multicast list to another device
- *	@to: destination device
- *	@from: source device
- *
- * 	Add newly added addresses to the destination device and release
- * 	addresses that have no users left. The source device must be
- * 	locked by netif_tx_lock_bh.
- *
- *	This function is intended to be called from the dev->set_multicast_list
- *	or dev->set_rx_mode function of layered software devices.
- */
-int dev_mc_sync(struct net_device *to, struct net_device *from)
-{
-	int err = 0;
-
-	netif_addr_lock_bh(to);
-	err = __dev_addr_sync(&to->mc_list, &to->mc_count,
-			      &from->mc_list, &from->mc_count);
-	if (!err)
-		__dev_set_rx_mode(to);
-	netif_addr_unlock_bh(to);
-
-	return err;
-}
-EXPORT_SYMBOL(dev_mc_sync);
-
-
-/**
- * 	dev_mc_unsync	- Remove synchronized addresses from the destination
- * 			  device
- *	@to: destination device
- *	@from: source device
- *
- * 	Remove all addresses that were added to the destination device by
- * 	dev_mc_sync(). This function is intended to be called from the
- * 	dev->stop function of layered software devices.
- */
-void dev_mc_unsync(struct net_device *to, struct net_device *from)
-{
-	netif_addr_lock_bh(from);
-	netif_addr_lock(to);
-
-	__dev_addr_unsync(&to->mc_list, &to->mc_count,
-			  &from->mc_list, &from->mc_count);
-	__dev_set_rx_mode(to);
-
-	netif_addr_unlock(to);
-	netif_addr_unlock_bh(from);
-}
-EXPORT_SYMBOL(dev_mc_unsync);
-
-#ifdef CONFIG_PROC_FS
-static int dev_mc_seq_show(struct seq_file *seq, void *v)
-{
-	struct dev_addr_list *m;
-	struct net_device *dev = v;
-
-	if (v == SEQ_START_TOKEN)
-		return 0;
-
-	netif_addr_lock_bh(dev);
-	for (m = dev->mc_list; m; m = m->next) {
-		int i;
-
-		seq_printf(seq, "%-4d %-15s %-5d %-5d ", dev->ifindex,
-			   dev->name, m->dmi_users, m->dmi_gusers);
-
-		for (i = 0; i < m->dmi_addrlen; i++)
-			seq_printf(seq, "%02x", m->dmi_addr[i]);
-
-		seq_putc(seq, '\n');
-	}
-	netif_addr_unlock_bh(dev);
-	return 0;
-}
-
-static const struct seq_operations dev_mc_seq_ops = {
-	.start = dev_seq_start,
-	.next  = dev_seq_next,
-	.stop  = dev_seq_stop,
-	.show  = dev_mc_seq_show,
-};
-
-static int dev_mc_seq_open(struct inode *inode, struct file *file)
-{
-	return seq_open_net(inode, file, &dev_mc_seq_ops,
-			    sizeof(struct seq_net_private));
-}
-
-static const struct file_operations dev_mc_seq_fops = {
-	.owner	 = THIS_MODULE,
-	.open    = dev_mc_seq_open,
-	.read    = seq_read,
-	.llseek  = seq_lseek,
-	.release = seq_release_net,
-};
-
-#endif
-
-static int __net_init dev_mc_net_init(struct net *net)
-{
-	if (!proc_net_fops_create(net, "dev_mcast", 0, &dev_mc_seq_fops))
-		return -ENOMEM;
-	return 0;
-}
-
-static void __net_exit dev_mc_net_exit(struct net *net)
-{
-	proc_net_remove(net, "dev_mcast");
-}
-
-static struct pernet_operations __net_initdata dev_mc_net_ops = {
-	.init = dev_mc_net_init,
-	.exit = dev_mc_net_exit,
-};
-
-void __init dev_mcast_init(void)
-{
-	register_pernet_subsys(&dev_mc_net_ops);
-}
-
-EXPORT_SYMBOL(dev_mc_add);
-EXPORT_SYMBOL(dev_mc_delete);
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 238af09..f3e4734 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -349,7 +349,7 @@ static void dn_dev_del_ifa(struct dn_dev *dn_db, struct dn_ifaddr **ifap, int de
 	if (dn_db->dev->type == ARPHRD_ETHER) {
 		if (ifa1->ifa_local != dn_eth2dn(dev->dev_addr)) {
 			dn_dn2eth(mac_addr, ifa1->ifa_local);
-			dev_mc_delete(dev, mac_addr, ETH_ALEN, 0);
+			dev_mc_del(dev, mac_addr);
 		}
 	}
 
@@ -380,7 +380,7 @@ static int dn_dev_insert_ifa(struct dn_dev *dn_db, struct dn_ifaddr *ifa)
 	if (dev->type == ARPHRD_ETHER) {
 		if (ifa->ifa_local != dn_eth2dn(dev->dev_addr)) {
 			dn_dn2eth(mac_addr, ifa->ifa_local);
-			dev_mc_add(dev, mac_addr, ETH_ALEN, 0);
+			dev_mc_add(dev, mac_addr);
 		}
 	}
 
@@ -1000,9 +1000,9 @@ static int dn_eth_up(struct net_device *dev)
 	struct dn_dev *dn_db = dev->dn_ptr;
 
 	if (dn_db->parms.forwarding == 0)
-		dev_mc_add(dev, dn_rt_all_end_mcast, ETH_ALEN, 0);
+		dev_mc_add(dev, dn_rt_all_end_mcast);
 	else
-		dev_mc_add(dev, dn_rt_all_rt_mcast, ETH_ALEN, 0);
+		dev_mc_add(dev, dn_rt_all_rt_mcast);
 
 	dn_db->use_long = 1;
 
@@ -1014,9 +1014,9 @@ static void dn_eth_down(struct net_device *dev)
 	struct dn_dev *dn_db = dev->dn_ptr;
 
 	if (dn_db->parms.forwarding == 0)
-		dev_mc_delete(dev, dn_rt_all_end_mcast, ETH_ALEN, 0);
+		dev_mc_del(dev, dn_rt_all_end_mcast);
 	else
-		dev_mc_delete(dev, dn_rt_all_rt_mcast, ETH_ALEN, 0);
+		dev_mc_del(dev, dn_rt_all_rt_mcast);
 }
 
 static void dn_dev_set_timer(struct net_device *dev);
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 63bf298..51824c4 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -997,7 +997,7 @@ static void ip_mc_filter_add(struct in_device *in_dev, __be32 addr)
 	   --ANK
 	   */
 	if (arp_mc_map(addr, buf, dev, 0) == 0)
-		dev_mc_add(dev, buf, dev->addr_len, 0);
+		dev_mc_add(dev, buf);
 }
 
 /*
@@ -1010,7 +1010,7 @@ static void ip_mc_filter_del(struct in_device *in_dev, __be32 addr)
 	struct net_device *dev = in_dev->dev;
 
 	if (arp_mc_map(addr, buf, dev, 0) == 0)
-		dev_mc_delete(dev, buf, dev->addr_len, 0);
+		dev_mc_del(dev, buf);
 }
 
 #ifdef CONFIG_IP_MULTICAST
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 0886f96..a2208b7 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -87,7 +87,7 @@ clusterip_config_entry_put(struct clusterip_config *c)
 		list_del(&c->list);
 		write_unlock_bh(&clusterip_lock);
 
-		dev_mc_delete(c->dev, c->clustermac, ETH_ALEN, 0);
+		dev_mc_del(c->dev, c->clustermac);
 		dev_put(c->dev);
 
 		/* In case anyone still accesses the file, the open/close
@@ -396,7 +396,7 @@ static bool clusterip_tg_check(const struct xt_tgchk_param *par)
 				dev_put(dev);
 				return false;
 			}
-			dev_mc_add(config->dev,config->clustermac, ETH_ALEN, 0);
+			dev_mc_add(config->dev, config->clustermac);
 		}
 	}
 	cipinfo->config = config;
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index bcd9719..37d1868 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -714,7 +714,7 @@ static void igmp6_group_added(struct ifmcaddr6 *mc)
 	if (!(mc->mca_flags&MAF_LOADED)) {
 		mc->mca_flags |= MAF_LOADED;
 		if (ndisc_mc_map(&mc->mca_addr, buf, dev, 0) == 0)
-			dev_mc_add(dev, buf, dev->addr_len, 0);
+			dev_mc_add(dev, buf);
 	}
 	spin_unlock_bh(&mc->mca_lock);
 
@@ -740,7 +740,7 @@ static void igmp6_group_dropped(struct ifmcaddr6 *mc)
 	if (mc->mca_flags&MAF_LOADED) {
 		mc->mca_flags &= ~MAF_LOADED;
 		if (ndisc_mc_map(&mc->mca_addr, buf, dev, 0) == 0)
-			dev_mc_delete(dev, buf, dev->addr_len, 0);
+			dev_mc_del(dev, buf);
 	}
 
 	if (mc->mca_flags & MAF_NOREPORT)
diff --git a/net/mac80211/driver-ops.h b/net/mac80211/driver-ops.h
index c3d8440..9179196 100644
--- a/net/mac80211/driver-ops.h
+++ b/net/mac80211/driver-ops.h
@@ -84,16 +84,14 @@ static inline void drv_bss_info_changed(struct ieee80211_local *local,
 }
 
 static inline u64 drv_prepare_multicast(struct ieee80211_local *local,
-					int mc_count,
-					struct dev_addr_list *mc_list)
+					struct netdev_hw_addr_list *mc_list)
 {
 	u64 ret = 0;
 
 	if (local->ops->prepare_multicast)
-		ret = local->ops->prepare_multicast(&local->hw, mc_count,
-						    mc_list);
+		ret = local->ops->prepare_multicast(&local->hw, mc_list);
 
-	trace_drv_prepare_multicast(local, mc_count, ret);
+	trace_drv_prepare_multicast(local, mc_list->count, ret);
 
 	return ret;
 }
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index ab369e2..7fdacf9 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -646,8 +646,7 @@ struct ieee80211_local {
 	struct work_struct recalc_smps;
 
 	/* aggregated multicast list */
-	struct dev_addr_list *mc_list;
-	int mc_count;
+	struct netdev_hw_addr_list mc_list;
 
 	bool tim_in_locked_section; /* see ieee80211_beacon_get() */
 
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index b4ec59a..00f3a93 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -412,8 +412,7 @@ static int ieee80211_stop(struct net_device *dev)
 
 	netif_addr_lock_bh(dev);
 	spin_lock_bh(&local->filter_lock);
-	__dev_addr_unsync(&local->mc_list, &local->mc_count,
-			  &dev->mc_list, &dev->mc_count);
+	__hw_addr_unsync(&local->mc_list, &dev->mc, dev->addr_len);
 	spin_unlock_bh(&local->filter_lock);
 	netif_addr_unlock_bh(dev);
 
@@ -596,8 +595,7 @@ static void ieee80211_set_multicast_list(struct net_device *dev)
 		sdata->flags ^= IEEE80211_SDATA_PROMISC;
 	}
 	spin_lock_bh(&local->filter_lock);
-	__dev_addr_sync(&local->mc_list, &local->mc_count,
-			&dev->mc_list, &dev->mc_count);
+	__hw_addr_sync(&local->mc_list, &dev->mc, dev->addr_len);
 	spin_unlock_bh(&local->filter_lock);
 	ieee80211_queue_work(&local->hw, &local->reconfig_filter);
 }
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 06c33b6..84ad249 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -71,7 +71,7 @@ void ieee80211_configure_filter(struct ieee80211_local *local)
 	spin_lock_bh(&local->filter_lock);
 	changed_flags = local->filter_flags ^ new_flags;
 
-	mc = drv_prepare_multicast(local, local->mc_count, local->mc_list);
+	mc = drv_prepare_multicast(local, &local->mc_list);
 	spin_unlock_bh(&local->filter_lock);
 
 	/* be a bit nasty */
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 48c1e0a..b0f037c 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1691,9 +1691,9 @@ static int packet_dev_mc(struct net_device *dev, struct packet_mclist *i,
 		if (i->alen != dev->addr_len)
 			return -EINVAL;
 		if (what > 0)
-			return dev_mc_add(dev, i->addr, i->alen, 0);
+			return dev_mc_add(dev, i->addr);
 		else
-			return dev_mc_delete(dev, i->addr, i->alen, 0);
+			return dev_mc_del(dev, i->addr);
 		break;
 	case PACKET_MR_PROMISC:
 		return dev_set_promiscuity(dev, what);
-- 
1.6.6.1

