From: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH net-next 4/5] treewide: replace dev->trans_start update with helper
Date: Tue,  3 May 2016 16:33:13 +0200
Message-ID: <1462285994-31983-1-git-send-email-fw@strlen.de>
References: <1462285862-30946-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>,
	user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org,
	linux1394-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	MPT-FusionLinux.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
	b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1462285862-30946-1-git-send-email-fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Replace all trans_start updates with netif_trans_update helper.
change was done via spatch:

struct net_device *d;
@@
- d->trans_start = jiffies
+ netif_trans_update(d)

Compile tested only.

Cc: user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Cc: linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org
Cc: linux1394-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: MPT-FusionLinux.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
Cc: linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org
Cc: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
---
 Checkpatch complains about whitespace damage, but
 this extra whitespace already exists before this patch.

 arch/um/drivers/net_kern.c                             | 4 ++--
 arch/xtensa/platforms/iss/network.c                    | 2 +-
 drivers/char/pcmcia/synclink_cs.c                      | 4 ++--
 drivers/firewire/net.c                                 | 2 +-
 drivers/infiniband/hw/nes/nes_nic.c                    | 2 +-
 drivers/infiniband/ulp/ipoib/ipoib_cm.c                | 2 +-
 drivers/infiniband/ulp/ipoib/ipoib_ib.c                | 2 +-
 drivers/isdn/hysdn/hysdn_net.c                         | 2 +-
 drivers/isdn/i4l/isdn_net.c                            | 4 ++--
 drivers/isdn/i4l/isdn_x25iface.c                       | 2 +-
 drivers/message/fusion/mptlan.c                        | 2 +-
 drivers/net/appletalk/cops.c                           | 2 +-
 drivers/net/can/mscan/mscan.c                          | 4 ++--
 drivers/net/can/usb/ems_usb.c                          | 4 ++--
 drivers/net/can/usb/esd_usb2.c                         | 4 ++--
 drivers/net/can/usb/peak_usb/pcan_usb_core.c           | 4 ++--
 drivers/net/cris/eth_v10.c                             | 2 +-
 drivers/net/ethernet/3com/3c509.c                      | 2 +-
 drivers/net/ethernet/3com/3c515.c                      | 2 +-
 drivers/net/ethernet/3com/3c574_cs.c                   | 2 +-
 drivers/net/ethernet/3com/3c589_cs.c                   | 2 +-
 drivers/net/ethernet/3com/3c59x.c                      | 2 +-
 drivers/net/ethernet/8390/axnet_cs.c                   | 6 +++---
 drivers/net/ethernet/8390/lib8390.c                    | 4 ++--
 drivers/net/ethernet/adaptec/starfire.c                | 2 +-
 drivers/net/ethernet/adi/bfin_mac.c                    | 2 +-
 drivers/net/ethernet/agere/et131x.c                    | 4 ++--
 drivers/net/ethernet/allwinner/sun4i-emac.c            | 6 +++---
 drivers/net/ethernet/amd/7990.c                        | 4 ++--
 drivers/net/ethernet/amd/a2065.c                       | 2 +-
 drivers/net/ethernet/amd/atarilance.c                  | 2 +-
 drivers/net/ethernet/amd/au1000_eth.c                  | 2 +-
 drivers/net/ethernet/amd/declance.c                    | 2 +-
 drivers/net/ethernet/amd/lance.c                       | 2 +-
 drivers/net/ethernet/amd/ni65.c                        | 4 ++--
 drivers/net/ethernet/amd/nmclan_cs.c                   | 2 +-
 drivers/net/ethernet/amd/pcnet32.c                     | 4 ++--
 drivers/net/ethernet/amd/sunlance.c                    | 2 +-
 drivers/net/ethernet/atheros/alx/main.c                | 2 +-
 drivers/net/ethernet/broadcom/bcmsysport.c             | 2 +-
 drivers/net/ethernet/broadcom/genet/bcmgenet.c         | 2 +-
 drivers/net/ethernet/broadcom/sb1250-mac.c             | 2 +-
 drivers/net/ethernet/broadcom/tg3.c                    | 2 +-
 drivers/net/ethernet/cavium/liquidio/lio_main.c        | 4 ++--
 drivers/net/ethernet/cavium/octeon/octeon_mgmt.c       | 2 +-
 drivers/net/ethernet/cavium/thunder/nicvf_main.c       | 2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c             | 2 +-
 drivers/net/ethernet/davicom/dm9000.c                  | 4 ++--
 drivers/net/ethernet/dec/tulip/de4x5.c                 | 4 ++--
 drivers/net/ethernet/dec/tulip/dmfe.c                  | 6 +++---
 drivers/net/ethernet/dec/tulip/pnic.c                  | 6 +++---
 drivers/net/ethernet/dec/tulip/tulip_core.c            | 2 +-
 drivers/net/ethernet/dec/tulip/uli526x.c               | 4 ++--
 drivers/net/ethernet/dec/tulip/winbond-840.c           | 2 +-
 drivers/net/ethernet/dlink/dl2k.c                      | 2 +-
 drivers/net/ethernet/dlink/sundance.c                  | 2 +-
 drivers/net/ethernet/fealnx.c                          | 2 +-
 drivers/net/ethernet/freescale/gianfar.c               | 2 +-
 drivers/net/ethernet/fujitsu/fmvj18x_cs.c              | 2 +-
 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c          | 2 +-
 drivers/net/ethernet/hisilicon/hns/hns_enet.c          | 6 +++---
 drivers/net/ethernet/hp/hp100.c                        | 2 +-
 drivers/net/ethernet/i825xx/82596.c                    | 2 +-
 drivers/net/ethernet/i825xx/lib82596.c                 | 2 +-
 drivers/net/ethernet/i825xx/sun3_82586.c               | 4 ++--
 drivers/net/ethernet/ibm/emac/core.c                   | 4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c           | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c          | 2 +-
 drivers/net/ethernet/korina.c                          | 8 ++++----
 drivers/net/ethernet/lantiq_etop.c                     | 4 ++--
 drivers/net/ethernet/marvell/pxa168_eth.c              | 2 +-
 drivers/net/ethernet/marvell/sky2.c                    | 2 +-
 drivers/net/ethernet/micrel/ksz884x.c                  | 4 ++--
 drivers/net/ethernet/microchip/encx24j600.c            | 2 +-
 drivers/net/ethernet/moxa/moxart_ether.c               | 2 +-
 drivers/net/ethernet/natsemi/natsemi.c                 | 2 +-
 drivers/net/ethernet/natsemi/sonic.c                   | 2 +-
 drivers/net/ethernet/nuvoton/w90p910_ether.c           | 4 ++--
 drivers/net/ethernet/packetengines/hamachi.c           | 2 +-
 drivers/net/ethernet/packetengines/yellowfin.c         | 2 +-
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c   | 2 +-
 drivers/net/ethernet/qualcomm/qca_spi.c                | 2 +-
 drivers/net/ethernet/realtek/atp.c                     | 2 +-
 drivers/net/ethernet/seeq/sgiseeq.c                    | 4 ++--
 drivers/net/ethernet/sgi/meth.c                        | 4 ++--
 drivers/net/ethernet/sis/sis900.c                      | 2 +-
 drivers/net/ethernet/smsc/epic100.c                    | 2 +-
 drivers/net/ethernet/smsc/smc911x.c                    | 6 +++---
 drivers/net/ethernet/smsc/smc9194.c                    | 4 ++--
 drivers/net/ethernet/smsc/smc91c92_cs.c                | 4 ++--
 drivers/net/ethernet/smsc/smc91x.c                     | 4 ++--
 drivers/net/ethernet/sun/niu.c                         | 2 +-
 drivers/net/ethernet/sun/sungem.c                      | 2 +-
 drivers/net/ethernet/synopsys/dwc_eth_qos.c            | 4 ++--
 drivers/net/ethernet/tehuti/tehuti.c                   | 2 +-
 drivers/net/ethernet/ti/cpsw.c                         | 2 +-
 drivers/net/ethernet/ti/netcp_core.c                   | 4 ++--
 drivers/net/ethernet/ti/tlan.c                         | 2 +-
 drivers/net/ethernet/tile/tilepro.c                    | 2 +-
 drivers/net/ethernet/toshiba/spider_net.c              | 2 +-
 drivers/net/ethernet/via/via-rhine.c                   | 2 +-
 drivers/net/ethernet/wiznet/w5100.c                    | 2 +-
 drivers/net/ethernet/wiznet/w5300.c                    | 2 +-
 drivers/net/ethernet/xilinx/ll_temac_main.c            | 2 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c      | 2 +-
 drivers/net/ethernet/xilinx/xilinx_emaclite.c          | 4 ++--
 drivers/net/ethernet/xircom/xirc2ps_cs.c               | 2 +-
 drivers/net/fjes/fjes_main.c                           | 2 +-
 drivers/net/hamradio/mkiss.c                           | 2 +-
 drivers/net/hamradio/scc.c                             | 2 +-
 drivers/net/hamradio/yam.c                             | 2 +-
 drivers/net/irda/ali-ircc.c                            | 8 ++++----
 drivers/net/irda/bfin_sir.c                            | 2 +-
 drivers/net/irda/irda-usb.c                            | 4 ++--
 drivers/net/irda/nsc-ircc.c                            | 8 ++++----
 drivers/net/irda/smsc-ircc2.c                          | 2 +-
 drivers/net/irda/stir4200.c                            | 2 +-
 drivers/net/irda/via-ircc.c                            | 8 ++++----
 drivers/net/slip/slip.c                                | 2 +-
 drivers/net/usb/catc.c                                 | 4 ++--
 drivers/net/usb/kaweth.c                               | 2 +-
 drivers/net/usb/lan78xx.c                              | 4 ++--
 drivers/net/usb/pegasus.c                              | 2 +-
 drivers/net/usb/rtl8150.c                              | 4 ++--
 drivers/net/usb/usbnet.c                               | 4 ++--
 drivers/net/wan/cosa.c                                 | 2 +-
 drivers/net/wan/farsync.c                              | 6 +++---
 drivers/net/wan/lmc/lmc_main.c                         | 2 +-
 drivers/net/wan/sbni.c                                 | 8 ++++----
 drivers/net/wimax/i2400m/netdev.c                      | 2 +-
 drivers/net/wireless/cisco/airo.c                      | 6 +++---
 drivers/net/wireless/intel/ipw2x00/ipw2100.c           | 2 +-
 drivers/net/wireless/intel/ipw2x00/ipw2200.c           | 6 +++---
 drivers/net/wireless/intersil/hostap/hostap_hw.c       | 2 +-
 drivers/net/wireless/intersil/orinoco/main.c           | 2 +-
 drivers/net/wireless/intersil/orinoco/orinoco_usb.c    | 2 +-
 drivers/net/wireless/marvell/mwifiex/init.c            | 2 +-
 drivers/net/wireless/wl3501_cs.c                       | 2 +-
 drivers/net/wireless/zydas/zd1201.c                    | 2 +-
 drivers/s390/net/ctcm_main.c                           | 6 +++---
 drivers/s390/net/ctcm_mpc.c                            | 2 +-
 drivers/s390/net/netiucv.c                             | 2 +-
 drivers/staging/rtl8192e/rtl8192e/rtl_core.c           | 2 +-
 drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c | 6 +++---
 drivers/staging/rtl8192u/r8192U_core.c                 | 4 ++--
 drivers/staging/wlan-ng/p80211netdev.c                 | 2 +-
 drivers/tty/n_gsm.c                                    | 2 +-
 drivers/tty/synclink.c                                 | 4 ++--
 drivers/tty/synclink_gt.c                              | 4 ++--
 drivers/tty/synclinkmp.c                               | 4 ++--
 drivers/usb/gadget/function/u_ether.c                  | 2 +-
 net/atm/lec.c                                          | 4 ++--
 net/batman-adv/soft-interface.c                        | 2 +-
 net/bluetooth/bnep/netdev.c                            | 2 +-
 net/irda/irlan/irlan_eth.c                             | 2 +-
 net/sched/sch_generic.c                                | 2 +-
 156 files changed, 232 insertions(+), 232 deletions(-)

