From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 1/5] [NET] NETNS: Omit net_device->nd_net without
 CONFIG_NET_NS.
Date: Wed, 26 Mar 2008 08:40:46 +0900 (JST)
Message-ID: <20080326.084046.78674847.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, dlezcano@fr.ibm.com, brian.haley@hp.com,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55033 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757569AbYCYXjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 19:39:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce per-net_device inlines: dev_net(), dev_net_set().
Without CONFIG_NET_NS, no namespace other than &init_net exists.
Let's explicitly define them to help compiler optimizations.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 arch/ia64/hp/sim/simeth.c           |    2 +-
 drivers/block/aoe/aoenet.c          |    2 +-
 drivers/net/bonding/bond_3ad.c      |    2 +-
 drivers/net/bonding/bond_alb.c      |    2 +-
 drivers/net/bonding/bond_main.c     |    6 ++--
 drivers/net/hamradio/bpqether.c     |    4 +-
 drivers/net/loopback.c              |    2 +-
 drivers/net/macvlan.c               |    2 +-
 drivers/net/pppoe.c                 |    6 ++--
 drivers/net/veth.c                  |    2 +-
 drivers/net/via-velocity.c          |    2 +-
 drivers/net/wan/dlci.c              |    2 +-
 drivers/net/wan/hdlc.c              |    4 +-
 drivers/net/wan/lapbether.c         |    4 +-
 drivers/net/wan/syncppp.c           |    2 +-
 drivers/s390/net/qeth_l3_main.c     |    2 +-
 include/linux/inetdevice.h          |    6 ++--
 include/linux/netdevice.h           |   25 +++++++++++++++++++-
 net/8021q/vlan.c                    |    2 +-
 net/8021q/vlan_dev.c                |    2 +-
 net/appletalk/aarp.c                |    4 +-
 net/appletalk/ddp.c                 |    6 ++--
 net/atm/clip.c                      |    2 +-
 net/atm/mpc.c                       |    2 +-
 net/ax25/af_ax25.c                  |    2 +-
 net/ax25/ax25_in.c                  |    2 +-
 net/bridge/br_notify.c              |    2 +-
 net/bridge/br_stp_bpdu.c            |    2 +-
 net/can/af_can.c                    |    4 +-
 net/can/bcm.c                       |    2 +-
 net/can/raw.c                       |    2 +-
 net/core/dev.c                      |   22 ++++++++--------
 net/core/dst.c                      |    2 +-
 net/core/fib_rules.c                |    2 +-
 net/core/neighbour.c                |   12 ++++----
 net/core/pktgen.c                   |    2 +-
 net/core/rtnetlink.c                |    4 +-
 net/decnet/af_decnet.c              |    2 +-
 net/decnet/dn_route.c               |    2 +-
 net/econet/af_econet.c              |    4 +-
 net/ipv4/arp.c                      |   14 +++++-----
 net/ipv4/devinet.c                  |   10 ++++----
 net/ipv4/fib_frontend.c             |   12 ++++----
 net/ipv4/icmp.c                     |    8 +++---
 net/ipv4/igmp.c                     |   16 ++++++------
 net/ipv4/ip_fragment.c              |    2 +-
 net/ipv4/ip_gre.c                   |    2 +-
 net/ipv4/ip_input.c                 |    6 ++--
 net/ipv4/ip_options.c               |    2 +-
 net/ipv4/ipconfig.c                 |    4 +-
 net/ipv4/ipmr.c                     |    2 +-
 net/ipv4/netfilter/ip_queue.c       |    2 +-
 net/ipv4/netfilter/ipt_MASQUERADE.c |    2 +-
 net/ipv4/raw.c                      |    4 +-
 net/ipv4/route.c                    |   28 +++++++++++-----------
 net/ipv4/tcp_ipv4.c                 |    6 ++--
 net/ipv4/udp.c                      |    4 +-
 net/ipv4/xfrm4_policy.c             |    2 +-
 net/ipv6/addrconf.c                 |   44 +++++++++++++++++-----------------
 net/ipv6/icmp.c                     |    4 +-
 net/ipv6/ip6_output.c               |    2 +-
 net/ipv6/mcast.c                    |    6 ++--
 net/ipv6/ndisc.c                    |   24 +++++++++---------
 net/ipv6/netfilter/ip6_queue.c      |    2 +-
 net/ipv6/proc.c                     |    2 +-
 net/ipv6/raw.c                      |    4 +-
 net/ipv6/reassembly.c               |    2 +-
 net/ipv6/route.c                    |   40 ++++++++++++++++----------------
 net/ipv6/tcp_ipv6.c                 |   10 ++++----
 net/ipv6/udp.c                      |    4 +-
 net/ipv6/xfrm6_policy.c             |    2 +-
 net/ipx/af_ipx.c                    |    4 +-
 net/irda/irlap_frame.c              |    2 +-
 net/llc/llc_input.c                 |    2 +-
 net/netfilter/core.c                |    2 +-
 net/netfilter/nfnetlink_queue.c     |    2 +-
 net/netlabel/netlabel_unlabeled.c   |    2 +-
 net/netrom/af_netrom.c              |    2 +-
 net/packet/af_packet.c              |    8 +++---
 net/rose/af_rose.c                  |    2 +-
 net/sctp/protocol.c                 |    2 +-
 net/tipc/eth_media.c                |    4 +-
 net/wireless/wext.c                 |    2 +-
 net/x25/af_x25.c                    |    2 +-
 net/x25/x25_dev.c                   |    2 +-
 net/xfrm/xfrm_policy.c              |    4 +-
 security/selinux/netif.c            |    2 +-
 87 files changed, 251 insertions(+), 228 deletions(-)

