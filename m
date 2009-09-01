From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 02/19] netdev: convert pseudo-devices to netdev_tx_t
Date: Mon, 31 Aug 2009 22:50:41 -0700
Message-ID: <20090901055128.581112223@vyatta.com>
References: <20090901055039.824876937@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57433 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751514AbZIAF6s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 01:58:48 -0400
Content-Disposition: inline; filename=misc-tx.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/ieee1394/eth1394.c  |   14 ++++----------
 net/8021q/vlan_dev.c        |    7 ++++---
 net/bluetooth/bnep/netdev.c |    3 ++-
 net/bridge/br_device.c      |    2 +-
 net/bridge/br_private.h     |    3 ++-
 net/core/pktgen.c           |    2 +-
 net/dsa/dsa_priv.h          |    6 +++---
 net/dsa/tag_dsa.c           |    2 +-
 net/dsa/tag_edsa.c          |    2 +-
 net/dsa/tag_trailer.c       |    2 +-
 net/ipv4/ip_gre.c           |    2 +-
 net/ipv4/ipip.c             |    2 +-
 net/ipv4/ipmr.c             |    2 +-
 net/ipv6/ip6_tunnel.c       |    2 +-
 net/ipv6/ip6mr.c            |    3 ++-
 net/ipv6/sit.c              |    3 ++-
 net/sched/sch_teql.c        |    4 ++--
 17 files changed, 30 insertions(+), 31 deletions(-)

--- a/net/core/pktgen.c	2009-08-31 16:20:50.093609481 -0700
+++ b/net/core/pktgen.c	2009-08-31 16:21:06.923607987 -0700
@@ -3381,7 +3381,7 @@ static void idle(struct pktgen_dev *pkt_
 static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 {
 	struct net_device *odev = pkt_dev->odev;
-	int (*xmit)(struct sk_buff *, struct net_device *)
+	netdev_tx_t (*xmit)(struct sk_buff *, struct net_device *)
 		= odev->netdev_ops->ndo_start_xmit;
 	struct netdev_queue *txq;
 	u16 queue_map;
--- a/net/dsa/tag_dsa.c	2009-08-31 16:20:50.213591561 -0700
+++ b/net/dsa/tag_dsa.c	2009-08-31 16:21:06.923607987 -0700
@@ -15,7 +15,7 @@
 
 #define DSA_HLEN	4
 
-int dsa_xmit(struct sk_buff *skb, struct net_device *dev)
+netdev_tx_t dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	u8 *dsa_header;
--- a/net/dsa/tag_edsa.c	2009-08-31 16:20:50.193589159 -0700
+++ b/net/dsa/tag_edsa.c	2009-08-31 16:21:06.923607987 -0700
@@ -16,7 +16,7 @@
 #define DSA_HLEN	4
 #define EDSA_HLEN	8
 
-int edsa_xmit(struct sk_buff *skb, struct net_device *dev)
+netdev_tx_t edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	u8 *edsa_header;
--- a/net/dsa/tag_trailer.c	2009-08-31 16:20:50.183591100 -0700
+++ b/net/dsa/tag_trailer.c	2009-08-31 16:21:06.923607987 -0700
@@ -13,7 +13,7 @@
 #include <linux/netdevice.h>
 #include "dsa_priv.h"
 
-int trailer_xmit(struct sk_buff *skb, struct net_device *dev)
+netdev_tx_t trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct sk_buff *nskb;
--- a/net/ipv4/ip_gre.c	2009-08-31 16:20:50.163606647 -0700
+++ b/net/ipv4/ip_gre.c	2009-08-31 16:21:06.923607987 -0700
@@ -662,7 +662,7 @@ drop_nolock:
 	return(0);
 }
 
-static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct net_device_stats *stats = &tunnel->dev->stats;
--- a/net/ipv4/ipip.c	2009-08-31 16:20:50.143591673 -0700
+++ b/net/ipv4/ipip.c	2009-08-31 16:21:06.923607987 -0700
@@ -387,7 +387,7 @@ static int ipip_rcv(struct sk_buff *skb)
  *	and that skb is filled properly by that function.
  */
 
-static int ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct net_device_stats *stats = &tunnel->dev->stats;
--- a/net/ipv4/ipmr.c	2009-08-31 16:20:50.153591757 -0700
+++ b/net/ipv4/ipmr.c	2009-08-31 16:21:06.923607987 -0700
@@ -201,7 +201,7 @@ failure:
 
 #ifdef CONFIG_IP_PIMSM
 
-static int reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net *net = dev_net(dev);
 
--- a/net/ipv6/ip6_tunnel.c	2009-08-31 16:20:50.123607428 -0700
+++ b/net/ipv6/ip6_tunnel.c	2009-08-31 16:21:06.923607987 -0700
@@ -1036,7 +1036,7 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, str
 	return 0;
 }
 