diff --git a/arch/um/drivers/net_kern.c b/arch/um/drivers/net_kern.c
index 9ef669d..2cd5b68 100644
--- a/arch/um/drivers/net_kern.c
+++ b/arch/um/drivers/net_kern.c
@@ -223,7 +223,7 @@ static int uml_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (len == skb->len) {
 		dev->stats.tx_packets++;
 		dev->stats.tx_bytes += skb->len;
-		dev->trans_start = jiffies;
+		netif_trans_update(dev);
 		netif_start_queue(dev);
 
 		/* this is normally done in the interrupt when tx finishes */
@@ -252,7 +252,7 @@ static void uml_net_set_multicast_list(struct net_device *dev)
 
 static void uml_net_tx_timeout(struct net_device *dev)
 {
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	netif_wake_queue(dev);
 }
 
diff --git a/arch/xtensa/platforms/iss/network.c b/arch/xtensa/platforms/iss/network.c
index 976a385..66a5d15 100644
--- a/arch/xtensa/platforms/iss/network.c
+++ b/arch/xtensa/platforms/iss/network.c
@@ -428,7 +428,7 @@ static int iss_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (len == skb->len) {
 		lp->stats.tx_packets++;
 		lp->stats.tx_bytes += skb->len;
-		dev->trans_start = jiffies;
+		netif_trans_update(dev);
 		netif_start_queue(dev);
 
 		/* this is normally done in the interrupt when tx finishes */
diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index 22c2765..e524e83 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -3969,7 +3969,7 @@ static netdev_tx_t hdlcdev_xmit(struct sk_buff *skb,
 	dev_kfree_skb(skb);
 
 	/* save start time for transmit timeout detection */
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 
 	/* start hardware transmitter if necessary */
 	spin_lock_irqsave(&info->lock, flags);
@@ -4032,7 +4032,7 @@ static int hdlcdev_open(struct net_device *dev)
 	tty_kref_put(tty);
 
 	/* enable network layer transmit */
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	netif_start_queue(dev);
 
 	/* inform generic HDLC layer of current DCD status */
diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index f4ea80d..309311b 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1023,7 +1023,7 @@ static int fwnet_send_packet(struct fwnet_packet_task *ptask)
 
 	spin_unlock_irqrestore(&dev->lock, flags);
 
-	dev->netdev->trans_start = jiffies;
+	netif_trans_update(dev->netdev);
  out:
 	if (free)
 		fwnet_free_ptask(ptask);
diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 99cef26..ea2f0d7 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -685,7 +685,7 @@ tso_sq_no_longer_full:
 		nes_write32(nesdev->regs+NES_WQE_ALLOC,
 				(wqe_count << 24) | (1 << 23) | nesvnic->nic.qp_id);
 
-	netdev->trans_start = jiffies;
+	netif_trans_update(netdev);
 
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
index c8ed535..b2f4283 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -766,7 +766,7 @@ void ipoib_cm_send(struct net_device *dev, struct sk_buff *skb, struct ipoib_cm_
 		ipoib_dma_unmap_tx(priv, tx_req);
 		dev_kfree_skb_any(skb);
 	} else {
-		dev->trans_start = jiffies;
+		netif_trans_update(dev);
 		++tx->tx_head;
 
 		if (++priv->tx_outstanding == ipoib_sendq_size) {
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
index f0e55e4..3643d55 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -637,7 +637,7 @@ void ipoib_send(struct net_device *dev, struct sk_buff *skb,
 		if (netif_queue_stopped(dev))
 			netif_wake_queue(dev);
 	} else {
-		dev->trans_start = jiffies;
+		netif_trans_update(dev);
 
 		address->last_send = priv->tx_head;
 		++priv->tx_head;
diff --git a/drivers/isdn/hysdn/hysdn_net.c b/drivers/isdn/hysdn/hysdn_net.c
index a0efb4c..5609dee 100644
--- a/drivers/isdn/hysdn/hysdn_net.c
+++ b/drivers/isdn/hysdn/hysdn_net.c
@@ -127,7 +127,7 @@ net_send_packet(struct sk_buff *skb, struct net_device *dev)
 	if (lp->in_idx >= MAX_SKB_BUFFERS)
 		lp->in_idx = 0;	/* wrap around */
 	lp->sk_count++;		/* adjust counter */
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 
 	/* If we just used up the very last entry in the
 	 * TX ring on this device, tell the queueing
diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index aa5dd56..c151c6d 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -1153,7 +1153,7 @@ static void isdn_net_tx_timeout(struct net_device *ndev)
 		 * ever called   --KG
 		 */
 	}
-	ndev->trans_start = jiffies;
+	netif_trans_update(ndev);
 	netif_wake_queue(ndev);
 }
 
@@ -1291,7 +1291,7 @@ isdn_net_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 			}
 		} else {
 			/* Device is connected to an ISDN channel */
-			ndev->trans_start = jiffies;
+			netif_trans_update(ndev);
 			if (!lp->dialstate) {
 				/* ISDN connection is established, try sending */
 				int ret;
diff --git a/drivers/isdn/i4l/isdn_x25iface.c b/drivers/isdn/i4l/isdn_x25iface.c
index e2d4e58..0c5d8de 100644
--- a/drivers/isdn/i4l/isdn_x25iface.c
+++ b/drivers/isdn/i4l/isdn_x25iface.c
@@ -278,7 +278,7 @@ static int isdn_x25iface_xmit(struct concap_proto *cprot, struct sk_buff *skb)
 	case X25_IFACE_DATA:
 		if (*state == WAN_CONNECTED) {
 			skb_pull(skb, 1);
-			cprot->net_dev->trans_start = jiffies;
+			netif_trans_update(cprot->net_dev);
 			ret = (cprot->dops->data_req(cprot, skb));
 			/* prepare for future retransmissions */
 			if (ret) skb_push(skb, 1);
diff --git a/drivers/message/fusion/mptlan.c b/drivers/message/fusion/mptlan.c
index cbe9607..6955c9e 100644
--- a/drivers/message/fusion/mptlan.c
+++ b/drivers/message/fusion/mptlan.c
@@ -791,7 +791,7 @@ mpt_lan_sdu_send (struct sk_buff *skb, struct net_device *dev)
 		pSimple->Address.High = 0;
 
 	mpt_put_msg_frame (LanCtx, mpt_dev, mf);
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 
 	dioprintk((KERN_INFO MYNAM ": %s/%s: Sending packet. FlagsLength = %08x.\n",
 			IOC_AND_NETDEV_NAMES_s_s(dev),
diff --git a/drivers/net/appletalk/cops.c b/drivers/net/appletalk/cops.c
index 7f2a032..1b2e921 100644
--- a/drivers/net/appletalk/cops.c
+++ b/drivers/net/appletalk/cops.c
@@ -861,7 +861,7 @@ static void cops_timeout(struct net_device *dev)
 	}
 	printk(KERN_WARNING "%s: Transmit timed out.\n", dev->name);
 	cops_jumpstart(dev);	/* Restart the card. */
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	netif_wake_queue(dev);
 }
 
diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
index e36b740..acb708f 100644
--- a/drivers/net/can/mscan/mscan.c
+++ b/drivers/net/can/mscan/mscan.c
@@ -276,7 +276,7 @@ static netdev_tx_t mscan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	out_8(&regs->cantflg, 1 << buf_id);
 
 	if (!test_bit(F_TX_PROGRESS, &priv->flags))
-		dev->trans_start = jiffies;
+		netif_trans_update(dev);
 
 	list_add_tail(&priv->tx_queue[buf_id].list, &priv->tx_head);
 
@@ -469,7 +469,7 @@ static irqreturn_t mscan_isr(int irq, void *dev_id)
 			clear_bit(F_TX_PROGRESS, &priv->flags);
 			priv->cur_pri = 0;
 		} else {
-			dev->trans_start = jiffies;
+			netif_trans_update(dev);
 		}
 
 		if (!test_bit(F_TX_WAIT_ALL, &priv->flags))
diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
index 3400fd1..71f0e79 100644
--- a/drivers/net/can/usb/ems_usb.c
+++ b/drivers/net/can/usb/ems_usb.c
@@ -521,7 +521,7 @@ static void ems_usb_write_bulk_callback(struct urb *urb)
 	if (urb->status)
 		netdev_info(netdev, "Tx URB aborted (%d)\n", urb->status);
 
-	netdev->trans_start = jiffies;
+	netif_trans_update(netdev);
 
 	/* transmission complete interrupt */
 	netdev->stats.tx_packets++;
@@ -835,7 +835,7 @@ static netdev_tx_t ems_usb_start_xmit(struct sk_buff *skb, struct net_device *ne
 			stats->tx_dropped++;
 		}
 	} else {
-		netdev->trans_start = jiffies;
+		netif_trans_update(netdev);
 
 		/* Slow down tx path */
 		if (atomic_read(&dev->active_tx_urbs) >= MAX_TX_URBS ||
diff --git a/drivers/net/can/usb/esd_usb2.c b/drivers/net/can/usb/esd_usb2.c
index 113e64f..784a900 100644
--- a/drivers/net/can/usb/esd_usb2.c
+++ b/drivers/net/can/usb/esd_usb2.c
@@ -480,7 +480,7 @@ static void esd_usb2_write_bulk_callback(struct urb *urb)
 	if (urb->status)
 		netdev_info(netdev, "Tx URB aborted (%d)\n", urb->status);
 
-	netdev->trans_start = jiffies;
+	netif_trans_update(netdev);
 }
 
 static ssize_t show_firmware(struct device *d,
@@ -820,7 +820,7 @@ static netdev_tx_t esd_usb2_start_xmit(struct sk_buff *skb,
 		goto releasebuf;
 	}
 
-	netdev->trans_start = jiffies;
+	netif_trans_update(netdev);
 
 	/*
 	 * Release our reference to this URB, the USB core will eventually free
diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_core.c b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
index 5a2e341..bfb91d8 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_core.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
@@ -274,7 +274,7 @@ static void peak_usb_write_bulk_callback(struct urb *urb)
 		netdev->stats.tx_bytes += context->data_len;
 
 		/* prevent tx timeout */
-		netdev->trans_start = jiffies;
+		netif_trans_update(netdev);
 		break;
 
 	default:
@@ -373,7 +373,7 @@ static netdev_tx_t peak_usb_ndo_start_xmit(struct sk_buff *skb,
 			stats->tx_dropped++;
 		}
 	} else {
-		netdev->trans_start = jiffies;
+		netif_trans_update(netdev);
 
 		/* slow down tx path */
 		if (atomic_read(&dev->active_tx_urbs) >= PCAN_USB_MAX_TX_URBS)
diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index 64c016a..221f5f0 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -1106,7 +1106,7 @@ e100_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 	myNextTxDesc->skb = skb;
 
-	dev->trans_start = jiffies; /* NETIF_F_LLTX driver :( */
+	netif_trans_update(dev); /* NETIF_F_LLTX driver :( */
 
 	e100_hardware_send_packet(np, buf, skb->len);
 
diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index 7677c74..91ada52 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -699,7 +699,7 @@ el3_tx_timeout (struct net_device *dev)
 		dev->name, inb(ioaddr + TX_STATUS), inw(ioaddr + EL3_STATUS),
 		inw(ioaddr + TX_FREE));
 	dev->stats.tx_errors++;
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	/* Issue TX_RESET and TX_START commands. */
 	outw(TxReset, ioaddr + EL3_CMD);
 	outw(TxEnable, ioaddr + EL3_CMD);
diff --git a/drivers/net/ethernet/3com/3c515.c b/drivers/net/ethernet/3com/3c515.c
index 942fb0d..b26e038 100644
--- a/drivers/net/ethernet/3com/3c515.c
+++ b/drivers/net/ethernet/3com/3c515.c
@@ -992,7 +992,7 @@ static void corkscrew_timeout(struct net_device *dev)
 		if (!(inw(ioaddr + EL3_STATUS) & CmdInProgress))
 			break;
 	outw(TxEnable, ioaddr + EL3_CMD);
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	dev->stats.tx_errors++;
 	dev->stats.tx_dropped++;
 	netif_wake_queue(dev);
diff --git a/drivers/net/ethernet/3com/3c574_cs.c b/drivers/net/ethernet/3com/3c574_cs.c
index b9948f0..b88afd7 100644
--- a/drivers/net/ethernet/3com/3c574_cs.c
+++ b/drivers/net/ethernet/3com/3c574_cs.c
@@ -700,7 +700,7 @@ static void el3_tx_timeout(struct net_device *dev)
 	netdev_notice(dev, "Transmit timed out!\n");
 	dump_status(dev);
 	dev->stats.tx_errors++;
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	/* Issue TX_RESET and TX_START commands. */
 	tc574_wait_for_completion(dev, TxReset);
 	outw(TxEnable, ioaddr + EL3_CMD);
diff --git a/drivers/net/ethernet/3com/3c589_cs.c b/drivers/net/ethernet/3com/3c589_cs.c
index c5a3205..71396e4 100644
--- a/drivers/net/ethernet/3com/3c589_cs.c
+++ b/drivers/net/ethernet/3com/3c589_cs.c
@@ -534,7 +534,7 @@ static void el3_tx_timeout(struct net_device *dev)
 	netdev_warn(dev, "Transmit timed out!\n");
 	dump_status(dev);
 	dev->stats.tx_errors++;
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	/* Issue TX_RESET and TX_START commands. */
 	tc589_wait_for_completion(dev, TxReset);
 	outw(TxEnable, ioaddr + EL3_CMD);
diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index d81fced..25c55ab 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -1944,7 +1944,7 @@ static void vortex_tx_timeout(struct net_device *dev)
 	}
 	/* Issue Tx Enable */
 	iowrite16(TxEnable, ioaddr + EL3_CMD);
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 }
 
 /*
diff --git a/drivers/net/ethernet/8390/axnet_cs.c b/drivers/net/ethernet/8390/axnet_cs.c
index ec6eac1..4ea717d 100644
--- a/drivers/net/ethernet/8390/axnet_cs.c
+++ b/drivers/net/ethernet/8390/axnet_cs.c
@@ -1041,7 +1041,7 @@ static netdev_tx_t axnet_start_xmit(struct sk_buff *skb,
 	{
 		ei_local->txing = 1;
 		NS8390_trigger_send(dev, send_length, output_page);
-		dev->trans_start = jiffies;
+		netif_trans_update(dev);
 		if (output_page == ei_local->tx_start_page) 
 		{
 			ei_local->tx1 = -1;
@@ -1270,7 +1270,7 @@ static void ei_tx_intr(struct net_device *dev)
 		{
 			ei_local->txing = 1;
 			NS8390_trigger_send(dev, ei_local->tx2, ei_local->tx_start_page + 6);
-			dev->trans_start = jiffies;
+			netif_trans_update(dev);
 			ei_local->tx2 = -1,
 			ei_local->lasttx = 2;
 		}
@@ -1287,7 +1287,7 @@ static void ei_tx_intr(struct net_device *dev)
 		{
 			ei_local->txing = 1;
 			NS8390_trigger_send(dev, ei_local->tx1, ei_local->tx_start_page);
-			dev->trans_start = jiffies;
+			netif_trans_update(dev);
 			ei_local->tx1 = -1;
 			ei_local->lasttx = 1;
 		}
diff --git a/drivers/net/ethernet/8390/lib8390.c b/drivers/net/ethernet/8390/lib8390.c
index b96e885..60f8e2c 100644
--- a/drivers/net/ethernet/8390/lib8390.c
+++ b/drivers/net/ethernet/8390/lib8390.c
@@ -596,7 +596,7 @@ static void ei_tx_intr(struct net_device *dev)
 		if (ei_local->tx2 > 0) {
 			ei_local->txing = 1;
 			NS8390_trigger_send(dev, ei_local->tx2, ei_local->tx_start_page + 6);
-			dev->trans_start = jiffies;
+			netif_trans_update(dev);
 			ei_local->tx2 = -1,
 			ei_local->lasttx = 2;
 		} else
@@ -609,7 +609,7 @@ static void ei_tx_intr(struct net_device *dev)
 		if (ei_local->tx1 > 0) {
 			ei_local->txing = 1;
 			NS8390_trigger_send(dev, ei_local->tx1, ei_local->tx_start_page);
-			dev->trans_start = jiffies;
+			netif_trans_update(dev);
 			ei_local->tx1 = -1;
 			ei_local->lasttx = 1;
 		} else
diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index ac72882..1d10696 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -1129,7 +1129,7 @@ static void tx_timeout(struct net_device *dev)
 
 	/* Trigger an immediate transmit demand. */
 
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	dev->stats.tx_errors++;
 	netif_wake_queue(dev);
 }
diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 74139cb..3d2245f 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1430,7 +1430,7 @@ static void bfin_mac_timeout(struct net_device *dev)
 	bfin_mac_enable(lp->phydev);
 
 	/* We can accept TX packets again */
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 }
 
 static void bfin_mac_multicast_hash(struct net_device *dev)