diff --git a/arch/ia64/hp/sim/simeth.c b/arch/ia64/hp/sim/simeth.c
index 969fe9f..3d47839 100644
--- a/arch/ia64/hp/sim/simeth.c
+++ b/arch/ia64/hp/sim/simeth.c
@@ -294,7 +294,7 @@ simeth_device_event(struct notifier_block *this,unsigned long event, void *ptr)
 		return NOTIFY_DONE;
 	}
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	if ( event != NETDEV_UP && event != NETDEV_DOWN ) return NOTIFY_DONE;
diff --git a/drivers/block/aoe/aoenet.c b/drivers/block/aoe/aoenet.c
index 8460ef7..18d243c 100644
--- a/drivers/block/aoe/aoenet.c
+++ b/drivers/block/aoe/aoenet.c
@@ -115,7 +115,7 @@ aoenet_rcv(struct sk_buff *skb, struct net_device *ifp, struct packet_type *pt,
 	struct aoe_hdr *h;
 	u32 n;
 
-	if (ifp->nd_net != &init_net)
+	if (dev_net(ifp) != &init_net)
 		goto exit;
 
 	skb = skb_share_check(skb, GFP_ATOMIC);
diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index cb3c6fa..457d81f 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2429,7 +2429,7 @@ int bond_3ad_lacpdu_recv(struct sk_buff *skb, struct net_device *dev, struct pac
 	struct slave *slave = NULL;
 	int ret = NET_RX_DROP;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		goto out;
 
 	if (!(dev->flags & IFF_MASTER))
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index b57bc94..b986dac 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -345,7 +345,7 @@ static int rlb_arp_recv(struct sk_buff *skb, struct net_device *bond_dev, struct
 	struct arp_pkt *arp = (struct arp_pkt *)skb->data;
 	int res = NET_RX_DROP;
 
-	if (bond_dev->nd_net != &init_net)
+	if (dev_net(bond_dev) != &init_net)
 		goto out;
 
 	if (!(bond_dev->flags & IFF_MASTER))
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5fc9d8d..ac688fc 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2629,7 +2629,7 @@ static int bond_arp_rcv(struct sk_buff *skb, struct net_device *dev, struct pack
 	unsigned char *arp_ptr;
 	__be32 sip, tip;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		goto out;
 
 	if (!(dev->priv_flags & IFF_BONDING) || !(dev->flags & IFF_MASTER))
@@ -3470,7 +3470,7 @@ static int bond_netdev_event(struct notifier_block *this, unsigned long event, v
 {
 	struct net_device *event_dev = (struct net_device *)ptr;
 
-	if (event_dev->nd_net != &init_net)
+	if (dev_net(event_dev) != &init_net)
 		return NOTIFY_DONE;
 
 	dprintk("event_dev: %s, event: %lx\n",
@@ -3508,7 +3508,7 @@ static int bond_inetaddr_event(struct notifier_block *this, unsigned long event,
 	struct bonding *bond, *bond_next;
 	struct vlan_entry *vlan, *vlan_next;
 
-	if (ifa->ifa_dev->dev->nd_net != &init_net)
+	if (dev_net(ifa->ifa_dev->dev) != &init_net)
 		return NOTIFY_DONE;
 
 	list_for_each_entry_safe(bond, bond_next, &bond_dev_list, bond_list) {
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index 5ddf8b0..5f4b4c6 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -172,7 +172,7 @@ static int bpq_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_ty
 	struct ethhdr *eth;
 	struct bpqdev *bpq;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		goto drop;
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
@@ -553,7 +553,7 @@ static int bpq_device_event(struct notifier_block *this,unsigned long event, voi
 {
 	struct net_device *dev = (struct net_device *)ptr;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	if (!dev_is_ethdev(dev))
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index f2a6e71..41b774b 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -258,7 +258,7 @@ static __net_init int loopback_net_init(struct net *net)
 	if (!dev)
 		goto out;
 
-	dev->nd_net = net;
+	dev_net_set(dev, net);
 	err = register_netdev(dev);
 	if (err)
 		goto out_free_netdev;
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index f651a81..2056cfc 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -402,7 +402,7 @@ static int macvlan_newlink(struct net_device *dev,
 	if (!tb[IFLA_LINK])
 		return -EINVAL;
 
-	lowerdev = __dev_get_by_index(dev->nd_net, nla_get_u32(tb[IFLA_LINK]));
+	lowerdev = __dev_get_by_index(dev_net(dev), nla_get_u32(tb[IFLA_LINK]));
 	if (lowerdev == NULL)
 		return -ENODEV;
 
diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index ac0ac98..4fad4dd 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -301,7 +301,7 @@ static int pppoe_device_event(struct notifier_block *this,
 {
 	struct net_device *dev = (struct net_device *) ptr;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	/* Only look at sockets that are using this specific device. */
@@ -392,7 +392,7 @@ static int pppoe_rcv(struct sk_buff *skb,
 	if (!(skb = skb_share_check(skb, GFP_ATOMIC)))
 		goto out;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		goto drop;
 
 	if (!pskb_may_pull(skb, sizeof(struct pppoe_hdr)))
@@ -424,7 +424,7 @@ static int pppoe_disc_rcv(struct sk_buff *skb,
 	struct pppoe_hdr *ph;
 	struct pppox_sock *po;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		goto abort;
 
 	if (!pskb_may_pull(skb, sizeof(struct pppoe_hdr)))
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index e2ad98b..31cd817 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -375,7 +375,7 @@ static int veth_newlink(struct net_device *dev,
 	else
 		snprintf(ifname, IFNAMSIZ, DRV_NAME "%%d");
 
-	peer = rtnl_create_link(dev->nd_net, ifname, &veth_link_ops, tbp);
+	peer = rtnl_create_link(dev_net(dev), ifname, &veth_link_ops, tbp);
 	if (IS_ERR(peer))
 		return PTR_ERR(peer);
 
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 1525e8a..ed1afaf 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -3464,7 +3464,7 @@ static int velocity_netdev_event(struct notifier_block *nb, unsigned long notifi
 	struct velocity_info *vptr;
 	unsigned long flags;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	spin_lock_irqsave(&velocity_dev_list_lock, flags);
diff --git a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
index 96b2324..b142427 100644
--- a/drivers/net/wan/dlci.c
+++ b/drivers/net/wan/dlci.c
@@ -517,7 +517,7 @@ static int dlci_dev_event(struct notifier_block *unused,
 {
 	struct net_device *dev = (struct net_device *) ptr;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	if (event == NETDEV_UNREGISTER) {
diff --git a/drivers/net/wan/hdlc.c b/drivers/net/wan/hdlc.c
index 39951d0..9a83c9d 100644
--- a/drivers/net/wan/hdlc.c
+++ b/drivers/net/wan/hdlc.c
@@ -68,7 +68,7 @@ static int hdlc_rcv(struct sk_buff *skb, struct net_device *dev,
 {
 	struct hdlc_device *hdlc = dev_to_hdlc(dev);
 
-	if (dev->nd_net != &init_net) {
+	if (dev_net(dev) != &init_net) {
 		kfree_skb(skb);
 		return 0;
 	}
@@ -105,7 +105,7 @@ static int hdlc_device_event(struct notifier_block *this, unsigned long event,
 	unsigned long flags;
 	int on;
  
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	if (dev->get_stats != hdlc_get_stats)
diff --git a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
index fb37b80..629c909 100644
--- a/drivers/net/wan/lapbether.c
+++ b/drivers/net/wan/lapbether.c
@@ -91,7 +91,7 @@ static int lapbeth_rcv(struct sk_buff *skb, struct net_device *dev, struct packe
 	int len, err;
 	struct lapbethdev *lapbeth;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		goto drop;
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
@@ -393,7 +393,7 @@ static int lapbeth_device_event(struct notifier_block *this,
 	struct lapbethdev *lapbeth;
 	struct net_device *dev = ptr;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	if (!dev_is_ethdev(dev))
diff --git a/drivers/net/wan/syncppp.c b/drivers/net/wan/syncppp.c
index 61e24b7..29b4b94 100644
--- a/drivers/net/wan/syncppp.c
+++ b/drivers/net/wan/syncppp.c
@@ -1444,7 +1444,7 @@ static void sppp_print_bytes (u_char *p, u16 len)
 
 static int sppp_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *p, struct net_device *orig_dev)
 {
-	if (dev->nd_net != &init_net) {
+	if (dev_net(dev) != &init_net) {
 		kfree_skb(skb);
 		return 0;
 	}
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index a856cb4..21c4390 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3250,7 +3250,7 @@ static int qeth_l3_ip_event(struct notifier_block *this,
 	struct qeth_ipaddr *addr;
 	struct qeth_card *card;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	QETH_DBF_TEXT(trace, 3, "ipevent");
diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index da05ab4..7009b0c 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -70,13 +70,13 @@ static inline void ipv4_devconf_setall(struct in_device *in_dev)
 	ipv4_devconf_set((in_dev), NET_IPV4_CONF_ ## attr, (val))
 
 #define IN_DEV_ANDCONF(in_dev, attr) \
-	(IPV4_DEVCONF_ALL(in_dev->dev->nd_net, attr) && \
+	(IPV4_DEVCONF_ALL(dev_net(in_dev->dev), attr) && \
 	 IN_DEV_CONF_GET((in_dev), attr))
 #define IN_DEV_ORCONF(in_dev, attr) \
-	(IPV4_DEVCONF_ALL(in_dev->dev->nd_net, attr) || \
+	(IPV4_DEVCONF_ALL(dev_net(in_dev->dev), attr) || \
 	 IN_DEV_CONF_GET((in_dev), attr))
 #define IN_DEV_MAXCONF(in_dev, attr) \
-	(max(IPV4_DEVCONF_ALL(in_dev->dev->nd_net, attr), \
+	(max(IPV4_DEVCONF_ALL(dev_net(in_dev->dev), attr), \
 	     IN_DEV_CONF_GET((in_dev), attr)))
 
 #define IN_DEV_FORWARD(in_dev)		IN_DEV_CONF_GET((in_dev), FORWARDING)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ced61f8..d146be4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -708,8 +708,10 @@ struct net_device
 	void                    (*poll_controller)(struct net_device *dev);
 #endif
 
+#ifdef CONFIG_NET_NS
 	/* Network namespace this network device is inside */
 	struct net		*nd_net;
+#endif
 
 	/* bridge stuff */
 	struct net_bridge_port	*br_port;
@@ -737,6 +739,27 @@ struct net_device
 #define	NETDEV_ALIGN		32
 #define	NETDEV_ALIGN_CONST	(NETDEV_ALIGN - 1)
 
+/*
+ * Net namespace inlines
+ */
+static inline
+struct net *dev_net(const struct net_device *dev)
+{
+#ifdef CONFIG_NET_NS
+	return dev->nd_net;
+#else
+	return &init_net;
+#endif
+}
+
+static inline
+void dev_net_set(struct net_device *dev, const struct net *net)
+{
+#ifdef CONFIG_NET_NS
+	dev->nd_dev = net;
+#endif
+}
+
 /**
  *	netdev_priv - access network device private data
  *	@dev: network device
@@ -813,7 +836,7 @@ static inline struct net_device *next_net_device(struct net_device *dev)
 	struct list_head *lh;
 	struct net *net;
 
-	net = dev->nd_net;
+	net = dev_net(dev);
 	lh = dev->dev_list.next;
 	return lh == &net->dev_base_head ? NULL : net_device_entry(lh);
 }
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index dbc81b9..c35dc23 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -382,7 +382,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	int i, flgs;
 	struct net_device *vlandev;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	if (!grp)
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 1e5c990..e536162 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -153,7 +153,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	struct net_device_stats *stats;
 	unsigned short vlan_TCI;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		goto err_free;
 
 	skb = skb_share_check(skb, GFP_ATOMIC);
diff --git a/net/appletalk/aarp.c b/net/appletalk/aarp.c
index 61166f6..25aa37c 100644
--- a/net/appletalk/aarp.c
+++ b/net/appletalk/aarp.c
@@ -333,7 +333,7 @@ static int aarp_device_event(struct notifier_block *this, unsigned long event,
 	struct net_device *dev = ptr;
 	int ct;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	if (event == NETDEV_DOWN) {
@@ -716,7 +716,7 @@ static int aarp_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct atalk_addr sa, *ma, da;
 	struct atalk_iface *ifa;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		goto out0;
 
 	/* We only do Ethernet SNAP AARP. */
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 3be55c8..44cd42f 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -648,7 +648,7 @@ static int ddp_device_event(struct notifier_block *this, unsigned long event,
 {
 	struct net_device *dev = ptr;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	if (event == NETDEV_DOWN)
@@ -1405,7 +1405,7 @@ static int atalk_rcv(struct sk_buff *skb, struct net_device *dev,
 	int origlen;
 	__u16 len_hops;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		goto freeit;
 
 	/* Don't mangle buffer if shared */
@@ -1493,7 +1493,7 @@ freeit:
 static int ltalk_rcv(struct sk_buff *skb, struct net_device *dev,
 		     struct packet_type *pt, struct net_device *orig_dev)
 {
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		goto freeit;
 
 	/* Expand any short form frames */
diff --git a/net/atm/clip.c b/net/atm/clip.c
index e82da67..6f8223e 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -612,7 +612,7 @@ static int clip_device_event(struct notifier_block *this, unsigned long event,
 {
 	struct net_device *dev = arg;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	if (event == NETDEV_UNREGISTER) {
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 9c7f712..9db332e 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -964,7 +964,7 @@ static int mpoa_event_listener(struct notifier_block *mpoa_notifier, unsigned lo
 
 	dev = (struct net_device *)dev_ptr;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	if (dev->name == NULL || strncmp(dev->name, "lec", 3))
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 48bfcc7..ee9dd83 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -116,7 +116,7 @@ static int ax25_device_event(struct notifier_block *this, unsigned long event,
 {
 	struct net_device *dev = (struct net_device *)ptr;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	/* Reject non AX.25 devices */
diff --git a/net/ax25/ax25_in.c b/net/ax25/ax25_in.c
index d1be080..33790a8 100644
--- a/net/ax25/ax25_in.c
+++ b/net/ax25/ax25_in.c
@@ -451,7 +451,7 @@ int ax25_kiss_rcv(struct sk_buff *skb, struct net_device *dev,
 	skb->sk = NULL;		/* Initially we don't know who it's for */
 	skb->destructor = NULL;	/* Who initializes this, dammit?! */
 
-	if (dev->nd_net != &init_net) {
+	if (dev_net(dev) != &init_net) {
 		kfree_skb(skb);
 		return 0;
 	}
diff --git a/net/bridge/br_notify.c b/net/bridge/br_notify.c
index 07ac3ae..00644a5 100644
--- a/net/bridge/br_notify.c
+++ b/net/bridge/br_notify.c
@@ -37,7 +37,7 @@ static int br_device_event(struct notifier_block *unused, unsigned long event, v
 	struct net_bridge_port *p = dev->br_port;
 	struct net_bridge *br;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	/* not a port of a bridge */
diff --git a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
index 0edbd2a..8deab64 100644
--- a/net/bridge/br_stp_bpdu.c
+++ b/net/bridge/br_stp_bpdu.c
@@ -142,7 +142,7 @@ int br_stp_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct net_bridge *br;
 	const unsigned char *buf;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		goto err;
 
 	if (!p)
diff --git a/net/can/af_can.c b/net/can/af_can.c
index 36b9f22..2759b76 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -599,7 +599,7 @@ static int can_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct dev_rcv_lists *d;
 	int matches;
 
-	if (dev->type != ARPHRD_CAN || dev->nd_net != &init_net) {
+	if (dev->type != ARPHRD_CAN || dev_net(dev) != &init_net) {
 		kfree_skb(skb);
 		return 0;
 	}
@@ -710,7 +710,7 @@ static int can_notifier(struct notifier_block *nb, unsigned long msg,
 	struct net_device *dev = (struct net_device *)data;
 	struct dev_rcv_lists *d;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	if (dev->type != ARPHRD_CAN)
diff --git a/net/can/bcm.c b/net/can/bcm.c
index bd4282d..e9f99b2 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1285,7 +1285,7 @@ static int bcm_notifier(struct notifier_block *nb, unsigned long msg,
 	struct bcm_op *op;
 	int notify_enodev = 0;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	if (dev->type != ARPHRD_CAN)
diff --git a/net/can/raw.c b/net/can/raw.c
index 94cd7f2..ead50c7 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -210,7 +210,7 @@ static int raw_notifier(struct notifier_block *nb,
 	struct raw_sock *ro = container_of(nb, struct raw_sock, notifier);
 	struct sock *sk = &ro->sk;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	if (dev->type != ARPHRD_CAN)
diff --git a/net/core/dev.c b/net/core/dev.c
index aebd086..8125348 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -216,7 +216,7 @@ static inline struct hlist_head *dev_index_hash(struct net *net, int ifindex)
 /* Device list insertion */
 static int list_netdevice(struct net_device *dev)
 {
-	struct net *net = dev->nd_net;
+	struct net *net = dev_net(dev);
 
 	ASSERT_RTNL();
 
@@ -852,8 +852,8 @@ int dev_alloc_name(struct net_device *dev, const char *name)
 	struct net *net;
 	int ret;
 
-	BUG_ON(!dev->nd_net);
-	net = dev->nd_net;
+	BUG_ON(!dev_net(dev));
+	net = dev_net(dev);
 	ret = __dev_alloc_name(net, name, buf);
 	if (ret >= 0)
 		strlcpy(dev->name, buf, IFNAMSIZ);
@@ -877,9 +877,9 @@ int dev_change_name(struct net_device *dev, char *newname)
 	struct net *net;
 
 	ASSERT_RTNL();
-	BUG_ON(!dev->nd_net);
+	BUG_ON(!dev_net(dev));
 
-	net = dev->nd_net;
+	net = dev_net(dev);
 	if (dev->flags & IFF_UP)
 		return -EBUSY;
 
@@ -2615,7 +2615,7 @@ static int ptype_seq_show(struct seq_file *seq, void *v)
 
 	if (v == SEQ_START_TOKEN)
 		seq_puts(seq, "Type Device      Function\n");
-	else if (pt->dev == NULL || pt->dev->nd_net == seq_file_net(seq)) {
+	else if (pt->dev == NULL || dev_net(pt->dev) == seq_file_net(seq)) {
 		if (pt->type == htons(ETH_P_ALL))
 			seq_puts(seq, "ALL ");
 		else
@@ -3689,8 +3689,8 @@ int register_netdevice(struct net_device *dev)
 
 	/* When net_device's are persistent, this will be fatal. */
 	BUG_ON(dev->reg_state != NETREG_UNINITIALIZED);
-	BUG_ON(!dev->nd_net);
-	net = dev->nd_net;
+	BUG_ON(!dev_net(dev));
+	net = dev_net(dev);
 
 	spin_lock_init(&dev->queue_lock);
 	spin_lock_init(&dev->_xmit_lock);
@@ -4011,7 +4011,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	dev = (struct net_device *)
 		(((long)p + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
 	dev->padded = (char *)dev - (char *)p;
-	dev->nd_net = &init_net;
+	dev_net_set(dev, &init_net);
 
 	if (sizeof_priv) {
 		dev->priv = ((char *)dev +
@@ -4136,7 +4136,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 
 	/* Get out if there is nothing todo */
 	err = 0;
-	if (dev->nd_net == net)
+	if (dev_net(dev) == net)
 		goto out;
 
 	/* Pick the destination device name, and ensure
@@ -4187,7 +4187,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	dev_addr_discard(dev);
 
 	/* Actually switch the network namespace */
-	dev->nd_net = net;
+	dev_net_set(dev, net);
 
 	/* Assign the new device name */
 	if (destname != dev->name)
diff --git a/net/core/dst.c b/net/core/dst.c
index 3a01a81..694cd2a 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -279,7 +279,7 @@ static inline void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 	if (!unregister) {
 		dst->input = dst->output = dst_discard;
 	} else {
-		dst->dev = dst->dev->nd_net->loopback_dev;
+		dst->dev = dev_net(dst->dev)->loopback_dev;
 		dev_hold(dst->dev);
 		dev_put(dev);
 		if (dst->neighbour && dst->neighbour->dev == dev) {
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 42ccaf5..942be93 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -618,7 +618,7 @@ static int fib_rules_event(struct notifier_block *this, unsigned long event,
 			    void *ptr)
 {
 	struct net_device *dev = ptr;
-	struct net *net = dev->nd_net;
+	struct net *net = dev_net(dev);
 	struct fib_rules_ops *ops;
 
 	ASSERT_RTNL();
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 23c0a10..c978bd1 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -388,7 +388,7 @@ struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, struct net *net,
 	hash_val = tbl->hash(pkey, NULL);
 	for (n = tbl->hash_buckets[hash_val & tbl->hash_mask]; n; n = n->next) {
 		if (!memcmp(n->primary_key, pkey, key_len) &&
-		    (net == n->dev->nd_net)) {
+		    dev_net(n->dev) == net) {
 			neigh_hold(n);
 			NEIGH_CACHE_STAT_INC(tbl, hits);
 			break;
@@ -1298,7 +1298,7 @@ struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 	struct neigh_parms *p, *ref;
 	struct net *net;
 
-	net = dev->nd_net;
+	net = dev_net(dev);
 	ref = lookup_neigh_params(tbl, net, 0);
 	if (!ref)
 		return NULL;
@@ -2050,7 +2050,7 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 			s_idx = 0;
 		for (n = tbl->hash_buckets[h], idx = 0; n; n = n->next) {
 			int lidx;
-			if (n->dev->nd_net != net)
+			if (dev_net(n->dev) != net)
 				continue;
 			lidx = idx++;
 			if (lidx < s_idx)
@@ -2155,7 +2155,7 @@ static struct neighbour *neigh_get_first(struct seq_file *seq)
 		n = tbl->hash_buckets[bucket];
 
 		while (n) {
-			if (n->dev->nd_net != net)
+			if (dev_net(n->dev) != net)
 				goto next;
 			if (state->neigh_sub_iter) {
 				loff_t fakep = 0;
@@ -2198,7 +2198,7 @@ static struct neighbour *neigh_get_next(struct seq_file *seq,
 
 	while (1) {
 		while (n) {
-			if (n->dev->nd_net != net)
+			if (dev_net(n->dev) != net)
 				goto next;
 			if (state->neigh_sub_iter) {
 				void *v = state->neigh_sub_iter(state, n, pos);
@@ -2482,7 +2482,7 @@ static inline size_t neigh_nlmsg_size(void)
 
 static void __neigh_notify(struct neighbour *n, int type, int flags)
 {
-	struct net *net = n->dev->nd_net;
+	struct net *net = dev_net(n->dev);
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
 
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 20e63b3..a803b44 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1874,7 +1874,7 @@ static int pktgen_device_event(struct notifier_block *unused,
 {
 	struct net_device *dev = ptr;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	/* It is OK that we do not hold the group lock right now,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2bd9c5f..09250a0 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -972,7 +972,7 @@ struct net_device *rtnl_create_link(struct net *net, char *ifname,
 			goto err_free;
 	}
 
-	dev->nd_net = net;
+	dev_net_set(dev, net);
 	dev->rtnl_link_ops = ops;
 
 	if (tb[IFLA_MTU])
@@ -1198,7 +1198,7 @@ static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
 
 void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change)
 {
-	struct net *net = dev->nd_net;
+	struct net *net = dev_net(dev);
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
 
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 23fd95a..3554fb3 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -2089,7 +2089,7 @@ static int dn_device_event(struct notifier_block *this, unsigned long event,
 {
 	struct net_device *dev = (struct net_device *)ptr;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	switch(event) {
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 9dc0abb..0a46b6c 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -580,7 +580,7 @@ int dn_route_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type
 	struct dn_dev *dn = (struct dn_dev *)dev->dn_ptr;
 	unsigned char padlen = 0;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		goto dump_it;
 
 	if (dn == NULL)
diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index bc0f625..68d1544 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -1064,7 +1064,7 @@ static int econet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 	struct sock *sk;
 	struct ec_device *edev = dev->ec_ptr;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		goto drop;
 
 	if (skb->pkt_type == PACKET_OTHERHOST)
@@ -1121,7 +1121,7 @@ static int econet_notifier(struct notifier_block *this, unsigned long msg, void
 	struct net_device *dev = (struct net_device *)data;
 	struct ec_device *edev;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	switch (msg) {
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 832473e..3ce2e13 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -242,7 +242,7 @@ static int arp_constructor(struct neighbour *neigh)
 		return -EINVAL;
 	}
 
-	neigh->type = inet_addr_type(dev->nd_net, addr);
+	neigh->type = inet_addr_type(dev_net(dev), addr);
 
 	parms = in_dev->arp_parms;
 	__neigh_parms_put(neigh->parms);
@@ -341,14 +341,14 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	switch (IN_DEV_ARP_ANNOUNCE(in_dev)) {
 	default:
 	case 0:		/* By default announce any local IP */
-		if (skb && inet_addr_type(dev->nd_net, ip_hdr(skb)->saddr) == RTN_LOCAL)
+		if (skb && inet_addr_type(dev_net(dev), ip_hdr(skb)->saddr) == RTN_LOCAL)
 			saddr = ip_hdr(skb)->saddr;
 		break;
 	case 1:		/* Restrict announcements of saddr in same subnet */
 		if (!skb)
 			break;
 		saddr = ip_hdr(skb)->saddr;
-		if (inet_addr_type(dev->nd_net, saddr) == RTN_LOCAL) {
+		if (inet_addr_type(dev_net(dev), saddr) == RTN_LOCAL) {
 			/* saddr should be known to target */
 			if (inet_addr_onlink(in_dev, target, saddr))
 				break;
@@ -424,7 +424,7 @@ static int arp_filter(__be32 sip, __be32 tip, struct net_device *dev)
 	int flag = 0;
 	/*unsigned long now; */
 
-	if (ip_route_output_key(dev->nd_net, &rt, &fl) < 0)
+	if (ip_route_output_key(dev_net(dev), &rt, &fl) < 0)
 		return 1;
 	if (rt->u.dst.dev != dev) {
 		NET_INC_STATS_BH(LINUX_MIB_ARPFILTER);
@@ -477,7 +477,7 @@ int arp_find(unsigned char *haddr, struct sk_buff *skb)
 
 	paddr = skb->rtable->rt_gateway;
 
-	if (arp_set_predefined(inet_addr_type(dev->nd_net, paddr), haddr, paddr, dev))
+	if (arp_set_predefined(inet_addr_type(dev_net(dev), paddr), haddr, paddr, dev))
 		return 0;
 
 	n = __neigh_lookup(&arp_tbl, &paddr, dev, 1);
@@ -709,7 +709,7 @@ static int arp_process(struct sk_buff *skb)
 	u16 dev_type = dev->type;
 	int addr_type;
 	struct neighbour *n;
-	struct net *net = dev->nd_net;
+	struct net *net = dev_net(dev);
 
 	/* arp_rcv below verifies the ARP header and verifies the device
 	 * is ARP'able.
@@ -858,7 +858,7 @@ static int arp_process(struct sk_buff *skb)
 
 	n = __neigh_lookup(&arp_tbl, &sip, dev, 0);
 
-	if (IPV4_DEVCONF_ALL(dev->nd_net, ARP_ACCEPT)) {
+	if (IPV4_DEVCONF_ALL(dev_net(dev), ARP_ACCEPT)) {
 		/* Unsolicited ARP is not accepted by default.
 		   It is possible, that this option should be enabled for some
 		   devices (strip is candidate)
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 4a10dbb..823c724 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -165,7 +165,7 @@ static struct in_device *inetdev_init(struct net_device *dev)
 	if (!in_dev)
 		goto out;
 	INIT_RCU_HEAD(&in_dev->rcu_head);
-	memcpy(&in_dev->cnf, dev->nd_net->ipv4.devconf_dflt,
+	memcpy(&in_dev->cnf, dev_net(dev)->ipv4.devconf_dflt,
 			sizeof(in_dev->cnf));
 	in_dev->cnf.sysctl = NULL;
 	in_dev->dev = dev;
@@ -872,7 +872,7 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 {
 	__be32 addr = 0;
 	struct in_device *in_dev;
-	struct net *net = dev->nd_net;
+	struct net *net = dev_net(dev);
 
 	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(dev);
@@ -974,7 +974,7 @@ __be32 inet_confirm_addr(struct in_device *in_dev,
 	if (scope != RT_SCOPE_LINK)
 		return confirm_addr_indev(in_dev, dst, local, scope);
 
-	net = in_dev->dev->nd_net;
+	net = dev_net(in_dev->dev);
 	read_lock(&dev_base_lock);
 	rcu_read_lock();
 	for_each_netdev(net, dev) {
@@ -1203,7 +1203,7 @@ static void rtmsg_ifa(int event, struct in_ifaddr* ifa, struct nlmsghdr *nlh,
 	int err = -ENOBUFS;
 	struct net *net;
 
-	net = ifa->ifa_dev->dev->nd_net;
+	net = dev_net(ifa->ifa_dev->dev);
 	skb = nlmsg_new(inet_nlmsg_size(), GFP_KERNEL);
 	if (skb == NULL)
 		goto errout;
@@ -1517,7 +1517,7 @@ static void devinet_sysctl_register(struct in_device *idev)
 {
 	neigh_sysctl_register(idev->dev, idev->arp_parms, NET_IPV4,
 			NET_IPV4_NEIGH, "ipv4", NULL, NULL);
-	__devinet_sysctl_register(idev->dev->nd_net, idev->dev->name,
+	__devinet_sysctl_register(dev_net(idev->dev), idev->dev->name,
 			idev->dev->ifindex, &idev->cnf);
 }
 
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 86ff271..0e4b34b 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -257,7 +257,7 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 	if (in_dev == NULL)
 		goto e_inval;
 
-	net = dev->nd_net;
+	net = dev_net(dev);
 	if (fib_lookup(net, &fl, &res))
 		goto last_resort;
 	if (res.type != RTN_UNICAST)
@@ -674,7 +674,7 @@ out:
 
 static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifaddr *ifa)
 {
-	struct net *net = ifa->ifa_dev->dev->nd_net;
+	struct net *net = dev_net(ifa->ifa_dev->dev);
 	struct fib_table *tb;
 	struct fib_config cfg = {
 		.fc_protocol = RTPROT_KERNEL,
@@ -801,15 +801,15 @@ static void fib_del_ifaddr(struct in_ifaddr *ifa)
 		fib_magic(RTM_DELROUTE, RTN_LOCAL, ifa->ifa_local, 32, prim);
 
 		/* Check, that this local address finally disappeared. */
-		if (inet_addr_type(dev->nd_net, ifa->ifa_local) != RTN_LOCAL) {
+		if (inet_addr_type(dev_net(dev), ifa->ifa_local) != RTN_LOCAL) {
 			/* And the last, but not the least thing.
 			   We must flush stray FIB entries.
 
 			   First of all, we scan fib_info list searching
 			   for stray nexthop entries, then ignite fib_flush.
 			*/
-			if (fib_sync_down_addr(dev->nd_net, ifa->ifa_local))
-				fib_flush(dev->nd_net);
+			if (fib_sync_down_addr(dev_net(dev), ifa->ifa_local))
+				fib_flush(dev_net(dev));
 		}
 	}
 #undef LOCAL_OK
@@ -899,7 +899,7 @@ static void nl_fib_lookup_exit(struct net *net)
 static void fib_disable_ip(struct net_device *dev, int force)
 {
 	if (fib_sync_down_dev(dev, force))
-		fib_flush(dev->nd_net);
+		fib_flush(dev_net(dev));
 	rt_cache_flush(0);
 	arp_ifdown(dev);
 }
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index ff9a8e6..f38f093 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -351,7 +351,7 @@ static void icmp_push_reply(struct icmp_bxm *icmp_param,
 	struct sock *sk;
 	struct sk_buff *skb;
 
-	sk = icmp_sk(rt->u.dst.dev->nd_net);
+	sk = icmp_sk(dev_net(rt->u.dst.dev));
 	if (ip_append_data(sk, icmp_glue_bits, icmp_param,
 			   icmp_param->data_len+icmp_param->head_len,
 			   icmp_param->head_len,
@@ -382,7 +382,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 {
 	struct ipcm_cookie ipc;
 	struct rtable *rt = skb->rtable;
-	struct net *net = rt->u.dst.dev->nd_net;
+	struct net *net = dev_net(rt->u.dst.dev);
 	struct sock *sk = icmp_sk(net);
 	struct inet_sock *inet = inet_sk(sk);
 	__be32 daddr;
@@ -447,7 +447,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 
 	if (!rt)
 		goto out;
-	net = rt->u.dst.dev->nd_net;
+	net = dev_net(rt->u.dst.dev);
 	sk = icmp_sk(net);
 
 	/*
@@ -677,7 +677,7 @@ static void icmp_unreach(struct sk_buff *skb)
 	u32 info = 0;
 	struct net *net;
 
-	net = skb->dst->dev->nd_net;
+	net = dev_net(skb->dst->dev);
 
 	/*
 	 *	Incomplete header ?
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 6a4ee8d..682f632 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -130,12 +130,12 @@
  */
 
 #define IGMP_V1_SEEN(in_dev) \
-	(IPV4_DEVCONF_ALL(in_dev->dev->nd_net, FORCE_IGMP_VERSION) == 1 || \
+	(IPV4_DEVCONF_ALL(dev_net(in_dev->dev), FORCE_IGMP_VERSION) == 1 || \
 	 IN_DEV_CONF_GET((in_dev), FORCE_IGMP_VERSION) == 1 || \
 	 ((in_dev)->mr_v1_seen && \
 	  time_before(jiffies, (in_dev)->mr_v1_seen)))
 #define IGMP_V2_SEEN(in_dev) \
-	(IPV4_DEVCONF_ALL(in_dev->dev->nd_net, FORCE_IGMP_VERSION) == 2 || \
+	(IPV4_DEVCONF_ALL(dev_net(in_dev->dev), FORCE_IGMP_VERSION) == 2 || \
 	 IN_DEV_CONF_GET((in_dev), FORCE_IGMP_VERSION) == 2 || \
 	 ((in_dev)->mr_v2_seen && \
 	  time_before(jiffies, (in_dev)->mr_v2_seen)))
@@ -1198,7 +1198,7 @@ void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 
 	ASSERT_RTNL();
 
-	if (in_dev->dev->nd_net != &init_net)
+	if (dev_net(in_dev->dev) != &init_net)
 		return;
 
 	for (im=in_dev->mc_list; im; im=im->next) {
@@ -1280,7 +1280,7 @@ void ip_mc_dec_group(struct in_device *in_dev, __be32 addr)
 
 	ASSERT_RTNL();
 
-	if (in_dev->dev->nd_net != &init_net)
+	if (dev_net(in_dev->dev) != &init_net)
 		return;
 
 	for (ip=&in_dev->mc_list; (i=*ip)!=NULL; ip=&i->next) {
@@ -1310,7 +1310,7 @@ void ip_mc_down(struct in_device *in_dev)
 
 	ASSERT_RTNL();
 
-	if (in_dev->dev->nd_net != &init_net)
+	if (dev_net(in_dev->dev) != &init_net)
 		return;
 
 	for (i=in_dev->mc_list; i; i=i->next)
@@ -1333,7 +1333,7 @@ void ip_mc_init_dev(struct in_device *in_dev)
 {
 	ASSERT_RTNL();
 
-	if (in_dev->dev->nd_net != &init_net)
+	if (dev_net(in_dev->dev) != &init_net)
 		return;
 
 	in_dev->mc_tomb = NULL;
@@ -1359,7 +1359,7 @@ void ip_mc_up(struct in_device *in_dev)
 
 	ASSERT_RTNL();
 
-	if (in_dev->dev->nd_net != &init_net)
+	if (dev_net(in_dev->dev) != &init_net)
 		return;
 
 	ip_mc_inc_group(in_dev, IGMP_ALL_HOSTS);
@@ -1378,7 +1378,7 @@ void ip_mc_destroy_dev(struct in_device *in_dev)
 
 	ASSERT_RTNL();
 
-	if (in_dev->dev->nd_net != &init_net)
+	if (dev_net(in_dev->dev) != &init_net)
 		return;
 
 	/* Deactivate timers */
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 8b448c4..fcb60e7 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -571,7 +571,7 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 
 	IP_INC_STATS_BH(IPSTATS_MIB_REASMREQDS);
 
-	net = skb->dev ? skb->dev->nd_net : skb->dst->dev->nd_net;
+	net = skb->dev ? dev_net(skb->dev) : dev_net(skb->dst->dev);
 	/* Start by cleaning up the memory. */
 	if (atomic_read(&net->ipv4.frags.mem) > net->ipv4.frags.high_thresh)
 		ip_evictor(net);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index f9ee844..50972b3 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1190,7 +1190,7 @@ static int ipgre_close(struct net_device *dev)
 	struct ip_tunnel *t = netdev_priv(dev);
 	if (ipv4_is_multicast(t->parms.iph.daddr) && t->mlink) {
 		struct in_device *in_dev;
-		in_dev = inetdev_by_index(dev->nd_net, t->mlink);
+		in_dev = inetdev_by_index(dev_net(dev), t->mlink);
 		if (in_dev) {
 			ip_mc_dec_group(in_dev, t->parms.iph.daddr);
 			in_dev_put(in_dev);
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 2aeea5d..26685c8 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -172,7 +172,7 @@ int ip_call_ra_chain(struct sk_buff *skb)
 		if (sk && inet_sk(sk)->num == protocol &&
 		    (!sk->sk_bound_dev_if ||
 		     sk->sk_bound_dev_if == dev->ifindex) &&
-		    sk->sk_net == dev->nd_net) {
+		    sk->sk_net == dev_net(dev)) {
 			if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
 				if (ip_defrag(skb, IP_DEFRAG_CALL_RA_CHAIN)) {
 					read_unlock(&ip_ra_lock);
@@ -199,7 +199,7 @@ int ip_call_ra_chain(struct sk_buff *skb)
 
 static int ip_local_deliver_finish(struct sk_buff *skb)
 {
-	struct net *net = skb->dev->nd_net;
+	struct net *net = dev_net(skb->dev);
 
 	__skb_pull(skb, ip_hdrlen(skb));
 
@@ -291,7 +291,7 @@ static inline int ip_rcv_options(struct sk_buff *skb)
 	opt = &(IPCB(skb)->opt);
 	opt->optlen = iph->ihl*4 - sizeof(struct iphdr);
 
-	if (ip_options_compile(dev->nd_net, opt, skb)) {
+	if (ip_options_compile(dev_net(dev), opt, skb)) {
 		IP_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
 		goto drop;
 	}
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 87cc122..d107543 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -145,7 +145,7 @@ int ip_options_echo(struct ip_options * dopt, struct sk_buff * skb)
 						__be32 addr;
 
 						memcpy(&addr, sptr+soffset-1, 4);
-						if (inet_addr_type(skb->dst->dev->nd_net, addr) != RTN_LOCAL) {
+						if (inet_addr_type(dev_net(skb->dst->dev), addr) != RTN_LOCAL) {
 							dopt->ts_needtime = 1;
 							soffset += 8;
 						}
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 96138b1..08e8fb6 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -434,7 +434,7 @@ ic_rarp_recv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	unsigned char *sha, *tha;		/* s for "source", t for "target" */
 	struct ic_device *d;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		goto drop;
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
@@ -854,7 +854,7 @@ static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, str
 	struct ic_device *d;
 	int len, ext_len;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		goto drop;
 
 	/* Perform verifications before taking the lock.  */
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 7d63d74..e54bc13 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1089,7 +1089,7 @@ static int ipmr_device_event(struct notifier_block *this, unsigned long event, v
 	struct vif_device *v;
 	int ct;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	if (event != NETDEV_UNREGISTER)
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index fe05da4..500998a 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -481,7 +481,7 @@ ipq_rcv_dev_event(struct notifier_block *this,
 {
 	struct net_device *dev = ptr;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	/* Drop any packets associated with the downed device */
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index c6817b1..84c26dd 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -120,7 +120,7 @@ static int masq_device_event(struct notifier_block *this,
 {
 	const struct net_device *dev = ptr;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	if (event == NETDEV_DOWN) {
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 3f68a93..8756d50 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -168,7 +168,7 @@ static int raw_v4_input(struct sk_buff *skb, struct iphdr *iph, int hash)
 	if (hlist_empty(head))
 		goto out;
 
-	net = skb->dev->nd_net;
+	net = dev_net(skb->dev);
 	sk = __raw_v4_lookup(net, __sk_head(head), iph->protocol,
 			     iph->saddr, iph->daddr,
 			     skb->dev->ifindex);
@@ -276,7 +276,7 @@ void raw_icmp_error(struct sk_buff *skb, int protocol, u32 info)
 	raw_sk = sk_head(&raw_v4_hashinfo.ht[hash]);
 	if (raw_sk != NULL) {
 		iph = (struct iphdr *)skb->data;
-		net = skb->dev->nd_net;
+		net = dev_net(skb->dev);
 
 		while ((raw_sk = __raw_v4_lookup(net, raw_sk, protocol,
 						iph->daddr, iph->saddr,
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 2941ef2..7768d71 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -284,7 +284,7 @@ static struct rtable *rt_cache_get_first(struct rt_cache_iter_state *st)
 		rcu_read_lock_bh();
 		r = rcu_dereference(rt_hash_table[st->bucket].chain);
 		while (r) {
-			if (r->u.dst.dev->nd_net == st->p.net &&
+			if (dev_net(r->u.dst.dev) == st->p.net &&
 			    r->rt_genid == st->genid)
 				return r;
 			r = rcu_dereference(r->u.dst.rt_next);
@@ -312,7 +312,7 @@ static struct rtable *rt_cache_get_next(struct rt_cache_iter_state *st,
 					struct rtable *r)
 {
 	while ((r = __rt_cache_get_next(st, r)) != NULL) {
-		if (r->u.dst.dev->nd_net != st->p.net)
+		if (dev_net(r->u.dst.dev) != st->p.net)
 			continue;
 		if (r->rt_genid == st->genid)
 			break;
@@ -680,7 +680,7 @@ static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
 
 static inline int compare_netns(struct rtable *rt1, struct rtable *rt2)
 {
-	return rt1->u.dst.dev->nd_net == rt2->u.dst.dev->nd_net;
+	return dev_net(rt1->u.dst.dev) == dev_net(rt2->u.dst.dev);
 }
 
 /*
@@ -1164,7 +1164,7 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 	if (!in_dev)
 		return;
 
-	net = dev->nd_net;
+	net = dev_net(dev);
 	if (new_gw == old_gw || !IN_DEV_RX_REDIRECTS(in_dev)
 	    || ipv4_is_multicast(new_gw) || ipv4_is_lbcast(new_gw)
 	    || ipv4_is_zeronet(new_gw))
@@ -1195,7 +1195,7 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 				    rth->fl.oif != ikeys[k] ||
 				    rth->fl.iif != 0 ||
 				    rth->rt_genid != atomic_read(&rt_genid) ||
-				    rth->u.dst.dev->nd_net != net) {
+				    dev_net(rth->u.dst.dev) != net) {
 					rthp = &rth->u.dst.rt_next;
 					continue;
 				}
@@ -1454,7 +1454,7 @@ unsigned short ip_rt_frag_needed(struct net *net, struct iphdr *iph,
 			    rth->rt_src  == iph->saddr &&
 			    rth->fl.iif == 0 &&
 			    !(dst_metric_locked(&rth->u.dst, RTAX_MTU)) &&
-			    rth->u.dst.dev->nd_net == net &&
+			    dev_net(rth->u.dst.dev) == net &&
 			    rth->rt_genid == atomic_read(&rt_genid)) {
 				unsigned short mtu = new_mtu;
 
@@ -1530,9 +1530,9 @@ static void ipv4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 {
 	struct rtable *rt = (struct rtable *) dst;
 	struct in_device *idev = rt->idev;
-	if (dev != dev->nd_net->loopback_dev && idev && idev->dev == dev) {
+	if (dev != dev_net(dev)->loopback_dev && idev && idev->dev == dev) {
 		struct in_device *loopback_idev =
-			in_dev_get(dev->nd_net->loopback_dev);
+			in_dev_get(dev_net(dev)->loopback_dev);
 		if (loopback_idev) {
 			rt->idev = loopback_idev;
 			in_dev_put(idev);
@@ -1576,7 +1576,7 @@ void ip_rt_get_source(u8 *addr, struct rtable *rt)
 
 	if (rt->fl.iif == 0)
 		src = rt->rt_src;
-	else if (fib_lookup(rt->u.dst.dev->nd_net, &rt->fl, &res) == 0) {
+	else if (fib_lookup(dev_net(rt->u.dst.dev), &rt->fl, &res) == 0) {
 		src = FIB_RES_PREFSRC(res);
 		fib_res_put(&res);
 	} else
@@ -1900,7 +1900,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	__be32		spec_dst;
 	int		err = -EINVAL;
 	int		free_res = 0;
-	struct net    * net = dev->nd_net;
+	struct net    * net = dev_net(dev);
 
 	/* IP on this device is disabled. */
 
@@ -2071,7 +2071,7 @@ int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	int iif = dev->ifindex;
 	struct net *net;
 
-	net = dev->nd_net;
+	net = dev_net(dev);
 	tos &= IPTOS_RT_MASK;
 	hash = rt_hash(daddr, saddr, iif);
 
@@ -2084,7 +2084,7 @@ int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		    rth->fl.oif == 0 &&
 		    rth->fl.mark == skb->mark &&
 		    rth->fl.fl4_tos == tos &&
-		    rth->u.dst.dev->nd_net == net &&
+		    dev_net(rth->u.dst.dev) == net &&
 		    rth->rt_genid == atomic_read(&rt_genid)) {
 			dst_use(&rth->u.dst, jiffies);
 			RT_CACHE_STAT_INC(in_hit);
@@ -2486,7 +2486,7 @@ int __ip_route_output_key(struct net *net, struct rtable **rp,
 		    rth->fl.mark == flp->mark &&
 		    !((rth->fl.fl4_tos ^ flp->fl4_tos) &
 			    (IPTOS_RT_MASK | RTO_ONLINK)) &&
-		    rth->u.dst.dev->nd_net == net &&
+		    dev_net(rth->u.dst.dev) == net &&
 		    rth->rt_genid == atomic_read(&rt_genid)) {
 			dst_use(&rth->u.dst, jiffies);
 			RT_CACHE_STAT_INC(out_hit);
@@ -2795,7 +2795,7 @@ int ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb)
 		rcu_read_lock_bh();
 		for (rt = rcu_dereference(rt_hash_table[h].chain), idx = 0; rt;
 		     rt = rcu_dereference(rt->u.dst.rt_next), idx++) {
-			if (rt->u.dst.dev->nd_net != net || idx < s_idx)
+			if (dev_net(rt->u.dst.dev) != net || idx < s_idx)
 				continue;
 			if (rt->rt_genid != atomic_read(&rt_genid))
 				continue;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 649d00a..28bece6 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -353,7 +353,7 @@ void tcp_v4_err(struct sk_buff *skb, u32 info)
 		return;
 	}
 
-	sk = inet_lookup(skb->dev->nd_net, &tcp_hashinfo, iph->daddr, th->dest,
+	sk = inet_lookup(dev_net(skb->dev), &tcp_hashinfo, iph->daddr, th->dest,
 			iph->saddr, th->source, inet_iif(skb));
 	if (!sk) {
 		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
@@ -1644,7 +1644,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	TCP_SKB_CB(skb)->flags	 = iph->tos;
 	TCP_SKB_CB(skb)->sacked	 = 0;
 
-	sk = __inet_lookup(skb->dev->nd_net, &tcp_hashinfo, iph->saddr,
+	sk = __inet_lookup(dev_net(skb->dev), &tcp_hashinfo, iph->saddr,
 			th->source, iph->daddr, th->dest, inet_iif(skb));
 	if (!sk)
 		goto no_tcp_socket;
@@ -1718,7 +1718,7 @@ do_time_wait:
 	}
 	switch (tcp_timewait_state_process(inet_twsk(sk), skb, th)) {
 	case TCP_TW_SYN: {
-		struct sock *sk2 = inet_lookup_listener(skb->dev->nd_net,
+		struct sock *sk2 = inet_lookup_listener(dev_net(skb->dev),
 							&tcp_hashinfo,
 							iph->daddr, th->dest,
 							inet_iif(skb));
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index b37581d..e2cd934 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -357,7 +357,7 @@ void __udp4_lib_err(struct sk_buff *skb, u32 info, struct hlist_head udptable[])
 	int harderr;
 	int err;
 
-	sk = __udp4_lib_lookup(skb->dev->nd_net, iph->daddr, uh->dest,
+	sk = __udp4_lib_lookup(dev_net(skb->dev), iph->daddr, uh->dest,
 			iph->saddr, uh->source, skb->dev->ifindex, udptable);
 	if (sk == NULL) {
 		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
@@ -1181,7 +1181,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 	if (rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
 		return __udp4_lib_mcast_deliver(skb, uh, saddr, daddr, udptable);
 
-	sk = __udp4_lib_lookup(skb->dev->nd_net, saddr, uh->source, daddr,
+	sk = __udp4_lib_lookup(dev_net(skb->dev), saddr, uh->source, daddr,
 			uh->dest, inet_iif(skb), udptable);
 
 	if (sk != NULL) {
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 10ed704..c63de0a 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -221,7 +221,7 @@ static void xfrm4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 	xdst = (struct xfrm_dst *)dst;
 	if (xdst->u.rt.idev->dev == dev) {
 		struct in_device *loopback_idev =
-			in_dev_get(dev->nd_net->loopback_dev);
+			in_dev_get(dev_net(dev)->loopback_dev);
 		BUG_ON(!loopback_idev);
 
 		do {
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8995488..d1de9ec 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -335,7 +335,7 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 
 	rwlock_init(&ndev->lock);
 	ndev->dev = dev;
-	memcpy(&ndev->cnf, dev->nd_net->ipv6.devconf_dflt, sizeof(ndev->cnf));
+	memcpy(&ndev->cnf, dev_net(dev)->ipv6.devconf_dflt, sizeof(ndev->cnf));
 	ndev->cnf.mtu6 = dev->mtu;
 	ndev->cnf.sysctl = NULL;
 	ndev->nd_parms = neigh_parms_alloc(dev, &nd_tbl);
@@ -561,7 +561,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
 	write_lock(&addrconf_hash_lock);
 
 	/* Ignore adding duplicate addresses on an interface */
-	if (ipv6_chk_same_addr(idev->dev->nd_net, addr, idev->dev)) {
+	if (ipv6_chk_same_addr(dev_net(idev->dev), addr, idev->dev)) {
 		ADBG(("ipv6_add_addr: already assigned\n"));
 		err = -EEXIST;
 		goto out;
@@ -751,7 +751,7 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 	if ((ifp->flags & IFA_F_PERMANENT) && onlink < 1) {
 		struct in6_addr prefix;
 		struct rt6_info *rt;
-		struct net *net = ifp->idev->dev->nd_net;
+		struct net *net = dev_net(ifp->idev->dev);
 		ipv6_addr_prefix(&prefix, &ifp->addr, ifp->prefix_len);
 		rt = rt6_lookup(net, &prefix, NULL, ifp->idev->dev->ifindex, 1);
 
@@ -1044,7 +1044,7 @@ int ipv6_dev_get_saddr(struct net_device *dst_dev,
 {
 	struct ipv6_saddr_score scores[2],
 				*score = &scores[0], *hiscore = &scores[1];
-	struct net *net = dst_dev->nd_net;
+	struct net *net = dev_net(dst_dev);
 	struct ipv6_saddr_dst dst;
 	struct net_device *dev;
 	int dst_type;
@@ -1217,7 +1217,7 @@ int ipv6_chk_addr(struct net *net, struct in6_addr *addr,
 
 	read_lock_bh(&addrconf_hash_lock);
 	for(ifp = inet6_addr_lst[hash]; ifp; ifp=ifp->lst_next) {
-		if (ifp->idev->dev->nd_net != net)
+		if (dev_net(ifp->idev->dev) != net)
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr) &&
 		    !(ifp->flags&IFA_F_TENTATIVE)) {
@@ -1239,7 +1239,7 @@ int ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
 	u8 hash = ipv6_addr_hash(addr);
 
 	for(ifp = inet6_addr_lst[hash]; ifp; ifp=ifp->lst_next) {
-		if (ifp->idev->dev->nd_net != net)
+		if (dev_net(ifp->idev->dev) != net)
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr)) {
 			if (dev == NULL || ifp->idev->dev == dev)
@@ -1257,7 +1257,7 @@ struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, struct in6_addr *addr,
 
 	read_lock_bh(&addrconf_hash_lock);
 	for(ifp = inet6_addr_lst[hash]; ifp; ifp=ifp->lst_next) {
-		if (ifp->idev->dev->nd_net != net)
+		if (dev_net(ifp->idev->dev) != net)
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr)) {
 			if (dev == NULL || ifp->idev->dev == dev ||
@@ -1559,7 +1559,7 @@ addrconf_prefix_route(struct in6_addr *pfx, int plen, struct net_device *dev,
 		.fc_expires = expires,
 		.fc_dst_len = plen,
 		.fc_flags = RTF_UP | flags,
-		.fc_nlinfo.nl_net = dev->nd_net,
+		.fc_nlinfo.nl_net = dev_net(dev),
 	};
 
 	ipv6_addr_copy(&cfg.fc_dst, pfx);
@@ -1586,7 +1586,7 @@ static void addrconf_add_mroute(struct net_device *dev)
 		.fc_ifindex = dev->ifindex,
 		.fc_dst_len = 8,
 		.fc_flags = RTF_UP,
-		.fc_nlinfo.nl_net = dev->nd_net,
+		.fc_nlinfo.nl_net = dev_net(dev),
 	};
 
 	ipv6_addr_set(&cfg.fc_dst, htonl(0xFF000000), 0, 0, 0);
@@ -1603,7 +1603,7 @@ static void sit_route_add(struct net_device *dev)
 		.fc_ifindex = dev->ifindex,
 		.fc_dst_len = 96,
 		.fc_flags = RTF_UP | RTF_NONEXTHOP,
-		.fc_nlinfo.nl_net = dev->nd_net,
+		.fc_nlinfo.nl_net = dev_net(dev),
 	};
 
 	/* prefix length - 96 bits "::d.d.d.d" */
@@ -1704,7 +1704,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 
 	if (pinfo->onlink) {
 		struct rt6_info *rt;
-		rt = rt6_lookup(dev->nd_net, &pinfo->prefix, NULL,
+		rt = rt6_lookup(dev_net(dev), &pinfo->prefix, NULL,
 				dev->ifindex, 1);
 
 		if (rt && ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
@@ -1748,7 +1748,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 
 ok:
 
-		ifp = ipv6_get_ifaddr(dev->nd_net, &addr, dev, 1);
+		ifp = ipv6_get_ifaddr(dev_net(dev), &addr, dev, 1);
 
 		if (ifp == NULL && valid_lft) {
 			int max_addresses = in6_dev->cnf.max_addresses;
@@ -2071,7 +2071,7 @@ static void sit_add_v4_addrs(struct inet6_dev *idev)
 	struct inet6_ifaddr * ifp;
 	struct in6_addr addr;
 	struct net_device *dev;
-	struct net *net = idev->dev->nd_net;
+	struct net *net = dev_net(idev->dev);
 	int scope;
 
 	ASSERT_RTNL();
@@ -2261,7 +2261,7 @@ ipv6_inherit_linklocal(struct inet6_dev *idev, struct net_device *link_dev)
 static void ip6_tnl_add_linklocal(struct inet6_dev *idev)
 {
 	struct net_device *link_dev;
-	struct net *net = idev->dev->nd_net;
+	struct net *net = dev_net(idev->dev);
 
 	/* first try to inherit the link-local address from the link device */
 	if (idev->dev->iflink &&
@@ -2442,7 +2442,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 {
 	struct inet6_dev *idev;
 	struct inet6_ifaddr *ifa, **bifa;
-	struct net *net = dev->nd_net;
+	struct net *net = dev_net(dev);
 	int i;
 
 	ASSERT_RTNL();
@@ -2771,7 +2771,7 @@ static struct inet6_ifaddr *if6_get_first(struct seq_file *seq)
 	for (state->bucket = 0; state->bucket < IN6_ADDR_HSIZE; ++state->bucket) {
 		ifa = inet6_addr_lst[state->bucket];
 
-		while (ifa && ifa->idev->dev->nd_net != net)
+		while (ifa && dev_net(ifa->idev->dev) != net)
 			ifa = ifa->lst_next;
 		if (ifa)
 			break;
@@ -2787,7 +2787,7 @@ static struct inet6_ifaddr *if6_get_next(struct seq_file *seq, struct inet6_ifad
 	ifa = ifa->lst_next;
 try_again:
 	if (ifa) {
-		if (ifa->idev->dev->nd_net != net) {
+		if (dev_net(ifa->idev->dev) != net) {
 			ifa = ifa->lst_next;
 			goto try_again;
 		}
@@ -2905,7 +2905,7 @@ int ipv6_chk_home_addr(struct net *net, struct in6_addr *addr)
 	u8 hash = ipv6_addr_hash(addr);
 	read_lock_bh(&addrconf_hash_lock);
 	for (ifp = inet6_addr_lst[hash]; ifp; ifp = ifp->lst_next) {
-		if (ifp->idev->dev->nd_net != net)
+		if (dev_net(ifp->idev->dev) != net)
 			continue;
 		if (ipv6_addr_cmp(&ifp->addr, addr) == 0 &&
 		    (ifp->flags & IFA_F_HOMEADDRESS)) {
@@ -3469,7 +3469,7 @@ errout:
 static void inet6_ifa_notify(int event, struct inet6_ifaddr *ifa)
 {
 	struct sk_buff *skb;
-	struct net *net = ifa->idev->dev->nd_net;
+	struct net *net = dev_net(ifa->idev->dev);
 	int err = -ENOBUFS;
 
 	skb = nlmsg_new(inet6_ifaddr_msgsize(), GFP_ATOMIC);
@@ -3675,7 +3675,7 @@ cont:
 void inet6_ifinfo_notify(int event, struct inet6_dev *idev)
 {
 	struct sk_buff *skb;
-	struct net *net = idev->dev->nd_net;
+	struct net *net = dev_net(idev->dev);
 	int err = -ENOBUFS;
 
 	skb = nlmsg_new(inet6_if_nlmsg_size(), GFP_ATOMIC);
@@ -3745,7 +3745,7 @@ static void inet6_prefix_notify(int event, struct inet6_dev *idev,
 			 struct prefix_info *pinfo)
 {
 	struct sk_buff *skb;
-	struct net *net = idev->dev->nd_net;
+	struct net *net = dev_net(idev->dev);
 	int err = -ENOBUFS;
 
 	skb = nlmsg_new(inet6_prefix_nlmsg_size(), GFP_ATOMIC);
@@ -4157,7 +4157,7 @@ static void addrconf_sysctl_register(struct inet6_dev *idev)
 			      NET_IPV6_NEIGH, "ipv6",
 			      &ndisc_ifinfo_sysctl_change,
 			      NULL);
-	__addrconf_sysctl_register(idev->dev->nd_net, idev->dev->name,
+	__addrconf_sysctl_register(dev_net(idev->dev), idev->dev->name,
 			idev->dev->ifindex, idev, &idev->cnf);
 }
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 8633241..5085766 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -306,7 +306,7 @@ static inline void mip6_addr_swap(struct sk_buff *skb) {}
 void icmpv6_send(struct sk_buff *skb, int type, int code, __u32 info,
 		 struct net_device *dev)
 {
-	struct net *net = skb->dev->nd_net;
+	struct net *net = dev_net(skb->dev);
 	struct inet6_dev *idev = NULL;
 	struct ipv6hdr *hdr = ipv6_hdr(skb);
 	struct sock *sk;
@@ -507,7 +507,7 @@ EXPORT_SYMBOL(icmpv6_send);
 
 static void icmpv6_echo_reply(struct sk_buff *skb)
 {
-	struct net *net = skb->dev->nd_net;
+	struct net *net = dev_net(skb->dev);
 	struct sock *sk;
 	struct inet6_dev *idev;
 	struct ipv6_pinfo *np;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d34aa61..556300f 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -402,7 +402,7 @@ int ip6_forward(struct sk_buff *skb)
 	struct dst_entry *dst = skb->dst;
 	struct ipv6hdr *hdr = ipv6_hdr(skb);
 	struct inet6_skb_parm *opt = IP6CB(skb);
-	struct net *net = dst->dev->nd_net;
+	struct net *net = dev_net(dst->dev);
 
 	if (ipv6_devconf.forwarding == 0)
 		goto error;
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 957ac7e..0357de8 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1400,7 +1400,7 @@ mld_scount(struct ifmcaddr6 *pmc, int type, int gdeleted, int sdeleted)
 
 static struct sk_buff *mld_newpack(struct net_device *dev, int size)
 {
-	struct net *net = dev->nd_net;
+	struct net *net = dev_net(dev);
 	struct sock *sk = net->ipv6.igmp_sk;
 	struct sk_buff *skb;
 	struct mld2_report *pmr;
@@ -1448,7 +1448,7 @@ static void mld_sendpack(struct sk_buff *skb)
 			      (struct mld2_report *)skb_transport_header(skb);
 	int payload_len, mldlen;
 	struct inet6_dev *idev = in6_dev_get(skb->dev);
-	struct net *net = skb->dev->nd_net;
+	struct net *net = dev_net(skb->dev);
 	int err;
 	struct flowi fl;
 
@@ -1762,7 +1762,7 @@ static void mld_send_cr(struct inet6_dev *idev)
 
 static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 {
-	struct net *net = dev->nd_net;
+	struct net *net = dev_net(dev);
 	struct sock *sk = net->ipv6.igmp_sk;
 	struct inet6_dev *idev;
 	struct sk_buff *skb;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 3f68a6e..79af57f 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -447,7 +447,7 @@ static void __ndisc_send(struct net_device *dev,
 {
 	struct flowi fl;
 	struct dst_entry *dst;
-	struct net *net = dev->nd_net;
+	struct net *net = dev_net(dev);
 	struct sock *sk = net->ipv6.ndisc_sk;
 	struct sk_buff *skb;
 	struct icmp6hdr *hdr;
@@ -539,7 +539,7 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 	};
 
 	/* for anycast or proxy, solicited_addr != src_addr */
-	ifp = ipv6_get_ifaddr(dev->nd_net, solicited_addr, dev, 1);
+	ifp = ipv6_get_ifaddr(dev_net(dev), solicited_addr, dev, 1);
 	if (ifp) {
 		src_addr = solicited_addr;
 		if (ifp->flags & IFA_F_OPTIMISTIC)
@@ -547,7 +547,7 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 		in6_ifa_put(ifp);
 	} else {
 		if (ipv6_dev_get_saddr(dev, daddr,
-				       inet6_sk(dev->nd_net->ipv6.ndisc_sk)->srcprefs,
+				       inet6_sk(dev_net(dev)->ipv6.ndisc_sk)->srcprefs,
 				       &tmpaddr))
 			return;
 		src_addr = &tmpaddr;
@@ -601,7 +601,7 @@ void ndisc_send_rs(struct net_device *dev, struct in6_addr *saddr,
 	 * suppress the inclusion of the sllao.
 	 */
 	if (send_sllao) {
-		struct inet6_ifaddr *ifp = ipv6_get_ifaddr(dev->nd_net, saddr,
+		struct inet6_ifaddr *ifp = ipv6_get_ifaddr(dev_net(dev), saddr,
 							   dev, 1);
 		if (ifp) {
 			if (ifp->flags & IFA_F_OPTIMISTIC)  {
@@ -639,7 +639,7 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	struct in6_addr *target = (struct in6_addr *)&neigh->primary_key;
 	int probes = atomic_read(&neigh->probes);
 
-	if (skb && ipv6_chk_addr(dev->nd_net, &ipv6_hdr(skb)->saddr, dev, 1))
+	if (skb && ipv6_chk_addr(dev_net(dev), &ipv6_hdr(skb)->saddr, dev, 1))
 		saddr = &ipv6_hdr(skb)->saddr;
 
 	if ((probes -= neigh->parms->ucast_probes) < 0) {
@@ -727,7 +727,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 
 	inc = ipv6_addr_is_multicast(daddr);
 
-	ifp = ipv6_get_ifaddr(dev->nd_net, &msg->target, dev, 1);
+	ifp = ipv6_get_ifaddr(dev_net(dev), &msg->target, dev, 1);
 	if (ifp) {
 
 		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
@@ -776,7 +776,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 		if (ipv6_chk_acast_addr(dev, &msg->target) ||
 		    (idev->cnf.forwarding &&
 		     (ipv6_devconf.proxy_ndp || idev->cnf.proxy_ndp) &&
-		     (pneigh = pneigh_lookup(&nd_tbl, dev->nd_net,
+		     (pneigh = pneigh_lookup(&nd_tbl, dev_net(dev),
 					     &msg->target, dev, 0)) != NULL)) {
 			if (!(NEIGH_CB(skb)->flags & LOCALLY_ENQUEUED) &&
 			    skb->pkt_type != PACKET_HOST &&
@@ -886,7 +886,7 @@ static void ndisc_recv_na(struct sk_buff *skb)
 			return;
 		}
 	}
-	ifp = ipv6_get_ifaddr(dev->nd_net, &msg->target, dev, 1);
+	ifp = ipv6_get_ifaddr(dev_net(dev), &msg->target, dev, 1);
 	if (ifp) {
 		if (ifp->flags & IFA_F_TENTATIVE) {
 			addrconf_dad_failure(ifp);
@@ -918,7 +918,7 @@ static void ndisc_recv_na(struct sk_buff *skb)
 		 */
 		if (lladdr && !memcmp(lladdr, dev->dev_addr, dev->addr_len) &&
 		    ipv6_devconf.forwarding && ipv6_devconf.proxy_ndp &&
-		    pneigh_lookup(&nd_tbl, dev->nd_net, &msg->target, dev, 0)) {
+		    pneigh_lookup(&nd_tbl, dev_net(dev), &msg->target, dev, 0)) {
 			/* XXX: idev->cnf.prixy_ndp */
 			goto out;
 		}
@@ -1008,7 +1008,7 @@ static void ndisc_ra_useropt(struct sk_buff *ra, struct nd_opt_hdr *opt)
 	struct sk_buff *skb;
 	struct nlmsghdr *nlh;
 	struct nduseroptmsg *ndmsg;
-	struct net *net = ra->dev->nd_net;
+	struct net *net = dev_net(ra->dev);
 	int err;
 	int base_size = NLMSG_ALIGN(sizeof(struct nduseroptmsg)
 				    + (opt->nd_opt_len << 3));
@@ -1395,7 +1395,7 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 			 struct in6_addr *target)
 {
 	struct net_device *dev = skb->dev;
-	struct net *net = dev->nd_net;
+	struct net *net = dev_net(dev);
 	struct sock *sk = net->ipv6.ndisc_sk;
 	int len = sizeof(struct icmp6hdr) + 2 * sizeof(struct in6_addr);
 	struct sk_buff *buff;
@@ -1597,7 +1597,7 @@ int ndisc_rcv(struct sk_buff *skb)
 static int ndisc_netdev_event(struct notifier_block *this, unsigned long event, void *ptr)
 {
 	struct net_device *dev = ptr;
-	struct net *net = dev->nd_net;
+	struct net *net = dev_net(dev);
 
 	switch (event) {
 	case NETDEV_CHANGEADDR:
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index cc2f9af..a6d3062 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -484,7 +484,7 @@ ipq_rcv_dev_event(struct notifier_block *this,
 {
 	struct net_device *dev = ptr;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	/* Drop any packets associated with the downed device */
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 8a5be29..364dc33 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -214,7 +214,7 @@ int snmp6_register_dev(struct inet6_dev *idev)
 	if (!idev || !idev->dev)
 		return -EINVAL;
 
-	if (idev->dev->nd_net != &init_net)
+	if (dev_net(idev->dev) != &init_net)
 		return 0;
 
 	if (!proc_net_devsnmp6)
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 548d076..efb0047 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -176,7 +176,7 @@ static int ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 	if (sk == NULL)
 		goto out;
 
-	net = skb->dev->nd_net;
+	net = dev_net(skb->dev);
 	sk = __raw_v6_lookup(net, sk, nexthdr, daddr, saddr, IP6CB(skb)->iif);
 
 	while (sk) {
@@ -363,7 +363,7 @@ void raw6_icmp_error(struct sk_buff *skb, int nexthdr,
 	if (sk != NULL) {
 		saddr = &ipv6_hdr(skb)->saddr;
 		daddr = &ipv6_hdr(skb)->daddr;
-		net = skb->dev->nd_net;
+		net = dev_net(skb->dev);
 
 		while ((sk = __raw_v6_lookup(net, sk, nexthdr, saddr, daddr,
 						IP6CB(skb)->iif))) {
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index f936d04..4e14476 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -600,7 +600,7 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 		return 1;
 	}
 
-	net = skb->dev->nd_net;
+	net = dev_net(skb->dev);
 	if (atomic_read(&net->ipv6.frags.mem) > net->ipv6.frags.high_thresh)
 		ip6_evictor(net, ip6_dst_idev(skb->dst));
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 06faa46..65053fb 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -208,7 +208,7 @@ static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 	struct rt6_info *rt = (struct rt6_info *)dst;
 	struct inet6_dev *idev = rt->rt6i_idev;
 	struct net_device *loopback_dev =
-		dev->nd_net->loopback_dev;
+		dev_net(dev)->loopback_dev;
 
 	if (dev != loopback_dev && idev != NULL && idev->dev == dev) {
 		struct inet6_dev *loopback_idev =
@@ -433,7 +433,7 @@ static struct rt6_info *rt6_select(struct fib6_node *fn, int oif, int strict)
 	RT6_TRACE("%s() => %p\n",
 		  __func__, match);
 
-	net = rt0->rt6i_dev->nd_net;
+	net = dev_net(rt0->rt6i_dev);
 	return (match ? match : net->ipv6.ip6_null_entry);
 }
 
@@ -441,7 +441,7 @@ static struct rt6_info *rt6_select(struct fib6_node *fn, int oif, int strict)
 int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 		  struct in6_addr *gwaddr)
 {
-	struct net *net = dev->nd_net;
+	struct net *net = dev_net(dev);
 	struct route_info *rinfo = (struct route_info *) opt;
 	struct in6_addr prefix_buf, *prefix;
 	unsigned int pref;
@@ -607,7 +607,7 @@ static int __ip6_ins_rt(struct rt6_info *rt, struct nl_info *info)
 int ip6_ins_rt(struct rt6_info *rt)
 {
 	struct nl_info info = {
-		.nl_net = rt->rt6i_dev->nd_net,
+		.nl_net = dev_net(rt->rt6i_dev),
 	};
 	return __ip6_ins_rt(rt, &info);
 }
@@ -745,7 +745,7 @@ static struct rt6_info *ip6_pol_route_input(struct net *net, struct fib6_table *
 void ip6_route_input(struct sk_buff *skb)
 {
 	struct ipv6hdr *iph = ipv6_hdr(skb);
-	struct net *net = skb->dev->nd_net;
+	struct net *net = dev_net(skb->dev);
 	int flags = RT6_LOOKUP_F_HAS_SADDR;
 	struct flowi fl = {
 		.iif = skb->dev->ifindex,
@@ -928,7 +928,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 {
 	struct rt6_info *rt;
 	struct inet6_dev *idev = in6_dev_get(dev);
-	struct net *net = dev->nd_net;
+	struct net *net = dev_net(dev);
 
 	if (unlikely(idev == NULL))
 		return NULL;
@@ -1252,7 +1252,7 @@ install_route:
 	rt->rt6i_idev = idev;
 	rt->rt6i_table = table;
 
-	cfg->fc_nlinfo.nl_net = dev->nd_net;
+	cfg->fc_nlinfo.nl_net = dev_net(dev);
 
 	return __ip6_ins_rt(rt, &cfg->fc_nlinfo);
 
@@ -1270,7 +1270,7 @@ static int __ip6_del_rt(struct rt6_info *rt, struct nl_info *info)
 {
 	int err;
 	struct fib6_table *table;
-	struct net *net = rt->rt6i_dev->nd_net;
+	struct net *net = dev_net(rt->rt6i_dev);
 
 	if (rt == net->ipv6.ip6_null_entry)
 		return -ENOENT;
@@ -1289,7 +1289,7 @@ static int __ip6_del_rt(struct rt6_info *rt, struct nl_info *info)
 int ip6_del_rt(struct rt6_info *rt)
 {
 	struct nl_info info = {
-		.nl_net = rt->rt6i_dev->nd_net,
+		.nl_net = dev_net(rt->rt6i_dev),
 	};
 	return __ip6_del_rt(rt, &info);
 }
@@ -1401,7 +1401,7 @@ static struct rt6_info *ip6_route_redirect(struct in6_addr *dest,
 					   struct net_device *dev)
 {
 	int flags = RT6_LOOKUP_F_HAS_SADDR;
-	struct net *net = dev->nd_net;
+	struct net *net = dev_net(dev);
 	struct ip6rd_flowi rdfl = {
 		.fl = {
 			.oif = dev->ifindex,
@@ -1428,7 +1428,7 @@ void rt6_redirect(struct in6_addr *dest, struct in6_addr *src,
 {
 	struct rt6_info *rt, *nrt = NULL;
 	struct netevent_redirect netevent;
-	struct net *net = neigh->dev->nd_net;
+	struct net *net = dev_net(neigh->dev);
 
 	rt = ip6_route_redirect(dest, src, saddr, neigh->dev);
 
@@ -1477,7 +1477,7 @@ void rt6_redirect(struct in6_addr *dest, struct in6_addr *src,
 	nrt->rt6i_nexthop = neigh_clone(neigh);
 	/* Reset pmtu, it may be better */
 	nrt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(neigh->dev);
-	nrt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(neigh->dev->nd_net,
+	nrt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dev_net(neigh->dev),
 							dst_mtu(&nrt->u.dst));
 
 	if (ip6_ins_rt(nrt))
@@ -1506,7 +1506,7 @@ void rt6_pmtu_discovery(struct in6_addr *daddr, struct in6_addr *saddr,
 			struct net_device *dev, u32 pmtu)
 {
 	struct rt6_info *rt, *nrt;
-	struct net *net = dev->nd_net;
+	struct net *net = dev_net(dev);
 	int allfrag = 0;
 
 	rt = rt6_lookup(net, daddr, saddr, dev->ifindex, 0);
@@ -1583,7 +1583,7 @@ out:
 
 static struct rt6_info * ip6_rt_copy(struct rt6_info *ort)
 {
-	struct net *net = ort->rt6i_dev->nd_net;
+	struct net *net = dev_net(ort->rt6i_dev);
 	struct rt6_info *rt = ip6_dst_alloc(net->ipv6.ip6_dst_ops);
 
 	if (rt) {
@@ -1682,7 +1682,7 @@ struct rt6_info *rt6_get_dflt_router(struct in6_addr *addr, struct net_device *d
 	struct rt6_info *rt;
 	struct fib6_table *table;
 
-	table = fib6_get_table(dev->nd_net, RT6_TABLE_DFLT);
+	table = fib6_get_table(dev_net(dev), RT6_TABLE_DFLT);
 	if (table == NULL)
 		return NULL;
 
@@ -1713,7 +1713,7 @@ struct rt6_info *rt6_add_dflt_router(struct in6_addr *gwaddr,
 				  RTF_UP | RTF_EXPIRES | RTF_PREF(pref),
 		.fc_nlinfo.pid = 0,
 		.fc_nlinfo.nlh = NULL,
-		.fc_nlinfo.nl_net = dev->nd_net,
+		.fc_nlinfo.nl_net = dev_net(dev),
 	};
 
 	ipv6_addr_copy(&cfg.fc_gateway, gwaddr);
@@ -1862,7 +1862,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 				    const struct in6_addr *addr,
 				    int anycast)
 {
-	struct net *net = idev->dev->nd_net;
+	struct net *net = dev_net(idev->dev);
 	struct rt6_info *rt = ip6_dst_alloc(net->ipv6.ip6_dst_ops);
 
 	if (rt == NULL)
@@ -1939,7 +1939,7 @@ static int rt6_mtu_change_route(struct rt6_info *rt, void *p_arg)
 {
 	struct rt6_mtu_change_arg *arg = (struct rt6_mtu_change_arg *) p_arg;
 	struct inet6_dev *idev;
-	struct net *net = arg->dev->nd_net;
+	struct net *net = dev_net(arg->dev);
 
 	/* In IPv6 pmtu discovery is not optional,
 	   so that RTAX_MTU lock cannot disable it.
@@ -1983,7 +1983,7 @@ void rt6_mtu_change(struct net_device *dev, unsigned mtu)
 		.mtu = mtu,
 	};
 
-	fib6_clean_all(dev->nd_net, rt6_mtu_change_route, 0, &arg);
+	fib6_clean_all(dev_net(dev), rt6_mtu_change_route, 0, &arg);
 }
 
 static const struct nla_policy rtm_ipv6_policy[RTA_MAX+1] = {
@@ -2321,7 +2321,7 @@ static int ip6_route_dev_notify(struct notifier_block *this,
 				unsigned long event, void *data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct net *net = dev->nd_net;
+	struct net *net = dev_net(dev);
 
 	if (event == NETDEV_REGISTER && (dev->flags & IFF_LOOPBACK)) {
 		net->ipv6.ip6_null_entry->u.dst.dev = dev;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 8dd7296..086deff 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -321,7 +321,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	struct tcp_sock *tp;
 	__u32 seq;
 
-	sk = inet6_lookup(skb->dev->nd_net, &tcp_hashinfo, &hdr->daddr,
+	sk = inet6_lookup(dev_net(skb->dev), &tcp_hashinfo, &hdr->daddr,
 			th->dest, &hdr->saddr, th->source, skb->dev->ifindex);
 
 	if (sk == NULL) {
@@ -988,7 +988,7 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 	struct tcphdr *th = tcp_hdr(skb), *t1;
 	struct sk_buff *buff;
 	struct flowi fl;
-	struct net *net = skb->dst->dev->nd_net;
+	struct net *net = dev_net(skb->dst->dev);
 	struct sock *ctl_sk = net->ipv6.tcp_sk;
 	unsigned int tot_len = sizeof(*th);
 #ifdef CONFIG_TCP_MD5SIG
@@ -1093,7 +1093,7 @@ static void tcp_v6_send_ack(struct tcp_timewait_sock *tw,
 	struct tcphdr *th = tcp_hdr(skb), *t1;
 	struct sk_buff *buff;
 	struct flowi fl;
-	struct net *net = skb->dev->nd_net;
+	struct net *net = dev_net(skb->dev);
 	struct sock *ctl_sk = net->ipv6.tcp_sk;
 	unsigned int tot_len = sizeof(struct tcphdr);
 	__be32 *topt;
@@ -1739,7 +1739,7 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 	TCP_SKB_CB(skb)->flags = ipv6_get_dsfield(ipv6_hdr(skb));
 	TCP_SKB_CB(skb)->sacked = 0;
 
-	sk = __inet6_lookup(skb->dev->nd_net, &tcp_hashinfo,
+	sk = __inet6_lookup(dev_net(skb->dev), &tcp_hashinfo,
 			&ipv6_hdr(skb)->saddr, th->source,
 			&ipv6_hdr(skb)->daddr, ntohs(th->dest),
 			inet6_iif(skb));
@@ -1822,7 +1822,7 @@ do_time_wait:
 	{
 		struct sock *sk2;
 
-		sk2 = inet6_lookup_listener(skb->dev->nd_net, &tcp_hashinfo,
+		sk2 = inet6_lookup_listener(dev_net(skb->dev), &tcp_hashinfo,
 					    &ipv6_hdr(skb)->daddr,
 					    ntohs(th->dest), inet6_iif(skb));
 		if (sk2 != NULL) {
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 593d3ef..6683c04 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -235,7 +235,7 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	struct sock *sk;
 	int err;
 
-	sk = __udp6_lib_lookup(skb->dev->nd_net, daddr, uh->dest,
+	sk = __udp6_lib_lookup(dev_net(skb->dev), daddr, uh->dest,
 			       saddr, uh->source, inet6_iif(skb), udptable);
 	if (sk == NULL)
 		return;
@@ -483,7 +483,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 	 * check socket cache ... must talk to Alan about his plans
 	 * for sock caches... i'll skip this for now.
 	 */
-	sk = __udp6_lib_lookup(skb->dev->nd_net, saddr, uh->source,
+	sk = __udp6_lib_lookup(dev_net(skb->dev), saddr, uh->source,
 			       daddr, uh->dest, inet6_iif(skb), udptable);
 
 	if (sk == NULL) {
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index d92d1fc..8f1e054 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -247,7 +247,7 @@ static void xfrm6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 	xdst = (struct xfrm_dst *)dst;
 	if (xdst->u.rt6.rt6i_idev->dev == dev) {
 		struct inet6_dev *loopback_idev =
-			in6_dev_get(dev->nd_net->loopback_dev);
+			in6_dev_get(dev_net(dev)->loopback_dev);
 		BUG_ON(!loopback_idev);
 
 		do {
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index c76a952..81ae873 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -335,7 +335,7 @@ static int ipxitf_device_event(struct notifier_block *notifier,
 	struct net_device *dev = ptr;
 	struct ipx_interface *i, *tmp;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	if (event != NETDEV_DOWN && event != NETDEV_UP)
@@ -1636,7 +1636,7 @@ static int ipx_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_ty
 	u16 ipx_pktsize;
 	int rc = 0;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		goto drop;
 
 	/* Not ours */
diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index a38b231..9089453 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -1326,7 +1326,7 @@ int irlap_driver_rcv(struct sk_buff *skb, struct net_device *dev,
 	int command;
 	__u8 control;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		goto out;
 
 	/* FIXME: should we get our own field? */
diff --git a/net/llc/llc_input.c b/net/llc/llc_input.c
index b9143d2..a69c5c4 100644
--- a/net/llc/llc_input.c
+++ b/net/llc/llc_input.c
@@ -146,7 +146,7 @@ int llc_rcv(struct sk_buff *skb, struct net_device *dev,
 	int (*rcv)(struct sk_buff *, struct net_device *,
 		   struct packet_type *, struct net_device *);
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		goto drop;
 
 	/*
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index ec05684..292fa28 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -168,7 +168,7 @@ int nf_hook_slow(int pf, unsigned int hook, struct sk_buff *skb,
 #ifdef CONFIG_NET_NS
 	struct net *net;
 
-	net = indev == NULL ? outdev->nd_net : indev->nd_net;
+	net = indev == NULL ? dev_net(outdev) : dev_net(indev);
 	if (net != &init_net)
 		return 1;
 #endif
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 012cb69..81fb048 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -557,7 +557,7 @@ nfqnl_rcv_dev_event(struct notifier_block *this,
 {
 	struct net_device *dev = ptr;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	/* Drop any packets associated with the downed device */
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 4478f2f..a547c63 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -954,7 +954,7 @@ static int netlbl_unlhsh_netdev_handler(struct notifier_block *this,
 	struct net_device *dev = ptr;
 	struct netlbl_unlhsh_iface *iface = NULL;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	/* XXX - should this be a check for NETDEV_DOWN or _UNREGISTER? */
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 972250c..a270ebf 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -106,7 +106,7 @@ static int nr_device_event(struct notifier_block *this, unsigned long event, voi
 {
 	struct net_device *dev = (struct net_device *)ptr;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	if (event != NETDEV_DOWN)
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index a56ed21..baa290d 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -263,7 +263,7 @@ static int packet_rcv_spkt(struct sk_buff *skb, struct net_device *dev,  struct
 	if (skb->pkt_type == PACKET_LOOPBACK)
 		goto out;
 
-	if (dev->nd_net != sk->sk_net)
+	if (dev_net(dev) != sk->sk_net)
 		goto out;
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
@@ -451,7 +451,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 	sk = pt->af_packet_priv;
 	po = pkt_sk(sk);
 
-	if (dev->nd_net != sk->sk_net)
+	if (dev_net(dev) != sk->sk_net)
 		goto drop;
 
 	skb->dev = dev;
@@ -568,7 +568,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev, struct packe
 	sk = pt->af_packet_priv;
 	po = pkt_sk(sk);
 
-	if (dev->nd_net != sk->sk_net)
+	if (dev_net(dev) != sk->sk_net)
 		goto drop;
 
 	if (dev->header_ops) {
@@ -1450,7 +1450,7 @@ static int packet_notifier(struct notifier_block *this, unsigned long msg, void
 	struct sock *sk;
 	struct hlist_node *node;
 	struct net_device *dev = data;
-	struct net *net = dev->nd_net;
+	struct net *net = dev_net(dev);
 
 	read_lock(&net->packet.sklist_lock);
 	sk_for_each(sk, node, &net->packet.sklist) {
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 4a31a81..1a7f143 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -197,7 +197,7 @@ static int rose_device_event(struct notifier_block *this, unsigned long event,
 {
 	struct net_device *dev = (struct net_device *)ptr;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	if (event != NETDEV_DOWN)
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index beea2fb..2faa0d8 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -630,7 +630,7 @@ static int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
 	struct sctp_sockaddr_entry *temp;
 	int found = 0;
 
-	if (ifa->ifa_dev->dev->nd_net != &init_net)
+	if (dev_net(ifa->ifa_dev->dev) != &init_net)
 		return NOTIFY_DONE;
 
 	switch (ev) {
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 3bbef2a..9cd35ee 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -101,7 +101,7 @@ static int recv_msg(struct sk_buff *buf, struct net_device *dev,
 	struct eth_bearer *eb_ptr = (struct eth_bearer *)pt->af_packet_priv;
 	u32 size;
 
-	if (dev->nd_net != &init_net) {
+	if (dev_net(dev) != &init_net) {
 		kfree_skb(buf);
 		return 0;
 	}
@@ -198,7 +198,7 @@ static int recv_notification(struct notifier_block *nb, unsigned long evt,
 	struct eth_bearer *eb_ptr = &eth_bearers[0];
 	struct eth_bearer *stop = &eth_bearers[MAX_ETH_BEARERS];
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	while ((eb_ptr->dev != dev)) {
diff --git a/net/wireless/wext.c b/net/wireless/wext.c
index 2c569b6..947188a 100644
--- a/net/wireless/wext.c
+++ b/net/wireless/wext.c
@@ -1157,7 +1157,7 @@ static void rtmsg_iwinfo(struct net_device *dev, char *event, int event_len)
 	struct sk_buff *skb;
 	int err;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return;
 
 	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 339ca4a..7a46ea7 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -191,7 +191,7 @@ static int x25_device_event(struct notifier_block *this, unsigned long event,
 	struct net_device *dev = ptr;
 	struct x25_neigh *nb;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	if (dev->type == ARPHRD_X25
diff --git a/net/x25/x25_dev.c b/net/x25/x25_dev.c
index f0679d2..3ff206c 100644
--- a/net/x25/x25_dev.c
+++ b/net/x25/x25_dev.c
@@ -95,7 +95,7 @@ int x25_lapb_receive_frame(struct sk_buff *skb, struct net_device *dev,
 	struct sk_buff *nskb;
 	struct x25_neigh *nb;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		goto drop;
 
 	nskb = skb_copy(skb, GFP_ATOMIC);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 8e588f2..15d73e4 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2079,7 +2079,7 @@ static int stale_bundle(struct dst_entry *dst)
 void xfrm_dst_ifdown(struct dst_entry *dst, struct net_device *dev)
 {
 	while ((dst = dst->child) && dst->xfrm && dst->dev == dev) {
-		dst->dev = dev->nd_net->loopback_dev;
+		dst->dev = dev_net(dev)->loopback_dev;
 		dev_hold(dst->dev);
 		dev_put(dev);
 	}
@@ -2350,7 +2350,7 @@ static int xfrm_dev_event(struct notifier_block *this, unsigned long event, void
 {
 	struct net_device *dev = ptr;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	switch (event) {
diff --git a/security/selinux/netif.c b/security/selinux/netif.c
index 013d311..9c8a82a 100644
--- a/security/selinux/netif.c
+++ b/security/selinux/netif.c
@@ -281,7 +281,7 @@ static int sel_netif_netdev_notifier_handler(struct notifier_block *this,
 {
 	struct net_device *dev = ptr;
 
-	if (dev->nd_net != &init_net)
+	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
 	if (event == NETDEV_DOWN)
-- 
1.4.4.4

