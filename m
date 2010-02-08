From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] net: use netdev_mc_count and netdev_mc_empty
 when appropriate
Date: Mon, 8 Feb 2010 15:30:35 +0100
Message-ID: <20100208143032.GD2601@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51771 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752295Ab0BHOaj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2010 09:30:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces dev->mc_count in all drivers (hopefully I didn't miss
anything). Used spatch and did small tweaks and conding style changes when
it was suitable.

Jirka

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 arch/xtensa/platforms/iss/network.c    |    2 +-
 drivers/infiniband/hw/nes/nes_nic.c    |    2 +-
 drivers/media/dvb/dvb-core/dvb_net.c   |    7 +++----
 drivers/net/3c505.c                    |    6 +++---
 drivers/net/3c509.c                    |   10 ++++++----
 drivers/net/3c523.c                    |    4 ++--
 drivers/net/3c527.c                    |   11 ++++++-----
 drivers/net/7990.c                     |    2 +-
 drivers/net/82596.c                    |    8 ++++----
 drivers/net/a2065.c                    |    2 +-
 drivers/net/acenic.c                   |    2 +-
 drivers/net/amd8111e.c                 |    7 ++++---
 drivers/net/ariadne.c                  |    2 +-
 drivers/net/arm/at91_ether.c           |    4 ++--
 drivers/net/arm/ether3.c               |    2 +-
 drivers/net/arm/ixp4xx_eth.c           |    2 +-
 drivers/net/arm/ks8695net.c            |    4 ++--
 drivers/net/at1700.c                   |    6 +++---
 drivers/net/atarilance.c               |    2 +-
 drivers/net/atp.c                      |    7 ++++---
 drivers/net/au1000_eth.c               |    4 ++--
 drivers/net/b44.c                      |    4 ++--
 drivers/net/bcm63xx_enet.c             |    4 ++--
 drivers/net/benet/be_main.c            |    5 +++--
 drivers/net/bfin_mac.c                 |    4 ++--
 drivers/net/bmac.c                     |    8 ++++----
 drivers/net/bnx2.c                     |    2 +-
 drivers/net/bnx2x_main.c               |    7 ++++---
 drivers/net/chelsio/common.h           |    4 ++--
 drivers/net/cpmac.c                    |    2 +-
 drivers/net/cris/eth_v10.c             |    2 +-
 drivers/net/davinci_emac.c             |    4 ++--
 drivers/net/de620.c                    |    2 +-
 drivers/net/declance.c                 |    2 +-
 drivers/net/defxx.c                    |    4 ++--
 drivers/net/depca.c                    |    2 +-
 drivers/net/dl2k.c                     |    6 +++---
 drivers/net/dm9000.c                   |    2 +-
 drivers/net/e100.c                     |    6 +++---
 drivers/net/eepro.c                    |   15 ++++++++-------
 drivers/net/eexpress.c                 |    6 +++---
 drivers/net/ehea/ehea_main.c           |    6 +++---
 drivers/net/enc28j60.c                 |    2 +-
 drivers/net/enic/enic_main.c           |    4 ++--
 drivers/net/epic100.c                  |    6 +++---
 drivers/net/eth16i.c                   |    2 +-
 drivers/net/ewrk3.c                    |    2 +-
 drivers/net/fealnx.c                   |    4 ++--
 drivers/net/fec.c                      |    2 +-
 drivers/net/fec_mpc52xx.c              |    2 +-
 drivers/net/fs_enet/mac-fcc.c          |    2 +-
 drivers/net/fs_enet/mac-fec.c          |    2 +-
 drivers/net/fs_enet/mac-scc.c          |    2 +-
 drivers/net/gianfar.c                  |    2 +-
 drivers/net/hamachi.c                  |    6 +++---
 drivers/net/hp100.c                    |    7 ++++---
 drivers/net/ibm_newemac/core.c         |    6 +++---
 drivers/net/ibmveth.c                  |    5 +++--
 drivers/net/igb/igb_main.c             |    8 ++++----
 drivers/net/igbvf/netdev.c             |    6 +++---
 drivers/net/ioc3-eth.c                 |    5 +++--
 drivers/net/ipg.c                      |    4 ++--
 drivers/net/isa-skeleton.c             |    5 +++--
 drivers/net/iseries_veth.c             |    4 ++--
 drivers/net/ixgb/ixgb_main.c           |    6 +++---
 drivers/net/ixgbe/ixgbe_main.c         |    2 +-
 drivers/net/ixgbevf/ixgbevf_main.c     |    2 +-
 drivers/net/jme.c                      |    2 +-
 drivers/net/korina.c                   |    6 +++---
 drivers/net/ks8851.c                   |    4 ++--
 drivers/net/ks8851_mll.c               |    4 ++--
 drivers/net/lance.c                    |    2 +-
 drivers/net/lib82596.c                 |    6 +++---
 drivers/net/ll_temac_main.c            |    6 +++---
 drivers/net/lp486e.c                   |   12 +++++++-----
 drivers/net/macb.c                     |    4 ++--
 drivers/net/mace.c                     |    2 +-
 drivers/net/macmace.c                  |    2 +-
 drivers/net/natsemi.c                  |    4 ++--
 drivers/net/netxen/netxen_nic_hw.c     |   10 +++++-----
 drivers/net/ni52.c                     |    2 +-
 drivers/net/ni65.c                     |    2 +-
 drivers/net/niu.c                      |    4 ++--
 drivers/net/ns83820.c                  |    2 +-
 drivers/net/octeon/octeon_mgmt.c       |    6 +++---
 drivers/net/pci-skeleton.c             |    4 ++--
 drivers/net/pcmcia/3c574_cs.c          |    2 +-
 drivers/net/pcmcia/3c589_cs.c          |    2 +-
 drivers/net/pcmcia/fmvj18x_cs.c        |    6 +++---
 drivers/net/pcmcia/nmclan_cs.c         |   14 +++++++-------
 drivers/net/pcmcia/smc91c92_cs.c       |    4 ++--
 drivers/net/pcmcia/xirc2ps_cs.c        |    8 ++++----
 drivers/net/pcnet32.c                  |    2 +-
 drivers/net/ps3_gelic_net.c            |    2 +-
 drivers/net/qlcnic/qlcnic_hw.c         |    4 ++--
 drivers/net/qlge/qlge_main.c           |    4 ++--
 drivers/net/r6040.c                    |   11 ++++++-----
 drivers/net/r8169.c                    |    4 ++--
 drivers/net/s2io.c                     |    8 ++++----
 drivers/net/sc92031.c                  |    2 +-
 drivers/net/sfc/efx.c                  |    2 +-
 drivers/net/sgiseeq.c                  |    2 +-
 drivers/net/sis190.c                   |    4 ++--
 drivers/net/sis900.c                   |    4 ++--
 drivers/net/skfp/skfddi.c              |    6 +++---
 drivers/net/skge.c                     |    6 +++---
 drivers/net/sky2.c                     |    4 ++--
 drivers/net/smc911x.c                  |    6 +++---
 drivers/net/smc9194.c                  |    4 ++--
 drivers/net/smc91x.c                   |    6 +++---
 drivers/net/smsc911x.c                 |    4 ++--
 drivers/net/smsc9420.c                 |    2 +-
 drivers/net/sonic.c                    |    8 +++++---
 drivers/net/starfire.c                 |    8 ++++----
 drivers/net/stmmac/dwmac100.c          |    6 +++---
 drivers/net/stmmac/dwmac1000_core.c    |    8 ++++----
 drivers/net/sun3_82586.c               |    2 +-
 drivers/net/sun3lance.c                |    2 +-
 drivers/net/sunbmac.c                  |    4 ++--
 drivers/net/sundance.c                 |    6 +++---
 drivers/net/sungem.c                   |    4 ++--
 drivers/net/sunhme.c                   |    8 ++++----
 drivers/net/sunlance.c                 |    2 +-
 drivers/net/sunqe.c                    |    4 ++--
 drivers/net/tc35815.c                  |    6 +++---
 drivers/net/tehuti.c                   |    4 ++--
 drivers/net/tg3.c                      |    4 ++--
 drivers/net/tlan.c                     |    2 +-
 drivers/net/tokenring/3c359.c          |    2 +-
 drivers/net/tokenring/ibmtr.c          |    2 +-
 drivers/net/tokenring/lanstreamer.c    |    2 +-
 drivers/net/tokenring/olympic.c        |    2 +-
 drivers/net/tokenring/tms380tr.c       |    2 +-
 drivers/net/tsi108_eth.c               |    2 +-
 drivers/net/tulip/de2104x.c            |    8 ++++----
 drivers/net/tulip/de4x5.c              |    6 +++---
 drivers/net/tulip/dmfe.c               |   15 ++++++++-------
 drivers/net/tulip/tulip_core.c         |   18 +++++++++++-------
 drivers/net/tulip/uli526x.c            |   12 +++++++-----
 drivers/net/tulip/winbond-840.c        |    7 ++++---
 drivers/net/typhoon.c                  |    9 +++++----
 drivers/net/ucc_geth.c                 |    3 ++-
 drivers/net/usb/asix.c                 |   12 ++++++------
 drivers/net/usb/catc.c                 |    4 +++-
 drivers/net/usb/int51x1.c              |    2 +-
 drivers/net/usb/kaweth.c               |    2 +-
 drivers/net/usb/mcs7830.c              |    6 +++---
 drivers/net/usb/pegasus.c              |    2 +-
 drivers/net/usb/rtl8150.c              |    2 +-
 drivers/net/usb/smsc95xx.c             |    4 ++--
 drivers/net/via-rhine.c                |    5 +++--
 drivers/net/via-velocity.c             |    6 ++++--
 drivers/net/virtio_net.c               |   13 ++++++++-----
 drivers/net/vmxnet3/vmxnet3_drv.c      |    8 ++++----
 drivers/net/vxge/vxge-main.c           |    6 +++---
 drivers/net/wireless/airo.c            |    2 +-
 drivers/net/wireless/orinoco/main.c    |    4 ++--
 drivers/net/wireless/ray_cs.c          |    2 +-
 drivers/net/wireless/rndis_wlan.c      |    6 +++---
 drivers/net/wireless/zd1201.c          |    7 +++----
 drivers/net/yellowfin.c                |    7 ++++---
 drivers/staging/et131x/et131x_netdev.c |   10 +++++-----
 drivers/staging/netwave/netwave_cs.c   |    8 ++++----
 drivers/staging/slicoss/slicoss.c      |    2 +-
 drivers/staging/vt6655/device_main.c   |    4 ++--
 drivers/staging/vt6656/main_usb.c      |    5 +++--
 drivers/staging/wavelan/wavelan.c      |    8 ++++----
 drivers/staging/wavelan/wavelan_cs.c   |   11 ++++++-----
 drivers/staging/wlags49_h2/wl_netdev.c |   12 ++++++------
 net/bluetooth/bnep/netdev.c            |    6 ++++--
 net/core/dev.c                         |    2 +-
 net/irda/irlan/irlan_eth.c             |    5 +++--
 net/mac80211/iface.c                   |    2 +-
 173 files changed, 440 insertions(+), 401 deletions(-)

diff --git a/arch/xtensa/platforms/iss/network.c b/arch/xtensa/platforms/iss/network.c
index 2f0b86b..87e218f 100644
--- a/arch/xtensa/platforms/iss/network.c
+++ b/arch/xtensa/platforms/iss/network.c
@@ -560,7 +560,7 @@ static void iss_net_set_multicast_list(struct net_device *dev)
 #if 0
 	if (dev->flags & IFF_PROMISC)
 		return;
-	else if (dev->mc_count)
+	else if (!netdev_mc_empty(dev))
 		dev->flags |= IFF_ALLMULTI;
 	else
 		dev->flags &= ~IFF_ALLMULTI;
diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index ab11027..c04f8fc 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -862,7 +862,7 @@ static void nes_netdev_set_multicast_list(struct net_device *netdev)
 	}
 
 	nes_debug(NES_DBG_NIC_RX, "Number of MC entries = %d, Promiscous = %d, All Multicast = %d.\n",
-		  netdev->mc_count, !!(netdev->flags & IFF_PROMISC),
+		  netdev_mc_count(netdev), !!(netdev->flags & IFF_PROMISC),
 		  !!(netdev->flags & IFF_ALLMULTI));
 	if (!mc_all_on) {
 		multicast_addr = netdev->mc_list;
diff --git a/drivers/media/dvb/dvb-core/dvb_net.c b/drivers/media/dvb/dvb-core/dvb_net.c
index da6552d..37d8579 100644
--- a/drivers/media/dvb/dvb-core/dvb_net.c
+++ b/drivers/media/dvb/dvb-core/dvb_net.c
@@ -1138,18 +1138,18 @@ static void wq_set_multicast_list (struct work_struct *work)
 	} else if ((dev->flags & IFF_ALLMULTI)) {
 		dprintk("%s: allmulti mode\n", dev->name);
 		priv->rx_mode = RX_MODE_ALL_MULTI;
-	} else if (dev->mc_count) {
+	} else if (!netdev_mc_empty(dev)) {
 		int mci;
 		struct dev_mc_list *mc;
 
 		dprintk("%s: set_mc_list, %d entries\n",
-			dev->name, dev->mc_count);
+			dev->name, netdev_mc_count(dev));
 
 		priv->rx_mode = RX_MODE_MULTI;
 		priv->multi_num = 0;
 
 		for (mci = 0, mc=dev->mc_list;
-		     mci < dev->mc_count;
+		     mci < netdev_mc_count(dev);
 		     mc = mc->next, mci++) {
 			dvb_set_mc_filter(dev, mc);
 		}
@@ -1236,7 +1236,6 @@ static void dvb_net_setup(struct net_device *dev)
 	dev->header_ops		= &dvb_header_ops;
 	dev->netdev_ops		= &dvb_netdev_ops;
 	dev->mtu		= 4096;
-	dev->mc_count           = 0;
 
 	dev->flags |= IFF_NOARP;
 }
diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
index 9257d7c..dadb46a 100644
--- a/drivers/net/3c505.c
+++ b/drivers/net/3c505.c
@@ -1229,8 +1229,8 @@ static void elp_set_mc_list(struct net_device *dev)
 		/* send a "load multicast list" command to the board, max 10 addrs/cmd */
 		/* if num_addrs==0 the list will be cleared */
 		adapter->tx_pcb.command = CMD_LOAD_MULTICAST_LIST;
-		adapter->tx_pcb.length = 6 * dev->mc_count;
-		for (i = 0; i < dev->mc_count; i++) {
+		adapter->tx_pcb.length = 6 * netdev_mc_count(dev);
+		for (i = 0; i < netdev_mc_count(dev); i++) {
 			memcpy(adapter->tx_pcb.data.multicast[i], dmi->dmi_addr, 6);
 			dmi = dmi->next;
 		}
@@ -1244,7 +1244,7 @@ static void elp_set_mc_list(struct net_device *dev)
 				TIMEOUT_MSG(__LINE__);
 			}
 		}
-		if (dev->mc_count)
+		if (!netdev_mc_empty(dev))
 			adapter->tx_pcb.data.configure = NO_LOOPBACK | RECV_BROAD | RECV_MULTI;
 		else		/* num_addrs == 0 */
 			adapter->tx_pcb.data.configure = NO_LOOPBACK | RECV_BROAD;
diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index 9d85efc..902435a 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -1111,12 +1111,14 @@ set_multicast_list(struct net_device *dev)
 	unsigned long flags;
 	struct el3_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
+	int mc_count = netdev_mc_count(dev);
 
 	if (el3_debug > 1) {
 		static int old;
-		if (old != dev->mc_count) {
-			old = dev->mc_count;
-			pr_debug("%s: Setting Rx mode to %d addresses.\n", dev->name, dev->mc_count);
+		if (old != mc_count) {
+			old = mc_count;
+			pr_debug("%s: Setting Rx mode to %d addresses.\n",
+				 dev->name, mc_count);
 		}
 	}
 	spin_lock_irqsave(&lp->lock, flags);
@@ -1124,7 +1126,7 @@ set_multicast_list(struct net_device *dev)
 		outw(SetRxFilter | RxStation | RxMulticast | RxBroadcast | RxProm,
 			 ioaddr + EL3_CMD);
 	}