diff --git a/drivers/net/ethernet/agere/et131x.c b/drivers/net/ethernet/agere/et131x.c
index 0907ab6..30defe6 100644
--- a/drivers/net/ethernet/agere/et131x.c
+++ b/drivers/net/ethernet/agere/et131x.c
@@ -3349,7 +3349,7 @@ static void et131x_down(struct net_device *netdev)
 	struct et131x_adapter *adapter = netdev_priv(netdev);
 
 	/* Save the timestamp for the TX watchdog, prevent a timeout */
-	netdev->trans_start = jiffies;
+	netif_trans_update(netdev);
 
 	phy_stop(adapter->phydev);
 	et131x_disable_txrx(netdev);
@@ -3816,7 +3816,7 @@ static netdev_tx_t et131x_tx(struct sk_buff *skb, struct net_device *netdev)
 		netif_stop_queue(netdev);
 
 	/* Save the timestamp for the TX timeout watchdog */
-	netdev->trans_start = jiffies;
+	netif_trans_update(netdev);
 
 	/* TCB is not available */
 	if (tx_ring->used >= NUM_TCB)
diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index 8d50314..de2c4bf 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -428,7 +428,7 @@ static void emac_timeout(struct net_device *dev)
 	emac_reset(db);
 	emac_init_device(dev);
 	/* We can accept TX packets again */
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	netif_wake_queue(dev);
 
 	/* Restore previous register address */
@@ -468,7 +468,7 @@ static int emac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		       db->membase + EMAC_TX_CTL0_REG);
 
 		/* save the time stamp */
-		dev->trans_start = jiffies;
+		netif_trans_update(dev);
 	} else if (channel == 1) {
 		/* set TX len */
 		writel(skb->len, db->membase + EMAC_TX_PL1_REG);
@@ -477,7 +477,7 @@ static int emac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		       db->membase + EMAC_TX_CTL1_REG);
 
 		/* save the time stamp */
-		dev->trans_start = jiffies;
+		netif_trans_update(dev);
 	}
 
 	if ((db->tx_fifo_stat & 3) == 3) {
diff --git a/drivers/net/ethernet/amd/7990.c b/drivers/net/ethernet/amd/7990.c
index 8e75755..dcf2a1f 100644
--- a/drivers/net/ethernet/amd/7990.c
+++ b/drivers/net/ethernet/amd/7990.c
@@ -260,7 +260,7 @@ static int lance_reset(struct net_device *dev)
 
 	load_csrs(lp);
 	lance_init_ring(dev);
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	status = init_restart_lance(lp);
 #ifdef DEBUG_DRIVER
 	printk("Lance restart=%d\n", status);
@@ -530,7 +530,7 @@ void lance_tx_timeout(struct net_device *dev)
 {
 	printk("lance_tx_timeout\n");
 	lance_reset(dev);
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	netif_wake_queue(dev);
 }
 EXPORT_SYMBOL_GPL(lance_tx_timeout);
diff --git a/drivers/net/ethernet/amd/a2065.c b/drivers/net/ethernet/amd/a2065.c
index 2a18d34..a83cd1c 100644
--- a/drivers/net/ethernet/amd/a2065.c
+++ b/drivers/net/ethernet/amd/a2065.c
@@ -512,7 +512,7 @@ static inline int lance_reset(struct net_device *dev)
 	load_csrs(lp);
 
 	lance_init_ring(dev);
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	netif_start_queue(dev);
 
 	status = init_restart_lance(lp);
diff --git a/drivers/net/ethernet/amd/atarilance.c b/drivers/net/ethernet/amd/atarilance.c
index b10964e..d2bc8e5 100644
--- a/drivers/net/ethernet/amd/atarilance.c
+++ b/drivers/net/ethernet/amd/atarilance.c
@@ -764,7 +764,7 @@ static void lance_tx_timeout (struct net_device *dev)
 	/* lance_restart, essentially */
 	lance_init_ring(dev);
 	REGA( CSR0 ) = CSR0_INEA | CSR0_INIT | CSR0_STRT;
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	netif_wake_queue(dev);
 }
 
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index d3977d0..9af309e 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -1074,7 +1074,7 @@ static void au1000_tx_timeout(struct net_device *dev)
 	netdev_err(dev, "au1000_tx_timeout: dev=%p\n", dev);
 	au1000_reset_mac(dev);
 	au1000_init(dev);
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	netif_wake_queue(dev);
 }
 
diff --git a/drivers/net/ethernet/amd/declance.c b/drivers/net/ethernet/amd/declance.c
index b584b78..b799c7a 100644
--- a/drivers/net/ethernet/amd/declance.c
+++ b/drivers/net/ethernet/amd/declance.c
@@ -877,7 +877,7 @@ static inline int lance_reset(struct net_device *dev)
 
 	lance_init_ring(dev);
 	load_csrs(lp);
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	status = init_restart_lance(lp);
 	return status;
 }
diff --git a/drivers/net/ethernet/amd/lance.c b/drivers/net/ethernet/amd/lance.c
index 3a7ebfd..abb1ba2 100644
--- a/drivers/net/ethernet/amd/lance.c
+++ b/drivers/net/ethernet/amd/lance.c
@@ -943,7 +943,7 @@ static void lance_tx_timeout (struct net_device *dev)
 #endif
 	lance_restart (dev, 0x0043, 1);
 
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	netif_wake_queue (dev);
 }
 
diff --git a/drivers/net/ethernet/amd/ni65.c b/drivers/net/ethernet/amd/ni65.c
index 1cf33ad..cda53db 100644
--- a/drivers/net/ethernet/amd/ni65.c
+++ b/drivers/net/ethernet/amd/ni65.c
@@ -782,7 +782,7 @@ static void ni65_stop_start(struct net_device *dev,struct priv *p)
 		if(!p->lock)
 			if (p->tmdnum || !p->xmit_queued)
 				netif_wake_queue(dev);
-		dev->trans_start = jiffies; /* prevent tx timeout */
+		netif_trans_update(dev); /* prevent tx timeout */
 	}
 	else
 		writedatareg(CSR0_STRT | csr0);
@@ -1148,7 +1148,7 @@ static void ni65_timeout(struct net_device *dev)
 		printk("%02x ",p->tmdhead[i].u.s.status);
 	printk("\n");
 	ni65_lance_reinit(dev);
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	netif_wake_queue(dev);
 }
 
diff --git a/drivers/net/ethernet/amd/nmclan_cs.c b/drivers/net/ethernet/amd/nmclan_cs.c
index 27245ef..2807e18 100644
--- a/drivers/net/ethernet/amd/nmclan_cs.c
+++ b/drivers/net/ethernet/amd/nmclan_cs.c
@@ -851,7 +851,7 @@ static void mace_tx_timeout(struct net_device *dev)
 #else /* #if RESET_ON_TIMEOUT */
   pr_cont("NOT resetting card\n");
 #endif /* #if RESET_ON_TIMEOUT */
-  dev->trans_start = jiffies; /* prevent tx timeout */
+  netif_trans_update(dev); /* prevent tx timeout */
   netif_wake_queue(dev);
 }
 
diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index 7ccebae..c22bf52 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -448,7 +448,7 @@ static void pcnet32_netif_stop(struct net_device *dev)
 {
 	struct pcnet32_private *lp = netdev_priv(dev);
 
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	napi_disable(&lp->napi);
 	netif_tx_disable(dev);
 }
@@ -2426,7 +2426,7 @@ static void pcnet32_tx_timeout(struct net_device *dev)
 	}
 	pcnet32_restart(dev, CSR0_NORMAL);
 
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	netif_wake_queue(dev);
 
 	spin_unlock_irqrestore(&lp->lock, flags);
diff --git a/drivers/net/ethernet/amd/sunlance.c b/drivers/net/ethernet/amd/sunlance.c
index 7847638..9b56b40 100644
--- a/drivers/net/ethernet/amd/sunlance.c
+++ b/drivers/net/ethernet/amd/sunlance.c
@@ -997,7 +997,7 @@ static int lance_reset(struct net_device *dev)
 	}
 	lp->init_ring(dev);
 	load_csrs(lp);
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	status = init_restart_lance(lp);
 	return status;
 }
diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index 55b118e..9fe8b5e 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -745,7 +745,7 @@ static netdev_features_t alx_fix_features(struct net_device *netdev,
 
 static void alx_netif_stop(struct alx_priv *alx)
 {
-	alx->dev->trans_start = jiffies;
+	netif_trans_update(alx->dev);
 	if (netif_carrier_ok(alx->dev)) {
 		netif_carrier_off(alx->dev);
 		netif_tx_disable(alx->dev);
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 30b0c28..543bf38 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1117,7 +1117,7 @@ static void bcm_sysport_tx_timeout(struct net_device *dev)
 {
 	netdev_warn(dev, "transmit timeout!\n");
 
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	dev->stats.tx_errors++;
 
 	netif_tx_wake_all_queues(dev);
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index fbff226..5414563 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -3059,7 +3059,7 @@ static void bcmgenet_timeout(struct net_device *dev)
 	bcmgenet_intrl2_0_writel(priv, int0_enable, INTRL2_CPU_MASK_CLEAR);
 	bcmgenet_intrl2_1_writel(priv, int1_enable, INTRL2_CPU_MASK_CLEAR);
 
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 
 	dev->stats.tx_errors++;
 
diff --git a/drivers/net/ethernet/broadcom/sb1250-mac.c b/drivers/net/ethernet/broadcom/sb1250-mac.c
index eacc559..f1b8118 100644
--- a/drivers/net/ethernet/broadcom/sb1250-mac.c
+++ b/drivers/net/ethernet/broadcom/sb1250-mac.c
@@ -2462,7 +2462,7 @@ static void sbmac_tx_timeout (struct net_device *dev)
 	spin_lock_irqsave(&sc->sbm_lock, flags);
 
 
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	dev->stats.tx_errors++;
 
 	spin_unlock_irqrestore(&sc->sbm_lock, flags);
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 3010080..ff300f7 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -7383,7 +7383,7 @@ static void tg3_napi_fini(struct tg3 *tp)
 
 static inline void tg3_netif_stop(struct tg3 *tp)
 {
-	tp->dev->trans_start = jiffies;	/* prevent tx timeout */
+	netif_trans_update(tp->dev);	/* prevent tx timeout */
 	tg3_napi_disable(tp);
 	netif_carrier_off(tp->dev);
 	netif_tx_disable(tp->dev);
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 34d269c..8de79ae 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2899,7 +2899,7 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 	if (status == IQ_SEND_STOP)
 		stop_q(lio->netdev, q_idx);
 
-	netdev->trans_start = jiffies;
+	netif_trans_update(netdev);
 
 	stats->tx_done++;
 	stats->tx_tot_bytes += skb->len;
@@ -2928,7 +2928,7 @@ static void liquidio_tx_timeout(struct net_device *netdev)
 	netif_info(lio, tx_err, lio->netdev,
 		   "Transmit timeout tx_dropped:%ld, waking up queues now!!\n",
 		   netdev->stats.tx_dropped);
-	netdev->trans_start = jiffies;
+	netif_trans_update(netdev);
 	txqs_wake(netdev);
 }
 
diff --git a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
index c177c7c..388cd79 100644
--- a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
@@ -1320,7 +1320,7 @@ static int octeon_mgmt_xmit(struct sk_buff *skb, struct net_device *netdev)
 	/* Ring the bell.  */
 	cvmx_write_csr(p->mix + MIX_ORING2, 1);
 
-	netdev->trans_start = jiffies;
+	netif_trans_update(netdev);
 	rv = NETDEV_TX_OK;
 out:
 	octeon_mgmt_update_tx_stats(netdev);
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index bfee298..a19e73f 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -1442,7 +1442,7 @@ static void nicvf_reset_task(struct work_struct *work)
 
 	nicvf_stop(nic->netdev);
 	nicvf_open(nic->netdev);
-	nic->netdev->trans_start = jiffies;
+	netif_trans_update(nic->netdev);
 }
 
 static int nicvf_config_loopback(struct nicvf *nic,
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 1ccd282..1bb57d3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -1448,7 +1448,7 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * the new TX descriptors and return success.
 	 */
 	txq_advance(&txq->q, ndesc);
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	ring_tx_db(adapter, &txq->q, ndesc);
 	return NETDEV_TX_OK;
 
diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 48d9194..9e06130 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -966,7 +966,7 @@ dm9000_init_dm9000(struct net_device *dev)
 	/* Init Driver variable */
 	db->tx_pkt_cnt = 0;
 	db->queue_pkt_len = 0;
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 }
 
 /* Our watchdog timed out. Called by the networking layer */
@@ -985,7 +985,7 @@ static void dm9000_timeout(struct net_device *dev)
 	dm9000_init_dm9000(dev);
 	dm9000_unmask_interrupts(db);
 	/* We can accept TX packets again */
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	netif_wake_queue(dev);
 
 	/* Restore previous register address */
diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index d88fbab..cbe8497 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -1336,7 +1336,7 @@ de4x5_open(struct net_device *dev)
     }
 
     lp->interrupt = UNMASK_INTERRUPTS;
-    dev->trans_start = jiffies; /* prevent tx timeout */
+    netif_trans_update(dev); /* prevent tx timeout */
 
     START_DE4X5;
 
@@ -1935,7 +1935,7 @@ set_multicast_list(struct net_device *dev)
 
 	    lp->tx_new = (lp->tx_new + 1) % lp->txRingSize;
 	    outl(POLL_DEMAND, DE4X5_TPD);       /* Start the TX */
-	    dev->trans_start = jiffies; /* prevent tx timeout */
+	    netif_trans_update(dev); /* prevent tx timeout */
 	}
     }
 }
diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
index dd1c815..8785f48 100644
--- a/drivers/net/ethernet/dec/tulip/dmfe.c
+++ b/drivers/net/ethernet/dec/tulip/dmfe.c
@@ -725,7 +725,7 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff *skb,
 		txptr->tdes0 = cpu_to_le32(0x80000000);	/* Set owner bit */
 		db->tx_packet_cnt++;			/* Ready to send */
 		dw32(DCR1, 0x1);			/* Issue Tx polling */
-		dev->trans_start = jiffies;		/* saved time stamp */
+		netif_trans_update(dev);		/* saved time stamp */
 	} else {
 		db->tx_queue_cnt++;			/* queue TX packet */
 		dw32(DCR1, 0x1);			/* Issue Tx polling */
@@ -931,7 +931,7 @@ static void dmfe_free_tx_pkt(struct net_device *dev, struct dmfe_board_info * db
 		db->tx_packet_cnt++;			/* Ready to send */
 		db->tx_queue_cnt--;
 		dw32(DCR1, 0x1);			/* Issue Tx polling */
-		dev->trans_start = jiffies;		/* saved time stamp */
+		netif_trans_update(dev);		/* saved time stamp */
 	}
 
 	/* Resource available check */
@@ -1542,7 +1542,7 @@ static void send_filter_frame(struct net_device *dev)
 		update_cr6(db->cr6_data | 0x2000, ioaddr);
 		dw32(DCR1, 0x1);	/* Issue Tx polling */
 		update_cr6(db->cr6_data, ioaddr);
-		dev->trans_start = jiffies;
+		netif_trans_update(dev);
 	} else
 		db->tx_queue_cnt++;	/* Put in TX queue */
 }
diff --git a/drivers/net/ethernet/dec/tulip/pnic.c b/drivers/net/ethernet/dec/tulip/pnic.c
index 5364563..7bcccf5 100644
--- a/drivers/net/ethernet/dec/tulip/pnic.c
+++ b/drivers/net/ethernet/dec/tulip/pnic.c
@@ -44,7 +44,7 @@ void pnic_do_nway(struct net_device *dev)
 			tp->csr6 = new_csr6;
 			/* Restart Tx */
 			tulip_restart_rxtx(tp);
-			dev->trans_start = jiffies;
+			netif_trans_update(dev);
 		}
 	}
 }
@@ -70,7 +70,7 @@ void pnic_lnk_change(struct net_device *dev, int csr5)
 			iowrite32(tp->csr6, ioaddr + CSR6);
 			iowrite32(0x30, ioaddr + CSR12);
 			iowrite32(0x0201F078, ioaddr + 0xB8); /* Turn on autonegotiation. */
-			dev->trans_start = jiffies;
+			netif_trans_update(dev);
 		}
 	} else if (ioread32(ioaddr + CSR5) & TPLnkPass) {
 		if (tulip_media_cap[dev->if_port] & MediaIsMII) {
@@ -147,7 +147,7 @@ void pnic_timer(unsigned long data)
 				tp->csr6 = new_csr6;
 				/* Restart Tx */
 				tulip_restart_rxtx(tp);
-				dev->trans_start = jiffies;
+				netif_trans_update(dev);
 				if (tulip_debug > 1)
 					dev_info(&dev->dev,
 						 "Changing PNIC configuration to %s %s-duplex, CSR6 %08x\n",
diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index 94d0eeb..bbde90b 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -605,7 +605,7 @@ static void tulip_tx_timeout(struct net_device *dev)
 
 out_unlock:
 	spin_unlock_irqrestore (&tp->lock, flags);
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	netif_wake_queue (dev);
 }
 
diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index 447d092..e750b5d 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -636,7 +636,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *skb,
 		txptr->tdes0 = cpu_to_le32(0x80000000);	/* Set owner bit */
 		db->tx_packet_cnt++;			/* Ready to send */
 		uw32(DCR1, 0x1);			/* Issue Tx polling */
-		dev->trans_start = jiffies;		/* saved time stamp */
+		netif_trans_update(dev);		/* saved time stamp */
 	}
 
 	/* Tx resource check */
@@ -1431,7 +1431,7 @@ static void send_filter_frame(struct net_device *dev, int mc_cnt)
 		update_cr6(db->cr6_data | 0x2000, ioaddr);
 		uw32(DCR1, 0x1);	/* Issue Tx polling */
 		update_cr6(db->cr6_data, ioaddr);
-		dev->trans_start = jiffies;
+		netif_trans_update(dev);
 	} else
 		netdev_err(dev, "No Tx resource - Send_filter_frame!\n");
 }
diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
index 3c0e4d5..1f62b94 100644
--- a/drivers/net/ethernet/dec/tulip/winbond-840.c
+++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
@@ -966,7 +966,7 @@ static void tx_timeout(struct net_device *dev)
 	enable_irq(irq);
 
 	netif_wake_queue(dev);
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	np->stats.tx_errors++;
 }
 
diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index f92b6d9..78f1446 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -706,7 +706,7 @@ rio_tx_timeout (struct net_device *dev)
 		dev->name, dr32(TxStatus));
 	rio_free_tx(dev, 0);
 	dev->if_port = 0;
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 }
 
 static netdev_tx_t
diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethernet/dlink/sundance.c
index a28a2e5..58c6338 100644
--- a/drivers/net/ethernet/dlink/sundance.c
+++ b/drivers/net/ethernet/dlink/sundance.c
@@ -1011,7 +1011,7 @@ static void tx_timeout(struct net_device *dev)
 
 	dev->if_port = 0;
 
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	dev->stats.tx_errors++;
 	if (np->cur_tx - np->dirty_tx < TX_QUEUE_LEN - 4) {
 		netif_wake_queue(dev);
diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
index b1b9eba..c08bd76 100644
--- a/drivers/net/ethernet/fealnx.c
+++ b/drivers/net/ethernet/fealnx.c
@@ -1227,7 +1227,7 @@ static void fealnx_tx_timeout(struct net_device *dev)
 
 	spin_unlock_irqrestore(&np->lock, flags);
 
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	dev->stats.tx_errors++;
 	netif_wake_queue(dev); /* or .._start_.. ?? */
 }
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index d2f917a..a580041 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2076,7 +2076,7 @@ void gfar_start(struct gfar_private *priv)
 
 	gfar_ints_enable(priv);
 
-	priv->ndev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(priv->ndev); /* prevent tx timeout */
 }
 
 static void free_grp_irqs(struct gfar_priv_grp *grp)
diff --git a/drivers/net/ethernet/fujitsu/fmvj18x_cs.c b/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
index 678f501..399cfd2 100644
--- a/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
+++ b/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
@@ -746,7 +746,7 @@ static irqreturn_t fjn_interrupt(int dummy, void *dev_id)
 	    lp->sent = lp->tx_queue ;
 	    lp->tx_queue = 0;
 	    lp->tx_queue_len = 0;
-	    dev->trans_start = jiffies;
+	    netif_trans_update(dev);
 	} else {
 	    lp->tx_started = 0;
 	}
diff --git a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
index e51892d..b9f2ea5 100644
--- a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
@@ -636,7 +636,7 @@ static int hix5hd2_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	pos = dma_ring_incr(pos, TX_DESC_NUM);
 	writel_relaxed(dma_byte(pos), priv->base + TX_BQ_WR_ADDR);
 
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
 	netdev_sent_queue(dev, skb->len);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index e47aff2..e621636 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -1275,7 +1275,7 @@ void hns_nic_net_reinit(struct net_device *netdev)
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 
-	priv->netdev->trans_start = jiffies;
+	netif_trans_update(priv->netdev);
 	while (test_and_set_bit(NIC_STATE_REINITING, &priv->state))
 		usleep_range(1000, 2000);
 
@@ -1376,7 +1376,7 @@ static netdev_tx_t hns_nic_net_xmit(struct sk_buff *skb,
 	ret = hns_nic_net_xmit_hw(ndev, skb,
 				  &tx_ring_data(priv, skb->queue_mapping));
 	if (ret == NETDEV_TX_OK) {
-		ndev->trans_start = jiffies;
+		netif_trans_update(ndev);
 		ndev->stats.tx_bytes += skb->len;
 		ndev->stats.tx_packets++;
 	}
@@ -1648,7 +1648,7 @@ static void hns_nic_reset_subtask(struct hns_nic_priv *priv)
 
 	rtnl_lock();
 	/* put off any impending NetWatchDogTimeout */
-	priv->netdev->trans_start = jiffies;
+	netif_trans_update(priv->netdev);
 
 	if (type == HNAE_PORT_DEBUG) {
 		hns_nic_net_reinit(priv->netdev);
diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index 3daf2d4..631dbc7 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -1102,7 +1102,7 @@ static int hp100_open(struct net_device *dev)
 		return -EAGAIN;
 	}
 
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	netif_start_queue(dev);
 
 	lp->lan_type = hp100_sense_lan(dev);
diff --git a/drivers/net/ethernet/i825xx/82596.c b/drivers/net/ethernet/i825xx/82596.c
index 7ce6379..befb4ac 100644
--- a/drivers/net/ethernet/i825xx/82596.c
+++ b/drivers/net/ethernet/i825xx/82596.c
@@ -1042,7 +1042,7 @@ static void i596_tx_timeout (struct net_device *dev)
 		lp->last_restart = dev->stats.tx_packets;
 	}
 
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	netif_wake_queue (dev);
 }
 
diff --git a/drivers/net/ethernet/i825xx/lib82596.c b/drivers/net/ethernet/i825xx/lib82596.c
index c984998..3dbc53c2 100644
--- a/drivers/net/ethernet/i825xx/lib82596.c
+++ b/drivers/net/ethernet/i825xx/lib82596.c
@@ -960,7 +960,7 @@ static void i596_tx_timeout (struct net_device *dev)
 		lp->last_restart = dev->stats.tx_packets;
 	}
 
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	netif_wake_queue (dev);
 }
 
diff --git a/drivers/net/ethernet/i825xx/sun3_82586.c b/drivers/net/ethernet/i825xx/sun3_82586.c
index 353f57f6..21c84cc 100644
--- a/drivers/net/ethernet/i825xx/sun3_82586.c
+++ b/drivers/net/ethernet/i825xx/sun3_82586.c
@@ -983,7 +983,7 @@ static void sun3_82586_timeout(struct net_device *dev)
 		p->scb->cmd_cuc = CUC_START;
 		sun3_attn586();
 		WAIT_4_SCB_CMD();
-		dev->trans_start = jiffies; /* prevent tx timeout */
+		netif_trans_update(dev); /* prevent tx timeout */
 		return 0;
 	}
 #endif
@@ -996,7 +996,7 @@ static void sun3_82586_timeout(struct net_device *dev)
 		sun3_82586_close(dev);
 		sun3_82586_open(dev);
 	}
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 }
 
 /******************************************************
diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 5d7db6c..4c9771d 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -301,7 +301,7 @@ static inline void emac_netif_stop(struct emac_instance *dev)
 	dev->no_mcast = 1;
 	netif_addr_unlock(dev->ndev);
 	netif_tx_unlock_bh(dev->ndev);
-	dev->ndev->trans_start = jiffies;	/* prevent tx timeout */
+	netif_trans_update(dev->ndev);	/* prevent tx timeout */
 	mal_poll_disable(dev->mal, &dev->commac);
 	netif_tx_disable(dev->ndev);
 }
@@ -1377,7 +1377,7 @@ static inline int emac_xmit_finish(struct emac_instance *dev, int len)
 		DBG2(dev, "stopped TX queue" NL);
 	}
 
-	ndev->trans_start = jiffies;
+	netif_trans_update(ndev);
 	++dev->stats.tx_packets;
 	dev->stats.tx_bytes += len;
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 206a466..e05aca9 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -145,7 +145,7 @@ static void fm10k_reinit(struct fm10k_intfc *interface)
 	WARN_ON(in_interrupt());
 
 	/* put off any impending NetWatchDogTimeout */
-	netdev->trans_start = jiffies;
+	netif_trans_update(netdev);
 
 	while (test_and_set_bit(__FM10K_RESETTING, &interface->state))
 		usleep_range(1000, 2000);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 18dcfc5..5f3d239 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5287,7 +5287,7 @@ void ixgbe_reinit_locked(struct ixgbe_adapter *adapter)
 {
 	WARN_ON(in_interrupt());
 	/* put off any impending NetWatchDogTimeout */
-	adapter->netdev->trans_start = jiffies;
+	netif_trans_update(adapter->netdev);
 
 	while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
 		usleep_range(1000, 2000);
diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index d74f5f4..1799fe1 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -152,7 +152,7 @@ static inline void korina_abort_dma(struct net_device *dev,
 	       writel(0x10, &ch->dmac);
 
 	       while (!(readl(&ch->dmas) & DMA_STAT_HALT))
-		       dev->trans_start = jiffies;
+		       netif_trans_update(dev);
 
 	       writel(0, &ch->dmas);
        }
@@ -283,7 +283,7 @@ static int korina_send_packet(struct sk_buff *skb, struct net_device *dev)
 	}
 	dma_cache_wback((u32) td, sizeof(*td));
 
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	return NETDEV_TX_OK;
@@ -622,7 +622,7 @@ korina_tx_dma_interrupt(int irq, void *dev_id)
 				&(lp->tx_dma_regs->dmandptr));
 			lp->tx_chain_status = desc_empty;
 			lp->tx_chain_head = lp->tx_chain_tail;
-			dev->trans_start = jiffies;
+			netif_trans_update(dev);
 		}
 		if (dmas & DMA_STAT_ERR)
 			printk(KERN_ERR "%s: DMA error\n", dev->name);
