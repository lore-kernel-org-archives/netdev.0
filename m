From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6 1/4] netns: Use net_eq() to compare net-namespaces
 for optimization.
Date: Sun, 20 Jul 2008 14:21:24 +0900 (JST)
Message-ID: <20080720.142124.132056009.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32812 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116AbYGTFV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 01:21:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without CONFIG_NET_NS, namespace is always &init_net.
Compiler will be able to omit namespace comparisons with this patch.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/appletalk/aarp.c                |    4 ++--
 net/appletalk/ddp.c                 |    6 +++---
 net/atm/clip.c                      |    2 +-
 net/atm/mpc.c                       |    2 +-
 net/ax25/af_ax25.c                  |    2 +-
 net/ax25/ax25_in.c                  |    2 +-
 net/bridge/br_notify.c              |    2 +-
 net/bridge/br_stp_bpdu.c            |    2 +-
 net/can/af_can.c                    |    4 ++--
 net/can/bcm.c                       |    2 +-
 net/can/raw.c                       |    2 +-
 net/core/pktgen.c                   |    2 +-
 net/decnet/af_decnet.c              |    2 +-
 net/decnet/dn_route.c               |    2 +-
 net/econet/af_econet.c              |    4 ++--
 net/ipv4/igmp.c                     |   26 +++++++++++++-------------
 net/ipv4/ipconfig.c                 |    4 ++--
 net/ipv4/ipmr.c                     |    2 +-
 net/ipv4/netfilter/ip_queue.c       |    2 +-
 net/ipv4/netfilter/ipt_MASQUERADE.c |    2 +-
 net/ipv6/ip6mr.c                    |    2 +-
 net/ipv6/netfilter/ip6_queue.c      |    2 +-
 net/ipv6/proc.c                     |    2 +-
 net/ipx/af_ipx.c                    |    4 ++--
 net/irda/irlap_frame.c              |    2 +-
 net/llc/llc_input.c                 |    2 +-
 net/netfilter/nf_sockopt.c          |    2 +-
 net/netfilter/nfnetlink_queue.c     |    2 +-
 net/netlabel/netlabel_unlabeled.c   |    2 +-
 net/netrom/af_netrom.c              |    2 +-
 net/packet/af_packet.c              |    2 +-
 net/rose/af_rose.c                  |    2 +-
 net/sctp/protocol.c                 |    2 +-
 net/tipc/eth_media.c                |    4 ++--
 net/wireless/wext.c                 |    2 +-
 net/x25/af_x25.c                    |    2 +-
 net/x25/x25_dev.c                   |    2 +-
 net/xfrm/xfrm_policy.c              |    2 +-
 38 files changed, 58 insertions(+), 58 deletions(-)

