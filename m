From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2 02/16] net: change netdev->features to u32
Date: Sat, 22 Jan 2011 23:14:12 +0100 (CET)
Message-ID: <d9fe088556152bd3b43390e0fb5ea20d83aef233.1295734271.git.mirq-linux@rere.qmqm.pl>
References: <cover.1295734270.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43051 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751175Ab1AVWOP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jan 2011 17:14:15 -0500
In-Reply-To: <cover.1295734270.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Ben Hutchings: we presumably won't be defining features that
can only be enabled on 64-bit architectures.

Occurences found by `grep -r` on net/, drivers/net, include/

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/bnx2.c              |    2 +-
 drivers/net/bonding/bond_main.c |    4 ++--
 drivers/net/myri10ge/myri10ge.c |    4 ++--
 drivers/net/sfc/ethtool.c       |    4 ++--
 drivers/net/sfc/net_driver.h    |    2 +-
 drivers/net/tun.c               |    2 +-
 include/linux/netdevice.h       |   19 +++++++++----------
 include/linux/skbuff.h          |    2 +-
 include/net/protocol.h          |    4 ++--
 include/net/tcp.h               |    2 +-
 include/net/udp.h               |    2 +-
 net/8021q/vlan.c                |    2 +-
 net/bridge/br_if.c              |    2 +-
 net/bridge/br_private.h         |    2 +-
 net/core/dev.c                  |   15 +++++++--------
 net/core/ethtool.c              |    2 +-
 net/core/net-sysfs.c            |    2 +-
 net/core/skbuff.c               |    4 ++--
 net/ipv4/af_inet.c              |    2 +-
 net/ipv4/tcp.c                  |    2 +-
 net/ipv4/udp.c                  |    2 +-
 net/ipv6/af_inet6.c             |    2 +-
 net/ipv6/udp.c                  |    2 +-
 23 files changed, 42 insertions(+), 44 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index df99edf..cab96fa 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -8312,7 +8312,7 @@ static const struct net_device_ops bnx2_netdev_op=
s =3D {
 #endif
 };