@@ -811,7 +811,7 @@ static int korina_init(struct net_device *dev)
 	/* reset ethernet logic */
 	writel(0, &lp->eth_regs->ethintfc);
 	while ((readl(&lp->eth_regs->ethintfc) & ETH_INT_FC_RIP))
-		dev->trans_start = jiffies;
+		netif_trans_update(dev);
 
 	/* Enable Ethernet Interface */
 	writel(ETH_INT_FC_EN, &lp->eth_regs->ethintfc);
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index b630ef1..dc82b1b 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -519,7 +519,7 @@ ltq_etop_tx(struct sk_buff *skb, struct net_device *dev)
 	byte_offset = CPHYSADDR(skb->data) % 16;
 	ch->skb[ch->dma.desc] = skb;
 
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 
 	spin_lock_irqsave(&priv->lock, flags);
 	desc->addr = ((unsigned int) dma_map_single(NULL, skb->data, len,
@@ -657,7 +657,7 @@ ltq_etop_tx_timeout(struct net_device *dev)
 	err = ltq_etop_hw_init(dev);
 	if (err)
 		goto err_hw;
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	netif_wake_queue(dev);
 	return;
 
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 7ace07d..c6268b9 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1295,7 +1295,7 @@ static int pxa168_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	stats->tx_bytes += length;
 	stats->tx_packets++;
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	if (pep->tx_ring_size - pep->tx_desc_count <= 1) {
 		/* We handled the current skb, but now we are out of space.*/
 		netif_stop_queue(dev);
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index ec0a221..467138b 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -2418,7 +2418,7 @@ static int sky2_change_mtu(struct net_device *dev, int new_mtu)
 	sky2_write32(hw, B0_IMSK, 0);
 	sky2_read32(hw, B0_IMSK);
 
-	dev->trans_start = jiffies;	/* prevent tx timeout */
+	netif_trans_update(dev);	/* prevent tx timeout */
 	napi_disable(&hw->napi);
 	netif_tx_disable(dev);
 
diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index 75dc46c..280e761 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -4790,7 +4790,7 @@ static void transmit_cleanup(struct dev_info *hw_priv, int normal)
 
 	/* Notify the network subsystem that the packet has been sent. */
 	if (dev)
-		dev->trans_start = jiffies;
+		netif_trans_update(dev);
 }
 
 /**
@@ -4965,7 +4965,7 @@ static void netdev_tx_timeout(struct net_device *dev)
 		hw_ena_intr(hw);
 	}
 
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	netif_wake_queue(dev);
 }
 
diff --git a/drivers/net/ethernet/microchip/encx24j600.c b/drivers/net/ethernet/microchip/encx24j600.c
index 707283b..42e3407 100644
--- a/drivers/net/ethernet/microchip/encx24j600.c
+++ b/drivers/net/ethernet/microchip/encx24j600.c
@@ -874,7 +874,7 @@ static netdev_tx_t encx24j600_tx(struct sk_buff *skb, struct net_device *dev)
 	netif_stop_queue(dev);
 
 	/* save the timestamp */
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 
 	/* Remember the skb for deferred processing */
 	priv->tx_skb = skb;
diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 3e67f45..4367dd6 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -376,7 +376,7 @@ static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	priv->tx_head = TX_NEXT(tx_head);
 
-	ndev->trans_start = jiffies;
+	netif_trans_update(ndev);
 	ret = NETDEV_TX_OK;
 out_unlock:
 	spin_unlock_irq(&priv->txlock);
diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index 122c2ee..ed89029 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -1904,7 +1904,7 @@ static void ns_tx_timeout(struct net_device *dev)
 	spin_unlock_irq(&np->lock);
 	enable_irq(irq);
 
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	dev->stats.tx_errors++;
 	netif_wake_queue(dev);
 }
diff --git a/drivers/net/ethernet/natsemi/sonic.c b/drivers/net/ethernet/natsemi/sonic.c
index 1bd419d..612c7a4 100644
--- a/drivers/net/ethernet/natsemi/sonic.c
+++ b/drivers/net/ethernet/natsemi/sonic.c
@@ -174,7 +174,7 @@ static void sonic_tx_timeout(struct net_device *dev)
 	/* Try to restart the adaptor. */
 	sonic_init(dev);
 	lp->stats.tx_errors++;
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	netif_wake_queue(dev);
 }
 
diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
index 52d9a94..87b7b81 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -476,7 +476,7 @@ static void w90p910_reset_mac(struct net_device *dev)
 
 	w90p910_init_desc(dev);
 
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	ether->cur_tx = 0x0;
 	ether->finish_tx = 0x0;
 	ether->cur_rx = 0x0;
@@ -490,7 +490,7 @@ static void w90p910_reset_mac(struct net_device *dev)
 	w90p910_trigger_tx(dev);
 	w90p910_trigger_rx(dev);
 
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 
 	if (netif_queue_stopped(dev))
 		netif_wake_queue(dev);
diff --git a/drivers/net/ethernet/packetengines/hamachi.c b/drivers/net/ethernet/packetengines/hamachi.c
index 13d88a6..91be2f0 100644
--- a/drivers/net/ethernet/packetengines/hamachi.c
+++ b/drivers/net/ethernet/packetengines/hamachi.c
@@ -1144,7 +1144,7 @@ static void hamachi_tx_timeout(struct net_device *dev)
 	hmp->rx_ring[RX_RING_SIZE-1].status_n_length |= cpu_to_le32(DescEndRing);
 
 	/* Trigger an immediate transmit demand. */
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	dev->stats.tx_errors++;
 
 	/* Restart the chip's Tx/Rx processes . */
diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
index fa2db41..fb1d103 100644
--- a/drivers/net/ethernet/packetengines/yellowfin.c
+++ b/drivers/net/ethernet/packetengines/yellowfin.c
@@ -714,7 +714,7 @@ static void yellowfin_tx_timeout(struct net_device *dev)
 	if (yp->cur_tx - yp->dirty_tx < TX_QUEUE_SIZE)
 		netif_wake_queue (dev);		/* Typical path */
 
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	dev->stats.tx_errors++;
 }
 
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index fd362b6..cad37af 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -2285,7 +2285,7 @@ static void netxen_tx_timeout_task(struct work_struct *work)
 			goto request_reset;
 		}
 	}
-	adapter->netdev->trans_start = jiffies;
+	netif_trans_update(adapter->netdev);
 	rtnl_unlock();
 	return;
 
diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index 82f3c88..6e2add9 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -719,7 +719,7 @@ qcaspi_netdev_xmit(struct sk_buff *skb, struct net_device *dev)
 		qca->stats.ring_full++;
 	}
 
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 
 	if (qca->spi_thread &&
 	    qca->spi_thread->state != TASK_RUNNING)
diff --git a/drivers/net/ethernet/realtek/atp.c b/drivers/net/ethernet/realtek/atp.c
index d77d60e..5cb9678 100644
--- a/drivers/net/ethernet/realtek/atp.c
+++ b/drivers/net/ethernet/realtek/atp.c
@@ -544,7 +544,7 @@ static void tx_timeout(struct net_device *dev)
 	dev->stats.tx_errors++;
 	/* Try to restart the adapter. */
 	hardware_init(dev);
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	netif_wake_queue(dev);
 	dev->stats.tx_errors++;
 }
diff --git a/drivers/net/ethernet/seeq/sgiseeq.c b/drivers/net/ethernet/seeq/sgiseeq.c
index ca73366..c2bd537 100644
--- a/drivers/net/ethernet/seeq/sgiseeq.c
+++ b/drivers/net/ethernet/seeq/sgiseeq.c
@@ -572,7 +572,7 @@ static inline int sgiseeq_reset(struct net_device *dev)
 	if (err)
 		return err;
 
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	netif_wake_queue(dev);
 
 	return 0;
@@ -648,7 +648,7 @@ static void timeout(struct net_device *dev)
 	printk(KERN_NOTICE "%s: transmit timed out, resetting\n", dev->name);
 	sgiseeq_reset(dev);
 
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	netif_wake_queue(dev);
 }
 
diff --git a/drivers/net/ethernet/sgi/meth.c b/drivers/net/ethernet/sgi/meth.c
index 5eac523..aaa80f1 100644
--- a/drivers/net/ethernet/sgi/meth.c
+++ b/drivers/net/ethernet/sgi/meth.c
@@ -708,7 +708,7 @@ static int meth_tx(struct sk_buff *skb, struct net_device *dev)
 	mace->eth.dma_ctrl = priv->dma_ctrl;
 
 	meth_add_to_tx_ring(priv, skb);
-	dev->trans_start = jiffies; /* save the timestamp */
+	netif_trans_update(dev); /* save the timestamp */
 
 	/* If TX ring is full, tell the upper layer to stop sending packets */
 	if (meth_tx_full(dev)) {
@@ -756,7 +756,7 @@ static void meth_tx_timeout(struct net_device *dev)
 	/* Enable interrupt */
 	spin_unlock_irqrestore(&priv->meth_lock, flags);
 
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	netif_wake_queue(dev);
 }
 
diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index fd812d2..95001ee4 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -1575,7 +1575,7 @@ static void sis900_tx_timeout(struct net_device *net_dev)
 
 	spin_unlock_irqrestore(&sis_priv->lock, flags);
 
-	net_dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(net_dev); /* prevent tx timeout */
 
 	/* load Transmit Descriptor Register */
 	sw32(txdp, sis_priv->tx_ring_dma);
diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
index 443f1da..7186b89 100644
--- a/drivers/net/ethernet/smsc/epic100.c
+++ b/drivers/net/ethernet/smsc/epic100.c
@@ -889,7 +889,7 @@ static void epic_tx_timeout(struct net_device *dev)
 		ew32(COMMAND, TxQueued);
 	}
 
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	dev->stats.tx_errors++;
 	if (!ep->tx_full)
 		netif_wake_queue(dev);
diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index a733868..cb49c96 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -499,7 +499,7 @@ static void smc911x_hardware_send_pkt(struct net_device *dev)
 	/* DMA complete IRQ will free buffer and set jiffies */
 #else
 	SMC_PUSH_DATA(lp, buf, len);
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	dev_kfree_skb_irq(skb);
 #endif
 	if (!lp->tx_throttle) {
@@ -1189,7 +1189,7 @@ smc911x_tx_dma_irq(void *data)
 	DBG(SMC_DEBUG_TX | SMC_DEBUG_DMA, dev, "TX DMA irq handler\n");
 	BUG_ON(skb == NULL);
 	dma_unmap_single(NULL, tx_dmabuf, tx_dmalen, DMA_TO_DEVICE);
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	dev_kfree_skb_irq(skb);
 	lp->current_tx_skb = NULL;
 	if (lp->pending_tx_skb != NULL)
@@ -1283,7 +1283,7 @@ static void smc911x_timeout(struct net_device *dev)
 		schedule_work(&lp->phy_configure);
 
 	/* We can accept TX packets again */
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	netif_wake_queue(dev);
 }
 
diff --git a/drivers/net/ethernet/smsc/smc9194.c b/drivers/net/ethernet/smsc/smc9194.c
index 664f596..d496888 100644
--- a/drivers/net/ethernet/smsc/smc9194.c
+++ b/drivers/net/ethernet/smsc/smc9194.c
@@ -663,7 +663,7 @@ static void smc_hardware_send_packet( struct net_device * dev )
 	lp->saved_skb = NULL;
 	dev_kfree_skb_any (skb);
 
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 
 	/* we can send another packet */
 	netif_wake_queue(dev);
@@ -1104,7 +1104,7 @@ static void smc_timeout(struct net_device *dev)
 	/* "kick" the adaptor */
 	smc_reset( dev->base_addr );
 	smc_enable( dev->base_addr );
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	/* clear anything saved */
 	((struct smc_local *)netdev_priv(dev))->saved_skb = NULL;
 	netif_wake_queue(dev);
diff --git a/drivers/net/ethernet/smsc/smc91c92_cs.c b/drivers/net/ethernet/smsc/smc91c92_cs.c
index 3449893..db3c696 100644
--- a/drivers/net/ethernet/smsc/smc91c92_cs.c
+++ b/drivers/net/ethernet/smsc/smc91c92_cs.c
@@ -1172,7 +1172,7 @@ static void smc_hardware_send_packet(struct net_device * dev)
 
     smc->saved_skb = NULL;
     dev_kfree_skb_irq(skb);
-    dev->trans_start = jiffies;
+    netif_trans_update(dev);
     netif_start_queue(dev);
 }
 
@@ -1187,7 +1187,7 @@ static void smc_tx_timeout(struct net_device *dev)
 		  inw(ioaddr)&0xff, inw(ioaddr + 2));
     dev->stats.tx_errors++;
     smc_reset(dev);
-    dev->trans_start = jiffies; /* prevent tx timeout */
+    netif_trans_update(dev); /* prevent tx timeout */
     smc->saved_skb = NULL;
     netif_wake_queue(dev);
 }
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index c5ed27c..18ac52d 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -619,7 +619,7 @@ static void smc_hardware_send_pkt(unsigned long data)
 	SMC_SET_MMU_CMD(lp, MC_ENQUEUE);
 	smc_special_unlock(&lp->lock, flags);
 
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += len;
 
