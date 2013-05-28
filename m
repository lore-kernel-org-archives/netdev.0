From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/3] net: pass info struct via netdevice notifier
Date: Tue, 28 May 2013 10:10:53 +0200
Message-ID: <1369728655-26649-2-git-send-email-jiri@resnulli.us>
References: <1369728655-26649-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, timo.teras@iki.fi,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, bhutchings@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:47373 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933383Ab3E1ILD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 04:11:03 -0400
Received: by mail-wi0-f172.google.com with SMTP id m6so2213414wiv.11
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 01:11:02 -0700 (PDT)
In-Reply-To: <1369728655-26649-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So far, only net_device * could be passed along with netdevice notofier
event. This patch provides a possibility to pass custom structure
able to provide info that event listener needs to know.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 arch/ia64/hp/sim/simeth.c                          |  2 +-
 arch/mips/txx9/generic/setup_tx4939.c              |  3 +-
 drivers/infiniband/core/cma.c                      |  4 +-
 drivers/infiniband/hw/mlx4/main.c                  |  2 +-
 drivers/net/bonding/bond_main.c                    |  2 +-
 drivers/net/can/led.c                              |  4 +-
 drivers/net/ethernet/broadcom/cnic.c               |  2 +-
 drivers/net/ethernet/marvell/skge.c                |  2 +-
 drivers/net/ethernet/marvell/sky2.c                |  2 +-
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  2 +-
 drivers/net/ethernet/sfc/efx.c                     |  2 +-
 drivers/net/hamradio/bpqether.c                    |  7 +--
 drivers/net/macvlan.c                              |  2 +-
 drivers/net/macvtap.c                              |  2 +-
 drivers/net/netconsole.c                           |  5 +-
 drivers/net/ppp/pppoe.c                            |  2 +-
 drivers/net/team/team.c                            |  2 +-
 drivers/net/wan/dlci.c                             |  2 +-
 drivers/net/wan/hdlc.c                             |  2 +-
 drivers/net/wan/lapbether.c                        |  2 +-
 drivers/scsi/fcoe/fcoe.c                           |  2 +-
 drivers/scsi/fcoe/fcoe_transport.c                 |  2 +-
 drivers/staging/csr/netdev.c                       |  2 +-
 drivers/staging/ft1000/ft1000-pcmcia/ft1000_proc.c |  2 +-
 drivers/staging/ft1000/ft1000-usb/ft1000_proc.c    |  2 +-
 drivers/staging/silicom/bpctl_mod.c                |  2 +-
 include/linux/netdevice.h                          | 13 +++++
 net/8021q/vlan.c                                   |  2 +-
 net/appletalk/aarp.c                               |  2 +-
 net/appletalk/ddp.c                                |  2 +-
 net/atm/clip.c                                     |  4 +-
 net/atm/mpc.c                                      |  6 +--
 net/ax25/af_ax25.c                                 |  6 +--
 net/batman-adv/hard-interface.c                    |  2 +-
 net/bridge/br_notify.c                             |  2 +-
 net/caif/caif_dev.c                                |  4 +-
 net/caif/caif_usb.c                                |  4 +-
 net/can/af_can.c                                   |  4 +-
 net/can/bcm.c                                      |  4 +-
 net/can/gw.c                                       |  4 +-
 net/can/raw.c                                      |  4 +-
 net/core/dev.c                                     | 56 ++++++++++++++++++----
 net/core/drop_monitor.c                            |  4 +-
 net/core/dst.c                                     |  2 +-
 net/core/fib_rules.c                               |  4 +-
 net/core/netprio_cgroup.c                          |  2 +-
 net/core/pktgen.c                                  |  2 +-
 net/core/rtnetlink.c                               |  2 +-
 net/decnet/af_decnet.c                             |  4 +-
 net/ieee802154/6lowpan.c                           |  5 +-
 net/ipv4/arp.c                                     |  2 +-
 net/ipv4/devinet.c                                 |  2 +-
 net/ipv4/fib_frontend.c                            |  2 +-
 net/ipv4/ipmr.c                                    |  2 +-
 net/ipv4/netfilter/ipt_MASQUERADE.c                |  2 +-
 net/ipv6/addrconf.c                                |  4 +-
 net/ipv6/ip6mr.c                                   |  2 +-
 net/ipv6/ndisc.c                                   |  2 +-
 net/ipv6/netfilter/ip6t_MASQUERADE.c               |  2 +-
 net/ipv6/route.c                                   |  4 +-
 net/ipx/af_ipx.c                                   |  2 +-
 net/iucv/af_iucv.c                                 |  2 +-
 net/mac80211/iface.c                               |  5 +-
 net/netfilter/ipvs/ip_vs_ctl.c                     |  4 +-
 net/netfilter/nfnetlink_queue_core.c               |  2 +-
 net/netfilter/xt_TEE.c                             |  2 +-
 net/netlabel/netlabel_unlabeled.c                  |  7 ++-
 net/netrom/af_netrom.c                             |  2 +-
 net/openvswitch/dp_notify.c                        |  2 +-
 net/packet/af_packet.c                             |  5 +-
 net/phonet/pn_dev.c                                |  4 +-
 net/rose/af_rose.c                                 |  6 +--
 net/sched/act_mirred.c                             |  2 +-
 net/tipc/eth_media.c                               |  4 +-
 net/tipc/ib_media.c                                |  4 +-
 net/wireless/core.c                                |  5 +-
 net/x25/af_x25.c                                   |  2 +-
 net/xfrm/xfrm_policy.c                             |  2 +-
 security/selinux/netif.c                           |  2 +-
 80 files changed, 172 insertions(+), 127 deletions(-)

