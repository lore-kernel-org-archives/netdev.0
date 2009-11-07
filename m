From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] rtnetlink: Cleanups
Date: Sat, 07 Nov 2009 07:23:17 +0100
Message-ID: <4AF51255.909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:32777 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750848AbZKGGXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2009 01:23:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pure cleanups patch

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/rtnetlink.c |   54 +++++++++++++++++------------------------
 1 files changed, 23 insertions(+), 31 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 391a62c..e2f3317 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -38,7 +38,6 @@
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
-#include <asm/string.h>
 
 #include <linux/inet.h>
 #include <linux/netdevice.h>
@@ -53,8 +52,7 @@
 #include <net/rtnetlink.h>
 #include <net/net_namespace.h>
 
-struct rtnl_link
-{
+struct rtnl_link {
 	rtnl_doit_func		doit;
 	rtnl_dumpit_func	dumpit;
 };
@@ -65,6 +63,7 @@ void rtnl_lock(void)
 {
 	mutex_lock(&rtnl_mutex);
 }
+EXPORT_SYMBOL(rtnl_lock);
 
 void __rtnl_unlock(void)
 {
@@ -76,16 +75,19 @@ void rtnl_unlock(void)
 	/* This fellow will unlock it for us. */
 	netdev_run_todo();
 }
+EXPORT_SYMBOL(rtnl_unlock);
 
 int rtnl_trylock(void)
 {
 	return mutex_trylock(&rtnl_mutex);
 }
+EXPORT_SYMBOL(rtnl_trylock);
 
 int rtnl_is_locked(void)
 {
 	return mutex_is_locked(&rtnl_mutex);
 }
+EXPORT_SYMBOL(rtnl_is_locked);
 
 static struct rtnl_link *rtnl_msg_handlers[NPROTO];
 
@@ -168,7 +170,6 @@ int __rtnl_register(int protocol, int msgtype,
 
 	return 0;
 }
-
 EXPORT_SYMBOL_GPL(__rtnl_register);
 
 /**
@@ -188,7 +189,6 @@ void rtnl_register(int protocol, int msgtype,
 		      "protocol = %d, message type = %d\n",
 		      protocol, msgtype);
 }
-
 EXPORT_SYMBOL_GPL(rtnl_register);
 
 /**
@@ -213,7 +213,6 @@ int rtnl_unregister(int protocol, int msgtype)
 
 	return 0;
 }
-
 EXPORT_SYMBOL_GPL(rtnl_unregister);
 
 /**
@@ -230,7 +229,6 @@ void rtnl_unregister_all(int protocol)
 	kfree(rtnl_msg_handlers[protocol]);
 	rtnl_msg_handlers[protocol] = NULL;
 }
-
 EXPORT_SYMBOL_GPL(rtnl_unregister_all);
 
 static LIST_HEAD(link_ops);
@@ -253,7 +251,6 @@ int __rtnl_link_register(struct rtnl_link_ops *ops)
 	list_add_tail(&ops->list, &link_ops);
 	return 0;
 }
-
 EXPORT_SYMBOL_GPL(__rtnl_link_register);
 
 /**
@@ -271,7 +268,6 @@ int rtnl_link_register(struct rtnl_link_ops *ops)
 	rtnl_unlock();
 	return err;
 }
-
 EXPORT_SYMBOL_GPL(rtnl_link_register);
 
 static void __rtnl_kill_links(struct net *net, struct rtnl_link_ops *ops)
@@ -309,7 +305,6 @@ void __rtnl_link_unregister(struct rtnl_link_ops *ops)
 	}
 	list_del(&ops->list);
 }
-
 EXPORT_SYMBOL_GPL(__rtnl_link_unregister);
 
 /**
@@ -322,7 +317,6 @@ void rtnl_link_unregister(struct rtnl_link_ops *ops)
 	__rtnl_link_unregister(ops);
 	rtnl_unlock();
 }
-
 EXPORT_SYMBOL_GPL(rtnl_link_unregister);
 
 static const struct rtnl_link_ops *rtnl_link_ops_get(const char *kind)
@@ -427,12 +421,13 @@ void __rta_fill(struct sk_buff *skb, int attrtype, int attrlen, const void *data
 	struct rtattr *rta;
 	int size = RTA_LENGTH(attrlen);
 
-	rta = (struct rtattr*)skb_put(skb, RTA_ALIGN(size));
+	rta = (struct rtattr *)skb_put(skb, RTA_ALIGN(size));
 	rta->rta_type = attrtype;
 	rta->rta_len = size;
 	memcpy(RTA_DATA(rta), data, attrlen);
 	memset(RTA_DATA(rta) + attrlen, 0, RTA_ALIGN(size) - size);
 }
+EXPORT_SYMBOL(__rta_fill);
 
 int rtnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, unsigned group, int echo)
 {
@@ -454,6 +449,7 @@ int rtnl_unicast(struct sk_buff *skb, struct net *net, u32 pid)
 
 	return nlmsg_unicast(rtnl, skb, pid);
 }
+EXPORT_SYMBOL(rtnl_unicast);
 
 void rtnl_notify(struct sk_buff *skb, struct net *net, u32 pid, u32 group,
 		 struct nlmsghdr *nlh, gfp_t flags)
@@ -466,6 +462,7 @@ void rtnl_notify(struct sk_buff *skb, struct net *net, u32 pid, u32 group,
 
 	nlmsg_notify(rtnl, skb, pid, group, report, flags);
 }
+EXPORT_SYMBOL(rtnl_notify);
 
 void rtnl_set_sk_err(struct net *net, u32 group, int error)
 {
@@ -473,6 +470,7 @@ void rtnl_set_sk_err(struct net *net, u32 group, int error)
 
 	netlink_set_err(rtnl, 0, group, error);
 }
+EXPORT_SYMBOL(rtnl_set_sk_err);
 
 int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics)
 {
@@ -501,6 +499,7 @@ nla_put_failure:
 	nla_nest_cancel(skb, mx);
 	return -EMSGSIZE;
 }
+EXPORT_SYMBOL(rtnetlink_put_metrics);
 
 int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst, u32 id,
 		       u32 ts, u32 tsage, long expires, u32 error)
@@ -520,14 +519,13 @@ int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst, u32 id,
 
 	return nla_put(skb, RTA_CACHEINFO, sizeof(ci), &ci);
 }
-
 EXPORT_SYMBOL_GPL(rtnl_put_cacheinfo);
 
 static void set_operstate(struct net_device *dev, unsigned char transition)
 {
 	unsigned char operstate = dev->operstate;
 
-	switch(transition) {
+	switch (transition) {
 	case IF_OPER_UP:
 		if ((operstate == IF_OPER_DORMANT ||
 		     operstate == IF_OPER_UNKNOWN) &&
@@ -728,6 +726,7 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_NET_NS_PID]	= { .type = NLA_U32 },
 	[IFLA_IFALIAS]	        = { .type = NLA_STRING, .len = IFALIASZ-1 },
 };
+EXPORT_SYMBOL(ifla_policy);
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
 	[IFLA_INFO_KIND]	= { .type = NLA_STRING },
@@ -932,7 +931,8 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		goto errout;
 	}
 
-	if ((err = validate_linkmsg(dev, tb)) < 0)
+	err = validate_linkmsg(dev, tb);
+	if (err < 0)
 		goto errout;
 
 	err = do_setlink(dev, ifm, tb, ifname, 0);
@@ -985,7 +985,8 @@ struct net_device *rtnl_create_link(struct net *net, char *ifname,
 	unsigned int real_num_queues = 1;
 
 	if (ops->get_tx_queues) {
-		err = ops->get_tx_queues(net, tb, &num_queues, &real_num_queues);
+		err = ops->get_tx_queues(net, tb, &num_queues,
+					 &real_num_queues);
 		if (err)
 			goto err;
 	}
@@ -1026,6 +1027,7 @@ err_free:
 err:
 	return ERR_PTR(err);
 }
+EXPORT_SYMBOL(rtnl_create_link);
 
 static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
@@ -1059,7 +1061,8 @@ replay:
 	else
 		dev = NULL;
 
-	if ((err = validate_linkmsg(dev, tb)) < 0)
+	err = validate_linkmsg(dev, tb);
+	if (err < 0)
 		return err;
 
 	if (tb[IFLA_LINKINFO]) {
@@ -1210,7 +1213,7 @@ static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
 
 	if (s_idx == 0)
 		s_idx = 1;
-	for (idx=1; idx<NPROTO; idx++) {
+	for (idx = 1; idx < NPROTO; idx++) {
 		int type = cb->nlh->nlmsg_type-RTM_BASE;
 		if (idx < s_idx || idx == PF_PACKET)
 			continue;
@@ -1277,7 +1280,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (nlh->nlmsg_len < NLMSG_LENGTH(sizeof(struct rtgenmsg)))
 		return 0;
 
-	family = ((struct rtgenmsg*)NLMSG_DATA(nlh))->rtgen_family;
+	family = ((struct rtgenmsg *)NLMSG_DATA(nlh))->rtgen_family;
 	if (family >= NPROTO)
 		return -EAFNOSUPPORT;
 
@@ -1310,7 +1313,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	if (nlh->nlmsg_len > min_len) {
 		int attrlen = nlh->nlmsg_len - NLMSG_ALIGN(min_len);
-		struct rtattr *attr = (void*)nlh + NLMSG_ALIGN(min_len);
+		struct rtattr *attr = (void *)nlh + NLMSG_ALIGN(min_len);
 
 		while (RTA_OK(attr, attrlen)) {
 			unsigned flavor = attr->rta_type;
@@ -1416,14 +1419,3 @@ void __init rtnetlink_init(void)
 	rtnl_register(PF_UNSPEC, RTM_GETROUTE, NULL, rtnl_dump_all);
 }
 
-EXPORT_SYMBOL(__rta_fill);
-EXPORT_SYMBOL(rtnetlink_put_metrics);
-EXPORT_SYMBOL(rtnl_lock);
-EXPORT_SYMBOL(rtnl_trylock);
-EXPORT_SYMBOL(rtnl_unlock);
-EXPORT_SYMBOL(rtnl_is_locked);
-EXPORT_SYMBOL(rtnl_unicast);
-EXPORT_SYMBOL(rtnl_notify);
-EXPORT_SYMBOL(rtnl_set_sk_err);
-EXPORT_SYMBOL(rtnl_create_link);
-EXPORT_SYMBOL(ifla_policy);