@@ -1364,7 +1364,7 @@ static void smc_timeout(struct net_device *dev)
 		schedule_work(&lp->phy_configure);
 
 	/* We can accept TX packets again */
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	netif_wake_queue(dev);
 }
 
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 9cc4564..a2371aa 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -6431,7 +6431,7 @@ static int niu_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 static void niu_netif_stop(struct niu *np)
 {
-	np->dev->trans_start = jiffies;	/* prevent tx timeout */
+	netif_trans_update(np->dev);	/* prevent tx timeout */
 
 	niu_disable_napi(np);
 
diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index 2437227..d6ad0fb 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -226,7 +226,7 @@ static void gem_put_cell(struct gem *gp)
 
 static inline void gem_netif_stop(struct gem *gp)
 {
-	gp->dev->trans_start = jiffies;	/* prevent tx timeout */
+	netif_trans_update(gp->dev);	/* prevent tx timeout */
 	napi_disable(&gp->napi);
 	netif_tx_disable(gp->dev);
 }
diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index af11ed1..158213c 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -949,7 +949,7 @@ static void dwceqos_adjust_link(struct net_device *ndev)
 
 	if (status_change) {
 		if (phydev->link) {
-			lp->ndev->trans_start = jiffies;
+			netif_trans_update(lp->ndev);
 			dwceqos_link_up(lp);
 		} else {
 			dwceqos_link_down(lp);
@@ -2203,7 +2203,7 @@ static int dwceqos_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	netdev_sent_queue(ndev, skb->len);
 	spin_unlock_bh(&lp->tx_lock);
 
-	ndev->trans_start = jiffies;
+	netif_trans_update(ndev);
 	return 0;
 
 tx_error:
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index 2524a69..7452b5f 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -1701,7 +1701,7 @@ static netdev_tx_t bdx_tx_transmit(struct sk_buff *skb,
 
 #endif
 #ifdef BDX_LLTX
-	ndev->trans_start = jiffies; /* NETIF_F_LLTX driver :( */
+	netif_trans_update(ndev); /* NETIF_F_LLTX driver :( */
 #endif
 	ndev->stats.tx_packets++;
 	ndev->stats.tx_bytes += skb->len;
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 0fa75a8..3d4662d 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1381,7 +1381,7 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	int ret;
 
-	ndev->trans_start = jiffies;
+	netif_trans_update(ndev);
 
 	if (skb_padto(skb, CPSW_MIN_PACKET_SIZE)) {
 		cpsw_err(priv, tx_err, "packet pad failed\n");
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 1d0942c..3251666 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1272,7 +1272,7 @@ static int netcp_ndo_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	if (ret)
 		goto drop;
 
-	ndev->trans_start = jiffies;
+	netif_trans_update(ndev);
 
 	/* Check Tx pool count & stop subqueue if needed */
 	desc_count = knav_pool_count(netcp->tx_pool);
@@ -1788,7 +1788,7 @@ static void netcp_ndo_tx_timeout(struct net_device *ndev)
 
 	dev_err(netcp->ndev_dev, "transmit timed out tx descs(%d)\n", descs);
 	netcp_process_tx_compl_packets(netcp, netcp->tx_pool_size);
-	ndev->trans_start = jiffies;
+	netif_trans_update(ndev);
 	netif_tx_wake_all_queues(ndev);
 }
 
diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index a274cd4..5617033 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -1007,7 +1007,7 @@ static void tlan_tx_timeout(struct net_device *dev)
 	tlan_reset_lists(dev);
 	tlan_read_and_clear_stats(dev, TLAN_IGNORE);
 	tlan_reset_adapter(dev);
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	netif_wake_queue(dev);
 
 }
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 298e059..0bb98bc 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -1883,7 +1883,7 @@ static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
 
 
 	/* Save the timestamp. */
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 
 
 #ifdef TILE_NET_PARANOIA
diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index 6761027..36a6e8b 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -705,7 +705,7 @@ spider_net_prepare_tx_descr(struct spider_net_card *card,
 	wmb();
 	descr->prev->hwdescr->next_descr_addr = descr->bus_addr;
 
-	card->netdev->trans_start = jiffies; /* set netdev watchdog timer */
+	netif_trans_update(card->netdev); /* set netdev watchdog timer */
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 2b7550c..9d14731 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1758,7 +1758,7 @@ static void rhine_reset_task(struct work_struct *work)
 
 	spin_unlock_bh(&rp->lock);
 
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	dev->stats.tx_errors++;
 	netif_wake_queue(dev);
 
diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index 8ed0c77..ec1889c 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -782,7 +782,7 @@ static void w5100_restart(struct net_device *ndev)
 	w5100_hw_reset(priv);
 	w5100_hw_start(priv);
 	ndev->stats.tx_errors++;
-	ndev->trans_start = jiffies;
+	netif_trans_update(ndev);
 	netif_wake_queue(ndev);
 }
 
diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
index 8da7b93..0b37ce9 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -362,7 +362,7 @@ static void w5300_tx_timeout(struct net_device *ndev)
 	w5300_hw_reset(priv);
 	w5300_hw_start(priv);
 	ndev->stats.tx_errors++;
-	ndev->trans_start = jiffies;
+	netif_trans_update(ndev);
 	netif_wake_queue(ndev);
 }
 
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 5a1068d..7397087 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -584,7 +584,7 @@ static void temac_device_reset(struct net_device *ndev)
 		dev_err(&ndev->dev, "Error setting TEMAC options\n");
 
 	/* Init Driver variable */
-	ndev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(ndev); /* prevent tx timeout */
 }
 
 static void temac_adjust_link(struct net_device *ndev)
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 4684644..8c7f5be 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -508,7 +508,7 @@ static void axienet_device_reset(struct net_device *ndev)
 	axienet_set_multicast_list(ndev);
 	axienet_setoptions(ndev, lp->options);
 
-	ndev->trans_start = jiffies;
+	netif_trans_update(ndev);
 }
 
 /**
diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index e324b30..3cee84a 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -531,7 +531,7 @@ static void xemaclite_tx_timeout(struct net_device *dev)
 	}
 
 	/* To exclude tx timeout */
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 
 	/* We're all ready to go. Start the queue */
 	netif_wake_queue(dev);
@@ -563,7 +563,7 @@ static void xemaclite_tx_handler(struct net_device *dev)
 			dev->stats.tx_bytes += lp->deferred_skb->len;
 			dev_kfree_skb_irq(lp->deferred_skb);
 			lp->deferred_skb = NULL;
-			dev->trans_start = jiffies; /* prevent tx timeout */
+			netif_trans_update(dev); /* prevent tx timeout */
 			netif_wake_queue(dev);
 		}
 	}
diff --git a/drivers/net/ethernet/xircom/xirc2ps_cs.c b/drivers/net/ethernet/xircom/xirc2ps_cs.c
index d56f869..7b44968 100644
--- a/drivers/net/ethernet/xircom/xirc2ps_cs.c
+++ b/drivers/net/ethernet/xircom/xirc2ps_cs.c
@@ -1199,7 +1199,7 @@ xirc2ps_tx_timeout_task(struct work_struct *work)
 	struct net_device *dev = local->dev;
     /* reset the card */
     do_reset(dev,1);
-    dev->trans_start = jiffies; /* prevent tx timeout */
+    netif_trans_update(dev); /* prevent tx timeout */
     netif_wake_queue(dev);
 }
 
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 7ad3d04..f4e6926 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -718,7 +718,7 @@ fjes_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 					ret = NETDEV_TX_OK;
 				} else {
-					netdev->trans_start = jiffies;
+					netif_trans_update(netdev);
 					netif_tx_stop_queue(cur_queue);
 
 					if (!work_pending(&adapter->tx_stall_task))
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index c685937..1dfe230 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -519,7 +519,7 @@ static void ax_encaps(struct net_device *dev, unsigned char *icp, int len)
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += actual;
 
-	ax->dev->trans_start = jiffies;
+	netif_trans_update(ax->dev);
 	ax->xleft = count - actual;
 	ax->xhead = ax->xbuff + actual;
 }
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index ce88df3..b808316 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -1669,7 +1669,7 @@ static netdev_tx_t scc_net_tx(struct sk_buff *skb, struct net_device *dev)
 		dev_kfree_skb(skb_del);
 	}
 	skb_queue_tail(&scc->tx_queue, skb);
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	
 
 	/*
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 1a4729c..aaff07c 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -601,7 +601,7 @@ static netdev_tx_t yam_send_packet(struct sk_buff *skb,
 		return ax25_ip_xmit(skb);
 
 	skb_queue_tail(&yp->send_queue, skb);
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 64bb44d..c285eaf 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -1427,7 +1427,7 @@ static netdev_tx_t ali_ircc_fir_hard_xmit(struct sk_buff *skb,
 		/* Check for empty frame */
 		if (!skb->len) {
 			ali_ircc_change_speed(self, speed); 
-			dev->trans_start = jiffies;
+			netif_trans_update(dev);
 			spin_unlock_irqrestore(&self->lock, flags);
 			dev_kfree_skb(skb);
 			return NETDEV_TX_OK;
@@ -1533,7 +1533,7 @@ static netdev_tx_t ali_ircc_fir_hard_xmit(struct sk_buff *skb,
 	/* Restore bank register */
 	switch_bank(iobase, BANK0);
 
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	spin_unlock_irqrestore(&self->lock, flags);
 	dev_kfree_skb(skb);
 
@@ -1946,7 +1946,7 @@ static netdev_tx_t ali_ircc_sir_hard_xmit(struct sk_buff *skb,
 		/* Check for empty frame */
 		if (!skb->len) {
 			ali_ircc_change_speed(self, speed); 
-			dev->trans_start = jiffies;
+			netif_trans_update(dev);
 			spin_unlock_irqrestore(&self->lock, flags);
 			dev_kfree_skb(skb);
 			return NETDEV_TX_OK;
@@ -1966,7 +1966,7 @@ static netdev_tx_t ali_ircc_sir_hard_xmit(struct sk_buff *skb,
 	/* Turn on transmit finished interrupt. Will fire immediately!  */
 	outb(UART_IER_THRI, iobase+UART_IER); 
 
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	spin_unlock_irqrestore(&self->lock, flags);
 
 	dev_kfree_skb(skb);
diff --git a/drivers/net/irda/bfin_sir.c b/drivers/net/irda/bfin_sir.c
index 303c4bd..be5bb0b 100644
--- a/drivers/net/irda/bfin_sir.c
+++ b/drivers/net/irda/bfin_sir.c
@@ -531,7 +531,7 @@ static void bfin_sir_send_work(struct work_struct *work)
 	bfin_sir_dma_tx_chars(dev);
 #endif
 	bfin_sir_enable_tx(port);
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 }
 
 static int bfin_sir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 25f2196..a198946 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -429,7 +429,7 @@ static netdev_tx_t irda_usb_hard_xmit(struct sk_buff *skb,
 			 * do an extra memcpy and increment packet counters...
 			 * Jean II */
 			irda_usb_change_speed_xbofs(self);
-			netdev->trans_start = jiffies;
+			netif_trans_update(netdev);
 			/* Will netif_wake_queue() in callback */
 			goto drop;
 		}
@@ -526,7 +526,7 @@ static netdev_tx_t irda_usb_hard_xmit(struct sk_buff *skb,
 		netdev->stats.tx_packets++;
                 netdev->stats.tx_bytes += skb->len;
 		
-		netdev->trans_start = jiffies;
+		netif_trans_update(netdev);
 	}
 	spin_unlock_irqrestore(&self->lock, flags);
 	
diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index dc0dbd8..9ef13d8 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -1399,7 +1399,7 @@ static netdev_tx_t nsc_ircc_hard_xmit_sir(struct sk_buff *skb,
 				 * to make sure packets gets through the
 				 * proper xmit handler - Jean II */
 			}
-			dev->trans_start = jiffies;
+			netif_trans_update(dev);
 			spin_unlock_irqrestore(&self->lock, flags);
 			dev_kfree_skb(skb);
 			return NETDEV_TX_OK;
@@ -1424,7 +1424,7 @@ static netdev_tx_t nsc_ircc_hard_xmit_sir(struct sk_buff *skb,
 	/* Restore bank register */
 	outb(bank, iobase+BSR);
 
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	spin_unlock_irqrestore(&self->lock, flags);
 
 	dev_kfree_skb(skb);
@@ -1470,7 +1470,7 @@ static netdev_tx_t nsc_ircc_hard_xmit_fir(struct sk_buff *skb,
 				 * the speed change has been done.
 				 * Jean II */
 			}
-			dev->trans_start = jiffies;
+			netif_trans_update(dev);
 			spin_unlock_irqrestore(&self->lock, flags);
 			dev_kfree_skb(skb);
 			return NETDEV_TX_OK;
@@ -1553,7 +1553,7 @@ static netdev_tx_t nsc_ircc_hard_xmit_fir(struct sk_buff *skb,
 	/* Restore bank register */
 	outb(bank, iobase+BSR);
 
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	spin_unlock_irqrestore(&self->lock, flags);
 	dev_kfree_skb(skb);
 
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index b455ffe..dcf92ba 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -862,7 +862,7 @@ static void smsc_ircc_timeout(struct net_device *dev)
 	spin_lock_irqsave(&self->lock, flags);
 	smsc_ircc_sir_start(self);
 	smsc_ircc_change_speed(self, self->io.speed);
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 	netif_wake_queue(dev);
 	spin_unlock_irqrestore(&self->lock, flags);
 }
diff --git a/drivers/net/irda/stir4200.c b/drivers/net/irda/stir4200.c
index 83cc48a..42da094 100644
--- a/drivers/net/irda/stir4200.c
+++ b/drivers/net/irda/stir4200.c
@@ -718,7 +718,7 @@ static void stir_send(struct stir_cb *stir, struct sk_buff *skb)
 
 	stir->netdev->stats.tx_packets++;
 	stir->netdev->stats.tx_bytes += skb->len;
-	stir->netdev->trans_start = jiffies;
+	netif_trans_update(stir->netdev);
 	pr_debug("send %d (%d)\n", skb->len, wraplen);
 
 	if (usb_bulk_msg(stir->usbdev, usb_sndbulkpipe(stir->usbdev, 1),
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 6960d4c..ca4442a 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -774,7 +774,7 @@ static netdev_tx_t via_ircc_hard_xmit_sir(struct sk_buff *skb,
 		/* Check for empty frame */
 		if (!skb->len) {
 			via_ircc_change_speed(self, speed);
-			dev->trans_start = jiffies;
+			netif_trans_update(dev);
 			dev_kfree_skb(skb);
 			return NETDEV_TX_OK;
 		} else
@@ -821,7 +821,7 @@ static netdev_tx_t via_ircc_hard_xmit_sir(struct sk_buff *skb,
 	RXStart(iobase, OFF);
 	TXStart(iobase, ON);
 
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	spin_unlock_irqrestore(&self->lock, flags);
 	dev_kfree_skb(skb);
 	return NETDEV_TX_OK;
@@ -849,7 +849,7 @@ static netdev_tx_t via_ircc_hard_xmit_fir(struct sk_buff *skb,
 	if ((speed != self->io.speed) && (speed != -1)) {
 		if (!skb->len) {
 			via_ircc_change_speed(self, speed);
-			dev->trans_start = jiffies;
+			netif_trans_update(dev);
 			dev_kfree_skb(skb);
 			return NETDEV_TX_OK;
 		} else
@@ -869,7 +869,7 @@ static netdev_tx_t via_ircc_hard_xmit_fir(struct sk_buff *skb,
 	via_ircc_dma_xmit(self, iobase);
 //F01   }
 //F01   if (self->tx_fifo.free < (MAX_TX_WINDOW -1 )) netif_wake_queue(self->netdev);
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	dev_kfree_skb(skb);
 	spin_unlock_irqrestore(&self->lock, flags);
 	return NETDEV_TX_OK;
diff --git a/drivers/net/slip/slip.c b/drivers/net/slip/slip.c
index a17d86a..9ed6d1c 100644
--- a/drivers/net/slip/slip.c
+++ b/drivers/net/slip/slip.c
@@ -407,7 +407,7 @@ static void sl_encaps(struct slip *sl, unsigned char *icp, int len)
 	set_bit(TTY_DO_WRITE_WAKEUP, &sl->tty->flags);
 	actual = sl->tty->ops->write(sl->tty, sl->xbuff, count);
 #ifdef SL_CHECK_TRANSMIT
-	sl->dev->trans_start = jiffies;
+	netif_trans_update(sl->dev);
 #endif
 	sl->xleft = count - actual;
 	sl->xhead = sl->xbuff + actual;
diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index 4e2b26a..d9ca05d 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -376,7 +376,7 @@ static int catc_tx_run(struct catc *catc)
 	catc->tx_idx = !catc->tx_idx;
 	catc->tx_ptr = 0;
 
-	catc->netdev->trans_start = jiffies;
+	netif_trans_update(catc->netdev);
 	return status;
 }
 
@@ -389,7 +389,7 @@ static void catc_tx_done(struct urb *urb)
 	if (status == -ECONNRESET) {
 		dev_dbg(&urb->dev->dev, "Tx Reset.\n");
 		urb->status = 0;
-		catc->netdev->trans_start = jiffies;
+		netif_trans_update(catc->netdev);
 		catc->netdev->stats.tx_errors++;
 		clear_bit(TX_RUNNING, &catc->flags);
 		netif_wake_queue(catc->netdev);
diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index f64b25c..770212b 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -938,7 +938,7 @@ static void kaweth_tx_timeout(struct net_device *net)
 
 	dev_warn(&net->dev, "%s: Tx timed out. Resetting.\n", net->name);
 	kaweth->stats.tx_errors++;
-	net->trans_start = jiffies;
+	netif_trans_update(net);
 
 	usb_unlink_urb(kaweth->tx_urb);
 }
diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index f20890e..0ea883a 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -3013,7 +3013,7 @@ gso_skb:
 	ret = usb_submit_urb(urb, GFP_ATOMIC);
 	switch (ret) {
 	case 0:
-		dev->net->trans_start = jiffies;
+		netif_trans_update(dev->net);
 		lan78xx_queue_skb(&dev->txq, skb, tx_start);
 		if (skb_queue_len(&dev->txq) >= dev->tx_qlen)
 			netif_stop_queue(dev->net);
@@ -3697,7 +3697,7 @@ int lan78xx_resume(struct usb_interface *intf)
 				usb_free_urb(res);
 				usb_autopm_put_interface_async(dev->intf);
 			} else {
-				dev->net->trans_start = jiffies;
+				netif_trans_update(dev->net);
 				lan78xx_queue_skb(&dev->txq, skb, tx_start);
 			}
 		}
diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index f840802..80d05db 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -615,7 +615,7 @@ static void write_bulk_callback(struct urb *urb)
 		break;
 	}
 
-	net->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(net); /* prevent tx timeout */
 	netif_wake_queue(net);
 }
 
diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index d37b7dc..7c72bfa 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -451,7 +451,7 @@ static void write_bulk_callback(struct urb *urb)
 	if (status)
 		dev_info(&urb->dev->dev, "%s: Tx status %d\n",
 			 dev->netdev->name, status);
-	dev->netdev->trans_start = jiffies;
+	netif_trans_update(dev->netdev);
 	netif_wake_queue(dev->netdev);
 }
 
@@ -694,7 +694,7 @@ static netdev_tx_t rtl8150_start_xmit(struct sk_buff *skb,
 	} else {
 		netdev->stats.tx_packets++;
 		netdev->stats.tx_bytes += skb->len;
-		netdev->trans_start = jiffies;
+		netif_trans_update(netdev);
 	}
 
 	return NETDEV_TX_OK;
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 1079812..f3b1f5a 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1415,7 +1415,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 			  "tx: submit urb err %d\n", retval);
 		break;
 	case 0:
-		net->trans_start = jiffies;
+		netif_trans_update(net);
 		__usbnet_queue_skb(&dev->txq, skb, tx_start);
 		if (dev->txq.qlen >= TX_QLEN (dev))
 			netif_stop_queue (net);
@@ -1844,7 +1844,7 @@ int usbnet_resume (struct usb_interface *intf)
 				usb_free_urb(res);
 				usb_autopm_put_interface_async(dev->intf);
 			} else {
-				dev->net->trans_start = jiffies;
+				netif_trans_update(dev->net);
 				__skb_queue_tail(&dev->txq, skb);
 			}
 		}
diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index 848ea6a..b87fe0a 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -739,7 +739,7 @@ static char *cosa_net_setup_rx(struct channel_data *chan, int size)
 		chan->netdev->stats.rx_dropped++;
 		return NULL;
 	}
-	chan->netdev->trans_start = jiffies;
+	netif_trans_update(chan->netdev);
 	return skb_put(chan->rx_skb, size);
 }
 
diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index 69b994f..3c9cbf9 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -831,7 +831,7 @@ fst_tx_dma_complete(struct fst_card_info *card, struct fst_port_info *port,
 		DMA_OWN | TX_STP | TX_ENP);
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += len;
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 }
 
 /*
@@ -1389,7 +1389,7 @@ do_bottom_half_tx(struct fst_card_info *card)
 						DMA_OWN | TX_STP | TX_ENP);
 					dev->stats.tx_packets++;
 					dev->stats.tx_bytes += skb->len;
-					dev->trans_start = jiffies;
+					netif_trans_update(dev);
 				} else {
 					/* Or do it through dma */
 					memcpy(card->tx_dma_handle_host,
@@ -2258,7 +2258,7 @@ fst_tx_timeout(struct net_device *dev)
 	    card->card_no, port->index);
 	fst_issue_cmd(port, ABORTTX);
 
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	netif_wake_queue(dev);
 	port->start = 0;
 }
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index bb33b24..299140c 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -2105,7 +2105,7 @@ static void lmc_driver_timeout(struct net_device *dev)
     sc->lmc_device->stats.tx_errors++;
     sc->extra_stats.tx_ProcTimeout++; /* -baz */
 
