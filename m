From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: [PATCH net-next v2 3/5] net: add netlink_ext_ack argument to rtnl_link_ops.validate
Date: Sun, 25 Jun 2017 23:56:01 +0200
Message-ID: <51f1b1e0b81216ce08a2c846c7eac6fb58e9d667.1498425679.git.mschiffer@universe-factory.net>
References: <cover.1498425679.git.mschiffer@universe-factory.net>
Cc: linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-can@vger.kernel.org,
        linux-ppp@vger.kernel.org, linux-wpan@vger.kernel.org
To: dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, wg@grandegger.com, mkl@pengutronix.de,
        pablo@netfilter.org, laforge@gnumonks.org, paulus@samba.org,
        jiri@resnulli.us, dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        davem@davemloft.net, stephen@networkplumber.org,
        arvid.brodin@alten.se, alex.aring@gmail.com,
        stefan@osg.samsung.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        johannes@sipsolutions.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1498425679.git.mschiffer@universe-factory.net>
In-Reply-To: <cover.1498425679.git.mschiffer@universe-factory.net>
References: <cover.1498425679.git.mschiffer@universe-factory.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for extended error reporting.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
---
 drivers/net/bonding/bond_netlink.c | 3 ++-
 drivers/net/can/dev.c              | 3 ++-
 drivers/net/dummy.c                | 3 ++-
 drivers/net/geneve.c               | 3 ++-
 drivers/net/gtp.c                  | 3 ++-
 drivers/net/ifb.c                  | 3 ++-
 drivers/net/ipvlan/ipvlan_main.c   | 3 ++-
 drivers/net/macsec.c               | 3 ++-
 drivers/net/macvlan.c              | 3 ++-
 drivers/net/nlmon.c                | 3 ++-
 drivers/net/ppp/ppp_generic.c      | 3 ++-
 drivers/net/team/team.c            | 3 ++-
 drivers/net/tun.c                  | 3 ++-
 drivers/net/veth.c                 | 5 +++--
 drivers/net/vrf.c                  | 3 ++-
 drivers/net/vxlan.c                | 3 ++-
 include/net/rtnetlink.h            | 3 ++-
 net/8021q/vlan_netlink.c           | 3 ++-
 net/bridge/br_netlink.c            | 4 +++-
 net/core/rtnetlink.c               | 2 +-
 net/ieee802154/6lowpan/core.c      | 3 ++-
 net/ipv4/ip_gre.c                  | 8 +++++---
 net/ipv4/ip_vti.c                  | 3 ++-
 net/ipv4/ipip.c                    | 3 ++-
 net/ipv6/ip6_gre.c                 | 8 +++++---
 net/ipv6/ip6_tunnel.c              | 3 ++-
 net/ipv6/ip6_vti.c                 | 3 ++-
 net/ipv6/sit.c                     | 3 ++-
 28 files changed, 63 insertions(+), 33 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index cb803c026f1f..0a9d78de6138 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -118,7 +118,8 @@ static const struct nla_policy bond_slave_policy[IFLA_BOND_SLAVE_MAX + 1] = {
 	[IFLA_BOND_SLAVE_QUEUE_ID]	= { .type = NLA_U16 },
 };
 