-	else if (dev->mc_count || (dev->flags&IFF_ALLMULTI)) {
+	else if (mc_count || (dev->flags&IFF_ALLMULTI)) {
 		outw(SetRxFilter | RxStation | RxMulticast | RxBroadcast, ioaddr + EL3_CMD);
 	}
 	else
diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index 27d80ca..6948d66 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -626,7 +626,7 @@ static int init586(struct net_device *dev)
 	volatile struct tdr_cmd_struct *tdr_cmd;
 	volatile struct mcsetup_cmd_struct *mc_cmd;
 	struct dev_mc_list *dmi = dev->mc_list;
-	int num_addrs = dev->mc_count;
+	int num_addrs = netdev_mc_count(dev);
 
 	ptr = (void *) ((char *) p->scb + sizeof(struct scb_struct));
 
@@ -771,7 +771,7 @@ static int init586(struct net_device *dev)
 	 * Multicast setup
 	 */
 
-	if (dev->mc_count) {
+	if (num_addrs) {
 		/* I don't understand this: do we really need memory after the init? */
 		int len = ((char *) p->iscp - (char *) ptr - 8) / 6;
 		if (len <= 0) {
diff --git a/drivers/net/3c527.c b/drivers/net/3c527.c
index 36c4191..ce98269 100644
--- a/drivers/net/3c527.c
+++ b/drivers/net/3c527.c
@@ -1526,10 +1526,10 @@ static void do_mc32_set_multicast_list(struct net_device *dev, int retry)
 
 	if ((dev->flags&IFF_PROMISC) ||
 	    (dev->flags&IFF_ALLMULTI) ||
-	    dev->mc_count > 10)
+	    netdev_mc_count(dev) > 10)
 		/* Enable promiscuous mode */
 		filt |= 1;
-	else if(dev->mc_count)
+	else if (!netdev_mc_empty(dev))
 	{
 		unsigned char block[62];
 		unsigned char *bp;
@@ -1542,16 +1542,17 @@ static void do_mc32_set_multicast_list(struct net_device *dev, int retry)
 		if(!lp->mc_list_valid)
 		{
 			block[1]=0;
-			block[0]=dev->mc_count;
+			block[0]=netdev_mc_count(dev);
 			bp=block+2;
 
-			for(i=0;i<dev->mc_count;i++)
+			for(i=0;i<netdev_mc_count(dev);i++)
 			{
 				memcpy(bp, dmc->dmi_addr, 6);
 				bp+=6;
 				dmc=dmc->next;
 			}
-			if(mc32_command_nowait(dev, 2, block, 2+6*dev->mc_count)==-1)
+			if(mc32_command_nowait(dev, 2, block,
+					       2+6*netdev_mc_count(dev))==-1)
 			{
 				lp->mc_reload_wait = 1;
 				return;
diff --git a/drivers/net/7990.c b/drivers/net/7990.c
index b1e5764..079d0be 100644
--- a/drivers/net/7990.c
+++ b/drivers/net/7990.c
@@ -611,7 +611,7 @@ static void lance_load_multicast (struct net_device *dev)
         ib->filter [1] = 0;
 
         /* Add addresses */
-        for (i = 0; i < dev->mc_count; i++){
+        for (i = 0; i < netdev_mc_count(dev); i++){
                 addrs = dmi->dmi_addr;
                 dmi   = dmi->next;
 
diff --git a/drivers/net/82596.c b/drivers/net/82596.c
index 1663bc9..638ce3b 100644
--- a/drivers/net/82596.c
+++ b/drivers/net/82596.c
@@ -1505,7 +1505,7 @@ static void set_multicast_list(struct net_device *dev)
 	int config = 0, cnt;
 
 	DEB(DEB_MULTI,printk(KERN_DEBUG "%s: set multicast list, %d entries, promisc %s, allmulti %s\n",
-		dev->name, dev->mc_count,
+		dev->name, netdev_mc_count(dev),
 		dev->flags & IFF_PROMISC  ? "ON" : "OFF",
 		dev->flags & IFF_ALLMULTI ? "ON" : "OFF"));
 
@@ -1533,7 +1533,7 @@ static void set_multicast_list(struct net_device *dev)
 		i596_add_cmd(dev, &lp->cf_cmd.cmd);
 	}
 
-	cnt = dev->mc_count;
+	cnt = netdev_mc_count(dev);
 	if (cnt > MAX_MC_CNT)
 	{
 		cnt = MAX_MC_CNT;
@@ -1541,7 +1541,7 @@ static void set_multicast_list(struct net_device *dev)
 			dev->name, cnt);
 	}
 
-	if (dev->mc_count > 0) {
+	if (!netdev_mc_empty(dev)) {
 		struct dev_mc_list *dmi;
 		unsigned char *cp;
 		struct mc_cmd *cmd;
@@ -1550,7 +1550,7 @@ static void set_multicast_list(struct net_device *dev)
 			return;
 		cmd = &lp->mc_cmd;
 		cmd->cmd.command = CmdMulticastList;
-		cmd->mc_cnt = dev->mc_count * 6;
+		cmd->mc_cnt = netdev_mc_count(dev) * 6;
 		cp = cmd->mc_addrs;
 		for (dmi = dev->mc_list; cnt && dmi != NULL; dmi = dmi->next, cnt--, cp += 6) {
 			memcpy(cp, dmi->dmi_addr, 6);
diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
index b7ec036..6a65f66 100644
--- a/drivers/net/a2065.c
+++ b/drivers/net/a2065.c
@@ -619,7 +619,7 @@ static void lance_load_multicast (struct net_device *dev)
 	ib->filter [1] = 0;
 
 	/* Add addresses */
-	for (i = 0; i < dev->mc_count; i++){
+	for (i = 0; i < netdev_mc_count(dev); i++){
 		addrs = dmi->dmi_addr;
 		dmi   = dmi->next;
 
diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index ec624ab..4ae750e 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -2845,7 +2845,7 @@ static void ace_set_multicast_list(struct net_device *dev)
 	 * set the entire multicast list at a time and keeping track of
 	 * it here is going to be messy.
 	 */
-	if ((dev->mc_count) && !(ap->mcast_all)) {
+	if (!netdev_mc_empty(dev) && !ap->mcast_all) {
 		cmd.evt = C_SET_MULTICAST_MODE;
 		cmd.code = C_C_MCAST_ENABLE;
 		cmd.idx = 0;
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index bb27b27..bdffdfb 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -1387,7 +1387,8 @@ static void amd8111e_set_multicast_list(struct net_device *dev)
 	}
 	else
 		writel( PROM, lp->mmio + CMD2);
-	if(dev->flags & IFF_ALLMULTI || dev->mc_count > MAX_FILTER_SIZE){
+	if (dev->flags & IFF_ALLMULTI ||
+	    netdev_mc_count(dev) > MAX_FILTER_SIZE) {
 		/* get all multicast packet */
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
 		lp->mc_list = dev->mc_list;
@@ -1395,7 +1396,7 @@ static void amd8111e_set_multicast_list(struct net_device *dev)
 		amd8111e_writeq(*(u64*)mc_filter,lp->mmio + LADRF);
 		return;
 	}
-	if( dev->mc_count == 0 ){
+	if (netdev_mc_empty(dev)) {
 		/* get only own packets */
 		mc_filter[1] = mc_filter[0] = 0;
 		lp->mc_list = NULL;
@@ -1409,7 +1410,7 @@ static void amd8111e_set_multicast_list(struct net_device *dev)
 	lp->options |= OPTION_MULTICAST_ENABLE;
 	lp->mc_list = dev->mc_list;
 	mc_filter[1] = mc_filter[0] = 0;
-	for (i = 0, mc_ptr = dev->mc_list; mc_ptr && i < dev->mc_count;
+	for (i = 0, mc_ptr = dev->mc_list; mc_ptr && i < netdev_mc_count(dev);
 		     i++, mc_ptr = mc_ptr->next) {
 		bit_num = (ether_crc_le(ETH_ALEN, mc_ptr->dmi_addr) >> 26) & 0x3f;
 		mc_filter[bit_num >> 5] |= 1 << (bit_num & 31);
diff --git a/drivers/net/ariadne.c b/drivers/net/ariadne.c
index e2c2024..08d8be4 100644
--- a/drivers/net/ariadne.c
+++ b/drivers/net/ariadne.c
@@ -819,7 +819,7 @@ static void set_multicast_list(struct net_device *dev)
 	lance->RDP = PROM;		/* Set promiscuous mode */
     } else {
 	short multicast_table[4];
-	int num_addrs = dev->mc_count;
+	int num_addrs = netdev_mc_count(dev);
 	int i;
 	/* We don't use the multicast table, but rely on upper-layer filtering. */
 	memset(multicast_table, (num_addrs == 0) ? 0 : -1,
diff --git a/drivers/net/arm/at91_ether.c b/drivers/net/arm/at91_ether.c
index c8bc60a..17d85d9 100644
--- a/drivers/net/arm/at91_ether.c
+++ b/drivers/net/arm/at91_ether.c
@@ -563,7 +563,7 @@ static void at91ether_sethashtable(struct net_device *dev)
 	mc_filter[0] = mc_filter[1] = 0;
 
 	curr = dev->mc_list;
-	for (i = 0; i < dev->mc_count; i++, curr = curr->next) {
+	for (i = 0; i < netdev_mc_count(dev); i++, curr = curr->next) {
 		if (!curr) break;	/* unexpected end of list */
 
 		bitnr = hash_get_index(curr->dmi_addr);
@@ -592,7 +592,7 @@ static void at91ether_set_multicast_list(struct net_device *dev)
 		at91_emac_write(AT91_EMAC_HSH, -1);
 		at91_emac_write(AT91_EMAC_HSL, -1);
 		cfg |= AT91_EMAC_MTI;
-	} else if (dev->mc_count > 0) {			/* Enable specific multicasts */
+	} else if (!netdev_mc_empty(dev)) { /* Enable specific multicasts */
 		at91ether_sethashtable(dev);
 		cfg |= AT91_EMAC_MTI;
 	} else if (dev->flags & (~IFF_ALLMULTI)) {	/* Disable all multicast mode */
diff --git a/drivers/net/arm/ether3.c b/drivers/net/arm/ether3.c
index 1f7a69c..d9de9bc 100644
--- a/drivers/net/arm/ether3.c
+++ b/drivers/net/arm/ether3.c
@@ -463,7 +463,7 @@ static void ether3_setmulticastlist(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC) {
 		/* promiscuous mode */
 		priv(dev)->regs.config1 |= CFG1_RECVPROMISC;
-	} else if (dev->flags & IFF_ALLMULTI || dev->mc_count) {
+	} else if (dev->flags & IFF_ALLMULTI || !netdev_mc_empty(dev)) {
 		priv(dev)->regs.config1 |= CFG1_RECVSPECBRMULTI;
 	} else
 		priv(dev)->regs.config1 |= CFG1_RECVSPECBROAD;
diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
index c3dfbdd..1a5f78b 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -737,7 +737,7 @@ static void eth_set_mcast_list(struct net_device *dev)
 	struct port *port = netdev_priv(dev);
 	struct dev_mc_list *mclist = dev->mc_list;
 	u8 diffs[ETH_ALEN], *addr;
-	int cnt = dev->mc_count, i;
+	int cnt = netdev_mc_count(dev), i;
 
 	if ((dev->flags & IFF_PROMISC) || !mclist || !cnt) {
 		__raw_writel(DEFAULT_RX_CNTRL0 & ~RX_CNTRL0_ADDR_FLTR_EN,
diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
index be256b3..1dc181a 100644
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -1207,7 +1207,7 @@ ks8695_set_multicast(struct net_device *ndev)
 	if (ndev->flags & IFF_ALLMULTI) {
 		/* enable all multicast mode */
 		ctrl |= DRXC_RM;
-	} else if (ndev->mc_count > KS8695_NR_ADDRESSES) {
+	} else if (netdev_mc_count(ndev) > KS8695_NR_ADDRESSES) {
 		/* more specific multicast addresses than can be
 		 * handled in hardware
 		 */
@@ -1216,7 +1216,7 @@ ks8695_set_multicast(struct net_device *ndev)
 		/* enable specific multicasts */
 		ctrl &= ~DRXC_RM;
 		ks8695_init_partial_multicast(ksp, ndev->mc_list,
-					      ndev->mc_count);
+					      netdev_mc_count(ndev));
 	}
 
 	ks8695_writereg(ksp, KS8695_DRXC, ctrl);
diff --git a/drivers/net/at1700.c b/drivers/net/at1700.c
index b14f479..fe60cd0 100644
--- a/drivers/net/at1700.c
+++ b/drivers/net/at1700.c
@@ -839,12 +839,12 @@ set_rx_mode(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC) {
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		outb(3, ioaddr + RX_MODE);	/* Enable promiscuous mode */
-	} else if (dev->mc_count > MC_FILTERBREAK ||
+	} else if (netdev_mc_count(dev) > MC_FILTERBREAK ||
 			   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		outb(2, ioaddr + RX_MODE);	/* Use normal mode. */
-	} else if (dev->mc_count == 0) {
+	} else if (netdev_mc_empty(dev)) {
 		memset(mc_filter, 0x00, sizeof(mc_filter));
 		outb(1, ioaddr + RX_MODE);	/* Ignore almost all multicasts. */
 	} else {
@@ -852,7 +852,7 @@ set_rx_mode(struct net_device *dev)
 		int i;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
 			 i++, mclist = mclist->next) {
 			unsigned int bit =
 				ether_crc_le(ETH_ALEN, mclist->dmi_addr) >> 26;
diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index cc9ed86..280cfff 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -1097,7 +1097,7 @@ static void set_multicast_list( struct net_device *dev )
 		REGA( CSR15 ) = 0x8000; /* Set promiscuous mode */
 	} else {
 		short multicast_table[4];
-		int num_addrs = dev->mc_count;
+		int num_addrs = netdev_mc_count(dev);
 		int i;
 		/* We don't use the multicast table, but rely on upper-layer
 		 * filtering. */
diff --git a/drivers/net/atp.c b/drivers/net/atp.c
index 2f8261c..a841feb 100644
--- a/drivers/net/atp.c
+++ b/drivers/net/atp.c
@@ -861,7 +861,7 @@ static void set_rx_mode_8002(struct net_device *dev)
 	struct net_local *lp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
-	if (dev->mc_count > 0 || (dev->flags & (IFF_ALLMULTI|IFF_PROMISC)))
+	if (!netdev_mc_empty(dev) || (dev->flags & (IFF_ALLMULTI|IFF_PROMISC)))
 		lp->addr_mode = CMR2h_PROMISC;
 	else
 		lp->addr_mode = CMR2h_Normal;
@@ -877,7 +877,8 @@ static void set_rx_mode_8012(struct net_device *dev)
 
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		new_mode = CMR2h_PROMISC;
-	} else if ((dev->mc_count > 1000)  ||  (dev->flags & IFF_ALLMULTI)) {
+	} else if ((netdev_mc_count(dev) > 1000) ||
+		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		new_mode = CMR2h_Normal;
@@ -885,7 +886,7 @@ static void set_rx_mode_8012(struct net_device *dev)
 		struct dev_mc_list *mclist;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
 			 i++, mclist = mclist->next)
 		{
 			int filterbit = ether_crc_le(ETH_ALEN, mclist->dmi_addr) & 0x3f;
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 6bac046..9337d02 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -1013,7 +1013,7 @@ static void au1000_multicast_list(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		aup->mac->control |= MAC_PROMISCUOUS;
 	} else if ((dev->flags & IFF_ALLMULTI)  ||
-			   dev->mc_count > MULTICAST_FILTER_LIMIT) {
+			   netdev_mc_count(dev) > MULTICAST_FILTER_LIMIT) {
 		aup->mac->control |= MAC_PASS_ALL_MULTI;
 		aup->mac->control &= ~MAC_PROMISCUOUS;
 		printk(KERN_INFO "%s: Pass all multicast\n", dev->name);
@@ -1023,7 +1023,7 @@ static void au1000_multicast_list(struct net_device *dev)
 		u32 mc_filter[2];	/* Multicast hash filter */
 
 		mc_filter[1] = mc_filter[0] = 0;
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
 			 i++, mclist = mclist->next) {
 			set_bit(ether_crc(ETH_ALEN, mclist->dmi_addr)>>26,
 					(long *)mc_filter);
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 44b66be..9091c65 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1691,7 +1691,7 @@ static int __b44_load_mcast(struct b44 *bp, struct net_device *dev)
 	struct dev_mc_list *mclist;
 	int i, num_ents;
 
-	num_ents = min_t(int, dev->mc_count, B44_MCAST_TABLE_SIZE);
+	num_ents = min_t(int, netdev_mc_count(dev), B44_MCAST_TABLE_SIZE);
 	mclist = dev->mc_list;
 	for (i = 0; mclist && i < num_ents; i++, mclist = mclist->next) {
 		__b44_cam_write(bp, mclist->dmi_addr, i + 1);
@@ -1716,7 +1716,7 @@ static void __b44_set_rx_mode(struct net_device *dev)
 		__b44_set_mac_addr(bp);
 
 		if ((dev->flags & IFF_ALLMULTI) ||
-		    (dev->mc_count > B44_MCAST_TABLE_SIZE))
+		    (netdev_mc_count(dev) > B44_MCAST_TABLE_SIZE))
 			val |= RXCONFIG_ALLMULTI;
 		else
 			i = __b44_load_mcast(bp, dev);
diff --git a/drivers/net/bcm63xx_enet.c b/drivers/net/bcm63xx_enet.c
index 0bd47d3..0927ffa 100644
--- a/drivers/net/bcm63xx_enet.c
+++ b/drivers/net/bcm63xx_enet.c
@@ -619,7 +619,7 @@ static void bcm_enet_set_multicast_list(struct net_device *dev)
 
 	/* only 3 perfect match registers left, first one is used for
 	 * own mac address */
-	if ((dev->flags & IFF_ALLMULTI) || dev->mc_count > 3)
+	if ((dev->flags & IFF_ALLMULTI) || netdev_mc_count(dev) > 3)
 		val |= ENET_RXCFG_ALLMCAST_MASK;
 	else
 		val &= ~ENET_RXCFG_ALLMCAST_MASK;
@@ -632,7 +632,7 @@ static void bcm_enet_set_multicast_list(struct net_device *dev)
 	}
 
 	for (i = 0, mc_list = dev->mc_list;
-	     (mc_list != NULL) && (i < dev->mc_count) && (i < 3);
+	     (mc_list != NULL) && (i < netdev_mc_count(dev)) && (i < 3);
 	     i++, mc_list = mc_list->next) {
 		u8 *dmi_addr;
 		u32 tmp;
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 626b76c..0014a4e 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -565,14 +565,15 @@ static void be_set_multicast_list(struct net_device *netdev)
 	}
 
 	/* Enable multicast promisc if num configured exceeds what we support */
-	if (netdev->flags & IFF_ALLMULTI || netdev->mc_count > BE_MAX_MC) {
+	if (netdev->flags & IFF_ALLMULTI ||
+	    netdev_mc_count(netdev) > BE_MAX_MC) {
 		be_cmd_multicast_set(adapter, adapter->if_handle, NULL, 0,
 				&adapter->mc_cmd_mem);
 		goto done;
 	}
 
 	be_cmd_multicast_set(adapter, adapter->if_handle, netdev->mc_list,
-		netdev->mc_count, &adapter->mc_cmd_mem);
+		netdev_mc_count(netdev), &adapter->mc_cmd_mem);
 done:
 	return;
 }
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 0b23bc4..ef7f771 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -819,7 +819,7 @@ static void bfin_mac_multicast_hash(struct net_device *dev)
 
 	emac_hashhi = emac_hashlo = 0;
 
-	for (i = 0; i < dev->mc_count; i++) {
+	for (i = 0; i < netdev_mc_count(dev); i++) {
 		addrs = dmi->dmi_addr;
 		dmi = dmi->next;
 
@@ -862,7 +862,7 @@ static void bfin_mac_set_multicast_list(struct net_device *dev)
 		sysctl = bfin_read_EMAC_OPMODE();
 		sysctl |= PAM;
 		bfin_write_EMAC_OPMODE(sysctl);
-	} else if (dev->mc_count) {
+	} else if (!netdev_mc_empty(dev)) {
 		/* set up multicast hash table */
 		sysctl = bfin_read_EMAC_OPMODE();
 		sysctl |= HM;
diff --git a/drivers/net/bmac.c b/drivers/net/bmac.c
index 9b587c3..189fa69 100644
--- a/drivers/net/bmac.c
+++ b/drivers/net/bmac.c
@@ -973,7 +973,7 @@ static void bmac_set_multicast(struct net_device *dev)
 {
 	struct dev_mc_list *dmi;
 	struct bmac_data *bp = netdev_priv(dev);
-	int num_addrs = dev->mc_count;
+	int num_addrs = netdev_mc_count(dev);
 	unsigned short rx_cfg;
 	int i;
 
@@ -982,7 +982,7 @@ static void bmac_set_multicast(struct net_device *dev)
 
 	XXDEBUG(("bmac: enter bmac_set_multicast, n_addrs=%d\n", num_addrs));
 
-	if((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 64)) {
+	if((dev->flags & IFF_ALLMULTI) || (netdev_mc_count(dev) > 64)) {
 		for (i=0; i<4; i++) bp->hash_table_mask[i] = 0xffff;
 		bmac_update_hash_table_mask(dev, bp);
 		rx_cfg = bmac_rx_on(dev, 1, 0);
@@ -1021,7 +1021,7 @@ static void bmac_set_multicast(struct net_device *dev)
 	unsigned short rx_cfg;
 	u32 crc;
 
-	if((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 64)) {
+	if((dev->flags & IFF_ALLMULTI) || (netdev_mc_count(dev) > 64)) {
 		bmwrite(dev, BHASH0, 0xffff);
 		bmwrite(dev, BHASH1, 0xffff);
 		bmwrite(dev, BHASH2, 0xffff);
@@ -1039,7 +1039,7 @@ static void bmac_set_multicast(struct net_device *dev)
 
 		for(i = 0; i < 4; i++) hash_table[i] = 0;
 
-		for(i = 0; i < dev->mc_count; i++) {
+		for(i = 0; i < netdev_mc_count(dev); i++) {
 			addrs = dmi->dmi_addr;
 			dmi = dmi->next;
 
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 5917b94..c7f5515 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3560,7 +3560,7 @@ bnx2_set_rx_mode(struct net_device *dev)
 
 		memset(mc_filter, 0, 4 * NUM_MC_HASH_REGISTERS);
 
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
 		     i++, mclist = mclist->next) {
 
 			crc = ether_crc_le(ETH_ALEN, mclist->dmi_addr);
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index ffc7381..6d85590 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -11471,7 +11471,8 @@ static void bnx2x_set_rx_mode(struct net_device *dev)
 		rx_mode = BNX2X_RX_MODE_PROMISC;
 
 	else if ((dev->flags & IFF_ALLMULTI) ||
-		 ((dev->mc_count > BNX2X_MAX_MULTICAST) && CHIP_IS_E1(bp)))
+		 ((netdev_mc_count(dev) > BNX2X_MAX_MULTICAST) &&
+		  CHIP_IS_E1(bp)))
 		rx_mode = BNX2X_RX_MODE_ALLMULTI;
 
 	else { /* some multicasts */
@@ -11482,7 +11483,7 @@ static void bnx2x_set_rx_mode(struct net_device *dev)
 						bnx2x_sp(bp, mcast_config);
 
 			for (i = 0, mclist = dev->mc_list;
-			     mclist && (i < dev->mc_count);
+			     mclist && (i < netdev_mc_count(dev));
 			     i++, mclist = mclist->next) {
 
 				config->config_table[i].
@@ -11554,7 +11555,7 @@ static void bnx2x_set_rx_mode(struct net_device *dev)
 			memset(mc_filter, 0, 4 * MC_HASH_SIZE);
 
 			for (i = 0, mclist = dev->mc_list;
-			     mclist && (i < dev->mc_count);
+			     mclist && (i < netdev_mc_count(dev));
 			     i++, mclist = mclist->next) {
 
 				DP(NETIF_MSG_IFUP, "Adding mcast MAC: %pM\n",
diff --git a/drivers/net/chelsio/common.h b/drivers/net/chelsio/common.h
index f6462b5..bb159d9 100644
--- a/drivers/net/chelsio/common.h
+++ b/drivers/net/chelsio/common.h
@@ -97,13 +97,13 @@ struct t1_rx_mode {
 
 #define t1_rx_mode_promisc(rm)	(rm->dev->flags & IFF_PROMISC)
 #define t1_rx_mode_allmulti(rm)	(rm->dev->flags & IFF_ALLMULTI)
-#define t1_rx_mode_mc_cnt(rm)	(rm->dev->mc_count)
+#define t1_rx_mode_mc_cnt(rm)	(netdev_mc_count(rm->dev))
 
 static inline u8 *t1_get_next_mcaddr(struct t1_rx_mode *rm)
 {
 	u8 *addr = NULL;
 
-	if (rm->idx++ < rm->dev->mc_count) {
+	if (rm->idx++ < t1_rx_mode_mc_cnt(rm)) {
 		addr = rm->list->dmi_addr;
 		rm->list = rm->list->next;
 	}
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 8d0be26..c9c537b 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -340,7 +340,7 @@ static void cpmac_set_multicast_list(struct net_device *dev)
 			 * cpmac uses some strange mac address hashing
 			 * (not crc32)
 			 */
-			for (i = 0, iter = dev->mc_list; i < dev->mc_count;
+			for (i = 0, iter = dev->mc_list; i < netdev_mc_count(dev);
 			     i++, iter = iter->next) {
 				bit = 0;
 				tmp = iter->dmi_addr[0];
diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index a24be34..c9309ea 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -1564,7 +1564,7 @@ static void
 set_multicast_list(struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
-	int num_addr = dev->mc_count;
+	int num_addr = netdev_mc_count(dev);
 	unsigned long int lo_bits;
 	unsigned long int hi_bits;
 
diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index faffad4..d1e03b5 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -956,11 +956,11 @@ static void emac_dev_mcast_set(struct net_device *ndev)
 	} else {
 		mbp_enable = (mbp_enable & ~EMAC_MBP_RXPROMISC);
 		if ((ndev->flags & IFF_ALLMULTI) ||
-		    (ndev->mc_count > EMAC_DEF_MAX_MULTICAST_ADDRESSES)) {
+		    netdev_mc_count(ndev) > EMAC_DEF_MAX_MULTICAST_ADDRESSES) {
 			mbp_enable = (mbp_enable | EMAC_MBP_RXMCAST);
 			emac_add_mcast(priv, EMAC_ALL_MULTI_SET, NULL);
 		}
-		if (ndev->mc_count > 0) {
+		if (!netdev_mc_empty(ndev)) {
 			struct dev_mc_list *mc_ptr;
 			mbp_enable = (mbp_enable | EMAC_MBP_RXMCAST);
 			emac_add_mcast(priv, EMAC_ALL_MULTI_CLR, NULL);
diff --git a/drivers/net/de620.c b/drivers/net/de620.c
index 45794f6..a0a6830 100644
--- a/drivers/net/de620.c
+++ b/drivers/net/de620.c
@@ -464,7 +464,7 @@ static int de620_close(struct net_device *dev)
 
 static void de620_set_multicast_list(struct net_device *dev)
 {
-	if (dev->mc_count || dev->flags&(IFF_ALLMULTI|IFF_PROMISC))
+	if (!netdev_mc_empty(dev) || dev->flags&(IFF_ALLMULTI|IFF_PROMISC))
 	{ /* Enable promiscuous mode */
 		de620_set_register(dev, W_TCR, (TCR_DEF & ~RXPBM) | RXALL);
 	}
diff --git a/drivers/net/declance.c b/drivers/net/declance.c
index be95902..76e0de6 100644
--- a/drivers/net/declance.c
+++ b/drivers/net/declance.c
@@ -960,7 +960,7 @@ static void lance_load_multicast(struct net_device *dev)
 	*lib_ptr(ib, filter[3], lp->type) = 0;
 
 	/* Add addresses */
-	for (i = 0; i < dev->mc_count; i++) {
+	for (i = 0; i < netdev_mc_count(dev); i++) {
 		addrs = dmi->dmi_addr;
 		dmi = dmi->next;
 
diff --git a/drivers/net/defxx.c b/drivers/net/defxx.c
index 98da085..5adb1e0 100644
--- a/drivers/net/defxx.c
+++ b/drivers/net/defxx.c
@@ -2227,7 +2227,7 @@ static void dfx_ctl_set_multicast_list(struct net_device *dev)
 		 *		 perfect filtering will be used.
 		 */
 
-		if (dev->mc_count > (PI_CMD_ADDR_FILTER_K_SIZE - bp->uc_count))
+		if (netdev_mc_count(dev) > (PI_CMD_ADDR_FILTER_K_SIZE - bp->uc_count))
 			{
 			bp->group_prom	= PI_FSTATE_K_PASS;		/* Enable LLC group prom mode */
 			bp->mc_count	= 0;					/* Don't add mc addrs to CAM */
@@ -2235,7 +2235,7 @@ static void dfx_ctl_set_multicast_list(struct net_device *dev)
 		else
 			{
 			bp->group_prom	= PI_FSTATE_K_BLOCK;	/* Disable LLC group prom mode */
-			bp->mc_count	= dev->mc_count;		/* Add mc addrs to CAM */
+			bp->mc_count	= netdev_mc_count(dev);		/* Add mc addrs to CAM */
 			}
 
 		/* Copy addresses to multicast address table, then update adapter CAM */
diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index 0c1f491..314bc96 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -1287,7 +1287,7 @@ static void SetMulticastFilter(struct net_device *dev)
 			lp->init_block.mcast_table[i] = 0;
 		}
 		/* Add multicast addresses */
-		for (i = 0; i < dev->mc_count; i++) {	/* for each address in the list */
+		for (i = 0; i < netdev_mc_count(dev); i++) {	/* for each address in the list */
 			addrs = dmi->dmi_addr;
 			dmi = dmi->next;
 			if ((*addrs & 0x01) == 1) {	/* multicast address? */
diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index 2a8b6a7..dea4095 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -1128,17 +1128,17 @@ set_multicast (struct net_device *dev)
 		/* Receive all frames promiscuously. */
 		rx_mode = ReceiveAllFrames;
 	} else if ((dev->flags & IFF_ALLMULTI) ||
-			(dev->mc_count > multicast_filter_limit)) {
+			(netdev_mc_count(dev) > multicast_filter_limit)) {
 		/* Receive broadcast and multicast frames */
 		rx_mode = ReceiveBroadcast | ReceiveMulticast | ReceiveUnicast;
-	} else if (dev->mc_count > 0) {
+	} else if (!netdev_mc_empty(dev)) {
 		int i;
 		struct dev_mc_list *mclist;
 		/* Receive broadcast frames and multicast frames filtering
 		   by Hashtable */
 		rx_mode =
 		    ReceiveBroadcast | ReceiveMulticastHash | ReceiveUnicast;
-		for (i=0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i=0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
 				i++, mclist=mclist->next)
 		{
 			int bit, index = 0;
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index b377300..da0985a 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -725,7 +725,7 @@ dm9000_hash_table(struct net_device *dev)
 {
 	board_info_t *db = netdev_priv(dev);
 	struct dev_mc_list *mcptr = dev->mc_list;
-	int mc_cnt = dev->mc_count;
+	int mc_cnt = netdev_mc_count(dev);
 	int i, oft;
 	u32 hash_val;
 	u16 hash_table[4];
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 5c7a155..e8c0e82 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1538,7 +1538,7 @@ static void e100_multi(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 {
 	struct net_device *netdev = nic->netdev;
 	struct dev_mc_list *list = netdev->mc_list;
-	u16 i, count = min(netdev->mc_count, E100_MAX_MULTICAST_ADDRS);
+	u16 i, count = min(netdev_mc_count(netdev), E100_MAX_MULTICAST_ADDRS);
 
 	cb->command = cpu_to_le16(cb_multi);
 	cb->u.multi.count = cpu_to_le16(count * ETH_ALEN);
@@ -1552,7 +1552,7 @@ static void e100_set_multicast_list(struct net_device *netdev)
 	struct nic *nic = netdev_priv(netdev);
 
 	DPRINTK(HW, DEBUG, "mc_count=%d, flags=0x%04X\n",
-		netdev->mc_count, netdev->flags);
+		netdev_mc_count(netdev), netdev->flags);
 
 	if (netdev->flags & IFF_PROMISC)
 		nic->flags |= promiscuous;
@@ -1560,7 +1560,7 @@ static void e100_set_multicast_list(struct net_device *netdev)
 		nic->flags &= ~promiscuous;
 
 	if (netdev->flags & IFF_ALLMULTI ||
-		netdev->mc_count > E100_MAX_MULTICAST_ADDRS)
+		netdev_mc_count(netdev) > E100_MAX_MULTICAST_ADDRS)
 		nic->flags |= multicast_all;
 	else
 		nic->flags &= ~multicast_all;
diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index 94c5949..488bc13 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -1288,8 +1288,9 @@ set_multicast_list(struct net_device *dev)
 	short ioaddr = dev->base_addr;
 	unsigned short mode;
 	struct dev_mc_list *dmi=dev->mc_list;
+	int mc_count = mc_count;
 
-	if (dev->flags&(IFF_ALLMULTI|IFF_PROMISC) || dev->mc_count > 63)
+	if (dev->flags&(IFF_ALLMULTI|IFF_PROMISC) || mc_count > 63)
 	{
 		eepro_sw2bank2(ioaddr); /* be CAREFUL, BANK 2 now */
 		mode = inb(ioaddr + REG2);
@@ -1299,7 +1300,7 @@ set_multicast_list(struct net_device *dev)
 		eepro_sw2bank0(ioaddr); /* Return to BANK 0 now */
 	}
 
-	else if (dev->mc_count==0 )
+	else if (mc_count == 0)
 	{
 		eepro_sw2bank2(ioaddr); /* be CAREFUL, BANK 2 now */
 		mode = inb(ioaddr + REG2);
@@ -1329,9 +1330,9 @@ set_multicast_list(struct net_device *dev)
 		outw(MC_SETUP, ioaddr + IO_PORT);
 		outw(0, ioaddr + IO_PORT);
 		outw(0, ioaddr + IO_PORT);
-		outw(6*(dev->mc_count + 1), ioaddr + IO_PORT);
+		outw(6 * (mc_count + 1), ioaddr + IO_PORT);
 
-		for (i = 0; i < dev->mc_count; i++)
+		for (i = 0; i < mc_count; i++)
 		{
 			eaddrs=(unsigned short *)dmi->dmi_addr;
 			dmi=dmi->next;
@@ -1348,7 +1349,7 @@ set_multicast_list(struct net_device *dev)
 		outb(MC_SETUP, ioaddr);
 
 		/* Update the transmit queue */
-		i = lp->tx_end + XMT_HEADER + 6*(dev->mc_count + 1);
+		i = lp->tx_end + XMT_HEADER + 6 * (mc_count + 1);
 
 		if (lp->tx_start != lp->tx_end)
 		{
@@ -1380,8 +1381,8 @@ set_multicast_list(struct net_device *dev)
 					break;
 				} else if ((i & 0x0f) == 0x03)	{ /* MC-Done */
 					printk(KERN_DEBUG "%s: set Rx mode to %d address%s.\n",
-						dev->name, dev->mc_count,
-						dev->mc_count > 1 ? "es":"");
+						dev->name, mc_count,
+						mc_count > 1 ? "es":"");
 					break;
 				}
 			}
diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
index 6fbfc8e..d804ff1 100644
--- a/drivers/net/eexpress.c
+++ b/drivers/net/eexpress.c
@@ -1578,7 +1578,7 @@ static void eexp_setup_filter(struct net_device *dev)
 {
 	struct dev_mc_list *dmi;
 	unsigned short ioaddr = dev->base_addr;
-	int count = dev->mc_count;
+	int count = netdev_mc_count(dev);
 	int i;
 	if (count > 8) {
 		printk(KERN_INFO "%s: too many multicast addresses (%d)\n",
@@ -1627,9 +1627,9 @@ eexp_set_multicast(struct net_device *dev)
         }
         if (!(dev->flags & IFF_PROMISC)) {
                 eexp_setup_filter(dev);
-                if (lp->old_mc_count != dev->mc_count) {
+                if (lp->old_mc_count != netdev_mc_count(dev)) {
                         kick = 1;
-                        lp->old_mc_count = dev->mc_count;
+                        lp->old_mc_count = netdev_mc_count(dev);
                 }
         }
         if (kick) {
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 7b62336..99e4f83 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -1981,7 +1981,7 @@ static void ehea_set_multicast_list(struct net_device *dev)
 	}
 	ehea_allmulti(dev, 0);
 
-	if (dev->mc_count) {
+	if (!netdev_mc_empty(dev)) {
 		ret = ehea_drop_multicast_list(dev);
 		if (ret) {
 			/* Dropping the current multicast list failed.
@@ -1990,14 +1990,14 @@ static void ehea_set_multicast_list(struct net_device *dev)
 			ehea_allmulti(dev, 1);
 		}
 
-		if (dev->mc_count > port->adapter->max_mc_mac) {
+		if (netdev_mc_count(dev) > port->adapter->max_mc_mac) {
 			ehea_info("Mcast registration limit reached (0x%llx). "
 				  "Use ALLMULTI!",
 				  port->adapter->max_mc_mac);
 			goto out;
 		}
 
-		for (i = 0, k_mcl_entry = dev->mc_list; i < dev->mc_count; i++,
+		for (i = 0, k_mcl_entry = dev->mc_list; i < netdev_mc_count(dev); i++,
 			     k_mcl_entry = k_mcl_entry->next)
 			ehea_add_multicast_entry(port, k_mcl_entry->dmi_addr);
 
diff --git a/drivers/net/enc28j60.c b/drivers/net/enc28j60.c
index 66813c9..3ee32e5 100644
--- a/drivers/net/enc28j60.c
+++ b/drivers/net/enc28j60.c
@@ -1413,7 +1413,7 @@ static void enc28j60_set_multicast_list(struct net_device *dev)
 		if (netif_msg_link(priv))
 			dev_info(&dev->dev, "promiscuous mode\n");
 		priv->rxfilter = RXFILTER_PROMISC;
-	} else if ((dev->flags & IFF_ALLMULTI) || dev->mc_count) {
+	} else if ((dev->flags & IFF_ALLMULTI) || !netdev_mc_empty(dev)) {
 		if (netif_msg_link(priv))
 			dev_info(&dev->dev, "%smulticast mode\n",
 				(dev->flags & IFF_ALLMULTI) ? "all-" : "");
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index c81bc4b..94749eb 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -827,11 +827,11 @@ static void enic_set_multicast_list(struct net_device *netdev)
 	int multicast = (netdev->flags & IFF_MULTICAST) ? 1 : 0;
 	int broadcast = (netdev->flags & IFF_BROADCAST) ? 1 : 0;
 	int promisc = (netdev->flags & IFF_PROMISC) ? 1 : 0;
+	unsigned int mc_count = netdev_mc_count(netdev);
 	int allmulti = (netdev->flags & IFF_ALLMULTI) ||
-	    (netdev->mc_count > ENIC_MULTICAST_PERFECT_FILTERS);
+		       mc_count > ENIC_MULTICAST_PERFECT_FILTERS;
 	unsigned int flags = netdev->flags | (allmulti ? IFF_ALLMULTI : 0);
 	u8 mc_addr[ENIC_MULTICAST_PERFECT_FILTERS][ETH_ALEN];
-	unsigned int mc_count = netdev->mc_count;
 	unsigned int i, j;
 
 	if (mc_count > ENIC_MULTICAST_PERFECT_FILTERS)
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 1f8b114..31a3adb 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -1390,20 +1390,20 @@ static void set_rx_mode(struct net_device *dev)
 		outl(0x002C, ioaddr + RxCtrl);
 		/* Unconditionally log net taps. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
-	} else if ((dev->mc_count > 0)  ||  (dev->flags & IFF_ALLMULTI)) {
+	} else if ((!netdev_mc_empty(dev)) || (dev->flags & IFF_ALLMULTI)) {
 		/* There is apparently a chip bug, so the multicast filter
 		   is never enabled. */
 		/* Too many to filter perfectly -- accept all multicasts. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		outl(0x000C, ioaddr + RxCtrl);
-	} else if (dev->mc_count == 0) {
+	} else if (netdev_mc_empty(dev)) {
 		outl(0x0004, ioaddr + RxCtrl);
 		return;
 	} else {					/* Never executed, for now. */
 		struct dev_mc_list *mclist;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
 			 i++, mclist = mclist->next) {
 			unsigned int bit_nr =
 				ether_crc_le(ETH_ALEN, mclist->dmi_addr) & 0x3f;
diff --git a/drivers/net/eth16i.c b/drivers/net/eth16i.c
index 71bfeec..d3abeee 100644
--- a/drivers/net/eth16i.c
+++ b/drivers/net/eth16i.c
@@ -1359,7 +1359,7 @@ static void eth16i_multicast(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
 
-	if(dev->mc_count || dev->flags&(IFF_ALLMULTI|IFF_PROMISC))
+	if (!netdev_mc_empty(dev) || dev->flags&(IFF_ALLMULTI|IFF_PROMISC))
 	{
 		outb(3, ioaddr + RECEIVE_MODE_REG);
 	} else {
diff --git a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
index dd4ba01..96817a8 100644
--- a/drivers/net/ewrk3.c
+++ b/drivers/net/ewrk3.c
@@ -1213,7 +1213,7 @@ static void SetMulticastFilter(struct net_device *dev)
 		}
 
 		/* Update table */
-		for (i = 0; i < dev->mc_count; i++) {	/* for each address in the list */
+		for (i = 0; i < netdev_mc_count(dev); i++) {	/* for each address in the list */
 			addrs = dmi->dmi_addr;
 			dmi = dmi->next;
 			if ((*addrs & 0x01) == 1) {	/* multicast address? */
diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index e6a9812..f95b5ff 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -1786,7 +1786,7 @@ static void __set_rx_mode(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC) {	/* Set promiscuous. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = CR_W_PROM | CR_W_AB | CR_W_AM;
-	} else if ((dev->mc_count > multicast_filter_limit) ||
+	} else if ((netdev_mc_count(dev) > multicast_filter_limit) ||
 		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to match, or accept all multicasts. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
@@ -1796,7 +1796,7 @@ static void __set_rx_mode(struct net_device *dev)
 		int i;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
 		     i++, mclist = mclist->next) {
 			unsigned int bit;
 			bit = (ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26) ^ 0x3F;
diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 16a1d58..092ac72 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1585,7 +1585,7 @@ static void set_multicast_list(struct net_device *dev)
 
 	dmi = dev->mc_list;
 
-	for (j = 0; j < dev->mc_count; j++, dmi = dmi->next) {
+	for (j = 0; j < netdev_mc_count(dev); j++, dmi = dmi->next) {
 		/* Only support group multicast for now */
 		if (!(dmi->dmi_addr[0] & 1))
 			continue;
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index 848e840..10903b7 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -581,7 +581,7 @@ static void mpc52xx_fec_set_multicast_list(struct net_device *dev)
 			u32 gaddr2 = 0x00000000;
 
 			dmi = dev->mc_list;
-			for (i=0; i<dev->mc_count; i++) {
+			for (i=0; i<netdev_mc_count(dev); i++) {
 				crc = ether_crc_le(6, dmi->dmi_addr) >> 26;
 				if (crc >= 32)
 					gaddr1 |= 1 << (crc-32);
diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
index 22e5a84..482f27d 100644
--- a/drivers/net/fs_enet/mac-fcc.c
+++ b/drivers/net/fs_enet/mac-fcc.c
@@ -218,7 +218,7 @@ static void set_multicast_finish(struct net_device *dev)
 
 	/* if all multi or too many multicasts; just enable all */
 	if ((dev->flags & IFF_ALLMULTI) != 0 ||
-	    dev->mc_count > FCC_MAX_MULTICAST_ADDRS) {
+	    netdev_mc_count(dev) > FCC_MAX_MULTICAST_ADDRS) {
 
 		W32(ep, fen_gaddrh, 0xffffffff);
 		W32(ep, fen_gaddrl, 0xffffffff);
diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
index ca7bcb8..ddf13ef 100644
--- a/drivers/net/fs_enet/mac-fec.c
+++ b/drivers/net/fs_enet/mac-fec.c
@@ -220,7 +220,7 @@ static void set_multicast_finish(struct net_device *dev)
 
 	/* if all multi or too many multicasts; just enable all */
 	if ((dev->flags & IFF_ALLMULTI) != 0 ||
-	    dev->mc_count > FEC_MAX_MULTICAST_ADDRS) {
+	    netdev_mc_count(dev) > FEC_MAX_MULTICAST_ADDRS) {
 		fep->fec.hthi = 0xffffffffU;
 		fep->fec.htlo = 0xffffffffU;
 	}
diff --git a/drivers/net/fs_enet/mac-scc.c b/drivers/net/fs_enet/mac-scc.c
index 008cdd9..141dbc9 100644
--- a/drivers/net/fs_enet/mac-scc.c
+++ b/drivers/net/fs_enet/mac-scc.c
@@ -213,7 +213,7 @@ static void set_multicast_finish(struct net_device *dev)
 
 	/* if all multi or too many multicasts; just enable all */
 	if ((dev->flags & IFF_ALLMULTI) != 0 ||
-	    dev->mc_count > SCC_MAX_MULTICAST_ADDRS) {
+	    netdev_mc_count(dev) > SCC_MAX_MULTICAST_ADDRS) {
 
 		W16(ep, sen_gaddr1, 0xffff);
 		W16(ep, sen_gaddr2, 0xffff);
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 8bd3c9f..c9be090 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2863,7 +2863,7 @@ static void gfar_set_multi(struct net_device *dev)
 			em_num = 0;
 		}
 
-		if (dev->mc_count == 0)
+		if (netdev_mc_empty(dev))
 			return;
 
 		/* Parse the list, and set the appropriate bits */
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index dd72c50..c70b147 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -1854,13 +1854,13 @@ static void set_rx_mode(struct net_device *dev)
 
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		writew(0x000F, ioaddr + AddrMode);
-	} else if ((dev->mc_count > 63)  ||  (dev->flags & IFF_ALLMULTI)) {
+	} else if ((netdev_mc_count(dev) > 63) || (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to match, or accept all multicasts. */
 		writew(0x000B, ioaddr + AddrMode);
-	} else if (dev->mc_count > 0) { /* Must use the CAM filter. */
+	} else if (!netdev_mc_empty(dev)) { /* Must use the CAM filter. */
 		struct dev_mc_list *mclist;
 		int i;
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
 			 i++, mclist = mclist->next) {
 			writel(*(u32*)(mclist->dmi_addr), ioaddr + 0x100 + i*8);
 			writel(0x20000 | (*(u16*)&mclist->dmi_addr[4]),
diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
index 0c2f2e8..debac1b 100644
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -2090,7 +2090,7 @@ static void hp100_set_multicast_list(struct net_device *dev)
 		lp->mac2_mode = HP100_MAC2MODE6;	/* promiscuous mode = get all good */
 		lp->mac1_mode = HP100_MAC1MODE6;	/* packets on the net */
 		memset(&lp->hash_bytes, 0xff, 8);
-	} else if (dev->mc_count || (dev->flags & IFF_ALLMULTI)) {
+	} else if (!netdev_mc_empty(dev) || (dev->flags & IFF_ALLMULTI)) {
 		lp->mac2_mode = HP100_MAC2MODE5;	/* multicast mode = get packets for */
 		lp->mac1_mode = HP100_MAC1MODE5;	/* me, broadcasts and all multicasts */
 #ifdef HP100_MULTICAST_FILTER	/* doesn't work!!! */
@@ -2104,9 +2104,10 @@ static void hp100_set_multicast_list(struct net_device *dev)
 
 			memset(&lp->hash_bytes, 0x00, 8);
 #ifdef HP100_DEBUG
-			printk("hp100: %s: computing hash filter - mc_count = %i\n", dev->name, dev->mc_count);
+			printk("hp100: %s: computing hash filter - mc_count = %i\n",
+			       dev->name, netdev_mc_count(dev));
 #endif
-			for (i = 0, dmi = dev->mc_list; i < dev->mc_count; i++, dmi = dmi->next) {
+			for (i = 0, dmi = dev->mc_list; i < netdev_mc_count(dev); i++, dmi = dmi->next) {
 				addrs = dmi->dmi_addr;
 				if ((*addrs & 0x01) == 0x01) {	/* multicast address? */
 #ifdef HP100_DEBUG
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index fb5e019..b75d27e 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -391,7 +391,7 @@ static void emac_hash_mc(struct emac_instance *dev)
 	struct dev_mc_list *dmi;
 	int i;
 
-	DBG(dev, "hash_mc %d" NL, dev->ndev->mc_count);
+	DBG(dev, "hash_mc %d" NL, netdev_mc_count(dev->ndev));
 
 	memset(gaht_temp, 0, sizeof (gaht_temp));
 
@@ -425,9 +425,9 @@ static inline u32 emac_iff2rmr(struct net_device *ndev)
 	if (ndev->flags & IFF_PROMISC)
 		r |= EMAC_RMR_PME;
 	else if (ndev->flags & IFF_ALLMULTI ||
-			 (ndev->mc_count > EMAC_XAHT_SLOTS(dev)))
+			 (netdev_mc_count(ndev) > EMAC_XAHT_SLOTS(dev)))
 		r |= EMAC_RMR_PMME;
-	else if (ndev->mc_count > 0)
+	else if (!netdev_mc_empty(ndev))
 		r |= EMAC_RMR_MAE;
 
 	return r;
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index a866939..41b9c0e 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -1062,7 +1062,8 @@ static void ibmveth_set_multicast_list(struct net_device *netdev)
 	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	unsigned long lpar_rc;
 
-	if((netdev->flags & IFF_PROMISC) || (netdev->mc_count > adapter->mcastFilterSize)) {
+	if ((netdev->flags & IFF_PROMISC) ||
+	    (netdev_mc_count(netdev) > adapter->mcastFilterSize)) {
 		lpar_rc = h_multicast_ctrl(adapter->vdev->unit_address,
 					   IbmVethMcastEnableRecv |
 					   IbmVethMcastDisableFiltering,
@@ -1083,7 +1084,7 @@ static void ibmveth_set_multicast_list(struct net_device *netdev)
 			ibmveth_error_printk("h_multicast_ctrl rc=%ld when attempting to clear filter table\n", lpar_rc);
 		}
 		/* add the addresses to the filter table */
-		for(i = 0; i < netdev->mc_count; ++i, mclist = mclist->next) {
+		for(i = 0; i < netdev_mc_count(netdev); ++i, mclist = mclist->next) {
 			// add the multicast address to the filter table
 			unsigned long mcast_addr = 0;
 			memcpy(((char *)&mcast_addr)+2, mclist->dmi_addr, 6);
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 0a064ce..0145771 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2858,14 +2858,14 @@ static int igb_write_mc_addr_list(struct net_device *netdev)
 	u32 vmolr = 0;
 	int i;
 
-	if (!netdev->mc_count) {
+	if (netdev_mc_empty(netdev)) {
 		/* nothing to program, so clear mc list */
 		igb_update_mc_addr_list(hw, NULL, 0);
 		igb_restore_vf_multicasts(adapter);
 		return 0;
 	}
 
-	mta_list = kzalloc(netdev->mc_count * 6, GFP_ATOMIC);
+	mta_list = kzalloc(netdev_mc_count(netdev) * 6, GFP_ATOMIC);
 	if (!mta_list)
 		return -ENOMEM;
 
@@ -2875,7 +2875,7 @@ static int igb_write_mc_addr_list(struct net_device *netdev)
 	/* The shared function expects a packed array of only addresses. */
 	mc_ptr = netdev->mc_list;
 
-	for (i = 0; i < netdev->mc_count; i++) {
+	for (i = 0; i < netdev_mc_count(netdev); i++) {
 		if (!mc_ptr)
 			break;
 		memcpy(mta_list + (i*ETH_ALEN), mc_ptr->dmi_addr, ETH_ALEN);
@@ -2884,7 +2884,7 @@ static int igb_write_mc_addr_list(struct net_device *netdev)
 	igb_update_mc_addr_list(hw, mta_list, i);
 	kfree(mta_list);
 
-	return netdev->mc_count;
+	return netdev_mc_count(netdev);
 }
 
 /**
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 23ce07d..6029c40 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -1403,8 +1403,8 @@ static void igbvf_set_multi(struct net_device *netdev)
 	u8  *mta_list = NULL;
 	int i;
 
-	if (netdev->mc_count) {
-		mta_list = kmalloc(netdev->mc_count * 6, GFP_ATOMIC);
+	if (!netdev_mc_empty(netdev)) {
+		mta_list = kmalloc(netdev_mc_count(netdev) * 6, GFP_ATOMIC);
 		if (!mta_list) {
 			dev_err(&adapter->pdev->dev,
 			        "failed to allocate multicast filter list\n");
@@ -1415,7 +1415,7 @@ static void igbvf_set_multi(struct net_device *netdev)
 	/* prepare a packed array of only addresses. */
 	mc_ptr = netdev->mc_list;
 
-	for (i = 0; i < netdev->mc_count; i++) {
+	for (i = 0; i < netdev_mc_count(netdev); i++) {
 		if (!mc_ptr)
 			break;
 		memcpy(mta_list + (i*ETH_ALEN), mc_ptr->dmi_addr,
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index 81a4c5d..0bd5fef 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -1681,14 +1681,15 @@ static void ioc3_set_multicast_list(struct net_device *dev)
 		ioc3_w_emcr(ip->emcr);			/* Clear promiscuous. */
 		(void) ioc3_r_emcr();
 
-		if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 64)) {
+		if ((dev->flags & IFF_ALLMULTI) ||
+		    (netdev_mc_count(dev) > 64)) {
 			/* Too many for hashing to make sense or we want all
 			   multicast packets anyway,  so skip computing all the
 			   hashes and just accept all packets.  */
 			ip->ehar_h = 0xffffffff;
 			ip->ehar_l = 0xffffffff;
 		} else {
-			for (i = 0; i < dev->mc_count; i++) {
+			for (i = 0; i < netdev_mc_count(dev); i++) {
 				char *addr = dmi->dmi_addr;
 				dmi = dmi->next;
 
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index 49f35e2..dbdebd5 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -585,11 +585,11 @@ static void ipg_nic_set_multicast_list(struct net_device *dev)
 		receivemode = IPG_RM_RECEIVEALLFRAMES;
 	} else if ((dev->flags & IFF_ALLMULTI) ||
 		   ((dev->flags & IFF_MULTICAST) &&
-		    (dev->mc_count > IPG_MULTICAST_HASHTABLE_SIZE))) {
+		    (netdev_mc_count(dev) > IPG_MULTICAST_HASHTABLE_SIZE))) {
 		/* NIC to be configured to receive all multicast
 		 * frames. */
 		receivemode |= IPG_RM_RECEIVEMULTICAST;
-	} else if ((dev->flags & IFF_MULTICAST) && (dev->mc_count > 0)) {
+	} else if ((dev->flags & IFF_MULTICAST) && !netdev_mc_empty(dev)) {
 		/* NIC to be configured to receive selected
 		 * multicast addresses. */
 		receivemode |= IPG_RM_RECEIVEMULTICASTHASH;
diff --git a/drivers/net/isa-skeleton.c b/drivers/net/isa-skeleton.c
index 04d0502..bb4a3cd 100644
--- a/drivers/net/isa-skeleton.c
+++ b/drivers/net/isa-skeleton.c
@@ -655,14 +655,15 @@ set_multicast_list(struct net_device *dev)
 		/* Enable promiscuous mode */
 		outw(MULTICAST|PROMISC, ioaddr);
 	}
-	else if((dev->flags&IFF_ALLMULTI) || dev->mc_count > HW_MAX_ADDRS)
+	else if ((dev->flags&IFF_ALLMULTI) ||
+		 netdev_mc_count(dev) > HW_MAX_ADDRS)
 	{
 		/* Disable promiscuous mode, use normal mode. */
 		hardware_set_filter(NULL);
 
 		outw(MULTICAST, ioaddr);
 	}
-	else if(dev->mc_count)
+	else if (!netdev_mc_empty(dev))
 	{
 		/* Walk the address list, and load the filter */
 		hardware_set_filter(dev->mc_list);
diff --git a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
index 16c9191..ff015e1 100644
--- a/drivers/net/iseries_veth.c
+++ b/drivers/net/iseries_veth.c
@@ -958,7 +958,7 @@ static void veth_set_multicast_list(struct net_device *dev)
 	write_lock_irqsave(&port->mcast_gate, flags);
 
 	if ((dev->flags & IFF_PROMISC) || (dev->flags & IFF_ALLMULTI) ||
-			(dev->mc_count > VETH_MAX_MCAST)) {
+			(netdev_mc_count(dev) > VETH_MAX_MCAST)) {
 		port->promiscuous = 1;
 	} else {
 		struct dev_mc_list *dmi = dev->mc_list;
@@ -969,7 +969,7 @@ static void veth_set_multicast_list(struct net_device *dev)
 		/* Update table */
 		port->num_mcast = 0;
 
-		for (i = 0; i < dev->mc_count; i++) {
+		for (i = 0; i < netdev_mc_count(dev); i++) {
 			u8 *addr = dmi->dmi_addr;
 			u64 xaddr = 0;
 
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index c56ea69..6a7b2cc 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1077,7 +1077,7 @@ ixgb_set_multi(struct net_device *netdev)
 		rctl |= IXGB_RCTL_VFE;
 	}
 
-	if (netdev->mc_count > IXGB_MAX_NUM_MULTICAST_ADDRESSES) {
+	if (netdev_mc_count(netdev) > IXGB_MAX_NUM_MULTICAST_ADDRESSES) {
 		rctl |= IXGB_RCTL_MPE;
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 	} else {
@@ -1092,7 +1092,7 @@ ixgb_set_multi(struct net_device *netdev)
 			memcpy(&mta[i * IXGB_ETH_LENGTH_OF_ADDRESS],
 			       mc_ptr->dmi_addr, IXGB_ETH_LENGTH_OF_ADDRESS);
 
-		ixgb_mc_addr_list_update(hw, mta, netdev->mc_count, 0);
+		ixgb_mc_addr_list_update(hw, mta, netdev_mc_count(netdev), 0);
 	}
 }
 
@@ -1616,7 +1616,7 @@ ixgb_update_stats(struct ixgb_adapter *adapter)
 		return;
 
 	if ((netdev->flags & IFF_PROMISC) || (netdev->flags & IFF_ALLMULTI) ||
-	   (netdev->mc_count > IXGB_MAX_NUM_MULTICAST_ADDRESSES)) {
+	   (netdev_mc_count(netdev) > IXGB_MAX_NUM_MULTICAST_ADDRESSES)) {
 		u64 multi = IXGB_READ_REG(&adapter->hw, MPRCL);
 		u32 bcast_l = IXGB_READ_REG(&adapter->hw, BPRCL);
 		u32 bcast_h = IXGB_READ_REG(&adapter->hw, BPRCH);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 2a3c831..e39305b 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2571,7 +2571,7 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 	hw->mac.ops.update_uc_addr_list(hw, netdev);
 
 	/* reprogram multicast list */
-	addr_count = netdev->mc_count;
+	addr_count = netdev_mc_count(netdev);
 	if (addr_count)
 		addr_list = netdev->mc_list->dmi_addr;
 	hw->mac.ops.update_mc_addr_list(hw, addr_list, addr_count,
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index b9f10d0..235b5fd 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -1527,7 +1527,7 @@ static void ixgbevf_set_rx_mode(struct net_device *netdev)
 	int addr_count = 0;
 
 	/* reprogram multicast list */
-	addr_count = netdev->mc_count;
+	addr_count = netdev_mc_count(netdev);
 	if (addr_count)
 		addr_list = netdev->mc_list->dmi_addr;
 	if (hw->mac.ops.update_mc_addr_list)
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 26eed49..d44c39d 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -2013,7 +2013,7 @@ jme_set_multi(struct net_device *netdev)
 
 		jme->reg_rxmcs |= RXMCS_MULFRAME | RXMCS_MULFILTERED;
 		for (i = 0, mclist = netdev->mc_list;
-			mclist && i < netdev->mc_count;
+			mclist && i < netdev_mc_count(netdev);
 			++i, mclist = mclist->next) {
 
 			bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) & 0x3F;
diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index 25e2af6..af0c764 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -490,19 +490,19 @@ static void korina_multicast_list(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC)
 		recognise |= ETH_ARC_PRO;
 
-	else if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 4))
+	else if ((dev->flags & IFF_ALLMULTI) || (netdev_mc_count(dev) > 4))
 		/* All multicast and broadcast */
 		recognise |= ETH_ARC_AM;
 
 	/* Build the hash table */
-	if (dev->mc_count > 4) {
+	if (netdev_mc_count(dev) > 4) {
 		u16 hash_table[4];
 		u32 crc;
 
 		for (i = 0; i < 4; i++)
 			hash_table[i] = 0;
 
-		for (i = 0; i < dev->mc_count; i++) {
+		for (i = 0; i < netdev_mc_count(dev); i++) {
 			char *addrs = dmi->dmi_addr;
 
 			dmi = dmi->next;
diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
index 6d3ac65..9845ab1 100644
--- a/drivers/net/ks8851.c
+++ b/drivers/net/ks8851.c
@@ -965,14 +965,14 @@ static void ks8851_set_rx_mode(struct net_device *dev)
 
 		rxctrl.rxcr1 = (RXCR1_RXME | RXCR1_RXAE |
 				RXCR1_RXPAFMA | RXCR1_RXMAFMA);
-	} else if (dev->flags & IFF_MULTICAST && dev->mc_count > 0) {
+	} else if (dev->flags & IFF_MULTICAST && !netdev_mc_empty(dev)) {
 		struct dev_mc_list *mcptr = dev->mc_list;
 		u32 crc;
 		int i;
 
 		/* accept some multicast */
 
-		for (i = dev->mc_count; i > 0; i--) {
+		for (i = netdev_mc_count(dev); i > 0; i--) {
 			crc = ether_crc(ETH_ALEN, mcptr->dmi_addr);
 			crc >>= (32 - 6);  /* get top six bits */
 
diff --git a/drivers/net/ks8851_mll.c b/drivers/net/ks8851_mll.c
index c0ceebc..ffffb38 100644
--- a/drivers/net/ks8851_mll.c
+++ b/drivers/net/ks8851_mll.c
@@ -1193,8 +1193,8 @@ static void ks_set_rx_mode(struct net_device *netdev)
 	else
 		ks_set_promis(ks, false);
 
-	if ((netdev->flags & IFF_MULTICAST) && netdev->mc_count) {
-		if (netdev->mc_count <= MAX_MCAST_LST) {
+	if ((netdev->flags & IFF_MULTICAST) && netdev_mc_count(netdev)) {
+		if (netdev_mc_count(netdev) <= MAX_MCAST_LST) {
 			int i = 0;
 			for (ptr = netdev->mc_list; ptr; ptr = ptr->next) {
 				if (!(*ptr->dmi_addr & 1))
diff --git a/drivers/net/lance.c b/drivers/net/lance.c
index 8d7d3d4..7b94476 100644
--- a/drivers/net/lance.c
+++ b/drivers/net/lance.c
@@ -1288,7 +1288,7 @@ static void set_multicast_list(struct net_device *dev)
 	} else {
 		short multicast_table[4];
 		int i;
-		int num_addrs=dev->mc_count;
+		int num_addrs=netdev_mc_count(dev);
 		if(dev->flags&IFF_ALLMULTI)
 			num_addrs=1;
 		/* FIXIT: We don't use the multicast table, but rely on upper-layer filtering. */
diff --git a/drivers/net/lib82596.c b/drivers/net/lib82596.c
index b60efd4..371b58b 100644
--- a/drivers/net/lib82596.c
+++ b/drivers/net/lib82596.c
@@ -1380,21 +1380,21 @@ static void set_multicast_list(struct net_device *dev)
 		}
 	}
 
-	cnt = dev->mc_count;
+	cnt = netdev_mc_count(dev);
 	if (cnt > MAX_MC_CNT) {
 		cnt = MAX_MC_CNT;
 		printk(KERN_NOTICE "%s: Only %d multicast addresses supported",
 			dev->name, cnt);
 	}
 
-	if (dev->mc_count > 0) {
+	if (!netdev_mc_empty(dev)) {
 		struct dev_mc_list *dmi;
 		unsigned char *cp;
 		struct mc_cmd *cmd;
 
 		cmd = &dma->mc_cmd;
 		cmd->cmd.command = SWAP16(CmdMulticastList);
-		cmd->mc_cnt = SWAP16(dev->mc_count * 6);
+		cmd->mc_cnt = SWAP16(netdev_mc_count(dev) * 6);
 		cp = cmd->mc_addrs;
 		for (dmi = dev->mc_list;
 		     cnt && dmi != NULL;
diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index a8522bd..8442c47 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -232,7 +232,7 @@ static void temac_set_multicast_list(struct net_device *ndev)
 
 	mutex_lock(&lp->indirect_mutex);
 	if (ndev->flags & (IFF_ALLMULTI | IFF_PROMISC) ||
-	    ndev->mc_count > MULTICAST_CAM_TABLE_NUM) {
+	    netdev_mc_count(ndev) > MULTICAST_CAM_TABLE_NUM) {
 		/*
 		 *	We must make the kernel realise we had to move
 		 *	into promisc mode or we start all out war on
@@ -242,9 +242,9 @@ static void temac_set_multicast_list(struct net_device *ndev)
 		ndev->flags |= IFF_PROMISC;
 		temac_indirect_out32(lp, XTE_AFM_OFFSET, XTE_AFM_EPPRM_MASK);
 		dev_info(&ndev->dev, "Promiscuous mode enabled.\n");
-	} else if (ndev->mc_count) {
+	} else if (!netdev_mc_empty(ndev)) {
 		struct dev_mc_list *mclist = ndev->mc_list;
-		for (i = 0; mclist && i < ndev->mc_count; i++) {
+		for (i = 0; mclist && i < netdev_mc_count(ndev); i++) {
 
 			if (i >= MULTICAST_CAM_TABLE_NUM)
 				break;
diff --git a/drivers/net/lp486e.c b/drivers/net/lp486e.c
index e20fefc..b1f5d79 100644
--- a/drivers/net/lp486e.c
+++ b/drivers/net/lp486e.c
@@ -1253,18 +1253,19 @@ static void set_multicast_list(struct net_device *dev) {
 
 	if (i596_debug > 1)
 		printk ("%s: set multicast list %d\n",
-			dev->name, dev->mc_count);
+			dev->name, netdev_mc_count(dev));
 
-	if (dev->mc_count > 0) {
+	if (!netdev_mc_empty(dev)) {
 		struct dev_mc_list *dmi;
 		char *cp;
-		cmd = kmalloc(sizeof(struct i596_cmd)+2+dev->mc_count*6, GFP_ATOMIC);
+		cmd = kmalloc(sizeof(struct i596_cmd) + 2 +
+			      netdev_mc_count(dev) * 6, GFP_ATOMIC);
 		if (cmd == NULL) {
 			printk (KERN_ERR "%s: set_multicast Memory squeeze.\n", dev->name);
 			return;
 		}
 		cmd->command = CmdMulticastList;
-		*((unsigned short *) (cmd + 1)) = dev->mc_count * 6;
+		*((unsigned short *) (cmd + 1)) = netdev_mc_count(dev) * 6;
 		cp = ((char *)(cmd + 1))+2;
 		for (dmi = dev->mc_list; dmi != NULL; dmi = dmi->next) {
 			memcpy(cp, dmi,6);
@@ -1277,7 +1278,8 @@ static void set_multicast_list(struct net_device *dev) {
 		if (lp->set_conf.pa_next != I596_NULL) {
 			return;
 		}
-		if (dev->mc_count == 0 && !(dev->flags & (IFF_PROMISC | IFF_ALLMULTI))) {
+		if (netdev_mc_empty(dev) &&
+		    !(dev->flags & (IFF_PROMISC | IFF_ALLMULTI))) {
 			lp->i596_config[8] &= ~0x01;
 		} else {
 			lp->i596_config[8] |= 0x01;
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 1d0d4d9..fbc371f 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -901,7 +901,7 @@ static void macb_sethashtable(struct net_device *dev)
 	mc_filter[0] = mc_filter[1] = 0;
 
 	curr = dev->mc_list;
-	for (i = 0; i < dev->mc_count; i++, curr = curr->next) {
+	for (i = 0; i < netdev_mc_count(dev); i++, curr = curr->next) {
 		if (!curr) break;	/* unexpected end of list */
 
 		bitnr = hash_get_index(curr->dmi_addr);
@@ -934,7 +934,7 @@ static void macb_set_rx_mode(struct net_device *dev)
 		macb_writel(bp, HRB, -1);
 		macb_writel(bp, HRT, -1);
 		cfg |= MACB_BIT(NCFGR_MTI);
-	} else if (dev->mc_count > 0) {
+	} else if (!netdev_mc_empty(dev)) {
 		/* Enable specific multicasts */
 		macb_sethashtable(dev);
 		cfg |= MACB_BIT(NCFGR_MTI);
diff --git a/drivers/net/mace.c b/drivers/net/mace.c
index d9fbad3..fdb0bbd 100644
--- a/drivers/net/mace.c
+++ b/drivers/net/mace.c
@@ -606,7 +606,7 @@ static void mace_set_multicast(struct net_device *dev)
 	} else {
 	    for (i = 0; i < 8; i++)
 		multicast_filter[i] = 0;
-	    for (i = 0; i < dev->mc_count; i++) {
+	    for (i = 0; i < netdev_mc_count(dev); i++) {
 	        crc = ether_crc_le(6, dmi->dmi_addr);
 		j = crc >> 26;	/* bit number in multicast_filter */
 		multicast_filter[j >> 3] |= 1 << (j & 7);
diff --git a/drivers/net/macmace.c b/drivers/net/macmace.c
index 44f3c28..740accb 100644
--- a/drivers/net/macmace.c
+++ b/drivers/net/macmace.c
@@ -518,7 +518,7 @@ static void mace_set_multicast(struct net_device *dev)
 		} else {
 			for (i = 0; i < 8; i++)
 				multicast_filter[i] = 0;
-			for (i = 0; i < dev->mc_count; i++) {
+			for (i = 0; i < netdev_mc_count(dev); i++) {
 				crc = ether_crc_le(6, dmi->dmi_addr);
 				j = crc >> 26;	/* bit number in multicast_filter */
 				multicast_filter[j >> 3] |= 1 << (j & 7);
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 2d7b3bb..c64e5b0 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -2488,7 +2488,7 @@ static void __set_rx_mode(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC) { /* Set promiscuous. */
 		rx_mode = RxFilterEnable | AcceptBroadcast
 			| AcceptAllMulticast | AcceptAllPhys | AcceptMyPhys;
-	} else if ((dev->mc_count > multicast_filter_limit) ||
+	} else if ((netdev_mc_count(dev) > multicast_filter_limit) ||
 		   (dev->flags & IFF_ALLMULTI)) {
 		rx_mode = RxFilterEnable | AcceptBroadcast
 			| AcceptAllMulticast | AcceptMyPhys;
@@ -2496,7 +2496,7 @@ static void __set_rx_mode(struct net_device *dev)
 		struct dev_mc_list *mclist;
 		int i;
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
 			 i++, mclist = mclist->next) {
 			int b = (ether_crc(ETH_ALEN, mclist->dmi_addr) >> 23) & 0x1ff;
 			mc_filter[b/8] |= (1 << (b & 0x07));
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index dd45c7a..25f4414 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -554,7 +554,7 @@ void netxen_p2_nic_set_multi(struct net_device *netdev)
 		return;
 	}
 
-	if (netdev->mc_count == 0) {
+	if (netdev_mc_empty(netdev)) {
 		adapter->set_promisc(adapter,
 				NETXEN_NIU_NON_PROMISC_MODE);
 		netxen_nic_disable_mcast_filter(adapter);
@@ -563,7 +563,7 @@ void netxen_p2_nic_set_multi(struct net_device *netdev)
 
 	adapter->set_promisc(adapter, NETXEN_NIU_ALLMULTI_MODE);
 	if (netdev->flags & IFF_ALLMULTI ||
-			netdev->mc_count > adapter->max_mc_count) {
+			netdev_mc_count(netdev) > adapter->max_mc_count) {
 		netxen_nic_disable_mcast_filter(adapter);
 		return;
 	}
@@ -573,7 +573,7 @@ void netxen_p2_nic_set_multi(struct net_device *netdev)
 	for (mc_ptr = netdev->mc_list; mc_ptr; mc_ptr = mc_ptr->next, index++)
 		netxen_nic_set_mcast_addr(adapter, index, mc_ptr->dmi_addr);
 
-	if (index != netdev->mc_count)
+	if (index != netdev_mc_count(netdev))
 		printk(KERN_WARNING "%s: %s multicast address count mismatch\n",
 			netxen_nic_driver_name, netdev->name);
 
@@ -704,12 +704,12 @@ void netxen_p3_nic_set_multi(struct net_device *netdev)
 	}
 
 	if ((netdev->flags & IFF_ALLMULTI) ||
-			(netdev->mc_count > adapter->max_mc_count)) {
+			(netdev_mc_count(netdev) > adapter->max_mc_count)) {
 		mode = VPORT_MISS_MODE_ACCEPT_MULTI;
 		goto send_fw_cmd;
 	}
 
-	if (netdev->mc_count > 0) {
+	if (!netdev_mc_empty(netdev)) {
 		for (mc_ptr = netdev->mc_list; mc_ptr;
 		     mc_ptr = mc_ptr->next) {
 			nx_p3_nic_add_mac(adapter, mc_ptr->dmi_addr, &del_list);
diff --git a/drivers/net/ni52.c b/drivers/net/ni52.c
index b42f5e5..497c6d5 100644
--- a/drivers/net/ni52.c
+++ b/drivers/net/ni52.c
@@ -597,7 +597,7 @@ static int init586(struct net_device *dev)
 	struct tdr_cmd_struct __iomem *tdr_cmd;
 	struct mcsetup_cmd_struct __iomem *mc_cmd;
 	struct dev_mc_list *dmi = dev->mc_list;
-	int num_addrs = dev->mc_count;
+	int num_addrs = netdev_mc_count(dev);
 
 	ptr = p->scb + 1;
 
diff --git a/drivers/net/ni65.c b/drivers/net/ni65.c
index ae19aaf..9225c76 100644
--- a/drivers/net/ni65.c
+++ b/drivers/net/ni65.c
@@ -849,7 +849,7 @@ static int ni65_lance_reinit(struct net_device *dev)
 
 	 if(dev->flags & IFF_PROMISC)
 		 ni65_init_lance(p,dev->dev_addr,0x00,M_PROM);
-	 else if(dev->mc_count || dev->flags & IFF_ALLMULTI)
+	 else if (netdev_mc_count(dev) || dev->flags & IFF_ALLMULTI)
 		 ni65_init_lance(p,dev->dev_addr,0xff,0x0);
 	 else
 		 ni65_init_lance(p,dev->dev_addr,0x00,0x00);
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index af9a864..7b52d97 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6369,7 +6369,7 @@ static void niu_set_rx_mode(struct net_device *dev)
 	np->flags &= ~(NIU_FLAGS_MCAST | NIU_FLAGS_PROMISC);
 	if (dev->flags & IFF_PROMISC)
 		np->flags |= NIU_FLAGS_PROMISC;
-	if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 0))
+	if ((dev->flags & IFF_ALLMULTI) || (!netdev_mc_empty(dev)))
 		np->flags |= NIU_FLAGS_MCAST;
 
 	alt_cnt = netdev_uc_count(dev);
@@ -6412,7 +6412,7 @@ static void niu_set_rx_mode(struct net_device *dev)
 	if (dev->flags & IFF_ALLMULTI) {
 		for (i = 0; i < 16; i++)
 			hash[i] = 0xffff;
-	} else if (dev->mc_count > 0) {
+	} else if (!netdev_mc_empty(dev)) {
 		for (addr = dev->mc_list; addr; addr = addr->next) {
 			u32 crc = ether_crc_le(ETH_ALEN, addr->da_addr);
 
diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index a3b6aa0..8dd509c 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -1719,7 +1719,7 @@ static void ns83820_set_multicast(struct net_device *ndev)
 	else
 		and_mask &= ~(RFCR_AAU | RFCR_AAM);
 
-	if (ndev->flags & IFF_ALLMULTI || ndev->mc_count)
+	if (ndev->flags & IFF_ALLMULTI || netdev_mc_count(ndev))
 		or_mask |= RFCR_AAM;
 	else
 		and_mask &= ~RFCR_AAM;
diff --git a/drivers/net/octeon/octeon_mgmt.c b/drivers/net/octeon/octeon_mgmt.c
index 6fd8789..3a0f910 100644
--- a/drivers/net/octeon/octeon_mgmt.c
+++ b/drivers/net/octeon/octeon_mgmt.c
@@ -493,8 +493,8 @@ static void octeon_mgmt_set_rx_filtering(struct net_device *netdev)
 	}
 
 	if (netdev->flags & IFF_MULTICAST) {
-		if (cam_mode == 0 || (netdev->flags & IFF_ALLMULTI)
-		    || netdev->mc_count  > available_cam_entries)
+		if (cam_mode == 0 || (netdev->flags & IFF_ALLMULTI) ||
+		    netdev_mc_count(netdev) > available_cam_entries)
 			multicast_mode = 2; /* 1 - Accept all multicast.  */
 		else
 			multicast_mode = 0; /* 0 - Use CAM.  */
@@ -511,7 +511,7 @@ static void octeon_mgmt_set_rx_filtering(struct net_device *netdev)
 		}
 	}
 	if (multicast_mode == 0) {
-		i = netdev->mc_count;
+		i = netdev_mc_count(netdev);
 		list = netdev->mc_list;
 		while (i--) {
 			octeon_mgmt_cam_state_add(&cam_state, list->da_addr);
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index 2027383..bbdf039 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -1820,7 +1820,7 @@ static void netdrv_set_rx_mode (struct net_device *dev)
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
-	} else if ((dev->mc_count > multicast_filter_limit) ||
+	} else if ((netdev_mc_count(dev) > multicast_filter_limit) ||
 		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
@@ -1829,7 +1829,7 @@ static void netdrv_set_rx_mode (struct net_device *dev)
 		struct dev_mc_list *mclist;
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0;
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
 		     i++, mclist = mclist->next) {
 			int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
 
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 98938ea..3d1d3a7 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -1148,7 +1148,7 @@ static void set_rx_mode(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC)
 		outw(SetRxFilter | RxStation | RxMulticast | RxBroadcast | RxProm,
 			 ioaddr + EL3_CMD);
-	else if (dev->mc_count || (dev->flags & IFF_ALLMULTI))
+	else if (!netdev_mc_empty(dev) || (dev->flags & IFF_ALLMULTI))
 		outw(SetRxFilter|RxStation|RxMulticast|RxBroadcast, ioaddr + EL3_CMD);
 	else
 		outw(SetRxFilter | RxStation | RxBroadcast, ioaddr + EL3_CMD);
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 322e11d..091e0b0 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -886,7 +886,7 @@ static void set_rx_mode(struct net_device *dev)
 
     if (dev->flags & IFF_PROMISC)
 	opts |= RxMulticast | RxProm;
-    else if (dev->mc_count || (dev->flags & IFF_ALLMULTI))
+    else if (!netdev_mc_empty(dev) || (dev->flags & IFF_ALLMULTI))
 	opts |= RxMulticast;
     outw(opts, ioaddr + EL3_CMD);
 }
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 7b17404..3d573ed 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -1187,19 +1187,19 @@ static void set_rx_mode(struct net_device *dev)
     if (dev->flags & IFF_PROMISC) {
 	memset(mc_filter, 0xff, sizeof(mc_filter));
 	outb(3, ioaddr + RX_MODE);	/* Enable promiscuous mode */
-    } else if (dev->mc_count > MC_FILTERBREAK ||
+    } else if (netdev_mc_count(dev) > MC_FILTERBREAK ||
 	       (dev->flags & IFF_ALLMULTI)) {
 	/* Too many to filter perfectly -- accept all multicasts. */
 	memset(mc_filter, 0xff, sizeof(mc_filter));
 	outb(2, ioaddr + RX_MODE);	/* Use normal mode. */
-    } else if (dev->mc_count == 0) {
+    } else if (netdev_mc_empty(dev)) {
 	memset(mc_filter, 0x00, sizeof(mc_filter));
 	outb(1, ioaddr + RX_MODE);	/* Ignore almost all multicasts. */
     } else {
 	struct dev_mc_list *mclist;
 
 	memset(mc_filter, 0, sizeof(mc_filter));
-	for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+	for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
 	     i++, mclist = mclist->next) {
 	    unsigned int bit =
 	    	ether_crc_le(ETH_ALEN, mclist->dmi_addr) >> 26;
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index 12e3233..c42a31a 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -1481,8 +1481,8 @@ static void set_multicast_list(struct net_device *dev)
 #ifdef PCMCIA_DEBUG
   {
     static int old;
-    if (dev->mc_count != old) {
-      old = dev->mc_count;
+    if (netdev_mc_count(dev) != old) {
+      old = netdev_mc_count(dev);
       pr_debug("%s: setting Rx mode to %d addresses.\n",
 	    dev->name, old);
     }
@@ -1490,13 +1490,13 @@ static void set_multicast_list(struct net_device *dev)
 #endif
 
   /* Set multicast_num_addrs. */
-  lp->multicast_num_addrs = dev->mc_count;
+  lp->multicast_num_addrs = netdev_mc_count(dev);
 
   /* Set multicast_ladrf. */
   if (num_addrs > 0) {
     /* Calculate multicast logical address filter */
     memset(lp->multicast_ladrf, 0, MACE_LADRF_LEN);
-    for (i = 0; i < dev->mc_count; i++) {
+    for (i = 0; i < netdev_mc_count(dev); i++) {
       memcpy(adr, dmi->dmi_addr, ETHER_ADDR_LEN);
       dmi = dmi->next;
       BuildLAF(lp->multicast_ladrf, adr);
@@ -1537,15 +1537,15 @@ static void set_multicast_list(struct net_device *dev)
 #ifdef PCMCIA_DEBUG
   {
     static int old;
-    if (dev->mc_count != old) {
-      old = dev->mc_count;
+    if (netdev_mc_count(dev) != old) {
+      old = netdev_mc_count(dev);
       pr_debug("%s: setting Rx mode to %d addresses.\n",
 	    dev->name, old);
     }
   }
 #endif
 
-  lp->multicast_num_addrs = dev->mc_count;
+  lp->multicast_num_addrs = netdev_mc_count(dev);
   restore_multicast_list(dev);
 
 } /* set_multicast_list */
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 6dd486d..d2e86b8 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -1638,8 +1638,8 @@ static void set_rx_mode(struct net_device *dev)
     } else if (dev->flags & IFF_ALLMULTI)
 	rx_cfg_setting = RxStripCRC | RxEnable | RxAllMulti;
     else {
-	if (dev->mc_count)  {
-	    fill_multicast_tbl(dev->mc_count, dev->mc_list,
+	if (!netdev_mc_empty(dev)) {
+	    fill_multicast_tbl(netdev_mc_count(dev), dev->mc_list,
 			       (u_char *)multicast_table);
 	}
 	rx_cfg_setting = RxStripCRC | RxEnable;
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 466fc72..4ace18a 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -1384,7 +1384,7 @@ set_addresses(struct net_device *dev)
 	    if (++n > 9)
 		break;
 	    i = 0;
-	    if (n > 1 && n <= dev->mc_count && dmi) {
+	    if (n > 1 && n <= netdev_mc_count(dev) && dmi) {
 	   	 dmi = dmi->next;
 	    }
 	}
@@ -1394,7 +1394,7 @@ set_addresses(struct net_device *dev)
 	    SelectPage(k);
 	}
 
-	if (n && n <= dev->mc_count && dmi)
+	if (n && n <= netdev_mc_count(dev) && dmi)
 	    addr = dmi->dmi_addr;
 	else
 	    addr = dev->dev_addr;
@@ -1424,9 +1424,9 @@ set_multicast_list(struct net_device *dev)
 
     if (dev->flags & IFF_PROMISC) { /* snoop */
 	PutByte(XIRCREG42_SWC1, value | 0x06); /* set MPE and PME */
-    } else if (dev->mc_count > 9 || (dev->flags & IFF_ALLMULTI)) {
+    } else if (netdev_mc_count(dev) > 9 || (dev->flags & IFF_ALLMULTI)) {
 	PutByte(XIRCREG42_SWC1, value | 0x02); /* set MPE */
-    } else if (dev->mc_count) {
+    } else if (!netdev_mc_empty(dev)) {
 	/* the chip can filter 9 addresses perfectly */
 	PutByte(XIRCREG42_SWC1, value | 0x01);
 	SelectPage(0x40);
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 0dc7ff8..3522794 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -2698,7 +2698,7 @@ static void pcnet32_load_multicast(struct net_device *dev)
 	ib->filter[1] = 0;
 
 	/* Add addresses */
-	for (i = 0; i < dev->mc_count; i++) {
+	for (i = 0; i < netdev_mc_count(dev); i++) {
 		addrs = dmi->dmi_addr;
 		dmi = dmi->next;
 
diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index 0c76859..c19dd4a 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -568,7 +568,7 @@ void gelic_net_set_multi(struct net_device *netdev)
 			status);
 
 	if ((netdev->flags & IFF_ALLMULTI) ||
-	    (netdev->mc_count > GELIC_NET_MC_COUNT_MAX)) {
+	    (netdev_mc_count(netdev) > GELIC_NET_MC_COUNT_MAX)) {
 		status = lv1_net_add_multicast_address(bus_id(card),
 						       dev_id(card),
 						       0, 1);
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index dc6cd69..8ea7f86 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -447,12 +447,12 @@ void qlcnic_set_multi(struct net_device *netdev)
 	}
 
 	if ((netdev->flags & IFF_ALLMULTI) ||
-			(netdev->mc_count > adapter->max_mc_count)) {
+	    (netdev_mc_count(netdev) > adapter->max_mc_count)) {
 		mode = VPORT_MISS_MODE_ACCEPT_MULTI;
 		goto send_fw_cmd;
 	}
 
-	if (netdev->mc_count > 0) {
+	if (!netdev_mc_empty(netdev)) {
 		for (mc_ptr = netdev->mc_list; mc_ptr;
 				     mc_ptr = mc_ptr->next) {
 			qlcnic_nic_add_mac(adapter, mc_ptr->dmi_addr,
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 3cb60e1..dd3e0f1 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -4221,7 +4221,7 @@ static void qlge_set_multicast_list(struct net_device *ndev)
 	 * transition is taking place.
 	 */
 	if ((ndev->flags & IFF_ALLMULTI) ||
-	    (ndev->mc_count > MAX_MULTICAST_ENTRIES)) {
+	    (netdev_mc_count(ndev) > MAX_MULTICAST_ENTRIES)) {
 		if (!test_bit(QL_ALLMULTI, &qdev->flags)) {
 			if (ql_set_routing_reg
 			    (qdev, RT_IDX_ALLMULTI_SLOT, RT_IDX_MCAST, 1)) {
@@ -4243,7 +4243,7 @@ static void qlge_set_multicast_list(struct net_device *ndev)
 		}
 	}
 
-	if (ndev->mc_count) {
+	if (!netdev_mc_empty(ndev)) {
 		status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
 		if (status)
 			goto exit;
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index d68ba7a..b810342 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -958,21 +958,22 @@ static void r6040_multicast_list(struct net_device *dev)
 	}
 	/* Too many multicast addresses
 	 * accept all traffic */
-	else if ((dev->mc_count > MCAST_MAX) || (dev->flags & IFF_ALLMULTI))
+	else if ((netdev_mc_count(dev) > MCAST_MAX) ||
+		 (dev->flags & IFF_ALLMULTI))
 		reg |= 0x0020;
 
 	iowrite16(reg, ioaddr);
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	/* Build the hash table */
-	if (dev->mc_count > MCAST_MAX) {
+	if (netdev_mc_count(dev) > MCAST_MAX) {
 		u16 hash_table[4];
 		u32 crc;
 
 		for (i = 0; i < 4; i++)
 			hash_table[i] = 0;
 
-		for (i = 0; i < dev->mc_count; i++) {
+		for (i = 0; i < netdev_mc_count(dev); i++) {
 			char *addrs = dmi->dmi_addr;
 
 			dmi = dmi->next;
@@ -994,14 +995,14 @@ static void r6040_multicast_list(struct net_device *dev)
 		iowrite16(hash_table[3], ioaddr + MAR3);
 	}
 	/* Multicast Address 1~4 case */
-	for (i = 0, dmi; (i < dev->mc_count) && (i < MCAST_MAX); i++) {
+	for (i = 0, dmi; (i < netdev_mc_count(dev)) && (i < MCAST_MAX); i++) {
 		adrp = (u16 *)dmi->dmi_addr;
 		iowrite16(adrp[0], ioaddr + MID_1L + 8*i);
 		iowrite16(adrp[1], ioaddr + MID_1M + 8*i);
 		iowrite16(adrp[2], ioaddr + MID_1H + 8*i);
 		dmi = dmi->next;
 	}
-	for (i = dev->mc_count; i < MCAST_MAX; i++) {
+	for (i = netdev_mc_count(dev); i < MCAST_MAX; i++) {
 		iowrite16(0xffff, ioaddr + MID_0L + 8*i);
 		iowrite16(0xffff, ioaddr + MID_0M + 8*i);
 		iowrite16(0xffff, ioaddr + MID_0H + 8*i);
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c1bb24c..85c635f 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4758,7 +4758,7 @@ static void rtl_set_rx_mode(struct net_device *dev)
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
-	} else if ((dev->mc_count > multicast_filter_limit) ||
+	} else if ((netdev_mc_count(dev) > multicast_filter_limit) ||
 		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
@@ -4769,7 +4769,7 @@ static void rtl_set_rx_mode(struct net_device *dev)
 
 		rx_mode = AcceptBroadcast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0;
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
 		     i++, mclist = mclist->next) {
 			int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
 			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index d166458..102be16 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -5055,8 +5055,8 @@ static void s2io_set_multicast(struct net_device *dev)
 	}
 
 	/*  Update individual M_CAST address list */
-	if ((!sp->m_cast_flg) && dev->mc_count) {
-		if (dev->mc_count >
+	if ((!sp->m_cast_flg) && netdev_mc_count(dev)) {
+		if (netdev_mc_count(dev) >
 		    (config->max_mc_addr - config->max_mac_addr)) {
 			DBG_PRINT(ERR_DBG,
 				  "%s: No more Rx filters can be added - "
@@ -5066,7 +5066,7 @@ static void s2io_set_multicast(struct net_device *dev)
 		}
 
 		prev_cnt = sp->mc_addr_count;
-		sp->mc_addr_count = dev->mc_count;
+		sp->mc_addr_count = netdev_mc_count(dev);
 
 		/* Clear out the previous list of Mc in the H/W. */
 		for (i = 0; i < prev_cnt; i++) {
@@ -5092,7 +5092,7 @@ static void s2io_set_multicast(struct net_device *dev)
 		}
 
 		/* Create the new Rx filter list and update the same in H/W. */
-		for (i = 0, mclist = dev->mc_list; i < dev->mc_count;
+		for (i = 0, mclist = dev->mc_list; i < netdev_mc_count(dev);
 		     i++, mclist = mclist->next) {
 			memcpy(sp->usr_addrs[i].addr, mclist->dmi_addr,
 			       ETH_ALEN);
diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index fd8cb50..00ff899 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -429,7 +429,7 @@ static void _sc92031_set_mar(struct net_device *dev)
 	u32 mar0 = 0, mar1 = 0;
 
 	if ((dev->flags & IFF_PROMISC) ||
-	    dev->mc_count > multicast_filter_limit ||
+	    netdev_mc_count(dev) > multicast_filter_limit ||
 	    (dev->flags & IFF_ALLMULTI))
 		mar0 = mar1 = 0xffffffff;
 	else if (dev->flags & IFF_MULTICAST) {
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 62d5cd5..fafaf30 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1615,7 +1615,7 @@ static void efx_set_multicast_list(struct net_device *net_dev)
 		memset(mc_hash, 0xff, sizeof(*mc_hash));
 	} else {
 		memset(mc_hash, 0x00, sizeof(*mc_hash));
-		for (i = 0; i < net_dev->mc_count; i++) {
+		for (i = 0; i < netdev_mc_count(net_dev); i++) {
 			crc = ether_crc_le(ETH_ALEN, mc_list->dmi_addr);
 			bit = crc & (EFX_MCAST_HASH_ENTRIES - 1);
 			set_bit_le(bit, mc_hash->byte);
diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index 6b364a6..ed999d3 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -660,7 +660,7 @@ static void sgiseeq_set_multicast(struct net_device *dev)
 
 	if(dev->flags & IFF_PROMISC)
 		sp->mode = SEEQ_RCMD_RANY;
-	else if ((dev->flags & IFF_ALLMULTI) || dev->mc_count)
+	else if ((dev->flags & IFF_ALLMULTI) || !netdev_mc_empty(dev))
 		sp->mode = SEEQ_RCMD_RBMCAST;
 	else
 		sp->mode = SEEQ_RCMD_RBCAST;
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 626de76..8c4e38f 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -841,7 +841,7 @@ static void sis190_set_rx_mode(struct net_device *dev)
 			AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 			AcceptAllPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
-	} else if ((dev->mc_count > multicast_filter_limit) ||
+	} else if ((netdev_mc_count(dev) > multicast_filter_limit) ||
 		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
@@ -852,7 +852,7 @@ static void sis190_set_rx_mode(struct net_device *dev)
 
 		rx_mode = AcceptBroadcast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0;
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
 		     i++, mclist = mclist->next) {
 			int bit_nr =
 				ether_crc(ETH_ALEN, mclist->dmi_addr) & 0x3f;
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index 20c5ce4..32ae87c 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -2288,7 +2288,7 @@ static void set_rx_mode(struct net_device *net_dev)
 		rx_mode = RFPromiscuous;
 		for (i = 0; i < table_entries; i++)
 			mc_filter[i] = 0xffff;
-	} else if ((net_dev->mc_count > multicast_filter_limit) ||
+	} else if ((netdev_mc_count(net_dev) > multicast_filter_limit) ||
 		   (net_dev->flags & IFF_ALLMULTI)) {
 		/* too many multicast addresses or accept all multicast packet */
 		rx_mode = RFAAB | RFAAM;
@@ -2301,7 +2301,7 @@ static void set_rx_mode(struct net_device *net_dev)
 		struct dev_mc_list *mclist;
 		rx_mode = RFAAB;
 		for (i = 0, mclist = net_dev->mc_list;
-			mclist && i < net_dev->mc_count;
+			mclist && i < netdev_mc_count(net_dev);
 			i++, mclist = mclist->next) {
 			unsigned int bit_nr =
 				sis900_mcast_bitnr(mclist->dmi_addr, sis_priv->chipset_rev);
diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index 6b955a4..346adfa 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -872,14 +872,14 @@ static void skfp_ctl_set_multicast_list_wo_lock(struct net_device *dev)
 		if (dev->flags & IFF_ALLMULTI) {
 			mac_drv_rx_mode(smc, RX_ENABLE_ALLMULTI);
 			pr_debug(KERN_INFO "ENABLE ALL MC ADDRESSES\n");
-		} else if (dev->mc_count > 0) {
-			if (dev->mc_count <= FPMAX_MULTICAST) {
+		} else if (!netdev_mc_empty(dev)) {
+			if (netdev_mc_count(dev) <= FPMAX_MULTICAST) {
 				/* use exact filtering */
 
 				// point to first multicast addr
 				dmi = dev->mc_list;
 
-				for (i = 0; i < dev->mc_count; i++) {
+				for (i = 0; i < netdev_mc_count(dev); i++) {
 					mac_add_multicast(smc, 
 							  (struct fddi_addr *)dmi->dmi_addr, 
 							  1);
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 5ff46eb..36ead52 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2932,7 +2932,7 @@ static void genesis_set_multicast(struct net_device *dev)
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
-	int i, count = dev->mc_count;
+	int i, count = netdev_mc_count(dev);
 	struct dev_mc_list *list = dev->mc_list;
 	u32 mode;
 	u8 filter[8];
@@ -2987,7 +2987,7 @@ static void yukon_set_multicast(struct net_device *dev)
 		reg &= ~(GM_RXCR_UCF_ENA | GM_RXCR_MCF_ENA);
 	else if (dev->flags & IFF_ALLMULTI)	/* all multicast */
 		memset(filter, 0xff, sizeof(filter));
-	else if (dev->mc_count == 0 && !rx_pause)/* no multicast */
+	else if (netdev_mc_empty(dev) && !rx_pause)/* no multicast */
 		reg &= ~GM_RXCR_MCF_ENA;
 	else {
 		int i;
@@ -2996,7 +2996,7 @@ static void yukon_set_multicast(struct net_device *dev)
 		if (rx_pause)
 			yukon_add_filter(filter, pause_mc_addr);
 
-		for (i = 0; list && i < dev->mc_count; i++, list = list->next)
+		for (i = 0; list && i < netdev_mc_count(dev); i++, list = list->next)
 			yukon_add_filter(filter, list->dmi_addr);
 	}
 
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 7443622..c55c6c0 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3620,7 +3620,7 @@ static void sky2_set_multicast(struct net_device *dev)
 		reg &= ~(GM_RXCR_UCF_ENA | GM_RXCR_MCF_ENA);
 	else if (dev->flags & IFF_ALLMULTI)
 		memset(filter, 0xff, sizeof(filter));
-	else if (dev->mc_count == 0 && !rx_pause)
+	else if (netdev_mc_empty(dev) && !rx_pause)
 		reg &= ~GM_RXCR_MCF_ENA;
 	else {
 		int i;
@@ -3629,7 +3629,7 @@ static void sky2_set_multicast(struct net_device *dev)
 		if (rx_pause)
 			sky2_add_filter(filter, pause_mc_addr);
 
-		for (i = 0; list && i < dev->mc_count; i++, list = list->next)
+		for (i = 0; list && i < netdev_mc_count(dev); i++, list = list->next)
 			sky2_add_filter(filter, list->dmi_addr);
 	}
 
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 3c5a4f5..ef9674c 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -1323,7 +1323,7 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 	 * I don't need to zero the multicast table, because the flag is
 	 * checked before the table is
 	 */
-	else if (dev->flags & IFF_ALLMULTI || dev->mc_count > 16) {
+	else if (dev->flags & IFF_ALLMULTI || netdev_mc_count(dev) > 16) {
 		DBG(SMC_DEBUG_MISC, "%s: RCR_ALMUL\n", dev->name);
 		mcr |= MAC_CR_MCPAS_;
 	}
@@ -1340,7 +1340,7 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 	 * the number of the 32 bit register, while the low 5 bits are the bit
 	 * within that register.
 	 */
-	else if (dev->mc_count)  {
+	else if (!netdev_mc_empty(dev)) {
 		int i;
 		struct dev_mc_list *cur_addr;
 
@@ -1351,7 +1351,7 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 		memset(multicast_table, 0, sizeof(multicast_table));
 
 		cur_addr = dev->mc_list;
-		for (i = 0; i < dev->mc_count; i++, cur_addr = cur_addr->next) {
+		for (i = 0; i < netdev_mc_count(dev); i++, cur_addr = cur_addr->next) {
 			u32 position;
 
 			/* do we have a pointer here? */
diff --git a/drivers/net/smc9194.c b/drivers/net/smc9194.c
index 8371b82..41c3ddd 100644
--- a/drivers/net/smc9194.c
+++ b/drivers/net/smc9194.c
@@ -1542,7 +1542,7 @@ static void smc_set_multicast_list(struct net_device *dev)
 	/* We just get all multicast packets even if we only want them
 	 . from one source.  This will be changed at some future
 	 . point. */
-	else if (dev->mc_count )  {
+	else if (!netdev_mc_empty(dev)) {
 		/* support hardware multicasting */
 
 		/* be sure I get rid of flags I might have set */
@@ -1550,7 +1550,7 @@ static void smc_set_multicast_list(struct net_device *dev)
 			ioaddr + RCR );
 		/* NOTE: this has to set the bank, so make sure it is the
 		   last thing called.  The bank is set to zero at the top */
-		smc_setmulticast( ioaddr, dev->mc_count, dev->mc_list );
+		smc_setmulticast(ioaddr, netdev_mc_count(dev), dev->mc_list);
 	}
 	else  {
 		outw( inw( ioaddr + RCR ) & ~(RCR_PROMISC | RCR_ALMUL),
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index ea4fae7..6645012 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -1395,7 +1395,7 @@ static void smc_set_multicast_list(struct net_device *dev)
 	 * I don't need to zero the multicast table, because the flag is
 	 * checked before the table is
 	 */
-	else if (dev->flags & IFF_ALLMULTI || dev->mc_count > 16) {
+	else if (dev->flags & IFF_ALLMULTI || netdev_mc_count(dev) > 16) {
 		DBG(2, "%s: RCR_ALMUL\n", dev->name);
 		lp->rcr_cur_mode |= RCR_ALMUL;
 	}
@@ -1412,7 +1412,7 @@ static void smc_set_multicast_list(struct net_device *dev)
 	 * the number of the 8 bit register, while the low 3 bits are the bit
 	 * within that register.
 	 */
-	else if (dev->mc_count)  {
+	else if (!netdev_mc_empty(dev)) {
 		int i;
 		struct dev_mc_list *cur_addr;
 
@@ -1423,7 +1423,7 @@ static void smc_set_multicast_list(struct net_device *dev)
 		memset(multicast_table, 0, sizeof(multicast_table));
 
 		cur_addr = dev->mc_list;
-		for (i = 0; i < dev->mc_count; i++, cur_addr = cur_addr->next) {
+		for (i = 0; i < netdev_mc_count(dev); i++, cur_addr = cur_addr->next) {
 			int position;
 
 			/* do we have a pointer here? */
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 494cd91..3c1f9aa 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1383,7 +1383,7 @@ static void smsc911x_set_multicast_list(struct net_device *dev)
 		pdata->clear_bits_mask = (MAC_CR_PRMS_ | MAC_CR_HPFILT_);
 		pdata->hashhi = 0;
 		pdata->hashlo = 0;
-	} else if (dev->mc_count > 0) {
+	} else if (!netdev_mc_empty(dev)) {
 		/* Enabling specific multicast addresses */
 		unsigned int hash_high = 0;
 		unsigned int hash_low = 0;
@@ -1408,7 +1408,7 @@ static void smsc911x_set_multicast_list(struct net_device *dev)
 			}
 			mc_list = mc_list->next;
 		}
-		if (count != (unsigned int)dev->mc_count)
+		if (count != (unsigned int)netdev_mc_count(dev))
 			SMSC_WARNING(DRV, "mc_count != dev->mc_count");
 
 		pdata->hashhi = hash_high;
diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index 1495a5d..2bd3c98 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -1062,7 +1062,7 @@ static void smsc9420_set_multicast_list(struct net_device *dev)
 		mac_cr &= (~MAC_CR_PRMS_);
 		mac_cr |= MAC_CR_MCPAS_;
 		mac_cr &= (~MAC_CR_HPFILT_);
-	} else if (dev->mc_count > 0) {
+	} else if (!netdev_mc_empty(dev)) {
 		struct dev_mc_list *mc_list = dev->mc_list;
 		u32 hash_lo = 0, hash_hi = 0;
 
diff --git a/drivers/net/sonic.c b/drivers/net/sonic.c
index 9599ce7..bd8bc66 100644
--- a/drivers/net/sonic.c
+++ b/drivers/net/sonic.c
@@ -541,13 +541,15 @@ static void sonic_multicast_list(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC) {	/* set promiscuous mode */
 		rcr |= SONIC_RCR_PRO;
 	} else {
-		if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 15)) {
+		if ((dev->flags & IFF_ALLMULTI) ||
+		    (netdev_mc_count(dev) > 15)) {
 			rcr |= SONIC_RCR_AMC;
 		} else {
 			if (sonic_debug > 2)
-				printk("sonic_multicast_list: mc_count %d\n", dev->mc_count);
+				printk("sonic_multicast_list: mc_count %d\n",
+				       netdev_mc_count(dev));
 			sonic_set_cam_enable(dev, 1);  /* always enable our own address */
-			for (i = 1; i <= dev->mc_count; i++) {
+			for (i = 1; i <= netdev_mc_count(dev); i++) {
 				addr = dmi->dmi_addr;
 				dmi = dmi->next;
 				sonic_cda_put(dev, i, SONIC_CD_CAP0, addr[1] << 8 | addr[0]);
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index d0556a9..58bc7ac 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1796,15 +1796,15 @@ static void set_rx_mode(struct net_device *dev)
 
 	if (dev->flags & IFF_PROMISC) {	/* Set promiscuous. */
 		rx_mode |= AcceptAll;
-	} else if ((dev->mc_count > multicast_filter_limit) ||
+	} else if ((netdev_mc_count(dev) > multicast_filter_limit) ||
 		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to match, or accept all multicasts. */
 		rx_mode |= AcceptBroadcast|AcceptAllMulticast|PerfectFilter;
-	} else if (dev->mc_count <= 14) {
+	} else if (netdev_mc_count(dev) <= 14) {
 		/* Use the 16 element perfect filter, skip first two entries. */
 		void __iomem *filter_addr = ioaddr + PerfFilterTable + 2 * 16;
 		__be16 *eaddrs;
-		for (i = 2, mclist = dev->mc_list; mclist && i < dev->mc_count + 2;
+		for (i = 2, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev) + 2;
 		     i++, mclist = mclist->next) {
 			eaddrs = (__be16 *)mclist->dmi_addr;
 			writew(be16_to_cpu(eaddrs[2]), filter_addr); filter_addr += 4;
@@ -1825,7 +1825,7 @@ static void set_rx_mode(struct net_device *dev)
 		__le16 mc_filter[32] __attribute__ ((aligned(sizeof(long))));	/* Multicast hash filter */
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
 		     i++, mclist = mclist->next) {
 			/* The chip uses the upper 9 CRC bits
 			   as index into the hash table */
diff --git a/drivers/net/stmmac/dwmac100.c b/drivers/net/stmmac/dwmac100.c
index ac48ed7..576b256 100644
--- a/drivers/net/stmmac/dwmac100.c
+++ b/drivers/net/stmmac/dwmac100.c
@@ -305,13 +305,13 @@ static void dwmac100_set_filter(struct net_device *dev)
 		value |= MAC_CONTROL_PR;
 		value &= ~(MAC_CONTROL_PM | MAC_CONTROL_IF | MAC_CONTROL_HO |
 			   MAC_CONTROL_HP);
-	} else if ((dev->mc_count > HASH_TABLE_SIZE)
+	} else if ((netdev_mc_count(dev) > HASH_TABLE_SIZE)
 		   || (dev->flags & IFF_ALLMULTI)) {
 		value |= MAC_CONTROL_PM;
 		value &= ~(MAC_CONTROL_PR | MAC_CONTROL_IF | MAC_CONTROL_HO);
 		writel(0xffffffff, ioaddr + MAC_HASH_HIGH);
 		writel(0xffffffff, ioaddr + MAC_HASH_LOW);
-	} else if (dev->mc_count == 0) {	/* no multicast */
+	} else if (netdev_mc_empty(dev)) {	/* no multicast */
 		value &= ~(MAC_CONTROL_PM | MAC_CONTROL_PR | MAC_CONTROL_IF |
 			   MAC_CONTROL_HO | MAC_CONTROL_HP);
 	} else {
@@ -327,7 +327,7 @@ static void dwmac100_set_filter(struct net_device *dev)
 
 		memset(mc_filter, 0, sizeof(mc_filter));
 		for (i = 0, mclist = dev->mc_list;
-		     mclist && i < dev->mc_count; i++, mclist = mclist->next) {
+		     mclist && i < netdev_mc_count(dev); i++, mclist = mclist->next) {
 			/* The upper 6 bits of the calculated CRC are used to
 			 * index the contens of the hash table */
 			int bit_nr =
diff --git a/drivers/net/stmmac/dwmac1000_core.c b/drivers/net/stmmac/dwmac1000_core.c
index d812e9c..90dbb4f 100644
--- a/drivers/net/stmmac/dwmac1000_core.c
+++ b/drivers/net/stmmac/dwmac1000_core.c
@@ -83,16 +83,16 @@ static void dwmac1000_set_filter(struct net_device *dev)
 	unsigned int value = 0;
 
 	DBG(KERN_INFO "%s: # mcasts %d, # unicast %d\n",
-	    __func__, dev->mc_count, netdev_uc_count(dev));
+	    __func__, netdev_mc_count(dev), netdev_uc_count(dev));
 
 	if (dev->flags & IFF_PROMISC)
 		value = GMAC_FRAME_FILTER_PR;
-	else if ((dev->mc_count > HASH_TABLE_SIZE)
+	else if ((netdev_mc_count(dev) > HASH_TABLE_SIZE)
 		   || (dev->flags & IFF_ALLMULTI)) {
 		value = GMAC_FRAME_FILTER_PM;	/* pass all multi */
 		writel(0xffffffff, ioaddr + GMAC_HASH_HIGH);
 		writel(0xffffffff, ioaddr + GMAC_HASH_LOW);
-	} else if (dev->mc_count > 0) {
+	} else if (!netdev_mc_empty(dev)) {
 		int i;
 		u32 mc_filter[2];
 		struct dev_mc_list *mclist;
@@ -102,7 +102,7 @@ static void dwmac1000_set_filter(struct net_device *dev)
 
 		memset(mc_filter, 0, sizeof(mc_filter));
 		for (i = 0, mclist = dev->mc_list;
-		     mclist && i < dev->mc_count; i++, mclist = mclist->next) {
+		     mclist && i < netdev_mc_count(dev); i++, mclist = mclist->next) {
 			/* The upper 6 bits of the calculated CRC are used to
 			   index the contens of the hash table */
 			int bit_nr =
diff --git a/drivers/net/sun3_82586.c b/drivers/net/sun3_82586.c
index b447a87..efedc25 100644
--- a/drivers/net/sun3_82586.c
+++ b/drivers/net/sun3_82586.c
@@ -414,7 +414,7 @@ static int init586(struct net_device *dev)
 	volatile struct tdr_cmd_struct *tdr_cmd;
 	volatile struct mcsetup_cmd_struct *mc_cmd;
 	struct dev_mc_list *dmi=dev->mc_list;
-	int num_addrs=dev->mc_count;
+	int num_addrs=netdev_mc_count(dev);
 
 	ptr = (void *) ((char *)p->scb + sizeof(struct scb_struct));
 
diff --git a/drivers/net/sun3lance.c b/drivers/net/sun3lance.c
index 0ca4241..9999886 100644
--- a/drivers/net/sun3lance.c
+++ b/drivers/net/sun3lance.c
@@ -917,7 +917,7 @@ static void set_multicast_list( struct net_device *dev )
 		REGA( CSR15 ) = 0x8000; /* Set promiscuous mode */
 	} else {
 		short multicast_table[4];
-		int num_addrs = dev->mc_count;
+		int num_addrs = netdev_mc_count(dev);
 		int i;
 		/* We don't use the multicast table, but rely on upper-layer
 		 * filtering. */
diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index 25e81eb..dfea56f 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -1013,7 +1013,7 @@ static void bigmac_set_multicast(struct net_device *dev)
 	while ((sbus_readl(bregs + BMAC_RXCFG) & BIGMAC_RXCFG_ENABLE) != 0)
 		udelay(20);
 
-	if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 64)) {
+	if ((dev->flags & IFF_ALLMULTI) || (netdev_mc_count(dev) > 64)) {
 		sbus_writel(0xffff, bregs + BMAC_HTABLE0);
 		sbus_writel(0xffff, bregs + BMAC_HTABLE1);
 		sbus_writel(0xffff, bregs + BMAC_HTABLE2);
@@ -1028,7 +1028,7 @@ static void bigmac_set_multicast(struct net_device *dev)
 		for (i = 0; i < 4; i++)
 			hash_table[i] = 0;
 
-		for (i = 0; i < dev->mc_count; i++) {
+		for (i = 0; i < netdev_mc_count(dev); i++) {
 			addrs = dmi->dmi_addr;
 			dmi = dmi->next;
 
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 0c972e5..4171259 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -1517,18 +1517,18 @@ static void set_rx_mode(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptAll | AcceptMyPhys;
-	} else if ((dev->mc_count > multicast_filter_limit) ||
+	} else if ((netdev_mc_count(dev) > multicast_filter_limit) ||
 		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to match, or accept all multicasts. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
-	} else if (dev->mc_count) {
+	} else if (!netdev_mc_empty(dev)) {
 		struct dev_mc_list *mclist;
 		int bit;
 		int index;
 		int crc;
 		memset (mc_filter, 0, sizeof (mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
 		     i++, mclist = mclist->next) {
 			crc = ether_crc_le (ETH_ALEN, mclist->dmi_addr);
 			for (index=0, bit=0; bit < 6; bit++, crc <<= 1)
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index b55ceb8..d497ec0 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -1837,7 +1837,7 @@ static u32 gem_setup_multicast(struct gem *gp)
 	int i;
 
 	if ((gp->dev->flags & IFF_ALLMULTI) ||
-	    (gp->dev->mc_count > 256)) {
+	    (netdev_mc_count(gp->dev) > 256)) {
 	    	for (i=0; i<16; i++)
 			writel(0xffff, gp->regs + MAC_HASH0 + (i << 2));
 		rxcfg |= MAC_RXCFG_HFE;
@@ -1852,7 +1852,7 @@ static u32 gem_setup_multicast(struct gem *gp)
 		for (i = 0; i < 16; i++)
 			hash_table[i] = 0;
 
-		for (i = 0; i < gp->dev->mc_count; i++) {
+		for (i = 0; i < netdev_mc_count(gp->dev); i++) {
 			char *addrs = dmi->dmi_addr;
 
 			dmi = dmi->next;
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 76ccd31..905df35 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -1516,7 +1516,7 @@ static int happy_meal_init(struct happy_meal *hp)
 
 	HMD(("htable, "));
 	if ((hp->dev->flags & IFF_ALLMULTI) ||
-	    (hp->dev->mc_count > 64)) {
+	    (netdev_mc_count(hp->dev) > 64)) {
 		hme_write32(hp, bregs + BMAC_HTABLE0, 0xffff);
 		hme_write32(hp, bregs + BMAC_HTABLE1, 0xffff);
 		hme_write32(hp, bregs + BMAC_HTABLE2, 0xffff);
@@ -1531,7 +1531,7 @@ static int happy_meal_init(struct happy_meal *hp)
 		for (i = 0; i < 4; i++)
 			hash_table[i] = 0;
 
-		for (i = 0; i < hp->dev->mc_count; i++) {
+		for (i = 0; i < netdev_mc_count(hp->dev); i++) {
 			addrs = dmi->dmi_addr;
 			dmi = dmi->next;
 
@@ -2373,7 +2373,7 @@ static void happy_meal_set_multicast(struct net_device *dev)
 
 	spin_lock_irq(&hp->happy_lock);
 
-	if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 64)) {
+	if ((dev->flags & IFF_ALLMULTI) || (netdev_mc_count(dev) > 64)) {
 		hme_write32(hp, bregs + BMAC_HTABLE0, 0xffff);
 		hme_write32(hp, bregs + BMAC_HTABLE1, 0xffff);
 		hme_write32(hp, bregs + BMAC_HTABLE2, 0xffff);
@@ -2387,7 +2387,7 @@ static void happy_meal_set_multicast(struct net_device *dev)
 		for (i = 0; i < 4; i++)
 			hash_table[i] = 0;
 
-		for (i = 0; i < dev->mc_count; i++) {
+		for (i = 0; i < netdev_mc_count(dev); i++) {
 			addrs = dmi->dmi_addr;
 			dmi = dmi->next;
 
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index 64e7d08..cf9d5bb 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -1196,7 +1196,7 @@ static void lance_load_multicast(struct net_device *dev)
 		return;
 
 	/* Add addresses */
-	for (i = 0; i < dev->mc_count; i++) {
+	for (i = 0; i < netdev_mc_count(dev); i++) {
 		addrs = dmi->dmi_addr;
 		dmi   = dmi->next;
 
diff --git a/drivers/net/sunqe.c b/drivers/net/sunqe.c
index 45c383f..3bc35d8 100644
--- a/drivers/net/sunqe.c
+++ b/drivers/net/sunqe.c
@@ -636,7 +636,7 @@ static void qe_set_multicast(struct net_device *dev)
 	/* Lock out others. */
 	netif_stop_queue(dev);
 
-	if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 64)) {
+	if ((dev->flags & IFF_ALLMULTI) || (netdev_mc_count(dev) > 64)) {
 		sbus_writeb(MREGS_IACONFIG_ACHNGE | MREGS_IACONFIG_LARESET,
 			    qep->mregs + MREGS_IACONFIG);
 		while ((sbus_readb(qep->mregs + MREGS_IACONFIG) & MREGS_IACONFIG_ACHNGE) != 0)
@@ -653,7 +653,7 @@ static void qe_set_multicast(struct net_device *dev)
 		for (i = 0; i < 4; i++)
 			hash_table[i] = 0;
 
-		for (i = 0; i < dev->mc_count; i++) {
+		for (i = 0; i < netdev_mc_count(dev); i++) {
 			addrs = dmi->dmi_addr;
 			dmi = dmi->next;
 
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 033408f..d838d40 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1941,18 +1941,18 @@ tc35815_set_multicast_list(struct net_device *dev)
 		/* Enable promiscuous mode */
 		tc_writel(CAM_CompEn | CAM_BroadAcc | CAM_GroupAcc | CAM_StationAcc, &tr->CAM_Ctl);
 	} else if ((dev->flags & IFF_ALLMULTI) ||
-		  dev->mc_count > CAM_ENTRY_MAX - 3) {
+		  netdev_mc_count(dev) > CAM_ENTRY_MAX - 3) {
 		/* CAM 0, 1, 20 are reserved. */
 		/* Disable promiscuous mode, use normal mode. */
 		tc_writel(CAM_CompEn | CAM_BroadAcc | CAM_GroupAcc, &tr->CAM_Ctl);
-	} else if (dev->mc_count) {
+	} else if (!netdev_mc_empty(dev)) {
 		struct dev_mc_list *cur_addr = dev->mc_list;
 		int i;
 		int ena_bits = CAM_Ena_Bit(CAM_ENTRY_SOURCE);
 
 		tc_writel(0, &tr->CAM_Ctl);
 		/* Walk the address list, and load the filter */
-		for (i = 0; i < dev->mc_count; i++, cur_addr = cur_addr->next) {
+		for (i = 0; i < netdev_mc_count(dev); i++, cur_addr = cur_addr->next) {
 			if (!cur_addr)
 				break;
 			/* entry 0,1 is reserved. */
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index b907bee..ab9b028 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -808,7 +808,7 @@ static void bdx_setmulti(struct net_device *ndev)
 		/* set IMF to accept all multicast frmaes */
 		for (i = 0; i < MAC_MCST_HASH_NUM; i++)
 			WRITE_REG(priv, regRX_MCST_HASH0 + i * 4, ~0);
-	} else if (ndev->mc_count) {
+	} else if (!netdev_mc_empty(ndev)) {
 		u8 hash;
 		struct dev_mc_list *mclist;
 		u32 reg, val;
@@ -840,7 +840,7 @@ static void bdx_setmulti(struct net_device *ndev)
 		}
 
 	} else {
-		DBG("only own mac %d\n", ndev->mc_count);
+		DBG("only own mac %d\n", netdev_mc_count(ndev));
 		rxf_val |= GMAC_RX_FILTER_AB;
 	}
 	WRITE_REG(priv, regGMAC_RXF_A, rxf_val);
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 7195bde..d29282f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9430,7 +9430,7 @@ static void __tg3_set_rx_mode(struct net_device *dev)
 	} else if (dev->flags & IFF_ALLMULTI) {
 		/* Accept all multicast. */
 		tg3_set_multi (tp, 1);
-	} else if (dev->mc_count < 1) {
+	} else if (netdev_mc_empty(dev)) {
 		/* Reject all multicast. */
 		tg3_set_multi (tp, 0);
 	} else {
@@ -9442,7 +9442,7 @@ static void __tg3_set_rx_mode(struct net_device *dev)
 		u32 bit;
 		u32 crc;
 
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
 		     i++, mclist = mclist->next) {
 
 			crc = calc_crc (mclist->dmi_addr, ETH_ALEN);
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 3ec31dc..e44d5a0 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -1335,7 +1335,7 @@ static void TLan_SetMulticastList( struct net_device *dev )
 			TLan_DioWrite32( dev->base_addr, TLAN_HASH_1, 0xFFFFFFFF );
 			TLan_DioWrite32( dev->base_addr, TLAN_HASH_2, 0xFFFFFFFF );
 		} else {
-			for ( i = 0; i < dev->mc_count; i++ ) {
+			for ( i = 0; i < netdev_mc_count(dev); i++ ) {
 				if ( i < 3 ) {
 					TLan_SetMac( dev, i + 1,
 						     (char *) &dmi->dmi_addr );
diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index b0d7db9..eff68e1 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -1408,7 +1408,7 @@ static void xl_set_rx_mode(struct net_device *dev)
 
 	dev_mc_address[0] = dev_mc_address[1] = dev_mc_address[2] = dev_mc_address[3] = 0 ;
 
-        for (i=0,dmi=dev->mc_list;i < dev->mc_count; i++,dmi = dmi->next) {
+        for (i=0,dmi=dev->mc_list;i < netdev_mc_count(dev); i++,dmi = dmi->next) {
                 dev_mc_address[0] |= dmi->dmi_addr[2] ;
                 dev_mc_address[1] |= dmi->dmi_addr[3] ;
                 dev_mc_address[2] |= dmi->dmi_addr[4] ;
diff --git a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
index 66272f2..1ce8f85 100644
--- a/drivers/net/tokenring/ibmtr.c
+++ b/drivers/net/tokenring/ibmtr.c
@@ -996,7 +996,7 @@ static void tok_set_multicast_list(struct net_device *dev)
 	if (/*BMSHELPdev->start == 0 ||*/ ti->open_status != OPEN) return;
 	address[0] = address[1] = address[2] = address[3] = 0;
 	mclist = dev->mc_list;
-	for (i = 0; i < dev->mc_count; i++) {
+	for (i = 0; i < netdev_mc_count(dev); i++) {
 		address[0] |= mclist->dmi_addr[2];
 		address[1] |= mclist->dmi_addr[3];
 		address[2] |= mclist->dmi_addr[4];
diff --git a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/lanstreamer.c
index 3f9d5a2..df77288 100644
--- a/drivers/net/tokenring/lanstreamer.c
+++ b/drivers/net/tokenring/lanstreamer.c
@@ -1303,7 +1303,7 @@ static void streamer_set_rx_mode(struct net_device *dev)
 	writel(streamer_priv->srb,streamer_mmio+LAPA);
 	dev_mc_address[0] = dev_mc_address[1] = dev_mc_address[2] = dev_mc_address[3] = 0 ; 
   
-	for (i=0,dmi=dev->mc_list;i < dev->mc_count; i++,dmi = dmi->next) 
+	for (i=0,dmi=dev->mc_list;i < netdev_mc_count(dev); i++,dmi = dmi->next) 
 	{ 
    	        dev_mc_address[0] |= dmi->dmi_addr[2] ; 
 		dev_mc_address[1] |= dmi->dmi_addr[3] ; 
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
index f010a4d..2cc913d 100644
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -1178,7 +1178,7 @@ static void olympic_set_rx_mode(struct net_device *dev)
 
 	dev_mc_address[0] = dev_mc_address[1] = dev_mc_address[2] = dev_mc_address[3] = 0 ; 
 
-	for (i=0,dmi=dev->mc_list;i < dev->mc_count; i++,dmi = dmi->next) { 
+	for (i=0,dmi=dev->mc_list;i < netdev_mc_count(dev); i++,dmi = dmi->next) { 
 		dev_mc_address[0] |= dmi->dmi_addr[2] ; 
 		dev_mc_address[1] |= dmi->dmi_addr[3] ; 
 		dev_mc_address[2] |= dmi->dmi_addr[4] ; 
diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index e3c42f5..6b88689 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -1214,7 +1214,7 @@ static void tms380tr_set_multicast_list(struct net_device *dev)
 		{
 			int i;
 			struct dev_mc_list *mclist = dev->mc_list;
-			for (i=0; i< dev->mc_count; i++)
+			for (i=0; i< netdev_mc_count(dev); i++)
 			{
 				((char *)(&tp->ocpl.FunctAddr))[0] |=
 					mclist->dmi_addr[2];
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index a69c4a4..f4b30c4 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -1184,7 +1184,7 @@ static void tsi108_set_rx_mode(struct net_device *dev)
 
 	rxcfg &= ~(TSI108_EC_RXCFG_UFE | TSI108_EC_RXCFG_MFE);
 
-	if (dev->flags & IFF_ALLMULTI || dev->mc_count) {
+	if (dev->flags & IFF_ALLMULTI || !netdev_mc_empty(dev)) {
 		int i;
 		struct dev_mc_list *mc = dev->mc_list;
 		rxcfg |= TSI108_EC_RXCFG_MFE | TSI108_EC_RXCFG_MC_HASH;
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 2933020..a4cff23 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -677,7 +677,7 @@ static void build_setup_frame_hash(u16 *setup_frm, struct net_device *dev)
 	memset(hash_table, 0, sizeof(hash_table));
 	set_bit_le(255, hash_table); 			/* Broadcast entry */
 	/* This should work on big-endian machines as well. */
-	for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+	for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
 	     i++, mclist = mclist->next) {
 		int index = ether_crc_le(ETH_ALEN, mclist->dmi_addr) & 0x1ff;
 
@@ -706,7 +706,7 @@ static void build_setup_frame_perfect(u16 *setup_frm, struct net_device *dev)
 
 	/* We have <= 14 addresses so we can use the wonderful
 	   16 address perfect filtering of the Tulip. */
-	for (i = 0, mclist = dev->mc_list; i < dev->mc_count;
+	for (i = 0, mclist = dev->mc_list; i < netdev_mc_count(dev);
 	     i++, mclist = mclist->next) {
 		eaddrs = (u16 *)mclist->dmi_addr;
 		*setup_frm++ = *eaddrs; *setup_frm++ = *eaddrs++;
@@ -741,7 +741,7 @@ static void __de_set_rx_mode (struct net_device *dev)
 		goto out;
 	}
 
-	if ((dev->mc_count > 1000) || (dev->flags & IFF_ALLMULTI)) {
+	if ((netdev_mc_count(dev) > 1000) || (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter well -- accept all multicasts. */
 		macmode |= AcceptAllMulticast;
 		goto out;
@@ -749,7 +749,7 @@ static void __de_set_rx_mode (struct net_device *dev)
 
 	/* Note that only the low-address shortword of setup_frame is valid!
 	   The values are doubled for big-endian architectures. */
-	if (dev->mc_count > 14)	/* Must use a multicast hash table. */
+	if (netdev_mc_count(dev) > 14)	/* Must use a multicast hash table. */
 		build_setup_frame_hash (de->setup_frame, dev);
 	else
 		build_setup_frame_perfect (de->setup_frame, dev);
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index a8349b7..0b6a973 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -1963,10 +1963,10 @@ SetMulticastFilter(struct net_device *dev)
     omr &= ~(OMR_PR | OMR_PM);
     pa = build_setup_frame(dev, ALL);        /* Build the basic frame */
 
-    if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 14)) {
+    if ((dev->flags & IFF_ALLMULTI) || (netdev_mc_count(dev) > 14)) {
 	omr |= OMR_PM;                       /* Pass all multicasts */
     } else if (lp->setup_f == HASH_PERF) {   /* Hash Filtering */
-	for (i=0;i<dev->mc_count;i++) {      /* for each address in the list */
+	for (i = 0; i < netdev_mc_count(dev) ;i++) {
 	    addrs=dmi->dmi_addr;
 	    dmi=dmi->next;
 	    if ((*addrs & 0x01) == 1) {      /* multicast address? */
@@ -1984,7 +1984,7 @@ SetMulticastFilter(struct net_device *dev)
 	    }
 	}
     } else {                                 /* Perfect filtering */
-	for (j=0; j<dev->mc_count; j++) {
+	for (j=0; j<netdev_mc_count(dev); j++) {
 	    addrs=dmi->dmi_addr;
 	    dmi=dmi->next;
 	    for (i=0; i<ETH_ALEN; i++) {
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 5fc61c1..534afbd 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -658,9 +658,9 @@ static void dmfe_init_dm910x(struct DEVICE *dev)
 
 	/* Send setup frame */
 	if (db->chip_id == PCI_DM9132_ID)
-		dm9132_id_table(dev, dev->mc_count);	/* DM9132 */
+		dm9132_id_table(dev, netdev_mc_count(dev));	/* DM9132 */
 	else
-		send_filter_frame(dev, dev->mc_count);	/* DM9102/DM9102A */
+		send_filter_frame(dev, netdev_mc_count(dev));	/* DM9102/DM9102A */
 
 	/* Init CR7, interrupt active bit */
 	db->cr7_data = CR7_DEFAULT;
@@ -1052,6 +1052,7 @@ static void dmfe_set_filter_mode(struct DEVICE * dev)
 {
 	struct dmfe_board_info *db = netdev_priv(dev);
 	unsigned long flags;
+	int mc_count = netdev_mc_count(dev);
 
 	DMFE_DBUG(0, "dmfe_set_filter_mode()", 0);
 	spin_lock_irqsave(&db->lock, flags);
@@ -1064,19 +1065,19 @@ static void dmfe_set_filter_mode(struct DEVICE * dev)
 		return;
 	}
 
-	if (dev->flags & IFF_ALLMULTI || dev->mc_count > DMFE_MAX_MULTICAST) {
-		DMFE_DBUG(0, "Pass all multicast address", dev->mc_count);
+	if (dev->flags & IFF_ALLMULTI || mc_count > DMFE_MAX_MULTICAST) {
+		DMFE_DBUG(0, "Pass all multicast address", mc_count);
 		db->cr6_data &= ~(CR6_PM | CR6_PBF);
 		db->cr6_data |= CR6_PAM;
 		spin_unlock_irqrestore(&db->lock, flags);
 		return;
 	}
 
-	DMFE_DBUG(0, "Set multicast address", dev->mc_count);
+	DMFE_DBUG(0, "Set multicast address", mc_count);
 	if (db->chip_id == PCI_DM9132_ID)
-		dm9132_id_table(dev, dev->mc_count);	/* DM9132 */
+		dm9132_id_table(dev, mc_count);		/* DM9132 */
 	else
-		send_filter_frame(dev, dev->mc_count); 	/* DM9102/DM9102A */
+		send_filter_frame(dev, mc_count);	/* DM9102/DM9102A */
 	spin_unlock_irqrestore(&db->lock, flags);
 }
 
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index e1a5f03..cce2ada 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -997,7 +997,7 @@ static void build_setup_frame_hash(u16 *setup_frm, struct net_device *dev)
 	memset(hash_table, 0, sizeof(hash_table));
 	set_bit_le(255, hash_table); 			/* Broadcast entry */
 	/* This should work on big-endian machines as well. */
-	for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+	for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
 	     i++, mclist = mclist->next) {
 		int index = ether_crc_le(ETH_ALEN, mclist->dmi_addr) & 0x1ff;
 
@@ -1026,7 +1026,7 @@ static void build_setup_frame_perfect(u16 *setup_frm, struct net_device *dev)
 
 	/* We have <= 14 addresses so we can use the wonderful
 	   16 address perfect filtering of the Tulip. */
-	for (i = 0, mclist = dev->mc_list; i < dev->mc_count;
+	for (i = 0, mclist = dev->mc_list; i < netdev_mc_count(dev);
 	     i++, mclist = mclist->next) {
 		eaddrs = (u16 *)mclist->dmi_addr;
 		*setup_frm++ = *eaddrs; *setup_frm++ = *eaddrs++;
@@ -1057,7 +1057,8 @@ static void set_rx_mode(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		tp->csr6 |= AcceptAllMulticast | AcceptAllPhys;
 		csr6 |= AcceptAllMulticast | AcceptAllPhys;
-	} else if ((dev->mc_count > 1000)  ||  (dev->flags & IFF_ALLMULTI)) {
+	} else if ((netdev_mc_count(dev) > 1000) ||
+		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter well -- accept all multicasts. */
 		tp->csr6 |= AcceptAllMulticast;
 		csr6 |= AcceptAllMulticast;
@@ -1066,14 +1067,16 @@ static void set_rx_mode(struct net_device *dev)
 		/* Should verify correctness on big-endian/__powerpc__ */
 		struct dev_mc_list *mclist;
 		int i;
-		if (dev->mc_count > 64) {		/* Arbitrary non-effective limit. */
+		if (netdev_mc_count(dev) > 64) {
+			/* Arbitrary non-effective limit. */
 			tp->csr6 |= AcceptAllMulticast;
 			csr6 |= AcceptAllMulticast;
 		} else {
 			u32 mc_filter[2] = {0, 0};		 /* Multicast hash filter */
 			int filterbit;
-			for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
-				 i++, mclist = mclist->next) {
+			for (i = 0, mclist = dev->mc_list;
+			     mclist && i < netdev_mc_count(dev);
+			     i++, mclist = mclist->next) {
 				if (tp->flags & COMET_MAC_ADDR)
 					filterbit = ether_crc_le(ETH_ALEN, mclist->dmi_addr);
 				else
@@ -1107,7 +1110,8 @@ static void set_rx_mode(struct net_device *dev)
 
 		/* Note that only the low-address shortword of setup_frame is valid!
 		   The values are doubled for big-endian architectures. */
-		if (dev->mc_count > 14) { /* Must use a multicast hash table. */
+		if (netdev_mc_count(dev) > 14) {
+			/* Must use a multicast hash table. */
 			build_setup_frame_hash(tp->setup_frame, dev);
 			tx_flags = 0x08400000 | 192;
 		} else {
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index dc3335d..216ceb3 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -557,7 +557,7 @@ static void uli526x_init(struct net_device *dev)
 	update_cr6(db->cr6_data, ioaddr);
 
 	/* Send setup frame */
-	send_filter_frame(dev, dev->mc_count);	/* M5261/M5263 */
+	send_filter_frame(dev, netdev_mc_count(dev));	/* M5261/M5263 */
 
 	/* Init CR7, interrupt active bit */
 	db->cr7_data = CR7_DEFAULT;
@@ -906,16 +906,18 @@ static void uli526x_set_filter_mode(struct net_device * dev)
 		return;
 	}
 
-	if (dev->flags & IFF_ALLMULTI || dev->mc_count > ULI5261_MAX_MULTICAST) {
-		ULI526X_DBUG(0, "Pass all multicast address", dev->mc_count);
+	if (dev->flags & IFF_ALLMULTI ||
+	    netdev_mc_count(dev) > ULI5261_MAX_MULTICAST) {
+		ULI526X_DBUG(0, "Pass all multicast address",
+			     netdev_mc_count(dev));
 		db->cr6_data &= ~(CR6_PM | CR6_PBF);
 		db->cr6_data |= CR6_PAM;
 		spin_unlock_irqrestore(&db->lock, flags);
 		return;
 	}
 
-	ULI526X_DBUG(0, "Set multicast address", dev->mc_count);
-	send_filter_frame(dev, dev->mc_count); 	/* M5261/M5263 */
+	ULI526X_DBUG(0, "Set multicast address", netdev_mc_count(dev));
+	send_filter_frame(dev, netdev_mc_count(dev)); 	/* M5261/M5263 */
 	spin_unlock_irqrestore(&db->lock, flags);
 }
 
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 9fb89af..98711a9 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -1361,7 +1361,7 @@ static u32 __set_rx_mode(struct net_device *dev)
 		memset(mc_filter, 0xff, sizeof(mc_filter));
 		rx_mode = RxAcceptBroadcast | AcceptMulticast | RxAcceptAllPhys
 			| AcceptMyPhys;
-	} else if ((dev->mc_count > multicast_filter_limit) ||
+	} else if ((netdev_mc_count(dev) > multicast_filter_limit) ||
 		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to match, or accept all multicasts. */
 		memset(mc_filter, 0xff, sizeof(mc_filter));
@@ -1370,8 +1370,9 @@ static u32 __set_rx_mode(struct net_device *dev)
 		struct dev_mc_list *mclist;
 		int i;
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
-			 i++, mclist = mclist->next) {
+		for (i = 0, mclist = dev->mc_list;
+		     mclist && i < netdev_mc_count(dev);
+		     i++, mclist = mclist->next) {
 			int filterbit = (ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26) ^ 0x3F;
 			filterbit &= 0x3f;
 			mc_filter[filterbit >> 5] |= 1 << (filterbit & 31);
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 6e4f754..edabc49 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -924,17 +924,18 @@ typhoon_set_rx_mode(struct net_device *dev)
 	filter = TYPHOON_RX_FILTER_DIRECTED | TYPHOON_RX_FILTER_BROADCAST;
 	if(dev->flags & IFF_PROMISC) {
 		filter |= TYPHOON_RX_FILTER_PROMISCOUS;
-	} else if((dev->mc_count > multicast_filter_limit) ||
+	} else if ((netdev_mc_count(dev) > multicast_filter_limit) ||
 		  (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to match, or accept all multicasts. */
 		filter |= TYPHOON_RX_FILTER_ALL_MCAST;
-	} else if(dev->mc_count) {
+	} else if (!netdev_mc_empty(dev)) {
 		struct dev_mc_list *mclist;
 		int i;
 
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for(i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
-		    i++, mclist = mclist->next) {
+		for (i = 0, mclist = dev->mc_list;
+		     mclist && i < netdev_mc_count(dev);
+		     i++, mclist = mclist->next) {
 			int bit = ether_crc(ETH_ALEN, mclist->dmi_addr) & 0x3f;
 			mc_filter[bit >> 5] |= 1 << (bit & 0x1f);
 		}
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 225f658..a057202 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2031,7 +2031,8 @@ static void ucc_geth_set_multi(struct net_device *dev)
 
 			dmi = dev->mc_list;
 
-			for (i = 0; i < dev->mc_count; i++, dmi = dmi->next) {
+			for (i = 0; i < netdev_mc_count(dev);
+			     i++, dmi = dmi->next) {
 
 				/* Only support group multicast for now.
 				 */
diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index a516185..f025517 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -542,9 +542,9 @@ static void asix_set_multicast(struct net_device *net)
 	if (net->flags & IFF_PROMISC) {
 		rx_ctl |= AX_RX_CTL_PRO;
 	} else if (net->flags & IFF_ALLMULTI ||
-		   net->mc_count > AX_MAX_MCAST) {
+		   netdev_mc_count(net) > AX_MAX_MCAST) {
 		rx_ctl |= AX_RX_CTL_AMALL;
-	} else if (net->mc_count == 0) {
+	} else if (netdev_mc_empty(net)) {
 		/* just broadcast and directed */
 	} else {
 		/* We use the 20 byte dev->data
@@ -558,7 +558,7 @@ static void asix_set_multicast(struct net_device *net)
 		memset(data->multi_filter, 0, AX_MCAST_FILTER_SIZE);
 
 		/* Build the multicast hash filter. */
-		for (i = 0; i < net->mc_count; i++) {
+		for (i = 0; i < netdev_mc_count(net); i++) {
 			crc_bits =
 			    ether_crc(ETH_ALEN,
 				      mc_list->dmi_addr) >> 26;
@@ -754,9 +754,9 @@ static void ax88172_set_multicast(struct net_device *net)
 	if (net->flags & IFF_PROMISC) {
 		rx_ctl |= 0x01;
 	} else if (net->flags & IFF_ALLMULTI ||
-		   net->mc_count > AX_MAX_MCAST) {
+		   netdev_mc_count(net) > AX_MAX_MCAST) {
 		rx_ctl |= 0x02;
-	} else if (net->mc_count == 0) {
+	} else if (netdev_mc_empty(net)) {
 		/* just broadcast and directed */
 	} else {
 		/* We use the 20 byte dev->data
@@ -770,7 +770,7 @@ static void ax88172_set_multicast(struct net_device *net)
 		memset(data->multi_filter, 0, AX_MCAST_FILTER_SIZE);
 
 		/* Build the multicast hash filter. */
-		for (i = 0; i < net->mc_count; i++) {
+		for (i = 0; i < netdev_mc_count(net); i++) {
 			crc_bits =
 			    ether_crc(ETH_ALEN,
 				      mc_list->dmi_addr) >> 26;
diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index 7d3fa06..5a13660 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -648,7 +648,9 @@ static void catc_set_multicast_list(struct net_device *netdev)
 	if (netdev->flags & IFF_ALLMULTI) {
 		memset(catc->multicast, 0xff, 64);
 	} else {
-		for (i = 0, mc = netdev->mc_list; mc && i < netdev->mc_count; i++, mc = mc->next) {
+		for (i = 0, mc = netdev->mc_list;
+		     mc && i < netdev_mc_count(netdev);
+		     i++, mc = mc->next) {
 			u32 crc = ether_crc_le(6, mc->dmi_addr);
 			if (!catc->is_f5u011) {
 				catc->multicast[(crc >> 3) & 0x3f] |= 1 << (crc & 7);
diff --git a/drivers/net/usb/int51x1.c b/drivers/net/usb/int51x1.c
index 55cf708..9ab5c19 100644
--- a/drivers/net/usb/int51x1.c
+++ b/drivers/net/usb/int51x1.c
@@ -139,7 +139,7 @@ static void int51x1_set_multicast(struct net_device *netdev)
 		/* do not expect to see traffic of other PLCs */
 		filter |= PACKET_TYPE_PROMISCUOUS;
 		devinfo(dev, "promiscuous mode enabled");
-	} else if (netdev->mc_count ||
+	} else if (!netdev_mc_empty(netdev) ||
 		  (netdev->flags & IFF_ALLMULTI)) {
 		filter |= PACKET_TYPE_ALL_MULTICAST;
 		devdbg(dev, "receive all multicast enabled");
diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index f1d64ef..52671ea 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -881,7 +881,7 @@ static void kaweth_set_rx_mode(struct net_device *net)
 	if (net->flags & IFF_PROMISC) {
 		packet_filter_bitmap |= KAWETH_PACKET_FILTER_PROMISCUOUS;
 	}
-	else if ((net->mc_count) || (net->flags & IFF_ALLMULTI)) {
+	else if (!netdev_mc_empty(net) || (net->flags & IFF_ALLMULTI)) {
 		packet_filter_bitmap |= KAWETH_PACKET_FILTER_ALL_MULTICAST;
 	}
 
diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index 6fc098f..3466513 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -443,9 +443,9 @@ static void mcs7830_data_set_multicast(struct net_device *net)
 	if (net->flags & IFF_PROMISC) {
 		data->config |= HIF_REG_CONFIG_PROMISCUOUS;
 	} else if (net->flags & IFF_ALLMULTI ||
-		   net->mc_count > MCS7830_MAX_MCAST) {
+		   netdev_mc_count(net) > MCS7830_MAX_MCAST) {
 		data->config |= HIF_REG_CONFIG_ALLMULTICAST;
-	} else if (net->mc_count == 0) {
+	} else if (netdev_mc_empty(net)) {
 		/* just broadcast and directed */
 	} else {
 		/* We use the 20 byte dev->data
@@ -457,7 +457,7 @@ static void mcs7830_data_set_multicast(struct net_device *net)
 		int i;
 
 		/* Build the multicast hash filter. */
-		for (i = 0; i < net->mc_count; i++) {
+		for (i = 0; i < netdev_mc_count(net); i++) {
 			crc_bits = ether_crc(ETH_ALEN, mc_list->dmi_addr) >> 26;
 			data->multi_filter[crc_bits >> 3] |= 1 << (crc_bits & 7);
 			mc_list = mc_list->next;
diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index ed4a508..44ae8f6 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -1232,7 +1232,7 @@ static void pegasus_set_multicast(struct net_device *net)
 		pegasus->eth_regs[EthCtrl2] |= RX_PROMISCUOUS;
 		if (netif_msg_link(pegasus))
 			pr_info("%s: Promiscuous mode enabled.\n", net->name);
-	} else if (net->mc_count || (net->flags & IFF_ALLMULTI)) {
+	} else if (!netdev_mc_empty(net) || (net->flags & IFF_ALLMULTI)) {
 		pegasus->eth_regs[EthCtrl0] |= RX_MULTICAST;
 		pegasus->eth_regs[EthCtrl2] &= ~RX_PROMISCUOUS;
 		if (netif_msg_link(pegasus))
diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index 21ac103..e85c89c 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -711,7 +711,7 @@ static void rtl8150_set_multicast(struct net_device *netdev)
 	if (netdev->flags & IFF_PROMISC) {
 		dev->rx_creg |= cpu_to_le16(0x0001);
 		dev_info(&netdev->dev, "%s: promiscuous mode\n", netdev->name);
-	} else if (netdev->mc_count ||
+	} else if (!netdev_mc_empty(netdev) ||
 		   (netdev->flags & IFF_ALLMULTI)) {
 		dev->rx_creg &= cpu_to_le16(0xfffe);
 		dev->rx_creg |= cpu_to_le16(0x0002);
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 0c3c738..48555d0 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -384,7 +384,7 @@ static void smsc95xx_set_multicast(struct net_device *netdev)
 			devdbg(dev, "receive all multicast enabled");
 		pdata->mac_cr |= MAC_CR_MCPAS_;
 		pdata->mac_cr &= ~(MAC_CR_PRMS_ | MAC_CR_HPFILT_);
-	} else if (dev->net->mc_count > 0) {
+	} else if (!netdev_mc_empty(dev->net)) {
 		struct dev_mc_list *mc_list = dev->net->mc_list;
 		int count = 0;
 
@@ -406,7 +406,7 @@ static void smsc95xx_set_multicast(struct net_device *netdev)
 			mc_list = mc_list->next;
 		}
 
-		if (count != ((u32)dev->net->mc_count))
+		if (count != ((u32) netdev_mc_count(dev->net)))
 			devwarn(dev, "mc_count != dev->mc_count");
 
 		if (netif_msg_drv(dev))
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index a7e0c84..85df7ac 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -1697,7 +1697,7 @@ static void rhine_set_rx_mode(struct net_device *dev)
 		rx_mode = 0x1C;
 		iowrite32(0xffffffff, ioaddr + MulticastFilter0);
 		iowrite32(0xffffffff, ioaddr + MulticastFilter1);
-	} else if ((dev->mc_count > multicast_filter_limit) ||
+	} else if ((netdev_mc_count(dev) > multicast_filter_limit) ||
 		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to match, or accept all multicasts. */
 		iowrite32(0xffffffff, ioaddr + MulticastFilter0);
@@ -1707,7 +1707,8 @@ static void rhine_set_rx_mode(struct net_device *dev)
 		struct dev_mc_list *mclist;
 		int i;
 		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc_list;
+		     mclist && i < netdev_mc_count(dev);
 		     i++, mclist = mclist->next) {
 			int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
 
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index f15485e..bdb19c3 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1132,7 +1132,7 @@ static void velocity_set_multi(struct net_device *dev)
 		writel(0xffffffff, &regs->MARCAM[0]);
 		writel(0xffffffff, &regs->MARCAM[4]);
 		rx_mode = (RCR_AM | RCR_AB | RCR_PROM);
-	} else if ((dev->mc_count > vptr->multicast_limit) ||
+	} else if ((netdev_mc_count(dev) > vptr->multicast_limit) ||
 		   (dev->flags & IFF_ALLMULTI)) {
 		writel(0xffffffff, &regs->MARCAM[0]);
 		writel(0xffffffff, &regs->MARCAM[4]);
@@ -1141,7 +1141,9 @@ static void velocity_set_multi(struct net_device *dev)
 		int offset = MCAM_SIZE - vptr->multicast_limit;
 		mac_get_cam_mask(regs, vptr->mCAMmask);
 
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count; i++, mclist = mclist->next) {
+		for (i = 0, mclist = dev->mc_list;
+		     mclist && i < netdev_mc_count(dev);
+		     i++, mclist = mclist->next) {
 			mac_set_cam(regs, i + offset, mclist->dmi_addr);
 			vptr->mCAMmask[(offset + i) / 8] |= 1 << ((offset + i) & 7);
 		}
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 9d8984a..4c347a3 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -735,6 +735,7 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	struct dev_addr_list *addr;
 	struct netdev_hw_addr *ha;
 	int uc_count;
+	int mc_count;
 	void *buf;
 	int i;
 
@@ -762,9 +763,11 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 			 allmulti ? "en" : "dis");
 
 	uc_count = netdev_uc_count(dev);
+	mc_count = netdev_mc_count(dev);
 	/* MAC filter - use one buffer for both lists */
-	mac_data = buf = kzalloc(((uc_count + dev->mc_count) * ETH_ALEN) +
-				 (2 * sizeof(mac_data->entries)), GFP_ATOMIC);
+	buf = kzalloc(((uc_count + mc_count) * ETH_ALEN) +
+		      (2 * sizeof(mac_data->entries)), GFP_ATOMIC);
+	mac_data = buf;
 	if (!buf) {
 		dev_warn(&dev->dev, "No memory for MAC address buffer\n");
 		return;
@@ -784,13 +787,13 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	/* multicast list and count fill the end */
 	mac_data = (void *)&mac_data->macs[uc_count][0];
 
-	mac_data->entries = dev->mc_count;
+	mac_data->entries = mc_count;
 	addr = dev->mc_list;
-	for (i = 0; i < dev->mc_count; i++, addr = addr->next)
+	for (i = 0; i < mc_count; i++, addr = addr->next)
 		memcpy(&mac_data->macs[i][0], addr->da_addr, ETH_ALEN);
 
 	sg_set_buf(&sg[1], mac_data,
-		   sizeof(mac_data->entries) + (dev->mc_count * ETH_ALEN));
+		   sizeof(mac_data->entries) + (mc_count * ETH_ALEN));
 
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC,
 				  VIRTIO_NET_CTRL_MAC_TABLE_SET,
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index b896f93..ee1b397 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1668,7 +1668,7 @@ static u8 *
 vmxnet3_copy_mc(struct net_device *netdev)
 {
 	u8 *buf = NULL;
-	u32 sz = netdev->mc_count * ETH_ALEN;
+	u32 sz = netdev_mc_count(netdev) * ETH_ALEN;
 
 	/* struct Vmxnet3_RxFilterConf.mfTableLen is u16. */
 	if (sz <= 0xffff) {
@@ -1678,7 +1678,7 @@ vmxnet3_copy_mc(struct net_device *netdev)
 			int i;
 			struct dev_mc_list *mc = netdev->mc_list;
 
-			for (i = 0; i < netdev->mc_count; i++) {
+			for (i = 0; i < netdev_mc_count(netdev); i++) {
 				BUG_ON(!mc);
 				memcpy(buf + i * ETH_ALEN, mc->dmi_addr,
 				       ETH_ALEN);
@@ -1708,12 +1708,12 @@ vmxnet3_set_mc(struct net_device *netdev)
 	if (netdev->flags & IFF_ALLMULTI)
 		new_mode |= VMXNET3_RXM_ALL_MULTI;
 	else
-		if (netdev->mc_count > 0) {
+		if (!netdev_mc_empty(netdev)) {
 			new_table = vmxnet3_copy_mc(netdev);
 			if (new_table) {
 				new_mode |= VMXNET3_RXM_MCAST;
 				rxConf->mfTableLen = cpu_to_le16(
-						netdev->mc_count * ETH_ALEN);
+					netdev_mc_count(netdev) * ETH_ALEN);
 				rxConf->mfTablePA = cpu_to_le64(virt_to_phys(
 						    new_table));
 			} else {
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index a6606b8..c248b01 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -1178,11 +1178,11 @@ static void vxge_set_multicast(struct net_device *dev)
 
 	memset(&mac_info, 0, sizeof(struct macInfo));
 	/* Update individual M_CAST address list */
-	if ((!vdev->all_multi_flg) && dev->mc_count) {
+	if ((!vdev->all_multi_flg) && netdev_mc_count(dev)) {
 
 		mcast_cnt = vdev->vpaths[0].mcast_addr_cnt;
 		list_head = &vdev->vpaths[0].mac_addr_list;
-		if ((dev->mc_count +
+		if ((netdev_mc_count(dev) +
 			(vdev->vpaths[0].mac_addr_cnt - mcast_cnt)) >
 				vdev->vpaths[0].max_mac_addr_cnt)
 			goto _set_all_mcast;
@@ -1217,7 +1217,7 @@ static void vxge_set_multicast(struct net_device *dev)
 		}
 
 		/* Add new ones */
-		for (i = 0, mclist = dev->mc_list; i < dev->mc_count;
+		for (i = 0, mclist = dev->mc_list; i < netdev_mc_count(dev);
 			i++, mclist = mclist->next) {
 
 			memcpy(mac_info.macaddr, mclist->dmi_addr, ETH_ALEN);
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index ef6b78d..c22a34c 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -2310,7 +2310,7 @@ static void airo_set_multicast_list(struct net_device *dev) {
 			airo_set_promisc(ai);
 	}
 
-	if ((dev->flags&IFF_ALLMULTI)||dev->mc_count>0) {
+	if ((dev->flags&IFF_ALLMULTI) || !netdev_mc_empty(dev)) {
 		/* Turn on multicast.  (Should be already setup...) */
 	}
 }
diff --git a/drivers/net/wireless/orinoco/main.c b/drivers/net/wireless/orinoco/main.c
index 753a180..a9e9cea 100644
--- a/drivers/net/wireless/orinoco/main.c
+++ b/drivers/net/wireless/orinoco/main.c
@@ -1668,12 +1668,12 @@ __orinoco_set_multicast_list(struct net_device *dev)
 	/* The Hermes doesn't seem to have an allmulti mode, so we go
 	 * into promiscuous mode and let the upper levels deal. */
 	if ((dev->flags & IFF_PROMISC) || (dev->flags & IFF_ALLMULTI) ||
-	    (dev->mc_count > MAX_MULTICAST(priv))) {
+	    (netdev_mc_count(dev) > MAX_MULTICAST(priv))) {
 		promisc = 1;
 		mc_count = 0;
 	} else {
 		promisc = 0;
-		mc_count = dev->mc_count;
+		mc_count = netdev_mc_count(dev);
 	}
 
 	err = __orinoco_hw_set_multicast_list(priv, dev->mc_list, mc_count,
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 88e1e4e..85905ca 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -1950,7 +1950,7 @@ static void set_multicast_list(struct net_device *dev)
 	if (dev->flags & IFF_ALLMULTI)
 		ray_update_multi_list(dev, 1);
 	else {
-		if (local->num_multi != dev->mc_count)
+		if (local->num_multi != netdev_mc_count(dev))
 			ray_update_multi_list(dev, 0);
 	}
 } /* end set_multicast_list */
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 305c106..14692bc 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -1492,10 +1492,10 @@ static void set_multicast_list(struct usbnet *usbdev)
 		filter |= RNDIS_PACKET_TYPE_PROMISCUOUS |
 			RNDIS_PACKET_TYPE_ALL_LOCAL;
 	} else if (usbdev->net->flags & IFF_ALLMULTI ||
-		   usbdev->net->mc_count > priv->multicast_size) {
+		   netdev_mc_count(usbdev->net) > priv->multicast_size) {
 		filter |= RNDIS_PACKET_TYPE_ALL_MULTICAST;
-	} else if (usbdev->net->mc_count > 0) {
-		size = min(priv->multicast_size, usbdev->net->mc_count);
+	} else if (!netdev_mc_empty(usbdev->net)) {
+		size = min(priv->multicast_size, netdev_mc_count(usbdev->net));
 		buf = kmalloc(size * ETH_ALEN, GFP_KERNEL);
 		if (!buf) {
 			devwarn(usbdev,
diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index 33c8be7..5d2b52f 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -879,16 +879,15 @@ static void zd1201_set_multicast(struct net_device *dev)
 	unsigned char reqbuf[ETH_ALEN*ZD1201_MAXMULTI];
 	int i;
 
-	if (dev->mc_count > ZD1201_MAXMULTI)
+	if (netdev_mc_count(dev) > ZD1201_MAXMULTI)
 		return;
 
-	for (i=0; i<dev->mc_count; i++) {
+	for (i=0; i<netdev_mc_count(dev); i++) {
 		memcpy(reqbuf+i*ETH_ALEN, mc->dmi_addr, ETH_ALEN);
 		mc = mc->next;
 	}
 	zd1201_setconfig(zd, ZD1201_RID_CNFGROUPADDRESS, reqbuf,
-	    dev->mc_count*ETH_ALEN, 0);
-	
+			 netdev_mc_count(dev) * ETH_ALEN, 0);
 }
 
 static int zd1201_config_commit(struct net_device *dev, 
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index 8b231b3..5c88024 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -1301,15 +1301,16 @@ static void set_rx_mode(struct net_device *dev)
 	iowrite16(cfg_value & ~0x1000, ioaddr + Cnfg);
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		iowrite16(0x000F, ioaddr + AddrMode);
-	} else if ((dev->mc_count > 64)  ||  (dev->flags & IFF_ALLMULTI)) {
+	} else if ((netdev_mc_count(dev) > 64) ||
+		   (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter well, or accept all multicasts. */
 		iowrite16(0x000B, ioaddr + AddrMode);
-	} else if (dev->mc_count > 0) { /* Must use the multicast hash table. */
+	} else if (!netdev_mc_empty(dev)) { /* Must use the multicast hash table. */
 		struct dev_mc_list *mclist;
 		u16 hash_table[4];
 		int i;
 		memset(hash_table, 0, sizeof(hash_table));
-		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
 			 i++, mclist = mclist->next) {
 			unsigned int bit;
 
diff --git a/drivers/staging/et131x/et131x_netdev.c b/drivers/staging/et131x/et131x_netdev.c
index 24d97b4..bc1fad2 100644
--- a/drivers/staging/et131x/et131x_netdev.c
+++ b/drivers/staging/et131x/et131x_netdev.c
@@ -444,11 +444,11 @@ void et131x_multicast(struct net_device *netdev)
 		adapter->PacketFilter |= ET131X_PACKET_TYPE_ALL_MULTICAST;
 	}
 
-	if (netdev->mc_count > NIC_MAX_MCAST_LIST) {
+	if (netdev_mc_count(netdev) > NIC_MAX_MCAST_LIST) {
 		adapter->PacketFilter |= ET131X_PACKET_TYPE_ALL_MULTICAST;
 	}
 
-	if (netdev->mc_count < 1) {
+	if (netdev_mc_count(netdev) < 1) {
 		adapter->PacketFilter &= ~ET131X_PACKET_TYPE_ALL_MULTICAST;
 		adapter->PacketFilter &= ~ET131X_PACKET_TYPE_MULTICAST;
 	} else {
@@ -456,10 +456,10 @@ void et131x_multicast(struct net_device *netdev)
 	}
 
 	/* Set values in the private adapter struct */
-	adapter->MCAddressCount = netdev->mc_count;
+	adapter->MCAddressCount = netdev_mc_count(netdev);
 
-	if (netdev->mc_count) {
-		count = netdev->mc_count - 1;
+	if (!netdev_mc_empty(netdev)) {
+		count = netdev_mc_count(netdev) - 1;
 		memcpy(adapter->MCList[count], mclist->dmi_addr, ETH_ALEN);
 	}
 
diff --git a/drivers/staging/netwave/netwave_cs.c b/drivers/staging/netwave/netwave_cs.c
index e61e6b9..e936717 100644
--- a/drivers/staging/netwave/netwave_cs.c
+++ b/drivers/staging/netwave/netwave_cs.c
@@ -1341,15 +1341,15 @@ static void set_multicast_list(struct net_device *dev)
 #ifdef PCMCIA_DEBUG
     {
 	xstatic int old;
-	if (old != dev->mc_count) {
-	    old = dev->mc_count;
+	if (old != netdev_mc_count(dev)) {
+	    old = netdev_mc_count(dev);
 	    pr_debug("%s: setting Rx mode to %d addresses.\n",
-		  dev->name, dev->mc_count);
+		  dev->name, netdev_mc_count(dev));
 	}
     }
 #endif
 	
-    if (dev->mc_count || (dev->flags & IFF_ALLMULTI)) {
+    if (!netdev_mc_empty(dev) || (dev->flags & IFF_ALLMULTI)) {
 	/* Multicast Mode */
 	rcvMode = rxConfRxEna + rxConfAMP + rxConfBcast;
     } else if (dev->flags & IFF_PROMISC) {
diff --git a/drivers/staging/slicoss/slicoss.c b/drivers/staging/slicoss/slicoss.c
index 5b191af..8c9d5e5 100644
--- a/drivers/staging/slicoss/slicoss.c
+++ b/drivers/staging/slicoss/slicoss.c
@@ -1365,7 +1365,7 @@ static void slic_mcast_set_list(struct net_device *dev)
 	int i;
 	char *addresses;
 	struct dev_mc_list *mc_list = dev->mc_list;
-	int mc_count = dev->mc_count;
+	int mc_count = netdev_mc_count(dev);
 
 	ASSERT(adapter);
 
diff --git a/drivers/staging/vt6655/device_main.c b/drivers/staging/vt6655/device_main.c
index 0db8d7b..82b3a6e 100644
--- a/drivers/staging/vt6655/device_main.c
+++ b/drivers/staging/vt6655/device_main.c
@@ -3093,7 +3093,7 @@ static void device_set_multi(struct net_device *dev) {
         /* Unconditionally log net taps. */
         pDevice->byRxMode |= (RCR_MULTICAST|RCR_BROADCAST|RCR_UNICAST);
     }
-    else if ((dev->mc_count > pDevice->multicast_limit)
+    else if ((netdev_mc_count(dev) > pDevice->multicast_limit)
         ||  (dev->flags & IFF_ALLMULTI)) {
         MACvSelectPage1(pDevice->PortOffset);
         VNSvOutPortD(pDevice->PortOffset + MAC_REG_MAR0, 0xffffffff);
@@ -3103,7 +3103,7 @@ static void device_set_multi(struct net_device *dev) {
     }
     else {
         memset(mc_filter, 0, sizeof(mc_filter));
-        for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+        for (i = 0, mclist = dev->mc_list; mclist && i < netdev_mc_count(dev);
              i++, mclist = mclist->next) {
             int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
             mc_filter[bit_nr >> 5] |= cpu_to_le32(1 << (bit_nr & 31));
diff --git a/drivers/staging/vt6656/main_usb.c b/drivers/staging/vt6656/main_usb.c
index ef17c49..2c6a535 100644
--- a/drivers/staging/vt6656/main_usb.c
+++ b/drivers/staging/vt6656/main_usb.c
@@ -1619,7 +1619,8 @@ static void device_set_multi(struct net_device *dev) {
         // Unconditionally log net taps.
         pDevice->byRxMode |= (RCR_MULTICAST|RCR_BROADCAST|RCR_UNICAST);
     }
-    else if ((dev->mc_count > pDevice->multicast_limit) || (dev->flags & IFF_ALLMULTI)) {
+    else if ((netdev_mc_count(dev) > pDevice->multicast_limit) ||
+	     (dev->flags & IFF_ALLMULTI)) {
         CONTROLnsRequestOut(pDevice,
                             MESSAGE_TYPE_WRITE,
                             MAC_REG_MAR0,
@@ -1631,7 +1632,7 @@ static void device_set_multi(struct net_device *dev) {
     }
     else {
         memset(mc_filter, 0, sizeof(mc_filter));
-        for (ii = 0, mclist = dev->mc_list; mclist && ii < dev->mc_count;
+        for (ii = 0, mclist = dev->mc_list; mclist && ii < netdev_mc_count(dev);
              ii++, mclist = mclist->next) {
             int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
             mc_filter[bit_nr >> 5] |= cpu_to_le32(1 << (bit_nr & 31));
diff --git a/drivers/staging/wavelan/wavelan.c b/drivers/staging/wavelan/wavelan.c
index d634b2d..961f141 100644
--- a/drivers/staging/wavelan/wavelan.c
+++ b/drivers/staging/wavelan/wavelan.c
@@ -1367,7 +1367,7 @@ static void wavelan_set_multicast_list(struct net_device * dev)
 #ifdef DEBUG_IOCTL_INFO
 	printk(KERN_DEBUG
 	       "%s: wavelan_set_multicast_list(): setting Rx mode %02X to %d addresses.\n",
-	       dev->name, dev->flags, dev->mc_count);
+	       dev->name, dev->flags, netdev_mc_count(dev));
 #endif
 
 	/* Are we asking for promiscuous mode,
@@ -1375,7 +1375,7 @@ static void wavelan_set_multicast_list(struct net_device * dev)
 	 * or too many multicast addresses for the hardware filter? */
 	if ((dev->flags & IFF_PROMISC) ||
 	    (dev->flags & IFF_ALLMULTI) ||
-	    (dev->mc_count > I82586_MAX_MULTICAST_ADDRESSES)) {
+	    (netdev_mc_count(dev) > I82586_MAX_MULTICAST_ADDRESSES)) {
 		/*
 		 * Enable promiscuous mode: receive all packets.
 		 */
@@ -1393,11 +1393,11 @@ static void wavelan_set_multicast_list(struct net_device * dev)
 		 * in multicast list
 		 */
 #ifdef MULTICAST_AVOID
-		if (lp->promiscuous || (dev->mc_count != lp->mc_count))
+		if (lp->promiscuous || (netdev_mc_count(dev) != lp->mc_count))
 #endif
 		{
 			lp->promiscuous = 0;
-			lp->mc_count = dev->mc_count;
+			lp->mc_count = netdev_mc_count(dev);
 
 			wv_82586_reconfig(dev);
 		}
diff --git a/drivers/staging/wavelan/wavelan_cs.c b/drivers/staging/wavelan/wavelan_cs.c
index 10c702b..08fcb22 100644
--- a/drivers/staging/wavelan/wavelan_cs.c
+++ b/drivers/staging/wavelan/wavelan_cs.c
@@ -1373,7 +1373,7 @@ wavelan_set_multicast_list(struct net_device *	dev)
 
 #ifdef DEBUG_IOCTL_INFO
   printk(KERN_DEBUG "%s: wavelan_set_multicast_list(): setting Rx mode %02X to %d addresses.\n",
-	 dev->name, dev->flags, dev->mc_count);
+	 dev->name, dev->flags, netdev_mc_count(dev));
 #endif
 
   if(dev->flags & IFF_PROMISC)
@@ -1394,7 +1394,7 @@ wavelan_set_multicast_list(struct net_device *	dev)
     /* If all multicast addresses
      * or too much multicast addresses for the hardware filter */
     if((dev->flags & IFF_ALLMULTI) ||
-       (dev->mc_count > I82593_MAX_MULTICAST_ADDRESSES))
+       (netdev_mc_count(dev) > I82593_MAX_MULTICAST_ADDRESSES))
       {
 	/*
 	 * Disable promiscuous mode, but active the all multicast mode
@@ -1418,12 +1418,12 @@ wavelan_set_multicast_list(struct net_device *	dev)
 	   */
 #ifdef MULTICAST_AVOID
 	  if(lp->promiscuous || lp->allmulticast ||
-	     (dev->mc_count != lp->mc_count))
+	     (netdev_mc_count(dev) != lp->mc_count))
 #endif
 	    {
 	      lp->promiscuous = 0;
 	      lp->allmulticast = 0;
-	      lp->mc_count = dev->mc_count;
+	      lp->mc_count = netdev_mc_count(dev);
 
 	      wv_82593_reconfig(dev);
 	    }
@@ -3622,7 +3622,8 @@ wv_82593_config(struct net_device *	dev)
       if(!wv_82593_cmd(dev, "wv_82593_config(): mc-setup",
 		       OP0_MC_SETUP, SR0_MC_SETUP_DONE))
 	ret = FALSE;
-      lp->mc_count = dev->mc_count;	/* remember to avoid repeated reset */
+      /* remember to avoid repeated reset */
+      lp->mc_count = netdev_mc_count(dev);
     }
 
   /* Job done, clear the flag */
diff --git a/drivers/staging/wlags49_h2/wl_netdev.c b/drivers/staging/wlags49_h2/wl_netdev.c
index 0d22e36..a95ebf8 100644
--- a/drivers/staging/wlags49_h2/wl_netdev.c
+++ b/drivers/staging/wlags49_h2/wl_netdev.c
@@ -1070,9 +1070,9 @@ void wl_multicast( struct net_device *dev )
             ( dev->flags & IFF_MULTICAST ) ? "Multicast " : "",
             ( dev->flags & IFF_ALLMULTI ) ? "All-Multicast" : "" );
 
-        DBG_PRINT( "  mc_count: %d\n", dev->mc_count );
+        DBG_PRINT( "  mc_count: %d\n", netdev_mc_count(dev));
 
-        for( x = 0, mclist = dev->mc_list; mclist && x < dev->mc_count;
+        for( x = 0, mclist = dev->mc_list; mclist && x < netdev_mc_count(dev);
              x++, mclist = mclist->next ) {
             DBG_PRINT( "    %s (%d)\n", DbgHwAddr(mclist->dmi_addr),
                        mclist->dmi_addrlen );
@@ -1103,7 +1103,7 @@ void wl_multicast( struct net_device *dev )
                 DBG_PRINT( "Enabling Promiscuous mode (IFF_PROMISC)\n" );
                 hcf_put_info( &( lp->hcfCtx ), (LTVP)&( lp->ltvRecord ));
             }
-            else if(( dev->mc_count > HCF_MAX_MULTICAST ) ||
+            else if ((netdev_mc_count(dev) > HCF_MAX_MULTICAST) ||
                     ( dev->flags & IFF_ALLMULTI )) {
                 /* Shutting off this filter will enable all multicast frames to
                    be sent up from the device; however, this is a static RID, so
@@ -1115,13 +1115,13 @@ void wl_multicast( struct net_device *dev )
                 hcf_put_info( &( lp->hcfCtx ), (LTVP)&( lp->ltvRecord ));
                 wl_apply( lp );
             }
-            else if( dev->mc_count != 0 ) {
+            else if (!netdev_mc_empty(dev)) {
                 /* Set the multicast addresses */
-                lp->ltvRecord.len = ( dev->mc_count * 3 ) + 1;
+                lp->ltvRecord.len = ( netdev_mc_count(dev) * 3 ) + 1;
                 lp->ltvRecord.typ = CFG_GROUP_ADDR;
 
                 for( x = 0, mclist = dev->mc_list;
-                ( x < dev->mc_count ) && ( mclist != NULL );
+                ( x < netdev_mc_count(dev)) && ( mclist != NULL );
                     x++, mclist = mclist->next ) {
                     memcpy( &( lp->ltvRecord.u.u8[x * ETH_ALEN] ),
                             mclist->dmi_addr, ETH_ALEN );
diff --git a/net/bluetooth/bnep/netdev.c b/net/bluetooth/bnep/netdev.c
index 26fb831..b6234b7 100644
--- a/net/bluetooth/bnep/netdev.c
+++ b/net/bluetooth/bnep/netdev.c
@@ -64,7 +64,7 @@ static void bnep_net_set_mc_list(struct net_device *dev)
 	struct sk_buff *skb;
 	int size;
 
-	BT_DBG("%s mc_count %d", dev->name, dev->mc_count);
+	BT_DBG("%s mc_count %d", dev->name, netdev_mc_count(dev));
 
 	size = sizeof(*r) + (BNEP_MAX_MULTICAST_FILTERS + 1) * ETH_ALEN * 2;
 	skb  = alloc_skb(size, GFP_ATOMIC);
@@ -97,7 +97,9 @@ static void bnep_net_set_mc_list(struct net_device *dev)
 
 		/* FIXME: We should group addresses here. */
 
-		for (i = 0; i < dev->mc_count && i < BNEP_MAX_MULTICAST_FILTERS; i++) {
+		for (i = 0;
+		     i < netdev_mc_count(dev) && i < BNEP_MAX_MULTICAST_FILTERS;
+		     i++) {
 			memcpy(__skb_put(skb, ETH_ALEN), dmi->dmi_addr, ETH_ALEN);
 			memcpy(__skb_put(skb, ETH_ALEN), dmi->dmi_addr, ETH_ALEN);
 			dmi = dmi->next;
diff --git a/net/core/dev.c b/net/core/dev.c
index 94c1eee..0c70df9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4263,7 +4263,7 @@ static void dev_addr_discard(struct net_device *dev)
 	netif_addr_lock_bh(dev);
 
 	__dev_addr_discard(&dev->mc_list);
-	dev->mc_count = 0;
+	netdev_mc_count(dev) = 0;
 
 	netif_addr_unlock_bh(dev);
 }
diff --git a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
index d340110..9616c32 100644
--- a/net/irda/irlan/irlan_eth.c
+++ b/net/irda/irlan/irlan_eth.c
@@ -321,14 +321,15 @@ static void irlan_eth_set_multicast_list(struct net_device *dev)
 		/* Enable promiscuous mode */
 		IRDA_WARNING("Promiscuous mode not implemented by IrLAN!\n");
 	}
-	else if ((dev->flags & IFF_ALLMULTI) || dev->mc_count > HW_MAX_ADDRS) {
+	else if ((dev->flags & IFF_ALLMULTI) ||
+		 netdev_mc_count(dev) > HW_MAX_ADDRS) {
 		/* Disable promiscuous mode, use normal mode. */
 		IRDA_DEBUG(4, "%s(), Setting multicast filter\n", __func__ );
 		/* hardware_set_filter(NULL); */
 
 		irlan_set_multicast_filter(self, TRUE);
 	}
-	else if (dev->mc_count) {
+	else if (!netdev_mc_empty(dev)) {
 		IRDA_DEBUG(4, "%s(), Setting multicast filter\n", __func__ );
 		/* Walk the address list, and load the filter */
 		/* hardware_set_filter(dev->mc_list); */
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 09fff46..f943f5f 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -413,7 +413,7 @@ static int ieee80211_stop(struct net_device *dev)
 	netif_addr_lock_bh(dev);
 	spin_lock_bh(&local->filter_lock);
 	__dev_addr_unsync(&local->mc_list, &local->mc_count,
-			  &dev->mc_list, &dev->mc_count);
+			  &dev->mc_list, dev->mc_count);
 	spin_unlock_bh(&local->filter_lock);
 	netif_addr_unlock_bh(dev);
 
-- 
1.6.6