-static int
+static netdev_tx_t
 ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
--- a/net/ipv6/ip6mr.c	2009-08-31 16:20:50.113591560 -0700
+++ b/net/ipv6/ip6mr.c	2009-08-31 16:21:06.923607987 -0700
@@ -416,7 +416,8 @@ static struct inet6_protocol pim6_protoc
 
 /* Service routines creating virtual interfaces: PIMREG */
 
-static int reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t reg_vif_xmit(struct sk_buff *skb,
+				      struct net_device *dev)
 {
 	struct net *net = dev_net(dev);
 
--- a/net/ipv6/sit.c	2009-08-31 16:20:50.133591239 -0700
+++ b/net/ipv6/sit.c	2009-08-31 16:21:35.458276003 -0700
@@ -609,7 +609,8 @@ static inline __be32 try_6to4(struct in6
  *	and that skb is filled properly by that function.
  */
 
-static int ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
+				     struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct net_device_stats *stats = &tunnel->dev->stats;
--- a/net/dsa/dsa_priv.h	2009-08-31 16:20:50.193589159 -0700
+++ b/net/dsa/dsa_priv.h	2009-08-31 16:21:06.923607987 -0700
@@ -169,13 +169,13 @@ struct net_device *dsa_slave_create(stru
 				    int port, char *name);
 
 /* tag_dsa.c */
-int dsa_xmit(struct sk_buff *skb, struct net_device *dev);
+netdev_tx_t dsa_xmit(struct sk_buff *skb, struct net_device *dev);
 
 /* tag_edsa.c */
-int edsa_xmit(struct sk_buff *skb, struct net_device *dev);
+netdev_tx_t edsa_xmit(struct sk_buff *skb, struct net_device *dev);
 
 /* tag_trailer.c */
-int trailer_xmit(struct sk_buff *skb, struct net_device *dev);
+netdev_tx_t trailer_xmit(struct sk_buff *skb, struct net_device *dev);
 
 
 #endif
--- a/net/bluetooth/bnep/netdev.c	2009-08-31 16:20:50.183591100 -0700
+++ b/net/bluetooth/bnep/netdev.c	2009-08-31 16:21:48.651094787 -0700
@@ -165,7 +165,8 @@ static inline int bnep_net_proto_filter(
 }
 #endif
 
-static int bnep_net_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t bnep_net_xmit(struct sk_buff *skb,
+				 struct net_device *dev)
 {
 	struct bnep_session *s = netdev_priv(dev);
 	struct sock *sk = s->sock->sk;
--- a/net/sched/sch_teql.c	2009-08-31 16:20:50.163606647 -0700
+++ b/net/sched/sch_teql.c	2009-08-31 16:21:06.923607987 -0700
@@ -268,7 +268,7 @@ static inline int teql_resolve(struct sk
 	return __teql_resolve(skb, skb_res, dev);
 }
 
-static int teql_master_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t teql_master_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct teql_master *master = netdev_priv(dev);
 	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
@@ -307,7 +307,7 @@ restart:
 
 				if (!netif_tx_queue_stopped(slave_txq) &&
 				    !netif_tx_queue_frozen(slave_txq) &&
-				    slave_ops->ndo_start_xmit(skb, slave) == 0) {
+				    slave_ops->ndo_start_xmit(skb, slave) == NETDEV_TX_OK) {
 					txq_trans_update(slave_txq);
 					__netif_tx_unlock(slave_txq);
 					master->slaves = NEXT_SLAVE(q);
--- a/net/8021q/vlan_dev.c	2009-08-31 16:20:50.103590218 -0700
+++ b/net/8021q/vlan_dev.c	2009-08-31 16:22:27.058282849 -0700
@@ -288,7 +288,8 @@ static int vlan_dev_hard_header(struct s
 	return rc;
 }
 
-static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
+					    struct net_device *dev)
 {
 	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
 	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)(skb->data);
@@ -325,8 +326,8 @@ static int vlan_dev_hard_start_xmit(stru
 	return NETDEV_TX_OK;
 }
 
-static int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
-					    struct net_device *dev)
+static netdev_tx_t vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
+						    struct net_device *dev)
 {
 	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
 	u16 vlan_tci;
--- a/drivers/ieee1394/eth1394.c	2009-08-31 16:20:50.223592344 -0700
+++ b/drivers/ieee1394/eth1394.c	2009-08-31 16:22:48.811086205 -0700
@@ -169,7 +169,8 @@ static int ether1394_header_cache(const 
 static void ether1394_header_cache_update(struct hh_cache *hh,
 					  const struct net_device *dev,
 					  const unsigned char *haddr);
-static int ether1394_tx(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t ether1394_tx(struct sk_buff *skb,
+				struct net_device *dev);
 static void ether1394_iso(struct hpsb_iso *iso);
 
 static struct ethtool_ops ethtool_ops;
@@ -1555,7 +1556,8 @@ static void ether1394_complete_cb(void *
 }
 
 /* Transmit a packet (called by kernel) */
-static int ether1394_tx(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ether1394_tx(struct sk_buff *skb,
+				struct net_device *dev)
 {
 	struct eth1394hdr hdr_buf;
 	struct eth1394_priv *priv = netdev_priv(dev);
@@ -1694,14 +1696,6 @@ fail:
 	dev->stats.tx_errors++;
 	spin_unlock_irqrestore(&priv->lock, flags);
 
-	/*
-	 * FIXME: According to a patch from 2003-02-26, "returning non-zero
-	 * causes serious problems" here, allegedly.  Before that patch,
-	 * -ERRNO was returned which is not appropriate under Linux 2.6.
-	 * Perhaps more needs to be done?  Stop the queue in serious
-	 * conditions and restart it elsewhere?
-	 */
-	/* return NETDEV_TX_BUSY; */
 	return NETDEV_TX_OK;
 }
 
--- a/net/bridge/br_device.c	2009-08-31 16:20:50.093609481 -0700
+++ b/net/bridge/br_device.c	2009-08-31 16:21:06.923607987 -0700
@@ -20,7 +20,7 @@
 #include "br_private.h"
 
 /* net device transmit always called with no BH (preempt_disabled) */
-int br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
+netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_bridge *br = netdev_priv(dev);
 	const unsigned char *dest = skb->data;
--- a/net/bridge/br_private.h	2009-08-31 16:20:50.103590218 -0700
+++ b/net/bridge/br_private.h	2009-08-31 16:23:10.522293080 -0700
@@ -143,7 +143,8 @@ static inline int br_is_root_bridge(cons
 
 /* br_device.c */
 extern void br_dev_setup(struct net_device *dev);
-extern int br_dev_xmit(struct sk_buff *skb, struct net_device *dev);
+extern netdev_tx_t br_dev_xmit(struct sk_buff *skb,
+			       struct net_device *dev);
 
 /* br_fdb.c */
 extern int br_fdb_init(void);

-- 

