From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: [PATCH net-next v2 5/5] net: add netlink_ext_ack argument to rtnl_link_ops.slave_validate
Date: Sun, 25 Jun 2017 23:56:03 +0200
Message-ID: <ae78184571760c3430159ea5a654e3d08ba2479d.1498425679.git.mschiffer@universe-factory.net>
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
Received: from chaos.universe-factory.net ([31.24.148.19]:43018 "EHLO
        chaos.universe-factory.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751443AbdFYV4S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2017 17:56:18 -0400
In-Reply-To: <cover.1498425679.git.mschiffer@universe-factory.net>
In-Reply-To: <cover.1498425679.git.mschiffer@universe-factory.net>
References: <cover.1498425679.git.mschiffer@universe-factory.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for extended error reporting.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
---
 include/net/rtnetlink.h | 3 ++-
 net/core/rtnetlink.c    | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index baf99e173dca..abe6b733d473 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -91,7 +91,8 @@ struct rtnl_link_ops {
 	int			slave_maxtype;
 	const struct nla_policy	*slave_policy;
 	int			(*slave_validate)(struct nlattr *tb[],
-						  struct nlattr *data[]);
+						  struct nlattr *data[],
+						  struct netlink_ext_ack *extack);
 	int			(*slave_changelink)(struct net_device *dev,
 						    struct net_device *slave_dev,
 						    struct nlattr *tb[],
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 658a48959fc4..ed51de525a88 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2601,7 +2601,8 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 				slave_data = slave_attr;
 			}
 			if (m_ops->slave_validate) {
-				err = m_ops->slave_validate(tb, slave_data);
+				err = m_ops->slave_validate(tb, slave_data,
+							    extack);
 				if (err < 0)
 					return err;
 			}
-- 
2.13.1
