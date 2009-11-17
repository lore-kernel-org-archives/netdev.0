From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] netns: net_identifiers should be read_mostly
Date: Tue, 17 Nov 2009 21:42:49 +0100
Message-ID: <4B030AC9.3050709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48585 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752582AbZKQUmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 15:42:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/bonding/bond_main.c         |    2 +-
 drivers/net/ppp_generic.c               |    2 +-
 drivers/net/pppoe.c                     |    2 +-
 drivers/net/pppol2tp.c                  |    2 +-
 net/8021q/vlan.c                        |    2 +-
 net/ipv4/ip_gre.c                       |    2 +-
 net/ipv4/ipip.c                         |    2 +-
 net/ipv6/ip6_tunnel.c                   |    2 +-
 net/ipv6/sit.c                          |    2 +-
 net/key/af_key.c                        |    2 +-
 net/netfilter/nf_conntrack_proto_dccp.c |    2 +-
 net/netfilter/nf_conntrack_proto_gre.c  |    2 +-
 net/phonet/pn_dev.c                     |    2 +-
 13 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index ecea6c2..726bd75 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -158,7 +158,7 @@ MODULE_PARM_DESC(fail_over_mac, "For active-backup, do not set all slaves to the
 static const char * const version =
 	DRV_DESCRIPTION ": v" DRV_VERSION " (" DRV_RELDATE ")\n";
 
-int bond_net_id;
+int bond_net_id __read_mostly;
 
 static __be32 arp_target[BOND_MAX_ARP_TARGETS];
 static int arp_ip_count;
diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 9bf2a6b..de64f64 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -184,7 +184,7 @@ static atomic_t ppp_unit_count = ATOMIC_INIT(0);
 static atomic_t channel_count = ATOMIC_INIT(0);
 
 /* per-net private data for this module */
-static int ppp_net_id;
+static int ppp_net_id __read_mostly;
 struct ppp_net {
 	/* units to ppp mapping */
 	struct idr units_idr;
diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 60c8d23..a1dcba2 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -97,7 +97,7 @@ static const struct proto_ops pppoe_ops;
 static struct ppp_channel_ops pppoe_chan_ops;
 
 /* per-net private data for this module */
-static int pppoe_net_id;
+static int pppoe_net_id __read_mostly;
 struct pppoe_net {
 	/*
 	 * we could use _single_ hash table for all
diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index 849cc9c..442c382 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -232,7 +232,7 @@ static struct ppp_channel_ops pppol2tp_chan_ops = { pppol2tp_xmit , NULL };
 static const struct proto_ops pppol2tp_ops;
 
 /* per-net private data for this module */
-static int pppol2tp_net_id;
+static int pppol2tp_net_id __read_mostly;
 struct pppol2tp_net {
 	struct list_head pppol2tp_tunnel_list;
 	rwlock_t pppol2tp_tunnel_list_lock;
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 39f8d01..d9cb020 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -41,7 +41,7 @@
 
 /* Global VLAN variables */
 
-int vlan_net_id;
+int vlan_net_id __read_mostly;
 
 /* Our listing of VLAN group(s) */
 static struct hlist_head vlan_group_hash[VLAN_GRP_HASH_SIZE];
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index a7de9e3..c5f6af5 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -125,7 +125,7 @@ static int ipgre_tunnel_bind_dev(struct net_device *dev);
 
 #define HASH_SIZE  16
 
-static int ipgre_net_id;
+static int ipgre_net_id __read_mostly;
 struct ipgre_net {
 	struct ip_tunnel *tunnels[4][HASH_SIZE];
 
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index c5b1f71..7242ffc 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -119,7 +119,7 @@
 #define HASH_SIZE  16
 #define HASH(addr) (((__force u32)addr^((__force u32)addr>>4))&0xF)
 
-static int ipip_net_id;
+static int ipip_net_id __read_mostly;
 struct ipip_net {
 	struct ip_tunnel *tunnels_r_l[HASH_SIZE];
 	struct ip_tunnel *tunnels_r[HASH_SIZE];
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 1d61411..e5c0f6b 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -78,7 +78,7 @@ static void ip6_fb_tnl_dev_init(struct net_device *dev);
 static void ip6_tnl_dev_init(struct net_device *dev);
 static void ip6_tnl_dev_setup(struct net_device *dev);
 
-static int ip6_tnl_net_id;
+static int ip6_tnl_net_id __read_mostly;
 struct ip6_tnl_net {
 	/* the IPv6 tunnel fallback device */
 	struct net_device *fb_tnl_dev;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index b6e145a..d9deaa7 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -66,7 +66,7 @@ static void ipip6_fb_tunnel_init(struct net_device *dev);
 static void ipip6_tunnel_init(struct net_device *dev);
 static void ipip6_tunnel_setup(struct net_device *dev);
 
-static int sit_net_id;
+static int sit_net_id __read_mostly;
 struct sit_net {
 	struct ip_tunnel *tunnels_r_l[HASH_SIZE];
 	struct ip_tunnel *tunnels_r[HASH_SIZE];
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 86b2c22..478c8b3 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -35,7 +35,7 @@
 #define _X2KEY(x) ((x) == XFRM_INF ? 0 : (x))
 #define _KEY2X(x) ((x) == 0 ? XFRM_INF : (x))
 
-static int pfkey_net_id;
+static int pfkey_net_id __read_mostly;
 struct netns_pfkey {
 	/* List of all pfkey sockets. */
 	struct hlist_head table;
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 1b816a2..80abdf2 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -384,7 +384,7 @@ dccp_state_table[CT_DCCP_ROLE_MAX + 1][DCCP_PKT_SYNCACK + 1][CT_DCCP_MAX + 1] =
 };
 
 /* this module per-net specifics */
-static int dccp_net_id;
+static int dccp_net_id __read_mostly;
 struct dccp_net {
 	int dccp_loose;
 	unsigned int dccp_timeout[CT_DCCP_MAX + 1];
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index a54a0af..91d0e71 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -43,7 +43,7 @@
 #define GRE_TIMEOUT		(30 * HZ)
 #define GRE_STREAM_TIMEOUT	(180 * HZ)
 
-static int proto_gre_net_id;
+static int proto_gre_net_id __read_mostly;
 struct netns_proto_gre {
 	rwlock_t		keymap_lock;
 	struct list_head	keymap_list;
diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 3287f8f..d5ad794 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -43,7 +43,7 @@ struct phonet_net {
 	struct phonet_routes routes;
 };
 
-int phonet_net_id;
+int phonet_net_id __read_mostly;
 
 struct phonet_device_list *phonet_device_list(struct net *net)
 {
