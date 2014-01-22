From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/5] rtnetlink: put "BOND" into nl attribute names which are related to bonding
Date: Wed, 22 Jan 2014 09:05:54 +0100
Message-ID: <1390377957-31466-3-git-send-email-jiri@resnulli.us>
References: <1390377957-31466-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, sfeldma@cumulusnetworks.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	nicolas.dichtel@6wind.com, john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:44810 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbaAVIGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 03:06:06 -0500
Received: by mail-ea0-f178.google.com with SMTP id a15so3174710eae.37
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 00:06:05 -0800 (PST)
In-Reply-To: <1390377957-31466-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_netlink.c | 12 ++++++------
 include/uapi/linux/if_link.h       | 19 ++++++++++---------
 net/core/rtnetlink.c               | 16 ++++++++--------
 3 files changed, 24 insertions(+), 23 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 21c6488..dd786a3 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -27,27 +27,27 @@ int bond_get_slave(struct net_device *slave_dev, struct sk_buff *skb)
 	struct slave *slave = bond_slave_get_rtnl(slave_dev);
 	const struct aggregator *agg;
 
-	if (nla_put_u8(skb, IFLA_SLAVE_STATE, bond_slave_state(slave)))
+	if (nla_put_u8(skb, IFLA_BOND_SLAVE_STATE, bond_slave_state(slave)))
 		goto nla_put_failure;
 
-	if (nla_put_u8(skb, IFLA_SLAVE_MII_STATUS, slave->link))
+	if (nla_put_u8(skb, IFLA_BOND_SLAVE_MII_STATUS, slave->link))
 		goto nla_put_failure;
 
-	if (nla_put_u32(skb, IFLA_SLAVE_LINK_FAILURE_COUNT,
+	if (nla_put_u32(skb, IFLA_BOND_SLAVE_LINK_FAILURE_COUNT,
 			slave->link_failure_count))
 		goto nla_put_failure;
 
-	if (nla_put(skb, IFLA_SLAVE_PERM_HWADDR,
+	if (nla_put(skb, IFLA_BOND_SLAVE_PERM_HWADDR,
 		    slave_dev->addr_len, slave->perm_hwaddr))
 		goto nla_put_failure;
 
-	if (nla_put_u16(skb, IFLA_SLAVE_QUEUE_ID, slave->queue_id))
+	if (nla_put_u16(skb, IFLA_BOND_SLAVE_QUEUE_ID, slave->queue_id))
 		goto nla_put_failure;
 
 	if (slave->bond->params.mode == BOND_MODE_8023AD) {
 		agg = SLAVE_AD_INFO(slave).port.aggregator;
 		if (agg)
-			if (nla_put_u16(skb, IFLA_SLAVE_AD_AGGREGATOR_ID,
+			if (nla_put_u16(skb, IFLA_BOND_SLAVE_AD_AGGREGATOR_ID,
 					agg->aggregator_identifier))
 				goto nla_put_failure;
 	}
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index ba2f3bf..1f30b85 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -144,7 +144,7 @@ enum {
 	IFLA_NUM_RX_QUEUES,
 	IFLA_CARRIER,
 	IFLA_PHYS_PORT_ID,
-	IFLA_SLAVE,
+	IFLA_BOND_SLAVE,
 	__IFLA_MAX
 };
 
@@ -370,16 +370,17 @@ enum {
 #define IFLA_BOND_AD_INFO_MAX	(__IFLA_BOND_AD_INFO_MAX - 1)
 
 enum {
-	IFLA_SLAVE_STATE,
-	IFLA_SLAVE_MII_STATUS,
-	IFLA_SLAVE_LINK_FAILURE_COUNT,
-	IFLA_SLAVE_PERM_HWADDR,
-	IFLA_SLAVE_QUEUE_ID,
-	IFLA_SLAVE_AD_AGGREGATOR_ID,
-	__IFLA_SLAVE_MAX,
+	IFLA_BOND_SLAVE_UNSPEC,
+	IFLA_BOND_SLAVE_STATE,
+	IFLA_BOND_SLAVE_MII_STATUS,
+	IFLA_BOND_SLAVE_LINK_FAILURE_COUNT,
+	IFLA_BOND_SLAVE_PERM_HWADDR,
+	IFLA_BOND_SLAVE_QUEUE_ID,
+	IFLA_BOND_SLAVE_AD_AGGREGATOR_ID,
+	__IFLA_BOND_SLAVE_MAX,
 };
 
-#define IFLA_SLAVE_MAX	(__IFLA_SLAVE_MAX - 1)
+#define IFLA_BOND_SLAVE_MAX	(__IFLA_BOND_SLAVE_MAX - 1)
 
 /* SR-IOV virtual function management section */
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 4f85de7..cace149 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -725,13 +725,13 @@ static size_t rtnl_bond_slave_size(const struct net_device *dev)
 {
 	struct net_device *bond;
 	size_t slave_size =
-		nla_total_size(sizeof(struct nlattr)) +	/* IFLA_SLAVE */
-		nla_total_size(1) +	/* IFLA_SLAVE_STATE */
-		nla_total_size(1) +	/* IFLA_SLAVE_MII_STATUS */
-		nla_total_size(4) +	/* IFLA_SLAVE_LINK_FAILURE_COUNT */
-		nla_total_size(MAX_ADDR_LEN) +	/* IFLA_SLAVE_PERM_HWADDR */
-		nla_total_size(2) +	/* IFLA_SLAVE_QUEUE_ID */
-		nla_total_size(2) +	/* IFLA_SLAVE_AD_AGGREGATOR_ID */
+		nla_total_size(sizeof(struct nlattr)) +	/* IFLA_BOND_SLAVE */
+		nla_total_size(1) +	/* IFLA_BOND_SLAVE_STATE */
+		nla_total_size(1) +	/* IFLA_BOND_SLAVE_MII_STATUS */
+		nla_total_size(4) +	/* IFLA_BOND_SLAVE_LINK_FAILURE_COUNT */
+		nla_total_size(MAX_ADDR_LEN) +	/* IFLA_BOND_SLAVE_PERM_HWADDR */
+		nla_total_size(2) +	/* IFLA_BOND_SLAVE_QUEUE_ID */
+		nla_total_size(2) +	/* IFLA_BOND_SLAVE_AD_AGGREGATOR_ID */
 		0;
 
 	if (netif_is_bond_slave((struct net_device *)dev)) {
@@ -883,7 +883,7 @@ static size_t rtnl_bond_slave_fill(struct sk_buff *skb, struct net_device *dev)
 	if (!bond || !bond->netdev_ops->ndo_get_slave)
 		return 0;
 
-	nest = nla_nest_start(skb, IFLA_SLAVE);
+	nest = nla_nest_start(skb, IFLA_BOND_SLAVE);
 	if (!nest)
 		return -EMSGSIZE;
 
-- 
1.8.3.1