=20
-static void inline vlan_features_add(struct net_device *dev, unsigned =
long flags)
+static void inline vlan_features_add(struct net_device *dev, u32 flags=
)
 {
 	dev->vlan_features |=3D flags;
 }
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index b1025b8..8d10aff 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1372,8 +1372,8 @@ static int bond_compute_features(struct bonding *=
bond)
 {
 	struct slave *slave;
 	struct net_device *bond_dev =3D bond->dev;
-	unsigned long features =3D bond_dev->features;
-	unsigned long vlan_features =3D 0;
+	u32 features =3D bond_dev->features;
+	u32 vlan_features =3D 0;
 	unsigned short max_hard_header_len =3D max((u16)ETH_HLEN,
 						bond_dev->hard_header_len);
 	int i;
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myr=
i10ge.c
index ea5cfe2..a7f2eed 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -253,7 +253,7 @@ struct myri10ge_priv {
 	unsigned long serial_number;
 	int vendor_specific_offset;
 	int fw_multicast_support;
-	unsigned long features;
+	u32 features;
 	u32 max_tso6;
 	u32 read_dma;
 	u32 write_dma;
@@ -1776,7 +1776,7 @@ static int myri10ge_set_rx_csum(struct net_device=
 *netdev, u32 csum_enabled)
 static int myri10ge_set_tso(struct net_device *netdev, u32 tso_enabled=
)
 {
 	struct myri10ge_priv *mgp =3D netdev_priv(netdev);
-	unsigned long flags =3D mgp->features & (NETIF_F_TSO6 | NETIF_F_TSO);
+	u32 flags =3D mgp->features & (NETIF_F_TSO6 | NETIF_F_TSO);
=20
 	if (tso_enabled)
 		netdev->features |=3D flags;
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 0e8bb19..713969a 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -502,7 +502,7 @@ static void efx_ethtool_get_stats(struct net_device=
 *net_dev,
 static int efx_ethtool_set_tso(struct net_device *net_dev, u32 enable)
 {
 	struct efx_nic *efx __attribute__ ((unused)) =3D netdev_priv(net_dev)=
;
-	unsigned long features;
+	u32 features;
=20
 	features =3D NETIF_F_TSO;
 	if (efx->type->offload_features & NETIF_F_V6_CSUM)
@@ -519,7 +519,7 @@ static int efx_ethtool_set_tso(struct net_device *n=
et_dev, u32 enable)
 static int efx_ethtool_set_tx_csum(struct net_device *net_dev, u32 ena=
ble)
 {
 	struct efx_nic *efx =3D netdev_priv(net_dev);
-	unsigned long features =3D efx->type->offload_features & NETIF_F_ALL_=
CSUM;
+	u32 features =3D efx->type->offload_features & NETIF_F_ALL_CSUM;
=20
 	if (enable)
 		net_dev->features |=3D features;
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.=
h
index 28df866..c652702 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -906,7 +906,7 @@ struct efx_nic_type {
 	unsigned int phys_addr_channels;
 	unsigned int tx_dc_base;
 	unsigned int rx_dc_base;
-	unsigned long offload_features;
+	u32 offload_features;
 	u32 reset_world_flags;
 };
=20
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index b100bd5..55786a0 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1142,7 +1142,7 @@ static int tun_get_iff(struct net *net, struct tu=
n_struct *tun,
  * privs required. */
 static int set_offload(struct net_device *dev, unsigned long arg)
 {
-	unsigned int old_features, features;
+	u32 old_features, features;
=20
 	old_features =3D dev->features;
 	/* Unset features, set them as we chew on the arg. */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 371fa88..c73d63d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -894,7 +894,7 @@ struct net_device {
 	struct list_head	unreg_list;
=20
 	/* Net device features */
-	unsigned long		features;
+	u32			features;
 #define NETIF_F_SG		1	/* Scatter/gather IO. */
 #define NETIF_F_IP_CSUM		2	/* Can checksum TCP/UDP over IPv4. */
 #define NETIF_F_NO_CSUM		4	/* Does not require checksum. F.e. loopack.=
 */
@@ -1150,7 +1150,7 @@ struct net_device {
 	const struct rtnl_link_ops *rtnl_link_ops;
=20
 	/* VLAN feature mask */
-	unsigned long vlan_features;
+	u32 vlan_features;
=20
 	/* for setting kernel sock attribute on TCP connection setup */
 #define GSO_MAX_SIZE		65536
@@ -1374,7 +1374,7 @@ struct packet_type {
 					 struct packet_type *,
 					 struct net_device *);
 	struct sk_buff		*(*gso_segment)(struct sk_buff *skb,
-						int features);
+						u32 features);
 	int			(*gso_send_check)(struct sk_buff *skb);
 	struct sk_buff		**(*gro_receive)(struct sk_buff **head,
 					       struct sk_buff *skb);
@@ -2343,7 +2343,7 @@ extern int		netdev_tstamp_prequeue;
 extern int		weight_p;
 extern int		netdev_set_master(struct net_device *dev, struct net_devic=
e *master);
 extern int skb_checksum_help(struct sk_buff *skb);
-extern struct sk_buff *skb_gso_segment(struct sk_buff *skb, int featur=
es);
+extern struct sk_buff *skb_gso_segment(struct sk_buff *skb, u32 featur=
es);
 #ifdef CONFIG_BUG
 extern void netdev_rx_csum_fault(struct net_device *dev);
 #else
@@ -2370,22 +2370,21 @@ extern char *netdev_drivername(const struct net=
_device *dev, char *buffer, int l
=20
 extern void linkwatch_run_queue(void);
=20
-unsigned long netdev_increment_features(unsigned long all, unsigned lo=
ng one,
-					unsigned long mask);
-unsigned long netdev_fix_features(unsigned long features, const char *=
name);
+u32 netdev_increment_features(u32 all, u32 one, u32 mask);
+u32 netdev_fix_features(u32 features, const char *name);
=20
 void netif_stacked_transfer_operstate(const struct net_device *rootdev=
,
 					struct net_device *dev);
=20
-int netif_skb_features(struct sk_buff *skb);
+u32 netif_skb_features(struct sk_buff *skb);
=20
-static inline int net_gso_ok(int features, int gso_type)
+static inline int net_gso_ok(u32 features, int gso_type)
 {
 	int feature =3D gso_type << NETIF_F_GSO_SHIFT;
 	return (features & feature) =3D=3D feature;
 }
=20
-static inline int skb_gso_ok(struct sk_buff *skb, int features)
+static inline int skb_gso_ok(struct sk_buff *skb, u32 features)
 {
 	return net_gso_ok(features, skb_shinfo(skb)->gso_type) &&
 	       (!skb_has_frag_list(skb) || (features & NETIF_F_FRAGLIST));
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6e946da..31f02d0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1877,7 +1877,7 @@ extern void	       skb_split(struct sk_buff *skb,
 extern int	       skb_shift(struct sk_buff *tgt, struct sk_buff *skb,
 				 int shiftlen);
=20
-extern struct sk_buff *skb_segment(struct sk_buff *skb, int features);
+extern struct sk_buff *skb_segment(struct sk_buff *skb, u32 features);
=20
 static inline void *skb_header_pointer(const struct sk_buff *skb, int =
offset,
 				       int len, void *buffer)
diff --git a/include/net/protocol.h b/include/net/protocol.h
index dc07495..6f7eb80 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -38,7 +38,7 @@ struct net_protocol {
 	void			(*err_handler)(struct sk_buff *skb, u32 info);
 	int			(*gso_send_check)(struct sk_buff *skb);
 	struct sk_buff	       *(*gso_segment)(struct sk_buff *skb,
-					       int features);
+					       u32 features);
 	struct sk_buff	      **(*gro_receive)(struct sk_buff **head,
 					       struct sk_buff *skb);
 	int			(*gro_complete)(struct sk_buff *skb);
@@ -57,7 +57,7 @@ struct inet6_protocol {
=20
 	int	(*gso_send_check)(struct sk_buff *skb);
 	struct sk_buff *(*gso_segment)(struct sk_buff *skb,
-				       int features);
+				       u32 features);
 	struct sk_buff **(*gro_receive)(struct sk_buff **head,
 					struct sk_buff *skb);
 	int	(*gro_complete)(struct sk_buff *skb);
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 38509f0..9179111 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1404,7 +1404,7 @@ extern struct request_sock_ops tcp6_request_sock_=
ops;
 extern void tcp_v4_destroy_sock(struct sock *sk);
=20
 extern int tcp_v4_gso_send_check(struct sk_buff *skb);
-extern struct sk_buff *tcp_tso_segment(struct sk_buff *skb, int featur=
es);
+extern struct sk_buff *tcp_tso_segment(struct sk_buff *skb, u32 featur=
es);
 extern struct sk_buff **tcp_gro_receive(struct sk_buff **head,
 					struct sk_buff *skb);
 extern struct sk_buff **tcp4_gro_receive(struct sk_buff **head,
diff --git a/include/net/udp.h b/include/net/udp.h
index bb967dd..e82f3a8 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -245,5 +245,5 @@ extern void udp4_proc_exit(void);
 extern void udp_init(void);
=20
 extern int udp4_ufo_send_check(struct sk_buff *skb);
-extern struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb, int feat=
ures);
+extern struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb, u32 feat=
ures);
 #endif	/* _UDP_H */
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 6e64f7c..7850412 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -327,7 +327,7 @@ static void vlan_sync_address(struct net_device *de=
v,
 static void vlan_transfer_features(struct net_device *dev,
 				   struct net_device *vlandev)
 {
-	unsigned long old_features =3D vlandev->features;
+	u32 old_features =3D vlandev->features;
=20
 	vlandev->features &=3D ~dev->vlan_features;
 	vlandev->features |=3D dev->features & dev->vlan_features;
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index d9d1e2b..52ce4a3 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -365,7 +365,7 @@ int br_min_mtu(const struct net_bridge *br)
 void br_features_recompute(struct net_bridge *br)
 {
 	struct net_bridge_port *p;
-	unsigned long features, mask;
+	u32 features, mask;
=20
 	features =3D mask =3D br->feature_mask;
 	if (list_empty(&br->port_list))
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 84aac77..9f22898 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -182,7 +182,7 @@ struct net_bridge
 	struct br_cpu_netstats __percpu *stats;
 	spinlock_t			hash_lock;
 	struct hlist_head		hash[BR_HASH_SIZE];
-	unsigned long			feature_mask;
+	u32				feature_mask;
 #ifdef CONFIG_BRIDGE_NETFILTER
 	struct rtable 			fake_rtable;
 	bool				nf_call_iptables;
diff --git a/net/core/dev.c b/net/core/dev.c
index 906b589..01d7ce2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1856,7 +1856,7 @@ EXPORT_SYMBOL(skb_checksum_help);
  *	It may return NULL if the skb requires no segmentation.  This is
  *	only possible when GSO is used for verifying header integrity.
  */
-struct sk_buff *skb_gso_segment(struct sk_buff *skb, int features)
+struct sk_buff *skb_gso_segment(struct sk_buff *skb, u32 features)
 {
 	struct sk_buff *segs =3D ERR_PTR(-EPROTONOSUPPORT);
 	struct packet_type *ptype;
@@ -2044,7 +2044,7 @@ static bool can_checksum_protocol(unsigned long f=
eatures, __be16 protocol)
 		 protocol =3D=3D htons(ETH_P_FCOE)));
 }
=20
-static int harmonize_features(struct sk_buff *skb, __be16 protocol, in=
t features)
+static u32 harmonize_features(struct sk_buff *skb, __be16 protocol, u3=
2 features)
 {
 	if (!can_checksum_protocol(protocol, features)) {
 		features &=3D ~NETIF_F_ALL_CSUM;
@@ -2056,10 +2056,10 @@ static int harmonize_features(struct sk_buff *s=
kb, __be16 protocol, int features
 	return features;
 }
=20
-int netif_skb_features(struct sk_buff *skb)
+u32 netif_skb_features(struct sk_buff *skb)
 {
 	__be16 protocol =3D skb->protocol;
-	int features =3D skb->dev->features;
+	u32 features =3D skb->dev->features;
=20
 	if (protocol =3D=3D htons(ETH_P_8021Q)) {
 		struct vlan_ethhdr *veh =3D (struct vlan_ethhdr *)skb->data;
@@ -2104,7 +2104,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, stru=
ct net_device *dev,
 	int rc =3D NETDEV_TX_OK;
=20
 	if (likely(!skb->next)) {
-		int features;
+		u32 features;
=20
 		/*
 		 * If device doesnt need skb->dst, release it right now while
@@ -5127,7 +5127,7 @@ static void rollback_registered(struct net_device=
 *dev)
 	rollback_registered_many(&single);
 }
=20
-unsigned long netdev_fix_features(unsigned long features, const char *=
name)
+u32 netdev_fix_features(u32 features, const char *name)
 {
 	/* Fix illegal checksum combinations */
 	if ((features & NETIF_F_HW_CSUM) &&
@@ -6057,8 +6057,7 @@ static int dev_cpu_callback(struct notifier_block=
 *nfb,
  *	@one to the master device with current feature set @all.  Will not
  *	enable anything that is off in @mask. Returns the new feature set.
  */
-unsigned long netdev_increment_features(unsigned long all, unsigned lo=
ng one,
-					unsigned long mask)
+u32 netdev_increment_features(u32 all, u32 one, u32 mask)
 {
 	/* If device needs checksumming, downgrade to it. */
 	if (all & NETIF_F_NO_CSUM && !(one & NETIF_F_NO_CSUM))
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 1774178..bd1af99 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1458,7 +1458,7 @@ int dev_ethtool(struct net *net, struct ifreq *if=
r)
 	void __user *useraddr =3D ifr->ifr_data;
 	u32 ethcmd;
 	int rc;
-	unsigned long old_features;
+	u32 old_features;
=20
 	if (!dev || !netif_device_present(dev))
 		return -ENODEV;
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index e23c01b..81367cc 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -99,7 +99,7 @@ NETDEVICE_SHOW(addr_assign_type, fmt_dec);
 NETDEVICE_SHOW(addr_len, fmt_dec);
 NETDEVICE_SHOW(iflink, fmt_dec);
 NETDEVICE_SHOW(ifindex, fmt_dec);
-NETDEVICE_SHOW(features, fmt_long_hex);
+NETDEVICE_SHOW(features, fmt_hex);
 NETDEVICE_SHOW(type, fmt_dec);
 NETDEVICE_SHOW(link_mode, fmt_dec);
=20
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d31bb36..436c4c4 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2497,7 +2497,7 @@ EXPORT_SYMBOL_GPL(skb_pull_rcsum);
  *	a pointer to the first in a list of new skbs for the segments.
  *	In case of error it returns ERR_PTR(err).
  */
-struct sk_buff *skb_segment(struct sk_buff *skb, int features)
+struct sk_buff *skb_segment(struct sk_buff *skb, u32 features)
 {
 	struct sk_buff *segs =3D NULL;
 	struct sk_buff *tail =3D NULL;
@@ -2507,7 +2507,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, =
int features)
 	unsigned int offset =3D doffset;
 	unsigned int headroom;
 	unsigned int len;
-	int sg =3D features & NETIF_F_SG;
+	int sg =3D !!(features & NETIF_F_SG);
 	int nfrags =3D skb_shinfo(skb)->nr_frags;
 	int err =3D -ENOMEM;
 	int i =3D 0;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index f2b6110..e5e2d9d 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1215,7 +1215,7 @@ out:
 	return err;
 }
=20
-static struct sk_buff *inet_gso_segment(struct sk_buff *skb, int featu=
res)
+static struct sk_buff *inet_gso_segment(struct sk_buff *skb, u32 featu=
res)
 {
 	struct sk_buff *segs =3D ERR_PTR(-EINVAL);
 	struct iphdr *iph;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 6c11eec..f9867d2 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2653,7 +2653,7 @@ int compat_tcp_getsockopt(struct sock *sk, int le=
vel, int optname,
 EXPORT_SYMBOL(compat_tcp_getsockopt);
 #endif
=20
-struct sk_buff *tcp_tso_segment(struct sk_buff *skb, int features)
+struct sk_buff *tcp_tso_segment(struct sk_buff *skb, u32 features)
 {
 	struct sk_buff *segs =3D ERR_PTR(-EINVAL);
 	struct tcphdr *th;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 8157b17..d37baaa 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2199,7 +2199,7 @@ int udp4_ufo_send_check(struct sk_buff *skb)
 	return 0;
 }
=20
-struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb, int features)
+struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb, u32 features)
 {
 	struct sk_buff *segs =3D ERR_PTR(-EINVAL);
 	unsigned int mss;
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 978e80e..3194aa9 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -772,7 +772,7 @@ out:
 	return err;
 }
=20
-static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb, int featu=
res)
+static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb, u32 featu=
res)
 {
 	struct sk_buff *segs =3D ERR_PTR(-EINVAL);
 	struct ipv6hdr *ipv6h;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 9a009c6..a419a78 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1299,7 +1299,7 @@ static int udp6_ufo_send_check(struct sk_buff *sk=
b)
 	return 0;
 }
=20
-static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb, int feat=
ures)
+static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb, u32 feat=
ures)
 {
 	struct sk_buff *segs =3D ERR_PTR(-EINVAL);
 	unsigned int mss;
--=20
1.7.2.3