diff --git a/arch/ia64/hp/sim/simeth.c b/arch/ia64/hp/sim/simeth.c
index c13064e..28ef220 100644
--- a/arch/ia64/hp/sim/simeth.c
+++ b/arch/ia64/hp/sim/simeth.c
@@ -268,7 +268,7 @@ static __inline__ int dev_is_ethdev(struct net_device *dev)
 static int
 simeth_device_event(struct notifier_block *this,unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_nofifier_info_dev(ptr);
 	struct simeth_local *local;
 	struct in_device *in_dev;
 	struct in_ifaddr **ifap = NULL;
diff --git a/arch/mips/txx9/generic/setup_tx4939.c b/arch/mips/txx9/generic/setup_tx4939.c
index 729a509..ad77024 100644
--- a/arch/mips/txx9/generic/setup_tx4939.c
+++ b/arch/mips/txx9/generic/setup_tx4939.c
@@ -331,7 +331,8 @@ static int tx4939_netdev_event(struct notifier_block *this,
 			       unsigned long event,
 			       void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
+
 	if (event == NETDEV_CHANGE && netif_carrier_ok(dev)) {
 		__u64 bit = 0;
 		if (dev->irq == TXX9_IRQ_BASE + TX4939_IR_ETH(0))
diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 71c2c71..032195e7 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -3269,9 +3269,9 @@ static int cma_netdev_change(struct net_device *ndev, struct rdma_id_private *id
 }
 
 static int cma_netdev_callback(struct notifier_block *self, unsigned long event,
-			       void *ctx)
+			       void *ptr)
 {
-	struct net_device *ndev = (struct net_device *)ctx;
+	struct net_device *ndev = get_netdevice_notifier_info_dev(ptr);
 	struct cma_device *cma_dev;
 	struct rdma_id_private *id_priv;
 	int ret = NOTIFY_DONE;
diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 23d7343..9a913ea 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1161,7 +1161,7 @@ static void netdev_removed(struct mlx4_ib_dev *dev, int port)
 static int mlx4_ib_netdev_event(struct notifier_block *this, unsigned long event,
 				void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct mlx4_ib_dev *ibdev;
 	struct net_device *oldnd;
 	struct mlx4_ib_iboe *iboe;
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 29b846c..0239373 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3277,7 +3277,7 @@ static int bond_slave_netdev_event(unsigned long event,
 static int bond_netdev_event(struct notifier_block *this,
 			     unsigned long event, void *ptr)
 {
-	struct net_device *event_dev = (struct net_device *)ptr;
+	struct net_device *event_dev = get_netdevice_notifier_info_dev(ptr);
 
 	pr_debug("event_dev: %s, event: %lx\n",
 		 event_dev ? event_dev->name : "None",
diff --git a/drivers/net/can/led.c b/drivers/net/can/led.c
index f27fca6..d68ca06 100644
--- a/drivers/net/can/led.c
+++ b/drivers/net/can/led.c
@@ -88,9 +88,9 @@ EXPORT_SYMBOL_GPL(devm_can_led_init);
 
 /* NETDEV rename notifier to rename the associated led triggers too */
 static int can_led_notifier(struct notifier_block *nb, unsigned long msg,
-			void *data)
+			    void *ptr)
 {
-	struct net_device *netdev = data;
+	struct net_device *netdev = get_netdevice_notifier_info_dev(ptr);
 	struct can_priv *priv = safe_candev_priv(netdev);
 	char name[CAN_LED_NAME_SZ];
 
diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 6b0dc13..588d350 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -5622,7 +5622,7 @@ static void cnic_rcv_netevent(struct cnic_local *cp, unsigned long event,
 static int cnic_netdev_event(struct notifier_block *this, unsigned long event,
 							 void *ptr)
 {
-	struct net_device *netdev = ptr;
+	struct net_device *netdev = get_netdevice_notifier_info_dev(ptr);
 	struct cnic_dev *dev;
 	int new_dev = 0;
 
diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 171f4b3..a108f57 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -3706,7 +3706,7 @@ static const struct file_operations skge_debug_fops = {
 static int skge_device_event(struct notifier_block *unused,
 			     unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct skge_port *skge;
 	struct dentry *d;
 
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index d175bbd..e09e30f 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -4642,7 +4642,7 @@ static const struct file_operations sky2_debug_fops = {
 static int sky2_device_event(struct notifier_block *unused,
 			     unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct sky2_port *sky2 = netdev_priv(dev);
 
 	if (dev->netdev_ops->ndo_open != sky2_open || !sky2_debug)
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index af951f3..8cbdf74 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -3311,7 +3311,7 @@ static int netxen_netdev_event(struct notifier_block *this,
 				 unsigned long event, void *ptr)
 {
 	struct netxen_adapter *adapter;
-	struct net_device *dev = (struct net_device *)ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct net_device *orig_dev = dev;
 	struct net_device *slave;
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index da82f2e..5e2d106 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -3530,7 +3530,7 @@ static int qlcnic_netdev_event(struct notifier_block *this,
 				 unsigned long event, void *ptr)
 {
 	struct qlcnic_adapter *adapter;
-	struct net_device *dev = (struct net_device *)ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 
 recheck:
 	if (dev == NULL)
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 39e4cb3..da096583 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2120,7 +2120,7 @@ static void efx_update_name(struct efx_nic *efx)
 static int efx_netdev_event(struct notifier_block *this,
 			    unsigned long event, void *ptr)
 {
-	struct net_device *net_dev = ptr;
+	struct net_device *net_dev = get_netdevice_notifier_info_dev(ptr);
 
 	if (net_dev->netdev_ops == &efx_netdev_ops &&
 	    event == NETDEV_CHANGENAME)
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index 02de6c8..399fdbf 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -103,7 +103,7 @@ static struct packet_type bpq_packet_type __read_mostly = {
 };
 
 static struct notifier_block bpq_dev_notifier = {
-	.notifier_call =bpq_device_event,
+	.notifier_call = bpq_device_event,
 };
 
 
@@ -544,9 +544,10 @@ static void bpq_free_device(struct net_device *ndev)
 /*
  *	Handle device status changes.
  */
-static int bpq_device_event(struct notifier_block *this,unsigned long event, void *ptr)
+static int bpq_device_event(struct notifier_block *this,
+			    unsigned long event, void *ptr)
 {
-	struct net_device *dev = (struct net_device *)ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 
 	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 1c502bb..8c0eaa7 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -921,7 +921,7 @@ static struct rtnl_link_ops macvlan_link_ops = {
 static int macvlan_device_event(struct notifier_block *unused,
 				unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct macvlan_dev *vlan, *next;
 	struct macvlan_port *port;
 	LIST_HEAD(list_kill);
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 59e9605..3935ff2 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -1053,7 +1053,7 @@ EXPORT_SYMBOL_GPL(macvtap_get_socket);
 static int macvtap_device_event(struct notifier_block *unused,
 				unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct macvlan_dev *vlan;
 	struct device *classdev;
 	dev_t devt;
diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 59ac143..27d8e0b 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -653,12 +653,11 @@ static struct configfs_subsystem netconsole_subsys = {
 
 /* Handle network interface device notifications */
 static int netconsole_netdev_event(struct notifier_block *this,
-				   unsigned long event,
-				   void *ptr)
+				   unsigned long event, void *ptr)
 {
 	unsigned long flags;
 	struct netconsole_target *nt;
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	bool stopped = false;
 
 	if (!(event == NETDEV_CHANGENAME || event == NETDEV_UNREGISTER ||
diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index bb07ba9..61fc134 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -338,7 +338,7 @@ static void pppoe_flush_dev(struct net_device *dev)
 static int pppoe_device_event(struct notifier_block *this,
 			      unsigned long event, void *ptr)
 {
-	struct net_device *dev = (struct net_device *)ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 
 	/* Only look at sockets that are using this specific device. */
 	switch (event) {
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 7c43261..174af14 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2647,7 +2647,7 @@ static void team_port_change_check(struct team_port *port, bool linkup)
 static int team_device_event(struct notifier_block *unused,
 			     unsigned long event, void *ptr)
 {
-	struct net_device *dev = (struct net_device *) ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct team_port *port;
 
 	port = team_port_get_rtnl(dev);
diff --git a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
index 147614e..d446aa7 100644
--- a/drivers/net/wan/dlci.c
+++ b/drivers/net/wan/dlci.c
@@ -477,7 +477,7 @@ static void dlci_setup(struct net_device *dev)
 static int dlci_dev_event(struct notifier_block *unused,
 			  unsigned long event, void *ptr)
 {
-	struct net_device *dev = (struct net_device *) ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 
 	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
diff --git a/drivers/net/wan/hdlc.c b/drivers/net/wan/hdlc.c
index a0a932c..73e816d 100644
--- a/drivers/net/wan/hdlc.c
+++ b/drivers/net/wan/hdlc.c
@@ -99,7 +99,7 @@ static inline void hdlc_proto_stop(struct net_device *dev)
 static int hdlc_device_event(struct notifier_block *this, unsigned long event,
 			     void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	hdlc_device *hdlc;
 	unsigned long flags;
 	int on;
diff --git a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
index a73b49e..f69899e 100644
--- a/drivers/net/wan/lapbether.c
+++ b/drivers/net/wan/lapbether.c
@@ -370,7 +370,7 @@ static int lapbeth_device_event(struct notifier_block *this,
 				unsigned long event, void *ptr)
 {
 	struct lapbethdev *lapbeth;
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 
 	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index 292b24f..b97522e 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -1975,7 +1975,7 @@ static int fcoe_device_notification(struct notifier_block *notifier,
 {
 	struct fcoe_ctlr_device *cdev;
 	struct fc_lport *lport = NULL;
-	struct net_device *netdev = ptr;
+	struct net_device *netdev = get_netdevice_notifier_info_dev(ptr);
 	struct fcoe_ctlr *ctlr;
 	struct fcoe_interface *fcoe;
 	struct fcoe_port *port;
diff --git a/drivers/scsi/fcoe/fcoe_transport.c b/drivers/scsi/fcoe/fcoe_transport.c
index f3a5a53..4ad5ab2 100644
--- a/drivers/scsi/fcoe/fcoe_transport.c
+++ b/drivers/scsi/fcoe/fcoe_transport.c
@@ -704,7 +704,7 @@ static struct net_device *fcoe_if_to_netdev(const char *buffer)
 static int libfcoe_device_notification(struct notifier_block *notifier,
 				    ulong event, void *ptr)
 {
-	struct net_device *netdev = ptr;
+	struct net_device *netdev = get_netdevice_notifier_info_dev(ptr);
 
 	switch (event) {
 	case NETDEV_UNREGISTER:
diff --git a/drivers/staging/csr/netdev.c b/drivers/staging/csr/netdev.c
index a0177d9..5fd3716 100644
--- a/drivers/staging/csr/netdev.c
+++ b/drivers/staging/csr/netdev.c
@@ -2891,7 +2891,7 @@ void uf_net_get_name(struct net_device *dev, char *name, int len)
  */
 static int
 uf_netdev_event(struct notifier_block *notif, unsigned long event, void* ptr) {
-    struct net_device *netdev = ptr;
+    struct net_device *netdev = get_netdevice_notifier_info_dev(ptr);
     netInterface_priv_t *interfacePriv = (netInterface_priv_t *)netdev_priv(netdev);
     unifi_priv_t *priv = NULL;
     static const CsrWifiMacAddress broadcast_address = {{0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF}};
diff --git a/drivers/staging/ft1000/ft1000-pcmcia/ft1000_proc.c b/drivers/staging/ft1000/ft1000-pcmcia/ft1000_proc.c
index 94e426e..9b1885e 100644
--- a/drivers/staging/ft1000/ft1000-pcmcia/ft1000_proc.c
+++ b/drivers/staging/ft1000/ft1000-pcmcia/ft1000_proc.c
@@ -164,7 +164,7 @@ static const struct file_operations ft1000_proc_fops = {
 static int ft1000NotifyProc(struct notifier_block *this, unsigned long event,
 				void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct ft1000_info *info;
 
 	info = netdev_priv(dev);
diff --git a/drivers/staging/ft1000/ft1000-usb/ft1000_proc.c b/drivers/staging/ft1000/ft1000-usb/ft1000_proc.c
index eca6f02..67a96c9 100644
--- a/drivers/staging/ft1000/ft1000-usb/ft1000_proc.c
+++ b/drivers/staging/ft1000/ft1000-usb/ft1000_proc.c
@@ -166,7 +166,7 @@ static const struct file_operations ft1000_proc_fops = {
 static int
 ft1000NotifyProc(struct notifier_block *this, unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct ft1000_info *info;
 	struct proc_dir_entry *ft1000_proc_file;
 
diff --git a/drivers/staging/silicom/bpctl_mod.c b/drivers/staging/silicom/bpctl_mod.c
index b7e570c..6b32843 100644
--- a/drivers/staging/silicom/bpctl_mod.c
+++ b/drivers/staging/silicom/bpctl_mod.c
@@ -133,7 +133,7 @@ static unsigned long str_to_hex(char *p);
 static int bp_device_event(struct notifier_block *unused,
 			   unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	static bpctl_dev_t *pbpctl_dev = NULL, *pbpctl_dev_m = NULL;
 	int dev_num = 0, ret = 0, ret_d = 0, time_left = 0;
 	/* printk("BP_PROC_SUPPORT event =%d %s %d\n", event,dev->name, dev->ifindex ); */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ea7b6bc..153127b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1597,6 +1597,19 @@ struct packet_offload {
 
 extern int register_netdevice_notifier(struct notifier_block *nb);
 extern int unregister_netdevice_notifier(struct notifier_block *nb);
+
+struct netdevice_notifier_info {
+	struct net_device *dev;
+};
+
+static inline struct net_device *
+get_netdevice_notifier_info_dev(const struct netdevice_notifier_info *info)
+{
+	return info->dev;
+}
+
+extern int call_netdevice_notifiers_info(unsigned long val, struct net_device *dev,
+					 struct netdevice_notifier_info *info);
 extern int call_netdevice_notifiers(unsigned long val, struct net_device *dev);
 
 
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 9424f37..d91b157 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -341,7 +341,7 @@ static void __vlan_device_event(struct net_device *dev, unsigned long event)
 static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 			     void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct vlan_group *grp;
 	struct vlan_info *vlan_info;
 	int i, flgs;
diff --git a/net/appletalk/aarp.c b/net/appletalk/aarp.c
index 173a2e8..e061dd2 100644
--- a/net/appletalk/aarp.c
+++ b/net/appletalk/aarp.c
@@ -332,7 +332,7 @@ static void aarp_expire_timeout(unsigned long unused)
 static int aarp_device_event(struct notifier_block *this, unsigned long event,
 			     void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	int ct;
 
 	if (!net_eq(dev_net(dev), &init_net))
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index ef12839..fd6ac4c 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -644,7 +644,7 @@ static inline void atalk_dev_down(struct net_device *dev)
 static int ddp_device_event(struct notifier_block *this, unsigned long event,
 			    void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 
 	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 8ae3a78..d9be162 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -539,9 +539,9 @@ static int clip_create(int number)
 }
 
 static int clip_device_event(struct notifier_block *this, unsigned long event,
-			     void *arg)
+			     void *ptr)
 {
-	struct net_device *dev = arg;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 
 	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index d4cc1be..153b8ac 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -998,14 +998,12 @@ int msg_to_mpoad(struct k_message *mesg, struct mpoa_client *mpc)
 }
 
 static int mpoa_event_listener(struct notifier_block *mpoa_notifier,
-			       unsigned long event, void *dev_ptr)
+			       unsigned long event, void *ptr)
 {
-	struct net_device *dev;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct mpoa_client *mpc;
 	struct lec_priv *priv;
 
-	dev = dev_ptr;
-
 	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index e277e38..fb6d888 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -111,9 +111,9 @@ again:
  *	Handle device status changes.
  */
 static int ax25_device_event(struct notifier_block *this, unsigned long event,
-	void *ptr)
+			     void *ptr)
 {
-	struct net_device *dev = (struct net_device *)ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 
 	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
@@ -1974,7 +1974,7 @@ static struct packet_type ax25_packet_type __read_mostly = {
 };
 
 static struct notifier_block ax25_dev_notifier = {
-	.notifier_call =ax25_device_event,
+	.notifier_call = ax25_device_event,
 };
 
 static int __init ax25_init(void)
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 522243a..339cd2e 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -595,7 +595,7 @@ void batadv_hardif_remove_interfaces(void)
 static int batadv_hard_if_event(struct notifier_block *this,
 				unsigned long event, void *ptr)
 {
-	struct net_device *net_dev = ptr;
+	struct net_device *net_dev = get_netdevice_notifier_info_dev(ptr);
 	struct batadv_hard_iface *hard_iface;
 	struct batadv_hard_iface *primary_if = NULL;
 	struct batadv_priv *bat_priv;
diff --git a/net/bridge/br_notify.c b/net/bridge/br_notify.c
index 1644b3e..a413913 100644
--- a/net/bridge/br_notify.c
+++ b/net/bridge/br_notify.c
@@ -31,7 +31,7 @@ struct notifier_block br_device_notifier = {
  */
 static int br_device_event(struct notifier_block *unused, unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct net_bridge_port *p;
 	struct net_bridge *br;
 	bool changed_addr;
diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 1f9ece1..b5fdeef 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -352,9 +352,9 @@ EXPORT_SYMBOL(caif_enroll_dev);
 
 /* notify Caif of device events */
 static int caif_device_notify(struct notifier_block *me, unsigned long what,
-			      void *arg)
+			      void *ptr)
 {
-	struct net_device *dev = arg;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct caif_device_entry *caifd = NULL;
 	struct caif_dev_common *caifdev;
 	struct cfcnfg *cfg;
diff --git a/net/caif/caif_usb.c b/net/caif/caif_usb.c
index 942e00a..9e2019b 100644
--- a/net/caif/caif_usb.c
+++ b/net/caif/caif_usb.c
@@ -121,9 +121,9 @@ static struct packet_type caif_usb_type __read_mostly = {
 };
 
 static int cfusbl_device_notify(struct notifier_block *me, unsigned long what,
-				void *arg)
+				void *ptr)
 {
-	struct net_device *dev = arg;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct caif_dev_common common;
 	struct cflayer *layer, *link_support;
 	struct usbnet *usbnet;
diff --git a/net/can/af_can.c b/net/can/af_can.c
index c4e5085..5f28de6 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -794,9 +794,9 @@ EXPORT_SYMBOL(can_proto_unregister);
  * af_can notifier to create/remove CAN netdevice specific structs
  */
 static int can_notifier(struct notifier_block *nb, unsigned long msg,
-			void *data)
+			void *ptr)
 {
-	struct net_device *dev = (struct net_device *)data;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct dev_rcv_lists *d;
 
 	if (!net_eq(dev_net(dev), &init_net))
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 8f113e6..5b4d2dc 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1350,9 +1350,9 @@ static int bcm_sendmsg(struct kiocb *iocb, struct socket *sock,
  * notification handler for netdevice status changes
  */
 static int bcm_notifier(struct notifier_block *nb, unsigned long msg,
-			void *data)
+			void *ptr)
 {
-	struct net_device *dev = (struct net_device *)data;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct bcm_sock *bo = container_of(nb, struct bcm_sock, notifier);
 	struct sock *sk = &bo->sk;
 	struct bcm_op *op;
diff --git a/net/can/gw.c b/net/can/gw.c
index 3ee690e..554c638 100644
--- a/net/can/gw.c
+++ b/net/can/gw.c
@@ -445,9 +445,9 @@ static inline void cgw_unregister_filter(struct cgw_job *gwj)
 }
 
 static int cgw_notifier(struct notifier_block *nb,
-			unsigned long msg, void *data)
+			unsigned long msg, void *ptr)
 {
-	struct net_device *dev = (struct net_device *)data;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 
 	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
diff --git a/net/can/raw.c b/net/can/raw.c
index 1085e65..bef83fd 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -239,9 +239,9 @@ static int raw_enable_allfilters(struct net_device *dev, struct sock *sk)
 }
 
 static int raw_notifier(struct notifier_block *nb,
-			unsigned long msg, void *data)
+			unsigned long msg, void *ptr)
 {
-	struct net_device *dev = (struct net_device *)data;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct raw_sock *ro = container_of(nb, struct raw_sock, notifier);
 	struct sock *sk = &ro->sk;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 50c02de..9a891e0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1398,6 +1398,20 @@ void dev_disable_lro(struct net_device *dev)
 }
 EXPORT_SYMBOL(dev_disable_lro);
 
+static void init_netdevice_notifier_info(struct netdevice_notifier_info *info,
+					 struct net_device *dev)
+{
+	info->dev = dev;
+}
+
+static int call_netdevice_notifier(struct notifier_block *nb, unsigned long val,
+				   struct net_device *dev)
+{
+	struct netdevice_notifier_info info;
+
+	init_netdevice_notifier_info(&info, dev);
+	return nb->notifier_call(nb, NETDEV_REGISTER, &info);
+}
 
 static int dev_boot_phase = 1;
 
@@ -1430,7 +1444,7 @@ int register_netdevice_notifier(struct notifier_block *nb)
 		goto unlock;
 	for_each_net(net) {
 		for_each_netdev(net, dev) {
-			err = nb->notifier_call(nb, NETDEV_REGISTER, dev);
+			err = call_netdevice_notifier(nb, NETDEV_REGISTER, dev);
 			err = notifier_to_errno(err);
 			if (err)
 				goto rollback;
@@ -1438,7 +1452,7 @@ int register_netdevice_notifier(struct notifier_block *nb)
 			if (!(dev->flags & IFF_UP))
 				continue;
 
-			nb->notifier_call(nb, NETDEV_UP, dev);
+			call_netdevice_notifier(nb, NETDEV_UP, dev);
 		}
 	}
 
@@ -1454,10 +1468,11 @@ rollback:
 				goto outroll;
 
 			if (dev->flags & IFF_UP) {
-				nb->notifier_call(nb, NETDEV_GOING_DOWN, dev);
-				nb->notifier_call(nb, NETDEV_DOWN, dev);
+				call_netdevice_notifier(nb, NETDEV_GOING_DOWN,
+							dev);
+				call_netdevice_notifier(nb, NETDEV_DOWN, dev);
 			}
-			nb->notifier_call(nb, NETDEV_UNREGISTER, dev);
+			call_netdevice_notifier(nb, NETDEV_UNREGISTER, dev);
 		}
 	}
 
@@ -1495,10 +1510,11 @@ int unregister_netdevice_notifier(struct notifier_block *nb)
 	for_each_net(net) {
 		for_each_netdev(net, dev) {
 			if (dev->flags & IFF_UP) {
-				nb->notifier_call(nb, NETDEV_GOING_DOWN, dev);
-				nb->notifier_call(nb, NETDEV_DOWN, dev);
+				call_netdevice_notifier(nb, NETDEV_GOING_DOWN,
+							dev);
+				call_netdevice_notifier(nb, NETDEV_DOWN, dev);
 			}
-			nb->notifier_call(nb, NETDEV_UNREGISTER, dev);
+			call_netdevice_notifier(nb, NETDEV_UNREGISTER, dev);
 		}
 	}
 unlock:
@@ -1508,6 +1524,25 @@ unlock:
 EXPORT_SYMBOL(unregister_netdevice_notifier);
 
 /**
+ *	call_netdevice_notifiers_info - call all network notifier blocks
+ *	@val: value passed unmodified to notifier function
+ *	@dev: net_device pointer passed unmodified to notifier function
+ *	@info: notifier information data
+ *
+ *	Call all network notifier blocks.  Parameters and return value
+ *	are as for raw_notifier_call_chain().
+ */
+
+int call_netdevice_notifiers_info(unsigned long val, struct net_device *dev,
+				  struct netdevice_notifier_info *info)
+{
+	ASSERT_RTNL();
+	init_netdevice_notifier_info(info, dev);
+	return raw_notifier_call_chain(&netdev_chain, val, info);
+}
+EXPORT_SYMBOL(call_netdevice_notifiers_info);
+
+/**
  *	call_netdevice_notifiers - call all network notifier blocks
  *      @val: value passed unmodified to notifier function
  *      @dev: net_device pointer passed unmodified to notifier function
@@ -1518,8 +1553,9 @@ EXPORT_SYMBOL(unregister_netdevice_notifier);
 
 int call_netdevice_notifiers(unsigned long val, struct net_device *dev)
 {
-	ASSERT_RTNL();
-	return raw_notifier_call_chain(&netdev_chain, val, dev);
+	struct netdevice_notifier_info info;
+
+	return call_netdevice_notifiers_info(val, dev, &info);
 }
 EXPORT_SYMBOL(call_netdevice_notifiers);
 
diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index d23b668..5baf777 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -295,9 +295,9 @@ static int net_dm_cmd_trace(struct sk_buff *skb,
 }
 
 static int dropmon_net_event(struct notifier_block *ev_block,
-			unsigned long event, void *ptr)
+			     unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct dm_hw_stat_delta *new_stat = NULL;
 	struct dm_hw_stat_delta *tmp;
 
diff --git a/net/core/dst.c b/net/core/dst.c
index df9cc81..a142836 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -372,7 +372,7 @@ static void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 static int dst_dev_event(struct notifier_block *this, unsigned long event,
 			 void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct dst_entry *dst, *last = NULL;
 
 	switch (event) {
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index d5a9f8e..0ff0920 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -705,9 +705,9 @@ static void detach_rules(struct list_head *rules, struct net_device *dev)
 
 
 static int fib_rules_event(struct notifier_block *this, unsigned long event,
-			    void *ptr)
+			   void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct net *net = dev_net(dev);
 	struct fib_rules_ops *ops;
 
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 0777d0a..6e53f7f 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -261,7 +261,7 @@ struct cgroup_subsys net_prio_subsys = {
 static int netprio_device_event(struct notifier_block *unused,
 				unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct netprio_map *old;
 
 	/*
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 11f2704..20370f4 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1921,7 +1921,7 @@ static void pktgen_change_name(const struct pktgen_net *pn, struct net_device *d
 static int pktgen_device_event(struct notifier_block *unused,
 			       unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct pktgen_net *pn = net_generic(dev_net(dev), pg_net_id);
 
 	if (pn->pktgen_exiting)
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a08bd2b..68fd32d 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2667,7 +2667,7 @@ static void rtnetlink_rcv(struct sk_buff *skb)
 
 static int rtnetlink_event(struct notifier_block *this, unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 
 	switch (event) {
 	case NETDEV_UP:
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index c21f200..2b12317 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -2078,9 +2078,9 @@ out_err:
 }
 
 static int dn_device_event(struct notifier_block *this, unsigned long event,
-			void *ptr)
+			   void *ptr)
 {
-	struct net_device *dev = (struct net_device *)ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 
 	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 55e1fd5..b2dd7ed 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -1352,10 +1352,9 @@ static inline void lowpan_netlink_fini(void)
 }
 
 static int lowpan_device_event(struct notifier_block *unused,
-				unsigned long event,
-				void *ptr)
+			       unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	LIST_HEAD(del_list);
 	struct lowpan_dev_record *entry, *tmp;
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 247ec19..b455213 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1234,7 +1234,7 @@ out:
 static int arp_netdev_event(struct notifier_block *this, unsigned long event,
 			    void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 
 	switch (event) {
 	case NETDEV_CHANGEADDR:
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index dfc39d4..e51c2cd 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1333,7 +1333,7 @@ static void inetdev_send_gratuitous_arp(struct net_device *dev,
 static int inetdev_event(struct notifier_block *this, unsigned long event,
 			 void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct in_device *in_dev = __in_dev_get_rtnl(dev);
 
 	ASSERT_RTNL();
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index c7629a2..6b61449 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1038,7 +1038,7 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
 
 static int fib_netdev_event(struct notifier_block *this, unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct in_device *in_dev;
 	struct net *net = dev_net(dev);
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 9d9610a..702194e 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1609,7 +1609,7 @@ int ipmr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
 
 static int ipmr_device_event(struct notifier_block *this, unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct net *net = dev_net(dev);
 	struct mr_table *mrt;
 	struct vif_device *v;
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index 5d5d4d1..165b91c 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -108,7 +108,7 @@ static int masq_device_event(struct notifier_block *this,
 			     unsigned long event,
 			     void *ptr)
 {
-	const struct net_device *dev = ptr;
+	const struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct net *net = dev_net(dev);
 
 	if (event == NETDEV_DOWN) {
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 432e084..da7301a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2826,9 +2826,9 @@ static void addrconf_ip6_tnl_config(struct net_device *dev)
 }
 
 static int addrconf_notify(struct notifier_block *this, unsigned long event,
-			   void *data)
+			   void *ptr)
 {
-	struct net_device *dev = (struct net_device *) data;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct inet6_dev *idev = __in6_dev_get(dev);
 	int run_pending = 0;
 	int err;
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 241fb8a..411c466 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1319,7 +1319,7 @@ static int ip6mr_mfc_delete(struct mr6_table *mrt, struct mf6cctl *mfc,
 static int ip6mr_device_event(struct notifier_block *this,
 			      unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct net *net = dev_net(dev);
 	struct mr6_table *mrt;
 	struct mif_device *v;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 2712ab2..ba3772e 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1568,7 +1568,7 @@ int ndisc_rcv(struct sk_buff *skb)
 
 static int ndisc_netdev_event(struct notifier_block *this, unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct net *net = dev_net(dev);
 	struct inet6_dev *idev;
 
diff --git a/net/ipv6/netfilter/ip6t_MASQUERADE.c b/net/ipv6/netfilter/ip6t_MASQUERADE.c
index 60e9053..beccff5 100644
--- a/net/ipv6/netfilter/ip6t_MASQUERADE.c
+++ b/net/ipv6/netfilter/ip6t_MASQUERADE.c
@@ -71,7 +71,7 @@ static int device_cmp(struct nf_conn *ct, void *ifindex)
 static int masq_device_event(struct notifier_block *this,
 			     unsigned long event, void *ptr)
 {
-	const struct net_device *dev = ptr;
+	const struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct net *net = dev_net(dev);
 
 	if (event == NETDEV_DOWN)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ad0aa6b..93a8b37 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2681,9 +2681,9 @@ errout:
 }
 
 static int ip6_route_dev_notify(struct notifier_block *this,
-				unsigned long event, void *data)
+				unsigned long event, void *ptr)
 {
-	struct net_device *dev = (struct net_device *)data;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct net *net = dev_net(dev);
 
 	if (event == NETDEV_REGISTER && (dev->flags & IFF_LOOPBACK)) {
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index f547a47..8222f29 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -330,7 +330,7 @@ static __inline__ void __ipxitf_put(struct ipx_interface *intrfc)
 static int ipxitf_device_event(struct notifier_block *notifier,
 				unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct ipx_interface *i, *tmp;
 
 	if (!net_eq(dev_net(dev), &init_net))
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index ae69165..08d7519 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -2293,7 +2293,7 @@ out_unlock:
 static int afiucv_netdev_event(struct notifier_block *this,
 			       unsigned long event, void *ptr)
 {
-	struct net_device *event_dev = (struct net_device *)ptr;
+	struct net_device *event_dev = get_netdevice_notifier_info_dev(ptr);
 	struct sock *sk;
 	struct iucv_sock *iucv;
 
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 60f1ce5..db10c00 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1717,10 +1717,9 @@ void ieee80211_remove_interfaces(struct ieee80211_local *local)
 }
 
 static int netdev_notify(struct notifier_block *nb,
-			 unsigned long state,
-			 void *ndev)
+			 unsigned long state, void *ptr)
 {
-	struct net_device *dev = ndev;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct ieee80211_sub_if_data *sdata;
 
 	if (state != NETDEV_CHANGENAME)
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 5b142fb..044139c 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1487,9 +1487,9 @@ ip_vs_forget_dev(struct ip_vs_dest *dest, struct net_device *dev)
  * Currently only NETDEV_DOWN is handled to release refs to cached dsts
  */
 static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
-			    void *ptr)
+			   void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct net *net = dev_net(dev);
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_service *svc;
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 4e27fa0..2a7e7ae 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -800,7 +800,7 @@ static int
 nfqnl_rcv_dev_event(struct notifier_block *this,
 		    unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 
 	/* Drop any packets associated with the downed device */
 	if (event == NETDEV_DOWN)
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index bd93e51..0a31ae7 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -200,7 +200,7 @@ tee_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 static int tee_netdev_event(struct notifier_block *this, unsigned long event,
 			    void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct xt_tee_priv *priv;
 
 	priv = container_of(this, struct xt_tee_priv, notifier);
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 8a6c6ea..a5802d8 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -708,7 +708,7 @@ unlhsh_remove_return:
  * netlbl_unlhsh_netdev_handler - Network device notification handler
  * @this: notifier block
  * @event: the event
- * @ptr: the network device (cast to void)
+ * @ptr: the netdevice notifier info (cast to void)
  *
  * Description:
  * Handle network device events, although at present all we care about is a
@@ -717,10 +717,9 @@ unlhsh_remove_return:
  *
  */
 static int netlbl_unlhsh_netdev_handler(struct notifier_block *this,
-					unsigned long event,
-					void *ptr)
+					unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct netlbl_unlhsh_iface *iface = NULL;
 
 	if (!net_eq(dev_net(dev), &init_net))
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index ec0c80f..35035ff 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -117,7 +117,7 @@ static void nr_kill_by_device(struct net_device *dev)
  */
 static int nr_device_event(struct notifier_block *this, unsigned long event, void *ptr)
 {
-	struct net_device *dev = (struct net_device *)ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 
 	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
diff --git a/net/openvswitch/dp_notify.c b/net/openvswitch/dp_notify.c
index ef4feec..bf316fc 100644
--- a/net/openvswitch/dp_notify.c
+++ b/net/openvswitch/dp_notify.c
@@ -78,7 +78,7 @@ static int dp_device_event(struct notifier_block *unused, unsigned long event,
 			   void *ptr)
 {
 	struct ovs_net *ovs_net;
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct vport *vport = NULL;
 
 	if (!ovs_is_internal_dev(dev))
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 8ec1bca..7cad470 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3331,10 +3331,11 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 }
 
 
-static int packet_notifier(struct notifier_block *this, unsigned long msg, void *data)
+static int packet_notifier(struct notifier_block *this,
+			   unsigned long msg, void *ptr)
 {
 	struct sock *sk;
-	struct net_device *dev = data;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct net *net = dev_net(dev);
 
 	rcu_read_lock();
diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 45a7df6..5a7efc5 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -292,9 +292,9 @@ static void phonet_route_autodel(struct net_device *dev)
 
 /* notify Phonet of device events */
 static int phonet_device_notify(struct notifier_block *me, unsigned long what,
-				void *arg)
+				void *ptr)
 {
-	struct net_device *dev = arg;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 
 	switch (what) {
 	case NETDEV_REGISTER:
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 9c83474..433b103 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -202,10 +202,10 @@ static void rose_kill_by_device(struct net_device *dev)
 /*
  *	Handle device status changes.
  */
-static int rose_device_event(struct notifier_block *this, unsigned long event,
-	void *ptr)
+static int rose_device_event(struct notifier_block *this,
+			     unsigned long event, void *ptr)
 {
-	struct net_device *dev = (struct net_device *)ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 
 	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 5d676ed..80ac61f 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -243,7 +243,7 @@ nla_put_failure:
 static int mirred_device_event(struct notifier_block *unused,
 			       unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct tcf_mirred *m;
 
 	if (event == NETDEV_UNREGISTER)
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 120a676..1f44056 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -251,9 +251,9 @@ static void disable_bearer(struct tipc_bearer *tb_ptr)
  * specified device.
  */
 static int recv_notification(struct notifier_block *nb, unsigned long evt,
-			     void *dv)
+			     void *ptr)
 {
-	struct net_device *dev = (struct net_device *)dv;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct eth_bearer *eb_ptr = &eth_bearers[0];
 	struct eth_bearer *stop = &eth_bearers[MAX_ETH_BEARERS];
 
diff --git a/net/tipc/ib_media.c b/net/tipc/ib_media.c
index 2a2864c..52b4558 100644
--- a/net/tipc/ib_media.c
+++ b/net/tipc/ib_media.c
@@ -244,9 +244,9 @@ static void disable_bearer(struct tipc_bearer *tb_ptr)
  * specified device.
  */
 static int recv_notification(struct notifier_block *nb, unsigned long evt,
-			     void *dv)
+			     void *ptr)
 {
-	struct net_device *dev = (struct net_device *)dv;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct ib_bearer *ib_ptr = &ib_bearers[0];
 	struct ib_bearer *stop = &ib_bearers[MAX_IB_BEARERS];
 
diff --git a/net/wireless/core.c b/net/wireless/core.c
index 73405e0..4b55a06 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -886,10 +886,9 @@ void cfg80211_leave(struct cfg80211_registered_device *rdev,
 }
 
 static int cfg80211_netdev_notifier_call(struct notifier_block *nb,
-					 unsigned long state,
-					 void *ndev)
+					 unsigned long state, void *ptr)
 {
-	struct net_device *dev = ndev;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct wireless_dev *wdev = dev->ieee80211_ptr;
 	struct cfg80211_registered_device *rdev;
 	int ret;
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 37ca969..1a06a87 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -224,7 +224,7 @@ static void x25_kill_by_device(struct net_device *dev)
 static int x25_device_event(struct notifier_block *this, unsigned long event,
 			    void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 	struct x25_neigh *nb;
 
 	if (!net_eq(dev_net(dev), &init_net))
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 23cea0f..c3a9450 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2784,7 +2784,7 @@ static void __net_init xfrm_dst_ops_init(struct net *net)
 
 static int xfrm_dev_event(struct notifier_block *this, unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 
 	switch (event) {
 	case NETDEV_DOWN:
diff --git a/security/selinux/netif.c b/security/selinux/netif.c
index 47a49d1..8ca0d9b 100644
--- a/security/selinux/netif.c
+++ b/security/selinux/netif.c
@@ -264,7 +264,7 @@ static int sel_netif_avc_callback(u32 event)
 static int sel_netif_netdev_notifier_handler(struct notifier_block *this,
 					     unsigned long event, void *ptr)
 {
-	struct net_device *dev = ptr;
+	struct net_device *dev = get_netdevice_notifier_info_dev(ptr);
 
 	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
-- 
1.7.11.7
