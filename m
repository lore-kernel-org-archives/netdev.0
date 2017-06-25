From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: [PATCH net-next v2 4/5] net: add netlink_ext_ack argument to rtnl_link_ops.slave_changelink
Date: Sun, 25 Jun 2017 23:56:02 +0200
Message-ID: <498ff06f59d5ce13b2ad3e1c1902c3d348ca3c00.1498425679.git.mschiffer@universe-factory.net>
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
Received: from chaos.universe-factory.net ([31.24.148.19]:42976 "EHLO
        chaos.universe-factory.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751349AbdFYV4R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2017 17:56:17 -0400
In-Reply-To: <cover.1498425679.git.mschiffer@universe-factory.net>
In-Reply-To: <cover.1498425679.git.mschiffer@universe-factory.net>
References: <cover.1498425679.git.mschiffer@universe-factory.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for extended error reporting.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
---
 drivers/net/bonding/bond_netlink.c | 3 ++-
 include/net/rtnetlink.h            | 3 ++-
 net/bridge/br_netlink.c            | 3 ++-
 net/core/rtnetlink.c               | 3 ++-
 4 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 0a9d78de6138..a1b33aa6054a 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -132,7 +132,8 @@ static int bond_validate(struct nlattr *tb[], struct nlattr *data[],
 
 static int bond_slave_changelink(struct net_device *bond_dev,
 				 struct net_device *slave_dev,
-				 struct nlattr *tb[], struct nlattr *data[])
+				 struct nlattr *tb[], struct nlattr *data[],
+				 struct netlink_ext_ack *extack)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct bond_opt_value newval;
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 11fe0ad60e43..baf99e173dca 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -95,7 +95,8 @@ struct rtnl_link_ops {
 	int			(*slave_changelink)(struct net_device *dev,
 						    struct net_device *slave_dev,
 						    struct nlattr *tb[],
-						    struct nlattr *data[]);
+						    struct nlattr *data[],
+						    struct netlink_ext_ack *extack);
 	size_t			(*get_slave_size)(const struct net_device *dev,
 						  const struct net_device *slave_dev);
 	int			(*fill_slave_info)(struct sk_buff *skb,
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 9af177ca4d31..3bc890716c89 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -897,7 +897,8 @@ static int br_validate(struct nlattr *tb[], struct nlattr *data[],
 static int br_port_slave_changelink(struct net_device *brdev,
 				    struct net_device *dev,
 				    struct nlattr *tb[],
-				    struct nlattr *data[])
+				    struct nlattr *data[],
+				    struct netlink_ext_ack *extack)
 {
 	struct net_bridge *br = netdev_priv(brdev);
 	int ret;
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 7136588e65e9..658a48959fc4 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2631,7 +2631,8 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 					return -EOPNOTSUPP;
 
 				err = m_ops->slave_changelink(master_dev, dev,
-							      tb, slave_data);
+							      tb, slave_data,
+							      extack);
 				if (err < 0)
 					return err;
 				status |= DO_SETLINK_NOTIFY;
-- 
2.13.1
