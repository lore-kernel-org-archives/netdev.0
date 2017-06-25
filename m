From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: [PATCH net-next v2 1/5] net: add netlink_ext_ack argument to rtnl_link_ops.newlink
Date: Sun, 25 Jun 2017 23:55:59 +0200
Message-ID: <29e5f66bf30227a951764cdec1b5770437f11d3a.1498425679.git.mschiffer@universe-factory.net>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from chaos.universe-factory.net ([31.24.148.19]:42812 "EHLO
        chaos.universe-factory.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751359AbdFYV4N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2017 17:56:13 -0400
In-Reply-To: <cover.1498425679.git.mschiffer@universe-factory.net>
In-Reply-To: <cover.1498425679.git.mschiffer@universe-factory.net>
References: <cover.1498425679.git.mschiffer@universe-factory.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for extended error reporting.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
---
 drivers/infiniband/ulp/ipoib/ipoib_netlink.c | 3 ++-
 drivers/net/bonding/bond_netlink.c           | 3 ++-
 drivers/net/caif/caif_hsi.c                  | 3 ++-
 drivers/net/can/dev.c                        | 3 ++-
 drivers/net/can/vxcan.c                      | 3 ++-
 drivers/net/geneve.c                         | 3 ++-
 drivers/net/gtp.c                            | 3 ++-
 drivers/net/ipvlan/ipvlan.h                  | 3 ++-
 drivers/net/ipvlan/ipvlan_main.c             | 3 ++-
 drivers/net/ipvlan/ipvtap.c                  | 9 ++++-----
 drivers/net/macsec.c                         | 3 ++-
 drivers/net/macvlan.c                        | 3 ++-
 drivers/net/macvtap.c                        | 7 +++----
 drivers/net/ppp/ppp_generic.c                | 3 ++-
 drivers/net/team/team.c                      | 3 ++-
 drivers/net/veth.c                           | 3 ++-
 drivers/net/vrf.c                            | 3 ++-
 drivers/net/vxlan.c                          | 3 ++-
 include/net/rtnetlink.h                      | 3 ++-
 net/8021q/vlan_netlink.c                     | 3 ++-
 net/bridge/br_netlink.c                      | 3 ++-
 net/caif/chnl_net.c                          | 3 ++-
 net/core/rtnetlink.c                         | 3 ++-
 net/hsr/hsr_netlink.c                        | 3 ++-
 net/ieee802154/6lowpan/core.c                | 3 ++-
 net/ipv4/ip_gre.c                            | 5 +++--
 net/ipv4/ip_vti.c                            | 3 ++-
 net/ipv4/ipip.c                              | 3 ++-
 net/ipv6/ip6_gre.c                           | 3 ++-
 net/ipv6/ip6_tunnel.c                        | 3 ++-
 net/ipv6/ip6_vti.c                           | 3 ++-
 net/ipv6/sit.c                               | 3 ++-
 32 files changed, 68 insertions(+), 40 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_netlink.c b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
index 28884781311b..8b75f80da56c 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
@@ -93,7 +93,8 @@ static int ipoib_changelink(struct net_device *dev,
 }
 
 static int ipoib_new_child_link(struct net *src_net, struct net_device *dev,
-			       struct nlattr *tb[], struct nlattr *data[])
+				struct nlattr *tb[], struct nlattr *data[],
+				struct netlink_ext_ack *extack)
 {
 	struct net_device *pdev;
 	struct ipoib_dev_priv *ppriv;
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 47a8103610bc..f817fb8005ef 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -438,7 +438,8 @@ static int bond_changelink(struct net_device *bond_dev,
 }
 
 static int bond_newlink(struct net *src_net, struct net_device *bond_dev,
-			struct nlattr *tb[], struct nlattr *data[])
+			struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
 {
 	int err;
 
diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 11ba6e3eea22..ed4723a9031f 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -1399,7 +1399,8 @@ static int caif_hsi_fill_info(struct sk_buff *skb, const struct net_device *dev)
 }
 
 static int caif_hsi_newlink(struct net *src_net, struct net_device *dev,
-			  struct nlattr *tb[], struct nlattr *data[])
+			    struct nlattr *tb[], struct nlattr *data[],
+			    struct netlink_ext_ack *extack)
 {
 	struct cfhsi *cfhsi = NULL;
 	struct cfhsi_ops *(*get_ops)(void);
diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index a3011c001080..7f99e8a5dd09 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -1146,7 +1146,8 @@ static int can_fill_xstats(struct sk_buff *skb, const struct net_device *dev)
 }
 
 static int can_newlink(struct net *src_net, struct net_device *dev,
-		       struct nlattr *tb[], struct nlattr *data[])
+		       struct nlattr *tb[], struct nlattr *data[],
+		       struct netlink_ext_ack *extack)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/drivers/net/can/vxcan.c b/drivers/net/can/vxcan.c
index cfe889e8f172..8404e8852a0f 100644
--- a/drivers/net/can/vxcan.c
+++ b/drivers/net/can/vxcan.c
@@ -163,7 +163,8 @@ static void vxcan_setup(struct net_device *dev)
 static struct rtnl_link_ops vxcan_link_ops;
 
 static int vxcan_newlink(struct net *net, struct net_device *dev,
-			 struct nlattr *tb[], struct nlattr *data[])
+			 struct nlattr *tb[], struct nlattr *data[],
+			 struct netlink_ext_ack *extack)
 {
 	struct vxcan_priv *priv;
 	struct net_device *peer;
diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index d586ad93aaff..0a72d914e1f9 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1181,7 +1181,8 @@ static void init_tnl_info(struct ip_tunnel_info *info, __u16 dst_port)
 }
 
 static int geneve_newlink(struct net *net, struct net_device *dev,
-			  struct nlattr *tb[], struct nlattr *data[])
+			  struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	bool use_udp6_rx_checksums = false;
 	struct ip_tunnel_info info;
diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 8e333a8a2295..9cfe8a24c1fc 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -636,7 +636,8 @@ static void gtp_hashtable_free(struct gtp_dev *gtp);
 static int gtp_encap_enable(struct gtp_dev *gtp, struct nlattr *data[]);
 
 static int gtp_newlink(struct net *src_net, struct net_device *dev,
-			struct nlattr *tb[], struct nlattr *data[])
+		       struct nlattr *tb[], struct nlattr *data[],
+		       struct netlink_ext_ack *extack)
 {
 	struct gtp_dev *gtp;
 	struct gtp_net *gn;
diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index 7919369c0a72..ba8173a0b62e 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -140,7 +140,8 @@ unsigned int ipvlan_nf_input(void *priv, struct sk_buff *skb,
 void ipvlan_count_rx(const struct ipvl_dev *ipvlan,
 		     unsigned int len, bool success, bool mcast);
 int ipvlan_link_new(struct net *src_net, struct net_device *dev,
-		    struct nlattr *tb[], struct nlattr *data[]);
+		    struct nlattr *tb[], struct nlattr *data[],
+		    struct netlink_ext_ack *extack);
 void ipvlan_link_delete(struct net_device *dev, struct list_head *head);
 void ipvlan_link_setup(struct net_device *dev);
 int ipvlan_link_register(struct rtnl_link_ops *ops);
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index dc888dd344eb..7bda5f630ac9 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -508,7 +508,8 @@ static int ipvlan_nl_fillinfo(struct sk_buff *skb,
 }
 
 int ipvlan_link_new(struct net *src_net, struct net_device *dev,
-		    struct nlattr *tb[], struct nlattr *data[])
+		    struct nlattr *tb[], struct nlattr *data[],
+		    struct netlink_ext_ack *extack)
 {
 	struct ipvl_dev *ipvlan = netdev_priv(dev);
 	struct ipvl_port *port;
diff --git a/drivers/net/ipvlan/ipvtap.c b/drivers/net/ipvlan/ipvtap.c
index 2b713b63b62c..22f133ea8d7b 100644
--- a/drivers/net/ipvlan/ipvtap.c
+++ b/drivers/net/ipvlan/ipvtap.c
@@ -73,10 +73,9 @@ static void ipvtap_update_features(struct tap_dev *tap,
 	netdev_update_features(vlan->dev);
 }
 
-static int ipvtap_newlink(struct net *src_net,
-			  struct net_device *dev,
-			  struct nlattr *tb[],
-			  struct nlattr *data[])
+static int ipvtap_newlink(struct net *src_net, struct net_device *dev,
+			  struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	struct ipvtap_dev *vlantap = netdev_priv(dev);
 	int err;
@@ -98,7 +97,7 @@ static int ipvtap_newlink(struct net *src_net,
 	/* Don't put anything that may fail after macvlan_common_newlink
 	 * because we can't undo what it does.
 	 */
-	err =  ipvlan_link_new(src_net, dev, tb, data);
+	err =  ipvlan_link_new(src_net, dev, tb, data, extack);
 	if (err) {
 		netdev_rx_handler_unregister(dev);
 		return err;
diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index e370d7c894cb..60f3e3089ec3 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -3203,7 +3203,8 @@ static int macsec_add_dev(struct net_device *dev, sci_t sci, u8 icv_len)
 }
 
 static int macsec_newlink(struct net *net, struct net_device *dev,
-			  struct nlattr *tb[], struct nlattr *data[])
+			  struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	struct macsec_dev *macsec = macsec_priv(dev);
 	struct net_device *real_dev;
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 8ca274c6df3d..526d23db3b71 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1390,7 +1390,8 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 EXPORT_SYMBOL_GPL(macvlan_common_newlink);
 
 static int macvlan_newlink(struct net *src_net, struct net_device *dev,
-			   struct nlattr *tb[], struct nlattr *data[])
+			   struct nlattr *tb[], struct nlattr *data[],
+			   struct netlink_ext_ack *extack)
 {
 	return macvlan_common_newlink(src_net, dev, tb, data);
 }
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index da85057680d6..91e7b19bbf86 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -77,10 +77,9 @@ static void macvtap_update_features(struct tap_dev *tap,
 	netdev_update_features(vlan->dev);
 }
 
-static int macvtap_newlink(struct net *src_net,
-			   struct net_device *dev,
-			   struct nlattr *tb[],
-			   struct nlattr *data[])
+static int macvtap_newlink(struct net *src_net, struct net_device *dev,
+			   struct nlattr *tb[], struct nlattr *data[],
+			   struct netlink_ext_ack *extack)
 {
 	struct macvtap_dev *vlantap = netdev_priv(dev);
 	int err;
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index d42091f11eb8..8479c130fe2e 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -1075,7 +1075,8 @@ static int ppp_nl_validate(struct nlattr *tb[], struct nlattr *data[])
 }
 
 static int ppp_nl_newlink(struct net *src_net, struct net_device *dev,
-			  struct nlattr *tb[], struct nlattr *data[])
+			  struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	struct ppp_config conf = {
 		.unit = -1,
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 629a412dc690..bbe97bb7c9cc 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2101,7 +2101,8 @@ static void team_setup(struct net_device *dev)
 }
 
 static int team_newlink(struct net *src_net, struct net_device *dev,
-			struct nlattr *tb[], struct nlattr *data[])
+			struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS] == NULL)
 		eth_hw_addr_random(dev);
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 0156fe8cac17..3db907cb7d07 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -347,7 +347,8 @@ static int veth_validate(struct nlattr *tb[], struct nlattr *data[])
 static struct rtnl_link_ops veth_link_ops;
 
 static int veth_newlink(struct net *src_net, struct net_device *dev,
-			 struct nlattr *tb[], struct nlattr *data[])
+			struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
 {
 	int err;
 	struct net_device *peer;
diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 997ef25189fd..762f4d033e1b 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -1389,7 +1389,8 @@ static void vrf_dellink(struct net_device *dev, struct list_head *head)
 }
 
 static int vrf_newlink(struct net *src_net, struct net_device *dev,
-		       struct nlattr *tb[], struct nlattr *data[])
+		       struct nlattr *tb[], struct nlattr *data[],
+		       struct netlink_ext_ack *extack)
 {
 	struct net_vrf *vrf = netdev_priv(dev);
 	bool *add_fib_rules;
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 653b2bb32be1..50a208747179 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -3333,7 +3333,8 @@ static int vxlan_nl2conf(struct nlattr *tb[], struct nlattr *data[],
 }
 
 static int vxlan_newlink(struct net *src_net, struct net_device *dev,
-			 struct nlattr *tb[], struct nlattr *data[])
+			 struct nlattr *tb[], struct nlattr *data[],
+			 struct netlink_ext_ack *extack)
 {
 	struct vxlan_config conf;
 	int err;
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 78fa5fe32947..33332a104ac5 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -68,7 +68,8 @@ struct rtnl_link_ops {
 	int			(*newlink)(struct net *src_net,
 					   struct net_device *dev,
 					   struct nlattr *tb[],
-					   struct nlattr *data[]);
+					   struct nlattr *data[],
+					   struct netlink_ext_ack *extack);
 	int			(*changelink)(struct net_device *dev,
 					      struct nlattr *tb[],
 					      struct nlattr *data[]);
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index 9c94aad153b3..11b74e2b1036 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -115,7 +115,8 @@ static int vlan_changelink(struct net_device *dev,
 }
 
 static int vlan_newlink(struct net *src_net, struct net_device *dev,
-			struct nlattr *tb[], struct nlattr *data[])
+			struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
 {
 	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	struct net_device *real_dev;
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 63dca347b73b..39c1fa104c8d 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -1213,7 +1213,8 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 }
 
 static int br_dev_newlink(struct net *src_net, struct net_device *dev,
-			  struct nlattr *tb[], struct nlattr *data[])
+			  struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	struct net_bridge *br = netdev_priv(dev);
 	int err;
diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index fe3c53efb949..3ad833cd042f 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -461,7 +461,8 @@ static void caif_netlink_parms(struct nlattr *data[],
 }
 
 static int ipcaif_newlink(struct net *src_net, struct net_device *dev,
-			  struct nlattr *tb[], struct nlattr *data[])
+			  struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	int ret;
 	struct chnl_net *caifdev;
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9a1bd510c812..8b3faa00905f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2705,7 +2705,8 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 		dev->ifindex = ifm->ifi_index;
 
 		if (ops->newlink) {
-			err = ops->newlink(link_net ? : net, dev, tb, data);
+			err = ops->newlink(link_net ? : net, dev, tb, data,
+					   extack);
 			/* Drivers should call free_netdev() in ->destructor
 			 * and unregister it on failure after registration
 			 * so that device could be finally freed in rtnl_unlock.
diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
index 81dac16933fc..b9cce0fd5696 100644
--- a/net/hsr/hsr_netlink.c
+++ b/net/hsr/hsr_netlink.c
@@ -33,7 +33,8 @@ static const struct nla_policy hsr_policy[IFLA_HSR_MAX + 1] = {
  * hsr_dev_setup routine has been executed. Nice!
  */
 static int hsr_newlink(struct net *src_net, struct net_device *dev,
-		       struct nlattr *tb[], struct nlattr *data[])
+		       struct nlattr *tb[], struct nlattr *data[],
+		       struct netlink_ext_ack *extack)
 {
 	struct net_device *link[2];
 	unsigned char multicast_spec, hsr_version;
diff --git a/net/ieee802154/6lowpan/core.c b/net/ieee802154/6lowpan/core.c
index 0a866f332290..1a4c585f3950 100644
--- a/net/ieee802154/6lowpan/core.c
+++ b/net/ieee802154/6lowpan/core.c
@@ -121,7 +121,8 @@ static int lowpan_validate(struct nlattr *tb[], struct nlattr *data[])
 }
 
 static int lowpan_newlink(struct net *src_net, struct net_device *ldev,
-			  struct nlattr *tb[], struct nlattr *data[])
+			  struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	struct net_device *wdev;
 	int ret;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 41394a4b9af9..989f29f2f0d5 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -957,7 +957,8 @@ static void ipgre_tap_setup(struct net_device *dev)
 }
 
 static int ipgre_newlink(struct net *src_net, struct net_device *dev,
-			 struct nlattr *tb[], struct nlattr *data[])
+			 struct nlattr *tb[], struct nlattr *data[],
+			 struct netlink_ext_ack *extack)
 {
 	struct ip_tunnel_parm p;
 	struct ip_tunnel_encap ipencap;
@@ -1155,7 +1156,7 @@ struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
 	t = netdev_priv(dev);
 	t->collect_md = true;
 
-	err = ipgre_newlink(net, dev, tb, NULL);
+	err = ipgre_newlink(net, dev, tb, NULL, NULL);
 	if (err < 0) {
 		free_netdev(dev);
 		return ERR_PTR(err);
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 4ec9affb2252..d748c5017d3b 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -503,7 +503,8 @@ static void vti_netlink_parms(struct nlattr *data[],
 }
 
 static int vti_newlink(struct net *src_net, struct net_device *dev,
-		       struct nlattr *tb[], struct nlattr *data[])
+		       struct nlattr *tb[], struct nlattr *data[],
+		       struct netlink_ext_ack *extack)
 {
 	struct ip_tunnel_parm parms;
 	__u32 fwmark = 0;
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 1e441c6f2160..51132060397d 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -469,7 +469,8 @@ static bool ipip_netlink_encap_parms(struct nlattr *data[],
 }
 
 static int ipip_newlink(struct net *src_net, struct net_device *dev,
-			struct nlattr *tb[], struct nlattr *data[])
+			struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
 	struct ip_tunnel_parm p;
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index e0e726c338a7..f7c949d41fda 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1342,7 +1342,8 @@ static bool ip6gre_netlink_encap_parms(struct nlattr *data[],
 }
 
 static int ip6gre_newlink(struct net *src_net, struct net_device *dev,
-	struct nlattr *tb[], struct nlattr *data[])
+			  struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	struct ip6_tnl *nt;
 	struct net *net = dev_net(dev);
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 8c6c3c8e7eef..ca12b2e33ae3 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1974,7 +1974,8 @@ static bool ip6_tnl_netlink_encap_parms(struct nlattr *data[],
 }
 
 static int ip6_tnl_newlink(struct net *src_net, struct net_device *dev,
-			   struct nlattr *tb[], struct nlattr *data[])
+			   struct nlattr *tb[], struct nlattr *data[],
+			   struct netlink_ext_ack *extack)
 {
 	struct net *net = dev_net(dev);
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 837ea1eefe7f..736a4f3f731d 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -940,7 +940,8 @@ static void vti6_netlink_parms(struct nlattr *data[],
 }
 
 static int vti6_newlink(struct net *src_net, struct net_device *dev,
-			struct nlattr *tb[], struct nlattr *data[])
+			struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
 {
 	struct net *net = dev_net(dev);
 	struct ip6_tnl *nt;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 2378503577b0..f7445fdb5e64 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1537,7 +1537,8 @@ static bool ipip6_netlink_6rd_parms(struct nlattr *data[],
 #endif
 
 static int ipip6_newlink(struct net *src_net, struct net_device *dev,
-			 struct nlattr *tb[], struct nlattr *data[])
+			 struct nlattr *tb[], struct nlattr *data[],
+			 struct netlink_ext_ack *extack)
 {
 	struct net *net = dev_net(dev);
 	struct ip_tunnel *nt;
-- 
2.13.1