diff --git a/net/appletalk/aarp.c b/net/appletalk/aarp.c
index 25aa37c..b25c1e9 100644
--- a/net/appletalk/aarp.c
+++ b/net/appletalk/aarp.c
@@ -333,7 +333,7 @@ static int aarp_device_event(struct notifier_block *this, unsigned long event,
 	struct net_device *dev = ptr;
 	int ct;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	if (event == NETDEV_DOWN) {
@@ -716,7 +716,7 @@ static int aarp_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct atalk_addr sa, *ma, da;
 	struct atalk_iface *ifa;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		goto out0;
 
 	/* We only do Ethernet SNAP AARP. */
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 44cd42f..07b5b82 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -648,7 +648,7 @@ static int ddp_device_event(struct notifier_block *this, unsigned long event,
 {
 	struct net_device *dev = ptr;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	if (event == NETDEV_DOWN)
@@ -1405,7 +1405,7 @@ static int atalk_rcv(struct sk_buff *skb, struct net_device *dev,
 	int origlen;
 	__u16 len_hops;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		goto freeit;
 
 	/* Don't mangle buffer if shared */
@@ -1493,7 +1493,7 @@ freeit:
 static int ltalk_rcv(struct sk_buff *skb, struct net_device *dev,
 		     struct packet_type *pt, struct net_device *orig_dev)
 {
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		goto freeit;
 
 	/* Expand any short form frames */
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 6f8223e..5b5b963 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -612,7 +612,7 @@ static int clip_device_event(struct notifier_block *this, unsigned long event,
 {
 	struct net_device *dev = arg;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	if (event == NETDEV_UNREGISTER) {
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 9db332e..4fccaa1 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -964,7 +964,7 @@ static int mpoa_event_listener(struct notifier_block *mpoa_notifier, unsigned lo
 
 	dev = (struct net_device *)dev_ptr;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	if (dev->name == NULL || strncmp(dev->name, "lec", 3))
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 97eaa23..01c83e2 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -116,7 +116,7 @@ static int ax25_device_event(struct notifier_block *this, unsigned long event,
 {
 	struct net_device *dev = (struct net_device *)ptr;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	/* Reject non AX.25 devices */
diff --git a/net/ax25/ax25_in.c b/net/ax25/ax25_in.c
index 33790a8..4a5ba97 100644
--- a/net/ax25/ax25_in.c
+++ b/net/ax25/ax25_in.c
@@ -451,7 +451,7 @@ int ax25_kiss_rcv(struct sk_buff *skb, struct net_device *dev,
 	skb->sk = NULL;		/* Initially we don't know who it's for */
 	skb->destructor = NULL;	/* Who initializes this, dammit?! */
 
-	if (dev_net(dev) != &init_net) {
+	if (!net_eq(dev_net(dev), &init_net)) {
 		kfree_skb(skb);
 		return 0;
 	}
diff --git a/net/bridge/br_notify.c b/net/bridge/br_notify.c
index 88d8ec7..76340bd 100644
--- a/net/bridge/br_notify.c
+++ b/net/bridge/br_notify.c
@@ -35,7 +35,7 @@ static int br_device_event(struct notifier_block *unused, unsigned long event, v
 	struct net_bridge_port *p = dev->br_port;
 	struct net_bridge *br;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	/* not a port of a bridge */
diff --git a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
index 9964761..8b200f9 100644
--- a/net/bridge/br_stp_bpdu.c
+++ b/net/bridge/br_stp_bpdu.c
@@ -140,7 +140,7 @@ void br_stp_rcv(const struct stp_proto *proto, struct sk_buff *skb,
 	struct net_bridge *br;
 	const unsigned char *buf;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		goto err;
 
 	if (!p)
diff --git a/net/can/af_can.c b/net/can/af_can.c
index 484bbf6..8035fbf 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -615,7 +615,7 @@ static int can_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct can_frame *cf = (struct can_frame *)skb->data;
 	int matches;
 
-	if (dev->type != ARPHRD_CAN || dev_net(dev) != &init_net) {
+	if (dev->type != ARPHRD_CAN || !net_eq(dev_net(dev), &init_net)) {
 		kfree_skb(skb);
 		return 0;
 	}
@@ -728,7 +728,7 @@ static int can_notifier(struct notifier_block *nb, unsigned long msg,
 	struct net_device *dev = (struct net_device *)data;
 	struct dev_rcv_lists *d;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	if (dev->type != ARPHRD_CAN)
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 72c2ce9..d0dd382 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1303,7 +1303,7 @@ static int bcm_notifier(struct notifier_block *nb, unsigned long msg,
 	struct bcm_op *op;
 	int notify_enodev = 0;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	if (dev->type != ARPHRD_CAN)
diff --git a/net/can/raw.c b/net/can/raw.c
index 3e46ee3..6e0663f 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -210,7 +210,7 @@ static int raw_notifier(struct notifier_block *nb,
 	struct raw_sock *ro = container_of(nb, struct raw_sock, notifier);
 	struct sock *sk = &ro->sk;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	if (dev->type != ARPHRD_CAN)
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 906802d..c7d484f 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1875,7 +1875,7 @@ static int pktgen_device_event(struct notifier_block *unused,
 {
 	struct net_device *dev = ptr;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	/* It is OK that we do not hold the group lock right now,
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 61b7df5..3c23ab3 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -2089,7 +2089,7 @@ static int dn_device_event(struct notifier_block *this, unsigned long event,
 {
 	struct net_device *dev = (struct net_device *)ptr;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	switch(event) {
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index f50e88b..821bd1c 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -580,7 +580,7 @@ int dn_route_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type
 	struct dn_dev *dn = (struct dn_dev *)dev->dn_ptr;
 	unsigned char padlen = 0;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		goto dump_it;
 
 	if (dn == NULL)
diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index d35127b..8789d2b 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -1062,7 +1062,7 @@ static int econet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 	struct sock *sk;
 	struct ec_device *edev = dev->ec_ptr;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		goto drop;
 
 	if (skb->pkt_type == PACKET_OTHERHOST)
@@ -1119,7 +1119,7 @@ static int econet_notifier(struct notifier_block *this, unsigned long msg, void
 	struct net_device *dev = (struct net_device *)data;
 	struct ec_device *edev;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	switch (msg) {
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 68e84a9..6203ece 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1196,7 +1196,7 @@ void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 
 	ASSERT_RTNL();
 
-	if (dev_net(in_dev->dev) != &init_net)
+	if (!net_eq(dev_net(in_dev->dev), &init_net))
 		return;
 
 	for (im=in_dev->mc_list; im; im=im->next) {
@@ -1278,7 +1278,7 @@ void ip_mc_dec_group(struct in_device *in_dev, __be32 addr)
 
 	ASSERT_RTNL();
 
-	if (dev_net(in_dev->dev) != &init_net)
+	if (!net_eq(dev_net(in_dev->dev), &init_net))
 		return;
 
 	for (ip=&in_dev->mc_list; (i=*ip)!=NULL; ip=&i->next) {
@@ -1308,7 +1308,7 @@ void ip_mc_down(struct in_device *in_dev)
 
 	ASSERT_RTNL();
 
-	if (dev_net(in_dev->dev) != &init_net)
+	if (!net_eq(dev_net(in_dev->dev), &init_net))
 		return;
 
 	for (i=in_dev->mc_list; i; i=i->next)
@@ -1331,7 +1331,7 @@ void ip_mc_init_dev(struct in_device *in_dev)
 {
 	ASSERT_RTNL();
 
-	if (dev_net(in_dev->dev) != &init_net)
+	if (!net_eq(dev_net(in_dev->dev), &init_net))
 		return;
 
 	in_dev->mc_tomb = NULL;
@@ -1357,7 +1357,7 @@ void ip_mc_up(struct in_device *in_dev)
 
 	ASSERT_RTNL();
 
-	if (dev_net(in_dev->dev) != &init_net)
+	if (!net_eq(dev_net(in_dev->dev), &init_net))
 		return;
 
 	ip_mc_inc_group(in_dev, IGMP_ALL_HOSTS);
@@ -1376,7 +1376,7 @@ void ip_mc_destroy_dev(struct in_device *in_dev)
 
 	ASSERT_RTNL();
 
-	if (dev_net(in_dev->dev) != &init_net)
+	if (!net_eq(dev_net(in_dev->dev), &init_net))
 		return;
 
 	/* Deactivate timers */
@@ -1760,7 +1760,7 @@ int ip_mc_join_group(struct sock *sk , struct ip_mreqn *imr)
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	if (sock_net(sk) != &init_net)
+	if (!net_eq(sock_net(sk), &init_net))
 		return -EPROTONOSUPPORT;
 
 	rtnl_lock();
@@ -1831,7 +1831,7 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 	u32 ifindex;
 	int ret = -EADDRNOTAVAIL;
 
-	if (sock_net(sk) != &init_net)
+	if (!net_eq(sock_net(sk), &init_net))
 		return -EPROTONOSUPPORT;
 
 	rtnl_lock();
@@ -1879,7 +1879,7 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	if (sock_net(sk) != &init_net)
+	if (!net_eq(sock_net(sk), &init_net))
 		return -EPROTONOSUPPORT;
 
 	rtnl_lock();
@@ -2015,7 +2015,7 @@ int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf, int ifindex)
 	    msf->imsf_fmode != MCAST_EXCLUDE)
 		return -EINVAL;
 
-	if (sock_net(sk) != &init_net)
+	if (!net_eq(sock_net(sk), &init_net))
 		return -EPROTONOSUPPORT;
 
 	rtnl_lock();
@@ -2098,7 +2098,7 @@ int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	if (sock_net(sk) != &init_net)
+	if (!net_eq(sock_net(sk), &init_net))
 		return -EPROTONOSUPPORT;
 
 	rtnl_lock();
@@ -2163,7 +2163,7 @@ int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	if (sock_net(sk) != &init_net)
+	if (!net_eq(sock_net(sk), &init_net))
 		return -EPROTONOSUPPORT;
 
 	rtnl_lock();
@@ -2250,7 +2250,7 @@ void ip_mc_drop_socket(struct sock *sk)
 	if (inet->mc_list == NULL)
 		return;
 
-	if (sock_net(sk) != &init_net)
+	if (!net_eq(sock_net(sk), &init_net))
 		return;
 
 	rtnl_lock();
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index b88aa9a..42065ff 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -432,7 +432,7 @@ ic_rarp_recv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	unsigned char *sha, *tha;		/* s for "source", t for "target" */
 	struct ic_device *d;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		goto drop;
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
@@ -852,7 +852,7 @@ static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, str
 	struct ic_device *d;
 	int len, ext_len;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		goto drop;
 
 	/* Perform verifications before taking the lock.  */
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 033c712..c519b8d 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1124,7 +1124,7 @@ static int ipmr_device_event(struct notifier_block *this, unsigned long event, v
 	struct vif_device *v;
 	int ct;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	if (event != NETDEV_UNREGISTER)
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index aa33a4a..432ce9d 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -477,7 +477,7 @@ ipq_rcv_dev_event(struct notifier_block *this,
 {
 	struct net_device *dev = ptr;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	/* Drop any packets associated with the downed device */
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index 84c26dd..0841aef 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -120,7 +120,7 @@ static int masq_device_event(struct notifier_block *this,
 {
 	const struct net_device *dev = ptr;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	if (event == NETDEV_DOWN) {
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 0b41aa2..095bc45 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -935,7 +935,7 @@ static int ip6mr_device_event(struct notifier_block *this,
 	struct mif_device *v;
 	int ct;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	if (event != NETDEV_UNREGISTER)
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 1b8815f..5859c04 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -480,7 +480,7 @@ ipq_rcv_dev_event(struct notifier_block *this,
 {
 	struct net_device *dev = ptr;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	/* Drop any packets associated with the downed device */
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 70940b3..f82f607 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -214,7 +214,7 @@ int snmp6_register_dev(struct inet6_dev *idev)
 	if (!idev || !idev->dev)
 		return -EINVAL;
 
-	if (dev_net(idev->dev) != &init_net)
+	if (!net_eq(dev_net(idev->dev), &init_net))
 		return 0;
 
 	if (!proc_net_devsnmp6)
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 81ae873..b6e70f9 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -335,7 +335,7 @@ static int ipxitf_device_event(struct notifier_block *notifier,
 	struct net_device *dev = ptr;
 	struct ipx_interface *i, *tmp;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	if (event != NETDEV_DOWN && event != NETDEV_UP)
@@ -1636,7 +1636,7 @@ static int ipx_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_ty
 	u16 ipx_pktsize;
 	int rc = 0;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		goto drop;
 
 	/* Not ours */
diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index 9089453..f17b65a 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -1326,7 +1326,7 @@ int irlap_driver_rcv(struct sk_buff *skb, struct net_device *dev,
 	int command;
 	__u8 control;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		goto out;
 
 	/* FIXME: should we get our own field? */
diff --git a/net/llc/llc_input.c b/net/llc/llc_input.c
index 1c45f17..57ad974 100644
--- a/net/llc/llc_input.c
+++ b/net/llc/llc_input.c
@@ -150,7 +150,7 @@ int llc_rcv(struct sk_buff *skb, struct net_device *dev,
 	int (*rcv)(struct sk_buff *, struct net_device *,
 		   struct packet_type *, struct net_device *);
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		goto drop;
 
 	/*
diff --git a/net/netfilter/nf_sockopt.c b/net/netfilter/nf_sockopt.c
index 69d699f..0148968 100644
--- a/net/netfilter/nf_sockopt.c
+++ b/net/netfilter/nf_sockopt.c
@@ -65,7 +65,7 @@ static struct nf_sockopt_ops *nf_sockopt_find(struct sock *sk, int pf,
 {
 	struct nf_sockopt_ops *ops;
 
-	if (sock_net(sk) != &init_net)
+	if (!net_eq(sock_net(sk), &init_net))
 		return ERR_PTR(-ENOPROTOOPT);
 
 	if (mutex_lock_interruptible(&nf_sockopt_mutex) != 0)
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 04e9c96..8c86011 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -555,7 +555,7 @@ nfqnl_rcv_dev_event(struct notifier_block *this,
 {
 	struct net_device *dev = ptr;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	/* Drop any packets associated with the downed device */
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 56f8087..921c118 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -954,7 +954,7 @@ static int netlbl_unlhsh_netdev_handler(struct notifier_block *this,
 	struct net_device *dev = ptr;
 	struct netlbl_unlhsh_iface *iface = NULL;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	/* XXX - should this be a check for NETDEV_DOWN or _UNREGISTER? */
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index d41be0d..fccc250 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -118,7 +118,7 @@ static int nr_device_event(struct notifier_block *this, unsigned long event, voi
 {
 	struct net_device *dev = (struct net_device *)ptr;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	if (event != NETDEV_DOWN)
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index de73bcb..d56cae1 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1677,7 +1677,7 @@ static int packet_ioctl(struct socket *sock, unsigned int cmd,
 		case SIOCGIFDSTADDR:
 		case SIOCSIFDSTADDR:
 		case SIOCSIFFLAGS:
-			if (sock_net(sk) != &init_net)
+			if (!net_eq(sock_net(sk), &init_net))
 				return -ENOIOCTLCMD;
 			return inet_dgram_ops.ioctl(sock, cmd, arg);
 #endif
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index f3a691f..dbc963b 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -209,7 +209,7 @@ static int rose_device_event(struct notifier_block *this, unsigned long event,
 {
 	struct net_device *dev = (struct net_device *)ptr;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	if (event != NETDEV_DOWN)
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index ed9acff..a6e0818 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -668,7 +668,7 @@ static int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
 	struct sctp_sockaddr_entry *temp;
 	int found = 0;
 
-	if (dev_net(ifa->ifa_dev->dev) != &init_net)
+	if (!net_eq(dev_net(ifa->ifa_dev->dev), &init_net))
 		return NOTIFY_DONE;
 
 	switch (ev) {
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index bc72fbc..fe43ef7 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -101,7 +101,7 @@ static int recv_msg(struct sk_buff *buf, struct net_device *dev,
 	struct eth_bearer *eb_ptr = (struct eth_bearer *)pt->af_packet_priv;
 	u32 size;
 
-	if (dev_net(dev) != &init_net) {
+	if (!net_eq(dev_net(dev), &init_net)) {
 		kfree_skb(buf);
 		return 0;
 	}
@@ -198,7 +198,7 @@ static int recv_notification(struct notifier_block *nb, unsigned long evt,
 	struct eth_bearer *eb_ptr = &eth_bearers[0];
 	struct eth_bearer *stop = &eth_bearers[MAX_ETH_BEARERS];
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	while ((eb_ptr->dev != dev)) {
diff --git a/net/wireless/wext.c b/net/wireless/wext.c
index 273a843..df5b388 100644
--- a/net/wireless/wext.c
+++ b/net/wireless/wext.c
@@ -1299,7 +1299,7 @@ static void rtmsg_iwinfo(struct net_device *dev, char *event, int event_len)
 	struct sk_buff *skb;
 	int err;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return;
 
 	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 7b1c6ef..9fc5b02 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -191,7 +191,7 @@ static int x25_device_event(struct notifier_block *this, unsigned long event,
 	struct net_device *dev = ptr;
 	struct x25_neigh *nb;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	if (dev->type == ARPHRD_X25
diff --git a/net/x25/x25_dev.c b/net/x25/x25_dev.c
index 3ff206c..3e1efe5 100644
--- a/net/x25/x25_dev.c
+++ b/net/x25/x25_dev.c
@@ -95,7 +95,7 @@ int x25_lapb_receive_frame(struct sk_buff *skb, struct net_device *dev,
 	struct sk_buff *nskb;
 	struct x25_neigh *nb;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		goto drop;
 
 	nskb = skb_copy(skb, GFP_ATOMIC);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index cae9fd8..841b32a 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2360,7 +2360,7 @@ static int xfrm_dev_event(struct notifier_block *this, unsigned long event, void
 {
 	struct net_device *dev = ptr;
 
-	if (dev_net(dev) != &init_net)
+	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
 	switch (event) {
-- 
1.4.4.4