-static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
+static int bond_validate(struct nlattr *tb[], struct nlattr *data[],
+			 struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 6d8191f2ad32..365a8cc62405 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -848,7 +848,8 @@ static const struct nla_policy can_policy[IFLA_CAN_MAX + 1] = {
 				= { .len = sizeof(struct can_bittiming_const) },
 };
 
-static int can_validate(struct nlattr *tb[], struct nlattr *data[])
+static int can_validate(struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
 {
 	bool is_can_fd = false;
 
diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 9905b52fe293..d0c165d2086e 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -356,7 +356,8 @@ static void dummy_setup(struct net_device *dev)
 	dev->max_mtu = ETH_MAX_MTU;
 }
 
-static int dummy_validate(struct nlattr *tb[], struct nlattr *data[])
+static int dummy_validate(struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 0a72d914e1f9..eb77201cb718 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1058,7 +1058,8 @@ static const struct nla_policy geneve_policy[IFLA_GENEVE_MAX + 1] = {
 	[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]	= { .type = NLA_U8 },
 };
 
-static int geneve_validate(struct nlattr *tb[], struct nlattr *data[])
+static int geneve_validate(struct nlattr *tb[], struct nlattr *data[],
+			   struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 9cfe8a24c1fc..1542e837fdfa 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -698,7 +698,8 @@ static const struct nla_policy gtp_policy[IFLA_GTP_MAX + 1] = {
 	[IFLA_GTP_ROLE]			= { .type = NLA_U32 },
 };
 
-static int gtp_validate(struct nlattr *tb[], struct nlattr *data[])
+static int gtp_validate(struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
 {
 	if (!data)
 		return -EINVAL;
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 144ea5ae8ab4..8870bd2a2e8a 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -273,7 +273,8 @@ static int ifb_open(struct net_device *dev)
 	return 0;
 }
 
-static int ifb_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ifb_validate(struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index e7d54072d7b3..f37e3c1fd4e7 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -477,7 +477,8 @@ static size_t ipvlan_nl_getsize(const struct net_device *dev)
 		);
 }
 
-static int ipvlan_nl_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ipvlan_nl_validate(struct nlattr *tb[], struct nlattr *data[],
+			      struct netlink_ext_ack *extack)
 {
 	if (data && data[IFLA_IPVLAN_MODE]) {
 		u16 mode = nla_get_u16(data[IFLA_IPVLAN_MODE]);
diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 38ba3d73ac15..5e1ab1160856 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -3287,7 +3287,8 @@ static int macsec_newlink(struct net *net, struct net_device *dev,
 	return err;
 }
 
-static int macsec_validate_attr(struct nlattr *tb[], struct nlattr *data[])
+static int macsec_validate_attr(struct nlattr *tb[], struct nlattr *data[],
+				struct netlink_ext_ack *extack)
 {
 	u64 csid = MACSEC_DEFAULT_CIPHER_ID;
 	u8 icv_len = DEFAULT_ICV_LEN;
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 3064416578a9..9ffff0362a11 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1162,7 +1162,8 @@ static void macvlan_port_destroy(struct net_device *dev)
 	kfree(port);
 }
 
-static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
+static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[],
+			    struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
diff --git a/drivers/net/nlmon.c b/drivers/net/nlmon.c
index c4b3362da4a2..4b22955de191 100644
--- a/drivers/net/nlmon.c
+++ b/drivers/net/nlmon.c
@@ -127,7 +127,8 @@ static void nlmon_setup(struct net_device *dev)
 	dev->min_mtu = sizeof(struct nlmsghdr);
 }
 
-static int nlmon_validate(struct nlattr *tb[], struct nlattr *data[])
+static int nlmon_validate(struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS])
 		return -EINVAL;
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 8479c130fe2e..13028833bee3 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -1061,7 +1061,8 @@ static const struct nla_policy ppp_nl_policy[IFLA_PPP_MAX + 1] = {
 	[IFLA_PPP_DEV_FD]	= { .type = NLA_S32 },
 };
 
-static int ppp_nl_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ppp_nl_validate(struct nlattr *tb[], struct nlattr *data[],
+			   struct netlink_ext_ack *extack)
 {
 	if (!data)
 		return -EINVAL;
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index bbe97bb7c9cc..464570409796 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2110,7 +2110,8 @@ static int team_newlink(struct net *src_net, struct net_device *dev,
 	return register_netdevice(dev);
 }
 
-static int team_validate(struct nlattr *tb[], struct nlattr *data[])
+static int team_validate(struct nlattr *tb[], struct nlattr *data[],
+			 struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index ae49f4b99b67..3d4c24572ecd 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1580,7 +1580,8 @@ static void tun_setup(struct net_device *dev)
 /* Trivial set of netlink ops to allow deleting tun or tap
  * device with netlink.
  */
-static int tun_validate(struct nlattr *tb[], struct nlattr *data[])
+static int tun_validate(struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
 {
 	return -EINVAL;
 }
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 3db907cb7d07..b33553b1e19c 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -329,7 +329,8 @@ static void veth_setup(struct net_device *dev)
  * netlink interface
  */
 
-static int veth_validate(struct nlattr *tb[], struct nlattr *data[])
+static int veth_validate(struct nlattr *tb[], struct nlattr *data[],
+			 struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
@@ -374,7 +375,7 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 		if (err < 0)
 			return err;
 
-		err = veth_validate(peer_tb, NULL);
+		err = veth_validate(peer_tb, NULL, extack);
 		if (err < 0)
 			return err;
 
diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 762f4d033e1b..f4d0054981c6 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -1372,7 +1372,8 @@ static void vrf_setup(struct net_device *dev)
 	dev->priv_flags |= IFF_NO_QUEUE;
 }
 
-static int vrf_validate(struct nlattr *tb[], struct nlattr *data[])
+static int vrf_validate(struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 60c40349e73e..0dafd8e6c665 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2711,7 +2711,8 @@ static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_REMCSUM_NOPARTIAL]	= { .type = NLA_FLAG },
 };
 
-static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
+static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN) {
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index f7d0320f75b0..11fe0ad60e43 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -63,7 +63,8 @@ struct rtnl_link_ops {
 	int			maxtype;
 	const struct nla_policy	*policy;
 	int			(*validate)(struct nlattr *tb[],
-					    struct nlattr *data[]);
+					    struct nlattr *data[],
+					    struct netlink_ext_ack *extack);
 
 	int			(*newlink)(struct net *src_net,
 					   struct net_device *dev,
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index f08b5e192e45..5e831de3103e 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -39,7 +39,8 @@ static inline int vlan_validate_qos_map(struct nlattr *attr)
 				   NULL);
 }
 
-static int vlan_validate(struct nlattr *tb[], struct nlattr *data[])
+static int vlan_validate(struct nlattr *tb[], struct nlattr *data[],
+			 struct netlink_ext_ack *extack)
 {
 	struct ifla_vlan_flags *flags;
 	u16 id;
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 37e4ec2953b2..9af177ca4d31 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -858,7 +858,9 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 
 	return err;
 }
-static int br_validate(struct nlattr *tb[], struct nlattr *data[])
+
+static int br_validate(struct nlattr *tb[], struct nlattr *data[],
+		       struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index bac81d1bb24d..7136588e65e9 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2582,7 +2582,7 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 				data = attr;
 			}
 			if (ops->validate) {
-				err = ops->validate(tb, data);
+				err = ops->validate(tb, data, extack);
 				if (err < 0)
 					return err;
 			}
diff --git a/net/ieee802154/6lowpan/core.c b/net/ieee802154/6lowpan/core.c
index 1a4c585f3950..de2661cd0328 100644
--- a/net/ieee802154/6lowpan/core.c
+++ b/net/ieee802154/6lowpan/core.c
@@ -111,7 +111,8 @@ static void lowpan_setup(struct net_device *ldev)
 	ldev->features		|= NETIF_F_NETNS_LOCAL;
 }
 
-static int lowpan_validate(struct nlattr *tb[], struct nlattr *data[])
+static int lowpan_validate(struct nlattr *tb[], struct nlattr *data[],
+			   struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != IEEE802154_ADDR_LEN)
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index a63985c4bec7..7a7829e839c2 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -779,7 +779,8 @@ static struct pernet_operations ipgre_net_ops = {
 	.size = sizeof(struct ip_tunnel_net),
 };
 
-static int ipgre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ipgre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[],
+				 struct netlink_ext_ack *extack)
 {
 	__be16 flags;
 
@@ -802,7 +803,8 @@ static int ipgre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
-static int ipgre_tap_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ipgre_tap_validate(struct nlattr *tb[], struct nlattr *data[],
+			      struct netlink_ext_ack *extack)
 {
 	__be32 daddr;
 
@@ -823,7 +825,7 @@ static int ipgre_tap_validate(struct nlattr *tb[], struct nlattr *data[])
 	}
 
 out:
-	return ipgre_tunnel_validate(tb, data);
+	return ipgre_tunnel_validate(tb, data, extack);
 }
 
 static int ipgre_netlink_parms(struct net_device *dev,
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 24acff67a4f2..0192c255e508 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -465,7 +465,8 @@ static struct pernet_operations vti_net_ops = {
 	.size = sizeof(struct ip_tunnel_net),
 };
 
-static int vti_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
+static int vti_tunnel_validate(struct nlattr *tb[], struct nlattr *data[],
+			       struct netlink_ext_ack *extack)
 {
 	return 0;
 }
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index eb7fe7b0046f..fb1ad22b5e29 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -375,7 +375,8 @@ static int ipip_tunnel_init(struct net_device *dev)
 	return ip_tunnel_init(dev);
 }
 
-static int ipip_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ipip_tunnel_validate(struct nlattr *tb[], struct nlattr *data[],
+				struct netlink_ext_ack *extack)
 {
 	u8 proto;
 
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 7232b28425f3..67ff2aaf5dcb 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1170,7 +1170,8 @@ static struct pernet_operations ip6gre_net_ops = {
 	.size = sizeof(struct ip6gre_net),
 };
 
-static int ip6gre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ip6gre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[],
+				  struct netlink_ext_ack *extack)
 {
 	__be16 flags;
 
@@ -1188,7 +1189,8 @@ static int ip6gre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
-static int ip6gre_tap_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ip6gre_tap_validate(struct nlattr *tb[], struct nlattr *data[],
+			       struct netlink_ext_ack *extack)
 {
 	struct in6_addr daddr;
 
@@ -1209,7 +1211,7 @@ static int ip6gre_tap_validate(struct nlattr *tb[], struct nlattr *data[])
 	}
 
 out:
-	return ip6gre_tunnel_validate(tb, data);
+	return ip6gre_tunnel_validate(tb, data, extack);
 }
 
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index d9f60a173107..3a0ba2ae4b0f 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1885,7 +1885,8 @@ static int __net_init ip6_fb_tnl_dev_init(struct net_device *dev)
 	return 0;
 }
 
-static int ip6_tnl_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ip6_tnl_validate(struct nlattr *tb[], struct nlattr *data[],
+			    struct netlink_ext_ack *extack)
 {
 	u8 proto;
 
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 2afdddb48e69..486c2305f53c 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -907,7 +907,8 @@ static int __net_init vti6_fb_tnl_dev_init(struct net_device *dev)
 	return 0;
 }
 
-static int vti6_validate(struct nlattr *tb[], struct nlattr *data[])
+static int vti6_validate(struct nlattr *tb[], struct nlattr *data[],
+			 struct netlink_ext_ack *extack)
 {
 	return 0;
 }
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index b8000429f78d..e9958b1398cb 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1406,7 +1406,8 @@ static void __net_init ipip6_fb_tunnel_init(struct net_device *dev)
 	rcu_assign_pointer(sitn->tunnels_wc[0], tunnel);
 }
 
-static int ipip6_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ipip6_validate(struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	u8 proto;
 
-- 
2.13.1