-    dev->trans_start = jiffies; /* prevent tx timeout */
+    netif_trans_update(dev); /* prevent tx timeout */
 
 bug_out:
 
diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index 8fef8d8..d98c7e5 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -860,9 +860,9 @@ prepare_to_send( struct sk_buff  *skb,  struct net_device  *dev )
 
 	outb( inb( dev->base_addr + CSR0 ) | TR_REQ,  dev->base_addr + CSR0 );
 #ifdef CONFIG_SBNI_MULTILINE
-	nl->master->trans_start = jiffies;
+	netif_trans_update(nl->master);
 #else
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 #endif
 }
 
@@ -889,10 +889,10 @@ drop_xmit_queue( struct net_device  *dev )
 	nl->state &= ~(FL_WAIT_ACK | FL_NEED_RESEND);
 #ifdef CONFIG_SBNI_MULTILINE
 	netif_start_queue( nl->master );
-	nl->master->trans_start = jiffies;
+	netif_trans_update(nl->master);
 #else
 	netif_start_queue( dev );
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 #endif
 }
 
diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index a9970f1..bb74f4b 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -334,7 +334,7 @@ int i2400m_net_tx(struct i2400m *i2400m, struct net_device *net_dev,
 	d_fnstart(3, dev, "(i2400m %p net_dev %p skb %p)\n",
 		  i2400m, net_dev, skb);
 	/* FIXME: check eth hdr, only IPv4 is routed by the device as of now */
-	net_dev->trans_start = jiffies;
+	netif_trans_update(net_dev);
 	i2400m_tx_prep_header(skb);
 	d_printf(3, dev, "NETTX: skb %p sending %d bytes to radio\n",
 		 skb, skb->len);
diff --git a/drivers/net/wireless/cisco/airo.c b/drivers/net/wireless/cisco/airo.c
index 4bd9e2b..55456f7 100644
--- a/drivers/net/wireless/cisco/airo.c
+++ b/drivers/net/wireless/cisco/airo.c
@@ -2026,7 +2026,7 @@ static int mpi_send_packet (struct net_device *dev)
 	} else {
 		*payloadLen = cpu_to_le16(len - sizeof(etherHead));
 
-		dev->trans_start = jiffies;
+		netif_trans_update(dev);
 
 		/* copy data into airo dma buffer */
 		memcpy(sendbuf, buffer, len);
@@ -2107,7 +2107,7 @@ static void airo_end_xmit(struct net_device *dev) {
 
 	i = 0;
 	if ( status == SUCCESS ) {
-		dev->trans_start = jiffies;
+		netif_trans_update(dev);
 		for (; i < MAX_FIDS / 2 && (priv->fids[i] & 0xffff0000); i++);
 	} else {
 		priv->fids[fid] &= 0xffff;
@@ -2174,7 +2174,7 @@ static void airo_end_xmit11(struct net_device *dev) {
 
 	i = MAX_FIDS / 2;
 	if ( status == SUCCESS ) {
-		dev->trans_start = jiffies;
+		netif_trans_update(dev);
 		for (; i < MAX_FIDS && (priv->fids[i] & 0xffff0000); i++);
 	} else {
 		priv->fids[fid] &= 0xffff;
diff --git a/drivers/net/wireless/intel/ipw2x00/ipw2100.c b/drivers/net/wireless/intel/ipw2x00/ipw2100.c
index e1e42ed..bfa542c 100644
--- a/drivers/net/wireless/intel/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/intel/ipw2x00/ipw2100.c
@@ -2954,7 +2954,7 @@ static int __ipw2100_tx_process(struct ipw2100_priv *priv)
 
 		/* A packet was processed by the hardware, so update the
 		 * watchdog */
-		priv->net_dev->trans_start = jiffies;
+		netif_trans_update(priv->net_dev);
 
 		break;
 
diff --git a/drivers/net/wireless/intel/ipw2x00/ipw2200.c b/drivers/net/wireless/intel/ipw2x00/ipw2200.c
index dac13cf..5adb7ce 100644
--- a/drivers/net/wireless/intel/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/intel/ipw2x00/ipw2200.c
@@ -7707,7 +7707,7 @@ static void ipw_handle_data_packet(struct ipw_priv *priv,
 	struct ipw_rx_packet *pkt = (struct ipw_rx_packet *)rxb->skb->data;
 
 	/* We received data from the HW, so stop the watchdog */
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 
 	/* We only process data packets if the
 	 * interface is open */
@@ -7770,7 +7770,7 @@ static void ipw_handle_data_packet_monitor(struct ipw_priv *priv,
 	unsigned short len = le16_to_cpu(pkt->u.frame.length);
 
 	/* We received data from the HW, so stop the watchdog */
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 
 	/* We only process data packets if the
 	 * interface is open */
@@ -7952,7 +7952,7 @@ static void ipw_handle_promiscuous_rx(struct ipw_priv *priv,
 		return;
 
 	/* We received data from the HW, so stop the watchdog */
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 
 	if (unlikely((len + IPW_RX_FRAME_SIZE) > skb_tailroom(rxb->skb))) {
 		dev->stats.rx_errors++;
diff --git a/drivers/net/wireless/intersil/hostap/hostap_hw.c b/drivers/net/wireless/intersil/hostap/hostap_hw.c
index 515aa3f..a8a9bd8 100644
--- a/drivers/net/wireless/intersil/hostap/hostap_hw.c
+++ b/drivers/net/wireless/intersil/hostap/hostap_hw.c
@@ -1794,7 +1794,7 @@ static int prism2_transmit(struct net_device *dev, int idx)
 		netif_wake_queue(dev);
 		return -1;
 	}
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 
 	/* Since we did not wait for command completion, the card continues
 	 * to process on the background and we will finish handling when
diff --git a/drivers/net/wireless/intersil/orinoco/main.c b/drivers/net/wireless/intersil/orinoco/main.c
index 7b5c554..7afe200 100644
--- a/drivers/net/wireless/intersil/orinoco/main.c
+++ b/drivers/net/wireless/intersil/orinoco/main.c
@@ -1794,7 +1794,7 @@ void orinoco_reset(struct work_struct *work)
 			printk(KERN_ERR "%s: orinoco_reset: Error %d reenabling card\n",
 			       dev->name, err);
 		} else
-			dev->trans_start = jiffies;
+			netif_trans_update(dev);
 	}
 
 	orinoco_unlock_irq(priv);
diff --git a/drivers/net/wireless/intersil/orinoco/orinoco_usb.c b/drivers/net/wireless/intersil/orinoco/orinoco_usb.c
index f2cd513..56f109b 100644
--- a/drivers/net/wireless/intersil/orinoco/orinoco_usb.c
+++ b/drivers/net/wireless/intersil/orinoco/orinoco_usb.c
@@ -1275,7 +1275,7 @@ static netdev_tx_t ezusb_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto busy;
 	}
 
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	stats->tx_bytes += skb->len;
 	goto ok;
 
diff --git a/drivers/net/wireless/marvell/mwifiex/init.c b/drivers/net/wireless/marvell/mwifiex/init.c
index 517653b..78c532f 100644
--- a/drivers/net/wireless/marvell/mwifiex/init.c
+++ b/drivers/net/wireless/marvell/mwifiex/init.c
@@ -317,7 +317,7 @@ void mwifiex_set_trans_start(struct net_device *dev)
 	for (i = 0; i < dev->num_tx_queues; i++)
 		netdev_get_tx_queue(dev, i)->trans_start = jiffies;
 
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 }
 
 /*
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 99de07d..13fd734 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1287,7 +1287,7 @@ static void wl3501_tx_timeout(struct net_device *dev)
 		printk(KERN_ERR "%s: Error %d resetting card on Tx timeout!\n",
 		       dev->name, rc);
 	else {
-		dev->trans_start = jiffies; /* prevent tx timeout */
+		netif_trans_update(dev); /* prevent tx timeout */
 		netif_wake_queue(dev);
 	}
 }
diff --git a/drivers/net/wireless/zydas/zd1201.c b/drivers/net/wireless/zydas/zd1201.c
index 6f5c793..dea049b 100644
--- a/drivers/net/wireless/zydas/zd1201.c
+++ b/drivers/net/wireless/zydas/zd1201.c
@@ -845,7 +845,7 @@ static void zd1201_tx_timeout(struct net_device *dev)
 	usb_unlink_urb(zd->tx_urb);
 	dev->stats.tx_errors++;
 	/* Restart the timeout to quiet the watchdog: */
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	netif_trans_update(dev); /* prevent tx timeout */
 }
 
 static int zd1201_set_mac_address(struct net_device *dev, void *p)
diff --git a/drivers/s390/net/ctcm_main.c b/drivers/s390/net/ctcm_main.c
index c3e2252..ad17fc5 100644
--- a/drivers/s390/net/ctcm_main.c
+++ b/drivers/s390/net/ctcm_main.c
@@ -642,7 +642,7 @@ static void ctcmpc_send_sweep_req(struct channel *rch)
 
 	kfree(header);
 
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	skb_queue_tail(&ch->sweep_queue, sweep_skb);
 
 	fsm_addtimer(&ch->sweep_timer, 100, CTC_EVENT_RSWEEP_TIMER, ch);
@@ -911,7 +911,7 @@ static int ctcm_tx(struct sk_buff *skb, struct net_device *dev)
 	if (ctcm_test_and_set_busy(dev))
 		return NETDEV_TX_BUSY;
 
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	if (ctcm_transmit_skb(priv->channel[CTCM_WRITE], skb) != 0)
 		return NETDEV_TX_BUSY;
 	return NETDEV_TX_OK;
@@ -994,7 +994,7 @@ static int ctcmpc_tx(struct sk_buff *skb, struct net_device *dev)
 					goto done;
 	}
 
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	if (ctcmpc_transmit_skb(priv->channel[CTCM_WRITE], skb) != 0) {
 		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
 			"%s(%s): device error - dropped",
diff --git a/drivers/s390/net/ctcm_mpc.c b/drivers/s390/net/ctcm_mpc.c
index edf16bf..c103fc7 100644
--- a/drivers/s390/net/ctcm_mpc.c
+++ b/drivers/s390/net/ctcm_mpc.c
@@ -671,7 +671,7 @@ static void ctcmpc_send_sweep_resp(struct channel *rch)
 
 	kfree(header);
 
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	skb_queue_tail(&ch->sweep_queue, sweep_skb);
 
 	fsm_addtimer(&ch->sweep_timer, 100, CTC_EVENT_RSWEEP_TIMER, ch);
diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index 0ba3a2f..b0e8ffd 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -1407,7 +1407,7 @@ static int netiucv_tx(struct sk_buff *skb, struct net_device *dev)
 		IUCV_DBF_TEXT(data, 2, "EBUSY from netiucv_tx\n");
 		return NETDEV_TX_BUSY;
 	}
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	rc = netiucv_transmit_skb(privptr->conn, skb);
 	netiucv_clear_busy(dev);
 	return rc ? NETDEV_TX_BUSY : NETDEV_TX_OK;
diff --git a/drivers/staging/rtl8192e/rtl8192e/rtl_core.c b/drivers/staging/rtl8192e/rtl8192e/rtl_core.c
index 9b7cc7d..13a5ddc 100644
--- a/drivers/staging/rtl8192e/rtl8192e/rtl_core.c
+++ b/drivers/staging/rtl8192e/rtl8192e/rtl_core.c
@@ -1792,7 +1792,7 @@ static short _rtl92e_tx(struct net_device *dev, struct sk_buff *skb)
 	__skb_queue_tail(&ring->queue, skb);
 	pdesc->OWN = 1;
 	spin_unlock_irqrestore(&priv->irq_th_lock, flags);
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 
 	rtl92e_writew(dev, TPPoll, 0x01 << tcb_desc->queue_index);
 	return 0;
diff --git a/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c b/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c
index de71450..d705595 100644
--- a/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c
+++ b/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c
@@ -249,7 +249,7 @@ inline void softmac_mgmt_xmit(struct sk_buff *skb, struct ieee80211_device *ieee
 				ieee->seq_ctrl[0]++;
 
 			/* avoid watchdog triggers */
-			ieee->dev->trans_start = jiffies;
+			netif_trans_update(ieee->dev);
 			ieee->softmac_data_hard_start_xmit(skb,ieee->dev,ieee->basic_rate);
 			//dev_kfree_skb_any(skb);//edit by thomas
 		}
@@ -302,7 +302,7 @@ inline void softmac_ps_mgmt_xmit(struct sk_buff *skb, struct ieee80211_device *i
 			ieee->seq_ctrl[0]++;
 
 		/* avoid watchdog triggers */
-		ieee->dev->trans_start = jiffies;
+		netif_trans_update(ieee->dev);
 		ieee->softmac_data_hard_start_xmit(skb,ieee->dev,ieee->basic_rate);
 
 	}else{
@@ -2205,7 +2205,7 @@ static void ieee80211_resume_tx(struct ieee80211_device *ieee)
 				ieee->dev, ieee->rate);
 				//(i+1)<ieee->tx_pending.txb->nr_frags);
 			ieee->stats.tx_packets++;
-			ieee->dev->trans_start = jiffies;
+			netif_trans_update(ieee->dev);
 		}
 	}
 
diff --git a/drivers/staging/rtl8192u/r8192U_core.c b/drivers/staging/rtl8192u/r8192U_core.c
index 849a95e..4af0140 100644
--- a/drivers/staging/rtl8192u/r8192U_core.c
+++ b/drivers/staging/rtl8192u/r8192U_core.c
@@ -1108,7 +1108,7 @@ static void rtl8192_tx_isr(struct urb *tx_urb)
 
 	if (tcb_desc->queue_index != TXCMD_QUEUE) {
 		if (tx_urb->status == 0) {
-			dev->trans_start = jiffies;
+			netif_trans_update(dev);
 			priv->stats.txoktotal++;
 			priv->ieee80211->LinkDetectInfo.NumTxOkInPeriod++;
 			priv->stats.txbytesunicast +=
@@ -1715,7 +1715,7 @@ short rtl8192_tx(struct net_device *dev, struct sk_buff *skb)
 				return -1;
 			}
 		}
-		dev->trans_start = jiffies;
+		netif_trans_update(dev);
 		atomic_inc(&priv->tx_pending[tcb_desc->queue_index]);
 		return 0;
 	}
diff --git a/drivers/staging/wlan-ng/p80211netdev.c b/drivers/staging/wlan-ng/p80211netdev.c
index 88255ce..1f9dfba 100644
--- a/drivers/staging/wlan-ng/p80211netdev.c
+++ b/drivers/staging/wlan-ng/p80211netdev.c
@@ -393,7 +393,7 @@ static int p80211knetdev_hard_start_xmit(struct sk_buff *skb,
 		goto failed;
 	}
 
-	netdev->trans_start = jiffies;
+	netif_trans_update(netdev);
 
 	netdev->stats.tx_packets++;
 	/* count only the packet payload */
diff --git a/drivers/tty/n_gsm.c b/drivers/tty/n_gsm.c
index c016207..0c27a00 100644
--- a/drivers/tty/n_gsm.c
+++ b/drivers/tty/n_gsm.c
@@ -2662,7 +2662,7 @@ static int gsm_mux_net_start_xmit(struct sk_buff *skb,
 	STATS(net).tx_bytes += skb->len;
 	gsm_dlci_data_kick(dlci);
 	/* And tell the kernel when the last transmit started. */
-	net->trans_start = jiffies;
+	netif_trans_update(net);
 	muxnet_put(mux_net);
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/tty/synclink.c b/drivers/tty/synclink.c
index f5476e2..c8c7601 100644
--- a/drivers/tty/synclink.c
+++ b/drivers/tty/synclink.c
@@ -7708,7 +7708,7 @@ static netdev_tx_t hdlcdev_xmit(struct sk_buff *skb,
 	dev_kfree_skb(skb);
 
 	/* save start time for transmit timeout detection */
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 
 	/* start hardware transmitter if necessary */
 	spin_lock_irqsave(&info->irq_spinlock,flags);
@@ -7764,7 +7764,7 @@ static int hdlcdev_open(struct net_device *dev)
 	mgsl_program_hw(info);
 
 	/* enable network layer transmit */
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	netif_start_queue(dev);
 
 	/* inform generic HDLC layer of current DCD status */
diff --git a/drivers/tty/synclink_gt.c b/drivers/tty/synclink_gt.c
index c0a2f5a..d5b6471 100644
--- a/drivers/tty/synclink_gt.c
+++ b/drivers/tty/synclink_gt.c
@@ -1493,7 +1493,7 @@ static netdev_tx_t hdlcdev_xmit(struct sk_buff *skb,
 	dev->stats.tx_bytes += skb->len;
 
 	/* save start time for transmit timeout detection */
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 
 	spin_lock_irqsave(&info->lock, flags);
 	tx_load(info, skb->data, skb->len);
@@ -1552,7 +1552,7 @@ static int hdlcdev_open(struct net_device *dev)
 	program_hw(info);
 
 	/* enable network layer transmit */
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	netif_start_queue(dev);
 
 	/* inform generic HDLC layer of current DCD status */
diff --git a/drivers/tty/synclinkmp.c b/drivers/tty/synclinkmp.c
index 90da0c7..3f89685 100644
--- a/drivers/tty/synclinkmp.c
+++ b/drivers/tty/synclinkmp.c
@@ -1612,7 +1612,7 @@ static netdev_tx_t hdlcdev_xmit(struct sk_buff *skb,
 	dev_kfree_skb(skb);
 
 	/* save start time for transmit timeout detection */
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 
 	/* start hardware transmitter if necessary */
 	spin_lock_irqsave(&info->lock,flags);
@@ -1668,7 +1668,7 @@ static int hdlcdev_open(struct net_device *dev)
 	program_hw(info);
 
 	/* enable network layer transmit */
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	netif_start_queue(dev);
 
 	/* inform generic HDLC layer of current DCD status */
diff --git a/drivers/usb/gadget/function/u_ether.c b/drivers/usb/gadget/function/u_ether.c
index 637809e..a3f7e7c 100644
--- a/drivers/usb/gadget/function/u_ether.c
+++ b/drivers/usb/gadget/function/u_ether.c
@@ -597,7 +597,7 @@ static netdev_tx_t eth_start_xmit(struct sk_buff *skb,
 		DBG(dev, "tx queue err %d\n", retval);
 		break;
 	case 0:
-		net->trans_start = jiffies;
+		netif_trans_update(net);
 		atomic_inc(&dev->tx_qlen);
 	}
 
diff --git a/net/atm/lec.c b/net/atm/lec.c
index cd3b379..e574a7e 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -194,7 +194,7 @@ lec_send(struct atm_vcc *vcc, struct sk_buff *skb)
 static void lec_tx_timeout(struct net_device *dev)
 {
 	pr_info("%s\n", dev->name);
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	netif_wake_queue(dev);
 }
 
@@ -324,7 +324,7 @@ static netdev_tx_t lec_start_xmit(struct sk_buff *skb,
 out:
 	if (entry)
 		lec_arp_put(entry);
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	return NETDEV_TX_OK;
 }
 
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 0710379..bae1397 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -208,7 +208,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	if (atomic_read(&bat_priv->mesh_state) != BATADV_MESH_ACTIVE)
 		goto dropped;
 
-	soft_iface->trans_start = jiffies;
+	netif_trans_update(soft_iface);
 	vid = batadv_get_vid(skb, 0);
 	ethhdr = eth_hdr(skb);
 
diff --git a/net/bluetooth/bnep/netdev.c b/net/bluetooth/bnep/netdev.c
index 6ceb5d3..f4fcb4a 100644
--- a/net/bluetooth/bnep/netdev.c
+++ b/net/bluetooth/bnep/netdev.c
@@ -188,7 +188,7 @@ static netdev_tx_t bnep_net_xmit(struct sk_buff *skb,
 	 * So we have to queue them and wake up session thread which is sleeping
 	 * on the sk_sleep(sk).
 	 */
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 	skb_queue_tail(&sk->sk_write_queue, skb);
 	wake_up_interruptible(sk_sleep(sk));
 
diff --git a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
index fcfbe57..d8b7267 100644
--- a/net/irda/irlan/irlan_eth.c
+++ b/net/irda/irlan/irlan_eth.c
@@ -181,7 +181,7 @@ static netdev_tx_t irlan_eth_xmit(struct sk_buff *skb,
 		skb = new_skb;
 	}
 
-	dev->trans_start = jiffies;
+	netif_trans_update(dev);
 
 	len = skb->len;
 	/* Now queue the packet in the transport layer */
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 9c77562..70182cf 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -775,7 +775,7 @@ void dev_activate(struct net_device *dev)
 		transition_one_qdisc(dev, dev_ingress_queue(dev), NULL);
 
 	if (need_watchdog) {
-		dev->trans_start = jiffies;
+		netif_trans_update(dev);
 		dev_watchdog_up(dev);
 	}
 }
-- 
2.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
